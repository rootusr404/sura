const _accents = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'á': 'a',
  'ã': 'a',
  'å': 'a',
  'ç': 'c',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ñ': 'n',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ý': 'y',
  'ÿ': 'y',
};

/// Minuscules + sans accents, pour des recherches tolérantes (« Éléonore » = « eleonore »).
String normalizeText(String input) {
  final b = StringBuffer();
  for (final ch in input.trim().toLowerCase().split('')) {
    b.write(_accents[ch] ?? ch);
  }
  return b.toString();
}

String _two(int n) => n.toString().padLeft(2, '0');

/// 01/10/2026 14:05
String formatDateTime(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

/// Minuscules + sans accents, SANS trim, en conservant la longueur exacte de la
/// chaîne : un indice trouvé dans le texte « plié » est valable dans l'original.
String foldAccents(String input) {
  final b = StringBuffer();
  for (final ch in input.toLowerCase().split('')) {
    b.write(ch == '’' ? "'" : (_accents[ch] ?? ch));
  }
  return b.toString();
}
