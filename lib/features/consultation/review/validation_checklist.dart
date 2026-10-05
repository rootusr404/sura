/// Une case de validation (R8).
class ChecklistItem {
  const ChecklistItem(this.code, this.label);
  final String code;
  final String label;
}

/// Les 5 cases que l'agent doit cocher avant de valider (R8). L'application
/// ne valide jamais seule : sans les 5 cases, la validation est impossible.
class ValidationChecklist {
  const ValidationChecklist._();

  static const items = <ChecklistItem>[
    ChecklistItem('transcript', 'J\'ai relu la transcription.'),
    ChecklistItem('structured', 'J\'ai vérifié les informations structurées.'),
    ChecklistItem(
      'missing',
      'J\'ai pris connaissance des informations manquantes.',
    ),
    ChecklistItem('urgency', 'J\'ai vérifié le niveau d\'urgence.'),
    ChecklistItem(
      'responsibility',
      'Je valide ce dossier sous ma responsabilité.',
    ),
  ];

  /// Vrai seulement si chacune des 5 cases connues est cochée.
  static bool isComplete(Map<String, bool> checked) =>
      remaining(checked).isEmpty;

  /// Cases non cochées (ou absentes), dans l'ordre d'affichage.
  static List<ChecklistItem> remaining(Map<String, bool> checked) => [
    for (final item in items)
      if (checked[item.code] != true) item,
  ];
}
