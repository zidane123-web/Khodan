import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/models/dashboard_kpi_row.dart';
import 'package:khodan/data/models/dashboard_snapshot.dart';
import 'package:khodan/data/models/dashboard_preferences.dart';
import 'package:khodan/data/repositories/dashboard_repository.dart';
import 'package:khodan/data/repositories/food_inventory_repository.dart';
import 'package:khodan/features/dashboard/domain/models/breeding_performance_stats.dart';
import 'package:khodan/features/dashboard/presentation/cubit/dashboard_cubit.dart';

import '../../helpers/offline_remote_stubs.dart';

class _SnapshotDashboardRepository implements DashboardRepository {
  _SnapshotDashboardRepository({
    required this.snapshot,
    required this.kpiRows,
  });

  final DashboardSnapshot snapshot;
  final List<DashboardKpiRow> kpiRows;

  @override
  Future<DashboardSnapshot?> fetchSnapshot({
    DateTime? periodStart,
    DateTime? periodEnd,
  }) async {
    return snapshot;
  }

  @override
  Future<List<DashboardKpiRow>> fetchKpis({
    DateTime? since,
    List<int>? speciesIds,
    int limit = 12,
  }) async {
    return kpiRows;
  }

  @override
  Future<DashboardPreferences?> loadPreferences(String profileId) async {
    return null;
  }

  @override
  Future<void> savePreferences(DashboardPreferences preferences) async {}
}

void main() {
  test(
    'DashboardCubit uses snapshot aggregates when backend data is available',
    () async {
      final DateTime today = DateTime(2025, 10, 20);
      final DashboardSnapshot snapshot = DashboardSnapshot(
        totalAnimals: 12,
        activeAnimals: 10,
        doesInGestation: 4,
        plannedBreedings: 3,
        activeLitters: 2,
        breedingEvaluatedCount: 6,
        breedingSuccessRate: 0.5,
        todayTasks: <DashboardSnapshotTask>[
          DashboardSnapshotTask(
            title: 'Vaccin lapereaux',
            contextLabel: 'Portee B12',
            dueDate: today,
            kind: 'health_follow_up',
            relativeLabel: 'Aujourd\'hui',
            isOverdue: false,
          ),
        ],
        upcomingTasks: <DashboardSnapshotTask>[
          DashboardSnapshotTask(
            title: 'Saillie planifiee',
            contextLabel: 'F01 x M03',
            dueDate: today.add(const Duration(days: 2)),
            kind: 'mating',
            relativeLabel: 'Dans 2 jours',
            isOverdue: false,
          ),
        ],
        alerts: <DashboardSnapshotAlert>[
          DashboardSnapshotAlert(
            title: 'Manque de vitamines',
            message: 'Verifier le lot #22',
            timestamp: today.subtract(const Duration(hours: 2)),
            type: 'warning',
          ),
        ],
        healthAlerts: <DashboardSnapshotAlert>[
          DashboardSnapshotAlert(
            title: 'Controle temperature',
            message: 'Colonie 3',
            timestamp: today.add(const Duration(hours: 5)),
            type: 'info',
          ),
        ],
        calendarEvents: <DashboardSnapshotCalendarEvent>[
          DashboardSnapshotCalendarEvent(
            date: today.add(const Duration(days: 1)),
            title: 'Palpation F01',
            category: 'task_palpation',
            subtitle: 'F01',
          ),
        ],
        kpiFilters: <String, DashboardSnapshotFilter>{
          'totalAnimals': const DashboardSnapshotFilter(
            label: 'Tous les animaux',
            includeIds: <String>{'a1', 'a2'},
          ),
        },
        inventorySummary: const InventorySummary(
          totalQuantityKg: 120,
          totalCost: 340,
          entriesCount: 8,
          estimatedMonthlyConsumptionKg: 45,
        ),
        performance: const BreedingPerformanceStats(
          totalLitters: 5,
          averageKitsBornAlive: 7.4,
          averageKitsWeaned: 6.2,
          totalKitsWeaned: 31,
          topDoeLabel: 'Fiona',
          topBuckLabel: 'Jasper',
        ),
        kpiRows: <DashboardKpiRow>[
          DashboardKpiRow(
            profileId: 'profile-1',
            speciesId: 1,
            speciesName: 'Lapin',
            periodStart: today.subtract(const Duration(days: 30)),
            periodEnd: today,
            totalLitters: 5,
            averageKitsBornAlive: 7.4,
            averageKitsWeaned: 6.2,
            totalKitsWeaned: 31,
            topDoeLabel: 'Fiona',
            topBuckLabel: 'Jasper',
          ),
        ],
      );

      final _SnapshotDashboardRepository dashboardRepository =
          _SnapshotDashboardRepository(snapshot: snapshot, kpiRows: snapshot.kpiRows!);
      final FoodInventoryRepository inventoryRepository =
          InMemoryFoodInventoryRepository();

      final DashboardCubit cubit = DashboardCubit(
        RecordingAnimalRepository(),
        RecordingBreedingRepository(),
        RecordingEventRepository(),
        dashboardRepository,
        inventoryRepository,
        profileId: 'profile-1',
      );
      addTearDown(cubit.close);

      await cubit.loadDashboard();
      final DashboardState state = cubit.state;

      expect(state.status, DashboardStatus.success);
      expect(state.totalAnimals, 12);
      expect(state.activeAnimals, 10);
      expect(state.doesInGestation, 4);
      expect(state.plannedBreedings, 3);
      expect(state.activeLitters, 2);
      expect(state.breedingSuccessRate, 0.5);
      expect(state.breedingEvaluatedCount, 6);
      expect(state.performance.totalLitters, 5);
      expect(state.performance.topDoeLabel, 'Fiona');
      expect(state.todayTasks, hasLength(1));
      expect(state.todayTasks.first.title, 'Vaccin lapereaux');
      expect(state.upcomingTasks.first.kind, DashboardTaskKind.mating);
      expect(state.alerts.first.type, DashboardAlertType.warning);
      expect(state.healthAlerts.first.title, 'Controle temperature');
      expect(state.calendarEvents.first.category,
          DashboardCalendarCategory.taskPalpation);
      expect(state.inventorySummary?.totalQuantityKg, 120);
    },
  );
}
