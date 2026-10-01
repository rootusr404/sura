import '../models/structured_info.dart';

/// Propriétaire : Membre 2 (C-04). Fonction pure : règles / RegExp, explicable.
/// Ne doit jamais lever d'exception, même sur un texte vide ou incohérent.
abstract class InformationExtractor {
  StructuredInfo extract(String transcript);
}
