import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/local/local_data_sources.dart';
import '../../../../data/models/animal.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/services/offline_sync_manager.dart';

enum AnimalStatus { initial, loading, success, failure }

class AnimalFilters extends Equatable {
  const AnimalFilters({
    this.searchTerm = '',
    this.sex,
    this.statuses,
    this.breeds,
    this.categories,
    this.origin,
    this.cageNumber,
    this.birthStart,
    this.birthEnd,
    this.entryStart,
    this.entryEnd,
    this.onlyRecentLitters = false,
  });

  final String searchTerm;
  final String? sex;
  final Set<String>? statuses;
  final Set<String>? breeds;
  final Set<String>? categories;
  final String? origin;
  final String? cageNumber;
  final DateTime? birthStart;
  final DateTime? birthEnd;
  final DateTime? entryStart;
  final DateTime? entryEnd;
  final bool onlyRecentLitters;

  bool get hasAdvancedFilters =>
      sex != null ||
      (statuses != null && statuses!.isNotEmpty) ||
      (breeds != null && breeds!.isNotEmpty) ||
      (categories != null && categories!.isNotEmpty) ||
      (origin != null && origin!.isNotEmpty) ||
      (cageNumber != null && cageNumber!.isNotEmpty) ||
      birthStart != null ||
      birthEnd != null ||
      entryStart != null ||
      entryEnd != null ||
      onlyRecentLitters;

  AnimalFilters copyWith({
    String? searchTerm,
    String? sex,
    bool clearSex = false,
    Set<String>? statuses,
    bool clearStatuses = false,
    Set<String>? breeds,
    bool clearBreeds = false,
    Set<String>? categories,
    bool clearCategories = false,
    String? origin,
    bool clearOrigin = false,
    String? cageNumber,
    bool clearCageNumber = false,
    DateTime? birthStart,
    bool clearBirthStart = false,
    DateTime? birthEnd,
    bool clearBirthEnd = false,
    DateTime? entryStart,
    bool clearEntryStart = false,
    DateTime? entryEnd,
    bool clearEntryEnd = false,
    bool? onlyRecentLitters,
  }) {
    Set<String>? clone(Set<String>? values) =>
        values == null ? null : <String>{...values};

    return AnimalFilters(
      searchTerm: searchTerm ?? this.searchTerm,
      sex: clearSex ? null : (sex ?? this.sex),
      statuses: clearStatuses
          ? null
          : clone(statuses ?? this.statuses),
      breeds: clearBreeds ? null : clone(breeds ?? this.breeds),
      categories: clearCategories
          ? null
          : clone(categories ?? this.categories),
      origin: clearOrigin ? null : (origin ?? this.origin),
      cageNumber: clearCageNumber ? null : (cageNumber ?? this.cageNumber),
      birthStart: clearBirthStart ? null : (birthStart ?? this.birthStart),
      birthEnd: clearBirthEnd ? null : (birthEnd ?? this.birthEnd),
      entryStart: clearEntryStart ? null : (entryStart ?? this.entryStart),
      entryEnd: clearEntryEnd ? null : (entryEnd ?? this.entryEnd),
      onlyRecentLitters: onlyRecentLitters ?? this.onlyRecentLitters,
    );
  }

  bool matches(Animal animal) {
    final String normalizedQuery = searchTerm.trim().toLowerCase();
    final Iterable<String?> searchable = <String?>[
      animal.tagId,
      animal.name,
      animal.id,
      animal.origin,
      animal.cageNumber,
      animal.breed,
      animal.category,
      animal.notes,
    ];
    final bool matchesSearch = normalizedQuery.isEmpty ||
        searchable
            .map((String? value) => value?.toLowerCase() ?? '')
            .any((String value) => value.contains(normalizedQuery));

    String normalize(String? value) => value?.toLowerCase().trim() ?? '';

    final bool matchesSex =
        sex == null || normalize(animal.sex) == normalize(sex);

    final Set<String>? normalizedStatuses = statuses
        ?.where((String value) => value.trim().isNotEmpty)
        .map(normalize)
        .toSet();
    final bool matchesStatus = normalizedStatuses == null ||
        normalizedStatuses.isEmpty ||
        normalizedStatuses.contains(normalize(animal.status));

    final Set<String>? normalizedBreeds = breeds
        ?.where((String value) => value.trim().isNotEmpty)
        .map(normalize)
        .toSet();
    final bool matchesBreed = normalizedBreeds == null ||
        normalizedBreeds.isEmpty ||
        normalizedBreeds.contains(normalize(animal.breed));

    final Set<String>? normalizedCategories = categories
        ?.where((String value) => value.trim().isNotEmpty)
        .map(normalize)
        .toSet();
    final bool matchesCategory = normalizedCategories == null ||
        normalizedCategories.isEmpty ||
        normalizedCategories.contains(normalize(animal.category));

    final bool matchesOrigin =
        origin == null ||
        (animal.origin != null &&
            animal.origin!.toLowerCase().contains(origin!.toLowerCase()));
    final bool matchesCage =
        cageNumber == null ||
        (animal.cageNumber != null &&
            animal.cageNumber!.toLowerCase().contains(
              cageNumber!.toLowerCase(),
            ));

    final bool matchesBirthStart =
        birthStart == null || !animal.birthDate.isBefore(birthStart!);
    final bool matchesBirthEnd =
        birthEnd == null || !animal.birthDate.isAfter(birthEnd!);

    final DateTime? entryDate = animal.entryDate;
    final bool matchesEntryStart = entryStart == null ||
        (entryDate != null && !entryDate.isBefore(entryStart!));
    final bool matchesEntryEnd = entryEnd == null ||
        (entryDate != null && !entryDate.isAfter(entryEnd!));

    final bool matchesRecent = !onlyRecentLitters ||
        (animal.lastLitterDate != null &&
            DateTime.now().difference(animal.lastLitterDate!).inDays <= 90);

    return matchesSearch &&
        matchesSex &&
        matchesStatus &&
        matchesBreed &&
        matchesCategory &&
        matchesOrigin &&
        matchesCage &&
        matchesBirthStart &&
        matchesBirthEnd &&
        matchesEntryStart &&
        matchesEntryEnd &&
        matchesRecent;
  }

  List<String>? _sorted(Set<String>? values) {
    if (values == null) {
      return null;
    }
    final List<String> sorted = values
        .where((String value) => value.trim().isNotEmpty)
        .map((String value) => value.toLowerCase().trim())
        .toList()
      ..sort();
    return sorted;
  }

  @override
  List<Object?> get props => <Object?>[
        searchTerm,
        sex,
        _sorted(statuses),
        _sorted(breeds),
        _sorted(categories),
        origin,
        cageNumber,
        birthStart,
        birthEnd,
        entryStart,
        entryEnd,
        onlyRecentLitters,
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
  List<Object?> get props => <Object?>[
    status,
    animals,
    allAnimals,
    filters,
    errorMessage,
  ];
}

class AnimalCubit extends Cubit<AnimalState> {
  AnimalCubit(
    this._repository, {
    OfflineSyncManager? offlineManager,
    LocalAnimalDataSource? localDataSource,
  }) : _offlineManager = offlineManager ?? OfflineSyncManager.instance,
       _localDataSource = localDataSource,
       super(const AnimalState());

  final AnimalRepository _repository;
  final OfflineSyncManager _offlineManager;
  final LocalAnimalDataSource? _localDataSource;

  String? get _currentProfileId {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchAnimals({int? speciesId}) async {
    final bool isOffline = _offlineManager.isOffline.value;
    if (isOffline) {
      final LocalAnimalDataSource? local = _localDataSource;
      final List<Animal> cached = local == null
          ? state.allAnimals
          : await local.fetchAnimals(
              profileId: _currentProfileId,
              speciesId: speciesId,
            );
      if (cached.isNotEmpty) {
        emit(
          state.copyWith(
            status: AnimalStatus.success,
            animals: _applyFilters(cached, state.filters),
            allAnimals: cached,
            errorMessage: null,
          ),
        );
      } else if (state.allAnimals.isNotEmpty) {
        emit(
          state.copyWith(
            status: AnimalStatus.success,
            animals: _applyFilters(state.allAnimals, state.filters),
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AnimalStatus.failure,
            errorMessage: 'Aucune donnée locale disponible hors-ligne.',
          ),
        );
      }
      return;
    }
    emit(state.copyWith(status: AnimalStatus.loading));
    try {
      final List<Animal> animals = await _repository.fetchAnimals(
        speciesId: speciesId,
      );
      await _localDataSource?.replaceAnimals(
        animals,
        profileId: _currentProfileId,
      );
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
      final LocalAnimalDataSource? local = _localDataSource;
      final List<Animal> cached = local == null
          ? const <Animal>[]
          : await local.fetchAnimals(
              profileId: _currentProfileId,
              speciesId: speciesId,
            );
      if (cached.isNotEmpty) {
        emit(
          state.copyWith(
            status: AnimalStatus.success,
            animals: _applyFilters(cached, state.filters),
            allAnimals: cached,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AnimalStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> createAnimal(Animal animal) async {
    if (_offlineManager.isOffline.value) {
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
      return;
    }
    emit(state.copyWith(status: AnimalStatus.loading));
    try {
      final Animal created = await _repository.createAnimal(animal);
      final List<Animal> allAnimals = List<Animal>.from(state.allAnimals)
        ..add(created);
      allAnimals.sort((Animal a, Animal b) => a.tagId.compareTo(b.tagId));
      await _localDataSource?.upsertAnimal(created);
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          allAnimals: allAnimals,
          animals: _applyFilters(allAnimals, state.filters),
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

  Future<void> updateAnimal(Animal animal) async {
    if (_offlineManager.isOffline.value) {
      final List<Animal> allAnimals = List<Animal>.from(state.allAnimals);
      final Animal updated = await _repository.updateAnimal(animal);
      final int index = allAnimals.indexWhere(
        (Animal element) => element.id == updated.id,
      );
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
      return;
    }
    emit(state.copyWith(status: AnimalStatus.loading));
    try {
      final Animal updated = await _repository.updateAnimal(animal);
      final List<Animal> allAnimals = List<Animal>.from(state.allAnimals);
      final int index = allAnimals.indexWhere(
        (Animal element) => element.id == updated.id,
      );
      if (index == -1) {
        allAnimals.add(updated);
      } else {
        allAnimals[index] = updated;
      }
      allAnimals.sort((Animal a, Animal b) => a.tagId.compareTo(b.tagId));
      await _localDataSource?.upsertAnimal(updated);
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          allAnimals: allAnimals,
          animals: _applyFilters(allAnimals, state.filters),
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

  Future<void> deleteAnimal(String id) async {
    if (_offlineManager.isOffline.value) {
      await _repository.deleteAnimal(id);
      final List<Animal> allAnimals = state.allAnimals
          .where((Animal animal) => animal.id != id)
          .toList();
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
      await _localDataSource?.deleteAnimal(id);
      final List<Animal> allAnimals = state.allAnimals
          .where((Animal animal) => animal.id != id)
          .toList();
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          allAnimals: allAnimals,
          animals: _applyFilters(allAnimals, state.filters),
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

  void updateSearchTerm(String searchTerm) {
    final AnimalFilters filters = state.filters.copyWith(
      searchTerm: searchTerm,
    );
    final List<Animal> filtered = _applyFilters(state.allAnimals, filters);
    emit(state.copyWith(filters: filters, animals: filtered));
  }

  void setFilters(AnimalFilters filters) {
    Set<String>? cleanSet(Set<String>? values) {
      if (values == null) {
        return null;
      }
      final Set<String> cleaned = <String>{};
      for (final String value in values) {
        final String trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          cleaned.add(trimmed);
        }
      }
      return cleaned.isEmpty ? null : cleaned;
    }

    String? cleanString(String? value) {
      if (value == null) {
        return null;
      }
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    final AnimalFilters nextFilters = AnimalFilters(
      searchTerm: filters.searchTerm,
      sex: cleanString(filters.sex),
      statuses: cleanSet(filters.statuses),
      breeds: cleanSet(filters.breeds),
      categories: cleanSet(filters.categories),
      origin: cleanString(filters.origin),
      cageNumber: cleanString(filters.cageNumber),
      birthStart: filters.birthStart,
      birthEnd: filters.birthEnd,
      entryStart: filters.entryStart,
      entryEnd: filters.entryEnd,
      onlyRecentLitters: filters.onlyRecentLitters,
    );
    emit(
      state.copyWith(
        filters: nextFilters,
        animals: _applyFilters(state.allAnimals, nextFilters),
      ),
    );
  }

  void clearAdvancedFilters() {
    final AnimalFilters filters = AnimalFilters(
      searchTerm: state.filters.searchTerm,
    );
    emit(
      state.copyWith(
        filters: filters,
        animals: _applyFilters(state.allAnimals, filters),
      ),
    );
  }

  void clearAllFilters() {
    emit(
      state.copyWith(
        filters: const AnimalFilters(),
        animals: _applyFilters(state.allAnimals, const AnimalFilters()),
      ),
    );
  }

  List<Animal> _applyFilters(List<Animal> animals, AnimalFilters filters) {
    return animals.where(filters.matches).toList();
  }
}
