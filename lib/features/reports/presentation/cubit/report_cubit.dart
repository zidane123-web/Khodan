import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../data/models/event.dart';
import '../../../../data/repositories/food_inventory_repository.dart';
import '../../../../data/services/reporting_service.dart';

enum ReportStatus { initial, loading, success, failure }

enum SexFilterOption { all, female, male }

enum ReportPeriod { threeMonths, sixMonths, twelveMonths, custom }

extension ReportPeriodDuration on ReportPeriod {
  Duration? get duration {
    switch (this) {
      case ReportPeriod.threeMonths:
        return const Duration(days: 90);
      case ReportPeriod.sixMonths:
        return const Duration(days: 182);
      case ReportPeriod.twelveMonths:
        return const Duration(days: 365);
      case ReportPeriod.custom:
        return null;
    }
  }

  String get label {
    switch (this) {
      case ReportPeriod.threeMonths:
        return '3 mois';
      case ReportPeriod.sixMonths:
        return '6 mois';
      case ReportPeriod.twelveMonths:
        return '12 mois';
      case ReportPeriod.custom:
        return 'Periode libre';
    }
  }
}

class ReportState extends Equatable {
  ReportState({
    this.status = ReportStatus.initial,
    this.dataset,
    this.period = ReportPeriod.sixMonths,
    this.customRange,
    this.sexFilter = SexFilterOption.all,
    this.selectedBreederId,
    this.selectedLot,
    this.selectedLocation,
    ReportViewData? viewData,
    this.errorMessage,
  }) : viewData = viewData ?? ReportViewData.empty();

  final ReportStatus status;
  final ReportDataset? dataset;
  final ReportPeriod period;
  final DateTimeRange? customRange;
  final SexFilterOption sexFilter;
  final String? selectedBreederId;
  final String? selectedLot;
  final String? selectedLocation;
  final ReportViewData viewData;
  final String? errorMessage;

  bool get canExport =>
      status == ReportStatus.success && viewData.filteredRecords.isNotEmpty;

  ReportState copyWith({
    ReportStatus? status,
    ReportDataset? dataset,
    bool clearDataset = false,
    ReportPeriod? period,
    DateTimeRange? customRange,
    bool clearCustomRange = false,
    SexFilterOption? sexFilter,
    String? selectedBreederId,
    bool clearBreeder = false,
    String? selectedLot,
    bool clearLot = false,
    String? selectedLocation,
    bool clearLocation = false,
    ReportViewData? viewData,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportState(
      status: status ?? this.status,
      dataset: clearDataset ? null : dataset ?? this.dataset,
      period: period ?? this.period,
      customRange: clearCustomRange
          ? null
          : customRange ?? this.customRange,
      sexFilter: sexFilter ?? this.sexFilter,
      selectedBreederId:
          clearBreeder ? null : selectedBreederId ?? this.selectedBreederId,
      selectedLot: clearLot ? null : selectedLot ?? this.selectedLot,
      selectedLocation:
          clearLocation ? null : selectedLocation ?? this.selectedLocation,
      viewData: viewData ?? this.viewData,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        dataset,
        period,
        customRange,
        sexFilter,
        selectedBreederId,
        selectedLot,
        selectedLocation,
        viewData,
        errorMessage,
      ];
}

class ReportViewData extends Equatable {
  const ReportViewData({
    required this.range,
    required this.filteredRecords,
    required this.filteredAnimals,
    required this.animalsById,
    required this.monthlyMetrics,
    required this.topPerformances,
    required this.eventCountsByType,
    required this.inventorySummary,
    required this.availableBreeders,
    required this.availableLots,
    required this.availableLocations,
  });

  factory ReportViewData.empty() {
    final DateTime fallback = DateTime(2000, 1, 1);
    return ReportViewData(
      range: DateTimeRange(start: fallback, end: fallback),
      filteredRecords: const <BreedingRecord>[],
      filteredAnimals: const <Animal>[],
      animalsById: const <String, Animal>{},
      monthlyMetrics: const <MonthlyMetric>[],
      topPerformances: const <BreederPerformance>[],
      eventCountsByType: const <String, int>{},
      inventorySummary: null,
      availableBreeders: const <Animal>[],
      availableLots: const <String>[],
      availableLocations: const <String>[],
    );
  }

  final DateTimeRange range;
  final List<BreedingRecord> filteredRecords;
  final List<Animal> filteredAnimals;
  final Map<String, Animal> animalsById;
  final List<MonthlyMetric> monthlyMetrics;
  final List<BreederPerformance> topPerformances;
  final Map<String, int> eventCountsByType;
  final InventorySummary? inventorySummary;
  final List<Animal> availableBreeders;
  final List<String> availableLots;
  final List<String> availableLocations;

  @override
  List<Object?> get props => <Object?>[
        range,
        filteredRecords,
        filteredAnimals,
        animalsById,
        monthlyMetrics,
        topPerformances,
        eventCountsByType,
        inventorySummary,
        availableBreeders,
        availableLots,
        availableLocations,
      ];
}

class ReportCubit extends Cubit<ReportState> {
  ReportCubit(this._reportingService) : super(ReportState());

  final ReportingService _reportingService;

  Future<void> load({
    required String? profileId,
    bool forceRefresh = false,
  }) async {
    emit(
      state.copyWith(
        status: ReportStatus.loading,
        clearError: true,
      ),
    );
    try {
      final ReportDataset dataset = await _reportingService.loadDataset(
        profileId: profileId,
        forceRefresh: forceRefresh,
      );
      emit(
        state.copyWith(
          status: ReportStatus.success,
          dataset: dataset,
          viewData: _buildViewData(dataset, state),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ReportStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void updatePeriod(ReportPeriod period) {
    emit(
      _recompute(
        state.copyWith(
          period: period,
          clearCustomRange: period != ReportPeriod.custom,
        ),
      ),
    );
  }

  void updateCustomRange(DateTimeRange range) {
    emit(
      _recompute(
        state.copyWith(
          period: ReportPeriod.custom,
          customRange: range,
        ),
      ),
    );
  }

  void updateSexFilter(SexFilterOption filter) {
    emit(_recompute(state.copyWith(sexFilter: filter)));
  }

  void updateBreeder(String? breederId) {
    emit(
      _recompute(
        state.copyWith(
          selectedBreederId: breederId,
          clearBreeder: breederId == null,
        ),
      ),
    );
  }

  void updateLot(String? lot) {
    emit(
      _recompute(
        state.copyWith(
          selectedLot: lot,
          clearLot: lot == null,
        ),
      ),
    );
  }

  void updateLocation(String? location) {
    emit(
      _recompute(
        state.copyWith(
          selectedLocation: location,
          clearLocation: location == null,
        ),
      ),
    );
  }

  ReportState _recompute(ReportState nextState) {
    final ReportDataset? dataset = nextState.dataset;
    if (dataset == null) {
      return nextState;
    }
    return nextState.copyWith(
      viewData: _buildViewData(dataset, nextState),
    );
  }

  ReportViewData _buildViewData(
    ReportDataset dataset,
    ReportState currentState,
  ) {
    final DateTimeRange range = _resolveRange(currentState);
    final DateTime rangeStart = range.start;
    final DateTime rangeEnd = range.end;

    final Map<String, Animal> animalsById = <String, Animal>{
      for (final Animal animal in dataset.animals) animal.id: animal,
    };

    bool matchesAnimal(
      String animalId, {
      SexFilterOption? expectedSex,
    }) {
      final Animal? animal = animalsById[animalId];
      if (animal == null) {
        return false;
      }
      if (expectedSex != null && expectedSex != SexFilterOption.all) {
        final String normalized = animal.sex.toLowerCase();
        if (expectedSex == SexFilterOption.female &&
            !normalized.contains('fem')) {
          return false;
        }
        if (expectedSex == SexFilterOption.male &&
            !(normalized.contains('mal') || normalized.contains('m\u00e2'))) {
          return false;
        }
      }
      final String? lot = dataset.animalLots[animalId];
      if (currentState.selectedLot != null &&
          currentState.selectedLot!.isNotEmpty) {
        if (lot != currentState.selectedLot) {
          return false;
        }
      }
      final String? location = dataset.animalLocations[animalId];
      if (currentState.selectedLocation != null &&
          currentState.selectedLocation!.isNotEmpty) {
        if (location != currentState.selectedLocation) {
          return false;
        }
      }
      return true;
    }

    bool matchesRecord(BreedingRecord record) {
      if (record.matingDate.isBefore(rangeStart) ||
          record.matingDate.isAfter(rangeEnd)) {
        return false;
      }
      if (currentState.selectedBreederId != null &&
          record.doeId != currentState.selectedBreederId &&
          record.buckId != currentState.selectedBreederId) {
        return false;
      }

      switch (currentState.sexFilter) {
        case SexFilterOption.all:
          if (currentState.selectedLot == null &&
              currentState.selectedLocation == null) {
            return true;
          }
          return matchesAnimal(record.doeId) ||
              matchesAnimal(record.buckId);
        case SexFilterOption.female:
          return matchesAnimal(
            record.doeId,
            expectedSex: SexFilterOption.female,
          );
        case SexFilterOption.male:
          return matchesAnimal(
            record.buckId,
            expectedSex: SexFilterOption.male,
          );
      }
    }

    final List<BreedingRecord> filteredRecords = dataset.breedingRecords
        .where(matchesRecord)
        .toList()
      ..sort(
        (BreedingRecord a, BreedingRecord b) =>
            a.matingDate.compareTo(b.matingDate),
      );

    final Set<String> animalIdsInRecords = <String>{
      for (final BreedingRecord record in filteredRecords) record.doeId,
      for (final BreedingRecord record in filteredRecords) record.buckId,
    };
    final List<Animal> filteredAnimals = <Animal>[
      for (final String animalId in animalIdsInRecords)
        if (animalsById.containsKey(animalId)) animalsById[animalId]!,
    ]..sort((Animal a, Animal b) => a.tagId.compareTo(b.tagId));

    final List<MonthlyMetric> monthlyMetrics =
        _buildMonthlyMetrics(filteredRecords);
    final List<BreederPerformance> topPerformances =
        _buildBreederPerformances(filteredRecords, animalsById);

    final Iterable<LivestockEvent> filteredEvents =
        dataset.events.where((LivestockEvent event) {
      if (event.eventDate.isBefore(rangeStart) ||
          event.eventDate.isAfter(rangeEnd)) {
        return false;
      }
      final List<String> linkedAnimals =
          dataset.eventAnimalIds[event.id] ?? <String>[];
      if (linkedAnimals.isEmpty) {
        return true;
      }
      return linkedAnimals.any(matchesAnimal);
    });

    final Map<String, int> eventCountsByType = <String, int>{};
    for (final LivestockEvent event in filteredEvents) {
      eventCountsByType.update(
        event.eventType,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    final List<Animal> breederOptions = <Animal>[
      for (final String animalId in <String>{
        for (final BreedingRecord record in dataset.breedingRecords) record.doeId,
        for (final BreedingRecord record in dataset.breedingRecords) record.buckId,
      })
        if (animalsById.containsKey(animalId)) animalsById[animalId]!,
    ]..sort((Animal a, Animal b) => a.tagId.compareTo(b.tagId));

    return ReportViewData(
      range: range,
      filteredRecords: filteredRecords,
      filteredAnimals: filteredAnimals,
      animalsById: animalsById,
      monthlyMetrics: monthlyMetrics,
      topPerformances: topPerformances,
      eventCountsByType: eventCountsByType,
      inventorySummary: dataset.inventorySummary,
      availableBreeders: breederOptions,
      availableLots: dataset.availableLots,
      availableLocations: dataset.availableLocations,
    );
  }

  DateTimeRange _resolveRange(ReportState state) {
    if (state.period == ReportPeriod.custom && state.customRange != null) {
      return state.customRange!;
    }
    final DateTime end = DateTime.now();
    final Duration fallback = const Duration(days: 182);
    final Duration duration = state.period.duration ?? fallback;
    final DateTime start = end.subtract(duration);
    return DateTimeRange(start: start, end: end);
  }

  List<MonthlyMetric> _buildMonthlyMetrics(List<BreedingRecord> records) {
    final Map<DateTime, _MonthlyAccumulator> buckets =
        <DateTime, _MonthlyAccumulator>{};
    for (final BreedingRecord record in records) {
      final DateTime key =
          DateTime(record.matingDate.year, record.matingDate.month);
      final _MonthlyAccumulator accumulator =
          buckets.putIfAbsent(key, _MonthlyAccumulator.new);
      accumulator.totalMatings += 1;
      if (record.palpationPositive == true) {
        accumulator.successfulMatings += 1;
      }
      if (record.kitsBornAlive != null) {
        accumulator.totalBorn += record.kitsBornAlive!;
        accumulator.bornSamples += 1;
      }
      if (record.kitsWeaned != null) {
        accumulator.totalWeaned += record.kitsWeaned!;
        accumulator.weanedSamples += 1;
      }
    }
    final List<DateTime> months = buckets.keys.toList()
      ..sort((DateTime a, DateTime b) => a.compareTo(b));
    return <MonthlyMetric>[
      for (final DateTime month in months)
        MonthlyMetric(
          month: month,
          successRate: buckets[month]!.successRate,
          averageBorn: buckets[month]!.averageBorn,
          averageWeaned: buckets[month]!.averageWeaned,
        ),
    ];
  }

  List<BreederPerformance> _buildBreederPerformances(
    List<BreedingRecord> records,
    Map<String, Animal> animalsById,
  ) {
    final Map<String, _BreederAccumulator> map =
        <String, _BreederAccumulator>{};

    void track(String? animalId, BreedingRecord record) {
      if (animalId == null) {
        return;
      }
      final _BreederAccumulator accumulator =
          map.putIfAbsent(animalId, _BreederAccumulator.new);
      accumulator.totalMatings += 1;
      if (record.palpationPositive == true) {
        accumulator.successfulMatings += 1;
      }
      if (record.kitsWeaned != null) {
        accumulator.totalWeaned += record.kitsWeaned!;
      }
    }

    for (final BreedingRecord record in records) {
      track(record.doeId, record);
      track(record.buckId, record);
    }

    final List<BreederPerformance> performances = <BreederPerformance>[
      for (final MapEntry<String, _BreederAccumulator> entry in map.entries)
        BreederPerformance(
          animalId: entry.key,
          animal: animalsById[entry.key],
          totalMatings: entry.value.totalMatings,
          successRate: entry.value.successRate,
          totalWeaned: entry.value.totalWeaned,
        ),
    ]..sort(
        (BreederPerformance a, BreederPerformance b) =>
            b.successRate.compareTo(a.successRate),
      );

    return performances.take(6).toList();
  }
}

class MonthlyMetric extends Equatable {
  const MonthlyMetric({
    required this.month,
    required this.successRate,
    required this.averageBorn,
    required this.averageWeaned,
  });

  final DateTime month;
  final double successRate;
  final double? averageBorn;
  final double? averageWeaned;

  @override
  List<Object?> get props => <Object?>[
        month,
        successRate,
        averageBorn,
        averageWeaned,
      ];
}

class BreederPerformance extends Equatable {
  const BreederPerformance({
    required this.animalId,
    required this.totalMatings,
    required this.successRate,
    required this.totalWeaned,
    this.animal,
  });

  final String animalId;
  final int totalMatings;
  final double successRate;
  final int totalWeaned;
  final Animal? animal;

  @override
  List<Object?> get props => <Object?>[
        animalId,
        totalMatings,
        successRate,
        totalWeaned,
        animal,
      ];
}

class _MonthlyAccumulator {
  int totalMatings = 0;
  int successfulMatings = 0;
  int totalBorn = 0;
  int bornSamples = 0;
  int totalWeaned = 0;
  int weanedSamples = 0;

  double get successRate =>
      totalMatings == 0 ? 0 : successfulMatings / totalMatings;

  double? get averageBorn =>
      bornSamples == 0 ? null : totalBorn / bornSamples;

  double? get averageWeaned =>
      weanedSamples == 0 ? null : totalWeaned / weanedSamples;
}

class _BreederAccumulator {
  int totalMatings = 0;
  int successfulMatings = 0;
  int totalWeaned = 0;

  double get successRate =>
      totalMatings == 0 ? 0 : successfulMatings / totalMatings;
}
