// Format SUR-XXXX-XXXX ; alphabet sans I, O, 0, 1 (voir id_generator.dart).
final _re = RegExp(r'^SUR-[A-HJ-NP-Z2-9]{4}-[A-HJ-NP-Z2-9]{4}$');

bool isValidPatientId(String s) => _re.hasMatch(s.trim().toUpperCase());

/// Renvoie l'identifiant normalisé si [raw] en est un, sinon null.
/// Sert au scan : le QR ne contient QUE l'identifiant (R2).
String? extractPatientId(String raw) {
  final t = raw.trim().toUpperCase();
  return _re.hasMatch(t) ? t : null;
}
