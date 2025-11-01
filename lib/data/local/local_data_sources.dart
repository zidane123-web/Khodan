import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/animal.dart';
import '../models/animal_event.dart';
import '../models/animal_media.dart';
import '../models/breeding_record.dart';
import '../models/event_template.dart';
import '../models/event.dart';
import '../models/food_stock.dart';
import '../models/food_type.dart';
import '../models/task_template.dart';
import '../models/dashboard_preferences.dart';
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

class LocalAnimalMediaDataSource {
  LocalAnimalMediaDataSource(this._db);

  final LocalDatabase _db;

  Future<void> replaceMedia(
    List<AnimalMedia> media, {
    required String profileId,
    required String animalId,
  }) async {
    await _db.transaction(() async {
      final List<String> ids =
          media.map((AnimalMedia asset) => asset.id).toList();
      await (_db.delete(_db.animalMediaTable)
            ..where(
              (AnimalMediaTable tbl) =>
                  tbl.profileId.equals(profileId) &
                  tbl.animalId.equals(animalId) &
                  (ids.isEmpty
                      ? const Constant<bool>(true)
                      : tbl.id.isNotIn(ids)),
            ))
          .go();
      if (media.isEmpty) {
        return;
      }
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.animalMediaTable,
          media.map((AnimalMedia asset) {
            return AnimalMediaTableCompanion.insert(
              id: asset.id,
              profileId: asset.profileId,
              animalId: asset.animalId,
              storagePath: asset.storagePath,
              payload: jsonEncode(asset.toJson()),
              createdAt: asset.createdAt,
              updatedAt: asset.updatedAt,
              syncState: Value(asset.syncState),
            );
          }).toList(),
        );
      });
    });
  }

  Future<void> upsertMedia(
    AnimalMedia asset, {
    String? syncState,
  }) async {
    await _db.into(_db.animalMediaTable).insertOnConflictUpdate(
          AnimalMediaTableCompanion.insert(
            id: asset.id,
            profileId: asset.profileId,
            animalId: asset.animalId,
            storagePath: asset.storagePath,
            payload: jsonEncode(
              asset.copyWith(
                syncState: syncState ?? asset.syncState,
              ).toJson(),
            ),
            createdAt: asset.createdAt,
            updatedAt: asset.updatedAt,
            syncState: Value(syncState ?? asset.syncState),
          ),
        );
  }

  Future<void> upsertAll(
    List<AnimalMedia> assets, {
    String? syncState,
  }) async {
    if (assets.isEmpty) {
      return;
    }
    await _db.batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        _db.animalMediaTable,
        assets.map((AnimalMedia asset) {
          final String targetSyncState = syncState ?? asset.syncState;
          return AnimalMediaTableCompanion.insert(
            id: asset.id,
            profileId: asset.profileId,
            animalId: asset.animalId,
            storagePath: asset.storagePath,
            payload: jsonEncode(
              asset.copyWith(syncState: targetSyncState).toJson(),
            ),
            createdAt: asset.createdAt,
            updatedAt: asset.updatedAt,
            syncState: Value(targetSyncState),
          );
        }).toList(),
      );
    });
  }

  Future<AnimalMedia?> fetchById(String id) async {
    final AnimalMediaTableData? row = await (_db.select(_db.animalMediaTable)
          ..where((AnimalMediaTable tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapMedia(row);
  }

  Future<List<AnimalMedia>> fetchByAnimal({
    required String profileId,
    required String animalId,
  }) async {
    final List<AnimalMediaTableData> rows = await (_db
            .select(_db.animalMediaTable)
          ..where(
            (AnimalMediaTable tbl) =>
                tbl.profileId.equals(profileId) &
                tbl.animalId.equals(animalId),
          ))
        .get();
    final List<AnimalMedia> assets =
        rows.map(_mapMedia).toList(growable: false);
    assets.sort(
      (AnimalMedia a, AnimalMedia b) => b.createdAt.compareTo(a.createdAt),
    );
    return assets;
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.animalMediaTable)
          ..where((AnimalMediaTable tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<void> deleteForAnimal({
    required String profileId,
    required String animalId,
  }) async {
    await (_db.delete(_db.animalMediaTable)
          ..where(
            (AnimalMediaTable tbl) =>
                tbl.profileId.equals(profileId) &
                tbl.animalId.equals(animalId),
          ))
        .go();
  }

  Future<void> updateSyncState(String id, String syncState) async {
    final AnimalMedia? current = await fetchById(id);
    if (current == null) {
      return;
    }
    await upsertMedia(current.copyWith(syncState: syncState));
  }

  AnimalMedia _mapMedia(AnimalMediaTableData row) {
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    return AnimalMedia.fromJson(json);
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

  Future<void> deleteSpeciesConfig(int id) async {
    await (_db.delete(_db.speciesConfigsTable)
          ..where((SpeciesConfigsTable tbl) => tbl.id.equals(id)))
        .go();
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

class LocalEventTemplateDataSource {
  LocalEventTemplateDataSource(this._db);

  final LocalDatabase _db;

  Future<void> replaceTemplates(
    List<EventTemplate> templates, {
    required String profileId,
    }) async {
      await _db.transaction(() async {
        if (templates.isEmpty) {
        await (_db.delete(_db.eventTemplatesTable)
              ..where(
                (EventTemplatesTable tbl) => tbl.profileId.equals(profileId),
              ))
            .go();
        return;
      }
      final List<int> ids =
          templates.map((EventTemplate template) => template.id).toList();
      await (_db.delete(_db.eventTemplatesTable)
            ..where(
              (EventTemplatesTable tbl) =>
                  tbl.profileId.equals(profileId) &
                  (ids.isEmpty
                      ? const Constant<bool>(true)
                      : tbl.id.isNotIn(ids)),
            ))
          .go();
        await upsertTemplates(
          templates,
          syncState: kSyncStateSynced,
        );
      });
  }

  Future<void> upsertTemplates(
    List<EventTemplate> templates, {
    String syncState = kSyncStateSynced,
  }) async {
    if (templates.isEmpty) {
      return;
    }
    await _db.batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        _db.eventTemplatesTable,
        templates.map((EventTemplate template) {
          return EventTemplatesTableCompanion(
            id: Value(template.id),
            profileId: Value(template.userId),
            templateName: Value(template.templateName),
            eventType: Value(template.eventType),
            payload: Value(jsonEncode(template.toJson())),
            createdAt: Value(template.createdAt),
            updatedAt: Value(template.updatedAt),
            syncState: Value(syncState),
          );
        }).toList(),
      );
    });
  }

  Future<EventTemplate?> fetchTemplateById(int id) async {
    final EventTemplatesTableData? row =
        await (_db.select(_db.eventTemplatesTable)
              ..where((EventTemplatesTable tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : _mapTemplate(row);
  }

  Future<void> deleteTemplate(int id) async {
    await (_db.delete(_db.eventTemplatesTable)
          ..where((EventTemplatesTable tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<List<EventTemplate>> fetchTemplates(String profileId) async {
    final List<EventTemplatesTableData> rows =
        await (_db.select(_db.eventTemplatesTable)
              ..where(
                (EventTemplatesTable tbl) => tbl.profileId.equals(profileId),
              ))
            .get();
    final List<EventTemplate> templates =
        rows.map(_mapTemplate).toList();
    templates.sort(
      (EventTemplate a, EventTemplate b) =>
          a.templateName.compareTo(b.templateName),
    );
    return templates;
  }

  EventTemplate _mapTemplate(EventTemplatesTableData row) {
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    return EventTemplate.fromJson(json);
  }
}

class LocalTaskTemplateDataSource {
  LocalTaskTemplateDataSource(this._db);

  final LocalDatabase _db;

  Future<void> replaceTemplates(
    List<TaskTemplate> templates, {
    required String profileId,
  }) async {
    await _db.transaction(() async {
      final List<String> ids =
          templates.map((TaskTemplate template) => template.id).toList();
      await (_db.delete(_db.taskTemplateStepsTable)
            ..where(
              (TaskTemplateStepsTable tbl) =>
                  tbl.profileId.equals(profileId) &
                  (ids.isEmpty
                      ? const Constant<bool>(true)
                      : tbl.templateId.isNotIn(ids)),
            ))
          .go();
      await (_db.delete(_db.taskTemplatesTable)
            ..where(
              (TaskTemplatesTable tbl) =>
                  tbl.profileId.equals(profileId) &
                  (ids.isEmpty
                      ? const Constant<bool>(true)
                      : tbl.id.isNotIn(ids)),
            ))
          .go();
      if (templates.isEmpty) {
        return;
      }
      await upsertTemplates(templates, syncState: kSyncStateSynced);
    });
  }

  Future<void> upsertTemplates(
    List<TaskTemplate> templates, {
    String syncState = kSyncStateSynced,
  }) async {
    if (templates.isEmpty) {
      return;
    }
    final DateTime now = DateTime.now();
    await _db.transaction(() async {
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.taskTemplatesTable,
          templates.map((TaskTemplate template) {
            return TaskTemplatesTableCompanion(
              id: Value(template.id),
              profileId: Value(template.profileId),
              payload: Value(
                jsonEncode(template.toJson(includeSteps: false)),
              ),
              updatedAt: Value(now),
              syncState: Value(syncState),
            );
          }).toList(),
        );
      });
      for (final TaskTemplate template in templates) {
        await (_db.delete(_db.taskTemplateStepsTable)
              ..where(
                (TaskTemplateStepsTable tbl) =>
                    tbl.templateId.equals(template.id),
              ))
            .go();
        if (template.steps.isEmpty) {
          continue;
        }
        await _db.batch((Batch batch) {
          batch.insertAllOnConflictUpdate(
            _db.taskTemplateStepsTable,
            template.steps.map((TaskTemplateStep step) {
              return TaskTemplateStepsTableCompanion(
                id: Value(step.id),
                templateId: Value(step.templateId),
                profileId: Value(step.profileId),
                position: Value(step.position),
                payload: Value(jsonEncode(step.toJson())),
                updatedAt: Value(now),
                syncState: Value(syncState),
              );
            }).toList(),
          );
        });
      }
    });
  }

  Future<List<TaskTemplate>> fetchTemplates(String profileId) async {
    final List<TaskTemplatesTableData> templateRows =
        await (_db.select(_db.taskTemplatesTable)
              ..where(
                (TaskTemplatesTable tbl) => tbl.profileId.equals(profileId),
              ))
            .get();
    if (templateRows.isEmpty) {
      return <TaskTemplate>[];
    }
    final List<TaskTemplateStepsTableData> stepRows =
        await (_db.select(_db.taskTemplateStepsTable)
              ..where(
                (TaskTemplateStepsTable tbl) => tbl.profileId.equals(profileId),
              ))
            .get();
    final Map<String, List<TaskTemplateStep>> stepsByTemplate =
        <String, List<TaskTemplateStep>>{};
    for (final TaskTemplateStepsTableData row in stepRows) {
      final Map<String, dynamic> json =
          jsonDecode(row.payload) as Map<String, dynamic>;
      final TaskTemplateStep step = TaskTemplateStep.fromJson(json);
      final List<TaskTemplateStep> list = stepsByTemplate.putIfAbsent(
        step.templateId,
        () => <TaskTemplateStep>[],
      );
      list.add(step);
    }
    final List<TaskTemplate> templates = templateRows.map((TaskTemplatesTableData row) {
      final Map<String, dynamic> json =
          jsonDecode(row.payload) as Map<String, dynamic>;
      final TaskTemplate template = TaskTemplate.fromJson(json);
      final List<TaskTemplateStep> steps =
          List<TaskTemplateStep>.from(stepsByTemplate[template.id] ?? <TaskTemplateStep>[]);
      steps.sort((TaskTemplateStep a, TaskTemplateStep b) => a.position.compareTo(b.position));
      return template.copyWith(steps: steps);
    }).toList();
    templates.sort((TaskTemplate a, TaskTemplate b) => a.name.compareTo(b.name));
    return templates;
  }

  Future<TaskTemplate?> fetchTemplateById(String id) async {
    final TaskTemplatesTableData? row =
        await (_db.select(_db.taskTemplatesTable)
              ..where((TaskTemplatesTable tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    final TaskTemplate template = TaskTemplate.fromJson(json);
    final List<TaskTemplateStepsTableData> stepRows =
        await (_db.select(_db.taskTemplateStepsTable)
              ..where((TaskTemplateStepsTable tbl) => tbl.templateId.equals(id)))
            .get();
    final List<TaskTemplateStep> steps = stepRows.map((TaskTemplateStepsTableData data) {
      final Map<String, dynamic> stepJson =
          jsonDecode(data.payload) as Map<String, dynamic>;
      return TaskTemplateStep.fromJson(stepJson);
    }).toList()
      ..sort((TaskTemplateStep a, TaskTemplateStep b) => a.position.compareTo(b.position));
    return template.copyWith(steps: steps);
  }

  Future<void> deleteTemplate(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.taskTemplateStepsTable)
            ..where((TaskTemplateStepsTable tbl) => tbl.templateId.equals(id)))
          .go();
      await (_db.delete(_db.taskTemplatesTable)
            ..where((TaskTemplatesTable tbl) => tbl.id.equals(id)))
          .go();
    });
  }
}

class LocalTaskTemplateAssignmentDataSource {
  LocalTaskTemplateAssignmentDataSource(this._db);

  final LocalDatabase _db;

  Future<void> replaceAssignments(
    List<TaskTemplateAssignment> assignments, {
    required String profileId,
    Map<String, List<TaskTemplateAssignmentEvent>> eventsByAssignment =
        const <String, List<TaskTemplateAssignmentEvent>>{},
  }) async {
    await _db.transaction(() async {
      final List<String> ids =
          assignments.map((TaskTemplateAssignment a) => a.id).toList();
      await (_db.delete(_db.taskTemplateAssignmentEventsTable)
            ..where(
              (TaskTemplateAssignmentEventsTable tbl) =>
                  tbl.profileId.equals(profileId) &
                  (ids.isEmpty
                      ? const Constant<bool>(true)
                      : tbl.assignmentId.isNotIn(ids)),
            ))
          .go();
      await (_db.delete(_db.taskTemplateAssignmentsTable)
            ..where(
              (TaskTemplateAssignmentsTable tbl) =>
                  tbl.profileId.equals(profileId) &
                  (ids.isEmpty
                      ? const Constant<bool>(true)
                      : tbl.id.isNotIn(ids)),
            ))
          .go();
      if (assignments.isEmpty) {
        return;
      }
      for (final TaskTemplateAssignment assignment in assignments) {
        await upsertAssignment(
          assignment,
          events:
              eventsByAssignment[assignment.id] ?? const <TaskTemplateAssignmentEvent>[],
          syncState: kSyncStateSynced,
        );
      }
    });
  }

  Future<void> upsertAssignment(
    TaskTemplateAssignment assignment, {
    List<TaskTemplateAssignmentEvent> events =
        const <TaskTemplateAssignmentEvent>[],
    String syncState = kSyncStateSynced,
  }) async {
    final DateTime now = DateTime.now();
    await _db.transaction(() async {
      await _db.into(_db.taskTemplateAssignmentsTable).insertOnConflictUpdate(
            TaskTemplateAssignmentsTableCompanion(
              id: Value(assignment.id),
              profileId: Value(assignment.profileId),
              templateId: Value(assignment.templateId),
              scopeType: Value(assignment.scopeType),
              scopeId: Value(assignment.scopeId),
              anchorDate: Value(
                DateTime.utc(
                  assignment.anchorDate.year,
                  assignment.anchorDate.month,
                  assignment.anchorDate.day,
                ),
              ),
              payload: Value(jsonEncode(assignment.toJson())),
              updatedAt: Value(now),
              syncState: Value(syncState),
            ),
          );
      await (_db.delete(_db.taskTemplateAssignmentEventsTable)
            ..where(
              (TaskTemplateAssignmentEventsTable tbl) =>
                  tbl.assignmentId.equals(assignment.id),
            ))
          .go();
      if (events.isEmpty) {
        return;
      }
      await _db.batch((Batch batch) {
        batch.insertAllOnConflictUpdate(
          _db.taskTemplateAssignmentEventsTable,
          events.map((TaskTemplateAssignmentEvent event) {
            return TaskTemplateAssignmentEventsTableCompanion(
              assignmentId: Value(event.assignmentId),
              stepId: Value(event.stepId),
              eventId: Value(event.eventId),
              profileId: Value(event.profileId),
              payload: Value(jsonEncode(event.toJson())),
              updatedAt: Value(now),
              syncState: Value(syncState),
            );
          }).toList(),
        );
      });
    });
  }

  Future<List<TaskTemplateAssignment>> fetchAssignments(String profileId) async {
    final List<TaskTemplateAssignmentsTableData> rows =
        await (_db.select(_db.taskTemplateAssignmentsTable)
              ..where(
                (TaskTemplateAssignmentsTable tbl) =>
                    tbl.profileId.equals(profileId),
              ))
            .get();
    final List<TaskTemplateAssignment> assignments = rows.map((TaskTemplateAssignmentsTableData row) {
      final Map<String, dynamic> json =
          jsonDecode(row.payload) as Map<String, dynamic>;
      return TaskTemplateAssignment.fromJson(json);
    }).toList()
      ..sort((TaskTemplateAssignment a, TaskTemplateAssignment b) => b.updatedAt.compareTo(a.updatedAt));
    return assignments;
  }

  Future<TaskTemplateAssignment?> fetchAssignment(String id) async {
    final TaskTemplateAssignmentsTableData? row =
        await (_db.select(_db.taskTemplateAssignmentsTable)
              ..where((TaskTemplateAssignmentsTable tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    return TaskTemplateAssignment.fromJson(json);
  }

  Future<List<TaskTemplateAssignmentEvent>> fetchAssignmentEvents(
    String assignmentId,
  ) async {
    final List<TaskTemplateAssignmentEventsTableData> rows =
        await (_db.select(_db.taskTemplateAssignmentEventsTable)
              ..where(
                (TaskTemplateAssignmentEventsTable tbl) =>
                    tbl.assignmentId.equals(assignmentId),
              ))
            .get();
    final List<TaskTemplateAssignmentEvent> events =
        rows.map((TaskTemplateAssignmentEventsTableData row) {
      final Map<String, dynamic> json =
          jsonDecode(row.payload) as Map<String, dynamic>;
      return TaskTemplateAssignmentEvent.fromJson(json);
    }).toList()
          ..sort(
            (TaskTemplateAssignmentEvent a, TaskTemplateAssignmentEvent b) =>
                a.stepId.compareTo(b.stepId),
          );
    return events;
  }

  Future<void> deleteAssignment(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.taskTemplateAssignmentEventsTable)
            ..where(
              (TaskTemplateAssignmentEventsTable tbl) =>
                  tbl.assignmentId.equals(id),
            ))
          .go();
      await (_db.delete(_db.taskTemplateAssignmentsTable)
            ..where((TaskTemplateAssignmentsTable tbl) => tbl.id.equals(id)))
          .go();
    });
  }
}

class LocalFoodTypeDataSource {
  LocalFoodTypeDataSource(this._db);

  final LocalDatabase _db;

  Future<void> replaceFoodTypes(
    List<FoodType> types, {
    required String profileId,
  }) async {
    await _db.transaction(() async {
      final List<int> ids = types.map((FoodType type) => type.id).toList();
      await (_db.delete(_db.foodTypesTable)
            ..where(
              (FoodTypesTable tbl) =>
                  tbl.profileId.equals(profileId) &
                  (ids.isEmpty
                      ? const Constant<bool>(true)
                      : tbl.id.isNotIn(ids)),
            ))
          .go();
      if (types.isEmpty) {
        return;
      }
      await upsertFoodTypes(types, syncState: kSyncStateSynced);
    });
  }

  Future<void> upsertFoodTypes(
    List<FoodType> types, {
    String syncState = kSyncStateSynced,
  }) async {
    if (types.isEmpty) {
      return;
    }
    await _db.batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        _db.foodTypesTable,
        types.map((FoodType type) {
          return FoodTypesTableCompanion(
            id: Value(type.id),
            profileId: Value(type.profileId),
            name: Value(type.name),
            payload: Value(jsonEncode(type.toJson())),
            createdAt: Value(type.createdAt),
            updatedAt: Value(type.updatedAt),
            syncState: Value(syncState),
          );
        }).toList(),
      );
    });
  }

  Future<void> deleteFoodType(int id) async {
    await (_db.delete(_db.foodTypesTable)
          ..where((FoodTypesTable tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<List<FoodType>> fetchFoodTypes(String profileId) async {
    final List<FoodTypesTableData> rows =
        await (_db.select(_db.foodTypesTable)
              ..where((FoodTypesTable tbl) => tbl.profileId.equals(profileId)))
            .get();
    final List<FoodType> types = rows.map(_mapFoodType).toList();
    types.sort(
      (FoodType a, FoodType b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
    );
    return types;
  }

  Future<FoodType?> fetchFoodTypeById(int id) async {
    final FoodTypesTableData? row =
        await (_db.select(_db.foodTypesTable)
              ..where((FoodTypesTable tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : _mapFoodType(row);
  }

  FoodType _mapFoodType(FoodTypesTableData row) {
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    return FoodType.fromJson(json);
  }
}

class LocalFoodStockDataSource {
  LocalFoodStockDataSource(this._db);

  final LocalDatabase _db;

  Future<void> replaceEntries(
    List<FoodStockEntry> entries, {
    required String profileId,
  }) async {
    await _db.transaction(() async {
      final List<int> ids =
          entries.map((FoodStockEntry entry) => entry.id).toList();
      await (_db.delete(_db.foodStockTable)
            ..where(
              (FoodStockTable tbl) =>
                  tbl.profileId.equals(profileId) &
                  (ids.isEmpty
                      ? const Constant<bool>(true)
                      : tbl.id.isNotIn(ids)),
            ))
          .go();
      if (entries.isEmpty) {
        return;
      }
      await upsertEntries(entries, syncState: kSyncStateSynced);
    });
  }

  Future<void> upsertEntries(
    List<FoodStockEntry> entries, {
    String syncState = kSyncStateSynced,
  }) async {
    if (entries.isEmpty) {
      return;
    }
    await _db.batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        _db.foodStockTable,
        entries.map((FoodStockEntry entry) {
          return FoodStockTableCompanion(
            id: Value(entry.id),
            profileId: Value(entry.profileId),
            foodTypeId: Value(entry.foodTypeId),
            payload: Value(jsonEncode(entry.toJson())),
            createdAt: Value(entry.createdAt),
            updatedAt: Value(entry.updatedAt),
            syncState: Value(syncState),
          );
        }).toList(),
      );
    });
  }

  Future<void> deleteEntry(int id) async {
    await (_db.delete(_db.foodStockTable)
          ..where((FoodStockTable tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<List<FoodStockEntry>> fetchEntries(String profileId) async {
    final List<FoodStockTableData> rows =
        await (_db.select(_db.foodStockTable)
              ..where((FoodStockTable tbl) => tbl.profileId.equals(profileId)))
            .get();
    final List<FoodStockEntry> entries =
        rows.map(_mapEntry).toList();
    entries.sort(
      (FoodStockEntry a, FoodStockEntry b) =>
          a.createdAt.compareTo(b.createdAt),
    );
    return entries;
  }

  Future<FoodStockEntry?> fetchEntryById(int id) async {
    final FoodStockTableData? row =
        await (_db.select(_db.foodStockTable)
              ..where((FoodStockTable tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : _mapEntry(row);
  }

  FoodStockEntry _mapEntry(FoodStockTableData row) {
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    return FoodStockEntry.fromJson(json);
  }
}

class LocalProfileDataSource {
  LocalProfileDataSource(this._db);

  final LocalDatabase _db;

  Future<void> upsertProfile(
    Profile profile, {
    String syncState = kSyncStateSynced,
  }) async {
    await _db.into(_db.profilesTable).insertOnConflictUpdate(
          ProfilesTableCompanion.insert(
            id: profile.id,
            payload: jsonEncode(profile.toJson()),
            updatedAt: DateTime.now(),
            syncState: Value(syncState),
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

class LocalDashboardPreferencesDataSource {
  LocalDashboardPreferencesDataSource(this._db);

  final LocalDatabase _db;

  Future<DashboardPreferences?> fetch(String profileId) async {
    final DashboardPreferencesTableData? row =
        await (_db.select(_db.dashboardPreferencesTable)
              ..where(
                (DashboardPreferencesTable tbl) => tbl.profileId.equals(
                  profileId,
                ),
              ))
            .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final Map<String, dynamic> json =
        jsonDecode(row.payload) as Map<String, dynamic>;
    return DashboardPreferences.fromJson(json);
  }

  Future<void> upsert(DashboardPreferences preferences) async {
    await _db.into(_db.dashboardPreferencesTable).insertOnConflictUpdate(
          DashboardPreferencesTableCompanion.insert(
            profileId: preferences.profileId,
            payload: jsonEncode(preferences.toJson()),
            updatedAt: preferences.updatedAt,
          ),
        );
  }

  Future<void> delete(String profileId) async {
    await (_db.delete(_db.dashboardPreferencesTable)
          ..where(
            (DashboardPreferencesTable tbl) => tbl.profileId.equals(profileId),
          ))
        .go();
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
