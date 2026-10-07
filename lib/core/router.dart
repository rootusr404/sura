import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screens.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/profile/profile_screens.dart';
import '../features/auth/auth_service.dart';
import '../features/consultation/consultation_screens.dart';
import '../features/home/home_screen.dart';
import '../features/patients/patients_screens.dart';
import '../features/patients/qr_widgets.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/settings_screens.dart';
import '../features/sync/sync_screen.dart';
import 'shell.dart';

GoRoute _step(String name, Widget Function(String id) b) => GoRoute(
      path: '/consult/:id/$name',
      builder: (c, s) => b(s.pathParameters['id']!),
    );

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final s = ref.read(sessionProvider);
      final loc = state.uri.path;
      if (!s.ready) return loc == '/splash' ? null : '/splash';
      if (!s.loggedIn) {
        return (loc == '/login' || loc == '/register' || loc == '/forgot')
            ? null
            : '/login';
      }
      if (!s.unlocked) return loc == '/pin' ? null : '/pin';
      if (loc == '/splash' || loc == '/login' || loc == '/pin') return '/home';
      return null;
    },
    routes: [
      GoRoute(
          path: '/splash',
          builder: (c, s) =>
              const Scaffold(body: Center(child: CircularProgressIndicator()))),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(
          path: '/forgot',
          builder: (c, s) =>
              ForgotPasswordScreen(initialEmail: s.extra as String?)),
      GoRoute(path: '/pin', builder: (c, s) => const PinScreen()),
      // 4 onglets racines : barre de navigation visible
      ShellRoute(
        builder: (c, s, child) => AppShell(location: s.uri.path, child: child),
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/patients', builder: (c, s) => const PatientsScreen()),
          GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        ],
      ),
      // Hors shell : pas de barre de navigation
      GoRoute(
          path: '/patients/new',
          builder: (c, s) => const CreatePatientScreen()),
      GoRoute(
          path: '/patients/:id',
          builder: (c, s) => PatientDetailScreen(id: s.pathParameters['id']!)),
      GoRoute(
          path: '/consultations/:id',
          builder: (c, s) =>
              ConsultationDetailScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/sync', builder: (c, s) => const SyncScreen()),
      GoRoute(
          path: '/settings/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(
          path: '/settings/profile/edit',
          builder: (c, s) => const EditProfileScreen()),
      GoRoute(
          path: '/settings/security',
          builder: (c, s) => const SecurityScreen()),
      GoRoute(
          path: '/settings/pin', builder: (c, s) => const ChangePinScreen()),
      GoRoute(
          path: '/settings/storage', builder: (c, s) => const StorageScreen()),
      GoRoute(path: '/settings/about', builder: (c, s) => const AboutScreen()),
      GoRoute(path: '/scan', builder: (c, s) => const ScanScreen()),
      GoRoute(
          path: '/consult/select',
          builder: (c, s) => const IdentifyPatientScreen()),
      _step('consent', (id) => ConsentScreen(id: id)),
      _step('refused', (id) => RefusedScreen(id: id)),
      _step('record', (id) => RecordScreen(id: id)),
      _step('transcript', (id) => TranscriptScreen(id: id)),
      _step('structured', (id) => StructuredScreen(id: id)),
      _step('missing', (id) => MissingScreen(id: id)),
      _step('urgency', (id) => UrgencyScreen(id: id)),
      _step('recap', (id) => RecapScreen(id: id)),
      _step('validate', (id) => ValidateScreen(id: id)),
      _step('saved', (id) => SavedScreen(id: id)),
    ],
  );
});
