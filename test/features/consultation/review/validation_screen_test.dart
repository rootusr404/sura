import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/domain/fakes/in_memory_repositories.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/features/consultation/review/saved_screen.dart';
import 'package:sura/features/consultation/review/validation_checklist.dart';
import 'package:sura/features/consultation/review/validation_screen.dart';

void main() {
  late InMemoryConsultationRepository consultations;
  late String id;

  Future<void> pumpScreen(WidgetTester tester) async {
    consultations = InMemoryConsultationRepository();
    final draft = await consultations.createDraft(
      patientId: 'SUR-TEST-0001',
      agentId: 'agent-1',
    );
    id = draft.id;
    final router = GoRouter(
      initialLocation: '/consultation/$id/validate',
      routes: [
        GoRoute(
          path: '/consultation/:id/validate',
          builder: (_, s) =>
              ValidationScreen(consultationId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/consultation/:id/saved',
          builder: (_, s) =>
              SavedScreen(consultationId: s.pathParameters['id']!),
        ),
        GoRoute(path: '/home', builder: (_, _) => const Text('accueil')),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          consultationRepositoryProvider.overrideWithValue(consultations),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder validateButton() =>
      find.widgetWithText(FilledButton, 'Valider et sauvegarder');

  testWidgets('sans case cochée, la validation est désactivée', (tester) async {
    await pumpScreen(tester);
    expect(tester.widget<FilledButton>(validateButton()).onPressed, isNull);
    expect((await consultations.getById(id))!.status, ConsultationStatus.draft);
  });

  testWidgets('4 cases sur 5 : la validation reste désactivée', (tester) async {
    await pumpScreen(tester);
    final boxes = find.byType(CheckboxListTile);
    expect(boxes, findsNWidgets(ValidationChecklist.items.length));
    for (var i = 0; i < 4; i++) {
      await tester.ensureVisible(boxes.at(i));
      await tester.tap(boxes.at(i));
      await tester.pump();
    }
    expect(tester.widget<FilledButton>(validateButton()).onPressed, isNull);
  });

  testWidgets('5 cases : valide, sauvegarde en attente de synchronisation', (
    tester,
  ) async {
    await pumpScreen(tester);
    final boxes = find.byType(CheckboxListTile);
    for (var i = 0; i < ValidationChecklist.items.length; i++) {
      await tester.ensureVisible(boxes.at(i));
      await tester.tap(boxes.at(i));
      await tester.pump();
    }
    await tester.ensureVisible(validateButton());
    await tester.tap(validateButton());
    await tester.pumpAndSettle();

    final saved = (await consultations.getById(id))!;
    expect(saved.status, ConsultationStatus.saved);
    expect(saved.validatedAt, isNotNull);
    expect(saved.syncState, SyncState.pending);
    expect(ValidationChecklist.isComplete(saved.checklist), isTrue);
    expect(find.text('Consultation enregistrée sur ce téléphone'), findsOne);
    expect(find.text('En attente'), findsOne);
  });
}
