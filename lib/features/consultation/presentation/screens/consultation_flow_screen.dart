import 'package:flutter/material.dart';
import 'package:sura/app/theme.dart';
import 'package:sura/core/models/consultation_data.dart';
import 'package:sura/features/consultation/presentation/screens/audio_recording_screen.dart';
import 'package:sura/features/consultation/presentation/screens/structured_info_screen.dart';
import 'package:sura/features/consultation/presentation/screens/transcription_screen.dart';
import 'package:sura/features/consultation/presentation/widgets/step_header.dart';
import 'package:sura/services/ai_local/audio_recorder_service.dart';
import 'package:sura/services/ai_local/information_extractor.dart';
import 'package:sura/services/ai_local/transcription_service.dart';

/// Parcours complet de consultation géré par Membre 2 :
/// Enregistrement audio (C-02) -> Transcription (C-03) -> Structuration (C-04)
/// avec respect strict de R3 (consentement), R4 (transcription modifiable), R5 (champs modifiables)
/// et repli officiel vers la saisie manuelle selon la décision D-07 (C-01).
class ConsultationFlowScreen extends StatefulWidget {
  final AudioRecorderServiceInterface? customRecorderService;
  final TranscriptionService? customTranscriptionService;
  final bool initialConsentGiven;

  const ConsultationFlowScreen({
    super.key,
    this.customRecorderService,
    this.customTranscriptionService,
    this.initialConsentGiven = true,
  });

  @override
  State<ConsultationFlowScreen> createState() => _ConsultationFlowScreenState();
}

enum ConsultationFlowStep {
  consent, // Écran 19 / 20
  recording, // Écran 21 (C-02)
  transcription, // Écran 22 (C-03)
  structuring, // Écran 23 (C-04)
  completed, // Récapitulatif
}

class _ConsultationFlowScreenState extends State<ConsultationFlowScreen> {
  late ConsultationFlowStep _currentStep;
  late bool _consentGiven;
  String? _recordedAudioPath;
  String _transcriptText = '';
  ConsultationData? _structuredData;

  @override
  void initState() {
    super.initState();
    _consentGiven = widget.initialConsentGiven;
    _currentStep = ConsultationFlowStep.consent;
  }

  void _onConsentAccepted() {
    setState(() {
      _consentGiven = true;
      _currentStep = ConsultationFlowStep.recording;
    });
  }

  void _onConsentRefused() {
    setState(() {
      _consentGiven = false;
      // Conformément à R3 : si refusé, l'audio ne démarre pas.
      // SŪRA propose le retour ou la saisie manuelle sans enregistrement.
    });
  }

  void _goToManualInput() {
    setState(() {
      _recordedAudioPath = null;
      _transcriptText = '';
      _currentStep = ConsultationFlowStep.transcription;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case ConsultationFlowStep.consent:
        return _buildConsentScreen();

      case ConsultationFlowStep.recording:
        return AudioRecordingScreen(
          consentGiven: _consentGiven,
          recorderService: widget.customRecorderService,
          onRecordingComplete: (path) {
            setState(() {
              _recordedAudioPath = path;
              _currentStep = ConsultationFlowStep.transcription;
            });
          },
          onManualInputFallback: _goToManualInput,
          onConsentMissing: () {
            setState(() {
              _currentStep = ConsultationFlowStep.consent;
            });
          },
        );

      case ConsultationFlowStep.transcription:
        return TranscriptionScreen(
          audioPath: _recordedAudioPath,
          initialText: _transcriptText,
          transcriptionService: widget.customTranscriptionService,
          onBack: () {
            setState(() {
              _currentStep = ConsultationFlowStep.recording;
            });
          },
          onConfirmTranscription: (text) {
            setState(() {
              _transcriptText = text;
              const extractor = InformationExtractor();
              _structuredData = extractor.extract(text);
              _currentStep = ConsultationFlowStep.structuring;
            });
          },
        );

      case ConsultationFlowStep.structuring:
        return StructuredInfoScreen(
          rawTranscript: _transcriptText,
          initialData: _structuredData,
          onBack: () {
            setState(() {
              _currentStep = ConsultationFlowStep.transcription;
            });
          },
          onValidated: (data) {
            setState(() {
              _structuredData = data;
              _currentStep = ConsultationFlowStep.completed;
            });
          },
        );

      case ConsultationFlowStep.completed:
        return _buildCompletedScreen();
    }
  }

  /// Écran 19 / 20 : Consentement éclairé du patient (R3)
  Widget _buildConsentScreen() {
    return Scaffold(
      appBar: const StepHeader(
        currentStep: 1,
        title: 'Étape 1',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Consentement du patient',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SuraTheme.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Expliquez à la patiente (Fatou Keïta) que vous allez enregistrer la consultation pour vous aider à remplir son dossier médical.',
                style: TextStyle(fontSize: 13.5, color: SuraTheme.slateMuted),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SuraTheme.borderLine),
                ),
                child: Column(
                  children: const [
                    _ConsentCheckItem(text: 'L’audio reste strictement sur cet appareil'),
                    SizedBox(height: 8),
                    _ConsentCheckItem(text: 'Suppression définitive après validation'),
                    SizedBox(height: 8),
                    _ConsentCheckItem(text: 'Refus possible à tout moment (R3)'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: SuraTheme.softTeal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.volume_up_outlined, size: 18, color: SuraTheme.tealPrimary),
                    SizedBox(width: 8),
                    Text(
                      '🔊 Écouter l’explication à voix haute (Wolof / Français)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: SuraTheme.tealPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              if (!_consentGiven) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SuraTheme.triageHighBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: SuraTheme.triageHigh, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Consentement actuellement refusé : l’enregistrement audio est bloqué (R3).',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: SuraTheme.triageHigh,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _onConsentRefused();
                        _goToManualInput();
                      },
                      child: const Text('Refuser (Saisie manuelle)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onConsentAccepted,
                      child: const Text('Accepter'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Écran récapitulatif après complétion de la structuration
  Widget _buildCompletedScreen() {
    final d = _structuredData ?? const ConsultationData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation SŪRA — Données prêtes'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SuraTheme.softTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: SuraTheme.tealPrimary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Informations extraites et validées',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: SuraTheme.tealPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Prêt pour le Triage (Membre 3) et la Sauvegarde (Membre 4)',
                            style: TextStyle(fontSize: 12, color: SuraTheme.tealPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SuraTheme.borderLine),
                  ),
                  child: ListView(
                    children: [
                      _infoRow('Motif', d.chiefComplaint),
                      _infoRow('Durée', d.durationDays != null ? '${d.durationDays} jour(s)' : 'Non renseignée'),
                      _infoRow('Température', d.temperatureC != null ? '${d.temperatureC} °C' : 'Non mesurée'),
                      _infoRow('Pouls', d.pulse != null ? '${d.pulse} bpm' : 'Non mesuré'),
                      _infoRow('Symptômes', d.symptoms.isNotEmpty ? d.symptoms.join(', ') : 'Aucun'),
                      _infoRow('Médicaments', d.medications.isNotEmpty ? d.medications.join(', ') : 'Aucun'),
                      _infoRow('Allergies', d.allergies.isNotEmpty ? d.allergies.join(', ') : 'Aucune'),
                      _infoRow('Antécédents', d.antecedents.isNotEmpty ? d.antecedents.join(', ') : 'Aucun'),
                      const Divider(height: 24),
                      const Text(
                        'Transcription brute (R4) :',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SuraTheme.slateMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.rawTranscript,
                        style: const TextStyle(fontSize: 13, height: 1.4, color: SuraTheme.ink),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = ConsultationFlowStep.consent;
                  });
                },
                child: const Text('Recommencer une consultation'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: SuraTheme.slateMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: SuraTheme.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentCheckItem extends StatelessWidget {
  final String text;
  const _ConsentCheckItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_rounded, color: SuraTheme.tealPrimary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: SuraTheme.ink,
            ),
          ),
        ),
      ],
    );
  }
}
