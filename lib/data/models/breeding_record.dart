import 'package:equatable/equatable.dart';

enum BreedingTaskType { palpation, kindling, weaning }

class BreedingTask extends Equatable {
  const BreedingTask({
    required this.type,
    required this.dueDate,
    this.completedDate,
  });

  final BreedingTaskType type;
  final DateTime dueDate;
  final DateTime? completedDate;

  bool get isCompleted => completedDate != null;

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  @override
  List<Object?> get props => <Object?>[type, dueDate, completedDate];
}

class BreedingReminder extends Equatable {
  const BreedingReminder({
    required this.recordId,
    required this.doeId,
    required this.buckId,
    required this.type,
    required this.dueDate,
    this.completedDate,
  });

  final String recordId;
  final String doeId;
  final String buckId;
  final BreedingTaskType type;
  final DateTime dueDate;
  final DateTime? completedDate;

  bool get isCompleted => completedDate != null;

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  static List<BreedingReminder> build(List<BreedingRecord> records) {
    final DateTime now = DateTime.now();
    final List<BreedingReminder> reminders = <BreedingReminder>[];
    for (final BreedingRecord record in records) {
      for (final BreedingTask task in record.tasks) {
        if (task.isCompleted) {
          continue;
        }
        if (task.type != BreedingTaskType.palpation &&
            record.palpationPositive == false) {
          continue;
        }
        if (task.dueDate.isBefore(now.subtract(const Duration(days: 30)))) {
          continue;
        }
        reminders.add(
          BreedingReminder(
            recordId: record.id,
            doeId: record.doeId,
            buckId: record.buckId,
            type: task.type,
            dueDate: task.dueDate,
            completedDate: task.completedDate,
          ),
        );
      }
    }
    reminders.sort(
      (BreedingReminder a, BreedingReminder b) =>
          a.dueDate.compareTo(b.dueDate),
    );
    return reminders;
  }

  @override
  List<Object?> get props => <Object?>[
        recordId,
        doeId,
        buckId,
        type,
        dueDate,
        completedDate,
      ];
}

class BreedingRecord extends Equatable {
  const BreedingRecord({
    required this.id,
    required this.profileId,
    required this.doeId,
    required this.buckId,
    required this.matingDate,
    this.palpationDate,
    this.palpationPositive,
    this.kindlingDate,
    this.kitsBornAlive,
    this.kitsBornDead,
    this.adoptedKitsIn,
    this.kitsRemoved,
    this.weaningDate,
    this.kitsWeaned,
    this.averageWeaningWeight,
    this.notes,
  });

  final String id;
  final String profileId;
  final String doeId;
  final String buckId;
  final DateTime matingDate;
  final DateTime? palpationDate;
  final bool? palpationPositive;
  final DateTime? kindlingDate;
  final int? kitsBornAlive;
  final int? kitsBornDead;
  final int? adoptedKitsIn;
  final int? kitsRemoved;
  final DateTime? weaningDate;
  final int? kitsWeaned;
  final double? averageWeaningWeight;
  final String? notes;

  DateTime get plannedPalpationDate =>
      matingDate.add(const Duration(days: 12));

  DateTime get plannedKindlingDate =>
      matingDate.add(const Duration(days: 31));

  DateTime get plannedWeaningDate =>
      (kindlingDate ?? plannedKindlingDate).add(const Duration(days: 28));

  List<BreedingTask> get tasks {
    final List<BreedingTask> tasks = <BreedingTask>[
      BreedingTask(
        type: BreedingTaskType.palpation,
        dueDate: plannedPalpationDate,
        completedDate: palpationDate,
      ),
    ];

    if (palpationPositive != false) {
      tasks
        ..add(
          BreedingTask(
            type: BreedingTaskType.kindling,
            dueDate: plannedKindlingDate,
            completedDate: kindlingDate,
          ),
        )
        ..add(
          BreedingTask(
            type: BreedingTaskType.weaning,
            dueDate: plannedWeaningDate,
            completedDate: weaningDate,
          ),
        );
    }

    return tasks;
  }

  BreedingRecord copyWith({
    String? id,
    String? profileId,
    String? doeId,
    String? buckId,
    DateTime? matingDate,
    DateTime? palpationDate,
    bool? palpationPositive,
    bool clearPalpationPositive = false,
    DateTime? kindlingDate,
    bool clearKindlingDate = false,
    int? kitsBornAlive,
    bool clearKitsBornAlive = false,
    int? kitsBornDead,
    bool clearKitsBornDead = false,
    int? adoptedKitsIn,
    bool clearAdoptedKitsIn = false,
    int? kitsRemoved,
    bool clearKitsRemoved = false,
    DateTime? weaningDate,
    bool clearWeaningDate = false,
    int? kitsWeaned,
    bool clearKitsWeaned = false,
    double? averageWeaningWeight,
    bool clearAverageWeaningWeight = false,
    String? notes,
    bool clearNotes = false,
  }) {
    return BreedingRecord(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      doeId: doeId ?? this.doeId,
      buckId: buckId ?? this.buckId,
      matingDate: matingDate ?? this.matingDate,
      palpationDate: palpationDate ?? this.palpationDate,
      palpationPositive:
          clearPalpationPositive ? null : (palpationPositive ?? this.palpationPositive),
      kindlingDate: clearKindlingDate ? null : (kindlingDate ?? this.kindlingDate),
      kitsBornAlive:
          clearKitsBornAlive ? null : (kitsBornAlive ?? this.kitsBornAlive),
      kitsBornDead:
          clearKitsBornDead ? null : (kitsBornDead ?? this.kitsBornDead),
      adoptedKitsIn:
          clearAdoptedKitsIn ? null : (adoptedKitsIn ?? this.adoptedKitsIn),
      kitsRemoved: clearKitsRemoved ? null : (kitsRemoved ?? this.kitsRemoved),
      weaningDate: clearWeaningDate ? null : (weaningDate ?? this.weaningDate),
      kitsWeaned: clearKitsWeaned ? null : (kitsWeaned ?? this.kitsWeaned),
      averageWeaningWeight: clearAverageWeaningWeight
          ? null
          : (averageWeaningWeight ?? this.averageWeaningWeight),
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  factory BreedingRecord.fromJson(Map<String, dynamic> json) {
    return BreedingRecord(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      doeId: json['doe_id'] as String,
      buckId: json['buck_id'] as String,
      matingDate: DateTime.parse(json['mating_date'] as String),
      palpationDate: json['palpation_date'] != null
          ? DateTime.parse(json['palpation_date'] as String)
          : null,
      palpationPositive: json['palpation_positive'] as bool?,
      kindlingDate: json['kindling_date'] != null
          ? DateTime.parse(json['kindling_date'] as String)
          : null,
      kitsBornAlive: json['kits_born_alive'] as int?,
      kitsBornDead: json['kits_born_dead'] as int?,
      adoptedKitsIn: json['adopted_kits_in'] as int?,
      kitsRemoved: json['kits_removed'] as int?,
      weaningDate: json['weaning_date'] != null
          ? DateTime.parse(json['weaning_date'] as String)
          : null,
      kitsWeaned: json['kits_weaned'] as int?,
      averageWeaningWeight:
          (json['average_weaning_weight'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'doe_id': doeId,
      'buck_id': buckId,
      'mating_date': matingDate.toIso8601String(),
      'palpation_date': palpationDate?.toIso8601String(),
      'palpation_positive': palpationPositive,
      'kindling_date': kindlingDate?.toIso8601String(),
      'kits_born_alive': kitsBornAlive,
      'kits_born_dead': kitsBornDead,
      'adopted_kits_in': adoptedKitsIn,
      'kits_removed': kitsRemoved,
      'weaning_date': weaningDate?.toIso8601String(),
      'kits_weaned': kitsWeaned,
      'average_weaning_weight': averageWeaningWeight,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        doeId,
        buckId,
        matingDate,
        palpationDate,
        palpationPositive,
        kindlingDate,
        kitsBornAlive,
        kitsBornDead,
        adoptedKitsIn,
        kitsRemoved,
        weaningDate,
        kitsWeaned,
        averageWeaningWeight,
        notes,
      ];
}
