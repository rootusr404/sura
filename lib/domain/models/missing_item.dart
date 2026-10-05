/// Information qui semble manquer. Alerte, jamais un blocage (R6).
class MissingItem {
  const MissingItem({required this.code, required this.label, this.hint});

  /// Identifiant stable, ex. 'allergies', 'duration'.
  final String code;

  /// Texte affiché à l'agent, ex. « Les allergies ne semblent pas renseignées ».
  final String label;
  final String? hint;

  Map<String, dynamic> toJson() => {'code': code, 'label': label, 'hint': hint};

  factory MissingItem.fromJson(Map<String, dynamic> j) => MissingItem(
    code: j['code'] as String,
    label: j['label'] as String,
    hint: j['hint'] as String?,
  );
}
