import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/local_data_sources.dart';
import '../models/litter.dart';
import '../models/sync_action.dart';
import '../services/api_client.dart';
import '../services/offline_sync_manager.dart';

const Uuid _uuid = Uuid();

abstract class LitterRepository {
  Future<List<Litter>> fetchLitters();

  Stream<List<Litter>> watchLitters();

  Future<Litter> createLitter(LitterDraft draft);

  Future<void> updateLittersBatch(LitterBatchUpdate update);

  Future<void> saveKitWeights({
    required String litterId,
    required List<LitterKitWeightInput> payload,
  });
}

class InMemoryLitterRepository implements LitterRepository {
  factory InMemoryLitterRepository() {
    _ensureInitialized();
    return _instance;
  }

  InMemoryLitterRepository._();

  static final InMemoryLitterRepository _instance =
      InMemoryLitterRepository._();

  static final List<Litter> _litters = <Litter>[];
  static final StreamController<List<Litter>> _controller =
      StreamController<List<Litter>>.broadcast();
  static bool _initialized = false;

  static void reset() {
    _litters
      ..clear()
      ..addAll(_seedLitters());
    _emit();
  }

  static void _ensureInitialized() {
    if (_initialized) {
      return;
    }
    _litters
      ..clear()
      ..addAll(_seedLitters());
    _emit();
    _initialized = true;
  }

  static List<Litter> _seedLitters() {
    final DateTime now = DateTime.now();
    return <Litter>[
      Litter(
        id: 'litter-001',
        code: 'P-2025-18',
        doeTag: 'F01',
        buckTag: 'M12',
        breedingDate: now.subtract(const Duration(days: 35)),
        kindlingDate: now.subtract(const Duration(days: 5)),
        bornAlive: 8,
        bornDead: 1,
        expectedWeaned: 7,
        cage: 'C-205',
        enclosure: 'Enclos plein air 2',
        status: LitterStatus.weaning,
        notes: 'Cycle reproduction standard',
        kits: List<LitterKit>.generate(
          7,
          (int index) => LitterKit(
            id: 'kit-001-${index + 1}',
            tag: 'K1${index + 1}',
            sex: index.isEven ? 'Femelle' : 'Male',
            birthWeightGrams: 45 + index.toDouble(),
            weaningWeightGrams: index.isEven ? 720 : null,
            preSlaughterWeightGrams: null,
            carcassWeightKg: null,
            marketValue: null,
            destination: 'Garde',
          ),
        ),
      ),
      Litter(
        id: 'litter-002',
        code: 'P-2025-17',
        doeTag: 'F02',
        buckTag: 'M01',
        breedingDate: now.subtract(const Duration(days: 62)),
        kindlingDate: now.subtract(const Duration(days: 27)),
        bornAlive: 6,
        bornDead: 0,
        expectedWeaned: 6,
        cage: 'C-210',
        status: LitterStatus.harvestReady,
        kits: List<LitterKit>.generate(
          6,
          (int index) => LitterKit(
            id: 'kit-002-${index + 1}',
            tag: 'J${index + 1}',
            sex: index.isOdd ? 'Femelle' : 'Male',
            birthWeightGrams: 46 + index.toDouble(),
            weaningWeightGrams: 820 + index * 20,
            preSlaughterWeightGrams: 1850 + index * 30,
            carcassWeightKg: 1.4 + index * 0.05,
            marketValue: 8500 + index * 500,
            destination: index.isOdd ? 'Abattu' : 'Vendu',
          ),
        ),
      ),
    ];
  }

  static void _emit() {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(List<Litter>.unmodifiable(_litters));
  }

  @override
  Future<List<Litter>> fetchLitters() async {
    final List<Litter> items = List<Litter>.from(_litters);
    items.sort(
      (Litter a, Litter b) => b.kindlingDate.compareTo(a.kindlingDate),
    );
    return items;
  }

  @override
  Stream<List<Litter>> watchLitters() async* {
    yield List<Litter>.unmodifiable(_litters);
    yield* _controller.stream;
  }

  @override
  Future<Litter> createLitter(LitterDraft draft) async {
    final Litter litter = _createLitterFromDraft(draft);
    _litters.insert(0, litter);
    _emit();
    return litter;
  }

  @override
  Future<void> updateLittersBatch(LitterBatchUpdate update) async {
    for (final String id in update.litterIds) {
      final int index =
          _litters.indexWhere((Litter element) => element.id == id);
      if (index == -1) {
        continue;
      }
      final Litter current = _litters[index];
      _litters[index] = current.copyWith(
        status: update.status ?? current.status,
        cage: update.cage ?? current.cage,
        enclosure: update.enclosure ?? current.enclosure,
        notes: update.notes ?? current.notes,
        nextReminder: update.nextReminder ?? current.nextReminder,
      );
    }
    _emit();
  }

  @override
  Future<void> saveKitWeights({
    required String litterId,
    required List<LitterKitWeightInput> payload,
  }) async {
    final int index =
        _litters.indexWhere((Litter element) => element.id == litterId);
    if (index == -1) {
      return;
    }

    final Litter litter = _litters[index];
    final List<LitterKit> updatedKits = litter.kits
        .map((LitterKit kit) {
          final LitterKitWeightInput? entry = payload.firstWhereOrNull(
            (LitterKitWeightInput item) => item.kitId == kit.id,
          );
          if (entry == null) {
            return kit;
          }
          return kit.copyWith(
            weaningWeightGrams:
                entry.weaningWeightGrams ?? kit.weaningWeightGrams,
            preSlaughterWeightGrams:
                entry.preSlaughterWeightGrams ?? kit.preSlaughterWeightGrams,
            carcassWeightKg: entry.carcassWeightKg ?? kit.carcassWeightKg,
            marketValue: entry.marketValue ?? kit.marketValue,
            destination: entry.destination ?? kit.destination,
          );
        })
        .toList(growable: false);

    _litters[index] = litter.copyWith(kits: updatedKits);
    _emit();
  }

  Litter _createLitterFromDraft(LitterDraft draft) {
    return Litter(
      id: _uuid.v4(),
      code: draft.code,
      doeTag: draft.doeTag,
      buckTag: draft.buckTag,
      breedingDate: draft.breedingDate,
      kindlingDate: draft.kindlingDate,
      bornAlive: draft.bornAlive,
      bornDead: draft.bornDead,
      expectedWeaned: draft.expectedWeaned,
      cage: draft.cage,
      enclosure: draft.enclosure,
      status: LitterStatus.gestating,
      notes: draft.notes,
      taskTemplateName: draft.taskTemplateName,
      kits: List<LitterKit>.generate(
        draft.expectedWeaned,
        (int index) => LitterKit(
          id: _uuid.v4(),
          tag: 'K${index + 1}',
          sex: index.isEven ? 'Femelle' : 'Male',
        ),
      ),
    );
  }
}

class SupabaseLitterRepository implements LitterRepository {
  SupabaseLitterRepository({ApiExecutor? apiClient})
    : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<List<Litter>> fetchLitters() async {
    final List<dynamic> rows = await _api.run((SupabaseClient client) {
      return client
          .from('litters')
          .select('*, kits:litter_kits(*)')
          .order('kindling_date', ascending: false);
    }, label: 'litters.fetch');
    return rows
        .map((dynamic row) => Litter.fromJson(_normalizeRow(row)))
        .toList();
  }

  @override
  Stream<List<Litter>> watchLitters() =>
      Stream<List<Litter>>.fromFuture(fetchLitters());

  @override
  Future<Litter> createLitter(LitterDraft draft) async {
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      return client
          .from('litters')
          .insert(draft.toJson())
          .select('*, kits:litter_kits(*)');
    }, label: 'litters.create');
    return Litter.fromJson(_normalizeRow(response.first));
  }

  @override
  Future<void> updateLittersBatch(LitterBatchUpdate update) async {
    final Map<String, dynamic> payload = <String, dynamic>{};
    if (update.status != null) {
      payload['status'] = update.status!.storageValue;
    }
    if (update.cage != null) {
      payload['cage'] = update.cage;
    }
    if (update.enclosure != null) {
      payload['enclosure'] = update.enclosure;
    }
    if (update.notes != null) {
      payload['notes'] = update.notes;
    }
    if (update.nextReminder != null) {
      payload['next_reminder'] = update.nextReminder!.toIso8601String();
    }
    if (payload.isEmpty) {
      return;
    }
    await _api.run((SupabaseClient client) {
      final PostgrestFilterBuilder<dynamic> query =
          client.from('litters').update(payload);
      if (update.litterIds.length == 1) {
        return query.eq('id', update.litterIds.first);
      }
      return query.inFilter('id', update.litterIds);
    }, label: 'litters.batchUpdate');
  }

  @override
  Future<void> saveKitWeights({
    required String litterId,
    required List<LitterKitWeightInput> payload,
  }) async {
    if (payload.isEmpty) {
      return;
    }
    final List<Map<String, dynamic>> updates = payload
        .map((LitterKitWeightInput input) {
          return <String, dynamic>{
            'id': input.kitId,
            'litter_id': litterId,
            'weaning_weight_grams': input.weaningWeightGrams,
            'pre_slaughter_weight_grams': input.preSlaughterWeightGrams,
            'carcass_weight_kg': input.carcassWeightKg,
            'market_value': input.marketValue,
            'destination': input.destination,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          };
        })
        .toList(growable: false);
    await _api.run((SupabaseClient client) {
      return client
          .from('litter_kits')
          .upsert(updates, onConflict: 'id');
    }, label: 'litters.saveWeights');
  }

  Map<String, dynamic> _normalizeRow(dynamic raw) {
    final Map<String, dynamic> json =
        Map<String, dynamic>.from(raw as Map<String, dynamic>);
    final List<dynamic> kits = (json['kits'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic item) => Map<String, dynamic>.from(
              item as Map<String, dynamic>,
            ))
        .toList();
    json['kits'] = kits;
    return json;
  }
}

class SyncedLitterRepository implements LitterRepository {
  SyncedLitterRepository({
    required LitterRepository remote,
    required LocalLitterDataSource local,
    OfflineSyncManager? offlineManager,
  })  : _remote = remote,
        _local = local,
        _offlineManager = offlineManager ?? OfflineSyncManager.instance {
    _registerHandlers();
  }

  final LitterRepository _remote;
  final LocalLitterDataSource _local;
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
  Future<List<Litter>> fetchLitters() async {
    final String? profileId = _currentProfileId;
    if (profileId == null) {
      return const <Litter>[];
    }

    if (_offlineManager.isOffline.value) {
      return _local.fetchLitters(profileId: profileId);
    }

    try {
      final List<Litter> litters = await _remote.fetchLitters();
      await _local.replaceLitters(litters, profileId: profileId);
      return litters;
    } catch (error) {
      final List<Litter> cached = await _local.fetchLitters(
        profileId: profileId,
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Stream<List<Litter>> watchLitters() {
    final String? profileId = _currentProfileId;
    if (profileId == null) {
      return Stream<List<Litter>>.value(const <Litter>[]);
    }
    return _local.watchLitters(profileId: profileId);
  }

  @override
  Future<Litter> createLitter(LitterDraft draft) async {
    final String? profileId = _currentProfileId;
    if (profileId == null) {
      throw StateError(
        'Impossible de créer une portée sans profil authentifié.',
      );
    }

    if (_offlineManager.isOffline.value) {
      final Litter pending = _buildPendingLitter(draft).copyWith(
        hasPendingSync: true,
      );
      await _local.upsertLitter(
        pending,
        profileId: profileId,
        syncState: kSyncStatePending,
      );
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.createLitter,
          description: 'Créer la portée ${pending.code}',
          payload: <String, dynamic>{
            'draft': draft.toJson(),
            'litter_id': pending.id,
          },
        ),
      );
      return pending;
    }

    final Litter created = await _remote.createLitter(draft);
    await _local.upsertLitter(
      created,
      profileId: profileId,
      syncState: kSyncStateSynced,
    );
    return created;
  }

  @override
  Future<void> updateLittersBatch(LitterBatchUpdate update) async {
    final String? profileId = _currentProfileId;
    if (profileId == null) {
      throw StateError('Aucun profil connecté.');
    }

    if (_offlineManager.isOffline.value) {
      await _applyBatchLocally(
        update,
        profileId: profileId,
        syncState: kSyncStatePending,
      );
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.updateLitterBatch,
          description:
              'Mettre à jour ${update.litterIds.length} portées',
          payload: update.toJson(),
        ),
      );
      return;
    }

    await _remote.updateLittersBatch(update);
    await _refreshFromRemote();
  }

  @override
  Future<void> saveKitWeights({
    required String litterId,
    required List<LitterKitWeightInput> payload,
  }) async {
    final String? profileId = _currentProfileId;
    if (profileId == null) {
      throw StateError('Aucun profil connecté.');
    }

    if (_offlineManager.isOffline.value) {
      await _saveWeightsLocally(
        litterId,
        payload,
        profileId: profileId,
        syncState: kSyncStatePending,
      );
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.saveLitterWeights,
          description: 'Mettre à jour les poids de $litterId',
          payload: <String, dynamic>{
            'litter_id': litterId,
            'weights': payload
                .map((LitterKitWeightInput input) => input.toJson())
                .toList(),
          },
        ),
      );
      return;
    }

    await _remote.saveKitWeights(litterId: litterId, payload: payload);
    await _refreshFromRemote();
  }

  Future<void> _refreshFromRemote() async {
    final String? profileId = _currentProfileId;
    if (profileId == null) {
      return;
    }
    try {
      final List<Litter> litters = await _remote.fetchLitters();
      await _local.replaceLitters(litters, profileId: profileId);
    } catch (error) {
      debugPrint('Impossible de rafraîchir les portées : $error');
    }
  }

  Future<void> _applyBatchLocally(
    LitterBatchUpdate update, {
    required String profileId,
    String syncState = kSyncStateSynced,
  }) async {
    for (final String id in update.litterIds) {
      final Litter? litter = await _local.fetchLitterById(
        id,
        profileId: profileId,
      );
      if (litter == null) {
        continue;
      }
      final Litter updated = litter.copyWith(
        status: update.status ?? litter.status,
        cage: update.cage ?? litter.cage,
        enclosure: update.enclosure ?? litter.enclosure,
        notes: update.notes ?? litter.notes,
        nextReminder: update.nextReminder ?? litter.nextReminder,
        hasPendingSync: syncState == kSyncStatePending
            ? true
            : litter.hasPendingSync,
      );
      await _local.upsertLitter(
        updated,
        profileId: profileId,
        syncState: syncState,
      );
    }
  }

  Future<void> _saveWeightsLocally(
    String litterId,
    List<LitterKitWeightInput> payload, {
    required String profileId,
    String syncState = kSyncStateSynced,
  }) async {
    final Litter? litter = await _local.fetchLitterById(
      litterId,
      profileId: profileId,
    );
    if (litter == null) {
      return;
    }
    final List<LitterKit> updatedKits = litter.kits
        .map((LitterKit kit) {
          final LitterKitWeightInput? entry = payload.firstWhereOrNull(
            (LitterKitWeightInput element) => element.kitId == kit.id,
          );
          if (entry == null) {
            return kit;
          }
          return kit.copyWith(
            weaningWeightGrams:
                entry.weaningWeightGrams ?? kit.weaningWeightGrams,
            preSlaughterWeightGrams:
                entry.preSlaughterWeightGrams ?? kit.preSlaughterWeightGrams,
            carcassWeightKg: entry.carcassWeightKg ?? kit.carcassWeightKg,
            marketValue: entry.marketValue ?? kit.marketValue,
            destination: entry.destination ?? kit.destination,
            hasPendingSync: syncState == kSyncStatePending
                ? true
                : kit.hasPendingSync,
          );
        })
        .toList(growable: false);

    await _local.upsertLitter(
      litter.copyWith(
        kits: updatedKits,
        hasPendingSync:
            syncState == kSyncStatePending ? true : litter.hasPendingSync,
      ),
      profileId: profileId,
      syncState: syncState,
    );
  }

  static Litter _buildPendingLitter(LitterDraft draft) {
    return Litter(
      id: _uuid.v4(),
      code: draft.code,
      doeTag: draft.doeTag,
      buckTag: draft.buckTag,
      breedingDate: draft.breedingDate,
      kindlingDate: draft.kindlingDate,
      bornAlive: draft.bornAlive,
      bornDead: draft.bornDead,
      expectedWeaned: draft.expectedWeaned,
      cage: draft.cage,
      enclosure: draft.enclosure,
      status: LitterStatus.gestating,
      notes: draft.notes,
      taskTemplateName: draft.taskTemplateName,
      kits: List<LitterKit>.generate(
        draft.expectedWeaned,
        (int index) => LitterKit(
          id: _uuid.v4(),
          tag: 'K${index + 1}',
          sex: index.isEven ? 'Femelle' : 'Male',
        ),
      ),
    );
  }

  void _registerHandlers() {
    if (_handlersRegistered) {
      return;
    }
    _handlersRegistered = true;

    _offlineManager.registerHandler(
      SyncActionType.createLitter,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> draftJson =
            action.payload['draft'] as Map<String, dynamic>;
        final LitterDraft draft = LitterDraft.fromJson(draftJson);
        await _remote.createLitter(draft);
        await _refreshFromRemote();
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final String? litterId = action.payload['litter_id'] as String?;
        final String? profileId = _currentProfileId;
        if (litterId != null && profileId != null) {
          await _local.deleteLitter(litterId, profileId: profileId);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.updateLitterBatch,
      (QueuedSyncAction action) async {
        final LitterBatchUpdate update =
            LitterBatchUpdate.fromJson(action.payload);
        await _remote.updateLittersBatch(update);
        await _refreshFromRemote();
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.saveLitterWeights,
      (QueuedSyncAction action) async {
        final String litterId = action.payload['litter_id'] as String;
        final List<dynamic> weightsRaw =
            action.payload['weights'] as List<dynamic>? ?? <dynamic>[];
        final List<LitterKitWeightInput> weights = weightsRaw
            .map(
              (dynamic item) =>
                  LitterKitWeightInput.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        await _remote.saveKitWeights(litterId: litterId, payload: weights);
        await _refreshFromRemote();
      },
    );
  }
}
