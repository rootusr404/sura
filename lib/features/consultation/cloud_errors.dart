import 'dart:convert';

/// Messages d'erreur clairs (en francais) pour la transcription distante.
String cloudErrorMessage(int status, String body) {
  var detail = '';
  try {
    final j = jsonDecode(body);
    if (j is Map && j['error'] is Map) {
      detail = '${(j['error'] as Map)['message'] ?? ''}';
    }
  } catch (_) {}
  final suffix = detail.isEmpty ? '' : ' ($detail)';
  switch (status) {
    case 401:
      return 'Clé API invalide ou absente.';
    case 402:
      return 'Crédits RODI insuffisants.';
    case 404:
      return 'Modèle de transcription introuvable$suffix.';
    case 429:
      return 'Trop de requêtes : réessayez dans un instant.';
    default:
      return 'Service de transcription indisponible (code $status)$suffix.';
  }
}
