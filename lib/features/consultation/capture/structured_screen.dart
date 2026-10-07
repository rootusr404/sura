import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/features/consultation/capture/capture_providers.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_page.dart';

class StructuredScreen extends StatelessWidget {
  const StructuredScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPage(
    consultationId: consultationId,
    step: ConsultationStep.structured,
    title: 'Informations structurées',
    builder: (_, record) => _StructuredBody(record: record),
  );
}

class _StructuredBody extends ConsumerStatefulWidget {
  const _StructuredBody({required this.record});
  final ConsultationRecord record;

  @override
  ConsumerState<_StructuredBody> createState() => _StructuredBodyState();
}

class _StructuredBodyState extends ConsumerState<_StructuredBody> {
  late final Map<String, TextEditingController> _fields = _createFields();
  bool _busy = false;

  Map<String, TextEditingController> _createFields() {
    final current =
        widget.record.structured ??
        ref
            .read(informationExtractorProvider)
            .extract(widget.record.transcript ?? '');
    return {
      'chiefComplaint': TextEditingController(
        text: current.chiefComplaint ?? '',
      ),
      'symptoms': TextEditingController(text: current.symptoms.join(', ')),
      'duration': TextEditingController(text: current.duration ?? ''),
      'temperature': TextEditingController(
        text: current.temperatureC?.toString() ?? '',
      ),
      'pulse': TextEditingController(text: current.pulse?.toString() ?? ''),
      'allergies': TextEditingController(text: current.allergies ?? ''),
      'medications': TextEditingController(text: current.medications ?? ''),
      'history': TextEditingController(text: current.history ?? ''),
    };
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _value(String key) {
    final value = _fields[key]!.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _continue() async {
    if (_busy) return;
    setState(() => _busy = true);
    final temperature = double.tryParse(
      (_value('temperature') ?? '').replaceAll(',', '.'),
    );
    final pulse = int.tryParse(_value('pulse') ?? '');
    final info = StructuredInfo(
      chiefComplaint: _value('chiefComplaint'),
      symptoms: (_value('symptoms') ?? '')
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      duration: _value('duration'),
      temperatureC: temperature,
      pulse: pulse,
      allergies: _value('allergies'),
      medications: _value('medications'),
      history: _value('history'),
    );
    await ref
        .read(consultationRepositoryProvider)
        .save(
          widget.record.copyWith(
            structured: info,
            step: ConsultationStep.missing.name,
          ),
        );
    if (mounted) context.go(ConsultationStep.missing.path(widget.record.id));
  }

  Widget _field(
    String key,
    String label, {
    int lines = 1,
    bool numeric = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: _fields[key],
      minLines: lines,
      maxLines: lines,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: numeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'Vérifiez et corrigez les informations proposées avant de continuer.',
        style: TextStyle(height: 1.4),
      ),
      const SizedBox(height: 16),
      _field('chiefComplaint', 'Motif de consultation'),
      _field('symptoms', 'Symptômes (séparés par des virgules)', lines: 2),
      _field('duration', 'Durée'),
      _field('temperature', 'Température (°C)', numeric: true),
      _field('pulse', 'Pouls (battements/min)', numeric: true),
      _field('allergies', 'Allergies'),
      _field('medications', 'Médicaments'),
      _field('history', 'Antécédents'),
      const SizedBox(height: 8),
      SuraButton(
        label: 'Enregistrer et vérifier les informations manquantes',
        icon: Icons.arrow_forward,
        loading: _busy,
        onPressed: _continue,
      ),
    ],
  );
}
