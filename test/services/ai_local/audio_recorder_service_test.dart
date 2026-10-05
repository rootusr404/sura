import 'package:flutter_test/flutter_test.dart';
import 'package:sura/services/ai_local/audio_recorder_service.dart';

/// Implémentation de test (Mock) pour AudioRecorderServiceInterface
class FakeAudioRecorderService implements AudioRecorderServiceInterface {
  RecordingState _state = const RecordingState();
  bool mockPermissionGranted = true;
  bool isDisposed = false;

  @override
  RecordingState get currentState => _state;

  @override
  Stream<RecordingState> get stateStream => Stream.value(_state);

  @override
  Future<bool> checkPermission() async => mockPermissionGranted;

  @override
  Future<bool> requestPermission() async => mockPermissionGranted;

  @override
  Future<String> startRecording({required bool consentGiven, String? customPath}) async {
    // RÈGLE STRICTE R3 : Refuse de démarrer sans consentement accordé
    if (!consentGiven) {
      _state = _state.copyWith(
        status: RecordingStatus.error,
        errorMessage: "R3 : Consentement obligatoire",
      );
      throw const ConsentRequiredException();
    }

    if (!mockPermissionGranted) {
      _state = _state.copyWith(
        status: RecordingStatus.error,
        errorMessage: "Microphone non autorisé",
      );
      throw const MicrophonePermissionDeniedException();
    }

    const path = '/tmp/fake_consultation.m4a';
    _state = _state.copyWith(
      status: RecordingStatus.recording,
      duration: Duration.zero,
      filePath: path,
    );
    return path;
  }

  @override
  Future<void> pauseRecording() async {
    if (_state.status == RecordingStatus.recording) {
      _state = _state.copyWith(status: RecordingStatus.paused);
    }
  }

  @override
  Future<void> resumeRecording() async {
    if (_state.status == RecordingStatus.paused) {
      _state = _state.copyWith(status: RecordingStatus.recording);
    }
  }

  @override
  Future<String?> stopRecording() async {
    _state = _state.copyWith(status: RecordingStatus.stopped);
    return _state.filePath;
  }

  @override
  Future<void> cancelRecording() async {
    _state = const RecordingState(status: RecordingStatus.idle);
  }

  @override
  void dispose() {
    isDisposed = true;
  }
}

void main() {
  group('C-02 : AudioRecorderService & Règle R3', () {
    late FakeAudioRecorderService recorder;

    setUp(() {
      recorder = FakeAudioRecorderService();
    });

    test('1. RÈGLE STRICTE R3 : Refuse formellement de démarrer sans consentement', () async {
      expect(
        () => recorder.startRecording(consentGiven: false),
        throwsA(isA<ConsentRequiredException>()),
      );
      expect(recorder.currentState.status, equals(RecordingStatus.error));
    });

    test('2. Démarre correctement l\'enregistrement si le consentement est accordé', () async {
      final path = await recorder.startRecording(consentGiven: true);
      expect(path, isNotEmpty);
      expect(recorder.currentState.status, equals(RecordingStatus.recording));
    });

    test('3. Cycles de vie : Pause, Reprise et Arrêt', () async {
      await recorder.startRecording(consentGiven: true);
      expect(recorder.currentState.status, equals(RecordingStatus.recording));

      await recorder.pauseRecording();
      expect(recorder.currentState.status, equals(RecordingStatus.paused));

      await recorder.resumeRecording();
      expect(recorder.currentState.status, equals(RecordingStatus.recording));

      final stoppedPath = await recorder.stopRecording();
      expect(stoppedPath, isNotNull);
      expect(recorder.currentState.status, equals(RecordingStatus.stopped));
    });

    test('4. Gestion du refus de microphone (État F7)', () async {
      recorder.mockPermissionGranted = false;

      expect(
        () => recorder.startRecording(consentGiven: true),
        throwsA(isA<MicrophonePermissionDeniedException>()),
      );
      expect(recorder.currentState.status, equals(RecordingStatus.error));
    });

    test('5. Annulation et nettoyage local', () async {
      await recorder.startRecording(consentGiven: true);
      await recorder.cancelRecording();
      expect(recorder.currentState.status, equals(RecordingStatus.idle));
    });
  });
}
