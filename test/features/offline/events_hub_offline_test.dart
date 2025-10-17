import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khodan/features/events/presentation/cubit/events_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khodan/data/local/local_data_sources.dart';
import 'package:khodan/data/local/local_database.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/breeding_repository.dart';
import 'package:khodan/data/repositories/event_repository.dart';
import 'package:khodan/data/services/connectivity_watcher.dart';
import 'package:khodan/data/services/offline_sync_manager.dart';
import 'package:khodan/features/events/presentation/screens/events_hub_screen.dart';

import '../../helpers/fake_connectivity.dart';
import '../../helpers/offline_remote_stubs.dart';
import '../../helpers/offline_samples.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(ensureSqliteForTests);

  late FakeConnectivityPlatform fakeConnectivity;
  late ConnectivityWatcher watcher;
  final OfflineSyncManager offlineManager = OfflineSyncManager.instance;

  setUp(() async {
    fakeConnectivity = FakeConnectivityPlatform(
      initialResult: const <ConnectivityResult>[ConnectivityResult.none],
    );
    ConnectivityPlatform.instance = fakeConnectivity;
    watcher = ConnectivityWatcher();
    await watcher.initialize();
  });

  tearDown(() async {
    await watcher.dispose();
    await fakeConnectivity.dispose();
    offlineManager.setOffline(false, flushWhenOnline: false);
  });

  testWidgets('EventsHubScreen displays cached events when offline', (
    WidgetTester tester,
  ) async {
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

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: <RepositoryProvider<dynamic>>[
          RepositoryProvider<LocalAnimalDataSource>.value(value: localAnimal),
          RepositoryProvider<LocalBreedingDataSource>.value(
            value: localBreeding,
          ),
          RepositoryProvider<LocalEventDataSource>.value(value: localEvent),
          RepositoryProvider<AnimalRepository>.value(value: animalRepository),
          RepositoryProvider<BreedingRepository>.value(
            value: breedingRepository,
          ),
          RepositoryProvider<EventRepository>.value(value: eventRepository),
        ],
        child: const MaterialApp(home: EventsHubScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.textContaining('Sant'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    debugDumpApp();

    final BuildContext cubitContext = tester.element(
      find.byWidgetPredicate(
        (Widget widget) => widget is BlocProvider<EventsCubit>,
      ),
    );
    final EventsState currentState = cubitContext.read<EventsCubit>().state;
    debugPrint(
      'EventsCubit state: ${currentState.status} '
      '(health=${currentState.healthEvents.length}, '
      'other=${currentState.otherEvents.length})',
    );

    expect(offlineManager.isOffline.value, isTrue);
    expect(remoteEvent.fetchEventsCount, equals(0));
    expect(remoteEvent.fetchLinksCount, equals(0));

    expect(find.text('health_check'), findsOneWidget);
    expect(remoteAnimal.fetchCount, equals(0));
    expect(remoteBreeding.fetchCount, equals(0));
    expect(remoteEvent.fetchEventsCount, equals(0));
    expect(remoteEvent.fetchLinksCount, equals(0));
  });
}
