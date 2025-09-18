import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';

enum BreedingStatus { initial, loading, success, failure }

class BreedingState extends Equatable {
  const BreedingState({
    this.status = BreedingStatus.initial,
    this.records = const <BreedingRecord>[],
    this.animals = const <Animal>[],
    this.errorMessage,
  });

  final BreedingStatus status;
  final List<BreedingRecord> records;
  final List<Animal> animals;
  final String? errorMessage;

  Map<String, Animal> get animalsById => <String, Animal>{
        for (final Animal animal in animals) animal.id: animal,
      };

  List<BreedingReminder> get reminders => BreedingReminder.build(records);

  BreedingState copyWith({
    BreedingStatus? status,
    List<BreedingRecord>? records,
    List<Animal>? animals,
    String? errorMessage,
  }) {
    return BreedingState(
      status: status ?? this.status,
      records: records ?? this.records,
      animals: animals ?? this.animals,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, records, animals, errorMessage];
}

class BreedingCubit extends Cubit<BreedingState> {
  BreedingCubit(this._repository, this._animalRepository)
      : super(const BreedingState());

  final BreedingRepository _repository;
  final AnimalRepository _animalRepository;

  Future<void> loadData() async {
    emit(state.copyWith(status: BreedingStatus.loading));
    try {
      final List<Animal> animals = await _animalRepository.fetchAnimals();
      final List<BreedingRecord> records =
          await _repository.fetchBreedingRecords();
      emit(
        state.copyWith(
          status: BreedingStatus.success,
          animals: animals,
          records: _sort(records),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BreedingStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> addRecord(BreedingRecord record) async {
    emit(state.copyWith(status: BreedingStatus.loading));
    try {
      final BreedingRecord created =
          await _repository.createBreedingRecord(record);
      final List<BreedingRecord> records =
          _sort(<BreedingRecord>[...state.records, created]);
      emit(
        state.copyWith(
          status: BreedingStatus.success,
          records: records,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: BreedingStatus.failure, errorMessage: error.toString()));
    }
  }

  Future<void> updateRecord(BreedingRecord record) async {
    emit(state.copyWith(status: BreedingStatus.loading));
    try {
      final BreedingRecord updated =
          await _repository.updateBreedingRecord(record);
      final List<BreedingRecord> records = List<BreedingRecord>.from(state.records);
      final int index =
          records.indexWhere((BreedingRecord element) => element.id == updated.id);
      if (index == -1) {
        records.add(updated);
      } else {
        records[index] = updated;
      }
      emit(
        state.copyWith(
          status: BreedingStatus.success,
          records: _sort(records),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: BreedingStatus.failure, errorMessage: error.toString()));
    }
  }

  Future<void> deleteRecord(String id) async {
    emit(state.copyWith(status: BreedingStatus.loading));
    try {
      await _repository.deleteBreedingRecord(id);
      final List<BreedingRecord> records =
          state.records.where((BreedingRecord record) => record.id != id).toList();
      emit(
        state.copyWith(
          status: BreedingStatus.success,
          records: _sort(records),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: BreedingStatus.failure, errorMessage: error.toString()));
    }
  }

  List<BreedingRecord> _sort(List<BreedingRecord> records) {
    final List<BreedingRecord> sorted = List<BreedingRecord>.from(records);
    sorted.sort(
      (BreedingRecord a, BreedingRecord b) =>
          b.matingDate.compareTo(a.matingDate),
    );
    return sorted;
  }
}
