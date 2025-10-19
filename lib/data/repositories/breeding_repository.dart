import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/local_data_sources.dart';
import '../models/breeding_record.dart';
import '../models/sync_action.dart';
import '../services/api_client.dart';
import '../services/offline_sync_manager.dart';

abstract class BreedingRepository {
  Future<List<BreedingRecord>> fetchBreedingRecords();

  Future<BreedingRecord> createBreedingRecord(BreedingRecord record);

  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record);

  Future<void> deleteBreedingRecord(String id);
}

class InMemoryBreedingRepository implements BreedingRepository {
  factory InMemoryBreedingRepository() => _instance;

  InMemoryBreedingRepository._internal();

  static InMemoryBreedingRepository _instance =
      InMemoryBreedingRepository._internal();

  static void reset() {
    _instance = InMemoryBreedingRepository._internal();
  }

  final List<BreedingRecord> _records = <BreedingRecord>[
    BreedingRecord(
      id: 'breeding-001',
      profileId: 'demo-profile',
      doeId: 'doe-001',
      buckId: 'buck-001',
      matingDate: DateTime.now().subtract(const Duration(days: 34)),
      palpationDate: DateTime.now().subtract(const Duration(days: 22)),
      palpationPositive: true,
      kindlingDate: DateTime.now().subtract(const Duration(days: 3)),
      kitsBornAlive: 8,
      kitsBornDead: 1,
      adoptedKitsIn: 1,
    ),
    BreedingRecord(
      id: 'breeding-002',
      profileId: 'demo-profile',
      doeId: 'doe-002',
      buckId: 'buck-001',
      matingDate: DateTime.now().subtract(const Duration(days: 10)),
    ),
    BreedingRecord(
      id: 'breeding-003',
      profileId: 'demo-profile',
      doeId: 'doe-001',
      buckId: 'buck-002',
      matingDate: DateTime.now().subtract(const Duration(days: 80)),
      palpationDate: DateTime.now().subtract(const Duration(days: 68)),
      palpationPositive: true,
      kindlingDate: DateTime.now().subtract(const Duration(days: 49)),
      kitsBornAlive: 7,
      kitsWeaned: 7,
      weaningDate: DateTime.now().subtract(const Duration(days: 21)),
      averageWeaningWeight: 1.8,
      notes: 'Portée homogène, croissance régulière.',
    ),
    BreedingRecord(
      id: 'breeding-004',
      profileId: 'demo-profile',
      doeId: 'doe-003',
      buckId: 'buck-002',
      matingDate: DateTime.now().add(const Duration(days: 3)),
    ),
  ];

  @override
  Future<List<BreedingRecord>> fetchBreedingRecords() async {
    final List<BreedingRecord> records = List<BreedingRecord>.from(_records);
    records.sort(
      (BreedingRecord a, BreedingRecord b) =>
          b.matingDate.compareTo(a.matingDate),
    );
    return records;
  }

  @override
  Future<BreedingRecord> createBreedingRecord(BreedingRecord record) async {
    final BreedingRecord created = record.copyWith(
      id: 'breeding-${DateTime.now().millisecondsSinceEpoch}',
    );
    _records.add(created);
    return created;
  }

  @override
  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) async {
    final int index = _records.indexWhere(
      (BreedingRecord element) => element.id == record.id,
    );
    if (index == -1) {
      throw StateError('Saillie ${record.id} introuvable');
    }
    _records[index] = record;
    return record;
  }

  @override
  Future<void> deleteBreedingRecord(String id) async {
    _records.removeWhere((BreedingRecord record) => record.id == id);
  }
}

class SupabaseBreedingRepository implements BreedingRepository {
  SupabaseBreedingRepository({ApiExecutor? apiClient})
    : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<List<BreedingRecord>> fetchBreedingRecords() async {
    final List<dynamic> data = await _api.run((SupabaseClient client) {
      return client.from('breeding_records').select();
    }, label: 'breeding.fetch');
    return data
        .map(
          (dynamic row) => BreedingRecord.fromJson(row as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<BreedingRecord> createBreedingRecord(BreedingRecord record) async {
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      return client.from('breeding_records').insert(record.toJson()).select();
    }, label: 'breeding.create');
    return BreedingRecord.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) async {
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      return client
          .from('breeding_records')
          .update(record.toJson())
          .eq('id', record.id)
          .select();
    }, label: 'breeding.update');
    return BreedingRecord.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<void> deleteBreedingRecord(String id) {
    return _api.run((SupabaseClient client) {
      return client.from('breeding_records').delete().eq('id', id);
    }, label: 'breeding.delete');
  }
}

class SyncedBreedingRepository implements BreedingRepository {
  SyncedBreedingRepository({
    required BreedingRepository remote,
    required LocalBreedingDataSource local,
    OfflineSyncManager? offlineManager,
  }) : _remote = remote,
       _local = local,
       _offlineManager = offlineManager ?? OfflineSyncManager.instance {
    _registerHandlers();
  }

  final BreedingRepository _remote;
  final LocalBreedingDataSource _local;
  final OfflineSyncManager _offlineManager;
  static bool _handlersRegistered = false;
  String? get _currentProfileId {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BreedingRecord>> fetchBreedingRecords() async {
    if (_offlineManager.isOffline.value) {
      return _local.fetchBreedingRecords();
    }

    try {
      final List<BreedingRecord> records = await _remote.fetchBreedingRecords();
      if (records.isNotEmpty) {
        await _local.replaceBreedingRecords(
          records,
          profileId: _currentProfileId,
        );
      } else if (_currentProfileId != null) {
        await _local.replaceBreedingRecords(
          const <BreedingRecord>[],
          profileId: _currentProfileId,
        );
      }
      return records;
    } catch (error) {
      final List<BreedingRecord> cached = await _local.fetchBreedingRecords();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<BreedingRecord> createBreedingRecord(BreedingRecord record) async {
    if (_offlineManager.isOffline.value) {
      await _local.upsertBreedingRecord(record, syncState: kSyncStatePending);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.createBreeding,
          rollbackType: SyncActionType.deleteBreeding,
          description: 'Créer saillie ${record.id}',
          payload: <String, dynamic>{'record': record.toJson()},
          rollbackPayload: <String, dynamic>{'record_id': record.id},
          priority: 90,
          execute: () async {
            final BreedingRecord created = await _remote.createBreedingRecord(
              record,
            );
            await _local.upsertBreedingRecord(created);
          },
        ),
      );
      return record;
    }

    final BreedingRecord created = await _remote.createBreedingRecord(record);
    await _local.upsertBreedingRecord(created);
    return created;
  }

  @override
  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) async {
    if (_offlineManager.isOffline.value) {
      final BreedingRecord? previous = await _local.fetchBreedingRecordById(
        record.id,
      );
      await _local.upsertBreedingRecord(record, syncState: kSyncStatePending);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.updateBreeding,
          rollbackType: previous == null
              ? SyncActionType.deleteBreeding
              : SyncActionType.updateBreeding,
          description: 'Mettre à jour saillie ${record.id}',
          payload: <String, dynamic>{'record': record.toJson()},
          rollbackPayload: previous == null
              ? <String, dynamic>{'record_id': record.id}
              : <String, dynamic>{'record': previous.toJson()},
          priority: 70,
          execute: () async {
            final BreedingRecord updated = await _remote.updateBreedingRecord(
              record,
            );
            await _local.upsertBreedingRecord(updated);
          },
        ),
      );
      return record;
    }

    final BreedingRecord updated = await _remote.updateBreedingRecord(record);
    await _local.upsertBreedingRecord(updated);
    return updated;
  }

  @override
  Future<void> deleteBreedingRecord(String id) async {
    if (_offlineManager.isOffline.value) {
      final BreedingRecord? snapshot = await _local.fetchBreedingRecordById(id);
      await _local.deleteBreedingRecord(id);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.deleteBreeding,
          rollbackType: snapshot == null ? null : SyncActionType.createBreeding,
          description: 'Supprimer saillie $id',
          payload: <String, dynamic>{'record_id': id},
          rollbackPayload: snapshot == null
              ? null
              : <String, dynamic>{'record': snapshot.toJson()},
          priority: 60,
          execute: () async {
            await _remote.deleteBreedingRecord(id);
            await _local.deleteBreedingRecord(id);
          },
        ),
      );
      return;
    }
    await _remote.deleteBreedingRecord(id);
    await _local.deleteBreedingRecord(id);
  }

  void _registerHandlers() {
    if (_handlersRegistered) {
      return;
    }
    _handlersRegistered = true;

    _offlineManager.registerHandler(
      SyncActionType.createBreeding,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['record'] as Map<String, dynamic>;
        final BreedingRecord record = BreedingRecord.fromJson(raw);
        final BreedingRecord created = await _remote.createBreedingRecord(
          record,
        );
        await _local.upsertBreedingRecord(created);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final String? id = action.rollbackPayload?['record_id'] as String?;
        if (id != null) {
          await _local.deleteBreedingRecord(id);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.updateBreeding,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['record'] as Map<String, dynamic>;
        final BreedingRecord record = BreedingRecord.fromJson(raw);
        final BreedingRecord updated = await _remote.updateBreedingRecord(
          record,
        );
        await _local.upsertBreedingRecord(updated);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['record'] as Map<String, dynamic>?;
        if (raw != null) {
          await _local.upsertBreedingRecord(
            BreedingRecord.fromJson(raw),
            syncState: kSyncStateSynced,
          );
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.deleteBreeding,
      (QueuedSyncAction action) async {
        final String id = action.payload['record_id'] as String;
        await _remote.deleteBreedingRecord(id);
        await _local.deleteBreedingRecord(id);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['record'] as Map<String, dynamic>?;
        if (raw != null) {
          await _local.upsertBreedingRecord(BreedingRecord.fromJson(raw));
        }
      },
    );
  }
}
