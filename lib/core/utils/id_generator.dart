import 'dart:math';

/// Alphabet sans caractères ambigus (0/O, 1/I).
const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
final _rng = Random.secure();

String _chunk(int n) =>
    List.generate(n, (_) => _alphabet[_rng.nextInt(_alphabet.length)]).join();

/// Identifiant patient : SUR-XXXX-XXXX
String generatePatientId() => 'SUR-${_chunk(4)}-${_chunk(4)}';

/// Code agent : AGT-XXXX
String generateAgentCode() => 'AGT-${_chunk(4)}';

/// Identifiant technique (consultations, comptes locaux).
String generateUid() {
  final b = List.generate(16, (_) => _rng.nextInt(256));
  return b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
}
