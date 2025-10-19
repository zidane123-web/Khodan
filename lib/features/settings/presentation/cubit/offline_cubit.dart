import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/models/sync_action.dart';
import '../../../../data/services/offline_sync_manager.dart';
import 'sync_history_cubit.dart';

class OfflineState extends Equatable {
  const OfflineState({
    this.enabled = false,
    this.loading = false,
    this.pendingActions = 0,
    this.queue = const <QueuedSyncAction>[],
    this.lastSuccess,
    this.errorMessage,
    this.statusMessage,
  });

  final bool enabled;
  final bool loading;
  final int pendingActions;
  final List<QueuedSyncAction> queue;
  final DateTime? lastSuccess;
  final String? errorMessage;
  final String? statusMessage;

  OfflineState copyWith({
    bool? enabled,
    bool? loading,
    int? pendingActions,
    List<QueuedSyncAction>? queue,
    DateTime? lastSuccess,
    String? errorMessage,
    bool clearError = false,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return OfflineState(
      enabled: enabled ?? this.enabled,
      loading: loading ?? this.loading,
      pendingActions: pendingActions ?? this.pendingActions,
      queue: queue ?? this.queue,
      lastSuccess: lastSuccess ?? this.lastSuccess,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      statusMessage:
          clearStatusMessage ? null : statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        enabled,
        loading,
        pendingActions,
        queue,
        lastSuccess,
        errorMessage,
        statusMessage,
      ];
}

class OfflineCubit extends Cubit<OfflineState> {
  OfflineCubit({
    SharedPreferences? preferences,
    OfflineSyncManager? manager,
    SyncHistoryCubit? historyCubit,
  })  : _preferences = preferences,
        _manager = manager ?? OfflineSyncManager.instance,
        _historyCubit = historyCubit,
        super(const OfflineState());

  static const String _prefOfflineModeKey = 'offline_mode';
  static const String _prefLastSuccessKey = 'offline_last_success';

  final OfflineSyncManager _manager;
  final SyncHistoryCubit? _historyCubit;

  SharedPreferences? _preferences;
  VoidCallback? _pendingListener;
  VoidCallback? _queueListener;
  VoidCallback? _offlineListener;

  Future<void> initialize() async {
    emit(state.copyWith(loading: true, clearError: true, clearStatusMessage: true));
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _historyCubit?.initialize();

      final bool savedValue =
          _preferences!.getBool(_prefOfflineModeKey) ?? false;
      _manager.setOffline(savedValue, flushWhenOnline: false);
      _listenToManager();

      final DateTime? lastSuccess = _loadLastSuccess();

      emit(
        state.copyWith(
          enabled: savedValue,
          loading: false,
          pendingActions: _manager.pendingActions.value,
          queue:
              List<QueuedSyncAction>.from(_manager.pendingQueueNotifier.value),
          lastSuccess: lastSuccess,
          clearError: true,
          clearStatusMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> toggle(bool enabled) async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        clearStatusMessage: true,
      ),
    );
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.setBool(_prefOfflineModeKey, enabled);
      _manager.setOffline(enabled, flushWhenOnline: false);

      DateTime? lastSuccess = state.lastSuccess;

      if (!enabled) {
        await _historyCubit?.addEntry(
          'Mode hors-ligne desactive',
          category: 'info',
        );
        final bool success = await _manager.flush();
        if (success) {
          lastSuccess = DateTime.now();
          await _saveLastSuccess(lastSuccess);
          await _historyCubit?.addEntry(
            'Synchronisation automatique reussie',
            timestamp: lastSuccess,
            category: 'info',
          );
        } else {
          await _historyCubit?.addEntry(
            'Synchronisation automatique partielle : des actions restent en attente.',
            category: 'warning',
          );
        }
      } else {
        await _historyCubit?.addEntry(
          'Mode hors-ligne active',
          category: 'info',
        );
      }

      emit(
        state.copyWith(
          enabled: enabled,
          loading: false,
          pendingActions: _manager.pendingActions.value,
          queue:
              List<QueuedSyncAction>.from(_manager.pendingQueueNotifier.value),
          lastSuccess: lastSuccess,
          statusMessage: enabled
              ? 'Mode hors-ligne active.'
              : (_manager.pendingQueueNotifier.value.isEmpty
                  ? 'Synchronisation realisee avec succes.'
                  : 'Synchronisation partielle, des actions restent en attente.'),
        ),
      );
    } catch (error) {
      await _historyCubit?.addEntry(
        'Erreur lors du changement de mode : $error',
        category: 'error',
      );
      emit(
        state.copyWith(
          loading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
  Future<void> synchronizeNow() async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        clearStatusMessage: true,
      ),
    );
    try {
      final bool success = await _manager.flush();
      DateTime? lastSuccess = state.lastSuccess;

      if (success) {
        lastSuccess = DateTime.now();
        await _saveLastSuccess(lastSuccess);
        await _historyCubit?.addEntry(
          'Synchronisation manuelle reussie',
          timestamp: lastSuccess,
          category: 'info',
        );
      } else {
        await _historyCubit?.addEntry(
          'Synchronisation manuelle partielle : des actions restent en attente.',
          category: 'warning',
        );
      }

      emit(
        state.copyWith(
          loading: false,
          pendingActions: _manager.pendingActions.value,
          queue:
              List<QueuedSyncAction>.from(_manager.pendingQueueNotifier.value),
          lastSuccess: lastSuccess,
          statusMessage: success
              ? 'Synchronisation terminee.'
              : 'Des actions restent a synchroniser.',
        ),
      );
    } catch (error) {
      await _historyCubit?.addEntry(
        'Erreur de synchronisation manuelle : $error',
        category: 'error',
      );
      emit(
        state.copyWith(
          loading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
  void acknowledgeStatus() {
    if (state.statusMessage != null) {
      emit(state.copyWith(clearStatusMessage: true));
    }
  }

  void acknowledgeError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  void _listenToManager() {
    _pendingListener ??= () {
      emit(
        state.copyWith(
          pendingActions: _manager.pendingActions.value,
        ),
      );
    };
    _queueListener ??= () {
      emit(
        state.copyWith(
          queue: List<QueuedSyncAction>.from(
            _manager.pendingQueueNotifier.value,
          ),
        ),
      );
    };
    _offlineListener ??= () {
      if (state.enabled != _manager.isOffline.value) {
        emit(state.copyWith(enabled: _manager.isOffline.value));
      }
    };
    _manager.pendingActions.addListener(_pendingListener!);
    _manager.pendingQueueNotifier.addListener(_queueListener!);
    _manager.isOffline.addListener(_offlineListener!);
  }

  DateTime? _loadLastSuccess() {
    final String? raw = _preferences?.getString(_prefLastSuccessKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> _saveLastSuccess(DateTime dateTime) async {
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.setString(
      _prefLastSuccessKey,
      dateTime.toIso8601String(),
    );
  }

  @override
  Future<void> close() {
    if (_pendingListener != null) {
      _manager.pendingActions.removeListener(_pendingListener!);
    }
    if (_queueListener != null) {
      _manager.pendingQueueNotifier.removeListener(_queueListener!);
    }
    if (_offlineListener != null) {
      _manager.isOffline.removeListener(_offlineListener!);
    }
    return super.close();
  }
}








