import 'package:flutter_test/flutter_test.dart';
import 'package:sura_app/features/auth/validators.dart';
import 'package:sura_app/features/profile/profile_model.dart';

void main() {
  group('AgentProfile', () {
    test('profil vide : 0 %', () {
      expect(const AgentProfile().completion, 0);
      expect(const AgentProfile().isComplete, isFalse);
    });
    test('profil complet : 100 %', () {
      const p = AgentProfile(
          fullName: 'A B',
          phone: '123456',
          region: 'R',
          healthPost: 'P',
          role: 'Médecin');
      expect(p.completion, 1.0);
      expect(p.isComplete, isTrue);
    });
    test('profil partiel : 2 champs sur 5', () {
      expect(const AgentProfile(fullName: 'A B', role: 'Autre').completion,
          closeTo(0.4, 0.001));
    });
    test('aller-retour map', () {
      const p = AgentProfile(
          fullName: 'A B',
          phone: '1',
          region: 'R',
          healthPost: 'P',
          role: 'Autre',
          email: 'a@b.co',
          consentAt: '2026-10-05T10:00:00.000');
      final r = AgentProfile.fromMap(p.toMap());
      expect(r.fullName, 'A B');
      expect(r.email, 'a@b.co');
      expect(r.consentAt, '2026-10-05T10:00:00.000');
    });
    test('identifiant agent derive du compte', () {
      expect(agentCode('abcdef123456'), 'AGT-ABCDEF');
      expect(agentCode('demo-agent'), 'AGT-DEMOAG');
      expect(agentCode('ab'), 'AGT-AB');
    });
  });

  group('Validateurs', () {
    test('e-mail', () {
      expect(emailValidator('a@b.co'), isNull);
      expect(emailValidator('abc'), isNotNull);
      expect(emailValidator(''), isNotNull);
    });
    test('mot de passe : 8 caracteres minimum', () {
      expect(passwordValidator('1234567'), isNotNull);
      expect(passwordValidator('12345678'), isNull);
    });
    test('confirmation du mot de passe', () {
      expect(confirmValidator('x', 'y'), isNotNull);
      expect(confirmValidator('motdepasse', 'motdepasse'), isNull);
      expect(confirmValidator('', ''), isNotNull);
    });
    test('telephone', () {
      expect(phoneValidator('12'), isNotNull);
      expect(phoneValidator('+226 70 12 34 56'), isNull);
    });
  });
}
