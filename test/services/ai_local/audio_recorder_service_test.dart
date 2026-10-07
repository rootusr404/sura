import 'package:flutter_test/flutter_test.dart';
import 'package:sura/domain/contracts/audio_recorder_service.dart';
import 'package:sura/services/ai_local/audio_recorder_service.dart';

class _FakeRecorder implements AudioRecorderService {
  var started = false;

  @override
  Future<void> cancel() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> start() async => started = true;

  @override
  Future<String> stop() async => 'audio.m4a';
}

void main() {
  test(
    'refuse de démarrer sans consentement avant tout accès au microphone',
    () async {
      final delegate = _FakeRecorder();
      final service = ConsentGatedAudioRecorderService(
        consentGranted: false,
        delegate: delegate,
      );

      await expectLater(
        service.start(),
        throwsA(isA<AudioConsentRequiredException>()),
      );
      expect(delegate.started, isFalse);
      expect(await service.requestPermission(), isFalse);
    },
  );
}
