import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/animal.dart';
import '../models/animal_event.dart';
import '../models/breeding_record.dart';
import '../models/event.dart';
import '../models/profile.dart';
import '../models/species_config.dart';
import '../models/sync_action.dart';
import 'local_database.dart';

const String kSyncStateSynced = 'synced';
const String kSyncStatePending = 'pending';

class LocalAnimalDataSource {
  LocalAnimalDataSource(this._db);

  final LocalDatabase _db;

  Future<void> replaceAnimals(
    List<Animal> animals, {
    String? profileId,
  }) async {
    final String? targetProfile =
        profileId ?? (animals.isNotEmpty ? animals.first.profileId : null);
    if (targetProfile == null) {
      return;
    }
    final DateTime now = DateTime.now();
    await _db.transaction(() async {
      final List<String> ids = animals.map((Animal animal) => animal.id).toList();
      await (_db.delete(_db.animalsTable)
            ..where(
              (AnimalsTable tbl) =>
                  tbl.profileId.equals(targetProfile) &
                  (ids.isEmpty
                      ? const Constant<bool>(true)
                      : tbl.id.isNotIn(ids)),
            ))
          .go();

      if (animals.isEmpty) {
        return;
      }

      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.animalsTable,
          animals.map((Animal animal) {
            return AnimalsTableCompanion.insert(
              id: animal.id,
              profileId: animal.profileId,
              speciesId: animal.speciesId,
              payload: jsonEncode(animal.toJson()),
              updatedAt: now,
              syncState: const Value(kSyncStateSynced),
            );
          }).toList(),
        );
      });
    });
  }

  Future<void> upsertAnimal(
    Animal animal, {
    String syncState = kSyncStateSynced,
  }) async {
    await _db.into(_db.animalsTable).insertOnConflictUpdate(
          AnimalsTableCompanion.insert(
            id: animal.id,
            profileId: animal.profileId,
            speciesId: animal.speciesId,
            payload: jsonEncode(animal.toJson()),
            updatedAt: DateTime.now(),
            syncState: Value(syncState),
          ),
        );
  }

  Future<void> deleteAnimal(String id) async {
    await (_db.delete(_db.animalsTable)
          ..where((AnimalsTable tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<List<Animal>> fetchAnimals({
    String? profileId,
    int? speciesId,
  }) async {
    final query = _db.select(_db.animalsTable);
    if (profileId != null) {
      query.where((AnimalsTable tbl) => tbl.profileId.equals(profileId));
    }
    if (speciesId != null) {
      query.where((AnimalsTable tbl) => tbl.speciesId.equals(speciesId));
    }
    final List<AnimalsTableData> rows = await query.get();
    final List<Animal> animals = rows.map(_mapAnimal).toList();
    animals.sort((Animal a, Animal b) => a.tagId.compareTo(b.tagId));
    return animals;
  }

  Future<Animal?> fetchAnimalById(String id) async {
    final AnimalsTableData? row = await (_db.select(_db.animalsTable)
          ..where((AnimalsTable tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapAnimal(row);
  }

  Animal _mapAnimal(AnimalsTableData row) {
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    return Animal.fromJson(json);
  }
}

class LocalBreedingDataSource {
  LocalBreedingDataSource(this._db);

  final LocalDatabase _db;

  Future<void> replaceBreedingRecords(
    List<BreedingRecord> records, {
    String? profileId,
  }) async {
    final String? targetProfile =
        profileId ?? (records.isNotEmpty ? records.first.profileId : null);
    if (targetProfile == null) {
      return;
    }
    final DateTime now = DateTime.now();
    await _db.transaction(() async {
      final List<String> ids =
          records.map((BreedingRecord record) => record.id).toList();
      await (_db.delete(_db.breedingRecordsTable)
            ..where(
              (BreedingRecordsTable tbl) =>
                  tbl.profileId.equals(targetProfile) &
                  (ids.isEmpty
                      ? const Constant<bool>(true)
                      : tbl.id.isNotIn(ids)),
            ))
          .go();
      if (records.isEmpty) {
        return;
      }
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.breedingRecordsTable,
          records.map((BreedingRecord record) {
            return BreedingRecordsTableCompanion.insert(
              id: record.id,
              profileId: record.profileId,
              payload: jsonEncode(record.toJson()),
              matingDate: record.matingDate,
              updatedAt: now,
              syncState: const Value(kSyncStateSynced),
            );
          }).toList(),
        );
      });
    });
  }

  Future<void> upsertBreedingRecord(
    BreedingRecord record, {
    String syncState = kSyncStateSynced,
  }) async {
    await _db.into(_db.breedingRecordsTable).insertOnConflictUpdate(
          BreedingRecordsTableCompanion.insert(
            id: record.id,
            profileId: record.profileId,
            payload: jsonEncode(record.toJson()),
            matingDate: record.matingDate,
            updatedAt: DateTime.now(),
            syncState: Value(syncState),
          ),
        );
  }

  Future<void> deleteBreedingRecord(String id) async {
    await (_db.delete(_db.breedingRecordsTable)
          ..where((BreedingRecordsTable tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<List<BreedingRecord>> fetchBreedingRecords() async {
    final List<BreedingRecordsTableData> rows =
        await _db.select(_db.breedingRecordsTable).get();
    final List<BreedingRecord> records =
        rows.map(_mapBreedingRecord).toList();
    records.sort(
      (BreedingRecord a, BreedingRecord b) =>
          b.matingDate.compareTo(a.matingDate),
    );
    return records;
  }

  Future<BreedingRecord?> fetchBreedingRecordById(String id) async {
    final BreedingRecordsTableData? row = await (_db
            .select(_db.breedingRecordsTable)
          ..where((BreedingRecordsTable tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapBreedingRecord(row);
  }

  BreedingRecord _mapBreedingRecord(BreedingRecordsTableData row) {
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    return BreedingRecord.fromJson(json);
  }
}

class LocalEventDataSource {
  LocalEventDataSource(this._db);

  final LocalDatabase _db;

  Future<void> replaceEvents(
    List<LivestockEvent> events, {
    List<AnimalEventLink> links = const <AnimalEventLink>[],
  }) async {
    final DateTime now = DateTime.now();
    await _db.transaction(() async {
      await _db.delete(_db.eventsTable).go();
      if (events.isNotEmpty) {
        await _db.batch((Batch batch) {
          batch.insertAllOnConflictUpdate(
            _db.eventsTable,
            events.map((LivestockEvent event) {
              return EventsTableCompanion.insert(
                id: event.id,
                profileId: event.profileId,
                payload: jsonEncode(event.toJson()),
                eventDate: event.eventDate,
                updatedAt: now,
                syncState: const Value(kSyncStateSynced),
              );
            }).toList(),
          );
        });
      }
      await _db.delete(_db.animalEventsTable).go();
      if (links.isNotEmpty) {
        await _db.batch((Batch batch) {
          batch.insertAllOnConflictUpdate(
            _db.animalEventsTable,
            links.map((AnimalEventLink link) {
              return AnimalEventsTableCompanion.insert(
                eventId: link.eventId,
                animalId: link.animalId,
                role: link.role,
                updatedAt: now,
              );
            }).toList(),
          );
        });
      }
    });
  }

  Future<void> upsertEvent(
    LivestockEvent event, {
    List<AnimalEventLink> links = const <AnimalEventLink>[],
    String syncState = kSyncStateSynced,
  }) async {
    final DateTime now = DateTime.now();
    await _db.transaction(() async {
      await _db.into(_db.eventsTable).insertOnConflictUpdate(
            EventsTableCompanion.insert(
              id: event.id,
              profileId: event.profileId,
              payload: jsonEncode(event.toJson()),
              eventDate: event.eventDate,
              updatedAt: now,
              syncState: Value(syncState),
            ),
          );
      await (_db.delete(_db.animalEventsTable)
            ..where(
              (AnimalEventsTable tbl) => tbl.eventId.equals(event.id),
            ))
          .go();
      if (links.isNotEmpty) {
        await _db.batch((Batch batch) {
          batch.insertAllOnConflictUpdate(
            _db.animalEventsTable,
            links.map((AnimalEventLink link) {
              return AnimalEventsTableCompanion.insert(
                eventId: event.id,
                animalId: link.animalId,
                role: link.role,
                updatedAt: now,
              );
            }).toList(),
          );
        });
      }
    });
  }

  Future<void> deleteEvent(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.animalEventsTable)
            ..where((AnimalEventsTable tbl) => tbl.eventId.equals(id)))
          .go();
      await (_db.delete(_db.eventsTable)
            ..where((EventsTable tbl) => tbl.id.equals(id)))
          .go();
    });
  }

  Future<List<LivestockEvent>> fetchEvents({
    DateTime? start,
    DateTime? end,
  }) async {
    final query = _db.select(_db.eventsTable);
    if (start != null) {
      query.where((EventsTable tbl) => tbl.eventDate.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      query.where((EventsTable tbl) => tbl.eventDate.isSmallerOrEqualValue(end));
    }
    final List<EventsTableData> rows = await query.get();
    final List<LivestockEvent> events = rows.map(_mapEvent).toList();
    events.sort((LivestockEvent a, LivestockEvent b) => a.eventDate.compareTo(b.eventDate));
    return events;
  }

  Future<List<AnimalEventLink>> fetchLinks() async {
    final List<AnimalEventsTableData> rows =
        await _db.select(_db.animalEventsTable).get();
    return rows
        .map(
          (AnimalEventsTableData row) => AnimalEventLink(
            eventId: row.eventId,
            animalId: row.animalId,
            role: row.role,
          ),
        )
        .toList();
  }

  Future<LivestockEvent?> fetchEventById(String id) async {
    final EventsTableData? row = await (_db.select(_db.eventsTable)
          ..where((EventsTable tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapEvent(row);
  }

  Future<List<AnimalEventLink>> fetchLinksForEvent(String eventId) async {
    final List<AnimalEventsTableData> rows = await (_db
            .select(_db.animalEventsTable)
          ..where((AnimalEventsTable tbl) => tbl.eventId.equals(eventId)))
        .get();
    return rows
        .map(
          (AnimalEventsTableData row) => AnimalEventLink(
            eventId: row.eventId,
            animalId: row.animalId,
            role: row.role,
          ),
        )
        .toList();
  }

  Future<void> replaceLinks(List<AnimalEventLink> links) async {
    final DateTime now = DateTime.now();
    await _db.transaction(() async {
      await _db.delete(_db.animalEventsTable).go();
      if (links.isEmpty) {
        return;
      }
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.animalEventsTable,
          links.map((AnimalEventLink link) {
            return AnimalEventsTableCompanion.insert(
              eventId: link.eventId,
              animalId: link.animalId,
              role: link.role,
              updatedAt: now,
            );
          }).toList(),
        );
      });
    });
  }

  LivestockEvent _mapEvent(EventsTableData row) {
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    return LivestockEvent.fromJson(json);
  }
}

class LocalSpeciesDataSource {
  LocalSpeciesDataSource(this._db);

  final LocalDatabase _db;

  Future<void> replaceSpeciesConfigs(
    List<SpeciesConfig> configs, {
    String? profileId,
  }) async {
    final String? targetProfile =
        profileId ?? (configs.isNotEmpty ? configs.first.profileId : null);
    if (targetProfile == null) {
      return;
    }
    final DateTime now = DateTime.now();
    await _db.transaction(() async {
      final List<int> ids =
          configs.map((SpeciesConfig config) => config.id).toList();
      await (_db.delete(_db.speciesConfigsTable)
            ..where(
              (SpeciesConfigsTable tbl) =>
                  tbl.profileId.equals(targetProfile) &
                  (ids.isEmpty
                      ? const Constant<bool>(true)
                      : tbl.id.isNotIn(ids)),
            ))
          .go();
      if (configs.isEmpty) {
        return;
      }
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.speciesConfigsTable,
          configs.map((SpeciesConfig config) {
            return SpeciesConfigsTableCompanion(
              id: Value(config.id),
              profileId: Value(config.profileId),
              payload: Value(jsonEncode(config.toJson())),
              updatedAt: Value(now),
              syncState: const Value(kSyncStateSynced),
            );
          }).toList(),
        );
      });
    });
  }

  Future<void> upsertSpeciesConfigs(
    List<SpeciesConfig> configs, {
    String syncState = kSyncStateSynced,
  }) async {
    if (configs.isEmpty) {
      return;
    }
    final DateTime now = DateTime.now();
    await _db.batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        _db.speciesConfigsTable,
        configs.map((SpeciesConfig config) {
          return SpeciesConfigsTableCompanion(
            id: Value(config.id),
            profileId: Value(config.profileId),
            payload: Value(jsonEncode(config.toJson())),
            updatedAt: Value(now),
            syncState: Value(syncState),
          );
        }).toList(),
      );
    });
  }

  Future<List<SpeciesConfig>> fetchSpecies(String profileId) async {
    final List<SpeciesConfigsTableData> rows =
        await (_db.select(_db.speciesConfigsTable)
              ..where(
                (SpeciesConfigsTable tbl) => tbl.profileId.equals(profileId),
              ))
            .get();
    final List<SpeciesConfig> configs =
        rows.map(_mapSpecies).toList();
    configs.sort(
      (SpeciesConfig a, SpeciesConfig b) =>
          a.speciesName.compareTo(b.speciesName),
    );
    return configs;
  }

  SpeciesConfig _mapSpecies(SpeciesConfigsTableData row) {
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    return SpeciesConfig.fromJson(json);
  }
}

class LocalProfileDataSource {
  LocalProfileDataSource(this._db);

  final LocalDatabase _db;

  Future<void> upsertProfile(Profile profile) async {
    await _db.into(_db.profilesTable).insertOnConflictUpdate(
          ProfilesTableCompanion.insert(
            id: profile.id,
            payload: jsonEncode(profile.toJson()),
            updatedAt: DateTime.now(),
            syncState: const Value(kSyncStateSynced),
          ),
        );
  }

  Future<Profile?> fetchProfile(String id) async {
    final ProfilesTableData? row = await (_db.select(_db.profilesTable)
          ..where((ProfilesTable tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    return Profile.fromJson(json);
  }
}

class LocalSyncQueueDataSource {
  LocalSyncQueueDataSource(this._db);

  final LocalDatabase _db;

  Future<void> insertAction(QueuedSyncAction action) async {
    await _db.into(_db.queuedActionsTable).insert(
          QueuedActionsTableCompanion.insert(
            id: action.id,
            type: action.type.key,
            rollbackType: Value(action.rollbackType?.key),
            description: action.description,
            payload: jsonEncode(action.payload),
            rollbackPayload: Value(
              action.rollbackPayload == null
                  ? null
                  : jsonEncode(action.rollbackPayload),
            ),
            priority: Value(action.priority),
            status: Value(action.status.key),
            attempts: Value(action.attempts),
            createdAt: action.createdAt,
            updatedAt: action.updatedAt,
            scheduledAt: Value(action.scheduledAt),
            lastError: Value(action.lastError),
          ),
        );
  }

  Future<QueuedSyncAction?> findById(String id) async {
    final QueuedActionsTableData? row = await (_db.select(_db.queuedActionsTable)
          ..where((QueuedActionsTable tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapQueuedAction(row);
  }

  Future<List<QueuedSyncAction>> fetchAll() async {
    final List<QueuedActionsTableData> rows =
        await (_db.select(_db.queuedActionsTable)
              ..orderBy(
                <OrderingTerm Function(QueuedActionsTable)>[
                  (QueuedActionsTable tbl) => OrderingTerm(
                        expression: tbl.priority,
                        mode: OrderingMode.desc,
                      ),
                  (QueuedActionsTable tbl) => OrderingTerm(
                        expression: tbl.createdAt,
                        mode: OrderingMode.asc,
                      ),
                ],
              ))
            .get();
    return rows.map(_mapQueuedAction).toList();
  }

  Future<List<QueuedSyncAction>> fetchExecutable({int limit = 10}) async {
    final DateTime now = DateTime.now();
    final List<QueuedActionsTableData> rows = await (_db
            .select(_db.queuedActionsTable)
          ..where(
            (QueuedActionsTable tbl) =>
                tbl.status.equals(SyncActionStatus.pending.key) &
                (tbl.scheduledAt.isNull() |
                    tbl.scheduledAt.isSmallerOrEqualValue(now)),
          )
          ..orderBy(
            <OrderingTerm Function(QueuedActionsTable)>[
              (QueuedActionsTable tbl) => OrderingTerm(
                    expression: tbl.priority,
                    mode: OrderingMode.desc,
                  ),
              (QueuedActionsTable tbl) => OrderingTerm(
                    expression: tbl.createdAt,
                    mode: OrderingMode.asc,
                  ),
            ],
          )
          ..limit(limit))
        .get();
    return rows.map(_mapQueuedAction).toList();
  }

  Future<void> updateStatus(
    String id, {
    required SyncActionStatus status,
    int? attempts,
    DateTime? scheduledAt,
    String? lastError,
  }) async {
    final DateTime now = DateTime.now();
    await (_db.update(_db.queuedActionsTable)
          ..where((QueuedActionsTable tbl) => tbl.id.equals(id)))
        .write(
          QueuedActionsTableCompanion(
            status: Value(status.key),
            attempts: attempts == null
                ? const Value.absent()
                : Value<int>(attempts),
            updatedAt: Value(now),
            scheduledAt: scheduledAt == null
                ? const Value(null)
                : Value<DateTime?>(scheduledAt),
            lastError: lastError == null
                ? const Value.absent()
                : Value<String?>(lastError),
          ),
        );
  }

  Future<void> updateAttempts(String id, int attempts) async {
    final DateTime now = DateTime.now();
    await (_db.update(_db.queuedActionsTable)
          ..where((QueuedActionsTable tbl) => tbl.id.equals(id)))
        .write(
          QueuedActionsTableCompanion(
            attempts: Value(attempts),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> updateSchedule(String id, DateTime? scheduledAt) async {
    final DateTime now = DateTime.now();
    await (_db.update(_db.queuedActionsTable)
          ..where((QueuedActionsTable tbl) => tbl.id.equals(id)))
        .write(
          QueuedActionsTableCompanion(
            scheduledAt: scheduledAt == null
                ? const Value(null)
                : Value<DateTime?>(scheduledAt),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> updateError(String id, String? error) async {
    final DateTime now = DateTime.now();
    await (_db.update(_db.queuedActionsTable)
          ..where((QueuedActionsTable tbl) => tbl.id.equals(id)))
        .write(
          QueuedActionsTableCompanion(
            lastError:
                error == null ? const Value(null) : Value<String?>(error),
            updatedAt: Value(now),
          ),
        );
  }

  Future<int> countActive() async {
    final Expression<int> countExp =
        _db.queuedActionsTable.id.count(distinct: false);
    final List<TypedResult> result = await (_db.selectOnly(
      _db.queuedActionsTable,
    )
          ..addColumns(<Expression<int>>[countExp])
          ..where(
            _db.queuedActionsTable.status.isNotIn(
              <String>[SyncActionStatus.completed.key],
            ),
          ))
        .get();
    if (result.isEmpty) {
      return 0;
    }
    return result.first.read(countExp) ?? 0;
  }

  Future<void> deleteAction(String id) async {
    await (_db.delete(_db.queuedActionsTable)
          ..where((QueuedActionsTable tbl) => tbl.id.equals(id)))
        .go();
  }

  QueuedSyncAction _mapQueuedAction(QueuedActionsTableData row) {
    final SyncActionType? type = SyncActionType.fromKey(row.type);
    if (type == null) {
      throw StateError('Unknown sync action type: ${row.type}');
    }
    final SyncActionType? rollbackType =
        row.rollbackType == null ? null : SyncActionType.fromKey(row.rollbackType!);
    return QueuedSyncAction(
      id: row.id,
      type: type,
      rollbackType: rollbackType,
      description: row.description,
      payload: jsonDecode(row.payload) as Map<String, dynamic>,
      rollbackPayload: row.rollbackPayload == null
          ? null
          : jsonDecode(row.rollbackPayload!) as Map<String, dynamic>,
      priority: row.priority,
      status: SyncActionStatus.fromKey(row.status),
      attempts: row.attempts,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      scheduledAt: row.scheduledAt,
      lastError: row.lastError,
    );
  }
}
