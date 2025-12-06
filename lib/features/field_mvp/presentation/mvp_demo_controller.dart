import 'dart:collection';

import 'package:flutter/material.dart';

import '../../../app/core/constants.dart';

class MvpDemoScope extends InheritedNotifier<MvpDemoController> {
  const MvpDemoScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static MvpDemoController of(BuildContext context) {
    final MvpDemoScope? scope =
        context.dependOnInheritedWidgetOfExactType<MvpDemoScope>();
    assert(scope != null, 'MvpDemoScope.of() called with no scope in context.');
    return scope!.notifier!;
  }
}

enum RabbitCategory { breeder, growOut }

enum TaskUrgency { urgent, today, tomorrow, reminder }

class MvpDemoController extends ChangeNotifier {
  MvpDemoController() {
    _seedData();
  }

  final List<MvpRabbit> _rabbits = <MvpRabbit>[];
  final List<MvpTask> _tasks = <MvpTask>[];
  final List<MvpTransaction> _transactions = <MvpTransaction>[];
  final List<MvpBreedingCycle> _breedingCycles = <MvpBreedingCycle>[];
  final List<MvpLitter> _litters = <MvpLitter>[];

  UnmodifiableListView<MvpRabbit> get rabbits =>
      UnmodifiableListView<MvpRabbit>(_rabbits);
  UnmodifiableListView<MvpTask> get tasks =>
      UnmodifiableListView<MvpTask>(_tasks);
  UnmodifiableListView<MvpTransaction> get transactions =>
      UnmodifiableListView<MvpTransaction>(_transactions);
  UnmodifiableListView<MvpBreedingCycle> get breedingCycles =>
      UnmodifiableListView<MvpBreedingCycle>(_breedingCycles);
  UnmodifiableListView<MvpLitter> get litters =>
      UnmodifiableListView<MvpLitter>(_litters);

  int get totalRabbits => _rabbits.length;
  int get growOutCount =>
      _rabbits.where((MvpRabbit rabbit) => rabbit.category == RabbitCategory.growOut).length;
  int get breederCount =>
      _rabbits.where((MvpRabbit rabbit) => rabbit.category == RabbitCategory.breeder).length;
  int get maleBreeders => _rabbits
      .where((MvpRabbit rabbit) =>
          rabbit.category == RabbitCategory.breeder && rabbit.isMale)
      .length;
  int get femaleBreeders => _rabbits
      .where((MvpRabbit rabbit) =>
          rabbit.category == RabbitCategory.breeder && rabbit.isFemale)
      .length;

  double get monthlyProfit {
    final DateTime now = DateTime.now();
    double income = 0;
    double expenses = 0;
    for (final MvpTransaction tx in _transactions) {
      final bool sameMonth = tx.date.month == now.month && tx.date.year == now.year;
      if (!sameMonth) {
        continue;
      }
      if (tx.isExpense) {
        expenses += tx.amount;
      } else {
        income += tx.amount;
      }
    }
    return income - expenses;
  }

  void addRabbit({
    required String name,
    required String id,
    required String sex,
    required String breed,
    required String cage,
    required RabbitCategory category,
  }) {
    _rabbits.add(
      MvpRabbit(
        id: id,
        name: name,
        breed: breed,
        cage: cage,
        sex: sex,
        category: category,
        birthDate: DateTime.now(),
        weight: 2.5,
      ),
    );
    notifyListeners();
  }

  void addBreedingCycle({
    required String buckName,
    required String doeName,
    required DateTime date,
    required String cage,
  }) {
    final DateTime dueDate =
        date.add(Duration(days: AppConstants.defaultRabbitGestationDays));
    final DateTime palpationDate = date.add(const Duration(days: 14));
    final DateTime nestDate = date.add(const Duration(days: 27));
    _breedingCycles.add(
      MvpBreedingCycle(
        id: 'BC-${DateTime.now().millisecondsSinceEpoch}',
        buckName: buckName,
        doeName: doeName,
        cage: cage,
        matingDate: date,
        palpationDate: palpationDate,
        nestDate: nestDate,
        stage: _cycleStage(
          now: DateTime.now(),
          palpationDate: palpationDate,
          nestDate: nestDate,
          dueDate: dueDate,
        ),
        progress: _cycleProgress(
          start: date,
          end: dueDate,
        ),
      ),
    );
    notifyListeners();
  }

  void addTransaction({
    required String label,
    required double amount,
    required bool isExpense,
    required String type,
  }) {
    _transactions.insert(
      0,
      MvpTransaction(
        label: label,
        type: type,
        amount: amount,
        isExpense: isExpense,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void recordKindling({
    required String cycleId,
    required int totalBorn,
    required int deadBorn,
  }) {
    final int index =
        _breedingCycles.indexWhere((MvpBreedingCycle cycle) => cycle.id == cycleId);
    if (index == -1) {
      return;
    }
    final MvpBreedingCycle cycle = _breedingCycles.removeAt(index);
    final int survivors = (totalBorn - deadBorn).clamp(0, totalBorn);
    _litters.insert(
      0,
      MvpLitter(
        mother: cycle.doeName,
        babies: survivors,
        mortality: deadBorn.clamp(0, totalBorn),
        birthDate: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  String _cycleStage({
    required DateTime now,
    required DateTime palpationDate,
    required DateTime nestDate,
    required DateTime dueDate,
  }) {
    if (now.isBefore(palpationDate)) {
      return 'En attente palpation';
    }
    if (now.isBefore(nestDate)) {
      return 'Gestation';
    }
    if (now.isBefore(dueDate)) {
      return 'Préparation mise bas';
    }
    return 'Mise bas';
  }

  double _cycleProgress({
    required DateTime start,
    required DateTime end,
  }) {
    final int totalSeconds = end.difference(start).inSeconds;
    if (totalSeconds <= 0) {
      return 1;
    }
    final int elapsedSeconds = DateTime.now().difference(start).inSeconds;
    return (elapsedSeconds / totalSeconds).clamp(0, 1).toDouble();
  }

  void _seedData() {
    final DateTime now = DateTime.now();

    _rabbits.addAll(<MvpRabbit>[
      MvpRabbit(
        id: 'RB-001',
        name: 'Saphir',
        breed: 'Californien',
        cage: 'C1',
        sex: 'Femelle',
        category: RabbitCategory.breeder,
        birthDate: now.subtract(const Duration(days: 320)),
        weight: 3.6,
        mother: 'Perle',
        father: 'Onyx',
        reproductionHistory: <String>['Saillie 10/03', 'Mise bas 08/04 (7)'],
        health: <String>['Vaccin VHD2 (2024)'],
        notes: <String>['Très maternelle'],
      ),
      MvpRabbit(
        id: 'RB-002',
        name: 'Onyx',
        breed: 'Géant des Flandres',
        cage: 'B2',
        sex: 'Mâle',
        category: RabbitCategory.breeder,
        birthDate: now.subtract(const Duration(days: 410)),
        weight: 4.2,
        notes: <String>['Bon reproducteur'],
      ),
      MvpRabbit(
        id: 'RB-003',
        name: 'Nova',
        breed: 'Néo-Zélandais',
        cage: 'E4',
        sex: 'Femelle',
        category: RabbitCategory.growOut,
        birthDate: now.subtract(const Duration(days: 120)),
        weight: 2.4,
      ),
      MvpRabbit(
        id: 'RB-004',
        name: 'Quartz',
        breed: 'Gris du Bouscat',
        cage: 'F1',
        sex: 'Mâle',
        category: RabbitCategory.growOut,
        birthDate: now.subtract(const Duration(days: 90)),
        weight: 2.2,
        isSold: true,
      ),
      MvpRabbit(
        id: 'RB-005',
        name: 'Opale',
        breed: 'Chinchilla',
        cage: 'G3',
        sex: 'Femelle',
        category: RabbitCategory.breeder,
        birthDate: now.subtract(const Duration(days: 500)),
        weight: 3.9,
        isDead: true,
        notes: <String>['Décédée en avril'],
      ),
    ]);

    _tasks.addAll(<MvpTask>[
      MvpTask(
        title: 'Prévoir foin',
        detail: 'Stock bas pour cages D et E',
        urgency: TaskUrgency.urgent,
      ),
      MvpTask(
        title: 'Nettoyer les cages',
        detail: 'Bloc C',
        urgency: TaskUrgency.today,
      ),
      MvpTask(
        title: 'Palper Nova',
        detail: 'J+14 après saillie',
        urgency: TaskUrgency.tomorrow,
      ),
      MvpTask(
        title: 'Rappel vaccin VHD',
        detail: 'Onyx et Saphir',
        urgency: TaskUrgency.reminder,
      ),
    ]);

    _transactions.addAll(<MvpTransaction>[
      MvpTransaction(
        label: 'Vente lapin engraissement',
        type: 'Vente',
        amount: 18000,
        isExpense: false,
        date: now.subtract(const Duration(days: 2)),
      ),
      MvpTransaction(
        label: 'Granulés',
        type: 'Alimentation',
        amount: 8000,
        isExpense: true,
        date: now.subtract(const Duration(days: 3)),
      ),
      MvpTransaction(
        label: 'Vente reproducteur',
        type: 'Vente',
        amount: 25000,
        isExpense: false,
        date: now.subtract(const Duration(days: 15)),
      ),
      MvpTransaction(
        label: 'Vaccins',
        type: 'Santé',
        amount: 6000,
        isExpense: true,
        date: now.subtract(const Duration(days: 20)),
      ),
    ]);

    final DateTime firstMating = now.subtract(const Duration(days: 10));
    final DateTime secondMating = now.subtract(const Duration(days: 25));
    _breedingCycles.addAll(<MvpBreedingCycle>[
      _buildCycle(
        id: 'BC-1',
        buck: 'Onyx',
        doe: 'Saphir',
        matingDate: firstMating,
        cage: 'C1',
      ),
      _buildCycle(
        id: 'BC-2',
        buck: 'Onyx',
        doe: 'Nova',
        matingDate: secondMating,
        cage: 'E4',
      ),
    ]);

    _litters.addAll(<MvpLitter>[
      MvpLitter(
        mother: 'Saphir',
        babies: 7,
        mortality: 1,
        birthDate: now.subtract(const Duration(days: 10)),
      ),
      MvpLitter(
        mother: 'Opale',
        babies: 6,
        mortality: 0,
        birthDate: now.subtract(const Duration(days: 24)),
      ),
    ]);
  }

  MvpBreedingCycle _buildCycle({
    required String id,
    required String buck,
    required String doe,
    required DateTime matingDate,
    required String cage,
  }) {
    final DateTime dueDate =
        matingDate.add(Duration(days: AppConstants.defaultRabbitGestationDays));
    final DateTime palpationDate = matingDate.add(const Duration(days: 14));
    final DateTime nestDate = matingDate.add(const Duration(days: 27));
    return MvpBreedingCycle(
      id: id,
      buckName: buck,
      doeName: doe,
      cage: cage,
      matingDate: matingDate,
      palpationDate: palpationDate,
      nestDate: nestDate,
      stage: _cycleStage(
        now: DateTime.now(),
        palpationDate: palpationDate,
        nestDate: nestDate,
        dueDate: dueDate,
      ),
      progress: _cycleProgress(start: matingDate, end: dueDate),
    );
  }
}

class MvpRabbit {
  MvpRabbit({
    required this.id,
    required this.name,
    required this.breed,
    required this.cage,
    required this.sex,
    required this.category,
    required this.birthDate,
    required this.weight,
    this.mother,
    this.father,
    this.isSold = false,
    this.isDead = false,
    List<String>? reproductionHistory,
    List<String>? health,
    List<String>? notes,
  })  : reproductionHistory = reproductionHistory ?? <String>[],
        health = health ?? <String>[],
        notes = notes ?? <String>[];

  final String id;
  final String name;
  final String breed;
  final String cage;
  final String sex;
  final RabbitCategory category;
  final DateTime birthDate;
  final double weight;
  final String? mother;
  final String? father;
  final bool isSold;
  final bool isDead;
  final List<String> reproductionHistory;
  final List<String> health;
  final List<String> notes;

  String get status {
    if (isDead) {
      return 'Mort';
    }
    if (isSold) {
      return 'Vendu';
    }
    return category == RabbitCategory.breeder ? 'Reproducteur' : 'Engraissement';
  }

  bool get isMale => sex.toLowerCase().startsWith('m');
  bool get isFemale => sex.toLowerCase().startsWith('f');

  Color statusColor(ThemeData theme) {
    if (isDead) {
      return theme.colorScheme.error;
    }
    if (isSold) {
      return theme.colorScheme.outline;
    }
    return category == RabbitCategory.breeder
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;
  }
}

class MvpBreedingCycle {
  MvpBreedingCycle({
    required this.id,
    required this.buckName,
    required this.doeName,
    required this.cage,
    required this.matingDate,
    required this.palpationDate,
    required this.nestDate,
    required this.stage,
    required this.progress,
  });

  final String id;
  final String buckName;
  final String doeName;
  final String cage;
  final DateTime matingDate;
  final DateTime palpationDate;
  final DateTime nestDate;
  final String stage;
  final double progress;

  String get pairings => '$buckName / $doeName';
  String get pairingLabel => '$buckName × $doeName';
}

class MvpLitter {
  MvpLitter({
    required this.mother,
    required this.babies,
    required this.mortality,
    required this.birthDate,
  });

  final String mother;
  final int babies;
  final int mortality;
  final DateTime birthDate;

  Duration get untilWeaning => birthDate
      .add(Duration(days: AppConstants.defaultRabbitWeaningDays))
      .difference(DateTime.now());
}

class MvpTransaction {
  MvpTransaction({
    required this.label,
    required this.type,
    required this.amount,
    required this.isExpense,
    required this.date,
  });

  final String label;
  final String type;
  final double amount;
  final bool isExpense;
  final DateTime date;
}

class MvpTask {
  const MvpTask({
    required this.title,
    required this.detail,
    required this.urgency,
  });

  final String title;
  final String detail;
  final TaskUrgency urgency;
}
