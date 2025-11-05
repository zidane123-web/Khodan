import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:khodan/data/models/animal.dart';
import 'package:khodan/data/models/animal_event.dart';
import 'package:khodan/data/models/cage_card_template.dart';
import 'package:khodan/data/models/event.dart';
import 'package:khodan/data/models/litter.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/event_repository.dart';
import 'package:khodan/data/repositories/litter_repository.dart';
import 'package:khodan/data/services/api_client.dart';
import 'package:khodan/data/services/cage_card_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockAnimalRepository extends Mock implements AnimalRepository {}

class _MockLitterRepository extends Mock implements LitterRepository {}

class _MockEventRepository extends Mock implements EventRepository {}

void main() {
  late _MockAnimalRepository animalRepository;
  late _MockLitterRepository litterRepository;
  late _MockEventRepository eventRepository;
  late CageCardService service;

  setUp(() {
    animalRepository = _MockAnimalRepository();
    litterRepository = _MockLitterRepository();
    eventRepository = _MockEventRepository();
    when(
      () => eventRepository.fetchEvents(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) async => <LivestockEvent>[]);
    when(() => eventRepository.fetchEventLinks()).thenAnswer(
      (_) async => <AnimalEventLink>[],
    );
    service = CageCardService(
      animalRepository: animalRepository,
      litterRepository: litterRepository,
      eventRepository: eventRepository,
      apiClient: _FakeApiExecutor(),
    );
  });

  group('CageCardService', () {
    test('loadActiveRecords merges breeders and litters with deep links', () async {
      final Animal doe = Animal(
        id: 'doe-123',
        profileId: 'demo',
        speciesId: 1,
        tagId: 'F01',
        name: 'Neige',
        birthDate: DateTime(2024, 3, 2),
        sex: 'Femelle',
        status: 'Actif',
        cageNumber: 'C12',
      );
      final Litter litter = Litter(
        id: 'litter-1',
        code: 'P-18',
        doeTag: 'F01',
        buckTag: 'M01',
        breedingDate: DateTime(2025, 9, 1),
        kindlingDate: DateTime(2025, 10, 2),
        bornAlive: 8,
        bornDead: 0,
        expectedWeaned: 7,
        cage: 'G5',
        status: LitterStatus.weaning,
        kits: const <LitterKit>[],
      );

      when(
        () => animalRepository.fetchAnimals(speciesId: 1),
      ).thenAnswer((_) async => <Animal>[doe]);
      when(litterRepository.fetchLitters).thenAnswer(
        (_) async => <Litter>[litter],
      );

      final List<CageCardRecord> records = await service.loadActiveRecords(
        baseDeepLink: Uri.parse('https://test.local'),
      );

      expect(records.length, 2);
      final CageCardRecord breederRecord = records
          .firstWhere((CageCardRecord r) => r.subjectType == CageCardSubjectType.breeder);
      expect(breederRecord.title, contains('Neige'));
      expect(breederRecord.deepLink.toString(), 'https://test.local/breeders/doe-123');
    });

    test('loadActiveRecords renseigne les pesées réelles quand dispo', () async {
      final Animal doe = Animal(
        id: 'doe-123',
        profileId: 'demo',
        speciesId: 1,
        tagId: 'F01',
        name: 'Neige',
        birthDate: DateTime(2024, 3, 2),
        sex: 'Femelle',
        status: 'Actif',
        cageNumber: 'C12',
      );
      when(
        () => animalRepository.fetchAnimals(speciesId: 1),
      ).thenAnswer((_) async => <Animal>[doe]);
      when(litterRepository.fetchLitters).thenAnswer(
        (_) async => <Litter>[],
      );

      final LivestockEvent weightEvent = LivestockEvent(
        id: 'evt-1',
        profileId: 'demo',
        eventType: 'weight',
        eventDate: DateTime(2025, 10, 1),
        details: <String, dynamic>{'weightKg': 4.2},
      );
      when(
        () => eventRepository.fetchEvents(
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => <LivestockEvent>[weightEvent]);
      when(() => eventRepository.fetchEventLinks()).thenAnswer(
        (_) async => <AnimalEventLink>[
          const AnimalEventLink(eventId: 'evt-1', animalId: 'doe-123', role: 'subject'),
        ],
      );

      final List<CageCardRecord> records = await service.loadActiveRecords();
      final CageCardRecord breederRecord = records.single;
      expect(breederRecord.latestWeightKg, 4.2);
      expect(breederRecord.latestWeightDate, DateTime(2025, 10, 1));
    });

    test('generatePdf returns valid PDF bytes', () async {
      final CageCardTemplate template = CageCardTemplate(
        id: 'tpl',
        label: 'Test',
        format: CageCardFormat.a4,
      );
      final CageCardRecord record = CageCardRecord(
        id: 'breeder-1',
        title: 'Blitz #B14',
        cageLabel: 'C12',
        subjectType: CageCardSubjectType.breeder,
        deepLink: Uri.parse('https://example.com/breeders/breeder-1'),
        birthDate: DateTime(2024, 7, 12),
        latestWeightKg: 3.2,
        latestWeightDate: DateTime(2025, 10, 1),
        includeSensitive: true,
        sensitiveNote: 'Coût achat : 12 000 FCFA',
      );

      final Uint8List bytes = await service.generatePdf(
        template: template,
        records: <CageCardRecord>[record],
      );

      expect(bytes, isNotEmpty);
      final String header = String.fromCharCodes(bytes.take(4));
      expect(header, equals('%PDF'));
    });
  });
}
class _FakeApiExecutor extends Fake implements ApiExecutor {
  @override
  SupabaseClient get client => throw UnimplementedError();

  @override
  Future<T> run<T>(
    Future<T> Function(SupabaseClient client) operation, {
    String? label,
  }) {
    throw UnimplementedError();
  }
}
