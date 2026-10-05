import 'package:flutter/material.dart';
import 'package:sura/app/theme.dart';
import 'package:sura/features/consultation/presentation/widgets/audio_waveform.dart';
import 'package:sura/features/consultation/presentation/widgets/step_header.dart';
import 'package:sura/services/ai_local/audio_recorder_service.dart';

/// Écran 21 de SŪRA : Enregistrement Audio (Tâche C-02)
/// Respecte strictement :
/// - R3 : Refuse de démarrer sans consentement accordé.
/// - F7 : État si micro refusé avec repli immédiat vers la saisie manuelle.
/// - Fichier audio local uniquement.
class AudioRecordingScreen extends StatefulWidget {
  final bool consentGiven;
  final String patientName;
  final AudioRecorderServiceInterface? recorderService;
  final ValueChanged<String?> onRecordingComplete;
  final VoidCallback onManualInputFallback;
  final VoidCallback onConsentMissing;

  const AudioRecordingScreen({
    super.key,
    required this.consentGiven,
    this.patientName = 'Fatou Keïta',
    this.recorderService,
    required this.onRecordingComplete,
    required this.onManualInputFallback,
    required this.onConsentMissing,
  });

  @override
  State<AudioRecordingScreen> createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  late final AudioRecorderServiceInterface _recorder;
  bool _isMicDenied = false;
  bool _isConsentMissing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _recorder = widget.recorderService ?? AudioRecorderService();
    _checkAndStart();
  }

  Future<void> _checkAndStart() async {
    // 1. RÈGLE STRICTE R3 : Refuse de démarrer sans consentement accordé
    if (!widget.consentGiven) {
      setState(() {
        _isConsentMissing = true;
      });
      return;
    }

    // 2. Démarrage de l'enregistrement avec capture de la permission micro
    try {
      await _recorder.startRecording(consentGiven: widget.consentGiven);
      setState(() {
        _isMicDenied = false;
        _errorMessage = null;
      });
    } on ConsentRequiredException catch (e) {
      setState(() {
        _isConsentMissing = true;
        _errorMessage = e.message;
      });
    } on MicrophonePermissionDeniedException catch (e) {
      setState(() {
        _isMicDenied = true;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecording();
    widget.onRecordingComplete(path);
  }

  Future<void> _togglePauseResume(RecordingState state) async {
    if (state.status == RecordingStatus.recording) {
      await _recorder.pauseRecording();
    } else if (state.status == RecordingStatus.paused) {
      await _recorder.resumeRecording();
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    if (widget.recorderService == null) {
      _recorder.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cas R3 : Consentement non accordé -> Refus catégorique de démarrer l'enregistrement
    if (_isConsentMissing) {
      return Scaffold(
        appBar: StepHeader(
          currentStep: 2,
          title: 'Étape 2',
          onQuit: () => Navigator.of(context).maybePop(),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: SuraTheme.triageHighBg,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: const Center(
                    child: Icon(Icons.gavel_rounded, color: SuraTheme.triageHigh, size: 36),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Consentement obligatoire (R3)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SuraTheme.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "SŪRA refuse formellement d'enregistrer la voix du patient sans consentement éclairé préalable accordé.",
                    style: TextStyle(
                      fontSize: 14,
                      color: SuraTheme.slateMuted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: widget.onConsentMissing,
                  child: const Text('Retourner au consentement'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: widget.onManualInputFallback,
                  child: const Text('Passer en saisie manuelle sans audio'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }

    // Cas F7 : Permission micro refusée -> Écran transverse F7
    if (_isMicDenied) {
      return Scaffold(
        appBar: StepHeader(
          currentStep: 2,
          title: 'Étape 2',
          onQuit: () => Navigator.of(context).maybePop(),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: SuraTheme.softTeal,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Center(
                    child: Icon(Icons.mic_off_rounded, color: SuraTheme.tealPrimary, size: 32),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Microphone non autorisé',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SuraTheme.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Sans micro, SŪRA ne peut pas enregistrer la consultation. '
                    'Autorisez-le dans les réglages, ou saisissez à la main.',
                    style: TextStyle(fontSize: 13.5, color: SuraTheme.slateMuted, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _checkAndStart,
                  child: const Text('Réessayer'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: widget.onManualInputFallback,
                  child: const Text('Saisir sans enregistrement (Repli)'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }

    // Cas normal : Enregistrement actif (Écran 21 de la maquette SŪRA)
    return Scaffold(
      appBar: StepHeader(
        currentStep: 2,
        title: 'Étape 2',
        onQuit: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: StreamBuilder<RecordingState>(
          stream: _recorder.stateStream,
          initialData: _recorder.currentState,
          builder: (context, snapshot) {
            final state = snapshot.data ?? const RecordingState();
            final isPaused = state.status == RecordingStatus.paused;
            final isRecording = state.status == RecordingStatus.recording;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Consultation : ${widget.patientName}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: SuraTheme.slateMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isPaused ? 'Enregistrement en pause' : 'Enregistrement en cours',
                    style: const TextStyle(
                      fontSize: 13,
                      color: SuraTheme.slateMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Minuteur au format MM:SS
                  Text(
                    _formatDuration(state.duration),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: SuraTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Visualiseur de formes d'onde audio
                  SizedBox(
                    height: 50,
                    child: AudioWaveform(
                      isRecording: isRecording,
                      isPaused: isPaused,
                      amplitude: state.amplitude,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Bouton Stop central conforme à la maquette (rouge argile SuraTheme.triageHigh)
                  GestureDetector(
                    onTap: _stopRecording,
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: SuraTheme.triageHigh,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: SuraTheme.triageHigh.withOpacity(0.35),
                            blurRadius: 18,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.stop_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Appuyez pour arrêter',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: SuraTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Boutons de contrôle secondaires : Pause / Reprendre
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _togglePauseResume(state),
                        icon: Icon(
                          isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          size: 20,
                        ),
                        label: Text(isPaused ? 'Reprendre' : 'Pause'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(130, 42),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Réassurance confidentialité et traitement 100% hors ligne
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: SuraTheme.softTeal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.lock_outline, size: 16, color: SuraTheme.tealPrimary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'L’audio est traité sur l’appareil. Rien n’est transmis.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: SuraTheme.tealPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
