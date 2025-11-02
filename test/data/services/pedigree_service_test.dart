import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khodan/data/models/pedigree.dart';
import 'package:khodan/data/services/api_client.dart';
import 'package:khodan/data/services/pedigree_service.dart';

class _FakeApiExecutor implements ApiExecutor {
  _FakeApiExecutor(this.result);

  final List<dynamic> result;

  @override
  SupabaseClient get client =>
      throw UnimplementedError('SupabaseClient not available in fake');

  @override
  Future<T> run<T>(
    Future<T> Function(SupabaseClient client) operation, {
    String? label,
  }) async {
    return result as T;
  }
}

void main() {
  group('PedigreeService', () {
    test('fetchTree returns grouped ancestors with missing flags', () async {
      final List<Map<String, dynamic>> rows = <Map<String, dynamic>>[
        <String, dynamic>{
          'profile_id': 'profile-1',
          'breeder_id': 'root-id',
          'generation': 0,
          'relation_path': '',
          'relation_side': 'root',
          'relation_label': 'Sujet',
          'tag_id': 'F01',
          'display_name': 'Fiona',
          'registered_name': 'Fiona',
          'sex': 'Femelle',
          'status': 'Actif',
          'birth_date': '2024-01-01',
          'entry_date': '2024-02-01',
          'cage_number': 'C101',
          'origin': 'Elevage interne',
          'species_id': 1,
          'missing': false,
          'last_mating_date': '2024-03-01',
          'last_kindling_date': null,
          'last_weaning_date': null,
          'node': <String, dynamic>{'id': 'root-id'},
        },
        <String, dynamic>{
          'profile_id': 'profile-1',
          'breeder_id': 'father-id',
          'generation': 1,
          'relation_path': 'P',
          'relation_side': 'P',
          'relation_label': 'Pere',
          'tag_id': 'M01',
          'display_name': 'Jasper',
          'registered_name': 'Jasper',
          'sex': 'Male',
          'status': 'Actif',
          'birth_date': '2022-01-01',
          'entry_date': '2022-02-01',
          'cage_number': 'C205',
          'origin': 'Elevage interne',
          'species_id': 1,
          'missing': false,
          'last_mating_date': '2024-02-15',
          'last_kindling_date': '2024-03-15',
          'last_weaning_date': null,
          'node': <String, dynamic>{'id': 'father-id'},
        },
        <String, dynamic>{
          'profile_id': 'profile-1',
          'breeder_id': null,
          'generation': 1,
          'relation_path': 'M',
          'relation_side': 'M',
          'relation_label': 'Mere',
          'tag_id': null,
          'display_name': null,
          'registered_name': null,
          'sex': null,
          'status': null,
          'birth_date': null,
          'entry_date': null,
          'cage_number': null,
          'origin': null,
          'species_id': 1,
          'missing': true,
          'last_mating_date': null,
          'last_kindling_date': null,
          'last_weaning_date': null,
          'node': null,
        },
      ];

      final PedigreeService service = PedigreeService(
        apiClient: _FakeApiExecutor(rows),
      );

      final PedigreeTree tree = await service.fetchTree(
        breederId: 'root-id',
        generations: 2,
      );

      expect(tree.nodes.length, 3);
      expect(tree.nodesByGeneration[0]!.length, 1);
      expect(tree.nodesByGeneration[1]!.length, 2);
      expect(tree.subject.effectiveName, 'Fiona');

      final PedigreeNode mother = tree.nodes.firstWhere(
        (PedigreeNode node) => node.relationPath == 'M',
      );
      expect(mother.missing, isTrue);
    });
  });
}
