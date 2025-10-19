import 'package:equatable/equatable.dart';

class DashboardKpiRow extends Equatable {
  const DashboardKpiRow({
    required this.profileId,
    required this.speciesId,
    required this.speciesName,
    required this.periodStart,
    required this.periodEnd,
    required this.totalLitters,
    this.averageKitsBornAlive,
    this.averageKitsWeaned,
    required this.totalKitsWeaned,
    this.topDoeLabel,
    this.topBuckLabel,
  });

  final String profileId;
  final int speciesId;
  final String? speciesName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalLitters;
  final double? averageKitsBornAlive;
  final double? averageKitsWeaned;
  final int totalKitsWeaned;
  final String? topDoeLabel;
  final String? topBuckLabel;

  factory DashboardKpiRow.fromJson(Map<String, dynamic> json) {
    return DashboardKpiRow(
      profileId: json['profile_id'] as String,
      speciesId: (json['species_id'] as num).toInt(),
      speciesName: json['species_name'] as String?,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      totalLitters: (json['total_litters'] as num).toInt(),
      averageKitsBornAlive: (json['average_kits_born_alive'] as num?)
          ?.toDouble(),
      averageKitsWeaned:
          (json['average_kits_weaned'] as num?)?.toDouble(),
      totalKitsWeaned: (json['total_kits_weaned'] as num).toInt(),
      topDoeLabel: json['top_doe_label'] as String?,
      topBuckLabel: json['top_buck_label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'profile_id': profileId,
      'species_id': speciesId,
      'species_name': speciesName,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'total_litters': totalLitters,
      'average_kits_born_alive': averageKitsBornAlive,
      'average_kits_weaned': averageKitsWeaned,
      'total_kits_weaned': totalKitsWeaned,
      'top_doe_label': topDoeLabel,
      'top_buck_label': topBuckLabel,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        profileId,
        speciesId,
        speciesName,
        periodStart,
        periodEnd,
        totalLitters,
        averageKitsBornAlive,
        averageKitsWeaned,
        totalKitsWeaned,
        topDoeLabel,
        topBuckLabel,
      ];
}
