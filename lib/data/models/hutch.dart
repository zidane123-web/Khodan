import 'package:equatable/equatable.dart';

enum HutchStatus {
  available,
  occupied,
  maintenance,
}

extension HutchStatusX on HutchStatus {
  String get label {
    switch (this) {
      case HutchStatus.available:
        return 'Disponible';
      case HutchStatus.occupied:
        return 'Occupe';
      case HutchStatus.maintenance:
        return 'Maintenance';
    }
  }
}

class HutchOccupant extends Equatable {
  const HutchOccupant({
    required this.litterId,
    required this.litterCode,
    this.kitCount = 0,
  });

  final String litterId;
  final String litterCode;
  final int kitCount;

  @override
  List<Object?> get props => <Object?>[litterId, litterCode, kitCount];
}

class Hutch extends Equatable {
  const Hutch({
    required this.id,
    required this.label,
    required this.status,
    required this.capacity,
    required this.lastCleaning,
    this.zone,
    this.notes,
    this.occupants = const <HutchOccupant>[],
    this.hasPendingSync = false,
  });

  final String id;
  final String label;
  final HutchStatus status;
  final int capacity;
  final DateTime lastCleaning;
  final String? zone;
  final String? notes;
  final List<HutchOccupant> occupants;
  final bool hasPendingSync;

  Hutch copyWith({
    String? id,
    String? label,
    HutchStatus? status,
    int? capacity,
    DateTime? lastCleaning,
    String? zone,
    String? notes,
    List<HutchOccupant>? occupants,
    bool? hasPendingSync,
  }) {
    return Hutch(
      id: id ?? this.id,
      label: label ?? this.label,
      status: status ?? this.status,
      capacity: capacity ?? this.capacity,
      lastCleaning: lastCleaning ?? this.lastCleaning,
      zone: zone ?? this.zone,
      notes: notes ?? this.notes,
      occupants: occupants ?? this.occupants,
      hasPendingSync: hasPendingSync ?? this.hasPendingSync,
    );
  }

  bool get isOverCapacity {
    final int totalKits = occupants.fold(
      0,
      (int acc, HutchOccupant occupant) => acc + occupant.kitCount,
    );
    return totalKits > capacity;
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        label,
        status,
        capacity,
        lastCleaning,
        zone,
        notes,
        occupants,
        hasPendingSync,
      ];
}

class HutchDraft {
  const HutchDraft({
    required this.label,
    required this.capacity,
    this.zone,
    this.notes,
  });

  final String label;
  final int capacity;
  final String? zone;
  final String? notes;
}
