import 'package:flutter/material.dart';

class PinKeypad extends StatelessWidget {
  const PinKeypad({super.key, required this.onKey});
  final void Function(String key) onKey;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.6,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        for (final k in keys)
          k.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(5),
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () => onKey(k),
                    child: Text(k,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                  ),
                ),
      ],
    );
  }
}

class PinDots extends StatelessWidget {
  const PinDots(this.filled, {super.key});
  final int filled;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (var i = 0; i < 6; i++)
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < filled ? c : Colors.transparent,
            border: Border.all(color: c, width: 2),
          ),
        ),
    ]);
  }
}
