import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/config.dart';
import '../../data/database.dart';
import '../../data/repository.dart';
import 'restore_mapping.dart';

/// Restauration depuis le serveur (apres reinstallation, nouvel appareil) : agents/{uid}/patients et /consultations.
/// N'ajoute QUE ce qui manque localement (jamais d'ecrasement) ; les elements restaures sont marques "synchronises".
/// Non restaures : brouillons, consultations jamais envoyees, transcriptions (sauf kUploadTranscript).
/// Renvoie un message a afficher a l'agent.
Future<String> restoreFromServer(SuraRepo repo, String uid) async {
  if (!kUseFirebase) {
    return 'Mode démonstration : aucune donnée serveur à restaurer.';
  }
  final net = await Connectivity().checkConnectivity();
  if (net.contains(ConnectivityResult.none)) {
    return 'Pas de connexion Internet : restauration impossible pour le moment.';
  }
  try {
    final base = FirebaseFirestore.instance.collection('agents').doc(uid);
    final ps = await base
        .collection('patients')
        .get()
        .timeout(const Duration(seconds: 25));
    final cs = await base
        .collection('consultations')
        .get()
        .timeout(const Duration(seconds: 25));

    final havePatients =
        (await repo.db.select(repo.db.patients).get()).map((e) => e.id).toSet();
    final haveCons = (await repo.db.select(repo.db.consultations).get())
        .map((e) => e.id)
        .toSet();

    var addedP = 0;
    for (final d in ps.docs) {
      final p = RestoredPatient.fromMap(d.data());
      if (p == null || havePatients.contains(p.id)) continue;
      await repo.insertPatientIfMissing(PatientsCompanion.insert(
        id: p.id,
        familyName: p.familyName,
        firstName: p.firstName,
        ageYears: p.ageYears,
        ageRecordedAt: p.ageRecordedAt,
        sex: p.sex,
        createdBy: p.createdBy,
        createdAt: p.createdAt,
        village: Value(p.village),
        syncStatus: const Value('synced'),
      ));
      addedP++;
    }

    var addedC = 0;
    for (final d in cs.docs) {
      final c = RestoredConsultation.fromMap(d.data());
      if (c == null || haveCons.contains(c.id)) continue;
      await repo.insertConsultationIfMissing(ConsultationsCompanion.insert(
        id: c.id,
        patientId: c.patientId,
        agentId: c.agentId,
        createdAt: c.createdAt,
        mode: Value(c.mode),
        stage: const Value('saved'),
        consent: Value(c.consent),
        consentAt: Value(c.consentAt),
        transcript: Value(c.transcript),
        structuredJson: Value(c.structuredJson),
        urgencyProposed: Value(c.urgencyProposed),
        urgencyFinal: Value(c.urgencyFinal),
        reasonsJson: Value(c.reasonsJson),
        status: const Value('saved'),
        validatedAt: Value(c.validatedAt),
        syncStatus: const Value('synced'),
        syncedAt: Value(DateTime.now()),
      ));
      addedC++;
    }

    if (addedP == 0 && addedC == 0) {
      return 'Rien à restaurer : cet appareil est déjà à jour.';
    }
    return 'Restauration terminée : $addedP patient(s) et $addedC consultation(s) ajoutés.';
  } catch (e) {
    return 'Restauration impossible : $e';
  }
}
