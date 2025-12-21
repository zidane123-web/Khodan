import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Sexe de l'animal avec conversion robuste depuis différents formats
enum AnimalSex {
  male,
  female;

  String get label {
    switch (this) {
      case AnimalSex.male:
        return 'Mâle';
      case AnimalSex.female:
        return 'Femelle';
    }
  }

  String get shortLabel {
    switch (this) {
      case AnimalSex.male:
        return 'M';
      case AnimalSex.female:
        return 'F';
    }
  }

  /// Convertit une chaîne en AnimalSex avec fallback intelligent
  static AnimalSex fromString(String? value) {
    if (value == null || value.isEmpty) return AnimalSex.male;
    final String lower = value.toLowerCase().trim();
    
    // Correspondances exactes
    if (lower == 'male' || lower == 'mâle' || lower == 'm') {
      return AnimalSex.male;
    }
    if (lower == 'female' || lower == 'femelle' || lower == 'f') {
      return AnimalSex.female;
    }
    
    // Correspondances partielles (rétrocompatibilité)
    if (lower.contains('fem') || lower.startsWith('f')) {
      return AnimalSex.female;
    }
    if (lower.contains('mâ') || lower.contains('mal') || lower.startsWith('m')) {
      return AnimalSex.male;
    }
    
    return AnimalSex.male; // Défaut
  }
}

/// Liste des races courantes de lapins
class RabbitBreeds {
  const RabbitBreeds._();

  static const List<String> common = <String>[
    'Bélier Français',
    'Blanc de Hotot',
    'Californien',
    'Fauve de Bourgogne',
    'Géant des Flandres',
    'Géant Papillon Français',
    'Néo-Zélandais',
    'Rex',
    'Argenté de Champagne',
    'Chinchilla',
    'Angora',
    'Hollandais',
    'Bélier Nain',
    'Nain de couleur',
    'Autre',
  ];
}

/// Statut reproducteur calculé dynamiquement
enum ReproductiveStatus {
  notApplicable,
  available,
  gestating,
  nursing,
  resting,
  retired;

  String get label {
    switch (this) {
      case ReproductiveStatus.notApplicable:
        return 'N/A';
      case ReproductiveStatus.available:
        return 'Disponible';
      case ReproductiveStatus.gestating:
        return 'Gestante';
      case ReproductiveStatus.nursing:
        return 'Allaitante';
      case ReproductiveStatus.resting:
        return 'Repos';
      case ReproductiveStatus.retired:
        return 'Réformée';
    }
  }

  Color get color {
    switch (this) {
      case ReproductiveStatus.notApplicable:
        return const Color(0xFF667085);
      case ReproductiveStatus.available:
        return const Color(0xFF2E8B57);
      case ReproductiveStatus.gestating:
        return const Color(0xFFE04F5F);
      case ReproductiveStatus.nursing:
        return const Color(0xFF2D7CBF);
      case ReproductiveStatus.resting:
        return const Color(0xFFFF7A2E);
      case ReproductiveStatus.retired:
        return const Color(0xFF98A2B3);
    }
  }
}

class Animal extends Equatable {
  const Animal({
    required this.id,
    required this.profileId,
    required this.speciesId,
    required this.tagId,
    required this.birthDate,
    required this.sexEnum,
    required this.status,
    this.name,
    this.imageUrl,
    this.sireId,
    this.damId,
    this.cageNumber,
    this.origin,
    this.entryDate,
    this.firstBreedingDate,
    this.race,
    this.color,
    this.currentWeight,
    this.lastWeightDate,
  });

  final String id;
  final String profileId;
  final int speciesId;
  final String tagId;
  final String? name;
  final DateTime birthDate;
  final AnimalSex sexEnum;
  final String status;
  final String? imageUrl;
  final String? sireId;
  final String? damId;
  final String? cageNumber;
  final String? origin;
  final DateTime? entryDate;
  final DateTime? firstBreedingDate;
  final String? race;
  final String? color;
  final double? currentWeight;
  final DateTime? lastWeightDate;

  /// Getter de compatibilité pour l'ancien code utilisant sex comme String
  String get sex => sexEnum.label;

  /// Vérifie si l'animal est un mâle
  bool get isMale => sexEnum == AnimalSex.male;

  /// Vérifie si l'animal est une femelle
  bool get isFemale => sexEnum == AnimalSex.female;

  /// Âge en jours depuis la naissance
  int get ageInDays => DateTime.now().difference(birthDate).inDays;

  /// Âge formaté (ex: "1 an 3 mois")
  String get formattedAge {
    final int days = ageInDays;
    if (days < 30) {
      return days <= 1 ? '$days jour' : '$days jours';
    }
    final int months = days ~/ 30;
    if (months < 12) {
      return months <= 1 ? '1 mois' : '$months mois';
    }
    final int years = months ~/ 12;
    final int remainingMonths = months % 12;
    if (remainingMonths == 0) {
      return years <= 1 ? '1 an' : '$years ans';
    }
    final String yearsPart = years <= 1 ? '1 an' : '$years ans';
    final String monthsPart = remainingMonths <= 1 ? '1 mois' : '$remainingMonths mois';
    return '$yearsPart $monthsPart';
  }

  /// Nom d'affichage complet (tagId + nom si présent)
  String get displayName {
    if (name == null || name!.trim().isEmpty) {
      return tagId;
    }
    return '$tagId · $name';
  }

  Animal copyWith({
    String? id,
    String? profileId,
    int? speciesId,
    String? tagId,
    String? name,
    DateTime? birthDate,
    AnimalSex? sexEnum,
    String? status,
    String? imageUrl,
    String? sireId,
    String? damId,
    String? cageNumber,
    String? origin,
    DateTime? entryDate,
    DateTime? firstBreedingDate,
    String? race,
    String? color,
    double? currentWeight,
    DateTime? lastWeightDate,
  }) {
    return Animal(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      speciesId: speciesId ?? this.speciesId,
      tagId: tagId ?? this.tagId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      sexEnum: sexEnum ?? this.sexEnum,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      sireId: sireId ?? this.sireId,
      damId: damId ?? this.damId,
      cageNumber: cageNumber ?? this.cageNumber,
      origin: origin ?? this.origin,
      entryDate: entryDate ?? this.entryDate,
      firstBreedingDate: firstBreedingDate ?? this.firstBreedingDate,
      race: race ?? this.race,
      color: color ?? this.color,
      currentWeight: currentWeight ?? this.currentWeight,
      lastWeightDate: lastWeightDate ?? this.lastWeightDate,
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
      sexEnum: AnimalSex.fromString(json['sex'] as String?),
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
      sireId: json['sire_id'] as String?,
      damId: json['dam_id'] as String?,
      cageNumber: json['cage_number'] as String?,
      origin: json['origin'] as String?,
      entryDate: json['entry_date'] != null
          ? DateTime.parse(json['entry_date'] as String)
          : null,
      firstBreedingDate: json['first_breeding_date'] != null
          ? DateTime.parse(json['first_breeding_date'] as String)
          : null,
      race: json['race'] as String?,
      color: json['color'] as String?,
      currentWeight: (json['current_weight'] as num?)?.toDouble(),
      lastWeightDate: json['last_weight_date'] != null
          ? DateTime.parse(json['last_weight_date'] as String)
          : null,
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
      'sex': sex, // Garde la compatibilité avec la DB (string)
      'status': status,
      'image_url': imageUrl,
      'sire_id': sireId,
      'dam_id': damId,
      'cage_number': cageNumber,
      'origin': origin,
      'entry_date': entryDate?.toIso8601String(),
      'first_breeding_date': firstBreedingDate?.toIso8601String(),
      'race': race,
      'color': color,
      'current_weight': currentWeight,
      'last_weight_date': lastWeightDate?.toIso8601String(),
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
        sexEnum,
        status,
        imageUrl,
        sireId,
        damId,
        cageNumber,
        origin,
        entryDate,
        firstBreedingDate,
        race,
        color,
        currentWeight,
        lastWeightDate,
      ];
}
