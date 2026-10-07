import 'models.dart';

/// Normalisation : minuscules, sans accents, apostrophes -> espaces.
/// Les chiffres et la ponctuation (virgule decimale) sont conserves.
String normalizeText(String s) {
  const from = 'àâäáãåéèêëíìîïóòôöõúùûüýÿçñ';
  const to = 'aaaaaaeeeeiiiiooooouuuuyycn';
  final t =
      s.toLowerCase().replaceAll('œ', 'oe').replaceAll(RegExp(r"[’'`´]"), ' ');
  final b = StringBuffer();
  for (final ch in t.split('')) {
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Symptomes reconnus : libelle canonique -> mots-cles (normalises, sans accents).
/// L'ORDRE compte : le premier symptome sert de base au motif.
const _symptomKeywords = <String, List<String>>{
  'Fièvre': ['fievre', 'febrile'],
  'Toux': ['toux', 'touss'],
  'Maux de tête': [
    'maux de tete',
    'mal de tete',
    'mal a la tete',
    'cephale',
    'migraine'
  ],
  'Diarrhée': ['diarrhee', 'selles liquides'],
  'Vomissements': ['vomissement', 'vomit', 'vomi '],
  'Nausées': ['nausee', 'envie de vomir', 'mal au coeur'],
  'Douleur abdominale': [
    'douleur abdominale',
    'douleurs abdominales',
    'mal au ventre',
    'mal de ventre',
    'mal a l estomac',
    'ventre douloureux',
    'abdominal'
  ],
  'Fatigue': ['fatigue', 'fatigu', 'epuis', 'faiblesse'],
  'Convulsion': ['convuls'],
  'Difficulté respiratoire': [
    'difficulte a respirer',
    'difficulte respiratoire',
    'difficultes respiratoires',
    'respire mal',
    'mal a respirer',
    'essouffl',
    'detresse respiratoire',
    'respiration difficile',
  ],
  'Éruption cutanée': ['eruption', 'bouton', 'demangeaison'],
  'Frissons': ['frisson'],
  'Courbatures': ['courbature', 'douleurs musculaires'],
  'Mal de gorge': ['mal a la gorge', 'mal de gorge', 'angine'],
};

/// Extraction par regles (decision d'equipe : regles maison, explicables).
class Extractor {
  static const _nums = <String, int>{
    'un': 1,
    'une': 1,
    'deux': 2,
    'trois': 3,
    'quatre': 4,
    'cinq': 5,
    'six': 6,
    'sept': 7,
    'huit': 8,
    'neuf': 9,
    'dix': 10,
  };

  /// Libelles canoniques trouves dans un texte libre (insensible aux accents et a la casse).
  static List<String> canonicalSymptoms(String text) {
    final t = '${normalizeText(text)} ';
    final out = <String>[];
    _symptomKeywords.forEach((label, keys) {
      if (keys.any((k) => t.contains(k)) && !out.contains(label)) {
        out.add(label);
      }
    });
    return out;
  }

  /// Saisie manuelle : symptomes tapes a la main + symptomes cites dans le motif.
  static List<String> symptomsFromFields(String typed, String motif) {
    final out = <String>[];
    for (final raw in typed.split(',')) {
      final x = raw.trim();
      if (x.isEmpty) continue;
      final c = canonicalSymptoms(x);
      if (c.isEmpty) {
        final label = x[0].toUpperCase() + x.substring(1);
        if (!out.contains(label)) out.add(label);
      } else {
        for (final y in c) {
          if (!out.contains(y)) out.add(y);
        }
      }
    }
    for (final y in canonicalSymptoms(motif)) {
      if (!out.contains(y)) out.add(y);
    }
    return out;
  }

  static int? daysFromText(String? text) {
    if (text == null) return null;
    final t = normalizeText(text);
    final m = RegExp(
            r'\b(\d+|une?|deux|trois|quatre|cinq|six|sept|huit|neuf|dix)\s*(jours?|semaines?|mois)')
        .firstMatch(t);
    if (m != null) {
      final raw = m.group(1)!;
      final n = int.tryParse(raw) ?? _nums[raw] ?? 1;
      final unit = m.group(2)!;
      return unit.startsWith('jour')
          ? n
          : (unit.startsWith('sem') ? n * 7 : n * 30);
    }
    if (RegExp(r'\bhier\b').hasMatch(t)) return 1;
    return null;
  }

  /// Chiffres ("38,5", "38,5 °C", "38 degres") ou lettres ("trente-neuf virgule quatre degres", "trente-huit et demi").
  static double? parseTemperature(String text) {
    final t = normalizeText(text);
    final m = RegExp(r'(\d{2}(?:[.,]\d)?)\s*(?:°|degr)').firstMatch(t) ??
        RegExp(r'temperature\D{0,15}?(\d{2}(?:[.,]\d)?)').firstMatch(t) ??
        RegExp(r'^\s*(\d{2}(?:[.,]\d)?)\s*(?:°\s*c)?\s*$').firstMatch(t);
    if (m != null) {
      final v = double.tryParse(m.group(1)!.replaceAll(',', '.'));
      if (v != null && v >= 30 && v <= 45) return v;
    }
    return _wordTemp(t);
  }

  static double? _wordTemp(String t) {
    const unit = r'(?:un|deux|trois|quatre|cinq|six|sept|huit|neuf)';
    final body =
        '(trente|quarante)(?:[\\s-]+($unit))?(?:\\s+virgule\\s+($unit)|\\s+et\\s+(demi))?';
    final m = RegExp('$body\\s*(?:°|degr)').firstMatch(t) ??
        RegExp('(?:temperature|fievre)\\s+(?:de\\s+|a\\s+)?$body')
            .firstMatch(t);
    if (m == null) return null;
    var v = m.group(1) == 'trente' ? 30.0 : 40.0;
    final u = m.group(2);
    if (u != null) v += _nums[u]!;
    final d = m.group(3);
    if (d != null) v += _nums[d]! / 10;
    if (m.group(4) != null) v += 0.5;
    return (v >= 35 && v <= 42) ? v : null;
  }

  static Structured extract(String text) {
    final t = normalizeText(text);
    final symptoms = canonicalSymptoms(text);

    String? duration;
    int? days;
    final d = RegExp(
            r'depuis\s+(\d+|une?|deux|trois|quatre|cinq|six|sept|huit|neuf|dix)\s+(jours?|semaines?|mois)')
        .firstMatch(t);
    if (d != null) {
      final raw = d.group(1)!;
      final n = int.tryParse(raw) ?? _nums[raw] ?? 1;
      final unit = d.group(2)!;
      duration = '$n $unit';
      days = unit.startsWith('jour')
          ? n
          : (unit.startsWith('sem') ? n * 7 : n * 30);
    } else if (RegExp(r'depuis\s+hier').hasMatch(t)) {
      duration = '1 jour';
      days = 1;
    }

    final temp = parseTemperature(text);

    String? allergies;
    if (t.contains('aucune allergie') ||
        t.contains('pas d allergie') ||
        t.contains('pas allergique') ||
        t.contains('sans allergie')) {
      allergies = 'Aucune';
    }
    String? treatment;
    if (t.contains('aucun traitement') ||
        t.contains('sans traitement') ||
        t.contains('pas de traitement')) {
      treatment = 'Aucun';
    }

    final motif = symptoms.isEmpty
        ? null
        : (duration == null
            ? symptoms.first
            : '${symptoms.first} depuis $duration');
    return Structured(
      motif: motif,
      symptoms: symptoms,
      duration: duration,
      durationDays: days,
      temperature: temp,
      allergies: allergies,
      treatment: treatment,
    );
  }
}

/// Informations manquantes : alertes seulement, jamais bloquantes (R6).
class MissingFinder {
  static const labels = <String, String>{
    'temperature': 'Température (°C)',
    'allergies': 'Allergies connues',
    'treatment': 'Traitement en cours',
  };

  static List<String> find(Structured s) {
    final m = <String>[];
    if (s.temperature == null) m.add('temperature');
    if ((s.allergies ?? '').trim().isEmpty) m.add('allergies');
    if ((s.treatment ?? '').trim().isEmpty) m.add('treatment');
    return m;
  }
}

/// ATTENTION : seuils de DEMONSTRATION, a faire valider par un professionnel de sante
/// (protocoles type PCIME/OMS) avant tout usage reel. Ce n'est pas un diagnostic (R7, R8) :
/// l'agent decide toujours.
///
/// Les symptomes sont relus a l'evaluation (texte libre, majuscules, accents, synonymes) :
/// la saisie manuelle et la saisie vocale donnent donc le meme resultat.
class UrgencyEngine {
  static UrgencyResult evaluate(Structured s, {int? ageYears}) {
    final reasons = <String>[];
    final sym = <String>{};
    for (final x in s.symptoms) {
      sym.addAll(Extractor.canonicalSymptoms(x));
    }
    sym.addAll(Extractor.canonicalSymptoms(s.motif ?? ''));

    final temp = s.temperature;
    final days = s.durationDays ??
        Extractor.daysFromText(s.duration) ??
        Extractor.daysFromText(s.motif);
    var level = Urgency.faible;

    void raise(Urgency u) {
      if (u.index > level.index) level = u;
    }

    if (temp != null) {
      final t = temp.toString().replaceAll('.', ',');
      if (temp >= 40) {
        raise(Urgency.eleve);
        reasons.add('Fièvre très élevée : $t °C');
      } else if (temp >= 38.5) {
        raise(Urgency.modere);
        reasons.add('Fièvre à $t °C');
      }
    }
    if (sym.contains('Convulsion')) {
      raise(Urgency.eleve);
      reasons.add('Convulsion signalée');
    }
    if (sym.contains('Difficulté respiratoire')) {
      raise(Urgency.eleve);
      reasons.add('Difficulté respiratoire signalée');
    }
    if (ageYears != null && ageYears < 5 && temp != null && temp >= 39) {
      raise(Urgency.eleve);
      reasons.add('Enfant de moins de 5 ans avec forte fièvre');
    }
    if (days != null && days >= 3 && sym.contains('Fièvre')) {
      raise(Urgency.modere);
      reasons.add('Fièvre depuis ${s.duration ?? '$days jours'}');
    }
    if (reasons.isEmpty) reasons.add('Aucun signe de danger signalé');
    // Montre a l'agent que ses symptomes ont bien ete pris en compte.
    if (sym.isNotEmpty) {
      reasons.add('Symptômes pris en compte : ${sym.join(', ')}');
    }
    return UrgencyResult(level, reasons);
  }
}
