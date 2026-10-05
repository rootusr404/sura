import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/domain/contracts/audio_recorder_service.dart';
import 'package:sura/domain/contracts/information_extractor.dart';
import 'package:sura/domain/contracts/transcription_service.dart';
import 'package:sura/domain/fakes/fake_services.dart';

// PROPRIÉTAIRE : Membre 2 (C-02, C-03, C-04). Remplacer les fakes un par un.
final audioRecorderProvider = Provider<AudioRecorderService>(
  (ref) => FakeAudioRecorderService(),
);

final transcriptionServiceProvider = Provider<TranscriptionService>(
  (ref) => FakeTranscriptionService(),
);

final informationExtractorProvider = Provider<InformationExtractor>(
  (ref) => FakeInformationExtractor(),
);
