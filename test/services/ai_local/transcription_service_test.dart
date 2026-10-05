import 'package:flutter_test/flutter_test.dart';
import 'package:sura/services/ai_local/transcription_service.dart';

void main() {
  group('C-03 : TranscriptionService & Mode Avion', () {
    test('1. Transcription hors ligne réussie avec texte par défaut', () async {
      final service = LocalTranscriptionService();
      final text = await service.transcribe('/tmp/sample.m4a');

      expect(text, isNotEmpty);
      expect(text, contains('fièvre persistante'));
      expect(text, contains('39,4 °C'));
      service.dispose();
    });

    test('2. Transcription avec texte personnalisé pour démonstration', () async {
      const demoTranscript =
          "Enfant de 3 ans présentant une diarrhée profuse et vomissements depuis 24h.";
      final service = LocalTranscriptionService(mockTextOverride: demoTranscript);

      final text = await service.transcribe('/tmp/sample.m4a');
      expect(text, equals(demoTranscript));
      service.dispose();
    });

    test('3. Repli gracieux : levée de TranscriptionEngineException en cas d\'échec', () async {
      final service = LocalTranscriptionService(shouldSimulateFailure: true);

      expect(
        () => service.transcribe('/tmp/corrupted.m4a'),
        throwsA(isA<TranscriptionEngineException>()),
      );
      service.dispose();
    });

    test('4. Émission des paliers de progression pour indicateur UI', () async {
      final service = LocalTranscriptionService();
      final progressValues = <double>[];

      final sub = service.progressStream.listen((p) {
        progressValues.add(p);
      });

      await service.transcribe('/tmp/sample.m4a');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(progressValues, isNotEmpty);
      expect(progressValues.first, greaterThan(0.0));
      expect(progressValues.last, equals(1.0));

      await sub.cancel();
      service.dispose();
    });
  });
}
