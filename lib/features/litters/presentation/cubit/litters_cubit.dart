import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/litter.dart';
import '../../../../data/repositories/litter_repository.dart';

enum LittersStatus { initial, loading, success, failure }

class LittersState extends Equatable {
  const LittersState({
    this.status = LittersStatus.initial,
    this.litters = const <Litter>[],
    this.selectedIds = const <String>{},
    this.errorMessage,
    this.infoMessage,
  });

  final LittersStatus status;
  final List<Litter> litters;
  final Set<String> selectedIds;
  final String? errorMessage;
  final String? infoMessage;

  bool get hasSelection => selectedIds.isNotEmpty;

  bool get hasPendingSync => litters.any((Litter litter) => litter.hasPendingSync);

  LittersState copyWith({
    LittersStatus? status,
    List<Litter>? litters,
    Set<String>? selectedIds,
    String? errorMessage,
    String? infoMessage,
  }) {
    return LittersState(
      status: status ?? this.status,
      litters: litters ?? this.litters,
      selectedIds: selectedIds ?? this.selectedIds,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        litters,
        selectedIds,
        errorMessage,
        infoMessage,
      ];
}

class LittersCubit extends Cubit<LittersState> {
  LittersCubit(this._repository) : super(const LittersState());

  final LitterRepository _repository;
  StreamSubscription<List<Litter>>? _subscription;

  Future<void> load() async {
    emit(state.copyWith(status: LittersStatus.loading, errorMessage: null, infoMessage: null));
    try {
      final List<Litter> items = await _repository.fetchLitters();
      emit(
        state.copyWith(
          status: LittersStatus.success,
          litters: items,
        ),
      );
      await _subscription?.cancel();
      _subscription = _repository.watchLitters().listen((List<Litter> items) {
        emit(
          state.copyWith(
            status: LittersStatus.success,
            litters: items,
          ),
        );
      });
    } catch (error) {
      emit(
        state.copyWith(
          status: LittersStatus.failure,
          errorMessage: 'Impossible de charger les portees : $error',
        ),
      );
    }
  }

  void toggleSelection(String litterId) {
    final Set<String> updated = Set<String>.from(state.selectedIds);
    if (!updated.add(litterId)) {
      updated.remove(litterId);
    }
    emit(state.copyWith(selectedIds: updated, infoMessage: null, errorMessage: null));
  }

  void clearSelection() {
    if (state.selectedIds.isEmpty) {
      return;
    }
    emit(state.copyWith(selectedIds: <String>{}, infoMessage: null));
  }

  void selectAll() {
    if (state.litters.isEmpty) {
      return;
    }
    emit(
      state.copyWith(
        selectedIds: state.litters.map((Litter litter) => litter.id).toSet(),
        infoMessage: null,
      ),
    );
  }

  Future<void> createLitter(LitterDraft draft) async {
    try {
      final Litter litter = await _repository.createLitter(draft);
      emit(
        state.copyWith(
          infoMessage: 'Portee ${litter.code} creee. Synchronisation a venir.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          errorMessage: 'Creation impossible : $error',
        ),
      );
    }
  }

  Future<void> applyBatch(LitterBatchUpdate update) async {
    try {
      await _repository.updateLittersBatch(update);
      emit(
        state.copyWith(
          selectedIds: <String>{},
          infoMessage: 'Modifications appliquees a ${update.litterIds.length} portees.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          errorMessage: 'Echec de la mise a jour : $error',
        ),
      );
    }
  }

  Future<void> saveKitWeights({
    required String litterId,
    required List<LitterKitWeightInput> payload,
  }) async {
    try {
      await _repository.saveKitWeights(litterId: litterId, payload: payload);
      emit(
        state.copyWith(
          infoMessage: 'Poids enregistres pour la portee.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          errorMessage: 'Impossible d enregistrer les poids : $error',
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
