import 'package:flutter/material.dart';
import 'package:sura/app/theme.dart';

/// Barre supérieure de progression à 11 étapes (conforme aux maquettes SŪRA)
class StepHeader extends StatelessWidget implements PreferredSizeWidget {
  final int currentStep; // 1 à 11
  final int totalSteps;
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onQuit;

  const StepHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 11,
    required this.title,
    this.onBack,
    this.onQuit,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SuraTheme.tealPrimary,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (onBack != null)
                    InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                    )
                  else
                    const SizedBox(width: 8),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (onQuit != null)
                    InkWell(
                      onTap: onQuit,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Quitter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Barre de progression à 11 segments
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: List.generate(totalSteps, (index) {
                  final isPassed = index < currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? SuraTheme.triageModerate // Marqueur ambre actif
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
