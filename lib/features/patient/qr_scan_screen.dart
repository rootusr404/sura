import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/utils/patient_id.dart';
import '../../core/widgets/inline_alert.dart';
import 'package:sura/core/db/repository_providers.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});
  @override
  ConsumerState<QrScanScreen> createState() => _State();
}

class _State extends ConsumerState<QrScanScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final raw = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (raw == null) return;
    _busy = true;

    final id = extractPatientId(raw);
    if (id == null) {
      _show('QR non reconnu : ce n\'est pas un code SŪRA.');
      return;
    }
    final patient = await ref.read(patientRepositoryProvider).getById(id);
    if (!mounted) return;
    if (patient == null) {
      _show(
        'Patient $id inconnu sur ce téléphone. Il a peut-être été créé sur un autre '
        'appareil : attendez la synchronisation ou créez un nouveau dossier.',
      );
      return;
    }
    context.pushReplacement('/patients/$id');
  }

  /// Affiche un message puis relance la détection après 2,5 s.
  void _show(String msg) {
    if (!mounted) return;
    setState(() => _message = msg);
    Future<void>.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() => _message = null);
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner un QR')),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _message != null
                ? InlineAlert(_message!)
                : const InlineAlert(
                    'Cadrez le QR du patient. Pas de caméra ? Cherchez son identifiant '
                    'dans la liste des patients.',
                    isError: false,
                  ),
          ),
        ],
      ),
    );
  }
}
