import 'package:flutter/material.dart';
import '../theme/sura_colors.dart';

class InlineAlert extends StatelessWidget {
  const InlineAlert(this.message, {super.key, this.isError = true});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.white : SuraColors.tealLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? SuraColors.ink : SuraColors.teal,
          width: isError ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 20,
            color: isError ? SuraColors.ink : SuraColors.tealDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: SuraColors.ink, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
