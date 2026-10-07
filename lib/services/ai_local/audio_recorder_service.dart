import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Exception levée si une tentative d'enregistrement a lieu sans consentement (R3)
class ConsentRequiredException implements Exception {
  final String message;
  const ConsentRequiredException([
    this.message =
        "R3 : L'enregistrement audio refuse formellement de démarrer sans le consentement éclairé du patient.",
  ]);

  @override
  String toString() => 'ConsentRequiredException: $message';
}

/// Exception levée si la permission microphone est refusée
class MicrophonePermissionDeniedException implements Exception {
  final String message;
  const MicrophonePermissionDeniedException([
    this.message =
        "Le microphone n'est pas autorisé. Saisie manuelle requise.",
  ]);

  @override
  String toString() => 'MicrophonePermissionDeniedException: $message';
}

/// État du service d'enregistrement
enum RecordingStatus { idle, recording, paused, stopped, error }

/// Informations d'état d'enregistrement
class RecordingState {
  final RecordingStatus status;
  final Duration duration;
  final double amplitude; // 0.0 à 1.0 normalisé
  final String? filePath;
  final String? errorMessage;

  const RecordingState({
    this.status = RecordingStatus.idle,
    this.duration = Duration.zero,
    this.amplitude = 0.0,
    this.filePath,
    this.errorMessage,
  });

  RecordingState copyWith({
    RecordingStatus? status,
    Duration? duration,
    double? amplitude,
    String? filePath,
    String? errorMessage,
  }) {
    return RecordingState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      amplitude: amplitude ?? this.amplitude,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Contrat du service d'enregistrement audio (Tâche C-02)
abstract class AudioRecorderServiceInterface {
  Stream<RecordingState> get stateStream;
  RecordingState get currentState;

  Future<bool> checkPermission();
  Future<bool> requestPermission();

  /// Démarre l'enregistrement audio.
  /// IMPÉRATIF : refuse de démarrer si [consentGiven] est false (Règle R3).
  Future<String> startRecording({required bool consentGiven, String? customPath});

  Future<void> pauseRecording();
  Future<void> resumeRecording();

  /// Arrête l'enregistrement et retourne le chemin du fichier local.
  Future<String?> stopRecording();

  /// Annule et supprime le fichier audio temporaire.
  Future<void> cancelRecording();

  void dispose();
}

/// Implémentation réelle de l'enregistreur audio basée sur le package `record`
class AudioRecorderService implements AudioRecorderServiceInterface {
  final AudioRecorder _audioRecorder;
  final StreamController<RecordingState> _stateController =
      StreamController<RecordingState>.broadcast();

  Timer? _timer;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  RecordingState _currentState = const RecordingState();

  AudioRecorderService({AudioRecorder? audioRecorder})
      : _audioRecorder = audioRecorder ?? AudioRecorder();

  @override
  Stream<RecordingState> get stateStream => _stateController.stream;

  @override
  RecordingState get currentState => _currentState;

  void _updateState(RecordingState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  @override
  Future<bool> checkPermission() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (_) {
      // Fallback si web ou simulateur
      return await _audioRecorder.hasPermission();
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) return false;
      return false;
    } catch (_) {
      return await _audioRecorder.hasPermission();
    }
  }

  @override
  Future<String> startRecording({
    required bool consentGiven,
    String? customPath,
  }) async {
    // 1. RÈGLE STRICTE R3 : Refuse de démarrer sans consentement accordé
    if (!consentGiven) {
      final exception = const ConsentRequiredException();
      _updateState(_currentState.copyWith(
        status: RecordingStatus.error,
        errorMessage: exception.message,
      ));
      throw exception;
    }

    // 2. Vérification de la permission microphone
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      final granted = await requestPermission();
      if (!granted) {
        final exception = const MicrophonePermissionDeniedException();
        _updateState(_currentState.copyWith(
          status: RecordingStatus.error,
          errorMessage: exception.message,
        ));
        throw exception;
      }
    }

    // 3. Préparation du chemin de stockage local (100% sur l'appareil)
    String filePath = customPath ?? '';
    if (filePath.isEmpty) {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      filePath = '${tempDir.path}/sura_consultation_$timestamp.m4a';
    }

    // 4. Configuration de l'enregistrement
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 64000,
      sampleRate: 16000, // 16kHz optimal pour la reconnaissance vocale / Whisper / Vosk
      numChannels: 1, // Mono pour réduire la taille du fichier
    );

    await _audioRecorder.start(config, path: filePath);

    // Initialisation du compteur et du suivi d'amplitude
    _timer?.cancel();
    int secondsElapsed = 0;
    _updateState(RecordingState(
      status: RecordingStatus.recording,
      duration: Duration.zero,
      filePath: filePath,
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentState.status == RecordingStatus.recording) {
        secondsElapsed++;
        _updateState(_currentState.copyWith(
          duration: Duration(seconds: secondsElapsed),
        ));
      }
    });

    // Écoute de l'amplitude pour l'animation visuelle
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 150))
        .listen((amp) {
      if (_currentState.status == RecordingStatus.recording) {
        // Normalisation d'amplitude de dB (-60 à 0 dB) vers [0.0, 1.0]
        final currentDb = amp.current.clamp(-60.0, 0.0);
        final normalized = (currentDb + 60.0) / 60.0;
        _updateState(_currentState.copyWith(amplitude: normalized));
      }
    });

    return filePath;
  }

  @override
  Future<void> pauseRecording() async {
    if (_currentState.status == RecordingStatus.recording) {
      await _audioRecorder.pause();
      _updateState(_currentState.copyWith(status: RecordingStatus.paused));
    }
  }

  @override
  Future<void> resumeRecording() async {
    if (_currentState.status == RecordingStatus.paused) {
      await _audioRecorder.resume();
      _updateState(_currentState.copyWith(status: RecordingStatus.recording));
    }
  }

  @override
  Future<String?> stopRecording() async {
    _timer?.cancel();
    _amplitudeSubscription?.cancel();

    if (_currentState.status == RecordingStatus.recording ||
        _currentState.status == RecordingStatus.paused) {
      final path = await _audioRecorder.stop();
      final finalPath = path ?? _currentState.filePath;
      _updateState(_currentState.copyWith(
        status: RecordingStatus.stopped,
        filePath: finalPath,
        amplitude: 0.0,
      ));
      return finalPath;
    }
    return _currentState.filePath;
  }

  @override
  Future<void> cancelRecording() async {
    _timer?.cancel();
    _amplitudeSubscription?.cancel();

    try {
      await _audioRecorder.stop();
    } catch (_) {}

    if (_currentState.filePath != null) {
      final file = File(_currentState.filePath!);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }

    _updateState(const RecordingState(status: RecordingStatus.idle));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSubscription?.cancel();
    _audioRecorder.dispose();
    _stateController.close();
  }
}
