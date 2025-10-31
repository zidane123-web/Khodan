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
}
