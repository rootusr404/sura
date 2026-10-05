import 'enums.dart';
import 'missing_item.dart';
import 'structured_info.dart';
import 'urgency_proposal.dart';

class PatientRecord {
  const PatientRecord({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.ageYears,
    required this.ageRecordedAt,
    required this.sex,
    required this.village,
    this.phone,
    required this.createdByAgentId,
    required this.createdAt,
    required this.updatedAt,
    this.syncState = SyncState.pending,
    this.syncAttempts = 0,
    this.syncError,
  });

  /// Format SUR-XXXX-XXXX (R1). C'est la seule donnée contenue dans le QR (R2).
  final String id;
  final String lastName;
  final String firstName;
  final int ageYears;
  final DateTime ageRecordedAt;
  final String sex; // 'F' | 'M'
  final String village;
  final String? phone;
  final String createdByAgentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncState syncState;
  final int syncAttempts;
  final String? syncError;

  String get fullName => '$firstName $lastName';

  PatientRecord copyWith({
    String? lastName,
    String? firstName,
    int? ageYears,
    String? sex,
    String? village,
    String? phone,
    DateTime? updatedAt,
    SyncState? syncState,
    int? syncAttempts,
    String? syncError,
    bool clearSyncError = false,
  }) => PatientRecord(
    id: id,
    lastName: lastName ?? this.lastName,
    firstName: firstName ?? this.firstName,
    ageYears: ageYears ?? this.ageYears,
    ageRecordedAt: ageRecordedAt,
    sex: sex ?? this.sex,
    village: village ?? this.village,
    phone: phone ?? this.phone,
    createdByAgentId: createdByAgentId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    syncAttempts: syncAttempts ?? this.syncAttempts,
    syncError: clearSyncError ? null : (syncError ?? this.syncError),
  );
}

class ConsultationRecord {
  const ConsultationRecord({
    required this.id,
    required this.patientId,
    required this.agentId,
    this.status = ConsultationStatus.draft,
    this.step = 'consent',
    this.consent,
    this.consentAt,
    this.transcriptRaw,
    this.transcriptEdited,
    this.structured,
    this.missing = const [],
    this.urgencyProposal,
    this.urgencyFinal,
    this.urgencyOverrideReason,
    this.checklist = const {},
    this.syncState = SyncState.pending,
    this.syncAttempts = 0,
    this.syncError,
    required this.createdAt,
    required this.updatedAt,
    this.validatedAt,
  });

  final String id;
  final String patientId;
  final String agentId;
  final ConsultationStatus status;

  /// Nom de l'étape courante (voir ConsultationStep).
  final String step;
  final ConsentStatus? consent;
  final DateTime? consentAt;
  final String? transcriptRaw;
  final String? transcriptEdited;
  final StructuredInfo? structured;
  final List<MissingItem> missing;
  final UrgencyProposal? urgencyProposal;
  final UrgencyLevel? urgencyFinal;
  final String? urgencyOverrideReason;

  /// Les 5 cases de validation (R8), clé = code de la case.
  final Map<String, bool> checklist;
  final SyncState syncState;
  final int syncAttempts;
  final String? syncError;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? validatedAt;

  /// Texte à utiliser en aval : la version corrigée par l'agent si elle existe.
  String? get transcript => transcriptEdited ?? transcriptRaw;

  ConsultationRecord copyWith({
    ConsultationStatus? status,
    String? step,
    ConsentStatus? consent,
    DateTime? consentAt,
    String? transcriptRaw,
    String? transcriptEdited,
    StructuredInfo? structured,
    List<MissingItem>? missing,
    UrgencyProposal? urgencyProposal,
    UrgencyLevel? urgencyFinal,
    String? urgencyOverrideReason,
    Map<String, bool>? checklist,
    SyncState? syncState,
    int? syncAttempts,
    String? syncError,
    bool clearSyncError = false,
    DateTime? updatedAt,
    DateTime? validatedAt,
  }) => ConsultationRecord(
    id: id,
    patientId: patientId,
    agentId: agentId,
    status: status ?? this.status,
    step: step ?? this.step,
    consent: consent ?? this.consent,
    consentAt: consentAt ?? this.consentAt,
    transcriptRaw: transcriptRaw ?? this.transcriptRaw,
    transcriptEdited: transcriptEdited ?? this.transcriptEdited,
    structured: structured ?? this.structured,
    missing: missing ?? this.missing,
    urgencyProposal: urgencyProposal ?? this.urgencyProposal,
    urgencyFinal: urgencyFinal ?? this.urgencyFinal,
    urgencyOverrideReason: urgencyOverrideReason ?? this.urgencyOverrideReason,
    checklist: checklist ?? this.checklist,
    syncState: syncState ?? this.syncState,
    syncAttempts: syncAttempts ?? this.syncAttempts,
    syncError: clearSyncError ? null : (syncError ?? this.syncError),
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    validatedAt: validatedAt ?? this.validatedAt,
  );
}
