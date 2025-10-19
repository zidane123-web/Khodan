import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../presentation/cubit/report_cubit.dart';
import '../../../data/repositories/food_inventory_repository.dart';

class ReportExportService {
  ReportExportService();

  final DateFormat _dateFormat = DateFormat.yMMMMd('fr');
  final NumberFormat _numberFormat = NumberFormat.decimalPattern('fr');
  final NumberFormat _percentFormat = NumberFormat.percentPattern('fr');

  Future<void> sharePdf({
    required ReportState state,
    Uint8List? fertilityChart,
    Uint8List? litterChart,
  }) async {
    final Uint8List bytes = await buildPdf(
      state: state,
      fertilityChart: fertilityChart,
      litterChart: litterChart,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: _buildFilename(prefix: 'rapport', extension: 'pdf', state: state),
    );
  }

  Future<Uint8List> buildPdf({
    required ReportState state,
    Uint8List? fertilityChart,
    Uint8List? litterChart,
  }) async {
    final pw.Document pdf = pw.Document();
    final ReportViewData data = state.viewData;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                pw.Text(
                  'Khodan - Rapport de suivi',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  _dateFormat.format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Periode: ${_dateFormat.format(data.range.start)} - '
              '${_dateFormat.format(data.range.end)}',
            ),
            if (state.selectedLot != null)
              pw.Text('Lot: ${state.selectedLot}'),
            if (state.selectedLocation != null)
              pw.Text('Localisation: ${state.selectedLocation}'),
            pw.SizedBox(height: 20),
            if (fertilityChart != null) ...<pw.Widget>[
              pw.Text('Evolution du taux de fertilite',
                  style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),
              pw.Image(pw.MemoryImage(fertilityChart), height: 180),
              pw.SizedBox(height: 16),
            ],
            if (litterChart != null) ...<pw.Widget>[
              pw.Text('Taille moyenne des portees',
                  style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),
              pw.Image(pw.MemoryImage(litterChart), height: 180),
              pw.SizedBox(height: 16),
            ],
            pw.Text('Indicateurs mensuels', style: _sectionStyle),
            pw.SizedBox(height: 8),
            _buildMonthlyMetricsTable(data.monthlyMetrics),
            pw.SizedBox(height: 20),
            pw.Text('Top reproducteurs', style: _sectionStyle),
            pw.SizedBox(height: 8),
            _buildBreederTable(data.topPerformances),
            pw.SizedBox(height: 20),
            pw.Text('Evenements recenses', style: _sectionStyle),
            pw.SizedBox(height: 8),
            _buildEventSummary(data.eventCountsByType),
            pw.SizedBox(height: 20),
            if (data.inventorySummary != null) ...<pw.Widget>[
              pw.Text('Inventaire aliments', style: _sectionStyle),
              pw.SizedBox(height: 8),
              _buildInventorySummary(data),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<void> shareCsv({required ReportState state}) async {
    final Uint8List bytes = buildCsv(state: state);
    final String filename =
        _buildFilename(prefix: 'rapport', extension: 'csv', state: state);
    await Share.shareXFiles(
      <XFile>[
        XFile.fromData(
          bytes,
          name: filename,
          mimeType: 'text/csv',
        ),
      ],
      subject: 'Rapport Khodan',
      text:
          'Export CSV du rapport Khodan pour la periode ${_dateFormat.format(state.viewData.range.start)} - ${_dateFormat.format(state.viewData.range.end)}.',
    );
  }

  Uint8List buildCsv({required ReportState state}) {
    final ReportViewData data = state.viewData;
    final List<List<dynamic>> rows = <List<dynamic>>[
      <String>[
        'Periode',
        _dateFormat.format(data.range.start),
        _dateFormat.format(data.range.end),
      ],
      <String>['Lot', state.selectedLot ?? 'Tous'],
      <String>['Localisation', state.selectedLocation ?? 'Toutes'],
      <String>[],
      <String>['Mois', 'Taux fertilite', 'Portee moyenne', 'Sevres moyens'],
      for (final MonthlyMetric metric in data.monthlyMetrics)
        <String>[
          _dateFormat.format(metric.month),
          _percentFormat.format(metric.successRate),
          metric.averageBorn == null
              ? '-'
              : metric.averageBorn!.toStringAsFixed(1),
          metric.averageWeaned == null
              ? '-'
              : metric.averageWeaned!.toStringAsFixed(1),
        ],
      <String>[],
      <String>['Reproducteur', 'Saillies', 'Taux succes', 'Sevres'],
      for (final BreederPerformance perf in data.topPerformances)
        <String>[
          perf.animal?.tagId ?? perf.animalId,
          perf.totalMatings.toString(),
          _percentFormat.format(perf.successRate),
          perf.totalWeaned.toString(),
        ],
    ];

    final String csv = const ListToCsvConverter().convert(rows);
    return Uint8List.fromList(utf8.encode(csv));
  }

  pw.Widget _buildMonthlyMetricsTable(List<MonthlyMetric> metrics) {
    if (metrics.isEmpty) {
      return pw.Text('Aucune donnee disponible.');
    }
    return pw.TableHelper.fromTextArray(
      headers: <String>[
        'Mois',
        'Taux',
        'Portee',
        'Sevres',
      ],
      data: <List<String>>[
        for (final MonthlyMetric metric in metrics)
          <String>[
            _dateFormat.format(metric.month),
            _percentFormat.format(metric.successRate),
            metric.averageBorn == null
                ? '-'
                : metric.averageBorn!.toStringAsFixed(1),
            metric.averageWeaned == null
                ? '-'
                : metric.averageWeaned!.toStringAsFixed(1),
          ],
      ],
      border: pw.TableBorder.all(width: 0.3),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerStyle: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: <int, pw.Alignment>{
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildBreederTable(List<BreederPerformance> performances) {
    if (performances.isEmpty) {
      return pw.Text('Aucun reproducteur pour cette periode.');
    }
    return pw.TableHelper.fromTextArray(
      headers: <String>[
        'Reproducteur',
        'Saillies',
        'Taux succes',
        'Sevres',
      ],
      data: <List<String>>[
        for (final BreederPerformance perf in performances)
          <String>[
            perf.animal?.tagId ?? perf.animalId,
            perf.totalMatings.toString(),
            _percentFormat.format(perf.successRate),
            perf.totalWeaned.toString(),
          ],
      ],
      border: pw.TableBorder.all(width: 0.3),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerStyle: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: <int, pw.Alignment>{
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildEventSummary(Map<String, int> counts) {
    if (counts.isEmpty) {
      return pw.Text('Aucun evenement enregistre.');
    }
    final List<MapEntry<String, int>> entries = counts.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) {
        return b.value.compareTo(a.value);
      });
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (final MapEntry<String, int> entry in entries)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Text(
              '${_formatEventName(entry.key)} : ${entry.value}',
            ),
          ),
      ],
    );
  }

  pw.Widget _buildInventorySummary(ReportViewData data) {
    final InventorySummary summary = data.inventorySummary!;
    return pw.TableHelper.fromTextArray(
      headers: <String>['Indicateur', 'Valeur'],
      data: <List<String>>[
        <String>[
          'Quantite totale (kg)',
          _numberFormat.format(summary.totalQuantityKg),
        ],
        <String>[
          'Entrees',
          _numberFormat.format(summary.entriesCount),
        ],
        <String>[
          'Valeur estimee',
          _numberFormat.format(summary.totalCost),
        ],
        <String>[
          'Conso mensuelle (kg)',
          _numberFormat.format(summary.estimatedMonthlyConsumptionKg),
        ],
      ],
      border: pw.TableBorder.all(width: 0.3),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerStyle: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: const <int, pw.Alignment>{
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
      },
    );
  }

  pw.TextStyle get _sectionStyle => pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
      );

  String _formatEventName(String raw) {
    if (raw.isEmpty) {
      return 'Autre';
    }
    final String spaced = raw.replaceAll('_', ' ');
    return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }

  String _buildFilename({
    required String prefix,
    required String extension,
    required ReportState state,
  }) {
    final String start = DateFormat('yyyyMMdd').format(state.viewData.range.start);
    final String end = DateFormat('yyyyMMdd').format(state.viewData.range.end);
    return '${prefix}_$start-$end.$extension';
  }
}
