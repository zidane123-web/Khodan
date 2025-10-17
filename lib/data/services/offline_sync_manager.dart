import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../local/local_data_sources.dart';
import '../models/sync_action.dart';

typedef SyncActionExecutor = Future<void> Function(QueuedSyncAction action);
typedef SyncActionRollback = Future<void> Function(
  QueuedSyncAction action,
  Object error,
);

class SyncActionRequest {
  SyncActionRequest({
    required this.type,
    required this.description,
    required this.payload,
    this.rollbackType,
    this.rollbackPayload,
    this.priority = 0,
    this.execute,
  });

  final SyncActionType type;
  final String description;
  final Map<String, dynamic> payload;
  final SyncActionType? rollbackType;
  final Map<String, dynamic>? rollbackPayload;
  final int priority;
  final Future<void> Function()? execute;
}

class OfflineSyncManager {
  OfflineSyncManager._();

  static final OfflineSyncManager instance = OfflineSyncManager._();

  static const int _maxAttempts = 5;
  static const Duration _baseBackoff = Duration(seconds: 8);
  static const Duration _maxBackoff = Duration(minutes: 30);
  static final Uuid _uuid = const Uuid();

  final ValueNotifier<bool> isOffline = ValueNotifier<bool>(false);
  final ValueNotifier<int> pendingActions = ValueNotifier<int>(0);
  final ValueNotifier<List<QueuedSyncAction>> pendingQueueNotifier =
      ValueNotifier<List<QueuedSyncAction>>(const <QueuedSyncAction>[]);

  final Map<SyncActionType, SyncActionExecutor> _handlers =
      <SyncActionType, SyncActionExecutor>{};
  final Map<SyncActionType, SyncActionRollback> _rollbackHandlers =
      <SyncActionType, SyncActionRollback>{};
  final Map<String, Future<void> Function()> _ephemeralExecutors =
      <String, Future<void> Function()>{};

  final List<QueuedSyncAction> _queueCache = <QueuedSyncAction>[];

  LocalSyncQueueDataSource? _queueDataSource;
  Future<bool>? _ongoingFlush;
  bool _initialLoadCompleted = false;
  Future<void> Function(String message, {DateTime? timestamp})?
      _historyLogger;

  List<QueuedSyncAction> get pendingQueue =>
      List<QueuedSyncAction>.unmodifiable(_queueCache);

  void attachQueue(LocalSyncQueueDataSource dataSource) {
    _queueDataSource = dataSource;
    _initialLoadCompleted = false;
    unawaited(_refreshCache());
  }

  void setHistoryLogger(
    Future<void> Function(String message, {DateTime? timestamp})? logger,
  ) {
    _historyLogger = logger;
  }

  void registerHandler(
    SyncActionType type,
    SyncActionExecutor handler, {
    SyncActionRollback? rollback,
  }) {
    _handlers[type] = handler;
    if (rollback != null) {
      _rollbackHandlers[type] = rollback;
    }
  }

  void setOffline(bool value, {bool flushWhenOnline = true}) {
    if (isOffline.value == value) {
      return;
    }
    isOffline.value = value;
    if (!value && flushWhenOnline) {
      unawaited(flush());
    }
  }

  Future<QueuedSyncAction> enqueueAction(SyncActionRequest request) async {
    final LocalSyncQueueDataSource dataSource = _ensureDataSource();
    final DateTime now = DateTime.now();
    final QueuedSyncAction action = QueuedSyncAction(
      id: _uuid.v4(),
      type: request.type,
      rollbackType: request.rollbackType,
      description: request.description,
      payload: request.payload,
      rollbackPayload: request.rollbackPayload,
      priority: request.priority,
      status: SyncActionStatus.pending,
      attempts: 0,
      createdAt: now,
      updatedAt: now,
      scheduledAt: null,
      lastError: null,
    );
    if (request.execute != null) {
      _ephemeralExecutors[action.id] = request.execute!;
    }
    await dataSource.insertAction(action);
    await _refreshCache();

    if (!isOffline.value) {
      unawaited(flush());
    } else {
      await _logHistory(
        'Action mise en file d\'attente : ${action.description}',
      );
    }
    return action;
  }

  Future<bool> flush() async {
    if (_queueDataSource == null) {
      return false;
    }
    if (_ongoingFlush != null) {
      return _ongoingFlush!;
    }
    final Completer<bool> completer = Completer<bool>();
    _ongoingFlush = completer.future;
    bool result = false;
    try {
      result = await _runFlush();
      completer.complete(result);
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _ongoingFlush = null;
    }
    return result;
  }

  Future<bool> _runFlush() async {
    final LocalSyncQueueDataSource dataSource = _ensureDataSource();
    bool allCompleted = true;
    while (true) {
      final List<QueuedSyncAction> batch =
          await dataSource.fetchExecutable(limit: 5);
      if (batch.isEmpty) {
        break;
      }
      for (final QueuedSyncAction action in batch) {
        await dataSource.updateStatus(
          action.id,
          status: SyncActionStatus.running,
          attempts: action.attempts,
          scheduledAt: null,
          lastError: null,
        );
        final QueuedSyncAction runningAction = action.copyWith(
          status: SyncActionStatus.running,
          updatedAt: DateTime.now(),
          clearScheduledAt: true,
          clearLastError: true,
        );
        await _refreshCache();
        final Future<void> Function()? closure = _ephemeralExecutors[action.id];
        final SyncActionExecutor? handler = _handlers[action.type];
        if (closure == null && handler == null) {
          await dataSource.updateStatus(
            action.id,
            status: SyncActionStatus.failed,
            attempts: action.attempts + 1,
            scheduledAt: null,
            lastError: 'Aucun exécuteur enregistré pour ${action.type.key}',
          );
          await _refreshCache();
          await _logHistory(
            'Action impossible à exécuter : ${action.description}',
          );
          allCompleted = false;
          continue;
        }
        try {
          if (closure != null) {
            await closure();
          } else if (handler != null) {
            await handler(runningAction);
          }
          await dataSource.updateStatus(
            action.id,
            status: SyncActionStatus.completed,
            attempts: runningAction.attempts,
            scheduledAt: null,
            lastError: null,
          );
          _ephemeralExecutors.remove(action.id);
          await _refreshCache();
          await _logHistory(
            'Synchronisation effectuée : ${action.description}',
          );
        } catch (error) {
          final int nextAttempts = runningAction.attempts + 1;
          final bool hasRetry = nextAttempts < _maxAttempts;
          final DateTime? schedule =
              hasRetry ? DateTime.now().add(_computeBackoff(nextAttempts)) : null;
          await dataSource.updateStatus(
            action.id,
            status:
                hasRetry ? SyncActionStatus.pending : SyncActionStatus.failed,
            attempts: nextAttempts,
            scheduledAt: schedule,
            lastError: error.toString(),
          );
          await _refreshCache();
          if (hasRetry) {
            await _logHistory(
              'Synchronisation reportée ($nextAttempts/$_maxAttempts) : ${action.description}',
            );
          } else {
            await _logHistory(
              'Synchronisation abandonnée : ${action.description} - ${error.toString()}',
            );
            final SyncActionType rollbackKey =
                action.rollbackType ?? action.type;
            final SyncActionRollback? rollback =
                _rollbackHandlers[rollbackKey];
            if (rollback != null) {
              try {
                await rollback(action, error);
              } catch (_) {
                // rollback failure is ignored but logged silently
              }
            }
          }
          allCompleted = false;
        }
      }
    }
    if (allCompleted) {
      await _logHistory('Toutes les actions hors-ligne sont synchronisées.');
    }
    return allCompleted && pendingActions.value == 0;
  }

  Duration _computeBackoff(int attempt) {
    final int multiplier = pow(2, attempt - 1).toInt();
    final Duration candidate = _baseBackoff * multiplier;
    if (candidate > _maxBackoff) {
      return _maxBackoff;
    }
    return candidate;
  }

  LocalSyncQueueDataSource _ensureDataSource() {
    final LocalSyncQueueDataSource? dataSource = _queueDataSource;
    if (dataSource == null) {
      throw StateError(
        'OfflineSyncManager n\'a pas été initialisé avec une file persitante.',
      );
    }
    return dataSource;
  }

  Future<void> _refreshCache() async {
    if (_queueDataSource == null) {
      pendingActions.value = 0;
      pendingQueueNotifier.value = const <QueuedSyncAction>[];
      return;
    }
    final List<QueuedSyncAction> snapshot =
        await _queueDataSource!.fetchAll();
    _queueCache
      ..clear()
      ..addAll(snapshot);
    final int pendingCount = snapshot
        .where(
          (QueuedSyncAction action) =>
              action.status != SyncActionStatus.completed,
        )
        .length;
    pendingActions.value = pendingCount;
    pendingQueueNotifier.value =
        List<QueuedSyncAction>.unmodifiable(snapshot);

    if (!_initialLoadCompleted) {
      _initialLoadCompleted = true;
      if (pendingCount > 0 && !isOffline.value) {
        unawaited(flush());
      }
    }
  }

  Future<void> _logHistory(
    String message, {
    DateTime? timestamp,
  }) async {
    final Future<void> Function(String, {DateTime? timestamp})? logger =
        _historyLogger;
    if (logger == null) {
      return;
    }
    await logger(message, timestamp: timestamp);
  }
}
