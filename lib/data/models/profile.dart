import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.email,
    required this.farmName,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String farmName;
  final DateTime createdAt;

  Profile copyWith({
    String? id,
    String? email,
    String? farmName,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      farmName: farmName ?? this.farmName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      farmName: json['farm_name'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'farm_name': farmName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object> get props => <Object>[id, email, farmName, createdAt];
}
