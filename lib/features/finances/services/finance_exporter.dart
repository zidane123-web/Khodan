import 'finance_exporter_stub.dart'
    if (dart.library.io) 'finance_exporter_io.dart'
    if (dart.library.html) 'finance_exporter_web.dart' as impl;

abstract class FinanceExporter {
  Future<void> save(String filename, String csvContent);
}

FinanceExporter createFinanceExporter() => impl.buildFinanceExporter();
