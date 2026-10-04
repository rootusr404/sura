import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  PinService({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _saltKey = 'sura.pin.salt';
  static const _hashKey = 'sura.pin.hash';
  static const _failedKey = 'sura.pin.failed';
  static const _lockUntilKey = 'sura.pin.lockUntil';
  static const _lockLevelKey = 'sura.pin.lockLevel';
  static const _maxAttempts = 5;

  static const _lockDurations = [
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 10),
    Duration(minutes: 30),
  ];

  static final _pbkdf2 = Pbkdf2.hmacSha256(iterations: 100000, bits: 256);

  Future<bool> get hasPin async =>
      await _storage.read(key: _saltKey) != null && await _storage.read(key: _hashKey) != null;

  Future<int> get failedAttempts async =>
      int.tryParse(await _storage.read(key: _failedKey) ?? '') ?? 0;

  Future<Duration?> get lockRemaining async {
    final value = await _storage.read(key: _lockUntilKey);
    if (value == null) return null;

    final until = DateTime.tryParse(value);
    if (until == null || !until.isAfter(DateTime.now())) {
      await _storage.delete(key: _lockUntilKey);
      return null;
    }

    return until.difference(DateTime.now());
  }

  Future<void> setPin(String pin) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw ArgumentError('Le PIN doit contenir exactement 6 chiffres.');
    }

    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = await _deriveHash(pin, salt);

    await _storage.write(key: _saltKey, value: base64UrlEncode(salt));
    await _storage.write(key: _hashKey, value: base64UrlEncode(hash));
    await _storage.write(key: _failedKey, value: '0');
    await _storage.write(key: _lockLevelKey, value: '0');
    await _storage.delete(key: _lockUntilKey);
  }

  Future<bool> verifyPin(String pin) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) return false;
    if (await lockRemaining != null) return false;

    final storedSalt = await _storage.read(key: _saltKey);
    final storedHash = await _storage.read(key: _hashKey);
    if (storedSalt == null || storedHash == null) return false;

    final salt = base64Url.decode(storedSalt);
    final expected = base64Url.decode(storedHash);
    final actual = await _deriveHash(pin, salt);

    var difference = expected.length ^ actual.length;
    for (var i = 0; i < min(expected.length, actual.length); i++) {
      difference |= expected[i] ^ actual[i];
    }

    if (difference == 0) {
      await _storage.write(key: _failedKey, value: '0');
      await _storage.write(key: _lockLevelKey, value: '0');
      await _storage.delete(key: _lockUntilKey);
      return true;
    }

    final attempts = (await failedAttempts) + 1;
    if (attempts < _maxAttempts) {
      await _storage.write(key: _failedKey, value: '$attempts');
      return false;
    }

    final level = int.tryParse(await _storage.read(key: _lockLevelKey) ?? '') ?? 0;
    final index = level.clamp(0, _lockDurations.length - 1);
    final duration = _lockDurations[index];

    await _storage.write(key: _failedKey, value: '0');
    await _storage.write(key: _lockLevelKey, value: '${level + 1}');
    await _storage.write(key: _lockUntilKey, value: DateTime.now().add(duration).toIso8601String());

    return false;
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _saltKey);
    await _storage.delete(key: _hashKey);
    await _storage.delete(key: _failedKey);
    await _storage.delete(key: _lockUntilKey);
    await _storage.delete(key: _lockLevelKey);
  }

  Future<List<int>> _deriveHash(String pin, List<int> salt) async {
    final key = await _pbkdf2.deriveKeyFromPassword(password: pin, nonce: salt);
    return key.extractBytes();
  }
}
