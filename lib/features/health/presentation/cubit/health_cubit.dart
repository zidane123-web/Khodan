import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/ailment.dart';
import '../../../../data/models/animal.dart';
import '../../../../data/models/health_record.dart';
import '../../../../data/models/health_treatment.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/health_repository.dart';
import 'health_state.dart';

class HealthCubit extends Cubit<HealthState> {
  HealthCubit({
    required HealthRepository healthRepository,
    required AnimalRepository animalRepository,
  }) : _healthRepository = healthRepository,
       _animalRepository = animalRepository,
       super(const HealthState());

  final HealthRepository _healthRepository;
  final AnimalRepository _animalRepository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final List<dynamic> results =
          await Future.wait<dynamic>(<Future<dynamic>>[
            _healthRepository.fetchAilments(),
            _healthRepository.fetchRecords(),
            _animalRepository.fetchAnimals(),
          ]);
      final List<Ailment> ailments = results[0] as List<Ailment>;
      final List<HealthRecord> records = results[1] as List<HealthRecord>;
      final List<Animal> animals = results[2] as List<Animal>;
      emit(
        state.copyWith(
          isLoading: false,
          ailments: ailments,
          filteredAilments: _filterAilments(ailments, state.searchQuery),
          records: records,
          animals: animals,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> refreshRecords() async {
    try {
      final List<HealthRecord> records = await _healthRepository.fetchRecords();
      emit(state.copyWith(records: records, errorMessage: null));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  void searchAilments(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        filteredAilments: _filterAilments(state.ailments, query),
      ),
    );
  }

  Future<HealthRecord?> createRecord(HealthRecord record) async {
    try {
      final HealthRecord saved = await _healthRepository.createRecord(record);
      await _refreshRecord(saved.id);
      return saved;
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
      rethrow;
    }
  }

  Future<HealthRecord?> updateRecord(HealthRecord record) async {
    try {
      final HealthRecord saved = await _healthRepository.updateRecord(record);
      await _refreshRecord(saved.id);
      return saved;
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
      rethrow;
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _healthRepository.deleteRecord(id);
      final List<HealthRecord> updated = state.records
          .where((HealthRecord record) => record.id != id)
          .toList();
      emit(state.copyWith(records: updated, errorMessage: null));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
      rethrow;
    }
  }

  Future<HealthTreatment?> createTreatment(HealthTreatment treatment) async {
    try {
      final HealthTreatment saved = await _healthRepository.createTreatment(
        treatment,
      );
      await _refreshRecord(saved.recordId);
      return saved;
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
      rethrow;
    }
  }

  Future<HealthTreatment?> updateTreatment(HealthTreatment treatment) async {
    try {
      final HealthTreatment saved = await _healthRepository.updateTreatment(
        treatment,
      );
      await _refreshRecord(saved.recordId);
      return saved;
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
      rethrow;
    }
  }

  Future<void> deleteTreatment(HealthTreatment treatment) async {
    try {
      await _healthRepository.deleteTreatment(treatment);
      await _refreshRecord(treatment.recordId);
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
      rethrow;
    }
  }

  Animal? findAnimal(String id) {
    for (final Animal animal in state.animals) {
      if (animal.id == id) {
        return animal;
      }
    }
    return null;
  }

  Future<void> _refreshRecord(String recordId) async {
    final HealthRecord? refreshed = await _healthRepository.fetchRecordById(
      recordId,
    );
    if (refreshed == null) {
      final List<HealthRecord> without = state.records
          .where((HealthRecord record) => record.id != recordId)
          .toList();
      emit(state.copyWith(records: without));
      return;
    }
    final List<HealthRecord> updated = state.records.map((HealthRecord record) {
      if (record.id == refreshed.id) {
        return refreshed;
      }
      return record;
    }).toList();
    bool exists = updated.any(
      (HealthRecord record) => record.id == refreshed.id,
    );
    if (!exists) {
      updated.add(refreshed);
    }
    updated.sort(
      (HealthRecord a, HealthRecord b) => b.onsetDate.compareTo(a.onsetDate),
    );
    emit(state.copyWith(records: updated, errorMessage: null));
  }

  List<Ailment> _filterAilments(List<Ailment> ailments, String query) {
    if (query.isEmpty) {
      final List<Ailment> sorted = List<Ailment>.from(ailments)
        ..sort((Ailment a, Ailment b) => a.name.compareTo(b.name));
      return sorted;
    }
    final String lower = query.toLowerCase();
    final List<Ailment> filtered =
        ailments
            .where(
              (Ailment ailment) => ailment.name.toLowerCase().contains(lower),
            )
            .toList()
          ..sort((Ailment a, Ailment b) => a.name.compareTo(b.name));
    return filtered;
  }
}
