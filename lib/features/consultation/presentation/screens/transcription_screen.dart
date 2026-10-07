import 'package:flutter/material.dart';
import 'package:sura/app/theme.dart';
import 'package:sura/features/consultation/presentation/widgets/step_header.dart';
import 'package:sura/services/ai_local/transcription_service.dart';

/// Écran 22 de SŪRA : Transcription (Tâche C-03)
/// Fonctionne 100% hors connexion / mode avion.
/// Respecte :
/// - R4 : Transcription modifiable à tout moment par l'agent.
/// - Repli automatique ou direct vers la saisie manuelle en cas d'échec moteur.
class TranscriptionScreen extends StatefulWidget {
  final String? audioPath;
  final String initialText;
  final TranscriptionService? transcriptionService;
  final ValueChanged<String> onConfirmTranscription;
  final VoidCallback? onBack;

  const TranscriptionScreen({
    super.key,
    this.audioPath,
    this.initialText = '',
    this.transcriptionService,
    required this.onConfirmTranscription,
    this.onBack,
  });

  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  late final TranscriptionService _transcriptionService;
  late final TextEditingController _textController;

  bool _isLoading = false;
  double _progress = 0.0;
  bool _isEditing = false;
  bool _hasEngineError = false;
  String? _errorMessage;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _transcriptionService =
        widget.transcriptionService ?? LocalTranscriptionService();
    _textController = TextEditingController(text: widget.initialText);

    if (widget.initialText.isEmpty) {
      final mockText = _transcriptionService is LocalTranscriptionService
          ? _transcriptionService.mockTextOverride
          : null;

      if (mockText != null && mockText.isNotEmpty) {
        _textController.text = mockText;
      } else {
        _startTranscription();
      }
    }
  }

  Future<void> _startTranscription() async {
    setState(() {
      _isLoading = true;
      _hasEngineError = false;
      _errorMessage = null;
      _progress = 0.1;
    });

    try {
      final text = await _transcriptionService.transcribe(
        widget.audioPath ?? '',
      );
      if (mounted) {
        setState(() {
          _textController.text = text;
          _isLoading = false;
          _progress = 1.0;
        });
      }
    } on TranscriptionEngineException catch (e) {
      if (mounted) {
        setState(() {
          _hasEngineError = true;
          _errorMessage = e.message;
          _isLoading = false;
          _isEditing = true; // Bascule en saisie manuelle automatique
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasEngineError = true;
          _errorMessage =
              "Erreur de traitement : bascule vers la saisie manuelle.";
          _isLoading = false;
          _isEditing = true;
        });
      }
    }
  }

  void _togglePlayAudio() {
    setState(() {
      _isPlayingAudio = !_isPlayingAudio;
    });
    // Si lecture simulée, auto-stop après 3 secondes
    if (_isPlayingAudio) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StepHeader(
        currentStep: 3,
        title: 'Étape 3',
        onBack: widget.onBack,
        onQuit: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bandeau proposition SŪRA (Écran 22)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: SuraTheme.triageModerateBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: SuraTheme.triageModerate,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'SŪRA propose ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: SuraTheme.ink,
                              ),
                            ),
                            TextSpan(
                              text: _hasEngineError
                                  ? '— ${_errorMessage ?? 'Moteur indisponible. Saisie manuelle activée.'}'
                                  : '— vérifiez et corrigez avant de continuer (R4).',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: SuraTheme.ink,
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Cas de chargement / progression hors ligne
              if (_isLoading) ...[
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        color: SuraTheme.tealPrimary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Transcription locale en cours... (${(_progress * 100).toInt()}%)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: SuraTheme.slateMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Zone de texte transcription : Modifiable (R4)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isEditing
                          ? SuraTheme.tealPrimary
                          : SuraTheme.borderLine,
                      width: _isEditing ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Texte de la consultation',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: SuraTheme.slateMuted,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                            child: Text(
                              _isEditing
                                  ? '✓ Terminer l\'édition'
                                  : '✎ Modifier le texte (R4)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: SuraTheme.tealPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          enabled: _isEditing || !_isLoading,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.45,
                            color: SuraTheme.ink,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'Saisissez ou dictez les symptômes et observations de la consultation...',
                            hintStyle: TextStyle(
                              color: SuraTheme.slateMuted,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Lecteur audio local
              if (widget.audioPath != null && widget.audioPath!.isNotEmpty)
                InkWell(
                  onTap: _togglePlayAudio,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: SuraTheme.softTeal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isPlayingAudio
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: SuraTheme.tealPrimary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isPlayingAudio
                              ? 'Lecture audio en cours...'
                              : '▶ Écouter l’enregistrement audio local',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: SuraTheme.tealPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              if (_isLoading)
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = false;
                      _isEditing = true;
                    });
                  },
                  child: const Text('Passer directement en saisie manuelle'),
                ),

              // Boutons d'action : "Confirmer et continuer" & "Modifier / Saisie manuelle"
              ElevatedButton(
                onPressed: () {
                  widget.onConfirmTranscription(_textController.text.trim());
                },
                child: const Text('Confirmer et continuer'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                child: Text(
                  _isEditing ? 'Verrouiller le texte' : 'Modifier le texte',
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
