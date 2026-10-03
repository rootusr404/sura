import 'package:flutter_test/flutter_test.dart';
import 'package:sura/core/utils/id_generator.dart';
import 'package:sura/core/utils/patient_id.dart';

void main() {
  test('les identifiants générés sont toujours valides', () {
    for (var i = 0; i < 300; i++) {
      expect(isValidPatientId(generatePatientId()), isTrue);
    }
  });

  test('extractPatientId normalise et rejette', () {
    expect(extractPatientId('  sur-ab2c-d3ef '), 'SUR-AB2C-D3EF');
    expect(extractPatientId('SUR-AB2C'), isNull);
    expect(extractPatientId('SUR-0000-OOOO'), isNull); // 0 et O exclus
    expect(extractPatientId('https://exemple.org'), isNull);
    expect(extractPatientId(''), isNull);
  });
}
