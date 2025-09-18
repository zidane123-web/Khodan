import 'package:equatable/equatable.dart';

class BreedingPerformanceStats extends Equatable {
  const BreedingPerformanceStats({
    this.totalLitters = 0,
    this.averageKitsBornAlive,
    this.averageKitsWeaned,
    this.totalKitsWeaned = 0,
    this.topDoeLabel,
    this.topBuckLabel,
  });

  final int totalLitters;
  final double? averageKitsBornAlive;
  final double? averageKitsWeaned;
  final int totalKitsWeaned;
  final String? topDoeLabel;
  final String? topBuckLabel;

  @override
  List<Object?> get props => <Object?>[
        totalLitters,
        averageKitsBornAlive,
        averageKitsWeaned,
        totalKitsWeaned,
        topDoeLabel,
        topBuckLabel,
      ];
}
