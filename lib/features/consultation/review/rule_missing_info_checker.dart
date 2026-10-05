import 'package:sura/domain/contracts/missing_info_checker.dart';
import 'package:sura/domain/models/missing_item.dart';
import 'package:sura/domain/models/patient_context.dart';
import 'package:sura/domain/models/structured_info.dart';

/// Âge en dessous duquel la température est toujours attendue.
const _youngChildMaxAge = 5;

/// Règles déterministes (U-01). Alertes explicables, jamais bloquantes (R6).
/// Température et pouls restent facultatifs (02 §8, #14), sauf fièvre évoquée
/// ou jeune enfant.
class RuleMissingInfoChecker implements MissingInfoChecker {
  @override
  List<MissingItem> check(StructuredInfo info, PatientContext patient) {
    final items = <MissingItem>[];

    void flag(String code, String subject, String hint) => items.add(
      MissingItem(
        code: code,
        label: 'Cette information semble manquer : $subject.',
        hint: hint,
      ),
    );

    if (_blank(info.chiefComplaint)) {
      flag(
        'chiefComplaint',
        'le motif de consultation',
        'Le motif principal de la visite n\'est pas renseigné.',
      );
    }
    if (info.symptoms.isEmpty) {
      flag(
        'symptoms',
        'les symptômes',
        'Aucun symptôme n\'a été relevé dans la transcription.',
      );
    }
    if (_blank(info.duration)) {
      flag(
        'duration',
        'la durée des symptômes',
        'Depuis quand les symptômes ont-ils commencé ?',
      );
    }
    if (info.temperatureC == null && _expectsTemperature(info, patient)) {
      flag(
        'temperature',
        'la température',
        'Une fièvre est évoquée ou le patient est un jeune enfant.',
      );
    }
    if (_blank(info.allergies)) {
      flag(
        'allergies',
        'les allergies connues',
        'Précisez « aucune » si le patient n\'en a pas.',
      );
    }
    if (_blank(info.medications)) {
      flag(
        'medications',
        'les médicaments en cours',
        'Précisez « aucun » si le patient n\'en prend pas.',
      );
    }
    if (_blank(info.history)) {
      flag(
        'history',
        'les antécédents',
        'Précisez « aucun » s\'il n\'y en a pas.',
      );
    }
    return items;
  }

  static bool _blank(String? v) => v == null || v.trim().isEmpty;

  static bool _expectsTemperature(StructuredInfo info, PatientContext patient) {
    if (patient.ageYears < _youngChildMaxAge) return true;
    final text = [
      info.chiefComplaint ?? '',
      ...info.symptoms,
    ].join(' ').toLowerCase();
    return text.contains('fièvre') || text.contains('fievre');
  }
}
