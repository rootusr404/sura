import 'enums.dart';

/// Proposition d'urgence, explicable. L'agent peut la modifier (R7) et seul
/// lui valide (R8).
class UrgencyProposal {
  const UrgencyProposal({required this.level, this.reasons = const []});

  final UrgencyLevel level;

  /// Raisons lisibles par l'agent, ex. « Fièvre depuis plus de 3 jours ».
  final List<String> reasons;

  Map<String, dynamic> toJson() => {'level': level.name, 'reasons': reasons};

  factory UrgencyProposal.fromJson(Map<String, dynamic> j) => UrgencyProposal(
    level: UrgencyLevel.values.firstWhere(
      (e) => e.name == j['level'],
      orElse: () => UrgencyLevel.moderate,
    ),
    reasons: (j['reasons'] as List?)?.cast<String>() ?? const [],
  );
}
