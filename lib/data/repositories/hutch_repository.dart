import 'dart:async';

import 'package:uuid/uuid.dart';

import '../models/hutch.dart';

abstract class HutchRepository {
  Future<List<Hutch>> fetchHutches();

  Stream<List<Hutch>> watchHutches();

  Future<Hutch> saveHutch(HutchDraft draft);

  Future<void> assignLitter({
    required String hutchId,
    required HutchOccupant occupant,
  });

  Future<void> recordMaintenance({
    required String hutchId,
    required DateTime cleaningDate,
    String? notes,
  });
}

class InMemoryHutchRepository implements HutchRepository {
  factory InMemoryHutchRepository() {
    _ensureInitialized();
    return _instance;
  }

  InMemoryHutchRepository._internal();

  static final InMemoryHutchRepository _instance =
      InMemoryHutchRepository._internal();

  static final Uuid _uuid = const Uuid();
  static final List<Hutch> _hutches = <Hutch>[];
  static final StreamController<List<Hutch>> _controller =
      StreamController<List<Hutch>>.broadcast();
  static bool _initialized = false;

  static void reset() {
    _hutches
      ..clear()
      ..addAll(_seedHutches());
    if (!_controller.isClosed) {
      _controller.add(List<Hutch>.unmodifiable(_hutches));
    }
  }

  static void _ensureInitialized() {
    if (_initialized) {
      return;
    }
    _hutches.addAll(_seedHutches());
    if (!_controller.isClosed) {
      _controller.add(List<Hutch>.unmodifiable(_hutches));
    }
    _initialized = true;
  }

  static List<Hutch> _seedHutches() {
    final DateTime now = DateTime.now();
    return <Hutch>[
      Hutch(
        id: 'hutch-001',
        label: 'C-205',
        status: HutchStatus.occupied,
        capacity: 10,
        zone: 'Bloc A',
        lastCleaning: now.subtract(const Duration(days: 3)),
        occupants: const <HutchOccupant>[
          HutchOccupant(litterId: 'litter-001', litterCode: 'P-2025-18', kitCount: 7),
        ],
      ),
      Hutch(
        id: 'hutch-002',
        label: 'C-210',
        status: HutchStatus.occupied,
        capacity: 8,
        zone: 'Bloc B',
        lastCleaning: now.subtract(const Duration(days: 8)),
        occupants: const <HutchOccupant>[
          HutchOccupant(litterId: 'litter-002', litterCode: 'P-2025-17', kitCount: 6),
        ],
        hasPendingSync: true,
      ),
      Hutch(
        id: 'hutch-003',
        label: 'Ext-01',
        status: HutchStatus.available,
        capacity: 12,
        zone: 'Enclos plein air',
        lastCleaning: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<List<Hutch>> fetchHutches() async {
    return List<Hutch>.unmodifiable(_hutches);
  }

  @override
  Stream<List<Hutch>> watchHutches() async* {
    yield List<Hutch>.unmodifiable(_hutches);
    yield* _controller.stream;
  }

  @override
  Future<Hutch> saveHutch(HutchDraft draft) async {
    final Hutch hutch = Hutch(
      id: _uuid.v4(),
      label: draft.label,
      status: HutchStatus.available,
      capacity: draft.capacity,
      zone: draft.zone,
      notes: draft.notes,
      lastCleaning: DateTime.now(),
      hasPendingSync: true,
    );
    _hutches.add(hutch);
    _emit();
    return hutch;
  }

  @override
  Future<void> assignLitter({
    required String hutchId,
    required HutchOccupant occupant,
  }) async {
    final int index =
        _hutches.indexWhere((Hutch element) => element.id == hutchId);
    if (index == -1) {
      return;
    }
    final Hutch hutch = _hutches[index];
    final List<HutchOccupant> updated = <HutchOccupant>[
      ...hutch.occupants.where(
        (HutchOccupant item) => item.litterId != occupant.litterId,
      ),
      occupant,
    ];
    _hutches[index] = hutch.copyWith(
      occupants: updated,
      status: HutchStatus.occupied,
      hasPendingSync: true,
    );
    _emit();
  }

  @override
  Future<void> recordMaintenance({
    required String hutchId,
    required DateTime cleaningDate,
    String? notes,
  }) async {
    final int index =
        _hutches.indexWhere((Hutch element) => element.id == hutchId);
    if (index == -1) {
      return;
    }
    final Hutch current = _hutches[index];
    _hutches[index] = current.copyWith(
      lastCleaning: cleaningDate,
      notes: notes ?? current.notes,
      hasPendingSync: true,
    );
    _emit();
  }

  void _emit() {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(List<Hutch>.unmodifiable(_hutches));
  }
}
