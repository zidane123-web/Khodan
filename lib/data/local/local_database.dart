import 'package:drift/drift.dart';

import 'database_executor.dart';

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

class EventTemplatesTable extends Table {
  IntColumn get id => integer()();
  TextColumn get profileId => text()();
  TextColumn get templateName => text()();
  TextColumn get eventType => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class FoodTypesTable extends Table {
  IntColumn get id => integer()();
  TextColumn get profileId => text()();
  TextColumn get name => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class FoodStockTable extends Table {
  IntColumn get id => integer()();
  TextColumn get profileId => text()();
  IntColumn get foodTypeId => integer().nullable()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class DashboardPreferencesTable extends Table {
  TextColumn get profileId => text()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{profileId};
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

class AnimalMediaTable extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get animalId => text()();
  TextColumn get storagePath => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class QueuedActionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get rollbackType => text().nullable()();
  TextColumn get description => text()();
  TextColumn get payload => text()();
  TextColumn get rollbackPayload => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(
  tables: <Type>[
    ProfilesTable,
    SpeciesConfigsTable,
    EventTemplatesTable,
    FoodTypesTable,
    FoodStockTable,
    DashboardPreferencesTable,
    AnimalsTable,
    AnimalMediaTable,
    BreedingRecordsTable,
    EventsTable,
    AnimalEventsTable,
    QueuedActionsTable,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase._(super.executor);

  factory LocalDatabase() => LocalDatabase._(createLocalDatabaseExecutor());

  LocalDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (Migrator migrator, int from, int to) async {
          if (from < 2) {
            await migrator.createTable(queuedActionsTable);
          }
          if (from < 3) {
            await migrator.createTable(eventTemplatesTable);
          }
          if (from < 4) {
            await migrator.createTable(foodTypesTable);
            await migrator.createTable(foodStockTable);
          }
          if (from < 5) {
            await migrator.createTable(dashboardPreferencesTable);
          }
          if (from < 6) {
            await migrator.createTable(animalMediaTable);
          }
        },
      );

  Future<void> clearAll() async {
    await transaction(() async {
      await delete(animalEventsTable).go();
      await delete(eventsTable).go();
      await delete(breedingRecordsTable).go();
      await delete(animalsTable).go();
      await delete(animalMediaTable).go();
      await delete(speciesConfigsTable).go();
      await delete(eventTemplatesTable).go();
      await delete(foodStockTable).go();
      await delete(foodTypesTable).go();
      await delete(dashboardPreferencesTable).go();
      await delete(profilesTable).go();
      await delete(queuedActionsTable).go();
    });
  }
}
