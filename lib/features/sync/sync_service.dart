import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../auth/auth_service.dart';
import '../profile/profile_service.dart';
import 'restore_service.dart';

/// Synchronisation vers Firestore : agents/{uid}/patients|consultations/{id}.
/// Principes : ecriture idempotente (meme id + merge), timeout obligatoire (une ecriture Firestore
/// hors ligne ne se termine qu'au retour du reseau), jamais de suppression locale en cas d'erreur (R10).
/// En mode demo (kUseFirebase = false), l'envoi est SIMULE : ne pas presenter comme une vraie synchro.
class SyncService {
  SyncService(this.repo, this.auth);
  final SuraRepo repo;
  final AuthService auth;
  bool _running = false;

  Future<bool> online() async {
    final r = await Connectivity().checkConnectivity();
    return !r.contains(ConnectivityResult.none);
  }

  Future<void> run() async {
    if (_running) return;
    _running = true;
    try {
      if (!await online()) return;
      await ProfileService.pushIfDirty(auth.agentId);
      if (await repo.isLocalEmpty()) {
        // Appareil vide (reinstallation, nouvel appareil) : on recupere d'abord les donnees du serveur.
        try {
          await restoreFromServer(repo, auth.agentId);
        } catch (_) {}
      }
      // Les patients d'abord : une consultation ne doit pas arriver avant son patient.
      for (final p in await repo.patientsToSync()) {
        await repo.setPatientSync(p.id, 'syncing');
        try {
          await _push('patients', p.id, {
            'id': p.id,
            'familyName': p.familyName,
            'firstName': p.firstName,
            'ageYears': p.ageYears,
            'ageRecordedAt': p.ageRecordedAt.toIso8601String(),
            'sex': p.sex,
            'village': p.village,
            'createdBy': p.createdBy,
            'createdAt': p.createdAt.toIso8601String(),
          });
          await repo.setPatientSync(p.id, 'synced');
        } catch (e) {
          await repo.setPatientSync(p.id, 'error', error: '$e');
        }
      }
      for (final c in await repo.consultationsToSync()) {
        await repo.setConsultationSync(c.id, 'syncing');
        try {
          await _push('consultations', c.id, {
            'id': c.id,
            'patientId': c.patientId,
            'agentId': c.agentId,
            'mode': c.mode,
            'consent': c.consent,
            'consentAt': c.consentAt?.toIso8601String(),
            'structured': c.structuredJson,
            'urgencyProposed': c.urgencyProposed,
            'urgencyFinal': c.urgencyFinal,
            'reasons': c.reasonsJson,
            if (kUploadTranscript) 'transcript': c.transcript,
            'validatedAt': c.validatedAt?.toIso8601String(),
            'createdAt': c.createdAt.toIso8601String(),
            // L'audio n'est jamais envoye (R17).
          });
          await repo.setConsultationSync(c.id, 'synced');
        } catch (e) {
          await repo.setConsultationSync(c.id, 'error', error: '$e');
        }
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _push(
      String collection, String id, Map<String, dynamic> data) async {
    if (!kUseFirebase) {
      await Future.delayed(
          const Duration(milliseconds: 700)); // simulation (mode demo)
      return;
    }
    await FirebaseFirestore.instance
        .collection('agents')
        .doc(auth.agentId)
        .collection(collection)
        .doc(id)
        .set({...data, 'syncedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true)).timeout(const Duration(seconds: 15));
  }
}

/// Etat reseau pour l'interface (R15) : separe du statut de chaque consultation.
final onlineProvider = StreamProvider<bool>((ref) async* {
  final c = Connectivity();
  yield !(await c.checkConnectivity()).contains(ConnectivityResult.none);
  yield* c.onConnectivityChanged
      .map((r) => !r.contains(ConnectivityResult.none));
});

/// Lance la synchronisation au demarrage (session deverrouillee) et a chaque retour du reseau.
final syncAutoProvider = Provider<void>((ref) {
  final unlocked = ref.watch(sessionProvider.select((s) => s.unlocked));
  if (!unlocked) return;
  final svc = ref.watch(syncServiceProvider);
  final sub = Connectivity().onConnectivityChanged.listen((r) {
    if (!r.contains(ConnectivityResult.none)) svc.run();
  });
  ref.onDispose(sub.cancel);
  svc.run();
});
