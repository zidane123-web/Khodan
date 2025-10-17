import 'package:flutter_test/flutter_test.dart';
import 'package:khodan/data/local/local_data_sources.dart';
import 'package:khodan/data/models/animal_event.dart';
import 'package:khodan/data/models/event.dart';
import 'package:khodan/data/repositories/event_repository.dart';
import 'package:khodan/data/services/offline_sync_manager.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocalEventDataSource extends Mock implements LocalEventDataSource {}

class _FakeRemoteEventRepository implements EventRepository {
  _FakeRemoteEventRepository(this._events, this._links);

  List<LivestockEvent> _events;
  List<AnimalEventLink> _links;
  int fetchCount = 0;
  int fetchLinksCount = 0;

  @override
  Future<List<LivestockEvent>> fetchEvents({DateTime? start, DateTime? end}) async {
    fetchCount += 1;
    return _events;
  }

  @override
  Future<List<AnimalEventLink>> fetchEventLinks() async {
    fetchLinksCount += 1;
    return _links;
  }

  @override
  Future<LivestockEvent> createEvent(
    LivestockEvent event, {
    List<AnimalEventLink> links = const <AnimalEventLink>[],
  }) async {
    _events = <LivestockEvent>[event];
    _links = links;
    return event;
  }
}

void main() {
  late _MockLocalEventDataSource local;
  late _FakeRemoteEventRepository remote;
  late SyncedEventRepository repository;

  final LivestockEvent sampleEvent = LivestockEvent(
    id: 'event-1',
    profileId: 'profile-1',
    eventType: 'health_check',
    eventDate: DateTime(2025, 1, 1),
    details: <String, dynamic>{'veterinarian': 'Dr. Foster'},
  );

  final AnimalEventLink sampleLink = AnimalEventLink(
    eventId: 'event-1',
    animalId: 'animal-1',
    role: 'subject',
  );

  setUpAll(() {
    registerFallbackValue(<LivestockEvent>[]);
    registerFallbackValue(<AnimalEventLink>[]);
  });

  setUp(() {
    local = _MockLocalEventDataSource();
    remote = _FakeRemoteEventRepository(
      <LivestockEvent>[sampleEvent],
      <AnimalEventLink>[sampleLink],
    );
    repository = SyncedEventRepository(
      remote: remote,
      local: local,
      offlineManager: OfflineSyncManager.instance,
    );
  });

  tearDown(() {
    OfflineSyncManager.instance.setOffline(false, flushWhenOnline: false);
  });

  test('fetchEvents pulls from cache when offline', () async {
    OfflineSyncManager.instance.setOffline(true, flushWhenOnline: false);
    when(() => local.fetchEvents(start: any(named: 'start'), end: any(named: 'end')))
        .thenAnswer((_) async => <LivestockEvent>[sampleEvent]);
    when(() => local.fetchLinks()).thenAnswer((_) async => <AnimalEventLink>[sampleLink]);

    final List<LivestockEvent> events = await repository.fetchEvents();
    final List<AnimalEventLink> links = await repository.fetchEventLinks();

    expect(remote.fetchCount, equals(0));
    expect(remote.fetchLinksCount, equals(0));
    expect(events, <LivestockEvent>[sampleEvent]);
    expect(links, <AnimalEventLink>[sampleLink]);
  });

  test('fetchEvents refreshes cache when online', () async {
    when(() => local.fetchLinks()).thenAnswer((_) async => <AnimalEventLink>[]);
    when(() => local.replaceEvents(any(), links: any(named: 'links')))
        .thenAnswer((_) async {});
    when(() => local.replaceLinks(any())).thenAnswer((_) async {});

    final List<LivestockEvent> events = await repository.fetchEvents();
    final List<AnimalEventLink> links = await repository.fetchEventLinks();

    expect(remote.fetchCount, equals(1));
    expect(remote.fetchLinksCount, equals(1));
    expect(events, <LivestockEvent>[sampleEvent]);
    expect(links, <AnimalEventLink>[sampleLink]);
    verify(() => local.replaceEvents(<LivestockEvent>[sampleEvent], links: any(named: 'links')))
        .called(1);
    verify(() => local.replaceLinks(<AnimalEventLink>[sampleLink])).called(1);
  });
}
