import '../models/patient_context.dart';
import '../models/structured_info.dart';
import '../models/urgency_proposal.dart';

/// Propriétaire : Membre 3 (U-02). Règles explicables : chaque niveau
/// s'accompagne de raisons. L'IA propose, l'agent décide (R7, R8).
abstract class UrgencyScorer {
  UrgencyProposal score(
    StructuredInfo info,
    String transcript,
    PatientContext patient,
  );
}
