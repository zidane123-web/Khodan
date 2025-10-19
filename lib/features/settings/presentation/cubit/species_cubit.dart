import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/species_config.dart';
import '../../../../data/repositories/species_repository.dart';

class SpeciesState extends Equatable {
  const SpeciesState({
    this.species = const <SpeciesConfig>[],
    this.loading = false,
    this.saving = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<SpeciesConfig> species;
  final bool loading;
  final bool saving;
  final String? errorMessage;
  final String? successMessage;

  SpeciesState copyWith({
    List<SpeciesConfig>? species,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return SpeciesState(
      species: species ?? this.species,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        species,
        loading,
        saving,
        errorMessage,
        successMessage,
      ];
}

class SpeciesCubit extends Cubit<SpeciesState> {
  SpeciesCubit(this._repository, {required this.profileId})
      : super(const SpeciesState());

  final SpeciesRepository _repository;
  final String profileId;

  bool _initialised = false;

  Future<void> initialize() async {
    if (_initialised) {
      return;
    }
    _initialised = true;
    await _loadSpecies(showLoader: true);
  }

  Future<void> refresh() => _loadSpecies(showLoader: false);

  Future<void> saveSpecies({
    int? id,
    required String name,
    required int gestationDays,
    required int weaningDays,
    required List<String> eventsSchema,
  }) async {
    emit(state.copyWith(saving: true, clearError: true, clearSuccess: true));
    final int resolvedId = id ?? _generateTemporaryId();
    final SpeciesConfig config = SpeciesConfig(
      id: resolvedId,
      profileId: profileId,
      speciesName: name.trim(),
      gestationDays: gestationDays,
      weaningDays: weaningDays,
      eventsSchema: eventsSchema,
    );
    try {
      final bool isUpdate = id != null;
      final SpeciesConfig result = isUpdate
          ? await _repository.updateSpecies(config)
          : await _repository.createSpecies(config);
      final String message = isUpdate
          ? 'Espèce mise à jour avec succès.'
          : 'Espèce créée avec succès.';
      await _loadSpecies(showLoader: false, successMessage: message);
      if (id == null && result.id != resolvedId) {
        await _loadSpecies(showLoader: false);
      }
    } catch (error) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> deleteSpecies(int id) async {
    emit(state.copyWith(saving: true, clearError: true, clearSuccess: true));
    try {
      await _repository.deleteSpecies(id);
      await _loadSpecies(
        showLoader: false,
        successMessage: 'Espèce supprimée.',
      );
    } catch (error) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void acknowledgeFeedback() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  Future<void> _loadSpecies({
    required bool showLoader,
    String? successMessage,
  }) async {
    if (showLoader) {
      emit(
        state.copyWith(
          loading: true,
          clearError: true,
          clearSuccess: true,
        ),
      );
    }
    try {
      final List<SpeciesConfig> species =
          await _repository.fetchSpecies(profileId);
      emit(
        state.copyWith(
          species: species,
          loading: false,
          saving: false,
          errorMessage: null,
          successMessage: successMessage,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          saving: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  int _generateTemporaryId() {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return -timestamp - Random().nextInt(1000);
  }
}

