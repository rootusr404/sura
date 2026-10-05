/// Propriétaire : Membre 2 (C-02). Implémentation finale : package `record`.
abstract class AudioRecorderService {
  Future<bool> requestPermission();
  Future<void> start();

  /// Arrête et renvoie le chemin du fichier audio (stocké localement, jamais synchronisé).
  Future<String> stop();
  Future<void> cancel();
}
