/// Validateurs de formulaire (Dart pur : testables sans Flutter).
String? requiredField(String? v) =>
    (v == null || v.trim().isEmpty) ? '⚠ Ce champ est requis.' : null;

String? emailValidator(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return '⚠ Ce champ est requis.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
    return '⚠ Adresse e-mail invalide.';
  }
  return null;
}

String? passwordValidator(String? v) =>
    (v ?? '').length < 8 ? '⚠ 8 caractères minimum.' : null;

String? confirmValidator(String? v, String original) =>
    (v ?? '') != original || original.isEmpty
        ? '⚠ Les mots de passe ne correspondent pas.'
        : null;

String? phoneValidator(String? v) {
  final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length < 6 ? '⚠ Numéro invalide.' : null;
}
