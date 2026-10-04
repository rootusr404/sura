import 'package:sura/core/utils/text_utils.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';

String urgencyLabel(UrgencyLevel l) => switch (l) {
  UrgencyLevel.high => 'ÉLEVÉ',
  UrgencyLevel.moderate => 'MODÉRÉ',
  UrgencyLevel.low => 'FAIBLE',
};

String syncLabel(SyncState s) => switch (s) {
  SyncState.offline => 'Hors ligne',
  SyncState.pending => 'En attente d\'envoi',
  SyncState.syncing => 'Envoi en cours',
  SyncState.synced => 'Synchronisée',
  SyncState.error => 'Échec d\'envoi',
};

/// Résumé en texte brut d'une consultation, à copier (SMS, message à un centre de santé).
/// N'inclut que les champs renseignés : jamais de « null ».
String buildConsultationSummary({
  required ConsultationRecord record,
  required String patientName,
  required int ageYears,
  required String sex,
  required String village,
  required String patientId,
}) {
  final r = record;
  final i = r.structured;
  final b = StringBuffer()
    ..writeln('SŪRA — Résumé de consultation')
    ..writeln(
      'Patient : $patientName ($ageYears ans, ${sex == 'F' ? 'femme' : 'homme'})'
      '${village.isEmpty ? '' : ' — $village'}',
    )
    ..writeln('Identifiant : $patientId')
    ..writeln('Date : ${formatDateTime(r.validatedAt ?? r.createdAt)}');

  final level = r.urgencyFinal ?? r.urgencyProposal?.level;
  if (level != null) {
    b.writeln('\nURGENCE : ${urgencyLabel(level)}');
    final proposed = r.urgencyProposal?.level;
    if (proposed != null && proposed != level) {
      b.writeln(
        '(proposé : ${urgencyLabel(proposed)}, modifié par l\'agent'
        '${(r.urgencyOverrideReason ?? '').isEmpty ? '' : ' — motif : ${r.urgencyOverrideReason}'})',
      );
    }
    for (final reason in r.urgencyProposal?.reasons ?? const <String>[]) {
      b.writeln('- $reason');
    }
  }

  void line(String label, String? value) {
    if (value != null && value.trim().isNotEmpty) b.writeln('$label : $value');
  }

  if (i != null) {
    b.writeln();
    line('Motif', i.chiefComplaint);
    line('Symptômes', i.symptoms.isEmpty ? null : i.symptoms.join(', '));
    line('Durée', i.duration);
    line('Température', i.temperatureC == null ? null : '${i.temperatureC} °C');
    line('Pouls', i.pulse?.toString());
    line('Allergies', i.allergies);
    line('Médicaments', i.medications);
    line('Antécédents', i.history);
    line('Notes', i.notes);
  }

  if (r.missing.isNotEmpty) {
    b.writeln('\nInformations signalées comme manquantes :');
    for (final m in r.missing) {
      b.writeln('- ${m.label}');
    }
  }
  final text = r.transcript;
  if (text != null && text.trim().isNotEmpty) {
    b.writeln('\nTexte de la consultation :\n${text.trim()}');
  }
  b.writeln(
    '\nStatut : ${r.status == ConsultationStatus.saved ? 'enregistrée' : 'brouillon'}'
    ' — ${syncLabel(r.syncState)}',
  );
  return b.toString().trimRight();
}
