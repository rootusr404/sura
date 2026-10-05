import 'package:flutter_test/flutter_test.dart';
import 'package:sura/features/consultation/review/validation_checklist.dart';

Map<String, bool> _all(bool value) => {
  for (final item in ValidationChecklist.items) item.code: value,
};

void main() {
  test('la validation comporte exactement 5 cases (R8)', () {
    expect(ValidationChecklist.items, hasLength(5));
  });

  test('les codes des cases sont uniques', () {
    final codes = ValidationChecklist.items.map((e) => e.code).toList();
    expect(codes.toSet(), hasLength(codes.length));
  });

  test('rien de coché : la validation est impossible', () {
    expect(ValidationChecklist.isComplete(const {}), isFalse);
    expect(ValidationChecklist.isComplete(_all(false)), isFalse);
  });

  test('4 cases sur 5 : la validation reste impossible', () {
    final partial = _all(true)..[ValidationChecklist.items.last.code] = false;
    expect(ValidationChecklist.isComplete(partial), isFalse);
  });

  test('une case absente compte comme non cochée', () {
    final partial = _all(true)..remove(ValidationChecklist.items.first.code);
    expect(ValidationChecklist.isComplete(partial), isFalse);
  });

  test('5 cases cochées : la validation est possible', () {
    expect(ValidationChecklist.isComplete(_all(true)), isTrue);
  });

  test('des clés inconnues ne remplacent pas une vraie case', () {
    final fake = <String, bool>{
      'a': true,
      'b': true,
      'c': true,
      'd': true,
      'e': true,
    };
    expect(ValidationChecklist.isComplete(fake), isFalse);
  });

  test('remaining liste les cases restantes dans l\'ordre', () {
    final partial = _all(true)
      ..[ValidationChecklist.items[1].code] = false
      ..[ValidationChecklist.items[3].code] = false;
    expect(ValidationChecklist.remaining(partial), [
      ValidationChecklist.items[1],
      ValidationChecklist.items[3],
    ]);
  });
}
