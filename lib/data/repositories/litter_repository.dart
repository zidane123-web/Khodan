import 'dart:async';

import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

import '../models/litter.dart';

abstract class LitterRepository {
  Future<List<Litter>> fetchLitters();

  Stream<List<Litter>> watchLitters();

  Future<Litter> createLitter(LitterDraft draft);

  Future<void> updateLittersBatch(LitterBatchUpdate update);

  Future<void> saveKitWeights({
    required String litterId,
    required List<LitterKitWeightInput> payload,
  });
}

class InMemoryLitterRepository implements LitterRepository {
  factory InMemoryLitterRepository() {
    _ensureInitialized();
    return _instance;
  }

  InMemoryLitterRepository._internal();

  static final InMemoryLitterRepository _instance =
      InMemoryLitterRepository._internal();

  static final Uuid _uuid = const Uuid();

  static final List<Litter> _litters = <Litter>[];
  static final StreamController<List<Litter>> _controller =
      StreamController<List<Litter>>.broadcast();
  static bool _initialized = false;

  static void reset() {
    _litters
      ..clear()
      ..addAll(_seedLitters());
    if (!_controller.isClosed) {
      _controller.add(List<Litter>.unmodifiable(_litters));
    }
  }

  static void _ensureInitialized() {
    if (_initialized) {
      return;
    }
    _litters.addAll(_seedLitters());
    if (!_controller.isClosed) {
      _controller.add(List<Litter>.unmodifiable(_litters));
    }
    _initialized = true;
  }

  static List<Litter> _seedLitters() {
    final DateTime now = DateTime.now();
    return <Litter>[
      Litter(
        id: 'litter-001',
        code: 'P-2025-18',
        doeTag: 'F01',
        buckTag: 'M12',
        breedingDate: now.subtract(const Duration(days: 35)),
        kindlingDate: now.subtract(const Duration(days: 5)),
        bornAlive: 8,
        bornDead: 1,
        expectedWeaned: 7,
        cage: 'C-205',
        enclosure: 'Enclos plein air 2',
        status: LitterStatus.weaning,
        notes: 'Cycle reproduction standard',
        kits: List<LitterKit>.generate(
          7,
          (int index) => LitterKit(
            id: 'kit-001-${index + 1}',
            tag: 'K1${index + 1}',
            sex: index.isEven ? 'Femelle' : 'Male',
            birthWeightGrams: 45 + index.toDouble(),
            weaningWeightGrams: index.isEven ? 720 : null,
            preSlaughterWeightGrams: null,
            carcassWeightKg: null,
            marketValue: null,
            destination: 'Garde',
          ),
        ),
        hasPendingSync: false,
      ),
      Litter(
        id: 'litter-002',
        code: 'P-2025-17',
        doeTag: 'F02',
        buckTag: 'M01',
        breedingDate: now.subtract(const Duration(days: 62)),
        kindlingDate: now.subtract(const Duration(days: 27)),
        bornAlive: 6,
        bornDead: 0,
        expectedWeaned: 6,
        cage: 'C-210',
        status: LitterStatus.harvestReady,
        kits: List<LitterKit>.generate(
          6,
          (int index) => LitterKit(
            id: 'kit-002-${index + 1}',
            tag: 'J${index + 1}',
            sex: index.isOdd ? 'Femelle' : 'Male',
            birthWeightGrams: 46 + index.toDouble(),
            weaningWeightGrams: 820 + index * 20,
            preSlaughterWeightGrams: 1850 + index * 30,
            carcassWeightKg: 1.4 + index * 0.05,
            marketValue: 8500 + index * 500,
            destination: index.isOdd ? 'Abattu' : 'Vendu',
          ),
        ),
        hasPendingSync: true,
      ),
    ];
  }

  @override
  Future<List<Litter>> fetchLitters() async {
    return List<Litter>.unmodifiable(_litters);
  }

  @override
  Stream<List<Litter>> watchLitters() async* {
    yield List<Litter>.unmodifiable(_litters);
    yield* _controller.stream;
  }

  @override
  Future<Litter> createLitter(LitterDraft draft) async {
    final Litter litter = Litter(
      id: _uuid.v4(),
      code: draft.code,
      doeTag: draft.doeTag,
      buckTag: draft.buckTag,
      breedingDate: draft.breedingDate,
      kindlingDate: draft.kindlingDate,
      bornAlive: draft.bornAlive,
      bornDead: draft.bornDead,
      expectedWeaned: draft.expectedWeaned,
      cage: draft.cage,
      enclosure: draft.enclosure,
      status: LitterStatus.gestating,
      notes: draft.notes,
      taskTemplateName: draft.taskTemplateName,
      kits: List<LitterKit>.generate(
        draft.expectedWeaned,
        (int index) => LitterKit(
          id: _uuid.v4(),
          tag: 'K${index + 1}',
          sex: index.isEven ? 'Femelle' : 'Male',
        ),
      ),
      hasPendingSync: true,
    );
    _litters.insert(0, litter);
    _emit();
    return litter;
  }

  @override
  Future<void> updateLittersBatch(LitterBatchUpdate update) async {
    for (final String id in update.litterIds) {
      final int index =
          _litters.indexWhere((Litter element) => element.id == id);
      if (index == -1) {
        continue;
      }
      final Litter current = _litters[index];
      _litters[index] = current.copyWith(
        status: update.status ?? current.status,
        cage: update.cage ?? current.cage,
        enclosure: update.enclosure ?? current.enclosure,
        notes: update.notes ?? current.notes,
        nextReminder: update.nextReminder ?? current.nextReminder,
        hasPendingSync: true,
      );
    }
    _emit();
  }

  @override
  Future<void> saveKitWeights({
    required String litterId,
    required List<LitterKitWeightInput> payload,
  }) async {
    final int index =
        _litters.indexWhere((Litter element) => element.id == litterId);
    if (index == -1) {
      return;
    }

    final Litter litter = _litters[index];
    final List<LitterKit> updatedKits = litter.kits
        .map((LitterKit kit) {
          final LitterKitWeightInput? entry = payload.firstWhereOrNull(
            (LitterKitWeightInput item) => item.kitId == kit.id,
          );
          if (entry == null) {
            return kit;
          }
          return kit.copyWith(
            weaningWeightGrams: entry.weaningWeightGrams ?? kit.weaningWeightGrams,
            preSlaughterWeightGrams:
                entry.preSlaughterWeightGrams ?? kit.preSlaughterWeightGrams,
            carcassWeightKg: entry.carcassWeightKg ?? kit.carcassWeightKg,
            marketValue: entry.marketValue ?? kit.marketValue,
            destination: entry.destination ?? kit.destination,
            hasPendingSync: true,
          );
        })
        .toList(growable: false);

    _litters[index] = litter.copyWith(
      kits: updatedKits,
      hasPendingSync: true,
    );
    _emit();
  }

  void _emit() {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(List<Litter>.unmodifiable(_litters));
  }
}
