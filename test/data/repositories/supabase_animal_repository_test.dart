import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:khodan/data/models/animal.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/services/api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _StubApiExecutor implements ApiExecutor {
  _StubApiExecutor();

  final Queue<Object?> _responses = Queue<Object?>();

  void enqueue(Object? value) => _responses.add(value);

  @override
  SupabaseClient get client => throw UnimplementedError();

  @override
  Future<T> run<T>(
    Future<T> Function(SupabaseClient client) operation, {
    String? label,
  }) async {
    if (_responses.isEmpty) {
      return Future<T>.error(
        StateError('No stubbed response for $label'),
      );
    }
    final Object? next = _responses.removeFirst();
    if (next is Exception) {
      throw next;
    }
    if (next is Future<T>) {
      return next;
    }
    return next as T;
  }
}

void main() {
  late _StubApiExecutor apiExecutor;
  late SupabaseAnimalRepository repository;

  setUp(() {
    apiExecutor = _StubApiExecutor();
    repository = SupabaseAnimalRepository(apiClient: apiExecutor);
  });

  Animal buildAnimal() {
    return Animal(
      id: 'animal-1',
      profileId: 'profile-1',
      speciesId: 1,
      tagId: 'TAG-01',
      birthDate: DateTime.utc(2024, 1, 10),
      sex: 'Femelle',
      status: 'Actif',
      name: 'Demo',
    );
  }

  Map<String, dynamic> animalToJson(Animal animal) {
    return animal.toJson()
      ..addAll(<String, dynamic>{
        'birth_date': animal.birthDate.toIso8601String(),
      });
  }

  test('fetchAnimals parses Supabase payload', () async {
    final Animal expected = buildAnimal();
    apiExecutor.enqueue(<dynamic>[animalToJson(expected)]);

    final List<Animal> animals = await repository.fetchAnimals();

    expect(animals, hasLength(1));
    expect(animals.first, equals(expected));
  });

  test('createAnimal returns created animal', () async {
    final Animal input = buildAnimal();
    apiExecutor.enqueue(<dynamic>[animalToJson(input)]);

    final Animal created = await repository.createAnimal(input);

    expect(created, equals(input));
  });

  test('updateAnimal propagates DataLayerException', () async {
    apiExecutor.enqueue(DataLayerException('update failed'));

    expect(
      () => repository.updateAnimal(buildAnimal()),
      throwsA(isA<DataLayerException>()),
    );
  });

  test('deleteAnimal completes when Supabase succeeds', () async {
    apiExecutor.enqueue(<dynamic>[]);

    await repository.deleteAnimal('animal-1');
  });
}
