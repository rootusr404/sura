import '../models/enums.dart';

/// Propriétaire : Membre 4 (S-04). Lit les enregistrements `pending`/`error`
/// dans les repositories, les envoie à Firestore, met à jour syncState.
/// R10/R11 : aucune perte de données, réessai possible. R15 : état toujours visible.
abstract class SyncService {
  /// État global affiché dans l'interface.
  Stream<SyncState> watchOverall();

  /// Envoie tout ce qui est en attente (patients d'abord, puis consultations).
  Future<void> syncPending();

  /// Réessaie une consultation en erreur.
  Future<void> retry(String consultationId);
}
