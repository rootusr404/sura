import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sura/domain/models/records.dart';

import 'repository_sync_service.dart';

/// Liste explicite des champs : aucun fichier audio ni chemin local.
Map<String, dynamic> patientSyncData(PatientRecord p) => {
  'id': p.id,
  'lastName': p.lastName,
  'firstName': p.firstName,
  'ageYears': p.ageYears,
  'ageRecordedAt': p.ageRecordedAt,
  'sex': p.sex,
  'village': p.village,
  'phone': p.phone,
  'createdByAgentId': p.createdByAgentId,
  'createdAt': p.createdAt,
  'updatedAt': p.updatedAt,
};

Map<String, dynamic> consultationSyncData(ConsultationRecord c) => {
  'id': c.id,
  'patientId': c.patientId,
  'agentId': c.agentId,
  'status': c.status.name,
  'step': c.step,
  'consent': c.consent?.name,
  'consentAt': c.consentAt,
  'transcriptRaw': c.transcriptRaw,
  'transcriptEdited': c.transcriptEdited,
  'structured': c.structured?.toJson(),
  'missing': c.missing.map((item) => item.toJson()).toList(),
  'urgencyProposal': c.urgencyProposal?.toJson(),
  'urgencyFinal': c.urgencyFinal?.name,
  'urgencyOverrideReason': c.urgencyOverrideReason,
  'checklist': c.checklist,
  'createdAt': c.createdAt,
  'updatedAt': c.updatedAt,
  'validatedAt': c.validatedAt,
};

class FirestoreSyncRemoteStore implements SyncRemoteStore {
  FirestoreSyncRemoteStore(this.firestore);
  final FirebaseFirestore firestore;

  @override
  Future<void> sendPatient(String agentId, PatientRecord patient) =>
      _write(agentId, 'patients', patient.id, patientSyncData(patient));

  @override
  Future<void> sendConsultation(
    String agentId,
    ConsultationRecord consultation,
  ) => _write(
    agentId,
    'consultations',
    consultation.id,
    consultationSyncData(consultation),
  );

  Future<void> _write(
    String agent,
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final document = firestore
        .collection('agents')
        .doc(agent)
        .collection(collection)
        .doc(id);
    // Identifiant stable : un réessai ne crée pas de doublon. La transaction
    // évite qu'un envoi expiré qui aboutit tard écrase une version plus récente.
    // Elle exige le serveur : le cache Firestore n'est pas un accusé de réception.
    await firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(document);
      final remoteVersion = snapshot.data()?['updatedAt'];
      if (remoteVersion is Timestamp &&
          remoteVersion.toDate().isAfter(data['updatedAt'] as DateTime)) {
        return;
      }
      transaction.set(document, data);
    });
  }
}
