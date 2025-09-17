import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/repositories/animal_repository.dart';

enum AnimalStatus { initial, loading, success, failure }

class AnimalState extends Equatable {
  const AnimalState({
    this.status = AnimalStatus.initial,
    this.animals = const <Animal>[],
    this.errorMessage,
  });

  final AnimalStatus status;
  final List<Animal> animals;
  final String? errorMessage;

  AnimalState copyWith({
    AnimalStatus? status,
    List<Animal>? animals,
    String? errorMessage,
  }) {
    return AnimalState(
      status: status ?? this.status,
      animals: animals ?? this.animals,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, animals, errorMessage];
}

class AnimalCubit extends Cubit<AnimalState> {
  AnimalCubit(this._repository) : super(const AnimalState());

  final AnimalRepository _repository;

  Future<void> fetchAnimals({int? speciesId}) async {
    emit(state.copyWith(status: AnimalStatus.loading));
    try {
      final List<Animal> animals =
          await _repository.fetchAnimals(speciesId: speciesId);
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          animals: animals,
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
}
