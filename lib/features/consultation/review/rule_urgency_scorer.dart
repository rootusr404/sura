import 'package:sura/domain/contracts/urgency_scorer.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/patient_context.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/domain/models/urgency_proposal.dart';

const _youngChildMaxAge = 5;
const _prolongedFeverDays = 3;
const _highFeverC = 40.0;
const _moderateFeverC = 38.5;

/// Signes de gravité : leur présence (non niée) donne un niveau élevé.
const _highSigns = <String, List<String>>{
  'Convulsions signalées': ['convulsion', 'crise convulsive'],
  'Difficulté à respirer': [
    'mal a respirer',
    'difficulte respiratoire',
    'difficultes respiratoires',
    'respire mal',
    'arrive pas a respirer',
    'essoufflement important',
  ],
  'Perte de connaissance': [
    'perdu connaissance',
    'perte de connaissance',
    'evanoui',
    'inconscient',
  ],
  'Douleur à la poitrine': ['douleur thoracique', 'douleur dans la poitrine'],
  'Saignement important': ['saignement abondant', 'hemorragie'],
  'Raideur de la nuque': ['nuque raide', 'raideur de la nuque'],
};

const _negations = [
  'pas de',
  'pas d',
  'sans',
  'aucun',
  'aucune',
  'ni ',
  'jamais',
];

/// U-02. Règles à mots-clés explicables : chaque niveau est accompagné de ses
/// raisons. Elle propose seulement, l'agent peut modifier (R7) et valide seul (R8).
class RuleUrgencyScorer implements UrgencyScorer {
  @override
  UrgencyProposal score(
    StructuredInfo info,
    String transcript,
    PatientContext patient,
  ) {
    final text = _normalize(
      [
        transcript,
        info.chiefComplaint ?? '',
        ...info.symptoms,
        info.notes ?? '',
      ].join(' . '),
    );

    final high = <String>[];
    final moderate = <String>[];

    _highSigns.forEach((reason, keywords) {
      if (keywords.any((k) => _mentions(text, k))) high.add(reason);
    });

    final temp = info.temperatureC;
    if (temp != null && temp >= _highFeverC) {
      high.add('Température très élevée (${_fmt(temp)} °C)');
    }

    final hasFever = (temp != null && temp >= 38) || _mentions(text, 'fievre');
    if (hasFever) {
      final days = _durationDays(info.duration, text);
      final isYoungChild = patient.ageYears < _youngChildMaxAge;
      final prolonged = days != null && days >= _prolongedFeverDays;
      if (prolonged && isYoungChild) {
        high.add('Fièvre depuis $days jours chez un enfant de moins de 5 ans');
      } else if (prolonged) {
        moderate.add('Fièvre depuis $days jours');
      } else if (temp != null && temp >= _moderateFeverC) {
        moderate.add('Fièvre élevée (${_fmt(temp)} °C)');
      } else {
        moderate.add('Fièvre signalée');
      }
    }

    if (patient.ageYears < _youngChildMaxAge &&
        (_mentions(text, 'vomissement') || _mentions(text, 'diarrhee'))) {
      moderate.add('Vomissements ou diarrhée chez un jeune enfant');
    }

    if (high.isNotEmpty) {
      return UrgencyProposal(
        level: UrgencyLevel.high,
        reasons: [...high, ...moderate],
      );
    }
    if (moderate.isNotEmpty) {
      return UrgencyProposal(level: UrgencyLevel.moderate, reasons: moderate);
    }
    return const UrgencyProposal(
      level: UrgencyLevel.low,
      reasons: [
        'Aucun signe de gravité détecté dans les informations disponibles',
      ],
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  static String _normalize(String s) {
    const from = 'àâäéèêëîïôöùûüç’';
    const to = "aaaeeeeiioouuuc'";
    final buf = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      final i = from.indexOf(ch);
      buf.write(i >= 0 ? to[i] : ch);
    }
    return buf.toString();
  }

  /// Vrai si [keyword] apparaît au moins une fois sans négation juste avant.
  static bool _mentions(String text, String keyword) {
    var from = 0;
    while (true) {
      final i = text.indexOf(keyword, from);
      if (i < 0) return false;
      final start = i < 20 ? 0 : i - 20;
      final before = text.substring(start, i);
      // Une négation ne vaut que dans la même phrase.
      final sentence = before.split(RegExp(r'[.;!?]')).last;
      if (!_negations.any(sentence.contains)) return true;
      from = i + keyword.length;
    }
  }

  static int? _durationDays(String? duration, String text) {
    final source = _normalize('${duration ?? ''} . $text');
    final m = RegExp(r'(\d+|un|une)\s*(jour|semaine|mois)').firstMatch(source);
    if (m != null) {
      final raw = m.group(1)!;
      final n = int.tryParse(raw) ?? 1;
      return switch (m.group(2)) {
        'semaine' => n * 7,
        'mois' => n * 30,
        _ => n,
      };
    }
    if (source.contains('plusieurs jours')) return _prolongedFeverDays;
    return null;
  }
}
