import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/services/offline_sync_manager.dart';

class OfflineState extends Equatable {
  const OfflineState({
    this.enabled = false,
    this.loading = false,
    this.pendingActions = 0,
    this.errorMessage,
  });

  final bool enabled;
  final bool loading;
  final int pendingActions;
  final String? errorMessage;

  OfflineState copyWith({
    bool? enabled,
    bool? loading,
    int? pendingActions,
    String? errorMessage,
  }) {
    return OfflineState(
      enabled: enabled ?? this.enabled,
      loading: loading ?? this.loading,
      pendingActions: pendingActions ?? this.pendingActions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[enabled, loading, pendingActions, errorMessage];
}

class OfflineCubit extends Cubit<OfflineState> {
  OfflineCubit({SharedPreferences? preferences, OfflineSyncManager? manager})
      : _preferences = preferences,
        _manager = manager ?? OfflineSyncManager.instance,
        super(const OfflineState());

  final OfflineSyncManager _manager;
  SharedPreferences? _preferences;
  VoidCallback? _pendingListener;
  VoidCallback? _offlineListener;

  Future<void> initialize() async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      _preferences ??= await SharedPreferences.getInstance();
      final bool savedValue = _preferences!.getBool('offline_mode') ?? false;
      _manager.setOffline(savedValue);
      _listenToManager();
      emit(
        state.copyWith(
          enabled: savedValue,
          loading: false,
          pendingActions: _manager.pendingActions.value,
          errorMessage: null,
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
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.setBool('offline_mode', enabled);
      _manager.setOffline(enabled);
      if (!enabled) {
        await _manager.flush();
      }
      emit(
        state.copyWith(
          enabled: enabled,
          loading: false,
          pendingActions: _manager.pendingActions.value,
          errorMessage: null,
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

  Future<void> synchronizeNow() async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      await _manager.flush();
      emit(
        state.copyWith(
          loading: false,
          pendingActions: _manager.pendingActions.value,
          errorMessage: null,
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

  void _listenToManager() {
    _pendingListener ??= () {
      emit(state.copyWith(pendingActions: _manager.pendingActions.value));
    };
    _offlineListener ??= () {
      if (state.enabled != _manager.isOffline.value) {
        emit(state.copyWith(enabled: _manager.isOffline.value));
      }
    };
    _manager.pendingActions.addListener(_pendingListener!);
    _manager.isOffline.addListener(_offlineListener!);
  }

  @override
  Future<void> close() {
    if (_pendingListener != null) {
      _manager.pendingActions.removeListener(_pendingListener!);
    }
    if (_offlineListener != null) {
      _manager.isOffline.removeListener(_offlineListener!);
    }
    return super.close();
  }
}
