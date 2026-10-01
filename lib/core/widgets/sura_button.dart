import 'package:flutter/material.dart';
import '../theme/sura_colors.dart';

enum SuraButtonKind { primary, secondary, destructive }

class SuraButton extends StatelessWidget {
  const SuraButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = SuraButtonKind.primary,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SuraButtonKind kind;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = loading ? null : onPressed;
    final child = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );
    switch (kind) {
      case SuraButtonKind.primary:
        return FilledButton(onPressed: action, child: child);
      case SuraButtonKind.secondary:
        return OutlinedButton(onPressed: action, child: child);
      case SuraButtonKind.destructive:
        return OutlinedButton(
          onPressed: action,
          style: OutlinedButton.styleFrom(
            foregroundColor: SuraColors.ink,
            side: const BorderSide(color: SuraColors.ink, width: 2),
          ),
          child: child,
        );
    }
  }
}
