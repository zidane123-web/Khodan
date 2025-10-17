import 'package:drift/native.dart';
import 'package:khodan/data/local/local_data_sources.dart';
import 'package:khodan/data/local/local_database.dart';
import 'package:khodan/data/models/animal.dart';
import 'package:khodan/data/models/animal_event.dart';
import 'package:khodan/data/models/breeding_record.dart';
import 'package:khodan/data/models/event.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// ignore: unused_import
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

bool _sqliteInitialized = false;

void ensureSqliteForTests() {
  if (_sqliteInitialized) {
    return;
  }
  sqfliteFfiInit();
  _sqliteInitialized = true;
}

final Animal sampleAnimal = Animal(
  id: 'animal-1',
  profileId: 'profile-1',
  speciesId: 1,
  tagId: 'F-001',
  name: 'Fiona',
  birthDate: DateTime(2023, 1, 10),
  sex: 'Femelle',
  status: 'Active',
  origin: 'Elevage interne',
  cageNumber: 'C-01',
  entryDate: DateTime(2023, 2, 1),
  firstBreedingDate: DateTime(2023, 6, 15),
);

final BreedingRecord sampleBreedingRecord = BreedingRecord(
  id: 'breeding-1',
  profileId: 'profile-1',
  doeId: 'animal-1',
  buckId: 'buck-1',
  matingDate: DateTime(2024, 3, 1),
  palpationDate: DateTime(2024, 3, 13),
  palpationPositive: true,
  kindlingDate: DateTime(2024, 4, 2),
  kitsBornAlive: 7,
  kitsBornDead: 1,
  weaningDate: DateTime(2024, 5, 12),
  kitsWeaned: 6,
  averageWeaningWeight: 1.8,
  notes: 'Portée homogène.',
);

final LivestockEvent sampleEvent = LivestockEvent(
  id: 'event-1',
  profileId: 'profile-1',
  eventType: 'health_check',
  eventDate: DateTime(2024, 3, 20),
  details: <String, dynamic>{'veterinarian': 'Dr. Lemoine'},
  notes: 'Contrôle annuel.',
);

final AnimalEventLink sampleEventLink = AnimalEventLink(
  eventId: 'event-1',
  animalId: 'animal-1',
  role: 'subject',
);

LocalDatabase createTestDatabase() {
  return LocalDatabase.forTesting(NativeDatabase.memory());
}

Future<void> seedAnimalData(LocalAnimalDataSource local) async {
  await local.replaceAnimals(<Animal>[
    sampleAnimal,
  ], profileId: sampleAnimal.profileId);
}

Future<void> seedBreedingData(LocalBreedingDataSource local) async {
  await local.replaceBreedingRecords(<BreedingRecord>[
    sampleBreedingRecord,
  ], profileId: sampleBreedingRecord.profileId);
}

Future<void> seedEventData(LocalEventDataSource local) async {
  await local.replaceEvents(
    <LivestockEvent>[sampleEvent],
    links: <AnimalEventLink>[sampleEventLink],
  );
}
