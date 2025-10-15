import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncHistoryEntry extends Equatable {
  const SyncHistoryEntry({
    required this.timestamp,
    required this.message,
  });

  final DateTime timestamp;
  final String message;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'timestamp': timestamp.toIso8601String(),
        'message': message,
      };

  factory SyncHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SyncHistoryEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      message: json['message'] as String,
    );
  }

  @override
  List<Object?> get props => <Object?>[timestamp, message];
}

class SyncHistoryState extends Equatable {
  const SyncHistoryState({
    this.entries = const <SyncHistoryEntry>[],
    this.loading = false,
    this.errorMessage,
  });

  final List<SyncHistoryEntry> entries;
  final bool loading;
  final String? errorMessage;

  SyncHistoryState copyWith({
    List<SyncHistoryEntry>? entries,
    bool? loading,
    String? errorMessage,
  }) {
    return SyncHistoryState(
      entries: entries ?? this.entries,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[entries, loading, errorMessage];
}

class SyncHistoryCubit extends Cubit<SyncHistoryState> {
  SyncHistoryCubit({SharedPreferences? preferences})
      : _preferences = preferences,
        super(const SyncHistoryState());

  static const String _historyKey = 'sync_history_entries';
  static const int _maxEntries = 30;

  SharedPreferences? _preferences;

  Future<void> initialize() async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      _preferences ??= await SharedPreferences.getInstance();
      final List<SyncHistoryEntry> loadedEntries = _readEntries();
      emit(
        state.copyWith(
          entries: loadedEntries,
          loading: false,
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

  Future<void> addEntry(String message, {DateTime? timestamp}) async {
    try {
      _preferences ??= await SharedPreferences.getInstance();
      final DateTime time = timestamp ?? DateTime.now();
      final List<SyncHistoryEntry> updated = <SyncHistoryEntry>[
        SyncHistoryEntry(timestamp: time, message: message),
        ...state.entries,
      ];
      if (updated.length > _maxEntries) {
        updated.removeRange(_maxEntries, updated.length);
      }
      await _saveEntries(updated);
      emit(
        state.copyWith(
          entries: updated,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  List<SyncHistoryEntry> _readEntries() {
    final String? raw = _preferences?.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      return const <SyncHistoryEntry>[];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SyncHistoryEntry.fromJson)
          .toList();
    } catch (_) {
      return const <SyncHistoryEntry>[];
    }
  }

  Future<void> _saveEntries(List<SyncHistoryEntry> entries) async {
    final String raw = jsonEncode(
      entries.map((SyncHistoryEntry entry) => entry.toJson()).toList(),
    );
    await _preferences!.setString(_historyKey, raw);
  }
}
