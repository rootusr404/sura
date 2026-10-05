import 'package:flutter_test/flutter_test.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/missing_item.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/domain/models/urgency_proposal.dart';
import 'package:sura/features/consultation/view/consultation_summary.dart';

void main() {
  final now = DateTime(2026, 10, 3, 14, 5);

  ConsultationRecord base({
    StructuredInfo? info,
    UrgencyProposal? proposal,
    UrgencyLevel? finalLevel,
    String? overrideReason,
    List<MissingItem> missing = const [],
    String? transcript,
  }) => ConsultationRecord(
    id: 'c1',
    patientId: 'SUR-AB2C-D3EF',
    agentId: 'a1',
    status: ConsultationStatus.saved,
    createdAt: now,
    updatedAt: now,
    validatedAt: now,
    transcriptRaw: transcript,
    structured: info,
    urgencyProposal: proposal,
    urgencyFinal: finalLevel,
    urgencyOverrideReason: overrideReason,
    missing: missing,
    syncState: SyncState.pending,
  );

  String summary(ConsultationRecord r) => buildConsultationSummary(
    record: r,
    patientName: 'Awa Traoré',
    ageYears: 34,
    sex: 'F',
    village: 'Koudougou',
    patientId: 'SUR-AB2C-D3EF',
  );

  test('contient patient, date, urgence, raisons et informations', () {
    final s = summary(
      base(
        info: const StructuredInfo(
          chiefComplaint: 'Fièvre',
          symptoms: ['Fièvre', 'Toux'],
          duration: 'trois jours',
          temperatureC: 39.0,
          allergies: 'Aucune',
        ),
        proposal: const UrgencyProposal(
          level: UrgencyLevel.moderate,
          reasons: ['Fièvre à 39 °C depuis 3 jours ou plus'],
        ),
        finalLevel: UrgencyLevel.moderate,
        transcript: 'La patiente a de la fièvre.',
      ),
    );
    expect(s, contains('Awa Traoré (34 ans, femme) — Koudougou'));
    expect(s, contains('SUR-AB2C-D3EF'));
    expect(s, contains('03/10/2026 14:05'));
    expect(s, contains('URGENCE : MODÉRÉ'));
    expect(s, contains('- Fièvre à 39 °C depuis 3 jours ou plus'));
    expect(s, contains('Symptômes : Fièvre, Toux'));
    expect(s, contains('Température : 39.0 °C'));
    expect(s, contains('La patiente a de la fièvre.'));
    expect(s, contains('enregistrée — En attente d\'envoi'));
  });

  test('un niveau modifié par l\'agent est signalé avec son motif', () {
    final s = summary(
      base(
        proposal: const UrgencyProposal(
          level: UrgencyLevel.moderate,
          reasons: ['x'],
        ),
        finalLevel: UrgencyLevel.high,
        overrideReason: 'Enfant fragile',
      ),
    );
    expect(s, contains('URGENCE : ÉLEVÉ'));
    expect(
      s,
      contains(
        'proposé : MODÉRÉ, modifié par l\'agent — motif : Enfant fragile',
      ),
    );
  });

  test('les informations manquantes sont listées', () {
    final s = summary(
      base(
        missing: const [
          MissingItem(
            code: 'allergies',
            label: 'Les allergies ne semblent pas renseignées.',
          ),
        ],
      ),
    );
    expect(s, contains('Informations signalées comme manquantes'));
    expect(s, contains('- Les allergies ne semblent pas renseignées.'));
  });

  test('les champs absents n\'apparaissent pas et jamais « null »', () {
    final s = summary(base(info: const StructuredInfo(chiefComplaint: 'Toux')));
    expect(s, contains('Motif : Toux'));
    expect(s, isNot(contains('Allergies')));
    expect(s, isNot(contains('Pouls')));
    expect(s, isNot(contains('null')));
    expect(s, isNot(contains('URGENCE')));
  });
}
