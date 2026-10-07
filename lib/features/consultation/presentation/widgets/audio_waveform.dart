import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sura/app/theme.dart';

/// Visualiseur de forme d'onde audio animé pour l'enregistrement (Écran 21)
class AudioWaveform extends StatefulWidget {
  final bool isRecording;
  final bool isPaused;
  final double amplitude; // 0.0 à 1.0

  const AudioWaveform({
    super.key,
    required this.isRecording,
    this.isPaused = false,
    this.amplitude = 0.0,
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const int barCount = 18;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(barCount, (index) {
            double height = 6.0;
            if (widget.isRecording && !widget.isPaused) {
              final wave = sin(
                (index / barCount) * pi + (_controller.value * pi),
              );
              final dynamicAmp =
                  (widget.amplitude * 28.0) + (wave.abs() * 18.0);
              height = max(6.0, dynamicAmp);
            } else if (widget.isPaused) {
              height = 8.0;
            }

            return Container(
              width: 5,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: widget.isPaused
                    ? SuraTheme.slateMuted.withValues(alpha: 0.5)
                    : SuraTheme.tealPrimary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
