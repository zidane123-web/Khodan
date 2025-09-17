import 'package:equatable/equatable.dart';

class Animal extends Equatable {
  const Animal({
    required this.id,
    required this.profileId,
    required this.speciesId,
    required this.tagId,
    required this.birthDate,
    required this.sex,
    required this.status,
    this.name,
    this.imageUrl,
    this.sireId,
    this.damId,
  });

  final String id;
  final String profileId;
  final int speciesId;
  final String tagId;
  final String? name;
  final DateTime birthDate;
  final String sex;
  final String status;
  final String? imageUrl;
  final String? sireId;
  final String? damId;

  int get ageInDays => DateTime.now().difference(birthDate).inDays;

  Animal copyWith({
    String? id,
    String? profileId,
    int? speciesId,
    String? tagId,
    String? name,
    DateTime? birthDate,
    String? sex,
    String? status,
    String? imageUrl,
    String? sireId,
    String? damId,
  }) {
    return Animal(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      speciesId: speciesId ?? this.speciesId,
      tagId: tagId ?? this.tagId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      sireId: sireId ?? this.sireId,
      damId: damId ?? this.damId,
    );
  }

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      speciesId: json['species_id'] as int,
      tagId: json['tag_id'] as String,
      name: json['name'] as String?,
      birthDate: DateTime.parse(json['birth_date'] as String),
      sex: json['sex'] as String,
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
      sireId: json['sire_id'] as String?,
      damId: json['dam_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'species_id': speciesId,
      'tag_id': tagId,
      'name': name,
      'birth_date': birthDate.toIso8601String(),
      'sex': sex,
      'status': status,
      'image_url': imageUrl,
      'sire_id': sireId,
      'dam_id': damId,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        speciesId,
        tagId,
        name,
        birthDate,
        sex,
        status,
        imageUrl,
        sireId,
        damId,
      ];
}
