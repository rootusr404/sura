import 'package:flutter_test/flutter_test.dart';
import 'package:sura/core/utils/text_utils.dart';

void main() {
  test('normalizeText retire accents et casse', () {
    expect(normalizeText('  Éléonore  '), 'eleonore');
    expect(normalizeText('Ouagadougou'), 'ouagadougou');
    expect(normalizeText('Côte d\'Ivoire'), 'cote d\'ivoire');
  });

  test('formatDateTime : jj/mm/aaaa hh:mm', () {
    expect(formatDateTime(DateTime(2026, 10, 1, 9, 5)), '01/10/2026 09:05');
  });
}
