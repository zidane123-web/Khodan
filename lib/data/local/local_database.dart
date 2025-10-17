import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_database.g.dart';

class ProfilesTable extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class SpeciesConfigsTable extends Table {
  IntColumn get id => integer()();
  TextColumn get profileId => text()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class AnimalsTable extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  IntColumn get speciesId => integer()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class BreedingRecordsTable extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get payload => text()();
  DateTimeColumn get matingDate => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class EventsTable extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get payload => text()();
  DateTimeColumn get eventDate => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class AnimalEventsTable extends Table {
  TextColumn get eventId => text()();
  TextColumn get animalId => text()();
  TextColumn get role => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{eventId, animalId, role};
}

@DriftDatabase(
  tables: <Type>[
    ProfilesTable,
    SpeciesConfigsTable,
    AnimalsTable,
    BreedingRecordsTable,
    EventsTable,
    AnimalEventsTable,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase._(super.executor);

  factory LocalDatabase() => LocalDatabase._(_openConnection());

  LocalDatabase.forTesting(super.executor);

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String path = p.join(dir.path, 'khodan_local.db');
      return NativeDatabase(File(path));
    });
  }

  @override
  int get schemaVersion => 1;

  Future<void> clearAll() async {
    await transaction(() async {
      await delete(animalEventsTable).go();
      await delete(eventsTable).go();
      await delete(breedingRecordsTable).go();
      await delete(animalsTable).go();
      await delete(speciesConfigsTable).go();
      await delete(profilesTable).go();
    });
  }
}
