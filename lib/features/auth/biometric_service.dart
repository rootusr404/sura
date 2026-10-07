import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Biometrie : sert UNIQUEMENT a deverrouiller l'interface (comme le PIN). Le PIN reste toujours disponible.
class BiometricService {
  final _auth = LocalAuthentication();
  final _s = const FlutterSecureStorage();

  Future<bool> available() async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> enabled() async =>
      (await _s.read(key: 'biometric_enabled')) == '1';

  Future<void> setEnabled(bool v) =>
      _s.write(key: 'biometric_enabled', value: v ? '1' : '0');

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(localizedReason: 'Déverrouillez SŪRA');
    } catch (_) {
      return false;
    }
  }
}

final biometricProvider =
    Provider<BiometricService>((ref) => BiometricService());
