import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/report_models.dart';

class ReportsExportService {
  ReportsExportService();

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'fr',
    symbol: 'FCFA',
    decimalDigits: 0,
  );
  final NumberFormat _decimalFormat = NumberFormat('0.00', 'fr');
  final DateFormat _fileDateFormat = DateFormat('yyyyMMdd');
  final DateFormat _periodLabel = DateFormat('MMM yyyy', 'fr');

  Future<void> exportCsv({
    required ReportsTab tab,
    required ReportsBundle bundle,
    required DateTimeRange range,
  }) async {
    final List<List<String>> rows = _buildRows(tab, bundle);
    final String csv = const ListToCsvConverter(
      fieldDelimiter: ';',
      eol: '\r\n',
    ).convert(rows);

    final Uint8List bytes = Uint8List.fromList(utf8.encode(csv));
    await Share.shareXFiles(<XFile>[
      XFile.fromData(
        bytes,
        name: _buildFilename(tab, range, 'csv'),
        mimeType: 'text/csv',
      ),
    ], subject: 'Rapport Khodan ${_tabLabel(tab)}');
  }

  Future<void> exportExcel({
    required ReportsTab tab,
    required ReportsBundle bundle,
    required DateTimeRange range,
  }) async {
    final Excel excel = Excel.createExcel();
    final String defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
    final String sheetName = _tabLabel(tab);
    excel.rename(defaultSheet, sheetName);
    final Sheet sheet = excel[sheetName];

    for (final List<String> row in _buildRows(tab, bundle)) {
      sheet.appendRow(row);
    }

    final List<int>? encoded = excel.encode();
    if (encoded == null) {
      throw Exception('Impossible de generer le fichier Excel.');
    }
    await Share.shareXFiles(<XFile>[
      XFile.fromData(
        Uint8List.fromList(encoded),
        name: _buildFilename(tab, range, 'xlsx'),
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ),
    ], subject: 'Rapport Khodan ${_tabLabel(tab)}');
  }

  List<List<String>> _buildRows(ReportsTab tab, ReportsBundle bundle) {
    switch (tab) {
      case ReportsTab.reproduction:
        return _buildReproductionRows(bundle.reproduction);
      case ReportsTab.growth:
        return _buildGrowthRows(bundle.growth);
      case ReportsTab.finances:
        return _buildFinanceRows(bundle.finances, bundle.summary);
    }
  }

  List<List<String>> _buildReproductionRows(List<ReproductionReportRow> rows) {
    final List<List<String>> result = <List<String>>[
      <String>[
        'Periode',
        'Saillies',
        'Fertilite (%)',
        'Mises bas',
        'Kits nes vivants',
        'Kits sevres',
        'Taille portee',
        'Taux sevrage (%)',
        'Mortalite (%)',
        'Intervalle (j)',
        'Poids sevrage (kg)',
      ],
    ];
    for (final ReproductionReportRow row in rows) {
      result.add(<String>[
        _periodLabel.format(row.periodStart),
        row.totalMatings.toString(),
        _formatPercent(row.fertilityRate),
        row.kindlings.toString(),
        row.kitsBornAlive.toString(),
        row.kitsWeaned.toString(),
        _formatNullable(row.averageLitterSize),
        _formatPercent(row.weaningRate),
        _formatPercent(row.preweaningMortalityRate),
        _formatNullable(row.averageKindlingIntervalDays),
        _formatNullable(row.averageWeaningWeight),
      ]);
    }
    return result;
  }

  List<List<String>> _buildGrowthRows(List<GrowthReportRow> rows) {
    final List<List<String>> result = <List<String>>[
      <String>[
        'Periode',
        'Echantillons sevrage',
        'Age moyen (j)',
        'Poids sevrage (kg)',
        'Echantillons poids',
        'Poids moyen (kg)',
        'Gain quotidien (g)',
        'Kits sevres',
        'Retenus 12 sem',
        'Retention 12 sem (%)',
      ],
    ];
    for (final GrowthReportRow row in rows) {
      result.add(<String>[
        _periodLabel.format(row.periodStart),
        row.weaningSamples.toString(),
        _formatNullable(row.averageWeaningAgeDays),
        _formatNullable(row.averageWeaningWeightKg),
        row.weightSamples.toString(),
        _formatNullable(row.averageWeightKg),
        _formatGain(row.averageDailyGainKg),
        row.kitsWeaned.toString(),
        row.retained12Weeks.toString(),
        _formatPercent(row.twelveWeekRetentionRate),
      ]);
    }
    return result;
  }

  List<List<String>> _buildFinanceRows(
    List<FinanceReportRow> rows,
    FinanceSummary summary,
  ) {
    final List<List<String>> result = <List<String>>[
      <String>[
        'Periode',
        'Recettes',
        'Depenses',
        'Marge nette',
        'Cout alim/portee',
        'Revenu doe',
        'Femelles actives',
        'Kits sevres',
      ],
    ];
    for (final FinanceReportRow row in rows) {
      result.add(<String>[
        _periodLabel.format(row.periodStart),
        _currencyFormat.format(row.incomeTotal),
        _currencyFormat.format(row.expenseTotal),
        _currencyFormat.format(row.netMargin),
        row.feedCostPerWeaned == null
            ? '--'
            : _currencyFormat.format(row.feedCostPerWeaned),
        row.revenuePerActiveDoe == null
            ? '--'
            : _currencyFormat.format(row.revenuePerActiveDoe),
        row.femaleActive.toString(),
        row.kitsWeaned.toString(),
      ]);
    }
    result.add(const <String>[]);
    result.add(<String>[
      'Total periode',
      _currencyFormat.format(summary.incomeTotal),
      _currencyFormat.format(summary.expenseTotal),
      _currencyFormat.format(summary.netMargin),
      _currencyFormat.format(summary.feedExpense),
      _currencyFormat.format(summary.salesIncome),
      '--',
      '--',
    ]);
    return result;
  }

  String _formatPercent(double? value) {
    if (value == null) {
      return '--';
    }
    return _decimalFormat.format(value * 100);
  }

  String _formatNullable(double? value) {
    if (value == null) {
      return '--';
    }
    return _decimalFormat.format(value);
  }

  String _formatGain(double? value) {
    if (value == null) {
      return '--';
    }
    return _decimalFormat.format(value * 1000);
  }

  String _buildFilename(ReportsTab tab, DateTimeRange range, String extension) {
    final String prefix = _tabLabel(tab).toLowerCase().replaceAll(' ', '_');
    final String start = _fileDateFormat.format(range.start);
    final String end = _fileDateFormat.format(range.end);
    return 'rapports_${prefix}_${start}_$end.$extension';
  }

  String _tabLabel(ReportsTab tab) {
    switch (tab) {
      case ReportsTab.reproduction:
        return 'Reproduction';
      case ReportsTab.growth:
        return 'Croissance';
      case ReportsTab.finances:
        return 'Finances';
    }
  }
}
