import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/domain/contracts/missing_info_checker.dart';
import 'package:sura/domain/contracts/urgency_scorer.dart';
import 'package:sura/domain/fakes/fake_services.dart';

// PROPRIÉTAIRE : Membre 3 (U-01, U-02). Remplacer les fakes un par un.
final missingInfoCheckerProvider = Provider<MissingInfoChecker>(
  (ref) => FakeMissingInfoChecker(),
);

final urgencyScorerProvider = Provider<UrgencyScorer>(
  (ref) => FakeUrgencyScorer(),
);
