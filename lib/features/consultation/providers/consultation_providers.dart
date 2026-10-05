import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/core/models/consultation_data.dart';
import 'package:sura/services/ai_local/audio_recorder_service.dart';
import 'package:sura/services/ai_local/information_extractor.dart';
import 'package:sura/services/ai_local/transcription_service.dart';

/// Provider pour le service d'enregistrement audio (C-02)
final audioRecorderServiceProvider = Provider<AudioRecorderServiceInterface>((ref) {
  final service = AudioRecorderService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider pour le flux d'état d'enregistrement en direct
final recordingStateStreamProvider = StreamProvider.autoDispose<RecordingState>((ref) {
  final recorder = ref.watch(audioRecorderServiceProvider);
  return recorder.stateStream;
});

/// Provider pour le service de transcription hors ligne (C-03)
final transcriptionServiceProvider = Provider<TranscriptionService>((ref) {
  return LocalTranscriptionService();
});

/// Provider pour le moteur d'extraction d'informations médicales (C-04)
final informationExtractorProvider = Provider<InformationExtractor>((ref) {
  return const InformationExtractor();
});

/// Notifier d'état pour les données de consultation en cours de saisie/validation
class ConsultationDataNotifier extends Notifier<ConsultationData> {
  @override
  ConsultationData build() {
    return const ConsultationData();
  }

  void updateWithTranscript(String transcript) {
    final extractor = ref.read(informationExtractorProvider);
    state = extractor.extract(transcript);
  }

  void updateData(ConsultationData data) {
    state = data;
  }

  void updateField({
    String? chiefComplaint,
    List<String>? symptoms,
    double? temperatureC,
    int? durationDays,
    int? pulse,
    int? respiratoryRate,
    List<String>? medications,
    List<String>? allergies,
    List<String>? antecedents,
  }) {
    state = state.copyWith(
      chiefComplaint: chiefComplaint,
      symptoms: symptoms,
      temperatureC: temperatureC,
      durationDays: durationDays,
      pulse: pulse,
      respiratoryRate: respiratoryRate,
      medications: medications,
      allergies: allergies,
      antecedents: antecedents,
    );
  }

  void reset() {
    state = const ConsultationData();
  }
}

final consultationDataProvider =
    NotifierProvider<ConsultationDataNotifier, ConsultationData>(
  ConsultationDataNotifier.new,
);
