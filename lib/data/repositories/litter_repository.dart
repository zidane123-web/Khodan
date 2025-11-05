import 'dart:async';

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
