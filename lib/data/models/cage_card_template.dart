import 'package:equatable/equatable.dart';

enum CageCardFormat { a4, a5, label }

extension CageCardFormatX on CageCardFormat {
  String get label {
    switch (this) {
      case CageCardFormat.a4:
        return 'A4 (4 cartes)';
      case CageCardFormat.a5:
        return 'A5 (2 cartes)';
      case CageCardFormat.label:
        return 'Étiquette 95×57 mm';
    }
  }

  String get storageValue {
    switch (this) {
      case CageCardFormat.a4:
        return 'A4';
      case CageCardFormat.a5:
        return 'A5';
      case CageCardFormat.label:
        return 'LABEL';
    }
  }

  static CageCardFormat fromStorage(String value) {
    switch (value.toUpperCase()) {
      case 'A5':
        return CageCardFormat.a5;
      case 'LABEL':
      case 'ETIQUETTE':
        return CageCardFormat.label;
      case 'A4':
      default:
        return CageCardFormat.a4;
    }
  }
}

enum CageCardField {
  identity,
  breedingDates,
  cage,
  weight,
  litterStats,
  notes,
  qr,
}

extension CageCardFieldX on CageCardField {
  String get label {
    switch (this) {
      case CageCardField.identity:
        return 'Identité';
      case CageCardField.breedingDates:
        return 'Dates clefs';
      case CageCardField.cage:
        return 'Cage / Clapier';
      case CageCardField.weight:
        return 'Poids';
      case CageCardField.litterStats:
        return 'Statistiques portée';
      case CageCardField.notes:
        return 'Notes';
      case CageCardField.qr:
        return 'QR code';
    }
  }
}

class CageCardTemplate extends Equatable {
  const CageCardTemplate({
    required this.id,
    required this.label,
    required this.format,
    this.enabledFields = const <CageCardField>{
      CageCardField.identity,
      CageCardField.breedingDates,
      CageCardField.cage,
      CageCardField.weight,
      CageCardField.litterStats,
      CageCardField.notes,
      CageCardField.qr,
    },
    this.accentColor = '#2F855A',
    this.includeSensitive = false,
    this.storagePath,
  });

  final String id;
  final String label;
  final CageCardFormat format;
  final Set<CageCardField> enabledFields;
  final String accentColor;
  final bool includeSensitive;
  final String? storagePath;

  CageCardTemplate copyWith({
    String? id,
    String? label,
    CageCardFormat? format,
    Set<CageCardField>? enabledFields,
    String? accentColor,
    bool? includeSensitive,
    String? storagePath,
  }) {
    return CageCardTemplate(
      id: id ?? this.id,
      label: label ?? this.label,
      format: format ?? this.format,
      enabledFields: enabledFields ?? this.enabledFields,
      accentColor: accentColor ?? this.accentColor,
      includeSensitive: includeSensitive ?? this.includeSensitive,
      storagePath: storagePath ?? this.storagePath,
    );
  }

  factory CageCardTemplate.fromMap(Map<String, dynamic> map) {
    final Iterable<dynamic>? rawFields =
        map['enabled_fields'] as Iterable<dynamic>?;
    return CageCardTemplate(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? 'Sans titre',
      format: CageCardFormatX.fromStorage(map['format'] as String? ?? 'A4'),
      enabledFields: rawFields == null
          ? const <CageCardField>{}
          : rawFields
              .map((dynamic value) =>
                  _fieldFromStorage(value.toString().toLowerCase()))
              .toSet(),
      accentColor: map['color'] as String? ??
          map['accent_color'] as String? ??
          '#2F855A',
      includeSensitive: map['include_sensitive'] as bool? ?? false,
      storagePath: map['storage_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'format': format.storageValue,
      'enabled_fields':
          enabledFields.map((CageCardField field) => field.name).toList(),
      'accent_color': accentColor,
      'include_sensitive': includeSensitive,
      'storage_path': storagePath,
    };
  }

  static CageCardField _fieldFromStorage(String value) {
    switch (value) {
      case 'breedingdates':
      case 'dates':
        return CageCardField.breedingDates;
      case 'cage':
        return CageCardField.cage;
      case 'weight':
        return CageCardField.weight;
      case 'litterstats':
      case 'stats':
        return CageCardField.litterStats;
      case 'notes':
        return CageCardField.notes;
      case 'qr':
        return CageCardField.qr;
      case 'identity':
      default:
        return CageCardField.identity;
    }
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        label,
        format,
        enabledFields,
        accentColor,
        includeSensitive,
        storagePath,
      ];
}

enum CageCardSubjectType { breeder, litter }

class CageCardRecord extends Equatable {
  const CageCardRecord({
    required this.id,
    required this.title,
    required this.cageLabel,
    required this.subjectType,
    required this.deepLink,
    this.subtitle,
    this.birthDate,
    this.kindlingDate,
    this.breedingDate,
    this.latestWeightKg,
    this.latestWeightDate,
    this.averageKitWeightKg,
    this.kitsAlive,
    this.tags = const <String>[],
    this.alert,
    this.sensitiveNote,
    this.includeSensitive = false,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String cageLabel;
  final CageCardSubjectType subjectType;
  final Uri deepLink;
  final DateTime? birthDate;
  final DateTime? kindlingDate;
  final DateTime? breedingDate;
  final double? latestWeightKg;
  final DateTime? latestWeightDate;
  final double? averageKitWeightKg;
  final int? kitsAlive;
  final List<String> tags;
  final String? alert;
  final String? sensitiveNote;
  final bool includeSensitive;

  CageCardRecord copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? cageLabel,
    CageCardSubjectType? subjectType,
    Uri? deepLink,
    DateTime? birthDate,
    DateTime? kindlingDate,
    DateTime? breedingDate,
    double? latestWeightKg,
    DateTime? latestWeightDate,
    double? averageKitWeightKg,
    int? kitsAlive,
    List<String>? tags,
    String? alert,
    String? sensitiveNote,
    bool? includeSensitive,
  }) {
    return CageCardRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      cageLabel: cageLabel ?? this.cageLabel,
      subjectType: subjectType ?? this.subjectType,
      deepLink: deepLink ?? this.deepLink,
      birthDate: birthDate ?? this.birthDate,
      kindlingDate: kindlingDate ?? this.kindlingDate,
      breedingDate: breedingDate ?? this.breedingDate,
      latestWeightKg: latestWeightKg ?? this.latestWeightKg,
      latestWeightDate: latestWeightDate ?? this.latestWeightDate,
      averageKitWeightKg: averageKitWeightKg ?? this.averageKitWeightKg,
      kitsAlive: kitsAlive ?? this.kitsAlive,
      tags: tags ?? this.tags,
      alert: alert ?? this.alert,
      sensitiveNote: sensitiveNote ?? this.sensitiveNote,
      includeSensitive: includeSensitive ?? this.includeSensitive,
    );
  }

  bool get hasSensitiveContent =>
      includeSensitive && (sensitiveNote?.isNotEmpty ?? false);

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        subtitle,
        cageLabel,
        subjectType,
        deepLink,
        birthDate,
        kindlingDate,
        breedingDate,
        latestWeightKg,
        latestWeightDate,
        averageKitWeightKg,
        kitsAlive,
        tags,
        alert,
        sensitiveNote,
        includeSensitive,
      ];
}
