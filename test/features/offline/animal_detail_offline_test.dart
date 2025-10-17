import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/local/local_data_sources.dart';
import 'package:khodan/data/local/local_database.dart';
import 'package:khodan/data/models/breeding_record.dart';
import 'package:khodan/data/repositories/breeding_repository.dart';
import 'package:khodan/data/services/offline_sync_manager.dart';

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

  test('SyncedBreedingRepository serves cached records when offline', () async {
    final LocalDatabase db = LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());

    final LocalBreedingDataSource localBreeding = LocalBreedingDataSource(db);
    await seedBreedingData(localBreeding);

    final RecordingBreedingRepository remoteBreeding =
        RecordingBreedingRepository();
    final BreedingRepository repository = SyncedBreedingRepository(
      remote: remoteBreeding,
      local: localBreeding,
      offlineManager: offlineManager,
    );

    final List<BreedingRecord> records = await repository.fetchBreedingRecords();

    expect(records, isNotEmpty);
    expect(remoteBreeding.fetchCount, equals(0));
  });
}
