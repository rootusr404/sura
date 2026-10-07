/// Interface unique : le moteur reel (whisper_edge, repli vosk_flutter) se branche ici apres le POC C-01.
abstract class TranscriptionService {
  Future<String> transcribe(String? audioPath);
}

/// MOCK pour developper et demontrer le parcours sans moteur reel.
class MockTranscriptionService implements TranscriptionService {
  @override
  Future<String> transcribe(String? audioPath) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'La patiente présente une fièvre persistante depuis trois jours, avec des maux de tête '
        'et une toux sèche. Température 39,4 degrés. Elle allaite son enfant de huit mois.';
  }
}
