import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/food_stock.dart';
import '../../../../data/models/food_type.dart';
import '../../../../data/repositories/food_inventory_repository.dart';

class FoodInventoryState extends Equatable {
  const FoodInventoryState({
    this.types = const <FoodType>[],
    this.stock = const <FoodStockEntry>[],
    this.summary = const InventorySummary(
      totalQuantityKg: 0,
      totalCost: 0,
      entriesCount: 0,
      estimatedMonthlyConsumptionKg: 0,
    ),
    this.loading = false,
    this.saving = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<FoodType> types;
  final List<FoodStockEntry> stock;
  final InventorySummary summary;
  final bool loading;
  final bool saving;
  final String? errorMessage;
  final String? successMessage;

  FoodInventoryState copyWith({
    List<FoodType>? types,
    List<FoodStockEntry>? stock,
    InventorySummary? summary,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return FoodInventoryState(
      types: types ?? this.types,
      stock: stock ?? this.stock,
      summary: summary ?? this.summary,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    types,
    stock,
    summary,
    loading,
    saving,
    errorMessage,
    successMessage,
  ];
}

class FoodInventoryCubit extends Cubit<FoodInventoryState> {
  FoodInventoryCubit(this._repository, {required this.profileId})
    : super(const FoodInventoryState());

  final FoodInventoryRepository _repository;
  final String profileId;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _reload(showLoader: true);
  }

  Future<void> refresh() => _reload(showLoader: true);

  Future<void> saveFoodType({int? id, required String name}) async {
    emit(state.copyWith(saving: true, clearError: true, clearSuccess: true));
    final int resolvedId = id ?? _generateTemporaryId();
    final DateTime createdAt = id == null
        ? DateTime.now()
        : _findType(id)?.createdAt ?? DateTime.now();
    final FoodType type = FoodType(
      id: resolvedId,
      profileId: profileId,
      name: name.trim(),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
    try {
      final bool isUpdate = id != null;
      final FoodType result = isUpdate
          ? await _repository.updateFoodType(type)
          : await _repository.createFoodType(type);
      await _reload(
        showLoader: false,
        successMessage: isUpdate
            ? 'Type d\'aliment mis a jour.'
            : 'Type d\'aliment cree.',
      );
      if (!isUpdate && result.id != resolvedId) {
        await _reload(showLoader: false);
      }
    } catch (error) {
      emit(state.copyWith(saving: false, errorMessage: error.toString()));
    }
  }

  Future<void> deleteFoodType(int id) async {
    emit(state.copyWith(saving: true, clearError: true, clearSuccess: true));
    try {
      await _repository.deleteFoodType(id);
      await _reload(
        showLoader: false,
        successMessage: 'Type d\'aliment supprime.',
      );
    } catch (error) {
      emit(state.copyWith(saving: false, errorMessage: error.toString()));
    }
  }

  Future<void> saveFoodStock({
    int? id,
    required int? foodTypeId,
    required double quantityKg,
    double? cost,
    DateTime? purchaseDate,
  }) async {
    emit(state.copyWith(saving: true, clearError: true, clearSuccess: true));
    final DateTime now = DateTime.now();
    final FoodStockEntry? existing = _findEntry(id);
    final FoodStockEntry entry = FoodStockEntry(
      id: id ?? _generateTemporaryId(),
      profileId: profileId,
      foodTypeId: foodTypeId,
      quantityKg: quantityKg,
      cost: cost,
      purchaseDate: purchaseDate,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      final bool isUpdate = id != null;
      final FoodStockEntry result = isUpdate
          ? await _repository.updateFoodStock(entry)
          : await _repository.createFoodStock(entry);
      await _reload(
        showLoader: false,
        successMessage: isUpdate
            ? 'Entree de stock mise a jour.'
            : 'Entree de stock ajoutee.',
      );
      if (!isUpdate && result.id != entry.id) {
        await _reload(showLoader: false);
      }
    } catch (error) {
      emit(state.copyWith(saving: false, errorMessage: error.toString()));
    }
  }

  Future<void> deleteFoodStock(int id) async {
    emit(state.copyWith(saving: true, clearError: true, clearSuccess: true));
    try {
      await _repository.deleteFoodStock(id);
      await _reload(
        showLoader: false,
        successMessage: 'Entree de stock supprimee.',
      );
    } catch (error) {
      emit(state.copyWith(saving: false, errorMessage: error.toString()));
    }
  }

  void acknowledgeFeedback() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  FoodType? _findType(int? id) {
    if (id == null) {
      return null;
    }
    for (final FoodType type in state.types) {
      if (type.id == id) {
        return type;
      }
    }
    return null;
  }

  FoodStockEntry? _findEntry(int? id) {
    if (id == null) {
      return null;
    }
    for (final FoodStockEntry entry in state.stock) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  Future<void> _reload({
    required bool showLoader,
    String? successMessage,
  }) async {
    if (showLoader) {
      emit(state.copyWith(loading: true, clearError: true, clearSuccess: true));
    }
    try {
      final List<FoodType> types = await _repository.fetchFoodTypes(profileId);
      final List<FoodStockEntry> stock = await _repository.fetchFoodStock(
        profileId,
      );
      final InventorySummary summary = await _repository.computeSummary(
        profileId,
      );
      emit(
        state.copyWith(
          types: types,
          stock: stock,
          summary: summary,
          loading: false,
          saving: false,
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
