import 'package:equatable/equatable.dart';

class FoodType extends Equatable {
  const FoodType({
    required this.id,
    required this.profileId,
    required this.name,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  final int id;
  final String profileId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodType copyWith({
    int? id,
    String? profileId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodType(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FoodType.fromJson(Map<String, dynamic> json) {
    return FoodType(
      id: json['id'] as int,
      profileId: json['user_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(
        (json['updated_at'] as String?) ?? json['created_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': profileId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[id, profileId, name, createdAt, updatedAt];
}
