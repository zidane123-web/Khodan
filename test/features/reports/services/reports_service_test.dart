import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/features/reports/models/report_models.dart';
import 'package:khodan/features/reports/services/reports_service.dart';

import '../../../utils/fake_api_executor.dart';

void main() {
  group('ReportsService', () {
    late ReportsService service;
    late FakeApiExecutor api;

    setUp(() {
      api = FakeApiExecutor(
        responses: <String, dynamic>{
          'reports.load.reproduction': <Map<String, dynamic>>[
            <String, dynamic>{
              'period_start': '2025-03-01',
              'period_end': '2025-03-31',
              'total_matings': 10,
              'confirmed_matings': 8,
              'kindlings': 7,
              'kits_born_alive': 56,
              'kits_born_dead': 2,
              'kits_weaned': 48,
              'fertility_rate': 0.8,
              'kindling_success_rate': 0.75,
              'average_litter_size': 8.0,
              'weaning_rate': 0.857,
              'preweaning_mortality_rate': 0.142,
              'average_kindling_interval_days': 32.0,
              'average_weaning_weight': 1.9,
            },
          ],
          'reports.load.growth': <Map<String, dynamic>>[
            <String, dynamic>{
              'period_start': '2025-03-01',
              'period_end': '2025-03-31',
              'weaning_samples': 5,
              'average_weaning_age_days': 31.0,
              'average_weaning_weight_kg': 1.9,
              'weight_samples': 12,
              'average_weight_kg': 2.4,
              'average_daily_gain_kg': 0.035,
              'kits_weaned': 48,
              'retained_12_weeks': 42,
              'twelve_week_retention_rate': 0.875,
            },
          ],
          'reports.load.finances': <Map<String, dynamic>>[
            <String, dynamic>{
              'period_start': '2025-03-01',
              'period_end': '2025-03-31',
              'income_total': 385000,
              'expense_total': 242000,
              'neutral_total': 0,
              'feed_expense': 140000,
              'sales_income': 285000,
              'net_margin': 143000,
              'kits_weaned': 48,
              'female_active': 22,
              'feed_cost_per_weaned': 2916.6,
              'revenue_per_active_doe': 12954.5,
            },
          ],
          'reports.load.financeSummary': <Map<String, dynamic>>[
            <String, dynamic>{
              'income_total': 385000,
              'expense_total': 242000,
              'neutral_total': 0,
              'feed_expense': 140000,
              'sales_income': 285000,
              'net_margin': 143000,
            },
          ],
        },
      );
      service = ReportsService(apiClient: api);
    });

    test('returns parsed bundle with metrics', () async {
      final ReportsBundle bundle = await service.load(
        profileId: 'profile-1',
        range: DateTimeRange(
          start: DateTime(2025, 3, 1),
          end: DateTime(2025, 3, 31),
        ),
      );

      expect(bundle.reproduction, hasLength(1));
      expect(bundle.growth, hasLength(1));
      expect(bundle.finances, hasLength(1));

      final ReproductionReportRow reproduction = bundle.reproduction.first;
      expect(reproduction.fertilityRate, closeTo(0.8, 0.001));
      expect(reproduction.kitsWeaned, 48);

      final GrowthReportRow growth = bundle.growth.first;
      expect(growth.averageDailyGainKg, closeTo(0.035, 0.0001));
      expect(growth.retained12Weeks, 42);

      final FinanceReportRow finance = bundle.finances.first;
      expect(finance.netMargin, 143000);
      expect(finance.feedCostPerWeaned, isNotNull);

      expect(bundle.summary.salesIncome, 285000);
    });
  });
}
