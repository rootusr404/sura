import 'package:flutter/material.dart';
import '../theme/sura_colors.dart';

class SuraLogo extends StatelessWidget {
  const SuraLogo({super.key, this.size = 72, this.showName = true});
  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: SuraColors.teal,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Icon(
            Icons.monitor_heart_outlined,
            color: Colors.white,
            size: size * 0.55,
          ),
        ),
        if (showName) ...[
          const SizedBox(height: 12),
          const Text(
            'SŪRA',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              color: SuraColors.tealDark,
            ),
          ),
        ],
      ],
    );
  }
}
