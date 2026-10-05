import 'package:flutter_test/flutter_test.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/missing_item.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/domain/models/urgency_proposal.dart';

void main() {
  test('StructuredInfo : aller-retour JSON', () {
    const info = StructuredInfo(
      chiefComplaint: 'Fièvre',
      symptoms: ['fièvre', 'toux'],
      duration: '3 jours',
      temperatureC: 38.5,
      pulse: 90,
      allergies: 'Aucune',
    );
    final back = StructuredInfo.fromJson(info.toJson());
    expect(back.chiefComplaint, 'Fièvre');
    expect(back.symptoms, ['fièvre', 'toux']);
    expect(back.temperatureC, 38.5);
    expect(back.pulse, 90);
    expect(back.allergies, 'Aucune');
  });

  test('StructuredInfo.fromJson tolère un JSON vide', () {
    final info = StructuredInfo.fromJson({});
    expect(info.symptoms, isEmpty);
    expect(info.chiefComplaint, isNull);
  });

  test('UrgencyProposal : aller-retour JSON', () {
    const p = UrgencyProposal(
      level: UrgencyLevel.high,
      reasons: ['Convulsions'],
    );
    final back = UrgencyProposal.fromJson(p.toJson());
    expect(back.level, UrgencyLevel.high);
    expect(back.reasons, ['Convulsions']);
  });

  test('MissingItem : aller-retour JSON', () {
    const m = MissingItem(
      code: 'allergies',
      label: 'Allergies ?',
      hint: 'Demander',
    );
    final back = MissingItem.fromJson(m.toJson());
    expect(back.code, 'allergies');
    expect(back.hint, 'Demander');
  });

  test('SyncStateX.fromDb retombe sur pending si inconnu', () {
    expect(SyncStateX.fromDb('synced'), SyncState.synced);
    expect(SyncStateX.fromDb('???'), SyncState.pending);
    expect(SyncStateX.fromDb(null), SyncState.pending);
  });
}
