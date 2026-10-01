import 'package:sura/domain/contracts/audio_recorder_service.dart';
import 'package:sura/domain/contracts/auth_service.dart';
import 'package:sura/domain/contracts/information_extractor.dart';
import 'package:sura/domain/contracts/missing_info_checker.dart';
import 'package:sura/domain/contracts/sync_service.dart';
import 'package:sura/domain/contracts/transcription_service.dart';
import 'package:sura/domain/contracts/urgency_scorer.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/missing_item.dart';
import 'package:sura/domain/models/patient_context.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/domain/models/urgency_proposal.dart';

/// Fakes de développement (Sprint 1). Chaque propriétaire les remplace par la
/// vraie implémentation en changeant UNE ligne dans son fichier de providers.

class FakeAudioRecorderService implements AudioRecorderService {
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> start() async {}
  @override
  Future<String> stop() async => 'fake_audio.wav';
  @override
  Future<void> cancel() async {}
}

class FakeTranscriptionService implements TranscriptionService {
  static const sampleText =
      'La patiente a de la fièvre depuis trois jours, avec des maux de tête '
      'et des frissons. Température de 39 degrés. Elle ne prend aucun médicament.';

  @override
  String get engine => 'fake';
  @override
  Future<void> prepare() async {}
  @override
  Future<TranscriptionResult> transcribe(String audioPath) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const TranscriptionResult(text: sampleText, engine: 'fake');
  }
}

class FakeInformationExtractor implements InformationExtractor {
  @override
  StructuredInfo extract(String transcript) => const StructuredInfo(
    chiefComplaint: 'Fièvre',
    symptoms: ['fièvre', 'maux de tête', 'frissons'],
    duration: '3 jours',
    temperatureC: 39,
    medications: 'Aucun',
  );
}

class FakeMissingInfoChecker implements MissingInfoChecker {
  @override
  List<MissingItem> check(StructuredInfo info, PatientContext patient) => [
    if ((info.allergies ?? '').isEmpty)
      const MissingItem(
        code: 'allergies',
        label: 'Les allergies ne semblent pas renseignées.',
        hint: 'Demandez au patient s\'il a des allergies connues.',
      ),
  ];
}

class FakeUrgencyScorer implements UrgencyScorer {
  @override
  UrgencyProposal score(
    StructuredInfo info,
    String transcript,
    PatientContext patient,
  ) => const UrgencyProposal(
    level: UrgencyLevel.moderate,
    reasons: ['Fièvre à 39 °C depuis 3 jours (donnée simulée)'],
  );
}

class FakeSyncService implements SyncService {
  @override
  Stream<SyncState> watchOverall() => Stream.value(SyncState.synced);
  @override
  Future<void> syncPending() async {}
  @override
  Future<void> retry(String consultationId) async {}
}

class FakeAuthService implements AuthService {
  static const user = AuthUser(id: 'dev-agent', email: 'dev@sura.test');
  @override
  Future<AuthUser?> currentUser() async => user;
  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async => user;
  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async => user;
  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<void> signOut() async {}
}
