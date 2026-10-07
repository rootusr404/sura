import 'package:sura/services/ai_local/consultation_data.dart';

/// Interface officielle partagée pour la structuration (Section 6 de l'architecture)
abstract class StructuringService {
  /// Transforme une transcription en données médicales structurées ConsultationData
  Future<ConsultationData> structure(String transcript);
}

/// Moteur d'extraction d'informations médicales par règles et expressions régulières (C-04)
/// Développé pour SŪRA : 100 % hors ligne, déterministe, instantané (< 5 ms)
/// GARANTIE : Ne plante JAMAIS sur texte vide, incomplet, bruité ou incohérent.
class InformationExtractor implements StructuringService {
  const InformationExtractor();

  @override
  Future<ConsultationData> structure(String transcript) async {
    return extract(transcript);
  }

  /// Extraction synchrone pure des champs à partir du texte
  ConsultationData extract(String? rawInput) {
    if (rawInput == null || rawInput.trim().isEmpty) {
      return const ConsultationData(
        chiefComplaint: 'other',
        symptoms: [],
        rawTranscript: '',
      );
    }

    final transcript = rawInput.trim();
    final lower = transcript.toLowerCase();

    // 1. Détection du motif principal (chiefComplaint)
    final chiefComplaint = _extractChiefComplaint(lower);

    // 2. Détection de la température
    final temperatureC = _extractTemperature(lower);

    // 3. Détection de la durée
    final durationDays = _extractDurationDays(lower);

    // 4. Détection du pouls / fréquence cardiaque
    final pulse = _extractPulse(lower);

    // 5. Détection de la fréquence respiratoire
    final respiratoryRate = _extractRespiratoryRate(lower);

    // 6. Détection du poids
    final weightKg = _extractWeight(lower);

    // 7. Détection de l'âge (converti en mois pour cohérence PCIME pédiatrique)
    final ageMonths = _extractAgeMonths(lower);

    // 8. Détection du statut de grossesse
    final pregnant = _extractPregnancy(lower);

    // 9. Détection des symptômes
    final symptoms = _extractSymptoms(lower);

    // 10. Détection des allergies
    final allergies = _extractAllergies(lower);

    // 11. Détection des médicaments
    final medications = _extractMedications(lower);

    // 12. Détection des antécédents médicaux
    final antecedents = _extractAntecedents(lower);

    return ConsultationData(
      chiefComplaint: chiefComplaint,
      symptoms: symptoms,
      ageMonths: ageMonths,
      durationDays: durationDays,
      temperatureC: temperatureC,
      weightKg: weightKg,
      respiratoryRate: respiratoryRate,
      pulse: pulse,
      pregnant: pregnant,
      allergies: allergies,
      medications: medications,
      antecedents: antecedents,
      rawTranscript: transcript,
    );
  }

  /// Détecte le motif de consultation et le renvoie en français.
  String _extractChiefComplaint(String text) {
    if (_hasAny(text, [
      'traumatisme',
      'blessure',
      'accident',
      'chute',
      'fracture',
      'plaie',
      'brûlure',
      'morsure',
      'coupure',
    ])) {
      return 'Traumatisme';
    }

    if (_hasAny(text, [
      'diarrhée',
      'diarrhee',
      'selles liquides',
      'selles fréquentes',
      'gastro',
      'déshydratation',
    ])) {
      return 'Diarrhée';
    }

    if (_hasAny(text, [
      'enceinte',
      'grossesse',
      'prénatal',
      'cpn',
      'accouchement',
      'contractions',
      'saignement obstétrical',
    ])) {
      return 'Grossesse';
    }

    if (_hasPositiveFever(text) &&
        _hasAny(text, ['convulsion', 'convulsions', 'crise convulsive'])) {
      return 'Fièvre avec convulsion';
    }

    if (_hasPositiveFever(text)) {
      return 'Fièvre';
    }

    if (_hasAny(text, ['rhume', 'nez qui coule', 'écoulement nasal'])) {
      return 'Rhume';
    }

    if (_hasAny(text, [
      'toux',
      'tousse',
      'expectoration',
      'crachats',
      'sifflement',
      'dyspnée',
      'bronchite',
      'pneumonie',
      'respiration difficile',
    ])) {
      return 'Toux';
    }

    return 'Autre';
  }

  bool _hasPositiveFever(String text) {
    final mentionsFever = _hasAny(text, [
      'fièvre',
      'fievre',
      'hyperthermie',
      'fébrile',
      'febrile',
    ]);
    if (!mentionsFever) return false;
    final negation = RegExp(
      r"(?:pas\s+(?:de|d['’])\s+|sans\s+|absence\s+de\s+|non\s+)(?:la\s+)?(?:fièvre|fievre)",
    );
    return !negation.hasMatch(text);
  }

  /// Extrait la température en °C (plage physiologique sécurisée : 35.0 - 43.0 °C)
  double? _extractTemperature(String text) {
    // Recherche de motifs comme : "39,4 °C", "39.4", "température de 38,5", "fièvre à 40", "38°"
    final regex = RegExp(
      r'(?:température|temperature|temp|fièvre\s*(?:à|de)?|fievre\s*(?:à|de)?|t°)?\s*([34]\d(?:[.,]\d)?)\s*(?:°\s*c|degrés|degres|°)?',
      caseSensitive: false,
    );

    final matches = regex.allMatches(text);
    for (final match in matches) {
      final rawVal = match.group(1);
      if (rawVal != null) {
        final normalized = rawVal.replaceAll(',', '.');
        final val = double.tryParse(normalized);
        if (val != null && val >= 35.0 && val <= 43.0) {
          return double.parse(val.toStringAsFixed(1));
        }
      }
    }
    return null;
  }

  /// Extrait la durée de l'affection en nombre de jours
  int? _extractDurationDays(String text) {
    // 0. Détection explicite des jours avant les indications vagues de "ce matin".
    final dayRegex = RegExp(
      r'(?:depuis|pendant|durée\s*(?:de|:)?)\s*(\d+)\s*(?:jours?|j\b)',
      caseSensitive: false,
    );
    final dayMatch = dayRegex.firstMatch(text);
    if (dayMatch != null) {
      final days = int.tryParse(dayMatch.group(1) ?? '');
      if (days != null) return days;
    }

    // 1. Détection "depuis hier" -> 1 jour
    if (text.contains('depuis hier') || text.contains('commencé hier')) {
      return 1;
    }
    if (text.contains('aujourd\'hui') || text.contains('ce matin')) {
      return 1;
    }

    // 2. Détection par nombre de semaines : "depuis 2 semaines" -> 14 jours
    final weekRegex = RegExp(
      r'(?:depuis|pendant|durée\s*:?)\s*(\d+)\s*semaine',
      caseSensitive: false,
    );
    final weekMatch = weekRegex.firstMatch(text);
    if (weekMatch != null) {
      final weeks = int.tryParse(weekMatch.group(1) ?? '');
      if (weeks != null) return weeks * 7;
    }

    // 3. Détection par nombre d'heures : "depuis 48 heures" -> 2 jours
    final hourRegex = RegExp(
      r'(?:depuis|pendant|il y a)\s*(\d+)\s*(?:heures|h\b)',
      caseSensitive: false,
    );
    final hourMatch = hourRegex.firstMatch(text);
    if (hourMatch != null) {
      final hours = int.tryParse(hourMatch.group(1) ?? '');
      if (hours != null) {
        final days = (hours / 24).round();
        return days > 0 ? days : 1;
      }
    }

    // 4. Pattern simplifié : "(\d+)\s*jours"
    final simpleDayRegex = RegExp(r'(\d+)\s*jours?', caseSensitive: false);
    final simpleDayMatch = simpleDayRegex.firstMatch(text);
    if (simpleDayMatch != null) {
      final days = int.tryParse(simpleDayMatch.group(1) ?? '');
      if (days != null && days < 365) return days;
    }

    return null;
  }

  /// Extrait le pouls / fréquence cardiaque en battements par minute
  int? _extractPulse(String text) {
    final regex = RegExp(
      r'(?:pouls|fréquence cardiaque|frequence cardiaque|fc|battements?)\s*(?:est\s*)?(?:de|à|:)?\s*(\d{2,3})\s*(?:bpm|battements|/min)?',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match != null) {
      final val = int.tryParse(match.group(1) ?? '');
      if (val != null && val >= 40 && val <= 240) {
        return val;
      }
    }

    // Recherche de notation directe "84 bpm"
    final bpmRegex = RegExp(r'(\d{2,3})\s*bpm', caseSensitive: false);
    final bpmMatch = bpmRegex.firstMatch(text);
    if (bpmMatch != null) {
      final val = int.tryParse(bpmMatch.group(1) ?? '');
      if (val != null && val >= 40 && val <= 240) {
        return val;
      }
    }

    return null;
  }

  /// Extrait la fréquence respiratoire par minute
  int? _extractRespiratoryRate(String text) {
    final regex = RegExp(
      r'(?:fréquence respiratoire|frequence respiratoire|fr\b|respiration)\s*(?:de|à|:)?\s*(\d{1,2})\s*(?:/min|mouvements?|cycles?)?',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match != null) {
      final val = int.tryParse(match.group(1) ?? '');
      if (val != null && val >= 10 && val <= 90) {
        return val;
      }
    }

    // Notation directe : "24 /min" ou "30 respirations/min"
    final directRegex = RegExp(
      r'(\d{1,2})\s*(?:/min|mouvements?\s*par\s*minute)',
      caseSensitive: false,
    );
    final directMatch = directRegex.firstMatch(text);
    if (directMatch != null) {
      final val = int.tryParse(directMatch.group(1) ?? '');
      if (val != null && val >= 10 && val <= 90) {
        return val;
      }
    }

    return null;
  }

  /// Extrait le poids en kg
  double? _extractWeight(String text) {
    final regex = RegExp(
      r'(?:poids|pèse|pesant)\s*(?:de|:)?\s*(\d{1,3}(?:[.,]\d+)?)\s*(?:kg|kilos?|k\b)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match != null) {
      final raw = match.group(1)?.replaceAll(',', '.');
      final val = double.tryParse(raw ?? '');
      if (val != null && val >= 1.5 && val <= 250.0) {
        return double.parse(val.toStringAsFixed(1));
      }
    }

    // Notation directe : "12,5 kg" ou "12 kg"
    final directRegex = RegExp(
      r'(\d{1,3}(?:[.,]\d+)?)\s*(?:kg|kilos?)',
      caseSensitive: false,
    );
    final directMatch = directRegex.firstMatch(text);
    if (directMatch != null) {
      final raw = directMatch.group(1)?.replaceAll(',', '.');
      final val = double.tryParse(raw ?? '');
      if (val != null && val >= 1.5 && val <= 250.0) {
        return double.parse(val.toStringAsFixed(1));
      }
    }

    return null;
  }

  /// Extrait l'âge en mois
  int? _extractAgeMonths(String text) {
    // 1. Détection "X mois" (ex: 8 mois)
    final monthRegex = RegExp(r'(\d+)\s*mois', caseSensitive: false);
    final monthMatch = monthRegex.firstMatch(text);
    if (monthMatch != null) {
      final val = int.tryParse(monthMatch.group(1) ?? '');
      if (val != null && val >= 0 && val <= 240) {
        return val;
      }
    }

    // 2. Détection "X an(s)" (ex: 3 ans -> 36 mois)
    final yearRegex = RegExp(r'(\d+)\s*(?:ans?|année)', caseSensitive: false);
    final yearMatch = yearRegex.firstMatch(text);
    if (yearMatch != null) {
      final val = int.tryParse(yearMatch.group(1) ?? '');
      if (val != null && val >= 0 && val <= 120) {
        return val * 12;
      }
    }

    return null;
  }

  /// Détecte si la patiente est enceinte
  bool? _extractPregnancy(String text) {
    if (text.contains('pas enceinte') || text.contains('non enceinte')) {
      return false;
    }
    if (_hasAny(text, [
      'enceinte',
      'grossesse',
      'attend un enfant',
      'femme enceinte',
      'patiente enceinte',
      'cpn',
    ])) {
      return true;
    }
    return null;
  }

  /// Extrait la liste des symptômes avec gestion des négations
  List<String> _extractSymptoms(String text) {
    final List<String> list = [];

    void checkSymptom(
      String label,
      List<String> keywords, [
      List<String> negations = const [],
    ]) {
      // Si une négation est présente dans le texte pour ce symptôme, on l'ignore
      for (final neg in negations) {
        if (text.contains(neg)) return;
      }
      if (_hasAny(text, keywords)) {
        if (!list.contains(label)) {
          list.add(label);
        }
      }
    }

    checkSymptom(
      'Fièvre',
      [
        'fièvre',
        'fievre',
        'chaud',
        'chaude',
        'hyperthermie',
        'fébrile',
        'febrile',
      ],
      [
        'pas de fièvre',
        'sans fièvre',
        'absence de fièvre',
        'apyrétique',
        'pas de fievre',
      ],
    );

    checkSymptom('Nez qui coule', [
      'nez qui coule',
      'nez coule',
      'écoulement nasal',
    ]);
    checkSymptom('Éternuements', ['éternue', 'éternuement', 'éternuements']);
    checkSymptom('Toux légère', ['toux légère', 'toux legere']);

    checkSymptom(
      'Frissons',
      ['frisson', 'frissons'],
      ['pas de frisson', 'sans frisson'],
    );
    checkSymptom(
      'Maux de tête (céphalées)',
      [
        'maux de tête',
        'mal de tete',
        'maux de tete',
        'céphalée',
        'cephalee',
        'céphalées',
        'cephalees',
      ],
      ['pas de maux de tête', 'sans céphalée'],
    );
    checkSymptom('Toux sèche', ['toux sèche', 'toux seche']);
    checkSymptom('Toux grasse', [
      'toux grasse',
      'expectoration',
      'expectorations',
      'crachats',
    ]);
    checkSymptom('Toux', ['toux', 'tousse'], ['pas de toux', 'sans toux']);
    checkSymptom('Courbatures', [
      'courbature',
      'courbatures',
      'douleurs musculaires',
    ]);
    checkSymptom('Fatigue (asthénie)', [
      'fatigue',
      'asthénie',
      'faiblesse générale',
      'épuisement',
    ]);
    checkSymptom(
      'Nausées',
      ['nausée', 'nausee', 'nausées', 'nausees'],
      ['pas de nausée', 'sans nausée'],
    );
    checkSymptom(
      'Vomissements',
      ['vomissement', 'vomissements', 'vomit', 'vomir'],
      ['pas de vomissement', 'sans vomissement'],
    );
    checkSymptom(
      'Diarrhée',
      ['diarrhée', 'diarrhee', 'selles liquides'],
      ['pas de diarrhée', 'sans diarrhée'],
    );
    checkSymptom(
      'Douleurs abdominales',
      [
        'mal au ventre',
        'douleur abdominale',
        'douleurs abdominales',
        'maux de ventre',
        'douleur au ventre',
      ],
      ['pas de douleur abdominale'],
    );
    checkSymptom('Douleur pelvienne', [
      'douleur pelvienne',
      'douleurs pelviennes',
      'bas ventre',
    ]);
    checkSymptom(
      'Difficulté respiratoire',
      [
        'dyspnée',
        'dyspnee',
        'étouffement',
        'respiration rapide',
        'sifflement',
        'tirage',
      ],
      ['respiration normale', 'sans dyspnée'],
    );
    checkSymptom('Convulsions', [
      'convulsion',
      'convulsions',
      'crise convulsive',
    ]);

    // Nettoyage : si "Toux sèche" ou "Toux grasse" est présente, on peut garder la précision
    if (list.any(
          (symptom) =>
              symptom == 'Toux sèche' ||
              symptom == 'Toux grasse' ||
              symptom == 'Toux légère',
        ) &&
        list.contains('Toux')) {
      list.remove('Toux');
    }

    return list;
  }

  /// Extrait les allergies mentionnées
  List<String> _extractAllergies(String text) {
    if (_hasAny(text, [
      'pas d\'allergie',
      'aucune allergie',
      'sans allergie',
      'allergies: non',
      'pas d allergie connue',
      'pas d\'allergie connue',
    ])) {
      return const ['aucune'];
    }

    final allergies = <String>[];
    if (text.contains('pénicilline') || text.contains('penicilline')) {
      allergies.add('Pénicilline');
    }
    if (text.contains('sulfamide') || text.contains('cotrimoxazole')) {
      allergies.add('Sulfamides');
    }
    if (text.contains('aspirine')) {
      allergies.add('Aspirine');
    }
    if (text.contains('amoxicilline')) {
      allergies.add('Amoxicilline');
    }

    // Pattern générique : "allergique à / au / aux X"
    final regex = RegExp(
      r'allerg(?:ie|ique)\s*(?:à|au|aux)?\s*([a-zA-ZÀ-ÿ]+)',
      caseSensitive: false,
    );
    final matches = regex.allMatches(text);
    for (final match in matches) {
      final item = match.group(1)?.trim();
      if (item != null && item.length > 2) {
        final capitalized =
            item[0].toUpperCase() + item.substring(1).toLowerCase();
        if (![
              'Pas',
              'Aucune',
              'Non',
              'La',
              'Le',
              'Les',
            ].contains(capitalized) &&
            !allergies.contains(capitalized)) {
          allergies.add(capitalized);
        }
      }
    }

    return allergies;
  }

  /// Extrait les médicaments mentionnés
  List<String> _extractMedications(String text) {
    if (_hasAny(text, [
      'aucun médicament',
      'aucun traitement',
      'pas de traitement',
      'sans traitement',
      'pas de médicament',
      'aucun medicament',
    ])) {
      return const ['aucun'];
    }

    final meds = <String>[];

    void checkMed(String label, List<String> keywords) {
      if (_hasAny(text, keywords)) {
        if (!meds.contains(label)) meds.add(label);
      }
    }

    checkMed('Paracétamol', [
      'paracétamol',
      'paracetamol',
      'doliprane',
      'efferalgan',
    ]);
    checkMed('Artéméther-Luméfantrine (CTA)', [
      'artéméther',
      'artemether',
      'luméfantrine',
      'coartem',
      'cta',
    ]);
    checkMed('Amoxicilline', ['amoxicilline', 'amoxil', 'clamoxyl']);
    checkMed('SRO (Sels de réhydratation)', [
      'sro',
      'sels de réhydratation',
      'rehydratation',
    ]);
    checkMed('Zinc', ['zinc']);
    checkMed('Cotrimoxazole', ['cotrimoxazole', 'bactrim']);
    checkMed('Ibuprofène', ['ibuprofène', 'ibuprofene', 'advil']);
    checkMed('Quinine', ['quinine']);

    return meds;
  }

  /// Extrait les antécédents médicaux pertinents
  List<String> _extractAntecedents(String text) {
    final antecedents = <String>[];

    if (_hasAny(text, [
      'pas d\'antécédent',
      'pas d’antécédent',
      'aucun antécédent',
      'aucune maladie connue',
      'pas d\'antécédents',
      'pas d’antécédents',
    ])) {
      return const ['aucun'];
    }

    void checkAnt(String label, List<String> keywords) {
      if (_hasAny(text, keywords)) {
        if (!antecedents.contains(label)) antecedents.add(label);
      }
    }

    checkAnt('Drépanocytose', [
      'drépanocytose',
      'drepanocytose',
      'drépanocytaire',
    ]);
    checkAnt('Asthme', ['asthme', 'asthmatique']);
    checkAnt('Diabète', ['diabète', 'diabete', 'diabétique']);
    checkAnt('Hypertension artérielle', [
      'hypertension',
      'hta',
      'tension élevée',
    ]);
    checkAnt('Malnutrition', ['malnutrition', 'émaciation', 'maigreur sévère']);

    return antecedents;
  }

  bool _hasAny(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (text.contains(kw)) return true;
    }
    return false;
  }
}
