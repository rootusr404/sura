import '../models/records.dart';
import '../models/enums.dart';

/// Propriétaire : Membre 1 (F-02). Implémentation finale : Drift.
abstract class PatientRepository {
  /// Génère l'identifiant SUR-XXXX-XXXX et enregistre localement (syncState = pending).
  Future<PatientRecord> create({
    required String lastName,
    required String firstName,
    required int ageYears,
    required String sex,
    required String village,
    String? phone,
    required String agentId,
  });

  Future<PatientRecord?> getById(String id);
  Stream<PatientRecord?> watchById(String id);
  Stream<List<PatientRecord>> watchAll();

  /// Recherche par nom, prénom, village ou identifiant (insensible à la casse).
  Future<List<PatientRecord>> search(String query);

  /// Mise à jour atomique de l'état, uniquement pour la version envoyée.
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
