/// Parcours de consultation. PROPRIÉTAIRE : Membre 1.
/// Les écrans naviguent avec : context.go(step.next!.path(consultationId)).
enum ConsultationStep {
  consent,
  record,
  transcript,
  structured,
  missing,
  urgency,
  recap,
  validate,
  saved;

  String path(String consultationId) => '/consultation/$consultationId/$name';

  ConsultationStep? get next =>
      index + 1 < values.length ? values[index + 1] : null;

  ConsultationStep? get previous => index > 0 ? values[index - 1] : null;
}
