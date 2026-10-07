import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_page.dart';

class TranscriptScreen extends StatelessWidget {
  const TranscriptScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPage(
    consultationId: consultationId,
    step: ConsultationStep.transcript,
    title: 'Transcription',
    builder: (_, record) => _TranscriptBody(record: record),
  );
}

class _TranscriptBody extends ConsumerStatefulWidget {
  const _TranscriptBody({required this.record});
  final ConsultationRecord record;

  @override
  ConsumerState<_TranscriptBody> createState() => _TranscriptBodyState();
}

class _TranscriptBodyState extends ConsumerState<_TranscriptBody> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.record.transcript ?? '',
  );
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final transcript = _controller.text.trim();
    if (transcript.isEmpty || _busy) return;
    setState(() => _busy = true);
    await ref
        .read(consultationRepositoryProvider)
        .save(
          widget.record.copyWith(
            transcriptRaw: transcript,
            transcriptEdited: transcript,
            step: ConsultationStep.structured.name,
          ),
        );
    if (mounted) {
      context.go(ConsultationStep.structured.path(widget.record.id));
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'Relisez la transcription ou saisissez les notes de consultation.',
        style: TextStyle(height: 1.4),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _controller,
        minLines: 12,
        maxLines: 18,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Texte de la consultation',
          hintText:
              'Décrivez le motif, les symptômes et les informations utiles…',
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 20),
      SuraButton(
        label: 'Enregistrer le texte et continuer',
        icon: Icons.arrow_forward,
        loading: _busy,
        onPressed: _controller.text.trim().isEmpty ? null : _continue,
      ),
    ],
  );
}
