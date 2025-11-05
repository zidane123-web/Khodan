import 'package:equatable/equatable.dart';

enum LitterStatus {
  gestating,
  palpationDue,
  weaning,
  harvestReady,
  archived,
}

extension LitterStatusX on LitterStatus {
  String get label {
    switch (this) {
      case LitterStatus.gestating:
        return 'Gestante';
      case LitterStatus.palpationDue:
        return 'A palper';
      case LitterStatus.weaning:
        return 'Sevrage';
      case LitterStatus.harvestReady:
        return 'Prete abattage';
      case LitterStatus.archived:
        return 'Archive';
    }
  }

  String get storageValue {
    switch (this) {
      case LitterStatus.gestating:
        return 'GESTATING';
      case LitterStatus.palpationDue:
        return 'PALPATION_DUE';
      case LitterStatus.weaning:
        return 'WEANING';
      case LitterStatus.harvestReady:
        return 'HARVEST_READY';
      case LitterStatus.archived:
        return 'ARCHIVED';
    }
  }

  static LitterStatus fromStorage(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'PALPATION_DUE':
        return LitterStatus.palpationDue;
      case 'WEANING':
        return LitterStatus.weaning;
      case 'HARVEST_READY':
        return LitterStatus.harvestReady;
      case 'ARCHIVED':
        return LitterStatus.archived;
      case 'GESTATING':
      default:
        return LitterStatus.gestating;
    }
  }
}

class LitterKit extends Equatable {
  const LitterKit({
    required this.id,
    required this.tag,
    required this.sex,
    this.birthWeightGrams,
    this.weaningWeightGrams,
    this.preSlaughterWeightGrams,
    this.carcassWeightKg,
    this.marketValue,
    this.destination,
    this.hasPendingSync = false,
  });

  final String id;
  final String tag;
  final String sex;
  final double? birthWeightGrams;
  final double? weaningWeightGrams;
  final double? preSlaughterWeightGrams;
  final double? carcassWeightKg;
  final double? marketValue;
  final String? destination;
  final bool hasPendingSync;

  LitterKit copyWith({
    String? id,
    String? tag,
    String? sex,
    double? birthWeightGrams,
    double? weaningWeightGrams,
    double? preSlaughterWeightGrams,
    double? carcassWeightKg,
    double? marketValue,
    String? destination,
    bool? hasPendingSync,
  }) {
    return LitterKit(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      sex: sex ?? this.sex,
      birthWeightGrams: birthWeightGrams ?? this.birthWeightGrams,
      weaningWeightGrams: weaningWeightGrams ?? this.weaningWeightGrams,
      preSlaughterWeightGrams:
          preSlaughterWeightGrams ?? this.preSlaughterWeightGrams,
      carcassWeightKg: carcassWeightKg ?? this.carcassWeightKg,
      marketValue: marketValue ?? this.marketValue,
      destination: destination ?? this.destination,
      hasPendingSync: hasPendingSync ?? this.hasPendingSync,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        tag,
        sex,
        birthWeightGrams,
        weaningWeightGrams,
        preSlaughterWeightGrams,
        carcassWeightKg,
        marketValue,
        destination,
        hasPendingSync,
      ];

  factory LitterKit.fromJson(Map<String, dynamic> json) {
    return LitterKit(
      id: json['id'] as String,
      tag: json['tag'] as String? ?? '',
      sex: json['sex'] as String? ?? '',
      birthWeightGrams: (json['birth_weight_grams'] as num?)?.toDouble(),
      weaningWeightGrams: (json['weaning_weight_grams'] as num?)?.toDouble(),
      preSlaughterWeightGrams:
          (json['pre_slaughter_weight_grams'] as num?)?.toDouble(),
      carcassWeightKg: (json['carcass_weight_kg'] as num?)?.toDouble(),
      marketValue: (json['market_value'] as num?)?.toDouble(),
      destination: json['destination'] as String?,
      hasPendingSync: json['has_pending_sync'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'tag': tag,
      'sex': sex,
      'birth_weight_grams': birthWeightGrams,
      'weaning_weight_grams': weaningWeightGrams,
      'pre_slaughter_weight_grams': preSlaughterWeightGrams,
      'carcass_weight_kg': carcassWeightKg,
      'market_value': marketValue,
      'destination': destination,
      'has_pending_sync': hasPendingSync,
    };
  }
}

class Litter extends Equatable {
  const Litter({
    required this.id,
    required this.code,
    required this.doeTag,
    required this.buckTag,
    required this.breedingDate,
    required this.kindlingDate,
    required this.bornAlive,
    required this.bornDead,
    required this.expectedWeaned,
    required this.cage,
    this.enclosure,
    this.status = LitterStatus.gestating,
    this.kits = const <LitterKit>[],
    this.notes,
    this.taskTemplateName,
    this.nextReminder,
    this.hasPendingSync = false,
  });

  final String id;
  final String code;
  final String doeTag;
  final String buckTag;
  final DateTime breedingDate;
  final DateTime kindlingDate;
  final int bornAlive;
  final int bornDead;
  final int expectedWeaned;
  final String cage;
  final String? enclosure;
  final LitterStatus status;
  final List<LitterKit> kits;
  final String? notes;
  final String? taskTemplateName;
  final DateTime? nextReminder;
  final bool hasPendingSync;

  int get totalKits => kits.length;

  int get kitsWithWeights =>
      kits.where((LitterKit kit) => kit.weaningWeightGrams != null).length;

  Litter copyWith({
    String? id,
    String? code,
    String? doeTag,
    String? buckTag,
    DateTime? breedingDate,
    DateTime? kindlingDate,
    int? bornAlive,
    int? bornDead,
    int? expectedWeaned,
    String? cage,
    String? enclosure,
    LitterStatus? status,
    List<LitterKit>? kits,
    String? notes,
    String? taskTemplateName,
    DateTime? nextReminder,
    bool? hasPendingSync,
  }) {
    return Litter(
      id: id ?? this.id,
      code: code ?? this.code,
      doeTag: doeTag ?? this.doeTag,
      buckTag: buckTag ?? this.buckTag,
      breedingDate: breedingDate ?? this.breedingDate,
      kindlingDate: kindlingDate ?? this.kindlingDate,
      bornAlive: bornAlive ?? this.bornAlive,
      bornDead: bornDead ?? this.bornDead,
      expectedWeaned: expectedWeaned ?? this.expectedWeaned,
      cage: cage ?? this.cage,
      enclosure: enclosure ?? this.enclosure,
      status: status ?? this.status,
      kits: kits ?? this.kits,
      notes: notes ?? this.notes,
      taskTemplateName: taskTemplateName ?? this.taskTemplateName,
      nextReminder: nextReminder ?? this.nextReminder,
      hasPendingSync: hasPendingSync ?? this.hasPendingSync,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        code,
        doeTag,
        buckTag,
        breedingDate,
        kindlingDate,
        bornAlive,
        bornDead,
        expectedWeaned,
        cage,
        enclosure,
        status,
        kits,
        notes,
        taskTemplateName,
        nextReminder,
      hasPendingSync,
      ];

  factory Litter.fromJson(Map<String, dynamic> json) {
    return Litter(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      doeTag: json['doe_tag'] as String? ?? '',
      buckTag: json['buck_tag'] as String? ?? '',
      breedingDate: DateTime.parse(json['breeding_date'] as String),
      kindlingDate: DateTime.parse(json['kindling_date'] as String),
      bornAlive: (json['born_alive'] as num).toInt(),
      bornDead: (json['born_dead'] as num?)?.toInt() ?? 0,
      expectedWeaned: (json['expected_weaned'] as num).toInt(),
      cage: json['cage'] as String? ?? '',
      enclosure: json['enclosure'] as String?,
      status: LitterStatusX.fromStorage(json['status'] as String?),
      kits: (json['kits'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => LitterKit.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      notes: json['notes'] as String?,
      taskTemplateName: json['task_template_name'] as String?,
      nextReminder: json['next_reminder'] == null
          ? null
          : DateTime.parse(json['next_reminder'] as String),
      hasPendingSync: json['has_pending_sync'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'doe_tag': doeTag,
      'buck_tag': buckTag,
      'breeding_date': breedingDate.toIso8601String(),
      'kindling_date': kindlingDate.toIso8601String(),
      'born_alive': bornAlive,
      'born_dead': bornDead,
      'expected_weaned': expectedWeaned,
      'cage': cage,
      'enclosure': enclosure,
      'status': status.storageValue,
      'kits': kits.map((LitterKit kit) => kit.toJson()).toList(),
      'notes': notes,
      'task_template_name': taskTemplateName,
      'next_reminder': nextReminder?.toIso8601String(),
      'has_pending_sync': hasPendingSync,
    };
  }
}

class LitterDraft {
  const LitterDraft({
    required this.code,
    required this.doeTag,
    required this.buckTag,
    required this.breedingDate,
    required this.kindlingDate,
    required this.bornAlive,
    required this.expectedWeaned,
    required this.cage,
    this.bornDead = 0,
    this.enclosure,
    this.taskTemplateName,
    this.notes,
  });

  final String code;
  final String doeTag;
  final String buckTag;
  final DateTime breedingDate;
  final DateTime kindlingDate;
  final int bornAlive;
  final int bornDead;
  final int expectedWeaned;
  final String cage;
  final String? enclosure;
  final String? taskTemplateName;
  final String? notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'doe_tag': doeTag,
      'buck_tag': buckTag,
      'breeding_date': breedingDate.toIso8601String(),
      'kindling_date': kindlingDate.toIso8601String(),
      'born_alive': bornAlive,
      'born_dead': bornDead,
      'expected_weaned': expectedWeaned,
      'cage': cage,
      'enclosure': enclosure,
      'task_template_name': taskTemplateName,
      'notes': notes,
    };
  }

  factory LitterDraft.fromJson(Map<String, dynamic> json) {
    return LitterDraft(
      code: json['code'] as String? ?? '',
      doeTag: json['doe_tag'] as String? ?? '',
      buckTag: json['buck_tag'] as String? ?? '',
      breedingDate: DateTime.parse(json['breeding_date'] as String),
      kindlingDate: DateTime.parse(json['kindling_date'] as String),
      bornAlive: (json['born_alive'] as num).toInt(),
      expectedWeaned: (json['expected_weaned'] as num).toInt(),
      cage: json['cage'] as String? ?? '',
      bornDead: (json['born_dead'] as num?)?.toInt() ?? 0,
      enclosure: json['enclosure'] as String?,
      taskTemplateName: json['task_template_name'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

class LitterBatchUpdate {
  const LitterBatchUpdate({
    required this.litterIds,
    this.status,
    this.cage,
    this.enclosure,
    this.notes,
    this.nextReminder,
  });

  final List<String> litterIds;
  final LitterStatus? status;
  final String? cage;
  final String? enclosure;
  final String? notes;
  final DateTime? nextReminder;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'litter_ids': litterIds,
      'status': status?.storageValue,
      'cage': cage,
      'enclosure': enclosure,
      'notes': notes,
      'next_reminder': nextReminder?.toIso8601String(),
    };
  }

  factory LitterBatchUpdate.fromJson(Map<String, dynamic> json) {
    return LitterBatchUpdate(
      litterIds: (json['litter_ids'] as List<dynamic>? ?? <dynamic>[])
          .cast<String>(),
      status: json['status'] == null
          ? null
          : LitterStatusX.fromStorage(json['status'] as String),
      cage: json['cage'] as String?,
      enclosure: json['enclosure'] as String?,
      notes: json['notes'] as String?,
      nextReminder: json['next_reminder'] == null
          ? null
          : DateTime.parse(json['next_reminder'] as String),
    );
  }
}

class LitterKitWeightInput {
  const LitterKitWeightInput({
    required this.kitId,
    this.weaningWeightGrams,
    this.preSlaughterWeightGrams,
    this.carcassWeightKg,
    this.marketValue,
    this.destination,
  });

  final String kitId;
  final double? weaningWeightGrams;
  final double? preSlaughterWeightGrams;
  final double? carcassWeightKg;
  final double? marketValue;
  final String? destination;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'kit_id': kitId,
      'weaning_weight_grams': weaningWeightGrams,
      'pre_slaughter_weight_grams': preSlaughterWeightGrams,
      'carcass_weight_kg': carcassWeightKg,
      'market_value': marketValue,
      'destination': destination,
    };
  }

  factory LitterKitWeightInput.fromJson(Map<String, dynamic> json) {
    return LitterKitWeightInput(
      kitId: json['kit_id'] as String,
      weaningWeightGrams: (json['weaning_weight_grams'] as num?)?.toDouble(),
      preSlaughterWeightGrams:
          (json['pre_slaughter_weight_grams'] as num?)?.toDouble(),
      carcassWeightKg: (json['carcass_weight_kg'] as num?)?.toDouble(),
      marketValue: (json['market_value'] as num?)?.toDouble(),
      destination: json['destination'] as String?,
    );
  }
}
