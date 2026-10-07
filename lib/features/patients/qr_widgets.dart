import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/widgets.dart';

/// QR du carnet de sante : identifiant opaque UNIQUEMENT, aucune donnee medicale (R2).
class PatientQr extends StatelessWidget {
  const PatientQr(this.data, {super.key});
  final String data;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: QrImageView(data: data, size: 180),
      );
}

/// Scanner : renvoie le texte lu via context.pop(code). Renvoie '__manual__' si l'agent prefere saisir a la main.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanState();
}

class _ScanState extends State<ScanScreen> {
  bool handled = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: suraAppBar(context, 'Scanner le QR'),
        body: Stack(children: [
          MobileScanner(
            onDetect: (capture) {
              if (handled) return;
              final code = capture.barcodes.isEmpty
                  ? null
                  : capture.barcodes.first.rawValue;
              if (code == null || code.isEmpty) return;
              handled = true;
              context.pop(code);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black54,
              padding: const EdgeInsets.all(14),
              child: SafeArea(
                top: false,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Centrez le QR du carnet de santé.',
                      style: TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: () => context.pop('__manual__'),
                    child: const Text('Saisir l’identifiant à la main',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      );
}
