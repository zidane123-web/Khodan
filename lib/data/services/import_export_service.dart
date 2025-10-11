import 'dart:convert';
import 'dart:io';

/// Service utilitaire pour préparer les fichiers d import/export CSV liés à Supabase.
class ImportExportService {
  const ImportExportService();

  Future<List<Map<String, String>>> readCsvFile(File file) async {
    final lines = await file.readAsLines();
    if (lines.isEmpty) {
      return <Map<String, String>>[];
    }
    final headers = _splitCsvLine(lines.first);
    return lines
        .skip(1)
        .where((line) => line.trim().isNotEmpty)
        .map((line) {
          final values = _splitCsvLine(line);
          return <String, String>{
            for (var i = 0; i < headers.length; i++)
              headers[i]: i < values.length ? values[i] : '',
          };
        })
        .toList();
  }

  Future<void> writeCsvFile(File file, List<String> headers, List<List<String>> rows) async {
    final sink = file.openWrite();
    sink.writeln(headers.join(','));
    for (final row in rows) {
      sink.writeln(row.map(_escapeCsvValue).join(','));
    }
    await sink.close();
  }

  List<String> _splitCsvLine(String line) {
    return const LineSplitter()
        .convert(line)
        .expand((part) => part.split(','))
        .toList();
  }

  String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      final escaped = value.replaceAll('"', '""');
      return '""';
    }
    return value;
  }
}
