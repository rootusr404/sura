import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sura/app/theme.dart';
import 'package:sura/features/consultation/presentation/screens/consultation_flow_screen.dart';
import 'package:sura/features/consultation/presentation/screens/audio_recording_screen.dart';
import 'package:sura/features/consultation/presentation/screens/transcription_screen.dart';
import 'package:sura/features/consultation/presentation/screens/structured_info_screen.dart';
import 'package:sura/services/ai_local/audio_recorder_service.dart';
import 'package:sura/services/ai_local/transcription_service.dart';

class MockAudioRecorderService implements AudioRecorderServiceInterface {
  RecordingState _state = const RecordingState();
  bool permissionGranted = true;

  @override
  RecordingState get currentState => _state;

  @override
  Stream<RecordingState> get stateStream => Stream.value(_state);

  @override
  Future<bool> checkPermission() async => permissionGranted;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<String> startRecording({required bool consentGiven, String? customPath}) async {
    if (!consentGiven) {
      throw const ConsentRequiredException();
    }
    if (!permissionGranted) {
      throw const MicrophonePermissionDeniedException();
    }
    _state = const RecordingState(status: RecordingStatus.recording);
    return '/tmp/mock.m4a';
  }

  @override
  Future<void> pauseRecording() async {}

  @override
  Future<void> resumeRecording() async {}

  @override
  Future<String?> stopRecording() async => '/tmp/mock.m4a';

  @override
  Future<void> cancelRecording() async {}

  @override
  void dispose() {}
}

void main() {
  group('Membre 2 — Tests d\'intégration du parcours de Consultation', () {
    testWidgets('1. Écran de Consentement : Refus empêche l\'audio et oriente vers saisie manuelle',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SuraTheme.themeData,
          home: const ConsultationFlowScreen(),
        ),
      );

      // Vérification des éléments de consentement
      expect(find.text('Consentement du patient'), findsOneWidget);
      expect(find.text('L’audio reste strictement sur cet appareil'), findsOneWidget);
      expect(find.text('Refuser (Saisie manuelle)'), findsOneWidget);
      expect(find.text('Accepter'), findsOneWidget);

      // Clic sur Refuser
      await tester.tap(find.text('Refuser (Saisie manuelle)'));
      await tester.pumpAndSettle();

      // On bascule directement en saisie manuelle (TranscriptionScreen) sans créer d'audio
      expect(find.text('Texte de la consultation'), findsOneWidget);
      expect(find.text('Confirmer et continuer'), findsOneWidget);
    });

    testWidgets('2. Écran de Consentement : Accepter passe à l\'enregistrement audio (Écran 21)',
        (tester) async {
      final mockRecorder = MockAudioRecorderService();

      await tester.pumpWidget(
        MaterialApp(
          theme: SuraTheme.themeData,
          home: ConsultationFlowScreen(
            customRecorderService: mockRecorder,
          ),
        ),
      );

      // Clic sur Accepter
      await tester.tap(find.text('Accepter'));
      await tester.pumpAndSettle();

      // Vérification de l'écran d'enregistrement audio (C-02)
      expect(find.byType(AudioRecordingScreen), findsOneWidget);
      expect(find.text('Appuyez pour arrêter'), findsOneWidget);
      expect(find.text('L’audio est traité sur l’appareil. Rien n’est transmis.'), findsOneWidget);
    });

    testWidgets('3. Règle R3 : Blocage si tentative d\'enregistrement sans consentement',
        (tester) async {
      final mockRecorder = MockAudioRecorderService();

      await tester.pumpWidget(
        MaterialApp(
          theme: SuraTheme.themeData,
          home: AudioRecordingScreen(
            consentGiven: false, // Refusé ou non accordé
            recorderService: mockRecorder,
            onRecordingComplete: (_) {},
            onManualInputFallback: () {},
            onConsentMissing: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Vérification que l'alerte R3 s'affiche et bloque
      expect(find.text('Consentement obligatoire (R3)'), findsOneWidget);
      expect(find.text('Passer en saisie manuelle sans audio'), findsOneWidget);
      expect(find.text('Appuyez pour arrêter'), findsNothing);
    });

    testWidgets('4. État F7 : Refus de microphone propose la saisie manuelle',
        (tester) async {
      final mockRecorder = MockAudioRecorderService()..permissionGranted = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: SuraTheme.themeData,
          home: AudioRecordingScreen(
            consentGiven: true,
            recorderService: mockRecorder,
            onRecordingComplete: (_) {},
            onManualInputFallback: () {},
            onConsentMissing: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Vérification écran F7
      expect(find.text('Microphone non autorisé'), findsOneWidget);
      expect(find.text('Saisir sans enregistrement (Repli)'), findsOneWidget);
    });

    testWidgets('5. Règle R4 : Transcription modifiable par l\'agent',
        (tester) async {
      final service = LocalTranscriptionService(
        mockTextOverride: 'Patiente avec fièvre 39.4°C depuis 3 jours.',
      );

      String confirmedText = '';

      await tester.pumpWidget(
        MaterialApp(
          theme: SuraTheme.themeData,
          home: TranscriptionScreen(
            audioPath: '/tmp/test.m4a',
            transcriptionService: service,
            onConfirmTranscription: (txt) => confirmedText = txt,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérification du texte et de la modification
      expect(find.text('✎ Modifier le texte (R4)'), findsOneWidget);

      // L'agent appuie sur modifier
      await tester.tap(find.text('✎ Modifier le texte (R4)'));
      await tester.pumpAndSettle();

      expect(find.text('✓ Terminer l\'édition'), findsOneWidget);

      // Confirmation
      await tester.tap(find.text('Confirmer et continuer'));
      await tester.pumpAndSettle();

      expect(confirmedText, contains('fièvre 39.4°C'));
    });

    testWidgets('6. Règle R5 : Informations structurées modifiables',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SuraTheme.themeData,
          home: StructuredInfoScreen(
            rawTranscript: 'Patiente présentant une fièvre à 39,4 °C depuis 3 jours.',
            onValidated: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(StructuredInfoScreen), findsOneWidget);
      expect(find.text('Motif principal'), findsOneWidget);
      expect(find.text('Température (°C)'), findsOneWidget);
      expect(find.text('39.4 °C'), findsOneWidget);
      expect(find.text('3 jour(s)'), findsOneWidget);

      // Chaque champ a son bouton "✎ Modifier" ou "Remplir"
      expect(find.text('✎ Modifier'), findsWidgets);
    });
  });
}
