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
  final List<QueuedSyncAction> _queue = <QueuedSyncAction>[];

  List<QueuedSyncAction> get pendingQueue => List<QueuedSyncAction>.unmodifiable(_queue);

  void setOffline(bool value) {
    if (isOffline.value == value) {
      return;
    }
    isOffline.value = value;
    if (!value) {
      flush();
    }
  }

  void enqueue(QueuedSyncAction action) {
    _queue.add(action);
    pendingActions.value = _queue.length;
  }

  Future<void> flush() async {
    if (_queue.isEmpty) {
      return;
    }
    final List<QueuedSyncAction> actions = List<QueuedSyncAction>.from(_queue);
    _queue.clear();
    pendingActions.value = 0;

    for (final QueuedSyncAction action in actions) {
      try {
        await action.execute();
      } catch (_) {
        _queue.insert(0, action);
        pendingActions.value = _queue.length;
        break;
      }
    }
  }
}
