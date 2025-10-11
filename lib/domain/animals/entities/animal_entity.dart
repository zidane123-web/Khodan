import 'package:equatable/equatable.dart';

import '../../../data/models/animal.dart';

class AnimalEntity extends Equatable {
  const AnimalEntity({
    required this.id,
    required this.farmId,
    required this.speciesId,
    required this.tagId,
    required this.sex,
    required this.status,
    required this.birthDate,
    this.profileId,
    this.name,
    this.imageUrl,
    this.sireId,
    this.damId,
    this.cageNumber,
    this.origin,
    this.entryDate,
    this.firstBreedingDate,
  });

  final String id;
  final String farmId;
  final int speciesId;
  final String tagId;
  final String sex;
  final String status;
  final DateTime birthDate;
  final String? profileId;
  final String? name;
  final String? imageUrl;
  final String? sireId;
  final String? damId;
  final String? cageNumber;
  final String? origin;
  final DateTime? entryDate;
  final DateTime? firstBreedingDate;

  AnimalEntity copyWith({
    String? id,
    String? farmId,
    int? speciesId,
    String? tagId,
    String? sex,
    String? status,
    DateTime? birthDate,
    String? profileId,
    String? name,
    String? imageUrl,
    String? sireId,
    String? damId,
    String? cageNumber,
    String? origin,
    DateTime? entryDate,
    DateTime? firstBreedingDate,
  }) {
    return AnimalEntity(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      speciesId: speciesId ?? this.speciesId,
      tagId: tagId ?? this.tagId,
      sex: sex ?? this.sex,
      status: status ?? this.status,
      birthDate: birthDate ?? this.birthDate,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      sireId: sireId ?? this.sireId,
      damId: damId ?? this.damId,
      cageNumber: cageNumber ?? this.cageNumber,
      origin: origin ?? this.origin,
      entryDate: entryDate ?? this.entryDate,
      firstBreedingDate: firstBreedingDate ?? this.firstBreedingDate,
    );
  }

  Animal toModel() {
    return Animal(
      id: id,
      profileId: profileId ?? '',
      speciesId: speciesId,
      tagId: tagId,
      name: name,
      birthDate: birthDate,
      sex: sex,
      status: status,
      imageUrl: imageUrl,
      sireId: sireId,
      damId: damId,
      cageNumber: cageNumber,
      origin: origin,
      entryDate: entryDate,
      firstBreedingDate: firstBreedingDate,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        farmId,
        speciesId,
        tagId,
        sex,
        status,
        birthDate,
        profileId,
        name,
        imageUrl,
        sireId,
        damId,
        cageNumber,
        origin,
        entryDate,
        firstBreedingDate,
      ];
}
