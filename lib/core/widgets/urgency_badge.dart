import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../theme/sura_colors.dart';

/// Badge d'urgence : forme + texte + couleur (jamais la couleur seule).
class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge({super.key, required this.level, this.large = false});
  final UrgencyLevel level;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final (label, icon, bg, fg, borderColor) = switch (level) {
      UrgencyLevel.high => (
        'ÉLEVÉ',
        Icons.change_history,
        SuraColors.ink,
        Colors.white,
        SuraColors.ink,
      ),
      UrgencyLevel.moderate => (
        'MODÉRÉ',
        Icons.diamond_outlined,
        SuraColors.amberLight,
        SuraColors.ink,
        SuraColors.amberDark,
      ),
      UrgencyLevel.low => (
        'FAIBLE',
        Icons.square_outlined,
        SuraColors.greenLight,
        SuraColors.ink,
        SuraColors.green,
      ),
    };
    final size = large ? 22.0 : 16.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 10 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: large ? 16 : 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
