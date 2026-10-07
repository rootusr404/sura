import 'package:flutter/material.dart';
import 'package:sura/app/theme.dart';

/// Carte de champ médical structuré modifiable (Règle R5 & Écran 23 de SŪRA)
class EditableFieldTile extends StatelessWidget {
  final String label;
  final String? value;
  final String missingPlaceholder;
  final bool isMissing;
  final VoidCallback onEdit;
  final IconData? icon;

  const EditableFieldTile({
    super.key,
    required this.label,
    required this.value,
    this.missingPlaceholder = '— Remplir',
    this.isMissing = false,
    required this.onEdit,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasNoValue = value == null || value!.trim().isEmpty;
    final bool highlightMissing = isMissing || hasNoValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: highlightMissing
            ? Border.all(color: SuraTheme.triageModerate, width: 1.5)
            : Border.all(color: SuraTheme.borderLine, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: highlightMissing
                        ? SuraTheme.triageModerate
                        : SuraTheme.tealPrimary,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: highlightMissing
                              ? SuraTheme.triageModerate
                              : SuraTheme.slateMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        highlightMissing ? '—' : value!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: highlightMissing
                              ? SuraTheme.slateMuted
                              : SuraTheme.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: highlightMissing
                        ? SuraTheme.triageModerateBg
                        : SuraTheme.softTeal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    highlightMissing ? 'Remplir' : '✎ Modifier',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: highlightMissing
                          ? SuraTheme.triageModerate
                          : SuraTheme.tealPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
