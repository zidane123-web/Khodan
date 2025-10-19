import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/local/local_data_sources.dart';
import 'package:khodan/data/local/local_database.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/breeding_repository.dart';
import 'package:khodan/data/repositories/event_repository.dart';
import 'package:khodan/data/repositories/dashboard_repository.dart';
import 'package:khodan/data/repositories/food_inventory_repository.dart';
import 'package:khodan/data/services/offline_sync_manager.dart';
import 'package:khodan/features/dashboard/presentation/cubit/dashboard_cubit.dart';

import '../../helpers/offline_remote_stubs.dart';
import '../../helpers/offline_samples.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ensureSqliteForTests);

  final OfflineSyncManager offlineManager = OfflineSyncManager.instance;

  setUp(() {
    offlineManager.setOffline(true, flushWhenOnline: false);
  });

  tearDown(() async {
    await offlineManager.flush();
    offlineManager.setOffline(false, flushWhenOnline: false);
  });

  test('DashboardCubit aggregates cached data when offline', () async {
    final LocalDatabase db = LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());

    final LocalAnimalDataSource localAnimal = LocalAnimalDataSource(db);
    final LocalBreedingDataSource localBreeding = LocalBreedingDataSource(db);
    final LocalEventDataSource localEvent = LocalEventDataSource(db);

    await seedAnimalData(localAnimal);
    await seedBreedingData(localBreeding);
    await seedEventData(localEvent);

    final RecordingAnimalRepository remoteAnimal = RecordingAnimalRepository();
    final RecordingBreedingRepository remoteBreeding =
        RecordingBreedingRepository();
    final RecordingEventRepository remoteEvent = RecordingEventRepository();

    final AnimalRepository animalRepository = SyncedAnimalRepository(
      remote: remoteAnimal,
      local: localAnimal,
      offlineManager: offlineManager,
    );
    final BreedingRepository breedingRepository = SyncedBreedingRepository(
      remote: remoteBreeding,
      local: localBreeding,
      offlineManager: offlineManager,
    );
    final EventRepository eventRepository = SyncedEventRepository(
      remote: remoteEvent,
      local: localEvent,
      offlineManager: offlineManager,
    );

    final DashboardRepository dashboardRepository =
        InMemoryDashboardRepository();
    final FoodInventoryRepository foodInventoryRepository =
        InMemoryFoodInventoryRepository();

    final DashboardCubit cubit = DashboardCubit(
      animalRepository,
      breedingRepository,
      eventRepository,
      dashboardRepository,
      foodInventoryRepository,
      profileId: 'demo-profile',
    );
    addTearDown(cubit.close);

    await cubit.loadDashboard();
    final DashboardState state = cubit.state;

    expect(state.status, DashboardStatus.success);
    expect(state.totalAnimals, equals(1));
    expect(remoteAnimal.fetchCount, equals(0));
    expect(remoteBreeding.fetchCount, equals(0));
    expect(remoteEvent.fetchEventsCount, equals(0));
    expect(remoteEvent.fetchLinksCount, equals(0));
  });
}
