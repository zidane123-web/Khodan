import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/local_data_sources.dart';
import '../models/ailment.dart';
import '../models/animal_event.dart';
import '../models/event.dart';
import '../models/health_record.dart';
import '../models/health_treatment.dart';
import '../models/sync_action.dart';
import '../services/api_client.dart';
import '../services/offline_sync_manager.dart';
import 'event_repository.dart';
import '../../features/notifications/services/local_notification_service.dart';

abstract class HealthRepository {
  Future<List<Ailment>> fetchAilments({
    String? query,
    int? speciesId,
    bool includeArchived = false,
  });

  Future<List<HealthRecord>> fetchRecords({
    String? animalId,
    bool includeArchived = false,
  });

  Future<HealthRecord?> fetchRecordById(String id);

  Future<List<HealthTreatment>> fetchTreatments(String recordId);

  Future<HealthRecord> createRecord(HealthRecord record);

  Future<HealthRecord> updateRecord(HealthRecord record);

  Future<void> deleteRecord(String id);

  Future<HealthTreatment> createTreatment(HealthTreatment treatment);

  Future<HealthTreatment> updateTreatment(HealthTreatment treatment);

  Future<void> deleteTreatment(HealthTreatment treatment);
}

class InMemoryHealthRepository implements HealthRepository {
  InMemoryHealthRepository() {
    final DateTime now = DateTime.now();
    final Ailment coccidiosis = Ailment(
      id: 'ailment-001',
      profileId: 'demo-profile',
      name: 'Coccidiosis',
      slug: 'coccidiosis',
      speciesId: 1,
      symptoms: const <HealthSymptom>[
        HealthSymptom(code: 'diarrhea', label: 'Diarrhea'),
        HealthSymptom(
          code: 'weight_loss',
          label: 'Weight loss',
          severity: 'high',
        ),
      ],
      commonCauses:
          'Protozoal infection triggered by contaminated feeders or waterers.',
      recommendedTreatments: const <TreatmentSuggestion>[
        TreatmentSuggestion(
          name: 'Sulfa drug',
          description: 'Administer in drinking water for 5 days',
          defaultDurationDays: 5,
          defaultDosage: '1 ml per litre',
        ),
      ],
      preventiveActions:
          'Keep hutches dry, sanitise feeders weekly, rotate pastures where possible.',
      createdAt: now.subtract(const Duration(days: 12)),
      updatedAt: now.subtract(const Duration(days: 3)),
    );
    final Ailment heatStress = Ailment(
      id: 'ailment-002',
      profileId: 'demo-profile',
      name: 'Heat stress',
      slug: 'heat-stress',
      symptoms: const <HealthSymptom>[
        HealthSymptom(code: 'rapid_breathing', label: 'Rapid breathing'),
        HealthSymptom(code: 'lethargy', label: 'Lethargy'),
      ],
      recommendedTreatments: const <TreatmentSuggestion>[
        TreatmentSuggestion(
          name: 'Hydration boost',
          description: 'Provide electrolytes and fresh cool water.',
          defaultDurationDays: 3,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 21)),
      updatedAt: now.subtract(const Duration(days: 7)),
    );
    _ailments.addAll(<Ailment>[coccidiosis, heatStress]);

    final HealthRecord record = HealthRecord(
      id: 'record-001',
      profileId: 'demo-profile',
      animalId: 'doe-001',
      ailmentId: coccidiosis.id,
      customDiagnosis: null,
      status: HealthRecordStatus.active,
      severity: HealthSeverity.high,
      symptoms: coccidiosis.symptoms,
      notes: 'Observed watery stools, introduced sulfa treatment.',
      onsetDate: now.subtract(const Duration(days: 2)),
      resolvedAt: null,
      nextCheckAt: now.add(const Duration(days: 3)),
      offlineReference: null,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now,
      treatments: const <HealthTreatment>[],
    );

    final HealthTreatment treatment = HealthTreatment(
      id: 'treatment-001',
      recordId: record.id,
      profileId: 'demo-profile',
      title: 'Sulfa drug',
      treatmentType: HealthTreatmentType.medication,
      dosage: '1 ml / litre',
      frequency: 'Daily',
      startAt: now.subtract(const Duration(days: 1)),
      endAt: now.add(const Duration(days: 3)),
      completedAt: null,
      notes: 'Ensure rabbit continues eating. Monitor hydration.',
      taskId: 'event-treatment-001',
      reminderMinutes: const <int>[0, -60],
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(hours: 6)),
    );

    _records.add(record.copyWith(treatments: <HealthTreatment>[treatment]));
    _treatments[treatment.id] = treatment;
  }

  final List<Ailment> _ailments = <Ailment>[];
  final List<HealthRecord> _records = <HealthRecord>[];
  final Map<String, HealthTreatment> _treatments = <String, HealthTreatment>{};

  @override
  Future<List<Ailment>> fetchAilments({
    String? query,
    int? speciesId,
    bool includeArchived = false,
  }) async {
    Iterable<Ailment> ailments = _ailments;
    if (speciesId != null) {
      ailments = ailments.where(
        (Ailment ailment) => ailment.speciesId == speciesId,
      );
    }
    if (query != null && query.trim().isNotEmpty) {
      final String lower = query.trim().toLowerCase();
      ailments = ailments.where(
        (Ailment ailment) => ailment.name.toLowerCase().contains(lower),
      );
    }
    if (!includeArchived) {
      ailments = ailments.where((Ailment ailment) => !ailment.isArchived);
    }
    return ailments.toList()
      ..sort((Ailment a, Ailment b) => a.name.compareTo(b.name));
  }

  @override
  Future<List<HealthRecord>> fetchRecords({
    String? animalId,
    bool includeArchived = false,
  }) async {
    Iterable<HealthRecord> records = _records;
    if (animalId != null) {
      records = records.where(
        (HealthRecord record) => record.animalId == animalId,
      );
    }
    if (!includeArchived) {
      records = records.where(
        (HealthRecord record) => record.status != HealthRecordStatus.archived,
      );
    }
    return records.toList()..sort(
      (HealthRecord a, HealthRecord b) => b.onsetDate.compareTo(a.onsetDate),
    );
  }

  @override
  Future<HealthRecord?> fetchRecordById(String id) async {
    for (final HealthRecord record in _records) {
      if (record.id == id) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<List<HealthTreatment>> fetchTreatments(String recordId) async {
    final HealthRecord? record = await fetchRecordById(recordId);
    if (record == null) {
      return const <HealthTreatment>[];
    }
    return record.treatments;
  }

  @override
  Future<HealthRecord> createRecord(HealthRecord record) async {
    _records.add(record);
    return record;
  }

  @override
  Future<HealthRecord> updateRecord(HealthRecord record) async {
    final int index = _records.indexWhere(
      (HealthRecord item) => item.id == record.id,
    );
    if (index == -1) {
      _records.add(record);
    } else {
      _records[index] = record;
    }
    return record;
  }

  @override
  Future<void> deleteRecord(String id) async {
    _records.removeWhere((HealthRecord record) => record.id == id);
    final List<String> toRemove = _treatments.values
        .where((HealthTreatment treatment) => treatment.recordId == id)
        .map((HealthTreatment treatment) => treatment.id)
        .toList();
    for (final String treatmentId in toRemove) {
      _treatments.remove(treatmentId);
    }
  }

  @override
  Future<HealthTreatment> createTreatment(HealthTreatment treatment) async {
    _treatments[treatment.id] = treatment;
    final int recordIndex = _records.indexWhere(
      (HealthRecord record) => record.id == treatment.recordId,
    );
    if (recordIndex != -1) {
      final HealthRecord record = _records[recordIndex];
      final List<HealthTreatment> treatments =
          record.treatments
              .where((HealthTreatment t) => t.id != treatment.id)
              .toList()
            ..add(treatment);
      _records[recordIndex] = record.copyWith(treatments: treatments);
    }
    return treatment;
  }

  @override
  Future<HealthTreatment> updateTreatment(HealthTreatment treatment) async {
    _treatments[treatment.id] = treatment;
    final int recordIndex = _records.indexWhere(
      (HealthRecord record) => record.id == treatment.recordId,
    );
    if (recordIndex != -1) {
      final HealthRecord record = _records[recordIndex];
      final List<HealthTreatment> treatments =
          record.treatments
              .where((HealthTreatment t) => t.id != treatment.id)
              .toList()
            ..add(treatment);
      _records[recordIndex] = record.copyWith(treatments: treatments);
    }
    return treatment;
  }

  @override
  Future<void> deleteTreatment(HealthTreatment treatment) async {
    _treatments.remove(treatment.id);
    final int recordIndex = _records.indexWhere(
      (HealthRecord record) => record.id == treatment.recordId,
    );
    if (recordIndex != -1) {
      final HealthRecord record = _records[recordIndex];
      final List<HealthTreatment> treatments = record.treatments
          .where((HealthTreatment t) => t.id != treatment.id)
          .toList();
      _records[recordIndex] = record.copyWith(treatments: treatments);
    }
  }
}

class SupabaseHealthRepository implements HealthRepository {
  SupabaseHealthRepository({ApiExecutor? apiClient})
    : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<List<Ailment>> fetchAilments({
    String? query,
    int? speciesId,
    bool includeArchived = false,
  }) async {
    final List<dynamic> data = await _api.run((SupabaseClient client) {
      dynamic request = client.from('ailments').select().order('name');
      if (!includeArchived) {
        request = request.is_('archived_at', null);
      }
      if (speciesId != null) {
        request = request.eq('species_id', speciesId);
      }
      if (query != null && query.trim().isNotEmpty) {
        final String pattern = '%${query.trim()}%';
        request = request.ilike('name', pattern);
      }
      return request;
    }, label: 'health.ailments.fetch');
    return data
        .map(
          (dynamic row) =>
              Ailment.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  @override
  Future<List<HealthRecord>> fetchRecords({
    String? animalId,
    bool includeArchived = false,
  }) async {
    final List<dynamic> data = await _api.run((SupabaseClient client) {
      dynamic request = client
          .from('health_records')
          .select('*, health_treatments(*)')
          .order('onset_date', ascending: false);
      if (!includeArchived) {
        request = request.neq('status', HealthRecordStatus.archived.key);
      }
      if (animalId != null) {
        request = request.eq('animal_id', animalId);
      }
      return request;
    }, label: 'health.records.fetch');
    return data
        .map(
          (dynamic row) =>
              HealthRecord.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  @override
  Future<HealthRecord?> fetchRecordById(String id) async {
    final Map<String, dynamic>? row = await _api.run((SupabaseClient client) {
      return client
          .from('health_records')
          .select('*, health_treatments(*)')
          .eq('id', id)
          .maybeSingle();
    }, label: 'health.records.fetchOne');
    if (row == null) {
      return null;
    }
    return HealthRecord.fromJson(Map<String, dynamic>.from(row));
  }

  @override
  Future<List<HealthTreatment>> fetchTreatments(String recordId) async {
    final List<dynamic> data = await _api.run((SupabaseClient client) {
      return client
          .from('health_treatments')
          .select()
          .eq('record_id', recordId)
          .order('start_at');
    }, label: 'health.treatments.fetch');
    return data
        .map(
          (dynamic row) =>
              HealthTreatment.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  @override
  Future<HealthRecord> createRecord(HealthRecord record) async {
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      return client
          .from('health_records')
          .insert(record.toJson(includeTreatments: false))
          .select('*, health_treatments(*)');
    }, label: 'health.records.create');
    return HealthRecord.fromJson(
      Map<String, dynamic>.from(response.first as Map),
    );
  }

  @override
  Future<HealthRecord> updateRecord(HealthRecord record) async {
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      final Map<String, dynamic> payload = record.toJson(
        includeTreatments: false,
      );
      return client
          .from('health_records')
          .update(payload)
          .eq('id', record.id)
          .select('*, health_treatments(*)');
    }, label: 'health.records.update');
    if (response.isEmpty) {
      throw StateError('Health record ${record.id} introuvable');
    }
    return HealthRecord.fromJson(
      Map<String, dynamic>.from(response.first as Map),
    );
  }

  @override
  Future<void> deleteRecord(String id) async {
    await _api.run((SupabaseClient client) {
      return client.from('health_records').delete().eq('id', id);
    }, label: 'health.records.delete');
  }

  @override
  Future<HealthTreatment> createTreatment(HealthTreatment treatment) async {
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      return client
          .from('health_treatments')
          .insert(treatment.toJson())
          .select();
    }, label: 'health.treatments.create');
    return HealthTreatment.fromJson(
      Map<String, dynamic>.from(response.first as Map),
    );
  }

  @override
  Future<HealthTreatment> updateTreatment(HealthTreatment treatment) async {
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      return client
          .from('health_treatments')
          .update(treatment.toJson())
          .eq('id', treatment.id)
          .select();
    }, label: 'health.treatments.update');
    if (response.isEmpty) {
      throw StateError('Health treatment ${treatment.id} introuvable');
    }
    return HealthTreatment.fromJson(
      Map<String, dynamic>.from(response.first as Map),
    );
  }

  @override
  Future<void> deleteTreatment(HealthTreatment treatment) async {
    await _api.run((SupabaseClient client) {
      return client.from('health_treatments').delete().eq('id', treatment.id);
    }, label: 'health.treatments.delete');
  }
}

class SyncedHealthRepository implements HealthRepository {
  SyncedHealthRepository({
    required HealthRepository remote,
    required LocalAilmentDataSource localAilments,
    required LocalHealthRecordDataSource localRecords,
    required EventRepository eventRepository,
    OfflineSyncManager? offlineManager,
    LocalNotificationService? notificationService,
    Uuid? uuid,
  }) : _remote = remote,
       _localAilments = localAilments,
       _localRecords = localRecords,
       _eventRepository = eventRepository,
       _offlineManager = offlineManager ?? OfflineSyncManager.instance,
       _notificationService =
           notificationService ?? LocalNotificationService.instance,
       _uuid = uuid ?? const Uuid() {
    _registerHandlers();
  }

  final HealthRepository _remote;
  final LocalAilmentDataSource _localAilments;
  final LocalHealthRecordDataSource _localRecords;
  final EventRepository _eventRepository;
  final OfflineSyncManager _offlineManager;
  final LocalNotificationService _notificationService;
  final Uuid _uuid;

  static bool _handlersRegistered = false;

  String? get _currentProfileId {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Ailment>> fetchAilments({
    String? query,
    int? speciesId,
    bool includeArchived = false,
  }) async {
    final String? profileId = _currentProfileId;
    if (_offlineManager.isOffline.value) {
      final List<Ailment> cached = await _localAilments.fetchAilments(
        profileId: profileId,
        includeArchived: includeArchived,
      );
      return _filterAilments(cached, query: query, speciesId: speciesId);
    }
    try {
      final List<Ailment> remote = await _remote.fetchAilments(
        query: query,
        speciesId: speciesId,
        includeArchived: includeArchived,
      );
      if (profileId != null) {
        await _localAilments.replaceAilments(remote, profileId: profileId);
      }
      return remote;
    } catch (_) {
      final List<Ailment> fallback = await _localAilments.fetchAilments(
        profileId: profileId,
        includeArchived: includeArchived,
      );
      if (fallback.isNotEmpty) {
        return _filterAilments(fallback, query: query, speciesId: speciesId);
      }
      rethrow;
    }
  }

  @override
  Future<List<HealthRecord>> fetchRecords({
    String? animalId,
    bool includeArchived = false,
  }) async {
    final String? profileId = _currentProfileId;
    if (_offlineManager.isOffline.value) {
      return _localRecords.fetchRecords(
        profileId: profileId,
        animalId: animalId,
        includeArchived: includeArchived,
      );
    }
    try {
      final List<HealthRecord> records = await _remote.fetchRecords(
        animalId: animalId,
        includeArchived: includeArchived,
      );
      if (profileId != null) {
        await _localRecords.replaceRecords(records, profileId: profileId);
      }
      return records;
    } catch (_) {
      final List<HealthRecord> fallback = await _localRecords.fetchRecords(
        profileId: profileId,
        animalId: animalId,
        includeArchived: includeArchived,
      );
      if (fallback.isNotEmpty) {
        return fallback;
      }
      rethrow;
    }
  }

  @override
  Future<HealthRecord?> fetchRecordById(String id) async {
    if (_offlineManager.isOffline.value) {
      return _localRecords.fetchRecordById(id);
    }
    try {
      final HealthRecord? record = await _remote.fetchRecordById(id);
      if (record != null) {
        await _localRecords.upsertRecord(record, syncState: kSyncStateSynced);
      }
      return record;
    } catch (_) {
      return _localRecords.fetchRecordById(id);
    }
  }

  @override
  Future<List<HealthTreatment>> fetchTreatments(String recordId) async {
    if (_offlineManager.isOffline.value) {
      return _localRecords.fetchTreatments(recordId);
    }
    try {
      final List<HealthTreatment> treatments = await _remote.fetchTreatments(
        recordId,
      );
      if (treatments.isNotEmpty) {
        await _localRecords.upsertTreatments(
          treatments,
          syncState: kSyncStateSynced,
        );
      }
      return treatments;
    } catch (_) {
      return _localRecords.fetchTreatments(recordId);
    }
  }

  @override
  Future<HealthRecord> createRecord(HealthRecord record) async {
    if (_offlineManager.isOffline.value) {
      await _localRecords.upsertRecord(record, syncState: kSyncStatePending);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.createHealthRecord,
          rollbackType: SyncActionType.deleteHealthRecord,
          description: 'Creer dossier sante ${record.id}',
          payload: <String, dynamic>{
            'record': record.toJson(includeTreatments: false),
          },
          rollbackPayload: <String, dynamic>{'record_id': record.id},
          priority: 85,
          execute: () async {
            final HealthRecord created = await _remote.createRecord(record);
            await _localRecords.upsertRecord(
              created,
              syncState: kSyncStateSynced,
            );
          },
        ),
      );
      return record;
    }

    final HealthRecord created = await _remote.createRecord(record);
    await _localRecords.upsertRecord(created, syncState: kSyncStateSynced);
    return created;
  }

  @override
  Future<HealthRecord> updateRecord(HealthRecord record) async {
    final HealthRecord? previous = await _localRecords.fetchRecordById(
      record.id,
    );
    if (_offlineManager.isOffline.value) {
      await _localRecords.upsertRecord(record, syncState: kSyncStatePending);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.updateHealthRecord,
          rollbackType: previous == null
              ? SyncActionType.deleteHealthRecord
              : SyncActionType.updateHealthRecord,
          description: 'Mettre a jour dossier sante ${record.id}',
          payload: <String, dynamic>{
            'record': record.toJson(includeTreatments: false),
          },
          rollbackPayload: previous == null
              ? <String, dynamic>{'record_id': record.id}
              : <String, dynamic>{
                  'record': previous.toJson(includeTreatments: false),
                },
          priority: 80,
          execute: () async {
            final HealthRecord updated = await _remote.updateRecord(record);
            await _localRecords.upsertRecord(
              updated,
              syncState: kSyncStateSynced,
            );
          },
        ),
      );
      return record;
    }

    final HealthRecord updated = await _remote.updateRecord(record);
    await _localRecords.upsertRecord(updated, syncState: kSyncStateSynced);
    return updated;
  }

  @override
  Future<void> deleteRecord(String id) async {
    final HealthRecord? snapshot = await _localRecords.fetchRecordById(id);
    if (_offlineManager.isOffline.value) {
      await _localRecords.deleteRecord(id);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.deleteHealthRecord,
          rollbackType: snapshot == null
              ? null
              : SyncActionType.createHealthRecord,
          description: 'Supprimer dossier sante $id',
          payload: <String, dynamic>{'record_id': id},
          rollbackPayload: snapshot == null
              ? null
              : <String, dynamic>{
                  'record': snapshot.toJson(includeTreatments: true),
                },
          priority: 70,
          execute: () async {
            await _remote.deleteRecord(id);
            await _localRecords.deleteRecord(id);
          },
        ),
      );
      return;
    }

    await _remote.deleteRecord(id);
    await _localRecords.deleteRecord(id);
  }

  @override
  Future<HealthTreatment> createTreatment(HealthTreatment treatment) async {
    final HealthRecord? record = await _loadRecord(treatment.recordId);
    if (record == null) {
      throw StateError(
        'Impossible de trouver le dossier sante ${treatment.recordId}',
      );
    }
    HealthTreatment effective = treatment;
    if (effective.taskId == null) {
      effective = await _ensureTreatmentEvent(effective, record);
    }

    if (_offlineManager.isOffline.value) {
      await _localRecords.upsertTreatment(
        effective,
        syncState: kSyncStatePending,
      );
      await _scheduleTreatmentReminders(effective, record: record);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.createHealthTreatment,
          rollbackType: SyncActionType.deleteHealthTreatment,
          description: 'Creer traitement ${effective.title}',
          payload: <String, dynamic>{'treatment': effective.toJson()},
          rollbackPayload: <String, dynamic>{
            'treatment_id': effective.id,
            'record_id': effective.recordId,
          },
          priority: 75,
          execute: () async {
            final HealthTreatment created = await _remote.createTreatment(
              effective,
            );
            await _localRecords.upsertTreatment(
              created,
              syncState: kSyncStateSynced,
            );
            await _scheduleTreatmentReminders(created, record: record);
          },
        ),
      );
      return effective;
    }

    final HealthTreatment created = await _remote.createTreatment(effective);
    await _localRecords.upsertTreatment(created, syncState: kSyncStateSynced);
    await _scheduleTreatmentReminders(created, record: record);
    return created;
  }

  @override
  Future<HealthTreatment> updateTreatment(HealthTreatment treatment) async {
    final HealthRecord? record = await _loadRecord(treatment.recordId);
    if (record == null) {
      throw StateError(
        'Impossible de trouver le dossier sante ${treatment.recordId}',
      );
    }

    final HealthTreatment? previous = await _getLocalTreatment(
      treatment.id,
      treatment.recordId,
    );
    HealthTreatment effective = treatment;
    if (effective.taskId == null) {
      effective = await _ensureTreatmentEvent(effective, record);
    }
    await _updateTreatmentEvent(effective, record);

    if (previous != null) {
      await _cancelTreatmentReminders(previous);
    }

    if (_offlineManager.isOffline.value) {
      await _localRecords.upsertTreatment(
        effective,
        syncState: kSyncStatePending,
      );
      await _scheduleTreatmentReminders(effective, record: record);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.updateHealthTreatment,
          rollbackType: previous == null
              ? SyncActionType.deleteHealthTreatment
              : SyncActionType.updateHealthTreatment,
          description: 'Mettre a jour traitement ${effective.title}',
          payload: <String, dynamic>{'treatment': effective.toJson()},
          rollbackPayload: previous == null
              ? <String, dynamic>{
                  'treatment_id': effective.id,
                  'record_id': effective.recordId,
                }
              : <String, dynamic>{'treatment': previous.toJson()},
          priority: 70,
          execute: () async {
            final HealthTreatment updated = await _remote.updateTreatment(
              effective,
            );
            await _localRecords.upsertTreatment(
              updated,
              syncState: kSyncStateSynced,
            );
            await _scheduleTreatmentReminders(updated, record: record);
          },
        ),
      );
      return effective;
    }

    final HealthTreatment updated = await _remote.updateTreatment(effective);
    await _localRecords.upsertTreatment(updated, syncState: kSyncStateSynced);
    await _scheduleTreatmentReminders(updated, record: record);
    return updated;
  }

  @override
  Future<void> deleteTreatment(HealthTreatment treatment) async {
    await _cancelTreatmentReminders(treatment);
    await _deleteTreatmentEvent(treatment);

    if (_offlineManager.isOffline.value) {
      await _localRecords.deleteTreatment(treatment.id);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.deleteHealthTreatment,
          rollbackType: SyncActionType.createHealthTreatment,
          description: 'Supprimer traitement ${treatment.title}',
          payload: <String, dynamic>{
            'treatment_id': treatment.id,
            'record_id': treatment.recordId,
          },
          rollbackPayload: <String, dynamic>{'treatment': treatment.toJson()},
          priority: 60,
          execute: () async {
            await _remote.deleteTreatment(treatment);
            await _localRecords.deleteTreatment(treatment.id);
          },
        ),
      );
      return;
    }

    await _remote.deleteTreatment(treatment);
    await _localRecords.deleteTreatment(treatment.id);
  }

  List<Ailment> _filterAilments(
    List<Ailment> ailments, {
    String? query,
    int? speciesId,
  }) {
    Iterable<Ailment> filtered = ailments;
    if (speciesId != null) {
      filtered = filtered.where(
        (Ailment ailment) =>
            ailment.speciesId == null || ailment.speciesId == speciesId,
      );
    }
    if (query != null && query.trim().isNotEmpty) {
      final String lower = query.trim().toLowerCase();
      filtered = filtered.where(
        (Ailment ailment) => ailment.name.toLowerCase().contains(lower),
      );
    }
    return filtered.toList()
      ..sort((Ailment a, Ailment b) => a.name.compareTo(b.name));
  }

  Future<HealthRecord?> _loadRecord(String recordId) async {
    final HealthRecord? local = await _localRecords.fetchRecordById(recordId);
    if (local != null) {
      return local;
    }
    final HealthRecord? remote = await _remote.fetchRecordById(recordId);
    if (remote != null) {
      await _localRecords.upsertRecord(remote, syncState: kSyncStateSynced);
    }
    return remote;
  }

  Future<HealthTreatment?> _getLocalTreatment(
    String treatmentId,
    String recordId,
  ) async {
    final List<HealthTreatment> treatments = await _localRecords
        .fetchTreatments(recordId);
    for (final HealthTreatment treatment in treatments) {
      if (treatment.id == treatmentId) {
        return treatment;
      }
    }
    return null;
  }

  Future<HealthTreatment> _ensureTreatmentEvent(
    HealthTreatment treatment,
    HealthRecord record,
  ) async {
    if (treatment.taskId != null) {
      return treatment;
    }
    final String eventId = _uuid.v4();
    final LivestockEvent event = LivestockEvent(
      id: eventId,
      profileId: treatment.profileId,
      eventType: 'health_treatment',
      eventDate: treatment.startAt,
      details: <String, dynamic>{
        'recordId': treatment.recordId,
        'title': treatment.title,
        'treatmentType': treatment.treatmentType.key,
        'reminderMinutes': treatment.reminderMinutes,
      },
      notes: treatment.notes,
    );
    final List<AnimalEventLink> links = <AnimalEventLink>[
      AnimalEventLink(
        eventId: eventId,
        animalId: record.animalId,
        role: 'subject',
      ),
    ];
    final LivestockEvent createdEvent = await _eventRepository.createEvent(
      event,
      links: links,
    );
    return treatment.copyWith(taskId: createdEvent.id);
  }

  Future<void> _updateTreatmentEvent(
    HealthTreatment treatment,
    HealthRecord record,
  ) async {
    if (treatment.taskId == null) {
      return;
    }
    final LivestockEvent event = LivestockEvent(
      id: treatment.taskId!,
      profileId: treatment.profileId,
      eventType: 'health_treatment',
      eventDate: treatment.startAt,
      details: <String, dynamic>{
        'recordId': treatment.recordId,
        'title': treatment.title,
        'treatmentType': treatment.treatmentType.key,
        'reminderMinutes': treatment.reminderMinutes,
        'status': treatment.isCompleted ? 'completed' : 'pending',
      },
      notes: treatment.notes,
    );
    await _eventRepository.updateEvent(event);
  }

  Future<void> _deleteTreatmentEvent(HealthTreatment treatment) async {
    if (treatment.taskId == null) {
      return;
    }
    await _eventRepository.deleteEvent(treatment.taskId!);
  }

  Future<void> _scheduleTreatmentReminders(
    HealthTreatment treatment, {
    HealthRecord? record,
  }) async {
    await _cancelTreatmentReminders(treatment);
    if (treatment.reminderMinutes.isEmpty) {
      return;
    }
    final HealthRecord? contextRecord =
        record ?? await _loadRecord(treatment.recordId);
    final String? body = contextRecord?.customDiagnosis;
    final String baseId = treatment.taskId ?? treatment.id;
    for (final int offset in treatment.reminderMinutes) {
      final DateTime trigger = treatment.startAt.add(Duration(minutes: offset));
      if (trigger.isBefore(DateTime.now())) {
        continue;
      }
      await _notificationService.scheduleTaskReminder(
        taskId: '$baseId#$offset',
        triggerAt: trigger,
        title: treatment.title,
        body: body,
        profileId: treatment.profileId,
        metadata: <String, dynamic>{
          'recordId': treatment.recordId,
          'treatmentType': treatment.treatmentType.key,
        },
      );
    }
  }

  Future<void> _cancelTreatmentReminders(HealthTreatment treatment) async {
    final String baseId = treatment.taskId ?? treatment.id;
    for (final int offset in treatment.reminderMinutes) {
      await _notificationService.cancelTaskReminder('$baseId#$offset');
    }
  }

  void _registerHandlers() {
    if (_handlersRegistered) {
      return;
    }
    _handlersRegistered = true;

    _offlineManager.registerHandler(
      SyncActionType.createHealthRecord,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw = Map<String, dynamic>.from(
          action.payload['record'] as Map,
        );
        final HealthRecord record = HealthRecord.fromJson(raw);
        final HealthRecord created = await _remote.createRecord(record);
        await _localRecords.upsertRecord(created, syncState: kSyncStateSynced);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final String? recordId =
            action.rollbackPayload?['record_id'] as String?;
        if (recordId != null) {
          await _localRecords.deleteRecord(recordId);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.updateHealthRecord,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw = Map<String, dynamic>.from(
          action.payload['record'] as Map,
        );
        final HealthRecord record = HealthRecord.fromJson(raw);
        final HealthRecord updated = await _remote.updateRecord(record);
        await _localRecords.upsertRecord(updated, syncState: kSyncStateSynced);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['record'] as Map<String, dynamic>?;
        if (raw != null) {
          final HealthRecord previous = HealthRecord.fromJson(raw);
          await _localRecords.upsertRecord(
            previous,
            syncState: kSyncStateSynced,
          );
          if (previous.treatments.isNotEmpty) {
            await _localRecords.upsertTreatments(
              previous.treatments,
              syncState: kSyncStateSynced,
            );
          }
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.deleteHealthRecord,
      (QueuedSyncAction action) async {
        final String recordId = action.payload['record_id'] as String;
        await _remote.deleteRecord(recordId);
        await _localRecords.deleteRecord(recordId);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['record'] as Map<String, dynamic>?;
        if (raw != null) {
          final HealthRecord record = HealthRecord.fromJson(raw);
          await _localRecords.upsertRecord(record, syncState: kSyncStateSynced);
          if (record.treatments.isNotEmpty) {
            await _localRecords.upsertTreatments(
              record.treatments,
              syncState: kSyncStateSynced,
            );
          }
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.createHealthTreatment,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw = Map<String, dynamic>.from(
          action.payload['treatment'] as Map,
        );
        final HealthTreatment treatment = HealthTreatment.fromJson(raw);
        final HealthTreatment created = await _remote.createTreatment(
          treatment,
        );
        await _localRecords.upsertTreatment(
          created,
          syncState: kSyncStateSynced,
        );
        final HealthRecord? record = await _loadRecord(created.recordId);
        if (record != null) {
          await _scheduleTreatmentReminders(created, record: record);
        }
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final String? treatmentId =
            action.rollbackPayload?['treatment_id'] as String?;
        if (treatmentId != null) {
          await _localRecords.deleteTreatment(treatmentId);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.updateHealthTreatment,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw = Map<String, dynamic>.from(
          action.payload['treatment'] as Map,
        );
        final HealthTreatment treatment = HealthTreatment.fromJson(raw);
        final HealthTreatment updated = await _remote.updateTreatment(
          treatment,
        );
        await _localRecords.upsertTreatment(
          updated,
          syncState: kSyncStateSynced,
        );
        final HealthRecord? record = await _loadRecord(updated.recordId);
        if (record != null) {
          await _updateTreatmentEvent(updated, record);
          await _scheduleTreatmentReminders(updated, record: record);
        }
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['treatment'] as Map<String, dynamic>?;
        if (raw != null) {
          final HealthTreatment previous = HealthTreatment.fromJson(raw);
          await _localRecords.upsertTreatment(
            previous,
            syncState: kSyncStateSynced,
          );
          await _scheduleTreatmentReminders(previous);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.deleteHealthTreatment,
      (QueuedSyncAction action) async {
        final String treatmentId = action.payload['treatment_id'] as String;
        final String recordId = action.payload['record_id'] as String;
        final HealthTreatment? snapshot = await _getLocalTreatment(
          treatmentId,
          recordId,
        );
        if (snapshot != null) {
          await _cancelTreatmentReminders(snapshot);
        }
        await _remote.deleteTreatment(
          HealthTreatment(
            id: treatmentId,
            recordId: recordId,
            profileId: snapshot?.profileId ?? '',
            title: snapshot?.title ?? '',
            treatmentType:
                snapshot?.treatmentType ?? HealthTreatmentType.medication,
            startAt: snapshot?.startAt ?? DateTime.now(),
            createdAt: snapshot?.createdAt ?? DateTime.now(),
            updatedAt: snapshot?.updatedAt ?? DateTime.now(),
            reminderMinutes: snapshot?.reminderMinutes ?? const <int>[],
            dosage: snapshot?.dosage,
            frequency: snapshot?.frequency,
            endAt: snapshot?.endAt,
            completedAt: snapshot?.completedAt,
            notes: snapshot?.notes,
            taskId: snapshot?.taskId,
          ),
        );
        await _localRecords.deleteTreatment(treatmentId);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['treatment'] as Map<String, dynamic>?;
        if (raw != null) {
          final HealthTreatment treatment = HealthTreatment.fromJson(raw);
          await _localRecords.upsertTreatment(
            treatment,
            syncState: kSyncStateSynced,
          );
          await _scheduleTreatmentReminders(treatment);
        }
      },
    );
  }
}
