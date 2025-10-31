import 'dart:convert';

import 'package:csv/csv.dart';

class BreederImportPreview {
  BreederImportPreview({
    required this.headers,
    required this.rows,
    required this.errors,
    this.sourceName,
  });

  final List<String> headers;
  final List<BreederImportRow> rows;
  final List<String> errors;
  final String? sourceName;

  int get validCount => rows.where((BreederImportRow row) => row.isValid).length;
  int get invalidCount => rows.length - validCount;
}

class BreederImportRow {
  BreederImportRow({
    required this.index,
    required this.values,
    required this.issues,
  });

  final int index;
  final Map<String, String> values;
  final List<String> issues;

  bool get isValid => issues.isEmpty;
}

class BreederImportService {
  BreederImportPreview preview(String source, {String? sourceName}) {
    final CsvToListConverter converter = CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    );
    final List<List<dynamic>> rows = converter.convert(source);
    if (rows.isEmpty) {
      return BreederImportPreview(
        headers: <String>[],
        rows: <BreederImportRow>[],
        errors: <String>['Le fichier est vide.'],
        sourceName: sourceName,
      );
    }

    final List<dynamic> headerRow = rows.first;
    final Map<int, String> columnMap = <int, String>{};
    final List<String> headers = <String>[];
    final List<String> errors = <String>[];

    for (int i = 0; i < headerRow.length; i++) {
      final String raw = '${headerRow[i]}'.trim();
      if (raw.isEmpty) {
        continue;
      }
      final String normalized = _normalizeHeader(raw);
      if (normalized.isEmpty) {
        continue;
      }
      if (columnMap.containsValue(normalized)) {
        errors.add('Colonne dupliquee detectee: "$raw"');
      }
      columnMap[i] = normalized;
      headers.add(normalized);
    }

    final List<String> missingColumns = _requiredColumns
        .where((String column) => !headers.contains(column))
        .toList();
    if (missingColumns.isNotEmpty) {
      errors.add('Colonnes obligatoires manquantes: ${missingColumns.join(', ')}');
    }

    final List<BreederImportRow> parsedRows = <BreederImportRow>[];
    for (int i = 1; i < rows.length; i++) {
      final List<dynamic> rawRow = rows[i];
      final Map<String, String> values = <String, String>{};
      final List<String> issues = <String>[];

      for (final MapEntry<int, String> entry in columnMap.entries) {
        final int index = entry.key;
        final String column = entry.value;
        final String value = index < rawRow.length
            ? '${rawRow[index]}'.trim()
            : '';
        values[column] = value;
      }

      for (final String required in _requiredColumns) {
        if ((values[required] ?? '').isEmpty) {
          issues.add('Champ obligatoire manquant: $required');
        }
      }

      final String? sex = values['sex'];
      if (sex != null && sex.isNotEmpty) {
        final String normalized = sex.toLowerCase();
        if (normalized != 'femelle' && normalized != 'male') {
          issues.add('Sexe invalide: "$sex"');
        }
      }

      final String? status = values['status'];
      if (status != null && status.isNotEmpty) {
        final String normalized = status.toLowerCase();
        if (!_acceptedStatuses.contains(normalized)) {
          issues.add('Statut invalide: "$status"');
        }
      }

      for (final String column in <String>['birth_date', 'entry_date', 'first_breeding_date']) {
        final String raw = values[column] ?? '';
        if (raw.isEmpty) {
          continue;
        }
        if (_parseDate(raw) == null) {
          issues.add('Date invalide ($column): "$raw"');
        }
      }

      parsedRows.add(
        BreederImportRow(
          index: i + 1,
          values: values,
          issues: issues,
        ),
      );
    }

    return BreederImportPreview(
      headers: headers,
      rows: parsedRows,
      errors: errors,
      sourceName: sourceName,
    );
  }

  BreederImportPreview previewFromBytes(List<int> bytes, {String? sourceName}) {
    final String content = utf8.decode(bytes, allowMalformed: true);
    return preview(content, sourceName: sourceName);
  }

  static const List<String> _requiredColumns = <String>[
    'tag_id',
    'sex',
    'status',
    'category',
    'birth_date',
    'entry_date',
  ];

  static const Map<String, String> _aliases = <String, String>{
    'tatouage': 'tag_id',
    'identifiant': 'tag_id',
    'tag': 'tag_id',
    'name': 'name',
    'nom': 'name',
    'sexe': 'sex',
    'statut': 'status',
    'race': 'breed',
    'categorie': 'category',
    'date_naissance': 'birth_date',
    'naissance': 'birth_date',
    'date_entree': 'entry_date',
    'entree': 'entry_date',
    'premiere_saillie': 'first_breeding_date',
    'origine': 'origin',
    'cage': 'cage',
    'notes': 'notes',
  };

  static final Set<String> _acceptedStatuses = <String>{
    'actif',
    'repos',
    'archive',
    'vendu',
  };

  static String _normalizeHeader(String raw) {
    final String lower = raw.trim().toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_');
    if (_aliases.containsKey(lower)) {
      return _aliases[lower]!;
    }
    return lower;
  }

  DateTime? _parseDate(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    DateTime? parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return parsed;
    }
    final RegExp european = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})');
    final Match? match = european.firstMatch(trimmed);
    if (match != null) {
      final int day = int.tryParse(match.group(1) ?? '') ?? 0;
      final int month = int.tryParse(match.group(2) ?? '') ?? 0;
      final int year = int.tryParse(match.group(3) ?? '') ?? 0;
      if (day > 0 && month > 0 && year > 0) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }
}
