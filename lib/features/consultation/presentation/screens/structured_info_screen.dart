import 'package:flutter/material.dart';
import 'package:sura/app/theme.dart';
import 'package:sura/core/models/consultation_data.dart';
import 'package:sura/features/consultation/presentation/widgets/editable_field_tile.dart';
import 'package:sura/features/consultation/presentation/widgets/step_header.dart';
import 'package:sura/services/ai_local/information_extractor.dart';

/// Écran 23 de SŪRA : Informations structurées (Tâche C-04)
/// Respecte strictement :
/// - R5 : Informations modifiables à tout moment par l'agent de santé.
/// - Mise en évidence des constantes manquantes avec avertissement doux (Règles OMS).
class StructuredInfoScreen extends StatefulWidget {
  final String rawTranscript;
  final ConsultationData? initialData;
  final ValueChanged<ConsultationData> onValidated;
  final VoidCallback? onBack;

  const StructuredInfoScreen({
    super.key,
    required this.rawTranscript,
    this.initialData,
    required this.onValidated,
    this.onBack,
  });

  @override
  State<StructuredInfoScreen> createState() => _StructuredInfoScreenState();
}

class _StructuredInfoScreenState extends State<StructuredInfoScreen> {
  late ConsultationData _data;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _data = widget.initialData!;
    } else {
      const extractor = InformationExtractor();
      _data = extractor.extract(widget.rawTranscript);
    }
  }

  void _editStringField({
    required String title,
    required String currentValue,
    required ValueChanged<String> onSaved,
  }) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Modifier : $title',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: SuraTheme.ink,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: SuraTheme.borderLine),
            ),
            hintText: 'Saisissez la valeur...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler', style: TextStyle(color: SuraTheme.slateMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(90, 40),
            ),
            onPressed: () {
              onSaved(controller.text.trim());
              Navigator.of(ctx).pop();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _editNumberField({
    required String title,
    required num? currentValue,
    required String unit,
    required ValueChanged<num?> onSaved,
  }) {
    final controller = TextEditingController(
      text: currentValue != null ? currentValue.toString() : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Modifier : $title ($unit)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: SuraTheme.ink,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: SuraTheme.borderLine),
            ),
            hintText: 'Exemple : 38.5',
            suffixText: unit,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler', style: TextStyle(color: SuraTheme.slateMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(90, 40),
            ),
            onPressed: () {
              final val = num.tryParse(controller.text.replaceAll(',', '.'));
              onSaved(val);
              Navigator.of(ctx).pop();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  String _formatChiefComplaint(String complaint) {
    switch (complaint) {
      case 'fever':
        return 'Fièvre (suspicion paludisme / infection)';
      case 'cough':
        return 'Toux / Infection respiratoire';
      case 'diarrhea':
        return 'Diarrhée / Gastroentérite';
      case 'pregnancy':
        return 'Grossesse / Consultation prénatale';
      case 'trauma':
        return 'Traumatisme / Accident';
      default:
        return 'Autre motif';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNoTemp = _data.temperatureC == null;
    final bool hasNoDuration = _data.durationDays == null;

    return Scaffold(
      appBar: StepHeader(
        currentStep: 4,
        title: 'Étape 4',
        onBack: widget.onBack,
        onQuit: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: [
                  // Bandeau de réassurance SŪRA
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: SuraTheme.triageModerateBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.auto_awesome, size: 18, color: SuraTheme.triageModerate),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SŪRA propose ces informations — vérifiez et modifiez si besoin (R5).',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: SuraTheme.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 1. Motif principal
                  EditableFieldTile(
                    label: 'Motif principal',
                    value: _formatChiefComplaint(_data.chiefComplaint),
                    icon: Icons.medical_services_outlined,
                    onEdit: () {
                      _showComplaintSelector();
                    },
                  ),

                  // 2. Durée
                  EditableFieldTile(
                    label: 'Durée de la maladie',
                    value: _data.durationDays != null ? '${_data.durationDays} jour(s)' : null,
                    isMissing: hasNoDuration,
                    missingPlaceholder: '— Non renseignée (Remplir)',
                    icon: Icons.calendar_today_outlined,
                    onEdit: () {
                      _editNumberField(
                        title: 'Durée',
                        currentValue: _data.durationDays,
                        unit: 'jours',
                        onSaved: (val) {
                          setState(() {
                            _data = _data.copyWith(durationDays: val?.toInt());
                          });
                        },
                      );
                    },
                  ),

                  // 3. Symptômes
                  EditableFieldTile(
                    label: 'Symptômes observés',
                    value: _data.symptoms.isNotEmpty
                        ? _data.symptoms.join(', ')
                        : 'Aucun symptôme détecté',
                    icon: Icons.healing_outlined,
                    onEdit: () {
                      _editStringField(
                        title: 'Symptômes',
                        currentValue: _data.symptoms.join(', '),
                        onSaved: (val) {
                          setState(() {
                            _data = _data.copyWith(
                              symptoms: val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                            );
                          });
                        },
                      );
                    },
                  ),

                  // 4. Température (°C)
                  EditableFieldTile(
                    label: 'Température (°C)',
                    value: _data.temperatureC != null ? '${_data.temperatureC} °C' : null,
                    isMissing: hasNoTemp,
                    missingPlaceholder: '— À mesurer (Remplir)',
                    icon: Icons.thermostat_outlined,
                    onEdit: () {
                      _editNumberField(
                        title: 'Température',
                        currentValue: _data.temperatureC,
                        unit: '°C',
                        onSaved: (val) {
                          setState(() {
                            _data = _data.copyWith(temperatureC: val?.toDouble());
                          });
                        },
                      );
                    },
                  ),

                  // 5. Pouls (bpm)
                  EditableFieldTile(
                    label: 'Pouls / Fréquence cardiaque',
                    value: _data.pulse != null ? '${_data.pulse} bpm' : null,
                    missingPlaceholder: '— Non mesuré (Remplir)',
                    icon: Icons.favorite_border_rounded,
                    onEdit: () {
                      _editNumberField(
                        title: 'Pouls',
                        currentValue: _data.pulse,
                        unit: 'bpm',
                        onSaved: (val) {
                          setState(() {
                            _data = _data.copyWith(pulse: val?.toInt());
                          });
                        },
                      );
                    },
                  ),

                  // 6. Fréquence respiratoire
                  EditableFieldTile(
                    label: 'Fréquence respiratoire (/min)',
                    value: _data.respiratoryRate != null ? '${_data.respiratoryRate} /min' : null,
                    missingPlaceholder: '— Non mesurée',
                    icon: Icons.air_outlined,
                    onEdit: () {
                      _editNumberField(
                        title: 'Fréquence respiratoire',
                        currentValue: _data.respiratoryRate,
                        unit: '/min',
                        onSaved: (val) {
                          setState(() {
                            _data = _data.copyWith(respiratoryRate: val?.toInt());
                          });
                        },
                      );
                    },
                  ),

                  // 7. Traitement en cours
                  EditableFieldTile(
                    label: 'Médicaments / Traitement pris',
                    value: _data.medications.isNotEmpty
                        ? _data.medications.join(', ')
                        : 'Aucun traitement',
                    icon: Icons.medication_outlined,
                    onEdit: () {
                      _editStringField(
                        title: 'Médicaments',
                        currentValue: _data.medications.join(', '),
                        onSaved: (val) {
                          setState(() {
                            _data = _data.copyWith(
                              medications: val.isEmpty
                                  ? []
                                  : val.split(',').map((e) => e.trim()).toList(),
                            );
                          });
                        },
                      );
                    },
                  ),

                  // 8. Allergies connues
                  EditableFieldTile(
                    label: 'Allergies déclarées',
                    value: _data.allergies.isNotEmpty
                        ? _data.allergies.join(', ')
                        : 'Aucune allergie connue',
                    icon: Icons.warning_amber_rounded,
                    onEdit: () {
                      _editStringField(
                        title: 'Allergies',
                        currentValue: _data.allergies.join(', '),
                        onSaved: (val) {
                          setState(() {
                            _data = _data.copyWith(
                              allergies: val.isEmpty
                                  ? []
                                  : val.split(',').map((e) => e.trim()).toList(),
                            );
                          });
                        },
                      );
                    },
                  ),

                  // 9. Antécédents
                  EditableFieldTile(
                    label: 'Antécédents / Situation particulière',
                    value: _data.antecedents.isNotEmpty
                        ? _data.antecedents.join(', ')
                        : 'Aucun antécédent particulier',
                    icon: Icons.history_edu_outlined,
                    onEdit: () {
                      _editStringField(
                        title: 'Antécédents',
                        currentValue: _data.antecedents.join(', '),
                        onSaved: (val) {
                          setState(() {
                            _data = _data.copyWith(
                              antecedents: val.isEmpty
                                  ? []
                                  : val.split(',').map((e) => e.trim()).toList(),
                            );
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Barre inférieure de validation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: SuraTheme.borderLine)),
              ),
              child: ElevatedButton(
                onPressed: () {
                  widget.onValidated(_data);
                },
                child: const Text('Vérifier et continuer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComplaintSelector() {
    final list = [
      {'key': 'fever', 'label': 'Fièvre (paludisme / infection)'},
      {'key': 'cough', 'label': 'Toux / Problème respiratoire'},
      {'key': 'diarrhea', 'label': 'Diarrhée / Déshydratation'},
      {'key': 'pregnancy', 'label': 'Grossesse / CPN'},
      {'key': 'trauma', 'label': 'Traumatisme / Blessure'},
      {'key': 'other', 'label': 'Autre motif'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Sélectionner le motif principal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              ...list.map(
                (item) => ListTile(
                  title: Text(item['label']!),
                  trailing: _data.chiefComplaint == item['key']
                      ? const Icon(Icons.check, color: SuraTheme.tealPrimary)
                      : null,
                  onTap: () {
                    setState(() {
                      _data = _data.copyWith(chiefComplaint: item['key']);
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
