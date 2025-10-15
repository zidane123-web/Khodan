import 'dart:async';

import 'package:flutter/foundation.dart';

class QueuedSyncAction {
  const QueuedSyncAction({
    required this.description,
    required this.execute,
  });

  final String description;
  final Future<void> Function() execute;
}

class OfflineSyncManager {
  OfflineSyncManager._();

  static final OfflineSyncManager instance = OfflineSyncManager._();

  final ValueNotifier<bool> isOffline = ValueNotifier<bool>(false);
  final ValueNotifier<int> pendingActions = ValueNotifier<int>(0);
  final ValueNotifier<List<QueuedSyncAction>> pendingQueueNotifier =
      ValueNotifier<List<QueuedSyncAction>>(const <QueuedSyncAction>[]);

  final List<QueuedSyncAction> _queue = <QueuedSyncAction>[];

  List<QueuedSyncAction> get pendingQueue =>
      List<QueuedSyncAction>.unmodifiable(_queue);

  void setOffline(bool value, {bool flushWhenOnline = true}) {
    if (isOffline.value == value) {
      return;
    }
    isOffline.value = value;
    if (!value && flushWhenOnline) {
      unawaited(flush());
    }
  }

  void enqueue(QueuedSyncAction action) {
    _queue.add(action);
    _notifyQueueChanged();
  }

  Future<bool> flush() async {
    if (_queue.isEmpty) {
      _notifyQueueChanged();
      return true;
    }

    final List<QueuedSyncAction> actions = List<QueuedSyncAction>.from(_queue);
    _queue.clear();
    _notifyQueueChanged();

    bool allSucceeded = true;
    for (int index = 0; index < actions.length; index += 1) {
      final QueuedSyncAction action = actions[index];
      try {
        await action.execute();
      } catch (_) {
        allSucceeded = false;
        final Iterable<QueuedSyncAction> remaining =
            actions.skip(index + 1);
        _queue
          ..insert(0, action)
          ..insertAll(1, remaining);
        _notifyQueueChanged();
        break;
      }
    }

    if (allSucceeded) {
      _notifyQueueChanged();
    }
    return allSucceeded && _queue.isEmpty;
  }

  void _notifyQueueChanged() {
    pendingActions.value = _queue.length;
    pendingQueueNotifier.value =
        List<QueuedSyncAction>.unmodifiable(_queue);
  }
}
