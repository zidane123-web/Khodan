import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../domain/models/breeding_performance_stats.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.totalAnimals = 0,
    this.activeAnimals = 0,
    this.doesInGestation = 0,
    this.plannedBreedings = 0,
    this.activeLitters = 0,
    this.breedingSuccessRate,
    this.breedingEvaluatedCount = 0,
    this.todayTasks = const <String>[],
    this.upcomingTasks = const <String>[],
    this.performance = const BreedingPerformanceStats(),
    this.errorMessage,
  });

  final DashboardStatus status;
  final int totalAnimals;
  final int activeAnimals;
  final int doesInGestation;
  final int plannedBreedings;
  final int activeLitters;
  final double? breedingSuccessRate;
  final int breedingEvaluatedCount;
  final List<String> todayTasks;
  final List<String> upcomingTasks;
  final BreedingPerformanceStats performance;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    int? totalAnimals,
    int? activeAnimals,
    int? doesInGestation,
    int? plannedBreedings,
    int? activeLitters,
    double? breedingSuccessRate,
    bool clearBreedingSuccessRate = false,
    int? breedingEvaluatedCount,
    List<String>? todayTasks,
    List<String>? upcomingTasks,
    BreedingPerformanceStats? performance,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      totalAnimals: totalAnimals ?? this.totalAnimals,
      activeAnimals: activeAnimals ?? this.activeAnimals,
      doesInGestation: doesInGestation ?? this.doesInGestation,
      plannedBreedings: plannedBreedings ?? this.plannedBreedings,
      activeLitters: activeLitters ?? this.activeLitters,
      breedingSuccessRate: clearBreedingSuccessRate
          ? null
          : (breedingSuccessRate ?? this.breedingSuccessRate),
      breedingEvaluatedCount:
          breedingEvaluatedCount ?? this.breedingEvaluatedCount,
      todayTasks: todayTasks ?? this.todayTasks,
      upcomingTasks: upcomingTasks ?? this.upcomingTasks,
      performance: performance ?? this.performance,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        totalAnimals,
        activeAnimals,
        doesInGestation,
        plannedBreedings,
        activeLitters,
        breedingSuccessRate,
        breedingEvaluatedCount,
        todayTasks,
        upcomingTasks,
        performance,
        errorMessage,
      ];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._animalRepository, this._breedingRepository)
      : super(const DashboardState());

  final AnimalRepository _animalRepository;
  final BreedingRepository _breedingRepository;

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final List<Animal> animals = await _animalRepository.fetchAnimals();
      final List<BreedingRecord> records =
          await _breedingRepository.fetchBreedingRecords();
      final Map<String, Animal> animalsById = <String, Animal>{
        for (final Animal animal in animals) animal.id: animal,
      };

      final DateTime now = DateTime.now();
      final DateTime startOfToday =
          DateTime(now.year, now.month, now.day);

      final int activeAnimals = animals
          .where((Animal animal) =>
              animal.status.toLowerCase().contains('viv'))
          .length;

      final Set<String> gestatingDoeIds = <String>{};
      for (final BreedingRecord record in records) {
        final bool hasMatingOccurred = record.matingDate.isBefore(now);
        final bool alreadyKindled = record.kindlingDate != null;
        final bool confirmedNegative = record.palpationPositive == false;
        if (hasMatingOccurred && !alreadyKindled && !confirmedNegative) {
          gestatingDoeIds.add(record.doeId);
        }
      }

      final int plannedBreedings = records
          .where((BreedingRecord record) => record.matingDate.isAfter(now))
          .length;

      final int activeLitters = records
          .where((BreedingRecord record) {
            if (record.kindlingDate == null) {
              return false;
            }
            if (record.weaningDate == null) {
              return true;
            }
            return record.weaningDate!.isAfter(now);
          })
          .length;

      final Iterable<BreedingRecord> evaluatedRecords = records.where(
        (BreedingRecord record) => record.palpationPositive != null,
      );
      final int evaluatedCount = evaluatedRecords.length;
      final double? breedingSuccessRate = evaluatedCount == 0
          ? null
          : evaluatedRecords
                  .where(
                    (BreedingRecord record) => record.palpationPositive == true,
                  )
                  .length /
              evaluatedCount;

      final List<BreedingReminder> reminders =
          BreedingReminder.build(records);
      final _TasksBreakdown breakdown =
          _buildTasks(reminders, records, animalsById, startOfToday);

      final BreedingPerformanceStats performance =
          _buildPerformanceStats(records, animalsById);

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          totalAnimals: animals.length,
          activeAnimals: activeAnimals,
          doesInGestation: gestatingDoeIds.length,
          plannedBreedings: plannedBreedings,
          activeLitters: activeLitters,
          breedingSuccessRate: breedingSuccessRate,
          breedingEvaluatedCount: evaluatedCount,
          todayTasks: breakdown.today,
          upcomingTasks: breakdown.upcoming,
          performance: performance,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: error.toString(),
          clearBreedingSuccessRate: true,
        ),
      );
    }
  }

  _TasksBreakdown _buildTasks(
    List<BreedingReminder> reminders,
    List<BreedingRecord> records,
    Map<String, Animal> animalsById,
    DateTime startOfToday,
  ) {
    final List<_TaskEntry> todayEntries = <_TaskEntry>[];
    final List<_TaskEntry> upcomingEntries = <_TaskEntry>[];

    void addEntry(DateTime dueDate, String label) {
      final DateTime dateOnly =
          DateTime(dueDate.year, dueDate.month, dueDate.day);
      final int diffDays = dateOnly.difference(startOfToday).inDays;

      if (diffDays < 0) {
        final int overdueDays = -diffDays;
        todayEntries.add(
          _TaskEntry(
            dateOnly,
            '$label – en retard depuis $overdueDays j'
            ' (${_formatShortDate(dateOnly)})',
          ),
        );
      } else if (diffDays == 0) {
        todayEntries.add(
          _TaskEntry(dateOnly, '$label – aujourd\'hui'),
        );
      } else if (diffDays == 1) {
        upcomingEntries.add(
          _TaskEntry(dateOnly, '$label – demain'),
        );
      } else if (diffDays <= 7) {
        upcomingEntries.add(
          _TaskEntry(dateOnly, '$label – dans $diffDays jours'),
        );
      }
    }

    for (final BreedingReminder reminder in reminders) {
      final String label =
          '${_labelForTask(reminder.type)} · ${_animalLabel(animalsById[reminder.doeId], reminder.doeId)}';
      addEntry(reminder.dueDate, label);
    }

    for (final BreedingRecord record in records) {
      if (!record.matingDate.isAfter(startOfToday)) {
        continue;
      }
      final Animal? doe = animalsById[record.doeId];
      final Animal? buck = animalsById[record.buckId];
      final String pairLabel =
          '${_animalLabel(doe, record.doeId)} × ${_animalLabel(buck, record.buckId)}';
      addEntry(
        record.matingDate,
        'Saillie planifiée · $pairLabel',
      );
    }

    todayEntries.sort((a, b) => a.date.compareTo(b.date));
    upcomingEntries.sort((a, b) => a.date.compareTo(b.date));

    return _TasksBreakdown(
      today: todayEntries.map((task) => task.label).toList(),
      upcoming: upcomingEntries.map((task) => task.label).toList(),
    );
  }

  BreedingPerformanceStats _buildPerformanceStats(
    List<BreedingRecord> records,
    Map<String, Animal> animalsById,
  ) {
    final Iterable<BreedingRecord> litters = records.where(
      (BreedingRecord record) => record.kindlingDate != null,
    );

    int totalKitsBornAlive = 0;
    int totalKitsWeaned = 0;
    final Map<String, int> weanedByDoe = <String, int>{};
    final Map<String, int> weanedByBuck = <String, int>{};

    for (final BreedingRecord record in litters) {
      totalKitsBornAlive += record.kitsBornAlive ?? 0;
      totalKitsWeaned += record.kitsWeaned ?? 0;

      if (record.kitsWeaned != null) {
        weanedByDoe.update(
          record.doeId,
          (int value) => value + record.kitsWeaned!,
          ifAbsent: () => record.kitsWeaned!,
        );
        weanedByBuck.update(
          record.buckId,
          (int value) => value + record.kitsWeaned!,
          ifAbsent: () => record.kitsWeaned!,
        );
      }
    }

    final int littersCount = litters.length;
    final double? avgBornAlive = littersCount == 0
        ? null
        : totalKitsBornAlive / littersCount;
    final double? avgWeaned = littersCount == 0
        ? null
        : totalKitsWeaned / littersCount;

    String? topDoeLabel;
    if (weanedByDoe.isNotEmpty) {
      final MapEntry<String, int> topDoe = weanedByDoe.entries.reduce(
        (MapEntry<String, int> a, MapEntry<String, int> b) =>
            a.value >= b.value ? a : b,
      );
      final Animal? doe = animalsById[topDoe.key];
      topDoeLabel =
          '${_animalLabel(doe, topDoe.key)} (${topDoe.value} sevrés)';
    }

    String? topBuckLabel;
    if (weanedByBuck.isNotEmpty) {
      final MapEntry<String, int> topBuck = weanedByBuck.entries.reduce(
        (MapEntry<String, int> a, MapEntry<String, int> b) =>
            a.value >= b.value ? a : b,
      );
      final Animal? buck = animalsById[topBuck.key];
      topBuckLabel =
          '${_animalLabel(buck, topBuck.key)} (${topBuck.value} sevrés)';
    }

    return BreedingPerformanceStats(
      totalLitters: littersCount,
      averageKitsBornAlive: avgBornAlive,
      averageKitsWeaned: avgWeaned,
      totalKitsWeaned: totalKitsWeaned,
      topDoeLabel: topDoeLabel,
      topBuckLabel: topBuckLabel,
    );
  }

  String _labelForTask(BreedingTaskType type) {
    switch (type) {
      case BreedingTaskType.palpation:
        return 'Palpation';
      case BreedingTaskType.kindling:
        return 'Mise-bas';
      case BreedingTaskType.weaning:
        return 'Sevrage';
    }
  }

  String _animalLabel(Animal? animal, String fallbackId) {
    if (animal == null) {
      return fallbackId;
    }
    if (animal.name != null && animal.name!.isNotEmpty) {
      return '${animal.tagId} · ${animal.name}';
    }
    return animal.tagId;
  }

  String _formatShortDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}

class _TaskEntry {
  _TaskEntry(this.date, this.label);

  final DateTime date;
  final String label;
}

class _TasksBreakdown {
  const _TasksBreakdown({required this.today, required this.upcoming});

  final List<String> today;
  final List<String> upcoming;
}