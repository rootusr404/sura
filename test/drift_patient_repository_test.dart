import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sura/core/db/app_database.dart';
import 'package:sura/core/db/drift_patient_repository.dart';
import 'package:sura/core/utils/patient_id.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';

void main() {
  late AppDatabase db;
  late DriftPatientRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftPatientRepository(db);
  });
  tearDown(() => db.close());

  Future<PatientRecord> make(
    String last, {
    String first = 'Fatou',
    String village = 'Village A',
  }) => repo.create(
    lastName: last,
    firstName: first,
    ageYears: 30,
    sex: 'F',
    village: village,
    agentId: 'agent-1',
  );

  test(
    'création : identifiant valide, en attente de synchro, données nettoyées',
    () async {
      final p = await make('  Traoré ');
      expect(isValidPatientId(p.id), isTrue);
      expect(p.syncState, SyncState.pending);
      expect(p.lastName, 'Traoré');
      expect(p.phone, isNull);
      expect(p.fullName, 'Fatou Traoré');
      expect((await repo.getById(p.id))?.firstName, 'Fatou');
    },
  );

  test('téléphone vide = absent ; renseigné = conservé', () async {
    final a = await repo.create(
      lastName: 'A',
      firstName: 'B',
      ageYears: 1,
      sex: 'M',
      village: 'V',
      phone: '   ',
      agentId: 'x',
    );
    final b = await repo.create(
      lastName: 'A',
      firstName: 'B',
      ageYears: 1,
      sex: 'M',
      village: 'V',
      phone: '70 12 34 56',
      agentId: 'x',
    );
    expect(a.phone, isNull);
    expect(b.phone, '70 12 34 56');
  });

  test('50 identifiants uniques', () async {
    final ids = <String>{};
    for (var i = 0; i < 50; i++) {
      ids.add((await make('N$i')).id);
    }
    expect(ids.length, 50);
  });

  test('watchAll : le plus récent d\'abord, même à la même seconde', () async {
    await make('Premier');
    await make('Second');
    final list = await repo.watchAll().first;
    expect(list.map((p) => p.lastName), ['Second', 'Premier']);
  });

  test('recherche sans accents ni casse : nom, village, identifiant', () async {
    final eleonore = await make(
      'Ouédraogo',
      first: 'Éléonore',
      village: 'Koudougou',
    );
    await make('Sawadogo', first: 'Issa', village: 'Ouagadougou');
    expect((await repo.search('eleonore')).single.id, eleonore.id);
    expect((await repo.search('OUEDRAOGO')).single.id, eleonore.id);
    expect((await repo.search('koudougou')).single.id, eleonore.id);
    expect(
      (await repo.search(eleonore.id.toLowerCase())).single.id,
      eleonore.id,
    );
    expect((await repo.search('')).length, 2);
    expect(await repo.search('zzz'), isEmpty);
  });

  test(
    'watchById émet la fiche puis ses mises à jour ; inconnu = null',
    () async {
      final p = await make('Test');
      expect((await repo.watchById(p.id).first)?.lastName, 'Test');
      expect(await repo.getById('SUR-AAAA-BBBB'), isNull);
    },
  );
}
