import 'package:flutter/material.dart';
import 'package:sura/core/widgets/dev_placeholder.dart';

class QrScanScreen extends StatelessWidget {
  const QrScanScreen({super.key});
  @override
  Widget build(BuildContext context) => const DevPlaceholder(
    title: 'Scanner un QR',
    task: 'F-05',
    owner: 'Membre 1',
  );
}
