import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../data/database.dart';
import '../../data/repository.dart';
import '../../domain/models.dart';
import '../../domain/rules.dart';

/// Ordre des etapes (maquettes V3) : 8 etapes en mode voix, 6 en saisie manuelle.
const voiceStages = [
  'consent',
  'record',
  'transcript',
  'structured',
  'missing',
  'urgency',
  'recap',
  'validate'
];
const manualStages = [
  'consent',
  'structured',
  'missing',
  'urgency',
  'recap',
  'validate'
];

List<String> stagesFor(String mode) =>
    mode == 'manual' ? manualStages : voiceStages;

class ConsultationService {
  ConsultationService(this.repo, this.agentId);
  final SuraRepo repo;
  final String agentId;

  Future<String> start(String patientId) async {
    final id = const Uuid().v4();
    await repo.addConsultation(ConsultationsCompanion.insert(
      id: id,
      patientId: patientId,
      agentId: agentId,
      createdAt: DateTime.now(),
    ));
    return id;
  }

  Future<void> setStage(String id, String stage) =>
      repo.patchConsultation(id, ConsultationsCompanion(stage: Value(stage)));

  /// R3 / R16 : un refus bascule en saisie manuelle et le refus est consigne.
  Future<void> setConsent(String id, bool granted) => repo.patchConsultation(
        id,
        ConsultationsCompanion(
          consent: Value(granted ? 'granted' : 'refused'),
          consentAt: Value(DateTime.now()),
          mode: Value(granted ? 'voice' : 'manual'),
        ),
      );

  Future<void> switchToManual(String id) => repo.patchConsultation(
      id, const ConsultationsCompanion(mode: Value('manual')));

  Future<void> saveTranscript(String id, String text) => repo.patchConsultation(
      id, ConsultationsCompanion(transcript: Value(text)));

  Future<void> saveStructured(String id, Structured s) =>
      repo.patchConsultation(
        id,
        ConsultationsCompanion(
          structuredJson: Value(s.encode()),
          missingJson: Value(jsonEncode(MissingFinder.find(s))),
        ),
      );

  UrgencyResult evaluate(Structured s, int? ageYears) =>
      UrgencyEngine.evaluate(s, ageYears: ageYears);

  Future<void> saveUrgency(String id, Urgency proposed, Urgency finalLevel,
          List<String> reasons) =>
      repo.patchConsultation(
        id,
        ConsultationsCompanion(
          urgencyProposed: Value(proposed.index),
          urgencyFinal: Value(finalLevel.index),
          reasonsJson: Value(jsonEncode(reasons)),
        ),
      );

  /// R8 / R9 : validee par l'agent, sauvegardee localement AVANT toute synchronisation.
  Future<void> validate(String id) => repo.patchConsultation(
        id,
        ConsultationsCompanion(
          status: const Value('saved'),
          stage: const Value('saved'),
          validatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );

  // TODO (hors MVP) : supprimer le fichier audio temporaire ici, apres validation et en cas d'abandon (R17).
  Future<void> abandon(String id) => repo.deleteConsultation(id);
}
