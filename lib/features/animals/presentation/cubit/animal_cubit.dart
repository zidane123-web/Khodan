import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/services/offline_sync_manager.dart';
import '../models/animal_quick_filter.dart';

enum AnimalStatus { initial, loading, success, failure }

class AnimalFilters extends Equatable {
  const AnimalFilters({
    this.searchTerm = '',
    this.sex,
    this.origin,
    this.cageNumber,
    this.statusQuery,
    this.includeIds,
    this.quickLabel,
  });

  final String searchTerm;
  final String? sex;
  final String? origin;
  final String? cageNumber;
  final String? statusQuery;
  final Set<String>? includeIds;
  final String? quickLabel;

  bool get hasAdvancedFilters =>
      sex != null ||
      (origin != null && origin!.isNotEmpty) ||
      (cageNumber != null && cageNumber!.isNotEmpty) ||
      statusQuery != null ||
      includeIds != null ||
      quickLabel != null;

  AnimalFilters copyWith({
    String? searchTerm,
    String? sex,
    bool clearSex = false,
    String? origin,
    bool clearOrigin = false,
    String? cageNumber,
    bool clearCageNumber = false,
    String? statusQuery,
    bool clearStatusQuery = false,
    Set<String>? includeIds,
    bool clearIncludeIds = false,
    String? quickLabel,
    bool clearQuickLabel = false,
  }) {
    return AnimalFilters(
      searchTerm: searchTerm ?? this.searchTerm,
      sex: clearSex ? null : (sex ?? this.sex),
      origin: clearOrigin ? null : (origin ?? this.origin),
      cageNumber:
          clearCageNumber ? null : (cageNumber ?? this.cageNumber),
      statusQuery:
          clearStatusQuery ? null : (statusQuery ?? this.statusQuery),
      includeIds:
          clearIncludeIds ? null : (includeIds ?? this.includeIds),
      quickLabel: clearQuickLabel ? null : (quickLabel ?? this.quickLabel),
    );
  }

  bool matches(Animal animal) {
    final String normalizedQuery = searchTerm.trim().toLowerCase();
    final bool matchesSearch = normalizedQuery.isEmpty ||
        <String?>[
          animal.tagId,
          animal.name,
          animal.id,
          animal.origin,
          animal.cageNumber,
        ]
            .where((String? value) => value != null)
            .map((String? value) => value!.toLowerCase())
            .any((String value) => value.contains(normalizedQuery));

    final bool matchesSex =
        sex == null || animal.sex.toLowerCase() == sex!.toLowerCase();
    final bool matchesOrigin = origin == null ||
        (animal.origin != null &&
            animal.origin!.toLowerCase().contains(origin!.toLowerCase()));
    final bool matchesCage = cageNumber == null ||
        (animal.cageNumber != null &&
            animal.cageNumber!
                .toLowerCase()
                .contains(cageNumber!.toLowerCase()));
    final bool matchesStatus = statusQuery == null ||
        animal.status.toLowerCase().contains(statusQuery!.toLowerCase());
    final bool matchesIds = includeIds == null || includeIds!.contains(animal.id);

    return matchesSearch &&
        matchesSex &&
        matchesOrigin &&
        matchesCage &&
        matchesStatus &&
        matchesIds;
  }

  @override
  List<Object?> get props => <Object?>[
        searchTerm,
        sex,
        origin,
        cageNumber,
        statusQuery,
        includeIds,
        quickLabel,
      ];
}

class AnimalState extends Equatable {
  const AnimalState({
    this.status = AnimalStatus.initial,
    this.animals = const <Animal>[],
    this.allAnimals = const <Animal>[],
    this.filters = const AnimalFilters(),
    this.errorMessage,
  });

  final AnimalStatus status;
  final List<Animal> animals;
  final List<Animal> allAnimals;
  final AnimalFilters filters;
  final String? errorMessage;

  AnimalState copyWith({
    AnimalStatus? status,
    List<Animal>? animals,
    List<Animal>? allAnimals,
    AnimalFilters? filters,
    String? errorMessage,
  }) {
    return AnimalState(
      status: status ?? this.status,
      animals: animals ?? this.animals,
      allAnimals: allAnimals ?? this.allAnimals,
      filters: filters ?? this.filters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[status, animals, allAnimals, filters, errorMessage];
}

class AnimalCubit extends Cubit<AnimalState> {
  AnimalCubit(this._repository, {OfflineSyncManager? offlineManager})
      : _offlineManager = offlineManager ?? OfflineSyncManager.instance,
        super(const AnimalState());

  final AnimalRepository _repository;
  final OfflineSyncManager _offlineManager;

  Future<void> fetchAnimals({int? speciesId}) async {
    if (_offlineManager.isOffline.value && state.allAnimals.isNotEmpty) {
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          animals: _applyFilters(state.allAnimals, state.filters),
          errorMessage: null,
        ),
      );
      return;
    }
    emit(state.copyWith(status: AnimalStatus.loading));
    try {
      final List<Animal> animals =
          await _repository.fetchAnimals(speciesId: speciesId);
      final List<Animal> filtered = _applyFilters(animals, state.filters);
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          animals: filtered,
          allAnimals: animals,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AnimalStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> createAnimal(Animal animal) async {
    if (_offlineManager.isOffline.value) {
      final List<Animal> allAnimals = List<Animal>.from(state.allAnimals)
        ..add(animal);
      allAnimals.sort((Animal a, Animal b) => a.tagId.compareTo(b.tagId));
      _offlineManager.enqueue(
        QueuedSyncAction(
          description: 'Créer ${animal.tagId}',
          execute: () async {
            await _repository.createAnimal(animal);
          },
        ),
      );
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          allAnimals: allAnimals,
          animals: _applyFilters(allAnimals, state.filters),
          errorMessage: null,
        ),
      );
      return;
    }
    emit(state.copyWith(status: AnimalStatus.loading));
    try {
      final Animal created = await _repository.createAnimal(animal);
      final List<Animal> allAnimals = List<Animal>.from(state.allAnimals)
        ..add(created);
      allAnimals.sort((Animal a, Animal b) => a.tagId.compareTo(b.tagId));
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          allAnimals: allAnimals,
          animals: _applyFilters(allAnimals, state.filters),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: AnimalStatus.failure, errorMessage: error.toString()));
    }
  }

  Future<void> updateAnimal(Animal animal) async {
    if (_offlineManager.isOffline.value) {
      final List<Animal> allAnimals = List<Animal>.from(state.allAnimals);
      final int index =
          allAnimals.indexWhere((Animal element) => element.id == animal.id);
      if (index == -1) {
        allAnimals.add(animal);
      } else {
        allAnimals[index] = animal;
      }
      allAnimals.sort((Animal a, Animal b) => a.tagId.compareTo(b.tagId));
      _offlineManager.enqueue(
        QueuedSyncAction(
          description: 'Mettre à jour ${animal.tagId}',
          execute: () async {
            await _repository.updateAnimal(animal);
          },
        ),
      );
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          allAnimals: allAnimals,
          animals: _applyFilters(allAnimals, state.filters),
          errorMessage: null,
        ),
      );
      return;
    }
    emit(state.copyWith(status: AnimalStatus.loading));
    try {
      final Animal updated = await _repository.updateAnimal(animal);
      final List<Animal> allAnimals = List<Animal>.from(state.allAnimals);
      final int index =
          allAnimals.indexWhere((Animal element) => element.id == updated.id);
      if (index == -1) {
        allAnimals.add(updated);
      } else {
        allAnimals[index] = updated;
      }
      allAnimals.sort((Animal a, Animal b) => a.tagId.compareTo(b.tagId));
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          allAnimals: allAnimals,
          animals: _applyFilters(allAnimals, state.filters),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: AnimalStatus.failure, errorMessage: error.toString()));
    }
  }

  Future<void> deleteAnimal(String id) async {
    if (_offlineManager.isOffline.value) {
      final List<Animal> allAnimals =
          state.allAnimals.where((Animal animal) => animal.id != id).toList();
      _offlineManager.enqueue(
        QueuedSyncAction(
          description: 'Supprimer $id',
          execute: () async {
            await _repository.deleteAnimal(id);
          },
        ),
      );
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          allAnimals: allAnimals,
          animals: _applyFilters(allAnimals, state.filters),
          errorMessage: null,
        ),
      );
      return;
    }
    emit(state.copyWith(status: AnimalStatus.loading));
    try {
      await _repository.deleteAnimal(id);
      final List<Animal> allAnimals =
          state.allAnimals.where((Animal animal) => animal.id != id).toList();
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          allAnimals: allAnimals,
          animals: _applyFilters(allAnimals, state.filters),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: AnimalStatus.failure, errorMessage: error.toString()));
    }
  }

  void updateSearchTerm(String searchTerm) {
    final AnimalFilters filters = state.filters.copyWith(
      searchTerm: searchTerm,
    );
    emit(
      state.copyWith(
        filters: filters,
        animals: _applyFilters(state.allAnimals, filters),
      ),
    );
  }

  void applyQuickFilter(AnimalQuickFilter quickFilter) {
    final AnimalFilters filters = state.filters.copyWith(
      sex: quickFilter.sex,
      statusQuery: quickFilter.statusQuery,
      includeIds: quickFilter.includeIds,
      quickLabel: quickFilter.label,
      clearSex: quickFilter.sex == null,
      clearStatusQuery: quickFilter.statusQuery == null,
      clearIncludeIds: quickFilter.includeIds == null,
      clearQuickLabel: false,
    );
    emit(
      state.copyWith(
        filters: filters,
        animals: _applyFilters(state.allAnimals, filters),
      ),
    );
  }

  void setFilters(AnimalFilters filters) {
    final AnimalFilters nextFilters = state.filters.copyWith(
      searchTerm: filters.searchTerm,
      sex: filters.sex,
      origin: filters.origin?.isEmpty == true ? null : filters.origin,
      cageNumber:
          filters.cageNumber?.isEmpty == true ? null : filters.cageNumber,
      statusQuery: filters.statusQuery,
      includeIds: filters.includeIds,
      quickLabel: filters.quickLabel,
      clearSex: filters.sex == null,
      clearOrigin: filters.origin == null,
      clearCageNumber: filters.cageNumber == null,
      clearStatusQuery: filters.statusQuery == null,
      clearIncludeIds: filters.includeIds == null,
      clearQuickLabel: filters.quickLabel == null,
    );
    emit(
      state.copyWith(
        filters: nextFilters,
        animals: _applyFilters(state.allAnimals, nextFilters),
      ),
    );
  }

  void clearAdvancedFilters() {
    final AnimalFilters filters = state.filters.copyWith(
      sex: null,
      origin: null,
      cageNumber: null,
      statusQuery: null,
      includeIds: null,
      quickLabel: null,
      clearSex: true,
      clearOrigin: true,
      clearCageNumber: true,
      clearStatusQuery: true,
      clearIncludeIds: true,
      clearQuickLabel: true,
    );
    emit(
      state.copyWith(
        filters: filters,
        animals: _applyFilters(state.allAnimals, filters),
      ),
    );
  }

  void clearAllFilters() {
    const AnimalFilters cleared = AnimalFilters();
    emit(
      state.copyWith(
        filters: cleared,
        animals: _applyFilters(state.allAnimals, cleared),
      ),
    );
  }

  List<Animal> _applyFilters(List<Animal> animals, AnimalFilters filters) {
    return animals.where(filters.matches).toList();
  }
}
