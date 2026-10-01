import 'package:flutter/material.dart';
import '../theme/sura_colors.dart';

/// Clavier PIN 6 chiffres. Changer la `key` du widget réinitialise la saisie.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.onCompleted,
    this.enabled = true,
    this.length = 6,
  });
  final ValueChanged<String> onCompleted;
  final bool enabled;
  final int length;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _value = '';

  void _tap(String d) {
    if (!widget.enabled || _value.length >= widget.length) return;
    setState(() => _value += d);
    if (_value.length == widget.length) widget.onCompleted(_value);
  }

  void _back() {
    if (!widget.enabled || _value.isEmpty) return;
    setState(() => _value = _value.substring(0, _value.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (i) {
            final filled = i < _value.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? SuraColors.teal : Colors.transparent,
                border: Border.all(color: SuraColors.teal, width: 2),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '<'],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final k in row)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _key(k),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _key(String k) {
    if (k.isEmpty) return const SizedBox(width: 72, height: 72);
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: widget.enabled ? SuraColors.surface : SuraColors.slateLight,
        shape: const CircleBorder(side: BorderSide(color: SuraColors.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => k == '<' ? _back() : _tap(k),
          child: Center(
            child: k == '<'
                ? const Icon(Icons.backspace_outlined, color: SuraColors.ink)
                : Text(
                    k,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: SuraColors.ink,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
