import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiagnosticsEntry extends Equatable {
  const DiagnosticsEntry({
    required this.timestamp,
    required this.message,
    required this.level,
    required this.source,
    this.details,
  });

  final DateTime timestamp;
  final String message;
  final String level;
  final String source;
  final String? details;

  DiagnosticsEntry copyWith({
    DateTime? timestamp,
    String? message,
    String? level,
    String? source,
    String? details,
  }) {
    return DiagnosticsEntry(
      timestamp: timestamp ?? this.timestamp,
      message: message ?? this.message,
      level: level ?? this.level,
      source: source ?? this.source,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'level': level,
      'source': source,
      'details': details,
    };
  }

  factory DiagnosticsEntry.fromJson(Map<String, dynamic> json) {
    return DiagnosticsEntry(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      message: (json['message'] ?? '') as String,
      level: (json['level'] ?? 'info') as String,
      source: (json['source'] ?? 'system') as String,
      details: json['details'] as String?,
    );
  }

  String formatPlain() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String time = formatter.format(timestamp.toLocal());
    final StringBuffer buffer =
        StringBuffer('[$time][$level][$source] $message');
    if (details != null && details!.trim().isNotEmpty) {
      buffer.write('\n$details');
    }
    return buffer.toString();
  }

  @override
  List<Object?> get props => <Object?>[timestamp, message, level, source, details];
}

class DiagnosticsService {
  DiagnosticsService._();

  static final DiagnosticsService instance = DiagnosticsService._();

  static const String _entriesKey = 'diagnostics_entries_v1';
  static const String _detailedKey = 'diagnostics_detailed_logging_v1';
  static const int _maxEntries = 250;

  final ValueNotifier<List<DiagnosticsEntry>> _entriesNotifier =
      ValueNotifier<List<DiagnosticsEntry>>(const <DiagnosticsEntry>[]);

  SharedPreferences? _preferences;
  bool _initialized = false;
  bool _detailedLoggingEnabled = false;

  ValueListenable<List<DiagnosticsEntry>> get entriesListenable =>
      _entriesNotifier;

  List<DiagnosticsEntry> get entries => _entriesNotifier.value;

  bool get detailedLoggingEnabled => _detailedLoggingEnabled;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _preferences ??= await SharedPreferences.getInstance();
    final SharedPreferences prefs = _preferences!;
    final String? rawEntries = prefs.getString(_entriesKey);
    if (rawEntries != null && rawEntries.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawEntries) as List<dynamic>;
        final List<DiagnosticsEntry> restored = decoded
            .whereType<Map<String, dynamic>>()
            .map(DiagnosticsEntry.fromJson)
            .toList()
            .take(_maxEntries)
            .toList();
        _entriesNotifier.value = List<DiagnosticsEntry>.unmodifiable(restored);
      } catch (_) {
        _entriesNotifier.value = const <DiagnosticsEntry>[];
      }
    }
    _detailedLoggingEnabled = prefs.getBool(_detailedKey) ?? false;
    _initialized = true;
  }

  Future<void> logSync(String message, {DateTime? timestamp}) {
    return _addEntry(
      DiagnosticsEntry(
        timestamp: timestamp ?? DateTime.now(),
        message: message,
        level: 'info',
        source: 'sync',
      ),
    );
  }

  Future<void> logInfo(
    String message, {
    String source = 'app',
    String? details,
  }) {
    return _addEntry(
      DiagnosticsEntry(
        timestamp: DateTime.now(),
        message: message,
        level: 'info',
        source: source,
        details: details,
      ),
    );
  }

  Future<void> logWarning(
    String message, {
    String source = 'app',
    String? details,
  }) {
    return _addEntry(
      DiagnosticsEntry(
        timestamp: DateTime.now(),
        message: message,
        level: 'warning',
        source: source,
        details: details,
      ),
    );
  }

  Future<void> logError(
    String message, {
    String source = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) {
    final StringBuffer buffer = StringBuffer();
    if (error != null) {
      buffer.writeln('Erreur : $error');
    }
    if (stackTrace != null) {
      buffer.writeln(stackTrace.toString());
    }
    return _addEntry(
      DiagnosticsEntry(
        timestamp: DateTime.now(),
        message: message,
        level: 'error',
        source: source,
        details: buffer.isEmpty ? null : buffer.toString(),
      ),
    );
  }

  Future<void> logDebug(
    String message, {
    String source = 'debug',
    String? details,
  }) {
    if (!_detailedLoggingEnabled) {
      return Future<void>.value();
    }
    return _addEntry(
      DiagnosticsEntry(
        timestamp: DateTime.now(),
        message: message,
        level: 'debug',
        source: source,
        details: details,
      ),
    );
  }

  Future<void> setDetailedLogging(bool enabled) async {
    await initialize();
    _detailedLoggingEnabled = enabled;
    await _ensurePreferences();
    await _preferences!.setBool(_detailedKey, enabled);
    await logInfo(
      enabled
          ? 'Journalisation détaillée activée.'
          : 'Journalisation détaillée désactivée.',
      source: 'settings',
    );
  }

  Future<String> exportToFile({List<String> headerLines = const <String>[]}) async {
    if (kIsWeb) {
      throw UnsupportedError('L’export des journaux n’est pas disponible sur le web.');
    }
    final Directory directory = await getTemporaryDirectory();
    final DateTime now = DateTime.now();
    final String safeTimestamp =
        now.toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
    final String fileName = 'khodan-logs-$safeTimestamp.txt';
    final File file = File(p.join(directory.path, fileName));
    final StringBuffer buffer = StringBuffer();
    if (headerLines.isNotEmpty) {
      for (final String line in headerLines) {
        buffer.writeln('# $line');
      }
      buffer.writeln();
    }
    for (final DiagnosticsEntry entry in entries) {
      buffer.writeln(entry.formatPlain());
      buffer.writeln();
    }
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<void> clear() async {
    await _ensurePreferences();
    _entriesNotifier.value = const <DiagnosticsEntry>[];
    await _preferences!.remove(_entriesKey);
  }

  Future<void> _addEntry(DiagnosticsEntry entry) async {
    await initialize();
    final List<DiagnosticsEntry> updated = <DiagnosticsEntry>[
      entry,
      ..._entriesNotifier.value,
    ];
    if (updated.length > _maxEntries) {
      updated.removeRange(_maxEntries, updated.length);
    }
    _entriesNotifier.value = List<DiagnosticsEntry>.unmodifiable(updated);
    await _persist();
  }

  Future<void> _persist() async {
    await _ensurePreferences();
    final String payload = jsonEncode(
      _entriesNotifier.value
          .map((DiagnosticsEntry entry) => entry.toJson())
          .toList(),
    );
    await _preferences!.setString(_entriesKey, payload);
  }

  Future<void> _ensurePreferences() async {
    _preferences ??= await SharedPreferences.getInstance();
  }
}
