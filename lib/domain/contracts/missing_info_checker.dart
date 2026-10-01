import '../models/missing_item.dart';
import '../models/patient_context.dart';
import '../models/structured_info.dart';

/// Propriétaire : Membre 3 (U-01). Fonction pure, déterministe (R6 : alertes, pas blocages).
abstract class MissingInfoChecker {
  List<MissingItem> check(StructuredInfo info, PatientContext patient);
}
