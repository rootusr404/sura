import 'package:flutter_test/flutter_test.dart';
import 'package:sura_app/features/consultation/cloud_errors.dart';

void main() {
  test('401 : cle invalide',
      () => expect(cloudErrorMessage(401, ''), contains('Clé API')));
  test('402 : credits insuffisants',
      () => expect(cloudErrorMessage(402, '{}'), contains('Crédits RODI')));
  test('404 : modele introuvable avec detail', () {
    final m =
        cloudErrorMessage(404, '{"error":{"message":"Model x not found."}}');
    expect(m, contains('Modèle'));
    expect(m, contains('Model x not found.'));
  });
  test('429 : trop de requetes',
      () => expect(cloudErrorMessage(429, ''), contains('Trop de requêtes')));
  test('500 : indisponible avec le code',
      () => expect(cloudErrorMessage(500, 'oops'), contains('500')));
}
