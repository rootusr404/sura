/// Transcriptions cliniques de test pour SŪRA
/// Correspondant aux scénarios de démo et aux fixtures D-03 (OMS/PCIME)
class ClinicalFixtures {
  /// Scénario Démo D-03 : Consultation type Fatou Keïta (34 ans)
  /// Motif : Fièvre, maux de tête, toux sèche. Durée : 3 jours. Température : 39.4°C.
  /// Antécédent : Allaitement enfant 8 mois. Médicament : Paracétamol.
  static const String d03FatouKeita =
      "La patiente Fatou Keïta, 34 ans, présente une fièvre persistante depuis 3 jours, "
      "accompagnée de violents maux de tête et d'une toux sèche. Température mesurée à 39,4 °C. "
      "Elle allaite son enfant de 8 mois. Pas d'allergie connue. Elle a pris du paracétamol hier sans amélioration.";

  /// Scénario Démo 2 : Enfant Amadou Sow (4 ans) avec signes de danger PCIME
  /// Motif : Fièvre très élevée 40.1°C, convulsions, frissons, pouls 110 bpm, FR 34/min.
  /// Allergie : Pénicilline. Antécédent : Drépanocytose.
  static const String d03AmadouSow =
      "Enfant Amadou Sow âgé de 4 ans, amené pour forte fièvre depuis 2 jours avec frissons et convulsion ce matin. "
      "Température constatée à 40,1 °C, pouls à 110 bpm et fréquence respiratoire de 34 mouvements par minute. Pèse 14,5 kg. "
      "Antécédent de drépanocytose connu. Allergique à la pénicilline. Traitement en cours : aucun.";

  /// Scénario Démo 3 : Diarrhée aiguë et déshydratation du nourrisson
  /// Motif : Selles liquides fréquentes depuis 48 heures, vomissements. Âge : 11 mois.
  /// Poids : 8.5 kg. Médicaments : SRO et zinc.
  static const String d03NourrissonDiarrhee =
      "Nourrisson de 11 mois présentant une diarrhée aiguë avec selles liquides et vomissements depuis 48 heures. "
      "Poids de 8,5 kg, température normale à 37,2 °C. Absence de fièvre. Mère a débuté SRO et zinc à domicile.";

  /// Scénario Démo 4 : Femme enceinte au 3ème trimestre
  /// Motif : Grossesse, douleurs pelviennes, contractions. Durée : depuis ce matin.
  static const String d03GrossesseDouleur =
      "Patiente enceinte de 7 mois, venue pour douleurs pelviennes vives et contractions depuis ce matin. "
      "Température à 37,8 °C, pouls 86 bpm. Aucun traitement pris.";

  /// Scénario Démo 5 : Toux chronique et dyspnée
  /// Motif : Toux grasse persistante depuis 2 semaines avec expectorations et fatigue.
  static const String d03TouxChronique =
      "Homme de 52 ans se plaignant d'une toux grasse avec crachats depuis 2 semaines. "
      "Asthénie et fatigue importante. Fréquence respiratoire à 26 /min. Antécédent d'asthme.";

  /// Scénario Démo 6 : Traumatisme aigu
  /// Motif : Chute avec plaie ouverte et fracture suspectée
  static const String d03TraumatismeChute =
      "Patient victime d'un accident de moto avec chute il y a 3 heures. "
      "Plaie ouverte à la jambe et douleur vive. Pas de perte de connaissance.";

  /// Cas limites :
  static const String emptyText = "";
  static const String whitespaceOnly = "   \n\t   ";
  static const String noiseAndGibberish =
      "!@#\$%^&*()_+ 12345 blabla xyz qwerty random noise ??? :: --";
  static const String negationOnly =
      "Le patient va bien. Pas de fièvre, pas de toux, pas de diarrhée, aucune allergie, aucun traitement.";
}
