import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/models/profile.dart';
import '../../../../data/models/sync_action.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../data/services/offline_sync_manager.dart';

class ProfileHistoryEntry extends Equatable {
  const ProfileHistoryEntry({
    required this.timestamp,
    required this.summary,
  });

  final DateTime timestamp;
  final String summary;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'timestamp': timestamp.toIso8601String(),
        'summary': summary,
      };

  factory ProfileHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ProfileHistoryEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      summary: json['summary'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => <Object?>[timestamp, summary];
}

class ProfileHistoryStore {
  ProfileHistoryStore({SharedPreferences? preferences})
      : _preferences = preferences;

  SharedPreferences? _preferences;

  static const int _maxEntries = 15;

  Future<List<ProfileHistoryEntry>> load(String profileId) async {
    final SharedPreferences prefs = await _ensurePreferences();
    final String? raw = prefs.getString(_historyKey(profileId));
    if (raw == null || raw.isEmpty) {
      return const <ProfileHistoryEntry>[];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ProfileHistoryEntry.fromJson)
          .toList();
    } catch (_) {
      return const <ProfileHistoryEntry>[];
    }
  }

  Future<List<ProfileHistoryEntry>> add(
    String profileId,
    Profile profile,
  ) async {
    final SharedPreferences prefs = await _ensurePreferences();
    final List<ProfileHistoryEntry> current = await load(profileId);
    final ProfileHistoryEntry entry = ProfileHistoryEntry(
      timestamp: DateTime.now(),
      summary: _summaryFor(profile),
    );
    final List<ProfileHistoryEntry> updated = <ProfileHistoryEntry>[
      entry,
      ...current,
    ];
    if (updated.length > _maxEntries) {
      updated.removeRange(_maxEntries, updated.length);
    }
    await prefs.setString(
      _historyKey(profileId),
      jsonEncode(
        updated.map((ProfileHistoryEntry entry) => entry.toJson()).toList(),
      ),
    );
    return updated;
  }

  Future<SharedPreferences> _ensurePreferences() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  String _summaryFor(Profile profile) {
    final StringBuffer buffer = StringBuffer();
    buffer.write('Nom: ${profile.farmName.isEmpty ? '- ' : profile.farmName}');
    buffer.write(' • Localisation: ${profile.farmLocation ?? 'Non définie'}');
    buffer.write(' • Téléphone: ${profile.phone ?? 'Non défini'}');
    buffer.write(
      ' • RGPD: ${(profile.hasAcceptedTerms && profile.hasAcceptedPrivacy) ? 'Accepté' : 'En attente'}',
    );
    return buffer.toString();
  }

  static String _historyKey(String profileId) =>
      'profile_history_$profileId';
}

class ProfileState extends Equatable {
  const ProfileState({
    this.loading = false,
    this.saving = false,
    this.profile,
    this.errorMessage,
    this.successMessage,
    this.history = const <ProfileHistoryEntry>[],
    this.pendingSync = false,
  });

  final bool loading;
  final bool saving;
  final Profile? profile;
  final String? errorMessage;
  final String? successMessage;
  final List<ProfileHistoryEntry> history;
  final bool pendingSync;

  ProfileState copyWith({
    bool? loading,
    bool? saving,
    Profile? profile,
    bool clearProfile = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    List<ProfileHistoryEntry>? history,
    bool? pendingSync,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      profile: clearProfile ? null : profile ?? this.profile,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
      history: history ?? this.history,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        loading,
        saving,
        profile,
        errorMessage,
        successMessage,
        history,
        pendingSync,
      ];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required ProfileRepository repository,
    required String profileId,
    required ProfileHistoryStore historyStore,
    OfflineSyncManager? offlineManager,
    Profile? seed,
  })  : _repository = repository,
        _profileId = profileId,
        _historyStore = historyStore,
        _offlineManager = offlineManager ?? OfflineSyncManager.instance,
        _seed = seed,
        super(const ProfileState());

  final ProfileRepository _repository;
  final String _profileId;
  final ProfileHistoryStore _historyStore;
  final OfflineSyncManager _offlineManager;
  final Profile? _seed;

  bool _initialized = false;
  VoidCallback? _queueListener;

  void initialize() {
    if (_initialized) {
      return;
    }
    _initialized = true;
    if (_seed != null) {
      emit(
        state.copyWith(
          profile: _seed,
          loading: true,
          clearError: true,
          clearSuccess: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          loading: true,
          clearError: true,
          clearSuccess: true,
        ),
      );
    }

    _queueListener = _handleQueueUpdate;
    _offlineManager.pendingQueueNotifier.addListener(_queueListener!);
    _handleQueueUpdate();

    unawaited(_loadHistory());
    unawaited(_refreshProfile());
  }

  Future<void> _loadHistory() async {
    try {
      final List<ProfileHistoryEntry> entries =
          await _historyStore.load(_profileId);
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          history: entries,
        ),
      );
    } catch (error) {
      // History failures should not block the screen; log silently.
    }
  }

  Future<void> _refreshProfile() async {
    try {
      final Profile profile = await _repository.fetch(_profileId);
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          profile: profile,
          loading: false,
          clearError: true,
        ),
      );
    } catch (error) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          loading: false,
          errorMessage: state.profile == null ? error.toString() : state.errorMessage,
        ),
      );
    }
  }

  Future<void> save(Profile profile) async {
    emit(
      state.copyWith(
        saving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final Profile updated = await _repository.update(profile);
      final List<ProfileHistoryEntry> history =
          await _historyStore.add(_profileId, updated);
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          saving: false,
          profile: updated,
          history: history,
          successMessage: _offlineManager.isOffline.value
              ? 'Modifications enregistrées hors connexion. Elles seront synchronisées automatiquement.'
              : 'Profil mis à jour avec succès.',
        ),
      );
      _handleQueueUpdate();
    } catch (error) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          saving: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refresh() => _refreshProfile();

  void acknowledgeError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  void acknowledgeSuccess() {
    if (state.successMessage != null) {
      emit(state.copyWith(clearSuccess: true));
    }
  }

  void _handleQueueUpdate() {
    final bool pending = _offlineManager.pendingQueue.any(
      (QueuedSyncAction action) => action.type == SyncActionType.updateProfile,
    );
    if (pending != state.pendingSync) {
      emit(state.copyWith(pendingSync: pending));
      if (!pending) {
        unawaited(_refreshProfile());
      }
    }
  }

  @override
  Future<void> close() async {
    if (_queueListener != null) {
      _offlineManager.pendingQueueNotifier.removeListener(_queueListener!);
      _queueListener = null;
    }
    return super.close();
  }
}
