import 'dart:async';

import 'package:sura/domain/contracts/consultation_repository.dart';
import 'package:sura/domain/contracts/patient_repository.dart';
import 'package:sura/domain/contracts/sync_service.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';

/// Transport séparé pour tester la machine d'états sans Firebase.
abstract class SyncRemoteStore {
  Future<void> sendPatient(String agentId, PatientRecord patient);
  Future<void> sendConsultation(
    String agentId,
    ConsultationRecord consultation,
  );
}

class RepositorySyncService implements SyncService {
  RepositorySyncService({
    required this.patients,
    required this.consultations,
    required this.remote,
    required this.currentAgentId,
    required this.checkOnline,
    this.baseRetryDelay = const Duration(seconds: 2),
    this.maxRetryDelay = const Duration(minutes: 2),
    this.sendTimeout = const Duration(seconds: 30),
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final PatientRepository patients;
  final ConsultationRepository consultations;
  final SyncRemoteStore remote;
  final String? Function() currentAgentId;
  final Future<bool> Function() checkOnline;
  final Duration baseRetryDelay;
  final Duration maxRetryDelay;
  final Duration sendTimeout;
  final DateTime Function() now;
  final _states = StreamController<SyncState>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  final _failures = <String, int>{};
  final _due = <String, DateTime>{};
  SyncState _state = SyncState.offline;
  Future<void>? _running;
  Timer? _timer;
  bool _requested = false;
  bool _disposed = false;
  bool _started = false;
  bool? _lastConnectivity;

  /// Les changements locaux, réseau et de session réveillent la file.
  void start({
    required Stream<bool> connectivity,
    required Stream<String?> auth,
  }) {
    if (_started || _disposed) return;
    _started = true;
    _subscriptions.add(
      connectivity.listen((online) {
        final previous = _lastConnectivity;
        _lastConnectivity = online;
        if (online) {
          if (previous != true) _due.clear();
          _wake();
        } else {
          _timer?.cancel();
          _emit(SyncState.offline);
        }
      }, onError: (Object _) => _emit(SyncState.offline)),
    );
    _subscriptions.add(
      auth.listen((_) {
        _due.clear();
        _wake();
      }, onError: (Object _) => _emit(SyncState.error)),
    );
    _subscriptions.add(
      patients.watchAll().listen((items) {
        if (items.any(
          (p) =>
              p.createdByAgentId == currentAgentId() &&
              p.syncState == SyncState.pending,
        )) {
          _wake();
        }
      }, onError: (Object _) => _emit(SyncState.error)),
    );
    _subscriptions.add(
      consultations.watchAll().listen((items) {
        if (items.any(
          (c) =>
              c.agentId == currentAgentId() &&
              _validated(c) &&
              c.syncState == SyncState.pending,
        )) {
          _wake();
        }
      }, onError: (Object _) => _emit(SyncState.error)),
    );
    _wake();
  }

  void _wake() {
    if (!_disposed) unawaited(syncPending());
  }

  void _emit(SyncState state) {
    if (_disposed || _state == state) return;
    _state = state;
    _states.add(state);
  }

  @override
  Stream<SyncState> watchOverall() => Stream<SyncState>.multi((controller) {
    final subscription = _states.stream.listen(controller.add);
    controller.add(_state);
    controller.onCancel = subscription.cancel;
  });

  @override
  Future<void> syncPending() {
    if (_disposed) return Future<void>.value();
    _requested = true;
    return _running ??= _drain().whenComplete(() => _running = null);
  }

  Future<void> _drain() async {
    _timer?.cancel();
    try {
      do {
        _requested = false;
        await _pass();
      } while (_requested && !_disposed);
    } catch (_) {
      // Une panne de lecture locale ne doit pas produire une erreur asynchrone
      // non gérée ni effacer la file.
      _emit(SyncState.error);
      if (!_disposed) _timer = Timer(baseRetryDelay, _wake);
    }
  }

  bool _validated(ConsultationRecord c) =>
      c.status == ConsultationStatus.saved && c.validatedAt != null;

  bool _queued(SyncState state) => state != SyncState.synced;
  bool _ready(String key) => !(_due[key]?.isAfter(now()) ?? false);

  Future<bool> _allowed(String agent) async {
    if (_disposed || currentAgentId() != agent) return false;
    if (!await checkOnline()) {
      _emit(SyncState.offline);
      return false;
    }
    return !_disposed && currentAgentId() == agent;
  }

  Future<void> _pass() async {
    final agent = currentAgentId();
    if (agent == null || !await _allowed(agent)) {
      _emit(SyncState.offline);
      return;
    }
    final patientItems = await patients.watchAll().first;
    for (final p in patientItems) {
      final key = 'p:${p.id}';
      if (p.createdByAgentId != agent ||
          !_queued(p.syncState) ||
          !_ready(key)) {
        continue;
      }
      if (!await _allowed(agent)) return;
      final attempts = p.syncAttempts + 1;
      if (!await patients.updateSyncState(
        p.id,
        SyncState.syncing,
        expectedUpdatedAt: p.updatedAt,
        attempts: attempts,
      )) {
        continue;
      }
      _emit(SyncState.syncing);
      try {
        await remote.sendPatient(agent, p).timeout(sendTimeout);
        await patients.updateSyncState(
          p.id,
          SyncState.synced,
          expectedUpdatedAt: p.updatedAt,
          attempts: attempts,
        );
        _succeeded(key);
      } catch (_) {
        await patients.updateSyncState(
          p.id,
          SyncState.error,
          error: 'Envoi interrompu. Les données restent sur cet appareil.',
          expectedUpdatedAt: p.updatedAt,
          attempts: attempts,
        );
        _failed(key, attempts);
      }
    }
    final consultationItems = await consultations.watchAll().first;
    for (final c in consultationItems) {
      final key = 'c:${c.id}';
      if (c.agentId != agent ||
          !_validated(c) ||
          !_queued(c.syncState) ||
          !_ready(key)) {
        continue;
      }
      if (!await _allowed(agent)) return;
      final parent = await patients.getById(c.patientId);
      if (parent == null ||
          parent.createdByAgentId != agent ||
          parent.syncState != SyncState.synced) {
        await consultations.updateSyncState(
          c.id,
          SyncState.error,
          expectedUpdatedAt: c.updatedAt,
          error: 'Le patient doit être synchronisé avant la consultation.',
        );
        _failed(key);
        continue;
      }
      final attempts = c.syncAttempts + 1;
      if (!await consultations.updateSyncState(
        c.id,
        SyncState.syncing,
        expectedUpdatedAt: c.updatedAt,
        attempts: attempts,
      )) {
        continue;
      }
      _emit(SyncState.syncing);
      try {
        await remote.sendConsultation(agent, c).timeout(sendTimeout);
        await consultations.updateSyncState(
          c.id,
          SyncState.synced,
          expectedUpdatedAt: c.updatedAt,
          attempts: attempts,
        );
        _succeeded(key);
      } catch (_) {
        await consultations.updateSyncState(
          c.id,
          SyncState.error,
          expectedUpdatedAt: c.updatedAt,
          attempts: attempts,
          error: 'Envoi interrompu. Les données restent sur cet appareil.',
        );
        _failed(key, attempts);
      }
    }
    if (!await _allowed(agent)) return;
    final ps = (await patients.watchAll().first).where(
      (p) => p.createdByAgentId == agent,
    );
    final cs = (await consultations.watchAll().first).where(
      (c) => c.agentId == agent && _validated(c),
    );
    final states = [
      ...ps.map((p) => p.syncState),
      ...cs.map((c) => c.syncState),
    ];
    _emit(
      states.contains(SyncState.error)
          ? SyncState.error
          : states.any(_queued)
          ? SyncState.pending
          : SyncState.synced,
    );
    _scheduleRetry();
  }

  void _succeeded(String key) {
    _failures.remove(key);
    _due.remove(key);
  }

  void _failed(String key, [int? persistedAttempts]) {
    final count = persistedAttempts ?? (_failures[key] ?? 0) + 1;
    _failures[key] = count;
    // Plafond avant le décalage pour éviter les débordements.
    final factor = 1 << (count - 1).clamp(0, 16);
    final milliseconds = (baseRetryDelay.inMilliseconds * factor).clamp(
      0,
      maxRetryDelay.inMilliseconds,
    );
    _due[key] = now().add(Duration(milliseconds: milliseconds));
  }

  void _scheduleRetry() {
    _timer?.cancel();
    if (_disposed || _due.isEmpty) return;
    final earliest = _due.values.reduce((a, b) => a.isBefore(b) ? a : b);
    final delay = earliest.difference(now());
    _timer = Timer(delay.isNegative ? Duration.zero : delay, _wake);
  }

  @override
  Future<void> retry(String recordId) async {
    final agent = currentAgentId();
    if (agent == null || _disposed) return;
    final patient = await patients.getById(recordId);
    if (patient != null) {
      if (patient.createdByAgentId != agent) return;
      _due.remove('p:${patient.id}');
      // Réveille aussi les consultations bloquées par ce patient.
      for (final c in await consultations.watchAll().first) {
        if (c.agentId == agent && c.patientId == patient.id && _validated(c)) {
          _due.remove('c:${c.id}');
        }
      }
    } else {
      final c = await consultations.getById(recordId);
      if (c == null || c.agentId != agent || !_validated(c)) return;
      _due.remove('c:${c.id}');
      _due.remove('p:${c.patientId}');
    }
    await syncPending();
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_states.close());
  }
}
