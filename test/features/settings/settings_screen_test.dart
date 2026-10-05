import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/domain/contracts/sync_service.dart';
import 'package:sura/domain/fakes/in_memory_repositories.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/features/auth/providers/auth_providers.dart';
import 'package:sura/features/settings/settings_providers.dart';
import 'package:sura/features/settings/settings_screen.dart';
import 'package:sura/features/sync/sync_providers.dart';

class TestSyncService implements SyncService {
  final retries = <String>[];
  bool fail = false;
  @override
  Stream<SyncState> watchOverall() => Stream.value(SyncState.offline);
  @override
  Future<void> syncPending() async {}
  @override
  Future<void> retry(String id) async {
    retries.add(id);
    if (fail) throw StateError('network');
  }
}

void main() {
  late InMemoryPatientRepository patients;
  late InMemoryConsultationRepository consultations;
  late TestSyncService sync;
  late PinSession pin;
  late int logoutCalls;
  late bool logoutFails;

  setUp(() {
    patients = InMemoryPatientRepository();
    consultations = InMemoryConsultationRepository();
    sync = TestSyncService();
    pin = PinSession()..unlock();
    logoutCalls = 0;
    logoutFails = false;
  });

  Future<PatientRecord> patient({String agent = 'a', String name = 'Awa'}) =>
      patients.create(
        lastName: 'Test',
        firstName: name,
        ageYears: 30,
        sex: 'F',
        village: 'Fictif',
        agentId: agent,
      );

  Future<ConsultationRecord> consultation(PatientRecord p) async {
    final c = await consultations.createDraft(patientId: p.id, agentId: 'a');
    await consultations.markValidated(c.id);
    return (await consultations.getById(c.id))!;
  }

  Future<void> show(
    WidgetTester tester, {
    Stream<List<PatientRecord>>? patientStream,
  }) async {
    tester.view.physicalSize = const Size(1100, 1900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
        GoRoute(
          path: '/unlock',
          builder: (_, _) => const Scaffold(body: Text('Écran PIN')),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Écran connexion')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patientRepositoryProvider.overrideWithValue(patients),
          consultationRepositoryProvider.overrideWithValue(consultations),
          settingsAgentIdProvider.overrideWith((ref) => Stream.value('a')),
          settingsLogoutProvider.overrideWithValue(() async {
            logoutCalls++;
            if (logoutFails) throw StateError('signout');
          }),
          pinSessionProvider.overrideWithValue(pin),
          syncServiceProvider.overrideWithValue(sync),
          overallSyncStateProvider.overrideWith((ref) => sync.watchOverall()),
          if (patientStream != null)
            settingsPatientsProvider.overrideWith((ref) => patientStream),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'liste réelle, filtrée par agent, actualisée après synchronisation',
    (tester) async {
      final p = await patient();
      await patients.updateSyncState(
        p.id,
        SyncState.error,
        expectedUpdatedAt: p.updatedAt,
        attempts: 2,
        error: 'Envoi interrompu',
      );
      final c = await consultation(p);
      await consultations.updateSyncState(
        c.id,
        SyncState.syncing,
        expectedUpdatedAt: c.updatedAt,
      );
      final draft = await consultations.createDraft(
        patientId: p.id,
        agentId: 'a',
      );
      final other = await patient(agent: 'b', name: 'Autre agent');
      final done = await patient(name: 'Déjà envoyé');
      await patients.updateSyncState(
        done.id,
        SyncState.synced,
        expectedUpdatedAt: done.updatedAt,
      );
      await show(tester);
      expect(find.text('Hors ligne'), findsOneWidget);
      expect(find.text('3 élément(s) non synchronisé(s)'), findsOneWidget);
      expect(find.byKey(ValueKey('sync-item-${p.id}')), findsOneWidget);
      expect(find.text('Tentatives : 2'), findsOneWidget);
      expect(find.text('Envoi interrompu'), findsOneWidget);
      expect(find.byKey(ValueKey('sync-item-${other.id}')), findsNothing);
      expect(find.byKey(ValueKey('sync-item-${done.id}')), findsNothing);
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(ValueKey('retry-${c.id}')))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(ValueKey('retry-${draft.id}')))
            .onPressed,
        isNull,
      );
      expect(
        find.text('Brouillon : à valider avant synchronisation.'),
        findsOneWidget,
      );
      await patients.updateSyncState(
        p.id,
        SyncState.synced,
        expectedUpdatedAt: p.updatedAt,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('sync-item-${p.id}')), findsNothing);
      expect(find.text('2 élément(s) non synchronisé(s)'), findsOneWidget);
    },
  );

  testWidgets(
    'Réessayer appelle le service avec les IDs patient et consultation',
    (tester) async {
      final p = await patient();
      final c = await consultation(p);
      await show(tester);
      await tester.tap(find.byKey(ValueKey('retry-${p.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('retry-${c.id}')));
      await tester.pumpAndSettle();
      expect(sync.retries, [p.id, c.id]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('échec du réessai affiché sans supprimer le patient', (
    tester,
  ) async {
    final p = await patient();
    sync.fail = true;
    await show(tester);
    await tester.tap(find.byKey(ValueKey('retry-${p.id}')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Impossible de relancer la synchronisation. Réessaie plus tard.',
      ),
      findsOneWidget,
    );
    expect(await patients.getById(p.id), isNotNull);
  });

  testWidgets(
    'déconnexion : annuler conserve la session, confirmer conserve les données',
    (tester) async {
      final p = await patient();
      final c = await consultation(p);
      final draft = await consultations.createDraft(
        patientId: p.id,
        agentId: 'a',
      );
      await show(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('settings-logout')));
      await tester.tap(find.byKey(const ValueKey('settings-logout')));
      await tester.pumpAndSettle();
      expect(find.text('Des données restent à synchroniser'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(logoutCalls, 0);
      expect(pin.isUnlocked, isTrue);
      await tester.tap(find.byKey(const ValueKey('settings-logout')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Se déconnecter'));
      await tester.pumpAndSettle();
      expect(logoutCalls, 1);
      expect(pin.isUnlocked, isFalse);
      expect(find.text('Écran connexion'), findsOneWidget);
      expect(await patients.getById(p.id), isNotNull);
      expect(await consultations.getById(c.id), isNotNull);
      expect(await consultations.getById(draft.id), isNotNull);
    },
  );

  testWidgets('aucun élément non synchronisé : déconnexion sans confirmation', (
    tester,
  ) async {
    await patient(agent: 'b'); // Le compte B ne doit pas bloquer A.
    final p = await patient();
    await patients.updateSyncState(
      p.id,
      SyncState.synced,
      expectedUpdatedAt: p.updatedAt,
    );
    await show(tester);
    await tester.tap(find.byKey(const ValueKey('settings-logout')));
    await tester.pumpAndSettle();
    expect(logoutCalls, 1);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Écran connexion'), findsOneWidget);
    expect(await patients.getById(p.id), isNotNull);
  });

  testWidgets('Verrouiller maintenant ouvre unlock sans appeler logout', (
    tester,
  ) async {
    final p = await patient();
    await show(tester);
    await tester.tap(find.text('Verrouiller maintenant'));
    await tester.pumpAndSettle();
    expect(pin.isUnlocked, isFalse);
    expect(logoutCalls, 0);
    expect(find.text('Écran PIN'), findsOneWidget);
    expect(await patients.getById(p.id), isNotNull);
  });

  testWidgets('données locales indisponibles : déconnexion désactivée', (
    tester,
  ) async {
    await show(tester, patientStream: Stream.error(StateError('database')));
    expect(
      find.textContaining('Impossible de lire les éléments'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('settings-logout')))
          .onPressed,
      isNull,
    );
    expect(logoutCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('échec de déconnexion conserve la session PIN', (tester) async {
    logoutFails = true;
    await show(tester);
    await tester.tap(find.byKey(const ValueKey('settings-logout')));
    await tester.pumpAndSettle();
    expect(logoutCalls, 1);
    expect(pin.isUnlocked, isTrue);
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.textContaining('Déconnexion impossible'), findsOneWidget);
  });
}
