import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/core/widgets/inline_alert.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/domain/contracts/audio_recorder_service.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/features/consultation/capture/capture_providers.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_page.dart';
import 'package:sura/services/ai_local/audio_recorder_service.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPage(
    consultationId: consultationId,
    step: ConsultationStep.record,
    title: 'Enregistrement',
    builder: (_, record) => _RecordingBody(record: record),
  );
}

class _RecordingBody extends ConsumerStatefulWidget {
  const _RecordingBody({required this.record});
  final ConsultationRecord record;

  @override
  ConsumerState<_RecordingBody> createState() => _RecordingBodyState();
}

class _RecordingBodyState extends ConsumerState<_RecordingBody> {
  AudioRecorderService? _recorder;
  bool _starting = false;
  bool _recording = false;
  bool _busy = false;
  String? _error;

  bool get _consentGranted => widget.record.consent == ConsentStatus.granted;

  @override
  void initState() {
    super.initState();
    if (_consentGranted) {
      _recorder = ref.read(audioRecorderProvider(true));
      unawaited(_startRecording());
    }
  }

  Future<void> _startRecording() async {
    if (!_consentGranted || _recorder == null || _starting || _recording) {
      return;
    }
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      if (!await _recorder!.requestPermission()) {
        throw StateError('Le microphone n’est pas autorisé.');
      }
      // Deuxième garde avant l’appel au service : le service vérifie aussi
      // consentGranted avant d’accéder au microphone.
      if (!_consentGranted) throw const AudioConsentRequiredException();
      await _recorder!.start();
      if (mounted) setState(() => _recording = true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _saveTranscript(String transcript) async {
    await ref
        .read(consultationRepositoryProvider)
        .save(
          widget.record.copyWith(
            transcriptRaw: transcript,
            transcriptEdited: transcript,
            step: ConsultationStep.transcript.name,
          ),
        );
    if (mounted) context.go(ConsultationStep.transcript.path(widget.record.id));
  }

  Future<void> _manualEntry() async {
    if (_recording) {
      await _recorder?.cancel();
      _recording = false;
    }
    await ref
        .read(consultationRepositoryProvider)
        .save(widget.record.copyWith(step: ConsultationStep.transcript.name));
    if (mounted) context.go(ConsultationStep.transcript.path(widget.record.id));
  }

  Future<void> _stopAndTranscribe() async {
    if (!_consentGranted || !_recording || _busy) return;
    setState(() => _busy = true);
    try {
      final audioPath = await _recorder!.stop();
      setState(() => _recording = false);
      final result = await ref
          .read(transcriptionServiceProvider)
          .transcribe(audioPath);
      await _saveTranscript(result.text);
    } catch (error) {
      if (mounted) {
        setState(() {
          _recording = false;
          _error = 'Transcription indisponible. Vous pouvez saisir le texte.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    if (_recording) unawaited(_recorder?.cancel() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_consentGranted) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const InlineAlert(
            'Le consentement audio n’a pas été accordé. Aucun enregistrement ne sera lancé.',
          ),
          const SizedBox(height: 16),
          SuraButton(
            label: 'Continuer en saisie manuelle',
            icon: Icons.edit_note,
            onPressed: _manualEntry,
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'L’enregistrement reste sur cet appareil. Vous pourrez vérifier et corriger le texte ensuite.',
          style: TextStyle(height: 1.4),
        ),
        const SizedBox(height: 28),
        Center(
          child: Icon(
            _recording ? Icons.mic : Icons.mic_none,
            size: 64,
            color: _recording ? SuraColors.teal : SuraColors.inkSoft,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            _starting
                ? 'Préparation du microphone…'
                : _recording
                ? 'Enregistrement en cours'
                : 'Enregistrement arrêté',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          InlineAlert(_error!),
        ],
        const SizedBox(height: 28),
        if (_recording)
          SuraButton(
            label: 'Arrêter et transcrire',
            icon: Icons.stop,
            loading: _busy,
            onPressed: _stopAndTranscribe,
          )
        else if (!_starting)
          SuraButton(
            label: 'Réessayer l’enregistrement',
            icon: Icons.mic,
            onPressed: _startRecording,
          ),
        const SizedBox(height: 12),
        SuraButton(
          label: 'Saisir le texte manuellement',
          icon: Icons.edit_note,
          kind: SuraButtonKind.secondary,
          onPressed: _busy ? null : _manualEntry,
        ),
      ],
    );
  }
}
