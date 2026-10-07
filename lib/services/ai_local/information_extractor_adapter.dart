import 'package:sura/domain/contracts/information_extractor.dart' as contract;
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/services/ai_local/information_extractor.dart' as engine;

/// Adapte le moteur C-04 au contrat utilisé par les écrans et repositories.
/// Toute erreur d'extraction se traduit par un résultat vide, jamais par un crash.
class RuleBasedInformationExtractor implements contract.InformationExtractor {
  const RuleBasedInformationExtractor();

  @override
  StructuredInfo extract(String transcript) {
    try {
      final data = const engine.InformationExtractor().extract(transcript);
      return StructuredInfo(
        chiefComplaint: data.chiefComplaint,
        symptoms: data.symptoms.map(_normalizeSymptom).toList(),
        duration: data.durationDays == null
            ? null
            : '${data.durationDays} ${data.durationDays == 1 ? 'jour' : 'jours'}',
        temperatureC: data.temperatureC,
        pulse: data.pulse,
        allergies: _joinOrNull(data.allergies),
        medications: _joinOrNull(data.medications),
        history: _joinOrNull(data.antecedents),
      );
    } catch (_) {
      return const StructuredInfo();
    }
  }

  String? _joinOrNull(List<String> values) => values.isEmpty
      ? null
      : values
            .map(
              (value) => value.isEmpty
                  ? value
                  : '${value[0].toLowerCase()}${value.substring(1)}',
            )
            .join(', ');

  String _normalizeSymptom(String symptom) => switch (symptom) {
    'Fièvre' => 'fièvre',
    'Frissons' => 'frissons',
    'Maux de tête (céphalées)' => 'maux de tête',
    'Convulsions' => 'convulsion',
    'Nez qui coule' => 'nez qui coule',
    'Éternuements' => 'éternuements',
    'Toux légère' => 'toux légère',
    'Toux sèche' => 'toux sèche',
    'Toux grasse' => 'toux grasse',
    'Toux' => 'toux',
    _ =>
      symptom.isEmpty
          ? symptom
          : '${symptom[0].toLowerCase()}${symptom.substring(1)}',
  };
}
