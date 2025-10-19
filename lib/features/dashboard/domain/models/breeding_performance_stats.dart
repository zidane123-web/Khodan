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

  factory BreedingPerformanceStats.fromJson(Map<String, dynamic> json) {
    return BreedingPerformanceStats(
      totalLitters: (json['total_litters'] as num?)?.toInt() ?? 0,
      averageKitsBornAlive:
          (json['average_kits_born_alive'] as num?)?.toDouble(),
      averageKitsWeaned:
          (json['average_kits_weaned'] as num?)?.toDouble(),
      totalKitsWeaned: (json['total_kits_weaned'] as num?)?.toInt() ?? 0,
      topDoeLabel: json['top_doe_label'] as String?,
      topBuckLabel: json['top_buck_label'] as String?,
    );
  }
}
