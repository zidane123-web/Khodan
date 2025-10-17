// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $ProfilesTableTable extends ProfilesTable
    with TableInfo<$ProfilesTableTable, ProfilesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [id, payload, updatedAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles_table';
  @override
  VerificationContext validateIntegrity(Insertable<ProfilesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfilesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfilesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $ProfilesTableTable createAlias(String alias) {
    return $ProfilesTableTable(attachedDatabase, alias);
  }
}

class ProfilesTableData extends DataClass
    implements Insertable<ProfilesTableData> {
  final String id;
  final String payload;
  final DateTime updatedAt;
  final String syncState;
  const ProfilesTableData(
      {required this.id,
      required this.payload,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  ProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return ProfilesTableCompanion(
      id: Value(id),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory ProfilesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfilesTableData(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  ProfilesTableData copyWith(
          {String? id,
          String? payload,
          DateTime? updatedAt,
          String? syncState}) =>
      ProfilesTableData(
        id: id ?? this.id,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  ProfilesTableData copyWithCompanion(ProfilesTableCompanion data) {
    return ProfilesTableData(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesTableData(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfilesTableData &&
          other.id == this.id &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class ProfilesTableCompanion extends UpdateCompanion<ProfilesTableData> {
  final Value<String> id;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const ProfilesTableCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesTableCompanion.insert({
    required String id,
    required String payload,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        payload = Value(payload),
        updatedAt = Value(updatedAt);
  static Insertable<ProfilesTableData> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? payload,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return ProfilesTableCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpeciesConfigsTableTable extends SpeciesConfigsTable
    with TableInfo<$SpeciesConfigsTableTable, SpeciesConfigsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesConfigsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, payload, updatedAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_configs_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<SpeciesConfigsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesConfigsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesConfigsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $SpeciesConfigsTableTable createAlias(String alias) {
    return $SpeciesConfigsTableTable(attachedDatabase, alias);
  }
}

class SpeciesConfigsTableData extends DataClass
    implements Insertable<SpeciesConfigsTableData> {
  final int id;
  final String profileId;
  final String payload;
  final DateTime updatedAt;
  final String syncState;
  const SpeciesConfigsTableData(
      {required this.id,
      required this.profileId,
      required this.payload,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  SpeciesConfigsTableCompanion toCompanion(bool nullToAbsent) {
    return SpeciesConfigsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory SpeciesConfigsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesConfigsTableData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  SpeciesConfigsTableData copyWith(
          {int? id,
          String? profileId,
          String? payload,
          DateTime? updatedAt,
          String? syncState}) =>
      SpeciesConfigsTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  SpeciesConfigsTableData copyWithCompanion(SpeciesConfigsTableCompanion data) {
    return SpeciesConfigsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesConfigsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, payload, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesConfigsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class SpeciesConfigsTableCompanion
    extends UpdateCompanion<SpeciesConfigsTableData> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  const SpeciesConfigsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
  });
  SpeciesConfigsTableCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String payload,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
  })  : profileId = Value(profileId),
        payload = Value(payload),
        updatedAt = Value(updatedAt);
  static Insertable<SpeciesConfigsTableData> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
    });
  }

  SpeciesConfigsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? profileId,
      Value<String>? payload,
      Value<DateTime>? updatedAt,
      Value<String>? syncState}) {
    return SpeciesConfigsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesConfigsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }
}

class $AnimalsTableTable extends AnimalsTable
    with TableInfo<$AnimalsTableTable, AnimalsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speciesIdMeta =
      const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
      'species_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, speciesId, payload, updatedAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animals_table';
  @override
  VerificationContext validateIntegrity(Insertable<AnimalsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(_speciesIdMeta,
          speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta));
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimalsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      speciesId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}species_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $AnimalsTableTable createAlias(String alias) {
    return $AnimalsTableTable(attachedDatabase, alias);
  }
}

class AnimalsTableData extends DataClass
    implements Insertable<AnimalsTableData> {
  final String id;
  final String profileId;
  final int speciesId;
  final String payload;
  final DateTime updatedAt;
  final String syncState;
  const AnimalsTableData(
      {required this.id,
      required this.profileId,
      required this.speciesId,
      required this.payload,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['species_id'] = Variable<int>(speciesId);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  AnimalsTableCompanion toCompanion(bool nullToAbsent) {
    return AnimalsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      speciesId: Value(speciesId),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory AnimalsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalsTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'speciesId': serializer.toJson<int>(speciesId),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  AnimalsTableData copyWith(
          {String? id,
          String? profileId,
          int? speciesId,
          String? payload,
          DateTime? updatedAt,
          String? syncState}) =>
      AnimalsTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        speciesId: speciesId ?? this.speciesId,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  AnimalsTableData copyWithCompanion(AnimalsTableCompanion data) {
    return AnimalsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('speciesId: $speciesId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, speciesId, payload, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.speciesId == this.speciesId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class AnimalsTableCompanion extends UpdateCompanion<AnimalsTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<int> speciesId;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const AnimalsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalsTableCompanion.insert({
    required String id,
    required String profileId,
    required int speciesId,
    required String payload,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        speciesId = Value(speciesId),
        payload = Value(payload),
        updatedAt = Value(updatedAt);
  static Insertable<AnimalsTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<int>? speciesId,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (speciesId != null) 'species_id': speciesId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<int>? speciesId,
      Value<String>? payload,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return AnimalsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      speciesId: speciesId ?? this.speciesId,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('speciesId: $speciesId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BreedingRecordsTableTable extends BreedingRecordsTable
    with TableInfo<$BreedingRecordsTableTable, BreedingRecordsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BreedingRecordsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _matingDateMeta =
      const VerificationMeta('matingDate');
  @override
  late final GeneratedColumn<DateTime> matingDate = GeneratedColumn<DateTime>(
      'mating_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, payload, matingDate, updatedAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'breeding_records_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<BreedingRecordsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('mating_date')) {
      context.handle(
          _matingDateMeta,
          matingDate.isAcceptableOrUnknown(
              data['mating_date']!, _matingDateMeta));
    } else if (isInserting) {
      context.missing(_matingDateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BreedingRecordsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BreedingRecordsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      matingDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}mating_date'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $BreedingRecordsTableTable createAlias(String alias) {
    return $BreedingRecordsTableTable(attachedDatabase, alias);
  }
}

class BreedingRecordsTableData extends DataClass
    implements Insertable<BreedingRecordsTableData> {
  final String id;
  final String profileId;
  final String payload;
  final DateTime matingDate;
  final DateTime updatedAt;
  final String syncState;
  const BreedingRecordsTableData(
      {required this.id,
      required this.profileId,
      required this.payload,
      required this.matingDate,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['payload'] = Variable<String>(payload);
    map['mating_date'] = Variable<DateTime>(matingDate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  BreedingRecordsTableCompanion toCompanion(bool nullToAbsent) {
    return BreedingRecordsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      payload: Value(payload),
      matingDate: Value(matingDate),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory BreedingRecordsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BreedingRecordsTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      payload: serializer.fromJson<String>(json['payload']),
      matingDate: serializer.fromJson<DateTime>(json['matingDate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'payload': serializer.toJson<String>(payload),
      'matingDate': serializer.toJson<DateTime>(matingDate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  BreedingRecordsTableData copyWith(
          {String? id,
          String? profileId,
          String? payload,
          DateTime? matingDate,
          DateTime? updatedAt,
          String? syncState}) =>
      BreedingRecordsTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        payload: payload ?? this.payload,
        matingDate: matingDate ?? this.matingDate,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  BreedingRecordsTableData copyWithCompanion(
      BreedingRecordsTableCompanion data) {
    return BreedingRecordsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      payload: data.payload.present ? data.payload.value : this.payload,
      matingDate:
          data.matingDate.present ? data.matingDate.value : this.matingDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BreedingRecordsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('matingDate: $matingDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, payload, matingDate, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BreedingRecordsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.payload == this.payload &&
          other.matingDate == this.matingDate &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class BreedingRecordsTableCompanion
    extends UpdateCompanion<BreedingRecordsTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> payload;
  final Value<DateTime> matingDate;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const BreedingRecordsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.payload = const Value.absent(),
    this.matingDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BreedingRecordsTableCompanion.insert({
    required String id,
    required String profileId,
    required String payload,
    required DateTime matingDate,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        payload = Value(payload),
        matingDate = Value(matingDate),
        updatedAt = Value(updatedAt);
  static Insertable<BreedingRecordsTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? payload,
    Expression<DateTime>? matingDate,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (payload != null) 'payload': payload,
      if (matingDate != null) 'mating_date': matingDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BreedingRecordsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<String>? payload,
      Value<DateTime>? matingDate,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return BreedingRecordsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      payload: payload ?? this.payload,
      matingDate: matingDate ?? this.matingDate,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (matingDate.present) {
      map['mating_date'] = Variable<DateTime>(matingDate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BreedingRecordsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('matingDate: $matingDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTableTable extends EventsTable
    with TableInfo<$EventsTableTable, EventsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventDateMeta =
      const VerificationMeta('eventDate');
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
      'event_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, payload, eventDate, updatedAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events_table';
  @override
  VerificationContext validateIntegrity(Insertable<EventsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(_eventDateMeta,
          eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta));
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      eventDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}event_date'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $EventsTableTable createAlias(String alias) {
    return $EventsTableTable(attachedDatabase, alias);
  }
}

class EventsTableData extends DataClass implements Insertable<EventsTableData> {
  final String id;
  final String profileId;
  final String payload;
  final DateTime eventDate;
  final DateTime updatedAt;
  final String syncState;
  const EventsTableData(
      {required this.id,
      required this.profileId,
      required this.payload,
      required this.eventDate,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['payload'] = Variable<String>(payload);
    map['event_date'] = Variable<DateTime>(eventDate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  EventsTableCompanion toCompanion(bool nullToAbsent) {
    return EventsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      payload: Value(payload),
      eventDate: Value(eventDate),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory EventsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventsTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      payload: serializer.fromJson<String>(json['payload']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'payload': serializer.toJson<String>(payload),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  EventsTableData copyWith(
          {String? id,
          String? profileId,
          String? payload,
          DateTime? eventDate,
          DateTime? updatedAt,
          String? syncState}) =>
      EventsTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        payload: payload ?? this.payload,
        eventDate: eventDate ?? this.eventDate,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  EventsTableData copyWithCompanion(EventsTableCompanion data) {
    return EventsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      payload: data.payload.present ? data.payload.value : this.payload,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('eventDate: $eventDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, payload, eventDate, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.payload == this.payload &&
          other.eventDate == this.eventDate &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class EventsTableCompanion extends UpdateCompanion<EventsTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> payload;
  final Value<DateTime> eventDate;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const EventsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.payload = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsTableCompanion.insert({
    required String id,
    required String profileId,
    required String payload,
    required DateTime eventDate,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        payload = Value(payload),
        eventDate = Value(eventDate),
        updatedAt = Value(updatedAt);
  static Insertable<EventsTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? payload,
    Expression<DateTime>? eventDate,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (payload != null) 'payload': payload,
      if (eventDate != null) 'event_date': eventDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<String>? payload,
      Value<DateTime>? eventDate,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return EventsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      payload: payload ?? this.payload,
      eventDate: eventDate ?? this.eventDate,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('eventDate: $eventDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalEventsTableTable extends AnimalEventsTable
    with TableInfo<$AnimalEventsTableTable, AnimalEventsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalEventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [eventId, animalId, role, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animal_events_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<AnimalEventsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId, animalId, role};
  @override
  AnimalEventsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalEventsTableData(
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AnimalEventsTableTable createAlias(String alias) {
    return $AnimalEventsTableTable(attachedDatabase, alias);
  }
}

class AnimalEventsTableData extends DataClass
    implements Insertable<AnimalEventsTableData> {
  final String eventId;
  final String animalId;
  final String role;
  final DateTime updatedAt;
  const AnimalEventsTableData(
      {required this.eventId,
      required this.animalId,
      required this.role,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['animal_id'] = Variable<String>(animalId);
    map['role'] = Variable<String>(role);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AnimalEventsTableCompanion toCompanion(bool nullToAbsent) {
    return AnimalEventsTableCompanion(
      eventId: Value(eventId),
      animalId: Value(animalId),
      role: Value(role),
      updatedAt: Value(updatedAt),
    );
  }

  factory AnimalEventsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalEventsTableData(
      eventId: serializer.fromJson<String>(json['eventId']),
      animalId: serializer.fromJson<String>(json['animalId']),
      role: serializer.fromJson<String>(json['role']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'animalId': serializer.toJson<String>(animalId),
      'role': serializer.toJson<String>(role),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AnimalEventsTableData copyWith(
          {String? eventId,
          String? animalId,
          String? role,
          DateTime? updatedAt}) =>
      AnimalEventsTableData(
        eventId: eventId ?? this.eventId,
        animalId: animalId ?? this.animalId,
        role: role ?? this.role,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AnimalEventsTableData copyWithCompanion(AnimalEventsTableCompanion data) {
    return AnimalEventsTableData(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      role: data.role.present ? data.role.value : this.role,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalEventsTableData(')
          ..write('eventId: $eventId, ')
          ..write('animalId: $animalId, ')
          ..write('role: $role, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, animalId, role, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalEventsTableData &&
          other.eventId == this.eventId &&
          other.animalId == this.animalId &&
          other.role == this.role &&
          other.updatedAt == this.updatedAt);
}

class AnimalEventsTableCompanion
    extends UpdateCompanion<AnimalEventsTableData> {
  final Value<String> eventId;
  final Value<String> animalId;
  final Value<String> role;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AnimalEventsTableCompanion({
    this.eventId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.role = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalEventsTableCompanion.insert({
    required String eventId,
    required String animalId,
    required String role,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : eventId = Value(eventId),
        animalId = Value(animalId),
        role = Value(role),
        updatedAt = Value(updatedAt);
  static Insertable<AnimalEventsTableData> custom({
    Expression<String>? eventId,
    Expression<String>? animalId,
    Expression<String>? role,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (animalId != null) 'animal_id': animalId,
      if (role != null) 'role': role,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalEventsTableCompanion copyWith(
      {Value<String>? eventId,
      Value<String>? animalId,
      Value<String>? role,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AnimalEventsTableCompanion(
      eventId: eventId ?? this.eventId,
      animalId: animalId ?? this.animalId,
      role: role ?? this.role,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalEventsTableCompanion(')
          ..write('eventId: $eventId, ')
          ..write('animalId: $animalId, ')
          ..write('role: $role, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $ProfilesTableTable profilesTable = $ProfilesTableTable(this);
  late final $SpeciesConfigsTableTable speciesConfigsTable =
      $SpeciesConfigsTableTable(this);
  late final $AnimalsTableTable animalsTable = $AnimalsTableTable(this);
  late final $BreedingRecordsTableTable breedingRecordsTable =
      $BreedingRecordsTableTable(this);
  late final $EventsTableTable eventsTable = $EventsTableTable(this);
  late final $AnimalEventsTableTable animalEventsTable =
      $AnimalEventsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        profilesTable,
        speciesConfigsTable,
        animalsTable,
        breedingRecordsTable,
        eventsTable,
        animalEventsTable
      ];
}

typedef $$ProfilesTableTableCreateCompanionBuilder = ProfilesTableCompanion
    Function({
  required String id,
  required String payload,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$ProfilesTableTableUpdateCompanionBuilder = ProfilesTableCompanion
    Function({
  Value<String> id,
  Value<String> payload,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$ProfilesTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $ProfilesTableTable,
    ProfilesTableData,
    $$ProfilesTableTableFilterComposer,
    $$ProfilesTableTableOrderingComposer,
    $$ProfilesTableTableCreateCompanionBuilder,
    $$ProfilesTableTableUpdateCompanionBuilder> {
  $$ProfilesTableTableTableManager(
      _$LocalDatabase db, $ProfilesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProfilesTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ProfilesTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesTableCompanion(
            id: id,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String payload,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesTableCompanion.insert(
            id: id,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$ProfilesTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ProfilesTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SpeciesConfigsTableTableCreateCompanionBuilder
    = SpeciesConfigsTableCompanion Function({
  Value<int> id,
  required String profileId,
  required String payload,
  required DateTime updatedAt,
  Value<String> syncState,
});
typedef $$SpeciesConfigsTableTableUpdateCompanionBuilder
    = SpeciesConfigsTableCompanion Function({
  Value<int> id,
  Value<String> profileId,
  Value<String> payload,
  Value<DateTime> updatedAt,
  Value<String> syncState,
});

class $$SpeciesConfigsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $SpeciesConfigsTableTable,
    SpeciesConfigsTableData,
    $$SpeciesConfigsTableTableFilterComposer,
    $$SpeciesConfigsTableTableOrderingComposer,
    $$SpeciesConfigsTableTableCreateCompanionBuilder,
    $$SpeciesConfigsTableTableUpdateCompanionBuilder> {
  $$SpeciesConfigsTableTableTableManager(
      _$LocalDatabase db, $SpeciesConfigsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$SpeciesConfigsTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$SpeciesConfigsTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
          }) =>
              SpeciesConfigsTableCompanion(
            id: id,
            profileId: profileId,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String profileId,
            required String payload,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
          }) =>
              SpeciesConfigsTableCompanion.insert(
            id: id,
            profileId: profileId,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
          ),
        ));
}

class $$SpeciesConfigsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $SpeciesConfigsTableTable> {
  $$SpeciesConfigsTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SpeciesConfigsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $SpeciesConfigsTableTable> {
  $$SpeciesConfigsTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AnimalsTableTableCreateCompanionBuilder = AnimalsTableCompanion
    Function({
  required String id,
  required String profileId,
  required int speciesId,
  required String payload,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$AnimalsTableTableUpdateCompanionBuilder = AnimalsTableCompanion
    Function({
  Value<String> id,
  Value<String> profileId,
  Value<int> speciesId,
  Value<String> payload,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$AnimalsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $AnimalsTableTable,
    AnimalsTableData,
    $$AnimalsTableTableFilterComposer,
    $$AnimalsTableTableOrderingComposer,
    $$AnimalsTableTableCreateCompanionBuilder,
    $$AnimalsTableTableUpdateCompanionBuilder> {
  $$AnimalsTableTableTableManager(_$LocalDatabase db, $AnimalsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AnimalsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AnimalsTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<int> speciesId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalsTableCompanion(
            id: id,
            profileId: profileId,
            speciesId: speciesId,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required int speciesId,
            required String payload,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalsTableCompanion.insert(
            id: id,
            profileId: profileId,
            speciesId: speciesId,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$AnimalsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $AnimalsTableTable> {
  $$AnimalsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get speciesId => $state.composableBuilder(
      column: $state.table.speciesId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AnimalsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $AnimalsTableTable> {
  $$AnimalsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get speciesId => $state.composableBuilder(
      column: $state.table.speciesId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$BreedingRecordsTableTableCreateCompanionBuilder
    = BreedingRecordsTableCompanion Function({
  required String id,
  required String profileId,
  required String payload,
  required DateTime matingDate,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$BreedingRecordsTableTableUpdateCompanionBuilder
    = BreedingRecordsTableCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> payload,
  Value<DateTime> matingDate,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$BreedingRecordsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $BreedingRecordsTableTable,
    BreedingRecordsTableData,
    $$BreedingRecordsTableTableFilterComposer,
    $$BreedingRecordsTableTableOrderingComposer,
    $$BreedingRecordsTableTableCreateCompanionBuilder,
    $$BreedingRecordsTableTableUpdateCompanionBuilder> {
  $$BreedingRecordsTableTableTableManager(
      _$LocalDatabase db, $BreedingRecordsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$BreedingRecordsTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$BreedingRecordsTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> matingDate = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BreedingRecordsTableCompanion(
            id: id,
            profileId: profileId,
            payload: payload,
            matingDate: matingDate,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required String payload,
            required DateTime matingDate,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BreedingRecordsTableCompanion.insert(
            id: id,
            profileId: profileId,
            payload: payload,
            matingDate: matingDate,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$BreedingRecordsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $BreedingRecordsTableTable> {
  $$BreedingRecordsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get matingDate => $state.composableBuilder(
      column: $state.table.matingDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$BreedingRecordsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $BreedingRecordsTableTable> {
  $$BreedingRecordsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get matingDate => $state.composableBuilder(
      column: $state.table.matingDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$EventsTableTableCreateCompanionBuilder = EventsTableCompanion
    Function({
  required String id,
  required String profileId,
  required String payload,
  required DateTime eventDate,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$EventsTableTableUpdateCompanionBuilder = EventsTableCompanion
    Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> payload,
  Value<DateTime> eventDate,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$EventsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $EventsTableTable,
    EventsTableData,
    $$EventsTableTableFilterComposer,
    $$EventsTableTableOrderingComposer,
    $$EventsTableTableCreateCompanionBuilder,
    $$EventsTableTableUpdateCompanionBuilder> {
  $$EventsTableTableTableManager(_$LocalDatabase db, $EventsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$EventsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$EventsTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> eventDate = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsTableCompanion(
            id: id,
            profileId: profileId,
            payload: payload,
            eventDate: eventDate,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required String payload,
            required DateTime eventDate,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsTableCompanion.insert(
            id: id,
            profileId: profileId,
            payload: payload,
            eventDate: eventDate,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$EventsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $EventsTableTable> {
  $$EventsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get eventDate => $state.composableBuilder(
      column: $state.table.eventDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$EventsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $EventsTableTable> {
  $$EventsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get eventDate => $state.composableBuilder(
      column: $state.table.eventDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AnimalEventsTableTableCreateCompanionBuilder
    = AnimalEventsTableCompanion Function({
  required String eventId,
  required String animalId,
  required String role,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AnimalEventsTableTableUpdateCompanionBuilder
    = AnimalEventsTableCompanion Function({
  Value<String> eventId,
  Value<String> animalId,
  Value<String> role,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AnimalEventsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $AnimalEventsTableTable,
    AnimalEventsTableData,
    $$AnimalEventsTableTableFilterComposer,
    $$AnimalEventsTableTableOrderingComposer,
    $$AnimalEventsTableTableCreateCompanionBuilder,
    $$AnimalEventsTableTableUpdateCompanionBuilder> {
  $$AnimalEventsTableTableTableManager(
      _$LocalDatabase db, $AnimalEventsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AnimalEventsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$AnimalEventsTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> eventId = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalEventsTableCompanion(
            eventId: eventId,
            animalId: animalId,
            role: role,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String eventId,
            required String animalId,
            required String role,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalEventsTableCompanion.insert(
            eventId: eventId,
            animalId: animalId,
            role: role,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$AnimalEventsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $AnimalEventsTableTable> {
  $$AnimalEventsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get animalId => $state.composableBuilder(
      column: $state.table.animalId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AnimalEventsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $AnimalEventsTableTable> {
  $$AnimalEventsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get animalId => $state.composableBuilder(
      column: $state.table.animalId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$ProfilesTableTableTableManager get profilesTable =>
      $$ProfilesTableTableTableManager(_db, _db.profilesTable);
  $$SpeciesConfigsTableTableTableManager get speciesConfigsTable =>
      $$SpeciesConfigsTableTableTableManager(_db, _db.speciesConfigsTable);
  $$AnimalsTableTableTableManager get animalsTable =>
      $$AnimalsTableTableTableManager(_db, _db.animalsTable);
  $$BreedingRecordsTableTableTableManager get breedingRecordsTable =>
      $$BreedingRecordsTableTableTableManager(_db, _db.breedingRecordsTable);
  $$EventsTableTableTableManager get eventsTable =>
      $$EventsTableTableTableManager(_db, _db.eventsTable);
  $$AnimalEventsTableTableTableManager get animalEventsTable =>
      $$AnimalEventsTableTableTableManager(_db, _db.animalEventsTable);
}
