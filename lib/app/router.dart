import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
import 'package:sura/features/consultation/flow/consultation_start_screen.dart';
import 'package:sura/features/consultation/review/missing_screen.dart';
import 'package:sura/features/consultation/review/recap_screen.dart';
import 'package:sura/features/consultation/review/saved_screen.dart';
import 'package:sura/features/consultation/review/urgency_screen.dart';
import 'package:sura/features/consultation/review/validation_screen.dart';
import 'package:sura/features/consultation/view/consultation_detail_screen.dart';
import 'package:sura/features/home/home_screen.dart';
import 'package:sura/features/home/shell_scaffold.dart';
import 'package:sura/features/patient/patient_create_screen.dart';
import 'package:sura/features/patient/patient_detail_screen.dart';
import 'package:sura/features/patient/patients_screen.dart';
import 'package:sura/features/patient/qr_scan_screen.dart';
import 'package:sura/features/settings/settings_screen.dart';
import 'package:sura/features/auth/providers/auth_providers.dart';

// PROPRIÉTAIRE : Membre 1. Toutes les routes sont déjà déclarées : pour
// construire un écran, remplacez le CONTENU de son fichier, pas ce routeur.
// Exceptions : Membre 4 peut ajouter la logique `redirect` (garde d'authentification),
// Membre 1 la coque de navigation (F-03).
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(FirebaseAuth auth) {
    _subscription = auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = FirebaseAuth.instance;
  final authRefresh = _AuthRefreshNotifier(auth);
  ref.onDispose(authRefresh.dispose);
  final pinService = ref.read(pinServiceProvider);
  final pinSession = ref.read(pinSessionProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: Listenable.merge([authRefresh, pinSession]),
    redirect: (context, state) async {
      final path = state.matchedLocation;
      final isPublic =
          path == '/login' || path == '/register' || path == '/forgot';
      final isSignedIn = auth.currentUser != null;

      if (!isSignedIn) {
        return isPublic ? null : '/login';
      }

      final hasPin = await pinService.hasPin;

      if (!hasPin && path != '/pin-setup') return '/pin-setup';

      if (hasPin && !pinSession.isUnlocked && path != '/unlock') {
        return '/unlock';
      }

      if (pinSession.isUnlocked &&
          (path == '/login' ||
              path == '/register' ||
              path == '/forgot' ||
              path == '/pin-setup' ||
              path == '/unlock')) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Coque de navigation : Accueil | Patients | [Consulter] | Paramètres.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patients',
                builder: (_, _) => const PatientsScreen(),
                routes: [
                  // 'new' et 'scan' AVANT ':pid'.
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const PatientCreateScreen(),
                  ),
                  GoRoute(
                    path: 'scan',
                    builder: (_, _) => const QrScanScreen(),
                  ),
                  GoRoute(
                    path: ':pid',
                    builder: (_, s) => PatientDetailScreen(
                      patientId: s.pathParameters['pid']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, _) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/forgot', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/pin-setup', builder: (_, _) => const PinSetupScreen()),
      GoRoute(path: '/unlock', builder: (_, _) => const UnlockScreen()),

      // Parcours de consultation : plein écran (pas de barre du bas).
      GoRoute(
        path: '/consultation/new',
        builder: (_, s) => ConsultationStartScreen(
          patientId: s.uri.queryParameters['patientId'],
        ),
      ),
      GoRoute(
        path: '/consultation/:id/consent',
        builder: (_, state) =>
            ConsentScreen(consultationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/record',
        builder: (_, state) =>
            RecordingScreen(consultationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/transcript',
        builder: (_, state) =>
            TranscriptScreen(consultationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/structured',
        builder: (_, state) =>
            StructuredScreen(consultationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/missing',
        builder: (_, state) =>
            MissingScreen(consultationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/urgency',
        builder: (_, state) =>
            UrgencyScreen(consultationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/recap',
        builder: (_, state) =>
            RecapScreen(consultationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/validate',
        builder: (_, state) =>
            ValidationScreen(consultationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/saved',
        builder: (_, state) =>
            SavedScreen(consultationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/:id/view',
        builder: (_, s) =>
            ConsultationDetailScreen(consultationId: s.pathParameters['id']!),
      ),
    ],
  );
});
