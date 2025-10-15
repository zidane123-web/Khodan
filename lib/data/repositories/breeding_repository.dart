import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/breeding_record.dart';
import '../services/api_client.dart';
abstract class BreedingRepository {
  Future<List<BreedingRecord>> fetchBreedingRecords();

  Future<BreedingRecord> createBreedingRecord(BreedingRecord record);

  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record);

  Future<void> deleteBreedingRecord(String id);
}

class InMemoryBreedingRepository implements BreedingRepository {
  factory InMemoryBreedingRepository() => _instance;

  InMemoryBreedingRepository._internal();

  static InMemoryBreedingRepository _instance =
      InMemoryBreedingRepository._internal();

  static void reset() {
    _instance = InMemoryBreedingRepository._internal();
  }

  final List<BreedingRecord> _records = <BreedingRecord>[
    BreedingRecord(
      id: 'breeding-001',
      profileId: 'demo-profile',
      doeId: 'doe-001',
      buckId: 'buck-001',
      matingDate: DateTime.now().subtract(const Duration(days: 34)),
      palpationDate: DateTime.now().subtract(const Duration(days: 22)),
      palpationPositive: true,
      kindlingDate: DateTime.now().subtract(const Duration(days: 3)),
      kitsBornAlive: 8,
      kitsBornDead: 1,
      adoptedKitsIn: 1,
    ),
    BreedingRecord(
      id: 'breeding-002',
      profileId: 'demo-profile',
      doeId: 'doe-002',
      buckId: 'buck-001',
      matingDate: DateTime.now().subtract(const Duration(days: 10)),
    ),
    BreedingRecord(
      id: 'breeding-003',
      profileId: 'demo-profile',
      doeId: 'doe-001',
      buckId: 'buck-002',
      matingDate: DateTime.now().subtract(const Duration(days: 80)),
      palpationDate: DateTime.now().subtract(const Duration(days: 68)),
      palpationPositive: true,
      kindlingDate: DateTime.now().subtract(const Duration(days: 49)),
      kitsBornAlive: 7,
      kitsWeaned: 7,
      weaningDate: DateTime.now().subtract(const Duration(days: 21)),
      averageWeaningWeight: 1.8,
      notes: 'Portée homogène, croissance régulière.',
    ),
    BreedingRecord(
      id: 'breeding-004',
      profileId: 'demo-profile',
      doeId: 'doe-003',
      buckId: 'buck-002',
      matingDate: DateTime.now().add(const Duration(days: 3)),
    ),
  ];

  @override
  Future<List<BreedingRecord>> fetchBreedingRecords() async {
    final List<BreedingRecord> records = List<BreedingRecord>.from(_records);
    records.sort(
      (BreedingRecord a, BreedingRecord b) =>
          b.matingDate.compareTo(a.matingDate),
    );
    return records;
  }

  @override
  Future<BreedingRecord> createBreedingRecord(BreedingRecord record) async {
    final BreedingRecord created = record.copyWith(
      id: 'breeding-${DateTime.now().millisecondsSinceEpoch}',
    );
    _records.add(created);
    return created;
  }

  @override
  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) async {
    final int index =
        _records.indexWhere((BreedingRecord element) => element.id == record.id);
    if (index == -1) {
      throw StateError('Saillie ${record.id} introuvable');
    }
    _records[index] = record;
    return record;
  }

  @override
  Future<void> deleteBreedingRecord(String id) async {
    _records.removeWhere((BreedingRecord record) => record.id == id);
  }
}

class SupabaseBreedingRepository implements BreedingRepository {
  SupabaseBreedingRepository({ApiExecutor? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<List<BreedingRecord>> fetchBreedingRecords() async {
    final List<dynamic> data = await _api.run(
      (SupabaseClient client) {
        return client.from('breeding_records').select();
      },
      label: 'breeding.fetch',
    );
    return data
        .map((dynamic row) =>
            BreedingRecord.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BreedingRecord> createBreedingRecord(BreedingRecord record) async {
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client.from('breeding_records').insert(record.toJson()).select();
      },
      label: 'breeding.create',
    );
    return BreedingRecord.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) async {
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('breeding_records')
            .update(record.toJson())
            .eq('id', record.id)
            .select();
      },
      label: 'breeding.update',
    );
    return BreedingRecord.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<void> deleteBreedingRecord(String id) {
    return _api.run(
      (SupabaseClient client) {
        return client.from('breeding_records').delete().eq('id', id);
      },
      label: 'breeding.delete',
    );
  }
}
