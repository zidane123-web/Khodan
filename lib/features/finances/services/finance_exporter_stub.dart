import 'finance_exporter.dart';

class UnsupportedFinanceExporter implements FinanceExporter {
  @override
  Future<void> save(String filename, String csvContent) async {
    throw UnsupportedError('CSV export not supported on this platform.');
  }
}

FinanceExporter buildFinanceExporter() => UnsupportedFinanceExporter();
