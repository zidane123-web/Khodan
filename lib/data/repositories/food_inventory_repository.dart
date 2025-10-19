import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/local_data_sources.dart';
import '../models/food_stock.dart';
import '../models/food_type.dart';
import '../models/sync_action.dart';
import '../services/api_client.dart';
import '../services/offline_sync_manager.dart';

class InventorySummary {
  const InventorySummary({
    required this.totalQuantityKg,
    required this.totalCost,
    required this.entriesCount,
    required this.estimatedMonthlyConsumptionKg,
  });

  final double totalQuantityKg;
  final double totalCost;
  final int entriesCount;
  final double estimatedMonthlyConsumptionKg;

  factory InventorySummary.fromEntries(List<FoodStockEntry> entries) {
    final double totalQuantity = entries.fold<double>(
      0,
      (double sum, FoodStockEntry entry) => sum + entry.quantityKg,
    );
    final double totalCost = entries.fold<double>(
      0,
      (double sum, FoodStockEntry entry) => sum + (entry.cost ?? 0),
    );
    return InventorySummary(
      totalQuantityKg: totalQuantity,
      totalCost: totalCost,
      entriesCount: entries.length,
      estimatedMonthlyConsumptionKg: _calculateEstimatedMonthlyConsumption(
        entries,
      ),
    );
  }

  static double _calculateEstimatedMonthlyConsumption(
    List<FoodStockEntry> entries,
  ) {
    if (entries.isEmpty) {
      return 0;
    }
    final Map<int, double> quantityPerMonth = <int, double>{};
    for (final FoodStockEntry entry in entries) {
      final DateTime referenceDate = entry.purchaseDate ?? entry.createdAt;
      final int monthKey = referenceDate.year * 12 + referenceDate.month;
      quantityPerMonth.update(
        monthKey,
        (double previous) => previous + entry.quantityKg,
        ifAbsent: () => entry.quantityKg,
      );
    }
    final double total = quantityPerMonth.values.fold<double>(
      0,
      (double sum, double value) => sum + value,
    );
    return total / quantityPerMonth.length;
  }

  factory InventorySummary.fromJson(Map<String, dynamic> json) {
    return InventorySummary(
      totalQuantityKg: (json['total_quantity_kg'] as num?)?.toDouble() ?? 0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0,
      entriesCount: (json['entries_count'] as num?)?.toInt() ?? 0,
      estimatedMonthlyConsumptionKg:
          (json['estimated_monthly_consumption_kg'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'total_quantity_kg': totalQuantityKg,
      'total_cost': totalCost,
      'entries_count': entriesCount,
      'estimated_monthly_consumption_kg': estimatedMonthlyConsumptionKg,
    };
  }
}

abstract class FoodInventoryRepository {
  Future<List<FoodType>> fetchFoodTypes(String profileId);

  Future<List<FoodStockEntry>> fetchFoodStock(String profileId);

  Future<InventorySummary> computeSummary(String profileId);

  Future<FoodType> createFoodType(FoodType type);

  Future<FoodType> updateFoodType(FoodType type);

  Future<void> deleteFoodType(int id);

  Future<FoodStockEntry> createFoodStock(FoodStockEntry entry);

  Future<FoodStockEntry> updateFoodStock(FoodStockEntry entry);

  Future<void> deleteFoodStock(int id);
}

class SupabaseFoodInventoryRepository implements FoodInventoryRepository {
  SupabaseFoodInventoryRepository({ApiExecutor? apiClient})
    : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<List<FoodType>> fetchFoodTypes(String profileId) async {
    final List<dynamic> data = await _api.run((SupabaseClient client) {
      return client
          .from('food_types')
          .select()
          .eq('user_id', profileId)
          .order('name');
    }, label: 'foodTypes.fetch');
    return data
        .map(
          (dynamic row) =>
              FoodType.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  @override
  Future<List<FoodStockEntry>> fetchFoodStock(String profileId) async {
    final List<dynamic> data = await _api.run((SupabaseClient client) {
      return client
          .from('food_stock')
          .select()
          .eq('user_id', profileId)
          .order('created_at', ascending: false);
    }, label: 'foodStock.fetch');
    return data
        .map(
          (dynamic row) =>
              FoodStockEntry.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  @override
  Future<InventorySummary> computeSummary(String profileId) async {
    final List<FoodStockEntry> entries = await fetchFoodStock(profileId);
    return InventorySummary.fromEntries(entries);
  }

  @override
  Future<FoodType> createFoodType(FoodType type) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'user_id': type.profileId,
      'name': type.name,
    };
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      return client.from('food_types').insert(payload).select();
    }, label: 'foodTypes.create');
    return FoodType.fromJson(Map<String, dynamic>.from(response.first as Map));
  }

  @override
  Future<FoodType> updateFoodType(FoodType type) async {
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      return client
          .from('food_types')
          .update(<String, dynamic>{'name': type.name})
          .eq('id', type.id)
          .select();
    }, label: 'foodTypes.update');
    if (response.isEmpty) {
      throw StateError('Food type ${type.id} introuvable.');
    }
    return FoodType.fromJson(Map<String, dynamic>.from(response.first as Map));
  }

  @override
  Future<void> deleteFoodType(int id) async {
    await _api.run((SupabaseClient client) {
      return client.from('food_types').delete().eq('id', id);
    }, label: 'foodTypes.delete');
  }

  @override
  Future<FoodStockEntry> createFoodStock(FoodStockEntry entry) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'user_id': entry.profileId,
      'food_type_id': entry.foodTypeId,
      'quantity_kg': entry.quantityKg,
      'cost': entry.cost,
      'purchase_date': entry.purchaseDate?.toIso8601String(),
    };
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      return client.from('food_stock').insert(payload).select();
    }, label: 'foodStock.create');
    return FoodStockEntry.fromJson(
      Map<String, dynamic>.from(response.first as Map),
    );
  }

  @override
  Future<FoodStockEntry> updateFoodStock(FoodStockEntry entry) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'food_type_id': entry.foodTypeId,
      'quantity_kg': entry.quantityKg,
      'cost': entry.cost,
      'purchase_date': entry.purchaseDate?.toIso8601String(),
    };
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      return client
          .from('food_stock')
          .update(payload)
          .eq('id', entry.id)
          .select();
    }, label: 'foodStock.update');
    if (response.isEmpty) {
      throw StateError('Food stock ${entry.id} introuvable.');
    }
    return FoodStockEntry.fromJson(
      Map<String, dynamic>.from(response.first as Map),
    );
  }

  @override
  Future<void> deleteFoodStock(int id) async {
    await _api.run((SupabaseClient client) {
      return client.from('food_stock').delete().eq('id', id);
    }, label: 'foodStock.delete');
  }
}

class SyncedFoodInventoryRepository implements FoodInventoryRepository {
  SyncedFoodInventoryRepository({
    required FoodInventoryRepository remote,
    required LocalFoodTypeDataSource localTypes,
    required LocalFoodStockDataSource localStock,
    OfflineSyncManager? offlineManager,
  }) : _remote = remote,
       _localTypes = localTypes,
       _localStock = localStock,
       _offlineManager = offlineManager ?? OfflineSyncManager.instance {
    _registerHandlers();
  }

  final FoodInventoryRepository _remote;
  final LocalFoodTypeDataSource _localTypes;
  final LocalFoodStockDataSource _localStock;
  final OfflineSyncManager _offlineManager;
  bool _handlersRegistered = false;

  @override
  Future<List<FoodType>> fetchFoodTypes(String profileId) async {
    if (_offlineManager.isOffline.value) {
      return _localTypes.fetchFoodTypes(profileId);
    }
    try {
      final List<FoodType> types = await _remote.fetchFoodTypes(profileId);
      await _localTypes.replaceFoodTypes(types, profileId: profileId);
      return types;
    } catch (error) {
      final List<FoodType> cached = await _localTypes.fetchFoodTypes(profileId);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<List<FoodStockEntry>> fetchFoodStock(String profileId) async {
    if (_offlineManager.isOffline.value) {
      return _localStock.fetchEntries(profileId);
    }
    try {
      final List<FoodStockEntry> entries = await _remote.fetchFoodStock(
        profileId,
      );
      await _localStock.replaceEntries(entries, profileId: profileId);
      return entries;
    } catch (error) {
      final List<FoodStockEntry> cached = await _localStock.fetchEntries(
        profileId,
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<InventorySummary> computeSummary(String profileId) async {
    final List<FoodStockEntry> entries = await _localStock.fetchEntries(
      profileId,
    );
    return InventorySummary.fromEntries(entries);
  }

  @override
  Future<FoodType> createFoodType(FoodType type) async {
    if (_offlineManager.isOffline.value) {
      await _localTypes.upsertFoodTypes(<FoodType>[
        type,
      ], syncState: kSyncStatePending);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.createFoodType,
          description: 'Creer aliment ${type.name}',
          payload: <String, dynamic>{'food_type': type.toJson()},
          rollbackPayload: <String, dynamic>{'food_type': type.toJson()},
          priority: 70,
        ),
      );
      return type;
    }

    final FoodType created = await _remote.createFoodType(type);
    if (created.id != type.id) {
      await _localTypes.deleteFoodType(type.id);
    }
    await _localTypes.upsertFoodTypes(<FoodType>[created]);
    return created;
  }

  @override
  Future<FoodType> updateFoodType(FoodType type) async {
    if (_offlineManager.isOffline.value) {
      final FoodType? previous = await _localTypes.fetchFoodTypeById(type.id);
      await _localTypes.upsertFoodTypes(<FoodType>[
        type,
      ], syncState: kSyncStatePending);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.updateFoodType,
          description: 'Mettre a jour aliment ${type.name}',
          payload: <String, dynamic>{'food_type': type.toJson()},
          rollbackPayload: previous == null
              ? null
              : <String, dynamic>{'food_type': previous.toJson()},
          priority: 65,
        ),
      );
      return type;
    }

    final FoodType updated = await _remote.updateFoodType(type);
    await _localTypes.upsertFoodTypes(<FoodType>[updated]);
    return updated;
  }

  @override
  Future<void> deleteFoodType(int id) async {
    if (_offlineManager.isOffline.value) {
      final FoodType? snapshot = await _localTypes.fetchFoodTypeById(id);
      await _localTypes.deleteFoodType(id);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.deleteFoodType,
          description: 'Supprimer aliment $id',
          payload: <String, dynamic>{'food_type_id': id},
          rollbackPayload: snapshot == null
              ? null
              : <String, dynamic>{'food_type': snapshot.toJson()},
          priority: 60,
        ),
      );
      return;
    }

    await _remote.deleteFoodType(id);
    await _localTypes.deleteFoodType(id);
  }

  @override
  Future<FoodStockEntry> createFoodStock(FoodStockEntry entry) async {
    if (_offlineManager.isOffline.value) {
      await _localStock.upsertEntries(<FoodStockEntry>[
        entry,
      ], syncState: kSyncStatePending);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.createFoodStock,
          description: 'Ajouter stock ${entry.quantityKg} kg',
          payload: <String, dynamic>{'food_stock': entry.toJson()},
          rollbackPayload: <String, dynamic>{'food_stock': entry.toJson()},
          priority: 55,
        ),
      );
      return entry;
    }

    final FoodStockEntry created = await _remote.createFoodStock(entry);
    if (created.id != entry.id) {
      await _localStock.deleteEntry(entry.id);
    }
    await _localStock.upsertEntries(<FoodStockEntry>[created]);
    return created;
  }

  @override
  Future<FoodStockEntry> updateFoodStock(FoodStockEntry entry) async {
    if (_offlineManager.isOffline.value) {
      final FoodStockEntry? previous = await _localStock.fetchEntryById(
        entry.id,
      );
      await _localStock.upsertEntries(<FoodStockEntry>[
        entry,
      ], syncState: kSyncStatePending);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.updateFoodStock,
          description: 'Mettre a jour stock ${entry.id}',
          payload: <String, dynamic>{'food_stock': entry.toJson()},
          rollbackPayload: previous == null
              ? null
              : <String, dynamic>{'food_stock': previous.toJson()},
          priority: 50,
        ),
      );
      return entry;
    }

    final FoodStockEntry updated = await _remote.updateFoodStock(entry);
    await _localStock.upsertEntries(<FoodStockEntry>[updated]);
    return updated;
  }

  @override
  Future<void> deleteFoodStock(int id) async {
    if (_offlineManager.isOffline.value) {
      final FoodStockEntry? snapshot = await _localStock.fetchEntryById(id);
      await _localStock.deleteEntry(id);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.deleteFoodStock,
          description: 'Supprimer entree stock $id',
          payload: <String, dynamic>{'food_stock_id': id},
          rollbackPayload: snapshot == null
              ? null
              : <String, dynamic>{'food_stock': snapshot.toJson()},
          priority: 45,
        ),
      );
      return;
    }
    await _remote.deleteFoodStock(id);
    await _localStock.deleteEntry(id);
  }

  void _registerHandlers() {
    if (_handlersRegistered) {
      return;
    }
    _handlersRegistered = true;

    _offlineManager.registerHandler(
      SyncActionType.createFoodType,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['food_type'] as Map<String, dynamic>;
        final FoodType type = FoodType.fromJson(raw);
        final FoodType created = await _remote.createFoodType(type);
        if (created.id != type.id) {
          await _localTypes.deleteFoodType(type.id);
        }
        await _localTypes.upsertFoodTypes(<FoodType>[created]);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['food_type'] as Map<String, dynamic>?;
        if (raw != null) {
          await _localTypes.deleteFoodType(raw['id'] as int);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.updateFoodType,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['food_type'] as Map<String, dynamic>;
        final FoodType type = FoodType.fromJson(raw);
        final FoodType updated = await _remote.updateFoodType(type);
        await _localTypes.upsertFoodTypes(<FoodType>[updated]);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['food_type'] as Map<String, dynamic>?;
        if (raw != null) {
          await _localTypes.upsertFoodTypes(<FoodType>[
            FoodType.fromJson(raw),
          ], syncState: kSyncStateSynced);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.deleteFoodType,
      (QueuedSyncAction action) async {
        final int id = action.payload['food_type_id'] as int;
        await _remote.deleteFoodType(id);
        await _localTypes.deleteFoodType(id);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['food_type'] as Map<String, dynamic>?;
        if (raw != null) {
          await _localTypes.upsertFoodTypes(<FoodType>[
            FoodType.fromJson(raw),
          ], syncState: kSyncStateSynced);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.createFoodStock,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['food_stock'] as Map<String, dynamic>;
        final FoodStockEntry entry = FoodStockEntry.fromJson(raw);
        final FoodStockEntry created = await _remote.createFoodStock(entry);
        if (created.id != entry.id) {
          await _localStock.deleteEntry(entry.id);
        }
        await _localStock.upsertEntries(<FoodStockEntry>[created]);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['food_stock'] as Map<String, dynamic>?;
        if (raw != null) {
          await _localStock.deleteEntry(raw['id'] as int);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.updateFoodStock,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['food_stock'] as Map<String, dynamic>;
        final FoodStockEntry entry = FoodStockEntry.fromJson(raw);
        final FoodStockEntry updated = await _remote.updateFoodStock(entry);
        await _localStock.upsertEntries(<FoodStockEntry>[updated]);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['food_stock'] as Map<String, dynamic>?;
        if (raw != null) {
          await _localStock.upsertEntries(<FoodStockEntry>[
            FoodStockEntry.fromJson(raw),
          ], syncState: kSyncStateSynced);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.deleteFoodStock,
      (QueuedSyncAction action) async {
        final int id = action.payload['food_stock_id'] as int;
        await _remote.deleteFoodStock(id);
        await _localStock.deleteEntry(id);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['food_stock'] as Map<String, dynamic>?;
        if (raw != null) {
          await _localStock.upsertEntries(<FoodStockEntry>[
            FoodStockEntry.fromJson(raw),
          ], syncState: kSyncStateSynced);
        }
      },
    );
  }
}

class InMemoryFoodInventoryRepository implements FoodInventoryRepository {
  InMemoryFoodInventoryRepository();

  final List<FoodType> _types = <FoodType>[];
  final List<FoodStockEntry> _stock = <FoodStockEntry>[];

  @override
  Future<List<FoodType>> fetchFoodTypes(String profileId) async {
    return _types
        .where((FoodType type) => type.profileId == profileId)
        .toList();
  }

  @override
  Future<List<FoodStockEntry>> fetchFoodStock(String profileId) async {
    return _stock
        .where((FoodStockEntry entry) => entry.profileId == profileId)
        .toList();
  }

  @override
  Future<InventorySummary> computeSummary(String profileId) async {
    final List<FoodStockEntry> entries = await fetchFoodStock(profileId);
    return InventorySummary.fromEntries(entries);
  }

  @override
  Future<FoodType> createFoodType(FoodType type) async {
    _types.removeWhere((FoodType element) => element.id == type.id);
    _types.add(type);
    return type;
  }

  @override
  Future<FoodType> updateFoodType(FoodType type) async {
    await deleteFoodType(type.id);
    _types.add(type);
    return type;
  }

  @override
  Future<void> deleteFoodType(int id) async {
    _types.removeWhere((FoodType type) => type.id == id);
  }

  @override
  Future<FoodStockEntry> createFoodStock(FoodStockEntry entry) async {
    _stock.removeWhere((FoodStockEntry element) => element.id == entry.id);
    _stock.add(entry);
    return entry;
  }

  @override
  Future<FoodStockEntry> updateFoodStock(FoodStockEntry entry) async {
    await deleteFoodStock(entry.id);
    _stock.add(entry);
    return entry;
  }

  @override
  Future<void> deleteFoodStock(int id) async {
    _stock.removeWhere((FoodStockEntry entry) => entry.id == id);
  }
}
