import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/hutch.dart';
import '../../../../data/models/litter.dart';
import '../../../../data/repositories/hutch_repository.dart';
import '../../../../data/repositories/litter_repository.dart';

enum HutchesStatus { initial, loading, success, failure }

class HutchesState extends Equatable {
  const HutchesState({
    this.status = HutchesStatus.initial,
    this.hutches = const <Hutch>[],
    this.errorMessage,
    this.infoMessage,
  });

  final HutchesStatus status;
  final List<Hutch> hutches;
  final String? errorMessage;
  final String? infoMessage;

  bool get hasPendingSync => hutches.any((Hutch hutch) => hutch.hasPendingSync);

  HutchesState copyWith({
    HutchesStatus? status,
    List<Hutch>? hutches,
    String? errorMessage,
    String? infoMessage,
  }) {
    return HutchesState(
      status: status ?? this.status,
      hutches: hutches ?? this.hutches,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        hutches,
        errorMessage,
        infoMessage,
      ];
}

class HutchesCubit extends Cubit<HutchesState> {
  HutchesCubit({
    required HutchRepository hutchRepository,
    required LitterRepository litterRepository,
  })  : _hutchRepository = hutchRepository,
        _litterRepository = litterRepository,
        super(const HutchesState());

  final HutchRepository _hutchRepository;
  final LitterRepository _litterRepository;
  StreamSubscription<List<Hutch>>? _subscription;

  Future<void> load() async {
    emit(state.copyWith(status: HutchesStatus.loading, errorMessage: null, infoMessage: null));
    try {
      final List<Hutch> items = await _hutchRepository.fetchHutches();
      emit(
        state.copyWith(
          status: HutchesStatus.success,
          hutches: items,
        ),
      );
      await _subscription?.cancel();
      _subscription = _hutchRepository.watchHutches().listen((List<Hutch> value) {
        emit(
          state.copyWith(
            status: HutchesStatus.success,
            hutches: value,
          ),
        );
      });
    } catch (error) {
      emit(
        state.copyWith(
          status: HutchesStatus.failure,
          errorMessage: 'Impossible de charger les clapiers : $error',
        ),
      );
    }
  }

  Future<void> createHutch(HutchDraft draft) async {
    try {
      final Hutch hutch = await _hutchRepository.saveHutch(draft);
      emit(
        state.copyWith(
          infoMessage: 'Clapier ${hutch.label} ajoute. Synchronisation a venir.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          errorMessage: 'Creation de clapier impossible : $error',
        ),
      );
    }
  }

  Future<void> recordMaintenance({
    required String hutchId,
    required DateTime cleaningDate,
    String? notes,
  }) async {
    try {
      await _hutchRepository.recordMaintenance(
        hutchId: hutchId,
        cleaningDate: cleaningDate,
        notes: notes,
      );
      emit(
        state.copyWith(
          infoMessage: 'Entretien enregistre.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          errorMessage: 'Echec de l enregistrement entretien : $error',
        ),
      );
    }
  }

  Future<void> assignLitter({
    required String hutchId,
    required HutchOccupant occupant,
  }) async {
    try {
      await _hutchRepository.assignLitter(
        hutchId: hutchId,
        occupant: occupant,
      );
      emit(
        state.copyWith(
          infoMessage: 'Portee ${occupant.litterCode} assignee a $hutchId.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          errorMessage: 'Assignation impossible : $error',
        ),
      );
    }
  }

  Future<void> saveKitWeights({
    required String litterId,
    required List<LitterKitWeightInput> payload,
  }) async {
    try {
      await _litterRepository.saveKitWeights(
        litterId: litterId,
        payload: payload,
      );
      emit(
        state.copyWith(
          infoMessage: 'Poids enregistres pour la portee.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          errorMessage: 'Impossible de mettre a jour les poids : $error',
        ),
      );
    }
  }

  void acknowledgeMessage() {
    if (state.infoMessage == null && state.errorMessage == null) {
      return;
    }
    emit(
      state.copyWith(
        infoMessage: null,
        errorMessage: null,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
