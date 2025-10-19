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
    this.origin,
    this.cageNumber,
  });

  final String searchTerm;
  final String? sex;
  final String? origin;
  final String? cageNumber;

  bool get hasAdvancedFilters =>
      sex != null ||
      (origin != null && origin!.isNotEmpty) ||
      (cageNumber != null && cageNumber!.isNotEmpty);

  AnimalFilters copyWith({
    String? searchTerm,
    String? sex,
    bool clearSex = false,
    String? origin,
    bool clearOrigin = false,
    String? cageNumber,
    bool clearCageNumber = false,
  }) {
    return AnimalFilters(
      searchTerm: searchTerm ?? this.searchTerm,
      sex: clearSex ? null : (sex ?? this.sex),
      origin: clearOrigin ? null : (origin ?? this.origin),
      cageNumber: clearCageNumber ? null : (cageNumber ?? this.cageNumber),
    );
  }

  bool matches(Animal animal) {
    final String normalizedQuery = searchTerm.trim().toLowerCase();
    final bool matchesSearch =
        normalizedQuery.isEmpty ||
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

    return matchesSearch && matchesSex && matchesOrigin && matchesCage;
  }

  @override
  List<Object?> get props => <Object?>[searchTerm, sex, origin, cageNumber];
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
    final AnimalFilters filters = AnimalFilters(
      searchTerm: searchTerm,
      sex: state.filters.sex,
      origin: state.filters.origin,
      cageNumber: state.filters.cageNumber,
    );
    final List<Animal> filtered = _applyFilters(state.allAnimals, filters);
    emit(state.copyWith(filters: filters, animals: filtered));
  }

  void setFilters(AnimalFilters filters) {
    final AnimalFilters nextFilters = AnimalFilters(
      searchTerm: filters.searchTerm,
      sex: filters.sex,
      origin: filters.origin?.isEmpty == true ? null : filters.origin,
      cageNumber: filters.cageNumber?.isEmpty == true
          ? null
          : filters.cageNumber,
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
