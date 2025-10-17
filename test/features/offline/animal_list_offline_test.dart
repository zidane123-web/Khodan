import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/local/local_data_sources.dart';
import 'package:khodan/data/local/local_database.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/services/offline_sync_manager.dart';
import 'package:khodan/features/animals/presentation/cubit/animal_cubit.dart';

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

  test('AnimalCubit loads cached animals when offline', () async {
    final LocalDatabase db = LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());

    final LocalAnimalDataSource localAnimal = LocalAnimalDataSource(db);
    await seedAnimalData(localAnimal);

    final RecordingAnimalRepository remoteAnimal = RecordingAnimalRepository();
    final AnimalRepository syncedRepository = SyncedAnimalRepository(
      remote: remoteAnimal,
      local: localAnimal,
      offlineManager: offlineManager,
    );

    final AnimalCubit cubit = AnimalCubit(
      syncedRepository,
      offlineManager: offlineManager,
      localDataSource: localAnimal,
    );
    addTearDown(cubit.close);

    await cubit.fetchAnimals();

    expect(cubit.state.status, AnimalStatus.success);
    expect(cubit.state.animals, isNotEmpty);
    expect(remoteAnimal.fetchCount, equals(0));
  });
}
