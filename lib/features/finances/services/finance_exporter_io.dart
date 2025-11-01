import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'finance_exporter.dart';

class IoFinanceExporter implements FinanceExporter {
  @override
  Future<void> save(String filename, String csvContent) async {
    Directory? targetDir;
    try {
      targetDir = await getDownloadsDirectory();
    } catch (_) {
      targetDir = null;
    }
    targetDir ??= await getApplicationDocumentsDirectory();
    final File file = File(p.join(targetDir.path, filename));
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(csvContent, flush: true);
  }
}

FinanceExporter buildFinanceExporter() => IoFinanceExporter();
