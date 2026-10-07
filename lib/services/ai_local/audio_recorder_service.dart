import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sura/domain/contracts/audio_recorder_service.dart';

class AudioConsentRequiredException implements Exception {
  const AudioConsentRequiredException();

  @override
  String toString() => 'L’enregistrement nécessite le consentement du patient.';
}

/// Garde de consentement commune à tous les enregistreurs.
class ConsentGatedAudioRecorderService implements AudioRecorderService {
  const ConsentGatedAudioRecorderService({
    required this.consentGranted,
    required this.delegate,
  });

  final bool consentGranted;
  final AudioRecorderService delegate;

  @override
  Future<bool> requestPermission() =>
      consentGranted ? delegate.requestPermission() : Future<bool>.value(false);

  @override
  Future<void> start() async {
    if (!consentGranted) throw const AudioConsentRequiredException();
    await delegate.start();
  }

  @override
  Future<String> stop() => delegate.stop();

  @override
  Future<void> cancel() => delegate.cancel();
}

/// Enregistreur local conforme au contrat partagé.
class LocalAudioRecorderService implements AudioRecorderService {
  LocalAudioRecorderService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  String? _path;

  @override
  Future<bool> requestPermission() => _recorder.hasPermission();

  @override
  Future<void> start() async {
    if (!await requestPermission()) {
      throw StateError('L’accès au microphone a été refusé.');
    }

    final directory = await getTemporaryDirectory();
    _path =
        '${directory.path}/sura_consultation_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _path!,
    );
  }

  @override
  Future<String> stop() async {
    final path = await _recorder.stop() ?? _path;
    if (path == null) throw StateError('Aucun enregistrement à arrêter.');
    _path = null;
    return path;
  }

  @override
  Future<void> cancel() async {
    await _recorder.cancel();
    _path = null;
  }
}
