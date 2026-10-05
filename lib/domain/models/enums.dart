enum UrgencyLevel { high, moderate, low }

enum SyncState { offline, pending, syncing, synced, error }

enum ConsentStatus { granted, refused }

enum ConsultationStatus { draft, saved }

extension SyncStateX on SyncState {
  String get db => name;
  static SyncState fromDb(String? v) => SyncState.values.firstWhere(
    (e) => e.name == v,
    orElse: () => SyncState.pending,
  );
}
