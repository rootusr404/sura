import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/features/auth/screens/forgot_password_screen.dart';
import 'package:sura/features/auth/screens/login_screen.dart';
import 'package:sura/features/auth/screens/pin_setup_screen.dart';
import 'package:sura/features/auth/screens/register_screen.dart';
import 'package:sura/features/auth/screens/unlock_screen.dart';
import 'package:sura/features/consultation/capture/recording_screen.dart';
import 'package:sura/features/consultation/capture/structured_screen.dart';
import 'package:sura/features/consultation/capture/transcript_screen.dart';
import 'package:sura/features/consultation/consent/consent_screen.dart';
import 'package:sura/features/consultation/review/missing_screen.dart';
import 'package:sura/features/consultation/review/recap_screen.dart';
import 'package:sura/features/consultation/review/saved_screen.dart';
import 'package:sura/features/consultation/review/urgency_screen.dart';
import 'package:sura/features/consultation/review/validation_screen.dart';
import 'package:sura/features/home/home_screen.dart';
import 'package:sura/features/patient/patient_create_screen.dart';
import 'package:sura/features/patient/patient_detail_screen.dart';
import 'package:sura/features/patient/patients_screen.dart';
import 'package:sura/features/patient/qr_scan_screen.dart';
import 'package:sura/features/settings/settings_screen.dart';

// PROPRIÉTAIRE : Membre 1. Toutes les routes sont déjà déclarées : pour
// construire un écran, remplacez le CONTENU de son fichier, pas ce routeur.
// Exceptions : Membre 4 peut ajouter la logique `redirect` (garde d'authentification),
// Membre 1 la coque de navigation (F-03).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/patients',
        builder: (_, _) => const PatientsScreen(),
        routes: [
          // 'new' et 'scan' AVANT ':pid'.
          GoRoute(path: 'new', builder: (_, _) => const PatientCreateScreen()),
          GoRoute(path: 'scan', builder: (_, _) => const QrScanScreen()),
          GoRoute(
            path: ':pid',
            builder: (_, s) =>
                PatientDetailScreen(patientId: s.pathParameters['pid']!),
          ),
        ],
      ),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/forgot', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/pin-setup', builder: (_, _) => const PinSetupScreen()),
      GoRoute(path: '/unlock', builder: (_, _) => const UnlockScreen()),
      GoRoute(
        path: '/consultation/:id/consent',
        builder: (_, s) =>
            ConsentScreen(consultationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/record',
        builder: (_, s) =>
            RecordingScreen(consultationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/transcript',
        builder: (_, s) =>
            TranscriptScreen(consultationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/structured',
        builder: (_, s) =>
            StructuredScreen(consultationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/missing',
        builder: (_, s) =>
            MissingScreen(consultationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/urgency',
        builder: (_, s) =>
            UrgencyScreen(consultationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/recap',
        builder: (_, s) => RecapScreen(consultationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/validate',
        builder: (_, s) =>
            ValidationScreen(consultationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/saved',
        builder: (_, s) => SavedScreen(consultationId: s.pathParameters['id']!),
      ),
    ],
  );
});
