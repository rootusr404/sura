class TranscriptionResult {
  const TranscriptionResult({
    required this.text,
    required this.engine,
    this.duration = Duration.zero,
  });
  final String text;

  /// 'whisper_edge' | 'vosk' | 'fake' | 'manual'
  final String engine;
  final Duration duration;
}

/// Propriétaire : Membre 2 (C-01/C-03). Doit fonctionner hors ligne.
/// Le moteur est choisi après le test C-01 ; l'interface ne change pas.
abstract class TranscriptionService {
  String get engine;

  /// Charge le modèle (peut être long). Idempotent.
  Future<void> prepare();
  Future<TranscriptionResult> transcribe(String audioPath);
}
