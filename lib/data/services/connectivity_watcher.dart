import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'offline_sync_manager.dart';

/// Listens to connectivity changes and keeps [OfflineSyncManager] in sync.
class ConnectivityWatcher {
  ConnectivityWatcher({
    Connectivity? connectivity,
    OfflineSyncManager? offlineManager,
  }) : _connectivity = connectivity ?? Connectivity(),
       _offlineManager = offlineManager ?? OfflineSyncManager.instance;

  final Connectivity _connectivity;
  final OfflineSyncManager _offlineManager;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> initialize() async {
    final List<ConnectivityResult> initial = await _connectivity
        .checkConnectivity();
    _offlineManager.setOffline(_isOffline(initial), flushWhenOnline: false);
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _offlineManager.setOffline(_isOffline(results));
      },
      onError: (_) {
        _offlineManager.setOffline(true, flushWhenOnline: false);
      },
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  bool _isOffline(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return true;
    }
    return results.every((ConnectivityResult result) {
      return result == ConnectivityResult.none;
    });
  }
}
