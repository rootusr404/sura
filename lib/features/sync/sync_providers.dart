import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/domain/contracts/sync_service.dart';
import 'package:sura/domain/fakes/fake_services.dart';
import 'package:sura/domain/models/enums.dart';

// PROPRIÉTAIRE : Membre 4 (S-04). Remplacer par la vraie synchronisation.
final syncServiceProvider = Provider<SyncService>((ref) => FakeSyncService());

final overallSyncStateProvider = StreamProvider<SyncState>(
  (ref) => ref.watch(syncServiceProvider).watchOverall(),
);
