import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

/// Node representing a single ancestor in the pedigree tree.
class PedigreeNode extends Equatable {
  const PedigreeNode({
    required this.generation,
    required this.relationPath,
    required this.relationSide,
    required this.relationLabel,
    required this.missing,
    this.profileId,
    this.id,
    this.tagId,
    this.displayName,
    this.registeredName,
    this.sex,
    this.status,
    this.birthDate,
    this.entryDate,
    this.cageNumber,
    this.origin,
    this.speciesId,
    this.lastMatingDate,
    this.lastKindlingDate,
    this.lastWeaningDate,
    this.raw,
  });

  factory PedigreeNode.fromMap(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return PedigreeNode(
      generation: (json['generation'] as num?)?.toInt() ?? 0,
      relationPath: json['relation_path'] as String? ?? '',
      relationSide: json['relation_side'] as String? ?? '',
      relationLabel: json['relation_label'] as String? ?? '',
      missing: json['missing'] as bool? ?? false,
      profileId: json['profile_id'] as String?,
      id: json['breeder_id'] as String?,
      tagId: json['tag_id'] as String?,
      displayName: json['display_name'] as String?,
      registeredName: json['registered_name'] as String?,
      sex: json['sex'] as String?,
      status: json['status'] as String?,
      birthDate: parseDate(json['birth_date']),
      entryDate: parseDate(json['entry_date']),
      cageNumber: json['cage_number'] as String?,
      origin: json['origin'] as String?,
      speciesId: (json['species_id'] as num?)?.toInt(),
      lastMatingDate: parseDate(json['last_mating_date']),
      lastKindlingDate: parseDate(json['last_kindling_date']),
      lastWeaningDate: parseDate(json['last_weaning_date']),
      raw: json['node'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['node'] as Map)
          : null,
    );
  }

  final int generation;
  final String relationPath;
  final String relationSide;
  final String relationLabel;
  final bool missing;

  final String? profileId;
  final String? id;
  final String? tagId;
  final String? displayName;
  final String? registeredName;
  final String? sex;
  final String? status;
  final DateTime? birthDate;
  final DateTime? entryDate;
  final String? cageNumber;
  final String? origin;
  final int? speciesId;
  final DateTime? lastMatingDate;
  final DateTime? lastKindlingDate;
  final DateTime? lastWeaningDate;
  final Map<String, dynamic>? raw;

  String get effectiveName =>
      displayName ??
      registeredName ??
      tagId ??
      (relationLabel.isEmpty ? 'Ancetre' : relationLabel);

  String get shortSex {
    final String value = (sex ?? '').toLowerCase();
    if (value.startsWith('f')) return 'Femelle';
    if (value.startsWith('m')) return 'Male';
    return '';
  }

  @override
  List<Object?> get props => <Object?>[
    generation,
    relationPath,
    relationSide,
    relationLabel,
    missing,
    profileId,
    id,
    tagId,
    displayName,
    registeredName,
    sex,
    status,
    birthDate,
    entryDate,
    cageNumber,
    origin,
    speciesId,
    lastMatingDate,
    lastKindlingDate,
    lastWeaningDate,
    raw,
  ];
}

/// Aggregate representing all nodes returned by fn_pedigree_tree.
class PedigreeTree extends Equatable {
  const PedigreeTree({required this.nodes, required this.requestedGenerations});

  factory PedigreeTree.fromRows(
    List<Map<String, dynamic>> rows, {
    required int requestedGenerations,
  }) {
    final List<PedigreeNode> nodes =
        rows.map(PedigreeNode.fromMap).toList(growable: false)..sort(
          (PedigreeNode a, PedigreeNode b) =>
              a.generation.compareTo(b.generation),
        );
    return PedigreeTree(
      nodes: nodes,
      requestedGenerations: requestedGenerations,
    );
  }

  final List<PedigreeNode> nodes;
  final int requestedGenerations;

  PedigreeNode get subject =>
      nodes.firstWhere((PedigreeNode node) => node.generation == 0);

  int get generationCount =>
      nodes.map((PedigreeNode node) => node.generation).maxOrNull ?? 0;

  Map<int, List<PedigreeNode>> get nodesByGeneration {
    final Map<int, List<PedigreeNode>> map = <int, List<PedigreeNode>>{};
    for (final PedigreeNode node in nodes) {
      map.putIfAbsent(node.generation, () => <PedigreeNode>[]).add(node);
    }
    for (final List<PedigreeNode> generationNodes in map.values) {
      generationNodes.sort(
        (PedigreeNode a, PedigreeNode b) =>
            a.relationPath.compareTo(b.relationPath),
      );
    }
    return map;
  }

  List<List<PedigreeNode>> get columns {
    final Map<int, List<PedigreeNode>> grouped = nodesByGeneration;
    final List<int> keys = grouped.keys.toList()
      ..sort((int a, int b) => a.compareTo(b));
    return keys.map((int key) => grouped[key] ?? <PedigreeNode>[]).toList();
  }

  @override
  List<Object?> get props => <Object?>[nodes, requestedGenerations];
}

/// Presentation options applied to the generated PDF.
class PedigreePdfTheme extends Equatable {
  const PedigreePdfTheme({
    this.primaryHex = '0E7F45',
    this.secondaryHex = 'C8E6C9',
    this.surfaceHex = 'F6F0E5',
    this.textHex = '323232',
  });

  final String primaryHex;
  final String secondaryHex;
  final String surfaceHex;
  final String textHex;

  @override
  List<Object?> get props => <Object?>[
    primaryHex,
    secondaryHex,
    surfaceHex,
    textHex,
  ];
}
