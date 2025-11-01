import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

enum ReportsTab { reproduction, growth, finances }

class ReproductionReportRow extends Equatable {
  const ReproductionReportRow({
    required this.periodStart,
    required this.periodEnd,
    required this.totalMatings,
    required this.confirmedMatings,
    required this.kindlings,
    required this.kitsBornAlive,
    required this.kitsBornDead,
    required this.kitsWeaned,
    required this.fertilityRate,
    required this.kindlingSuccessRate,
    required this.averageLitterSize,
    required this.weaningRate,
    required this.preweaningMortalityRate,
    required this.averageKindlingIntervalDays,
    required this.averageWeaningWeight,
  });

  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalMatings;
  final int confirmedMatings;
  final int kindlings;
  final int kitsBornAlive;
  final int kitsBornDead;
  final int kitsWeaned;
  final double fertilityRate;
  final double kindlingSuccessRate;
  final double? averageLitterSize;
  final double? weaningRate;
  final double? preweaningMortalityRate;
  final double? averageKindlingIntervalDays;
  final double? averageWeaningWeight;

  factory ReproductionReportRow.fromJson(Map<String, dynamic> json) {
    return ReproductionReportRow(
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      totalMatings: (json['total_matings'] as num?)?.toInt() ?? 0,
      confirmedMatings: (json['confirmed_matings'] as num?)?.toInt() ?? 0,
      kindlings: (json['kindlings'] as num?)?.toInt() ?? 0,
      kitsBornAlive: (json['kits_born_alive'] as num?)?.toInt() ?? 0,
      kitsBornDead: (json['kits_born_dead'] as num?)?.toInt() ?? 0,
      kitsWeaned: (json['kits_weaned'] as num?)?.toInt() ?? 0,
      fertilityRate: _parseDouble(json['fertility_rate']),
      kindlingSuccessRate: _parseDouble(json['kindling_success_rate']),
      averageLitterSize: _parseNullable(json['average_litter_size']),
      weaningRate: _parseNullable(json['weaning_rate']),
      preweaningMortalityRate: _parseNullable(
        json['preweaning_mortality_rate'],
      ),
      averageKindlingIntervalDays: _parseNullable(
        json['average_kindling_interval_days'],
      ),
      averageWeaningWeight: _parseNullable(json['average_weaning_weight']),
    );
  }

  String get label {
    final DateFormat formatter = DateFormat('MMMM yyyy', 'fr');
    return formatter.format(periodStart);
  }

  @override
  List<Object?> get props => <Object?>[
    periodStart,
    periodEnd,
    totalMatings,
    confirmedMatings,
    kindlings,
    kitsBornAlive,
    kitsBornDead,
    kitsWeaned,
    fertilityRate,
    kindlingSuccessRate,
    averageLitterSize,
    weaningRate,
    preweaningMortalityRate,
    averageKindlingIntervalDays,
    averageWeaningWeight,
  ];
}

class GrowthReportRow extends Equatable {
  const GrowthReportRow({
    required this.periodStart,
    required this.periodEnd,
    required this.weaningSamples,
    required this.averageWeaningAgeDays,
    required this.averageWeaningWeightKg,
    required this.weightSamples,
    required this.averageWeightKg,
    required this.averageDailyGainKg,
    required this.kitsWeaned,
    required this.retained12Weeks,
    required this.twelveWeekRetentionRate,
  });

  final DateTime periodStart;
  final DateTime periodEnd;
  final int weaningSamples;
  final double? averageWeaningAgeDays;
  final double? averageWeaningWeightKg;
  final int weightSamples;
  final double? averageWeightKg;
  final double? averageDailyGainKg;
  final int kitsWeaned;
  final int retained12Weeks;
  final double? twelveWeekRetentionRate;

  factory GrowthReportRow.fromJson(Map<String, dynamic> json) {
    return GrowthReportRow(
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      weaningSamples: (json['weaning_samples'] as num?)?.toInt() ?? 0,
      averageWeaningAgeDays: _parseNullable(json['average_weaning_age_days']),
      averageWeaningWeightKg: _parseNullable(json['average_weaning_weight_kg']),
      weightSamples: (json['weight_samples'] as num?)?.toInt() ?? 0,
      averageWeightKg: _parseNullable(json['average_weight_kg']),
      averageDailyGainKg: _parseNullable(json['average_daily_gain_kg']),
      kitsWeaned: (json['kits_weaned'] as num?)?.toInt() ?? 0,
      retained12Weeks: (json['retained_12_weeks'] as num?)?.toInt() ?? 0,
      twelveWeekRetentionRate: _parseNullable(
        json['twelve_week_retention_rate'],
      ),
    );
  }

  String get label {
    final DateFormat formatter = DateFormat('MMMM yyyy', 'fr');
    return formatter.format(periodStart);
  }

  @override
  List<Object?> get props => <Object?>[
    periodStart,
    periodEnd,
    weaningSamples,
    averageWeaningAgeDays,
    averageWeaningWeightKg,
    weightSamples,
    averageWeightKg,
    averageDailyGainKg,
    kitsWeaned,
    retained12Weeks,
    twelveWeekRetentionRate,
  ];
}

class FinanceReportRow extends Equatable {
  const FinanceReportRow({
    required this.periodStart,
    required this.periodEnd,
    required this.incomeTotal,
    required this.expenseTotal,
    required this.neutralTotal,
    required this.feedExpense,
    required this.salesIncome,
    required this.netMargin,
    required this.kitsWeaned,
    required this.femaleActive,
    required this.feedCostPerWeaned,
    required this.revenuePerActiveDoe,
  });

  final DateTime periodStart;
  final DateTime periodEnd;
  final double incomeTotal;
  final double expenseTotal;
  final double neutralTotal;
  final double feedExpense;
  final double salesIncome;
  final double netMargin;
  final int kitsWeaned;
  final int femaleActive;
  final double? feedCostPerWeaned;
  final double? revenuePerActiveDoe;

  factory FinanceReportRow.fromJson(Map<String, dynamic> json) {
    return FinanceReportRow(
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      incomeTotal: _parseDouble(json['income_total']),
      expenseTotal: _parseDouble(json['expense_total']),
      neutralTotal: _parseDouble(json['neutral_total']),
      feedExpense: _parseDouble(json['feed_expense']),
      salesIncome: _parseDouble(json['sales_income']),
      netMargin: _parseDouble(json['net_margin']),
      kitsWeaned: (json['kits_weaned'] as num?)?.toInt() ?? 0,
      femaleActive: (json['female_active'] as num?)?.toInt() ?? 0,
      feedCostPerWeaned: _parseNullable(json['feed_cost_per_weaned']),
      revenuePerActiveDoe: _parseNullable(json['revenue_per_active_doe']),
    );
  }

  String get label {
    final DateFormat formatter = DateFormat('MMMM yyyy', 'fr');
    return formatter.format(periodStart);
  }

  @override
  List<Object?> get props => <Object?>[
    periodStart,
    periodEnd,
    incomeTotal,
    expenseTotal,
    neutralTotal,
    feedExpense,
    salesIncome,
    netMargin,
    kitsWeaned,
    femaleActive,
    feedCostPerWeaned,
    revenuePerActiveDoe,
  ];
}

class FinanceSummary extends Equatable {
  const FinanceSummary({
    required this.incomeTotal,
    required this.expenseTotal,
    required this.neutralTotal,
    required this.feedExpense,
    required this.salesIncome,
    required this.netMargin,
  });

  final double incomeTotal;
  final double expenseTotal;
  final double neutralTotal;
  final double feedExpense;
  final double salesIncome;
  final double netMargin;

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      incomeTotal: _parseDouble(json['income_total']),
      expenseTotal: _parseDouble(json['expense_total']),
      neutralTotal: _parseDouble(json['neutral_total']),
      feedExpense: _parseDouble(json['feed_expense']),
      salesIncome: _parseDouble(json['sales_income']),
      netMargin: _parseDouble(json['net_margin']),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    incomeTotal,
    expenseTotal,
    neutralTotal,
    feedExpense,
    salesIncome,
    netMargin,
  ];
}

class ReportsBundle extends Equatable {
  const ReportsBundle({
    required this.reproduction,
    required this.growth,
    required this.finances,
    required this.summary,
  });

  final List<ReproductionReportRow> reproduction;
  final List<GrowthReportRow> growth;
  final List<FinanceReportRow> finances;
  final FinanceSummary summary;

  bool get isEmpty =>
      reproduction.isEmpty && growth.isEmpty && finances.isEmpty;

  @override
  List<Object?> get props => <Object?>[reproduction, growth, finances, summary];
}

double _parseDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String && value.isNotEmpty) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

double? _parseNullable(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String && value.isNotEmpty) {
    return double.tryParse(value);
  }
  return null;
}
