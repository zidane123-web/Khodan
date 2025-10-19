import 'package:equatable/equatable.dart';

class DashboardPreferences extends Equatable {
  const DashboardPreferences({
    required this.profileId,
    required this.kpiOrder,
    required this.moduleOrder,
    required this.hiddenModules,
    required this.updatedAt,
  });

  final String profileId;
  final List<String> kpiOrder;
  final List<String> moduleOrder;
  final Set<String> hiddenModules;
  final DateTime updatedAt;

  DashboardPreferences copyWith({
    List<String>? kpiOrder,
    List<String>? moduleOrder,
    Set<String>? hiddenModules,
    DateTime? updatedAt,
  }) {
    return DashboardPreferences(
      profileId: profileId,
      kpiOrder: kpiOrder ?? this.kpiOrder,
      moduleOrder: moduleOrder ?? this.moduleOrder,
      hiddenModules: hiddenModules ?? this.hiddenModules,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'profileId': profileId,
      'kpiOrder': kpiOrder,
      'moduleOrder': moduleOrder,
      'hiddenModules': hiddenModules.toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DashboardPreferences.fromJson(Map<String, dynamic> json) {
    final Iterable<dynamic> rawKpi = json['kpiOrder'] as Iterable<dynamic>? ??
        const <dynamic>[];
    final Iterable<dynamic> rawModules =
        json['moduleOrder'] as Iterable<dynamic>? ?? const <dynamic>[];
    final Iterable<dynamic> rawHidden =
        json['hiddenModules'] as Iterable<dynamic>? ?? const <dynamic>[];
    return DashboardPreferences(
      profileId: json['profileId'] as String,
      kpiOrder: rawKpi.map((dynamic value) => value as String).toList(),
      moduleOrder: rawModules.map((dynamic value) => value as String).toList(),
      hiddenModules: rawHidden.map((dynamic value) => value as String).toSet(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        profileId,
        kpiOrder,
        moduleOrder,
        hiddenModules,
        updatedAt,
      ];
}
