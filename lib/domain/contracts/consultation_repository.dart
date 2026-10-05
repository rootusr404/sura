import '../models/records.dart';
import '../models/enums.dart';

/// Propriétaire : Membre 1 (F-02). Implémentation finale : Drift.
/// Tous les écrans du parcours lisent et écrivent la consultation ICI,
/// jamais directement dans la base.
abstract class ConsultationRepository {
  Future<ConsultationRecord> createDraft({
    required String patientId,
    required String agentId,
  });

  Future<ConsultationRecord?> getById(String id);
  Stream<ConsultationRecord?> watchById(String id);
  Stream<List<ConsultationRecord>> watchByPatient(String patientId);
  Stream<List<ConsultationRecord>> watchAll();

  /// Upsert complet (l'appelant fait record.copyWith(...) puis save).
  Future<void> save(ConsultationRecord record);

  /// R9 : passe en « saved », horodate, syncState = pending. Sauvegarde locale d'abord.
  Future<void> markValidated(String id);

  /// Mise à jour atomique : un accusé de réception ancien ne doit jamais
  /// marquer une version modifiée pendant l'envoi comme synchronisée.
  /// Persiste état, tentatives et erreur dans une seule écriture conditionnelle.
  /// attempts == null conserve le compteur; error == null efface l'erreur.
  /// Retourne false si la version a changé, sans aucune modification.
  /// Ne modifie ni les données métier ni updatedAt.
  Future<bool> updateSyncState(
    String id,
    SyncState state, {
    required DateTime expectedUpdatedAt,
    int? attempts,
    String? error,
  });
}
