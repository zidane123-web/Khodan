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

class $EventTemplatesTableTable extends EventTemplatesTable
    with TableInfo<$EventTemplatesTableTable, EventTemplatesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventTemplatesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _templateNameMeta =
      const VerificationMeta('templateName');
  @override
  late final GeneratedColumn<String> templateName = GeneratedColumn<String>(
      'template_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
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
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        templateName,
        eventType,
        payload,
        createdAt,
        updatedAt,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_templates_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<EventTemplatesTableData> instance,
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
    if (data.containsKey('template_name')) {
      context.handle(
          _templateNameMeta,
          templateName.isAcceptableOrUnknown(
              data['template_name']!, _templateNameMeta));
    } else if (isInserting) {
      context.missing(_templateNameMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  EventTemplatesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventTemplatesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      templateName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_name'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $EventTemplatesTableTable createAlias(String alias) {
    return $EventTemplatesTableTable(attachedDatabase, alias);
  }
}

class EventTemplatesTableData extends DataClass
    implements Insertable<EventTemplatesTableData> {
  final int id;
  final String profileId;
  final String templateName;
  final String eventType;
  final String payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  const EventTemplatesTableData(
      {required this.id,
      required this.profileId,
      required this.templateName,
      required this.eventType,
      required this.payload,
      required this.createdAt,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['template_name'] = Variable<String>(templateName);
    map['event_type'] = Variable<String>(eventType);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  EventTemplatesTableCompanion toCompanion(bool nullToAbsent) {
    return EventTemplatesTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      templateName: Value(templateName),
      eventType: Value(eventType),
      payload: Value(payload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory EventTemplatesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventTemplatesTableData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      templateName: serializer.fromJson<String>(json['templateName']),
      eventType: serializer.fromJson<String>(json['eventType']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
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
      'templateName': serializer.toJson<String>(templateName),
      'eventType': serializer.toJson<String>(eventType),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  EventTemplatesTableData copyWith(
          {int? id,
          String? profileId,
          String? templateName,
          String? eventType,
          String? payload,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncState}) =>
      EventTemplatesTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        templateName: templateName ?? this.templateName,
        eventType: eventType ?? this.eventType,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  EventTemplatesTableData copyWithCompanion(EventTemplatesTableCompanion data) {
    return EventTemplatesTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      templateName: data.templateName.present
          ? data.templateName.value
          : this.templateName,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventTemplatesTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('templateName: $templateName, ')
          ..write('eventType: $eventType, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, templateName, eventType,
      payload, createdAt, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventTemplatesTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.templateName == this.templateName &&
          other.eventType == this.eventType &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class EventTemplatesTableCompanion
    extends UpdateCompanion<EventTemplatesTableData> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> templateName;
  final Value<String> eventType;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  const EventTemplatesTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.templateName = const Value.absent(),
    this.eventType = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
  });
  EventTemplatesTableCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String templateName,
    required String eventType,
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
  })  : profileId = Value(profileId),
        templateName = Value(templateName),
        eventType = Value(eventType),
        payload = Value(payload),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<EventTemplatesTableData> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? templateName,
    Expression<String>? eventType,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (templateName != null) 'template_name': templateName,
      if (eventType != null) 'event_type': eventType,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
    });
  }

  EventTemplatesTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? profileId,
      Value<String>? templateName,
      Value<String>? eventType,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncState}) {
    return EventTemplatesTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      templateName: templateName ?? this.templateName,
      eventType: eventType ?? this.eventType,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
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
    if (templateName.present) {
      map['template_name'] = Variable<String>(templateName.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('EventTemplatesTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('templateName: $templateName, ')
          ..write('eventType: $eventType, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }
}

class $TaskTemplatesTableTable extends TaskTemplatesTable
    with TableInfo<$TaskTemplatesTableTable, TaskTemplatesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTemplatesTableTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'task_templates_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TaskTemplatesTableData> instance,
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
  TaskTemplatesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTemplatesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
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
  $TaskTemplatesTableTable createAlias(String alias) {
    return $TaskTemplatesTableTable(attachedDatabase, alias);
  }
}

class TaskTemplatesTableData extends DataClass
    implements Insertable<TaskTemplatesTableData> {
  final String id;
  final String profileId;
  final String payload;
  final DateTime updatedAt;
  final String syncState;
  const TaskTemplatesTableData(
      {required this.id,
      required this.profileId,
      required this.payload,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  TaskTemplatesTableCompanion toCompanion(bool nullToAbsent) {
    return TaskTemplatesTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory TaskTemplatesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTemplatesTableData(
      id: serializer.fromJson<String>(json['id']),
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
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  TaskTemplatesTableData copyWith(
          {String? id,
          String? profileId,
          String? payload,
          DateTime? updatedAt,
          String? syncState}) =>
      TaskTemplatesTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  TaskTemplatesTableData copyWithCompanion(TaskTemplatesTableCompanion data) {
    return TaskTemplatesTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTemplatesTableData(')
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
      (other is TaskTemplatesTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class TaskTemplatesTableCompanion
    extends UpdateCompanion<TaskTemplatesTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const TaskTemplatesTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTemplatesTableCompanion.insert({
    required String id,
    required String profileId,
    required String payload,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        payload = Value(payload),
        updatedAt = Value(updatedAt);
  static Insertable<TaskTemplatesTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTemplatesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<String>? payload,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return TaskTemplatesTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
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
    return (StringBuffer('TaskTemplatesTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskTemplateStepsTableTable extends TaskTemplateStepsTable
    with TableInfo<$TaskTemplateStepsTableTable, TaskTemplateStepsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTemplateStepsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
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
      [id, templateId, profileId, position, payload, updatedAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_template_steps_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TaskTemplateStepsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
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
  TaskTemplateStepsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTemplateStepsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $TaskTemplateStepsTableTable createAlias(String alias) {
    return $TaskTemplateStepsTableTable(attachedDatabase, alias);
  }
}

class TaskTemplateStepsTableData extends DataClass
    implements Insertable<TaskTemplateStepsTableData> {
  final int id;
  final String templateId;
  final String profileId;
  final int position;
  final String payload;
  final DateTime updatedAt;
  final String syncState;
  const TaskTemplateStepsTableData(
      {required this.id,
      required this.templateId,
      required this.profileId,
      required this.position,
      required this.payload,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['template_id'] = Variable<String>(templateId);
    map['profile_id'] = Variable<String>(profileId);
    map['position'] = Variable<int>(position);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  TaskTemplateStepsTableCompanion toCompanion(bool nullToAbsent) {
    return TaskTemplateStepsTableCompanion(
      id: Value(id),
      templateId: Value(templateId),
      profileId: Value(profileId),
      position: Value(position),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory TaskTemplateStepsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTemplateStepsTableData(
      id: serializer.fromJson<int>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      position: serializer.fromJson<int>(json['position']),
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
      'templateId': serializer.toJson<String>(templateId),
      'profileId': serializer.toJson<String>(profileId),
      'position': serializer.toJson<int>(position),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  TaskTemplateStepsTableData copyWith(
          {int? id,
          String? templateId,
          String? profileId,
          int? position,
          String? payload,
          DateTime? updatedAt,
          String? syncState}) =>
      TaskTemplateStepsTableData(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        profileId: profileId ?? this.profileId,
        position: position ?? this.position,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  TaskTemplateStepsTableData copyWithCompanion(
      TaskTemplateStepsTableCompanion data) {
    return TaskTemplateStepsTableData(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      position: data.position.present ? data.position.value : this.position,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTemplateStepsTableData(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('profileId: $profileId, ')
          ..write('position: $position, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, templateId, profileId, position, payload, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTemplateStepsTableData &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.profileId == this.profileId &&
          other.position == this.position &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class TaskTemplateStepsTableCompanion
    extends UpdateCompanion<TaskTemplateStepsTableData> {
  final Value<int> id;
  final Value<String> templateId;
  final Value<String> profileId;
  final Value<int> position;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  const TaskTemplateStepsTableCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.position = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
  });
  TaskTemplateStepsTableCompanion.insert({
    this.id = const Value.absent(),
    required String templateId,
    required String profileId,
    required int position,
    required String payload,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
  })  : templateId = Value(templateId),
        profileId = Value(profileId),
        position = Value(position),
        payload = Value(payload),
        updatedAt = Value(updatedAt);
  static Insertable<TaskTemplateStepsTableData> custom({
    Expression<int>? id,
    Expression<String>? templateId,
    Expression<String>? profileId,
    Expression<int>? position,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (profileId != null) 'profile_id': profileId,
      if (position != null) 'position': position,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
    });
  }

  TaskTemplateStepsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? templateId,
      Value<String>? profileId,
      Value<int>? position,
      Value<String>? payload,
      Value<DateTime>? updatedAt,
      Value<String>? syncState}) {
    return TaskTemplateStepsTableCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      profileId: profileId ?? this.profileId,
      position: position ?? this.position,
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
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
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
    return (StringBuffer('TaskTemplateStepsTableCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('profileId: $profileId, ')
          ..write('position: $position, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }
}

class $TaskTemplateAssignmentsTableTable extends TaskTemplateAssignmentsTable
    with
        TableInfo<$TaskTemplateAssignmentsTableTable,
            TaskTemplateAssignmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTemplateAssignmentsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeTypeMeta =
      const VerificationMeta('scopeType');
  @override
  late final GeneratedColumn<String> scopeType = GeneratedColumn<String>(
      'scope_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeIdMeta =
      const VerificationMeta('scopeId');
  @override
  late final GeneratedColumn<String> scopeId = GeneratedColumn<String>(
      'scope_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _anchorDateMeta =
      const VerificationMeta('anchorDate');
  @override
  late final GeneratedColumn<DateTime> anchorDate = GeneratedColumn<DateTime>(
      'anchor_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
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
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        templateId,
        scopeType,
        scopeId,
        anchorDate,
        payload,
        updatedAt,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_template_assignments_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TaskTemplateAssignmentsTableData> instance,
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
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('scope_type')) {
      context.handle(_scopeTypeMeta,
          scopeType.isAcceptableOrUnknown(data['scope_type']!, _scopeTypeMeta));
    } else if (isInserting) {
      context.missing(_scopeTypeMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(_scopeIdMeta,
          scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta));
    }
    if (data.containsKey('anchor_date')) {
      context.handle(
          _anchorDateMeta,
          anchorDate.isAcceptableOrUnknown(
              data['anchor_date']!, _anchorDateMeta));
    } else if (isInserting) {
      context.missing(_anchorDateMeta);
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
  TaskTemplateAssignmentsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTemplateAssignmentsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      scopeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_type'])!,
      scopeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_id']),
      anchorDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}anchor_date'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $TaskTemplateAssignmentsTableTable createAlias(String alias) {
    return $TaskTemplateAssignmentsTableTable(attachedDatabase, alias);
  }
}

class TaskTemplateAssignmentsTableData extends DataClass
    implements Insertable<TaskTemplateAssignmentsTableData> {
  final String id;
  final String profileId;
  final String templateId;
  final String scopeType;
  final String? scopeId;
  final DateTime anchorDate;
  final String payload;
  final DateTime updatedAt;
  final String syncState;
  const TaskTemplateAssignmentsTableData(
      {required this.id,
      required this.profileId,
      required this.templateId,
      required this.scopeType,
      this.scopeId,
      required this.anchorDate,
      required this.payload,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['template_id'] = Variable<String>(templateId);
    map['scope_type'] = Variable<String>(scopeType);
    if (!nullToAbsent || scopeId != null) {
      map['scope_id'] = Variable<String>(scopeId);
    }
    map['anchor_date'] = Variable<DateTime>(anchorDate);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  TaskTemplateAssignmentsTableCompanion toCompanion(bool nullToAbsent) {
    return TaskTemplateAssignmentsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      templateId: Value(templateId),
      scopeType: Value(scopeType),
      scopeId: scopeId == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeId),
      anchorDate: Value(anchorDate),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory TaskTemplateAssignmentsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTemplateAssignmentsTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      templateId: serializer.fromJson<String>(json['templateId']),
      scopeType: serializer.fromJson<String>(json['scopeType']),
      scopeId: serializer.fromJson<String?>(json['scopeId']),
      anchorDate: serializer.fromJson<DateTime>(json['anchorDate']),
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
      'templateId': serializer.toJson<String>(templateId),
      'scopeType': serializer.toJson<String>(scopeType),
      'scopeId': serializer.toJson<String?>(scopeId),
      'anchorDate': serializer.toJson<DateTime>(anchorDate),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  TaskTemplateAssignmentsTableData copyWith(
          {String? id,
          String? profileId,
          String? templateId,
          String? scopeType,
          Value<String?> scopeId = const Value.absent(),
          DateTime? anchorDate,
          String? payload,
          DateTime? updatedAt,
          String? syncState}) =>
      TaskTemplateAssignmentsTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        templateId: templateId ?? this.templateId,
        scopeType: scopeType ?? this.scopeType,
        scopeId: scopeId.present ? scopeId.value : this.scopeId,
        anchorDate: anchorDate ?? this.anchorDate,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  TaskTemplateAssignmentsTableData copyWithCompanion(
      TaskTemplateAssignmentsTableCompanion data) {
    return TaskTemplateAssignmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      scopeType: data.scopeType.present ? data.scopeType.value : this.scopeType,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
      anchorDate:
          data.anchorDate.present ? data.anchorDate.value : this.anchorDate,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTemplateAssignmentsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('templateId: $templateId, ')
          ..write('scopeType: $scopeType, ')
          ..write('scopeId: $scopeId, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, templateId, scopeType, scopeId,
      anchorDate, payload, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTemplateAssignmentsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.templateId == this.templateId &&
          other.scopeType == this.scopeType &&
          other.scopeId == this.scopeId &&
          other.anchorDate == this.anchorDate &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class TaskTemplateAssignmentsTableCompanion
    extends UpdateCompanion<TaskTemplateAssignmentsTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> templateId;
  final Value<String> scopeType;
  final Value<String?> scopeId;
  final Value<DateTime> anchorDate;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const TaskTemplateAssignmentsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.scopeType = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.anchorDate = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTemplateAssignmentsTableCompanion.insert({
    required String id,
    required String profileId,
    required String templateId,
    required String scopeType,
    this.scopeId = const Value.absent(),
    required DateTime anchorDate,
    required String payload,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        templateId = Value(templateId),
        scopeType = Value(scopeType),
        anchorDate = Value(anchorDate),
        payload = Value(payload),
        updatedAt = Value(updatedAt);
  static Insertable<TaskTemplateAssignmentsTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? templateId,
    Expression<String>? scopeType,
    Expression<String>? scopeId,
    Expression<DateTime>? anchorDate,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (templateId != null) 'template_id': templateId,
      if (scopeType != null) 'scope_type': scopeType,
      if (scopeId != null) 'scope_id': scopeId,
      if (anchorDate != null) 'anchor_date': anchorDate,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTemplateAssignmentsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<String>? templateId,
      Value<String>? scopeType,
      Value<String?>? scopeId,
      Value<DateTime>? anchorDate,
      Value<String>? payload,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return TaskTemplateAssignmentsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      templateId: templateId ?? this.templateId,
      scopeType: scopeType ?? this.scopeType,
      scopeId: scopeId ?? this.scopeId,
      anchorDate: anchorDate ?? this.anchorDate,
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
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (scopeType.present) {
      map['scope_type'] = Variable<String>(scopeType.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (anchorDate.present) {
      map['anchor_date'] = Variable<DateTime>(anchorDate.value);
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
    return (StringBuffer('TaskTemplateAssignmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('templateId: $templateId, ')
          ..write('scopeType: $scopeType, ')
          ..write('scopeId: $scopeId, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskTemplateAssignmentEventsTableTable
    extends TaskTemplateAssignmentEventsTable
    with
        TableInfo<$TaskTemplateAssignmentEventsTableTable,
            TaskTemplateAssignmentEventsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTemplateAssignmentEventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assignmentIdMeta =
      const VerificationMeta('assignmentId');
  @override
  late final GeneratedColumn<String> assignmentId = GeneratedColumn<String>(
      'assignment_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stepIdMeta = const VerificationMeta('stepId');
  @override
  late final GeneratedColumn<int> stepId = GeneratedColumn<int>(
      'step_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
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
      [assignmentId, stepId, eventId, profileId, payload, updatedAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_template_assignment_events_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TaskTemplateAssignmentEventsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('assignment_id')) {
      context.handle(
          _assignmentIdMeta,
          assignmentId.isAcceptableOrUnknown(
              data['assignment_id']!, _assignmentIdMeta));
    } else if (isInserting) {
      context.missing(_assignmentIdMeta);
    }
    if (data.containsKey('step_id')) {
      context.handle(_stepIdMeta,
          stepId.isAcceptableOrUnknown(data['step_id']!, _stepIdMeta));
    } else if (isInserting) {
      context.missing(_stepIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {assignmentId, stepId, eventId};
  @override
  TaskTemplateAssignmentEventsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTemplateAssignmentEventsTableData(
      assignmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assignment_id'])!,
      stepId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}step_id'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
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
  $TaskTemplateAssignmentEventsTableTable createAlias(String alias) {
    return $TaskTemplateAssignmentEventsTableTable(attachedDatabase, alias);
  }
}

class TaskTemplateAssignmentEventsTableData extends DataClass
    implements Insertable<TaskTemplateAssignmentEventsTableData> {
  final String assignmentId;
  final int stepId;
  final String eventId;
  final String profileId;
  final String payload;
  final DateTime updatedAt;
  final String syncState;
  const TaskTemplateAssignmentEventsTableData(
      {required this.assignmentId,
      required this.stepId,
      required this.eventId,
      required this.profileId,
      required this.payload,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['assignment_id'] = Variable<String>(assignmentId);
    map['step_id'] = Variable<int>(stepId);
    map['event_id'] = Variable<String>(eventId);
    map['profile_id'] = Variable<String>(profileId);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  TaskTemplateAssignmentEventsTableCompanion toCompanion(bool nullToAbsent) {
    return TaskTemplateAssignmentEventsTableCompanion(
      assignmentId: Value(assignmentId),
      stepId: Value(stepId),
      eventId: Value(eventId),
      profileId: Value(profileId),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory TaskTemplateAssignmentEventsTableData.fromJson(
      Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTemplateAssignmentEventsTableData(
      assignmentId: serializer.fromJson<String>(json['assignmentId']),
      stepId: serializer.fromJson<int>(json['stepId']),
      eventId: serializer.fromJson<String>(json['eventId']),
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
      'assignmentId': serializer.toJson<String>(assignmentId),
      'stepId': serializer.toJson<int>(stepId),
      'eventId': serializer.toJson<String>(eventId),
      'profileId': serializer.toJson<String>(profileId),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  TaskTemplateAssignmentEventsTableData copyWith(
          {String? assignmentId,
          int? stepId,
          String? eventId,
          String? profileId,
          String? payload,
          DateTime? updatedAt,
          String? syncState}) =>
      TaskTemplateAssignmentEventsTableData(
        assignmentId: assignmentId ?? this.assignmentId,
        stepId: stepId ?? this.stepId,
        eventId: eventId ?? this.eventId,
        profileId: profileId ?? this.profileId,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  TaskTemplateAssignmentEventsTableData copyWithCompanion(
      TaskTemplateAssignmentEventsTableCompanion data) {
    return TaskTemplateAssignmentEventsTableData(
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      stepId: data.stepId.present ? data.stepId.value : this.stepId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTemplateAssignmentEventsTableData(')
          ..write('assignmentId: $assignmentId, ')
          ..write('stepId: $stepId, ')
          ..write('eventId: $eventId, ')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      assignmentId, stepId, eventId, profileId, payload, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTemplateAssignmentEventsTableData &&
          other.assignmentId == this.assignmentId &&
          other.stepId == this.stepId &&
          other.eventId == this.eventId &&
          other.profileId == this.profileId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class TaskTemplateAssignmentEventsTableCompanion
    extends UpdateCompanion<TaskTemplateAssignmentEventsTableData> {
  final Value<String> assignmentId;
  final Value<int> stepId;
  final Value<String> eventId;
  final Value<String> profileId;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const TaskTemplateAssignmentEventsTableCompanion({
    this.assignmentId = const Value.absent(),
    this.stepId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTemplateAssignmentEventsTableCompanion.insert({
    required String assignmentId,
    required int stepId,
    required String eventId,
    required String profileId,
    required String payload,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : assignmentId = Value(assignmentId),
        stepId = Value(stepId),
        eventId = Value(eventId),
        profileId = Value(profileId),
        payload = Value(payload),
        updatedAt = Value(updatedAt);
  static Insertable<TaskTemplateAssignmentEventsTableData> custom({
    Expression<String>? assignmentId,
    Expression<int>? stepId,
    Expression<String>? eventId,
    Expression<String>? profileId,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (stepId != null) 'step_id': stepId,
      if (eventId != null) 'event_id': eventId,
      if (profileId != null) 'profile_id': profileId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTemplateAssignmentEventsTableCompanion copyWith(
      {Value<String>? assignmentId,
      Value<int>? stepId,
      Value<String>? eventId,
      Value<String>? profileId,
      Value<String>? payload,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return TaskTemplateAssignmentEventsTableCompanion(
      assignmentId: assignmentId ?? this.assignmentId,
      stepId: stepId ?? this.stepId,
      eventId: eventId ?? this.eventId,
      profileId: profileId ?? this.profileId,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assignmentId.present) {
      map['assignment_id'] = Variable<String>(assignmentId.value);
    }
    if (stepId.present) {
      map['step_id'] = Variable<int>(stepId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskTemplateAssignmentEventsTableCompanion(')
          ..write('assignmentId: $assignmentId, ')
          ..write('stepId: $stepId, ')
          ..write('eventId: $eventId, ')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AilmentsTableTable extends AilmentsTable
    with TableInfo<$AilmentsTableTable, AilmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AilmentsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
      'slug', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _speciesIdMeta =
      const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
      'species_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        name,
        slug,
        speciesId,
        payload,
        createdAt,
        updatedAt,
        archivedAt,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ailments_table';
  @override
  VerificationContext validateIntegrity(Insertable<AilmentsTableData> instance,
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
          _slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    }
    if (data.containsKey('species_id')) {
      context.handle(_speciesIdMeta,
          speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
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
  AilmentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AilmentsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      slug: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}slug']),
      speciesId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}species_id']),
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $AilmentsTableTable createAlias(String alias) {
    return $AilmentsTableTable(attachedDatabase, alias);
  }
}

class AilmentsTableData extends DataClass
    implements Insertable<AilmentsTableData> {
  final String id;
  final String profileId;
  final String name;
  final String? slug;
  final int? speciesId;
  final String payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final String syncState;
  const AilmentsTableData(
      {required this.id,
      required this.profileId,
      required this.name,
      this.slug,
      this.speciesId,
      required this.payload,
      required this.createdAt,
      required this.updatedAt,
      this.archivedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || slug != null) {
      map['slug'] = Variable<String>(slug);
    }
    if (!nullToAbsent || speciesId != null) {
      map['species_id'] = Variable<int>(speciesId);
    }
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  AilmentsTableCompanion toCompanion(bool nullToAbsent) {
    return AilmentsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      slug: slug == null && nullToAbsent ? const Value.absent() : Value(slug),
      speciesId: speciesId == null && nullToAbsent
          ? const Value.absent()
          : Value(speciesId),
      payload: Value(payload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      syncState: Value(syncState),
    );
  }

  factory AilmentsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AilmentsTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      slug: serializer.fromJson<String?>(json['slug']),
      speciesId: serializer.fromJson<int?>(json['speciesId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'slug': serializer.toJson<String?>(slug),
      'speciesId': serializer.toJson<int?>(speciesId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  AilmentsTableData copyWith(
          {String? id,
          String? profileId,
          String? name,
          Value<String?> slug = const Value.absent(),
          Value<int?> speciesId = const Value.absent(),
          String? payload,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> archivedAt = const Value.absent(),
          String? syncState}) =>
      AilmentsTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        name: name ?? this.name,
        slug: slug.present ? slug.value : this.slug,
        speciesId: speciesId.present ? speciesId.value : this.speciesId,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
        syncState: syncState ?? this.syncState,
      );
  AilmentsTableData copyWithCompanion(AilmentsTableCompanion data) {
    return AilmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      slug: data.slug.present ? data.slug.value : this.slug,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AilmentsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('slug: $slug, ')
          ..write('speciesId: $speciesId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, name, slug, speciesId, payload,
      createdAt, updatedAt, archivedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AilmentsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.slug == this.slug &&
          other.speciesId == this.speciesId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt &&
          other.syncState == this.syncState);
}

class AilmentsTableCompanion extends UpdateCompanion<AilmentsTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String?> slug;
  final Value<int?> speciesId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const AilmentsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.slug = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AilmentsTableCompanion.insert({
    required String id,
    required String profileId,
    required String name,
    this.slug = const Value.absent(),
    this.speciesId = const Value.absent(),
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        name = Value(name),
        payload = Value(payload),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AilmentsTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? slug,
    Expression<int>? speciesId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (slug != null) 'slug': slug,
      if (speciesId != null) 'species_id': speciesId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AilmentsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<String>? name,
      Value<String?>? slug,
      Value<int?>? speciesId,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? archivedAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return AilmentsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      speciesId: speciesId ?? this.speciesId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
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
    return (StringBuffer('AilmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('slug: $slug, ')
          ..write('speciesId: $speciesId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HealthRecordsTableTable extends HealthRecordsTable
    with TableInfo<$HealthRecordsTableTable, HealthRecordsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthRecordsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _onsetDateMeta =
      const VerificationMeta('onsetDate');
  @override
  late final GeneratedColumn<DateTime> onsetDate = GeneratedColumn<DateTime>(
      'onset_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        animalId,
        status,
        severity,
        onsetDate,
        createdAt,
        updatedAt,
        payload,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_records_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<HealthRecordsTableData> instance,
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
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('onset_date')) {
      context.handle(_onsetDateMeta,
          onsetDate.isAcceptableOrUnknown(data['onset_date']!, _onsetDateMeta));
    } else if (isInserting) {
      context.missing(_onsetDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
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
  HealthRecordsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthRecordsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      onsetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}onset_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $HealthRecordsTableTable createAlias(String alias) {
    return $HealthRecordsTableTable(attachedDatabase, alias);
  }
}

class HealthRecordsTableData extends DataClass
    implements Insertable<HealthRecordsTableData> {
  final String id;
  final String profileId;
  final String animalId;
  final String status;
  final String severity;
  final DateTime onsetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String payload;
  final String syncState;
  const HealthRecordsTableData(
      {required this.id,
      required this.profileId,
      required this.animalId,
      required this.status,
      required this.severity,
      required this.onsetDate,
      required this.createdAt,
      required this.updatedAt,
      required this.payload,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['animal_id'] = Variable<String>(animalId);
    map['status'] = Variable<String>(status);
    map['severity'] = Variable<String>(severity);
    map['onset_date'] = Variable<DateTime>(onsetDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['payload'] = Variable<String>(payload);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  HealthRecordsTableCompanion toCompanion(bool nullToAbsent) {
    return HealthRecordsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      animalId: Value(animalId),
      status: Value(status),
      severity: Value(severity),
      onsetDate: Value(onsetDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      payload: Value(payload),
      syncState: Value(syncState),
    );
  }

  factory HealthRecordsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthRecordsTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      animalId: serializer.fromJson<String>(json['animalId']),
      status: serializer.fromJson<String>(json['status']),
      severity: serializer.fromJson<String>(json['severity']),
      onsetDate: serializer.fromJson<DateTime>(json['onsetDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      payload: serializer.fromJson<String>(json['payload']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'animalId': serializer.toJson<String>(animalId),
      'status': serializer.toJson<String>(status),
      'severity': serializer.toJson<String>(severity),
      'onsetDate': serializer.toJson<DateTime>(onsetDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'payload': serializer.toJson<String>(payload),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  HealthRecordsTableData copyWith(
          {String? id,
          String? profileId,
          String? animalId,
          String? status,
          String? severity,
          DateTime? onsetDate,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? payload,
          String? syncState}) =>
      HealthRecordsTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        animalId: animalId ?? this.animalId,
        status: status ?? this.status,
        severity: severity ?? this.severity,
        onsetDate: onsetDate ?? this.onsetDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        payload: payload ?? this.payload,
        syncState: syncState ?? this.syncState,
      );
  HealthRecordsTableData copyWithCompanion(HealthRecordsTableCompanion data) {
    return HealthRecordsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      status: data.status.present ? data.status.value : this.status,
      severity: data.severity.present ? data.severity.value : this.severity,
      onsetDate: data.onsetDate.present ? data.onsetDate.value : this.onsetDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      payload: data.payload.present ? data.payload.value : this.payload,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthRecordsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('animalId: $animalId, ')
          ..write('status: $status, ')
          ..write('severity: $severity, ')
          ..write('onsetDate: $onsetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('payload: $payload, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, animalId, status, severity,
      onsetDate, createdAt, updatedAt, payload, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthRecordsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.animalId == this.animalId &&
          other.status == this.status &&
          other.severity == this.severity &&
          other.onsetDate == this.onsetDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.payload == this.payload &&
          other.syncState == this.syncState);
}

class HealthRecordsTableCompanion
    extends UpdateCompanion<HealthRecordsTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> animalId;
  final Value<String> status;
  final Value<String> severity;
  final Value<DateTime> onsetDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> payload;
  final Value<String> syncState;
  final Value<int> rowid;
  const HealthRecordsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.status = const Value.absent(),
    this.severity = const Value.absent(),
    this.onsetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.payload = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthRecordsTableCompanion.insert({
    required String id,
    required String profileId,
    required String animalId,
    required String status,
    required String severity,
    required DateTime onsetDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String payload,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        animalId = Value(animalId),
        status = Value(status),
        severity = Value(severity),
        onsetDate = Value(onsetDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        payload = Value(payload);
  static Insertable<HealthRecordsTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? animalId,
    Expression<String>? status,
    Expression<String>? severity,
    Expression<DateTime>? onsetDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? payload,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (animalId != null) 'animal_id': animalId,
      if (status != null) 'status': status,
      if (severity != null) 'severity': severity,
      if (onsetDate != null) 'onset_date': onsetDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (payload != null) 'payload': payload,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthRecordsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<String>? animalId,
      Value<String>? status,
      Value<String>? severity,
      Value<DateTime>? onsetDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? payload,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return HealthRecordsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      animalId: animalId ?? this.animalId,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      onsetDate: onsetDate ?? this.onsetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      payload: payload ?? this.payload,
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
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (onsetDate.present) {
      map['onset_date'] = Variable<DateTime>(onsetDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
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
    return (StringBuffer('HealthRecordsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('animalId: $animalId, ')
          ..write('status: $status, ')
          ..write('severity: $severity, ')
          ..write('onsetDate: $onsetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('payload: $payload, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HealthTreatmentsTableTable extends HealthTreatmentsTable
    with TableInfo<$HealthTreatmentsTableTable, HealthTreatmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthTreatmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordIdMeta =
      const VerificationMeta('recordId');
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
      'record_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startAtMeta =
      const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
      'start_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
      'end_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        recordId,
        profileId,
        taskId,
        startAt,
        endAt,
        completedAt,
        createdAt,
        updatedAt,
        payload,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_treatments_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<HealthTreatmentsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(_recordIdMeta,
          recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta));
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta,
          startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
          _endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
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
  HealthTreatmentsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthTreatmentsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      recordId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id']),
      startAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_at'])!,
      endAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $HealthTreatmentsTableTable createAlias(String alias) {
    return $HealthTreatmentsTableTable(attachedDatabase, alias);
  }
}

class HealthTreatmentsTableData extends DataClass
    implements Insertable<HealthTreatmentsTableData> {
  final String id;
  final String recordId;
  final String profileId;
  final String? taskId;
  final DateTime startAt;
  final DateTime? endAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String payload;
  final String syncState;
  const HealthTreatmentsTableData(
      {required this.id,
      required this.recordId,
      required this.profileId,
      this.taskId,
      required this.startAt,
      this.endAt,
      this.completedAt,
      required this.createdAt,
      required this.updatedAt,
      required this.payload,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['record_id'] = Variable<String>(recordId);
    map['profile_id'] = Variable<String>(profileId);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['start_at'] = Variable<DateTime>(startAt);
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<DateTime>(endAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['payload'] = Variable<String>(payload);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  HealthTreatmentsTableCompanion toCompanion(bool nullToAbsent) {
    return HealthTreatmentsTableCompanion(
      id: Value(id),
      recordId: Value(recordId),
      profileId: Value(profileId),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      startAt: Value(startAt),
      endAt:
          endAt == null && nullToAbsent ? const Value.absent() : Value(endAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      payload: Value(payload),
      syncState: Value(syncState),
    );
  }

  factory HealthTreatmentsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthTreatmentsTableData(
      id: serializer.fromJson<String>(json['id']),
      recordId: serializer.fromJson<String>(json['recordId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime?>(json['endAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      payload: serializer.fromJson<String>(json['payload']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recordId': serializer.toJson<String>(recordId),
      'profileId': serializer.toJson<String>(profileId),
      'taskId': serializer.toJson<String?>(taskId),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime?>(endAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'payload': serializer.toJson<String>(payload),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  HealthTreatmentsTableData copyWith(
          {String? id,
          String? recordId,
          String? profileId,
          Value<String?> taskId = const Value.absent(),
          DateTime? startAt,
          Value<DateTime?> endAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? payload,
          String? syncState}) =>
      HealthTreatmentsTableData(
        id: id ?? this.id,
        recordId: recordId ?? this.recordId,
        profileId: profileId ?? this.profileId,
        taskId: taskId.present ? taskId.value : this.taskId,
        startAt: startAt ?? this.startAt,
        endAt: endAt.present ? endAt.value : this.endAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        payload: payload ?? this.payload,
        syncState: syncState ?? this.syncState,
      );
  HealthTreatmentsTableData copyWithCompanion(
      HealthTreatmentsTableCompanion data) {
    return HealthTreatmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      payload: data.payload.present ? data.payload.value : this.payload,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthTreatmentsTableData(')
          ..write('id: $id, ')
          ..write('recordId: $recordId, ')
          ..write('profileId: $profileId, ')
          ..write('taskId: $taskId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('payload: $payload, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recordId, profileId, taskId, startAt,
      endAt, completedAt, createdAt, updatedAt, payload, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthTreatmentsTableData &&
          other.id == this.id &&
          other.recordId == this.recordId &&
          other.profileId == this.profileId &&
          other.taskId == this.taskId &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.payload == this.payload &&
          other.syncState == this.syncState);
}

class HealthTreatmentsTableCompanion
    extends UpdateCompanion<HealthTreatmentsTableData> {
  final Value<String> id;
  final Value<String> recordId;
  final Value<String> profileId;
  final Value<String?> taskId;
  final Value<DateTime> startAt;
  final Value<DateTime?> endAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> payload;
  final Value<String> syncState;
  final Value<int> rowid;
  const HealthTreatmentsTableCompanion({
    this.id = const Value.absent(),
    this.recordId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.payload = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthTreatmentsTableCompanion.insert({
    required String id,
    required String recordId,
    required String profileId,
    this.taskId = const Value.absent(),
    required DateTime startAt,
    this.endAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required String payload,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        recordId = Value(recordId),
        profileId = Value(profileId),
        startAt = Value(startAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        payload = Value(payload);
  static Insertable<HealthTreatmentsTableData> custom({
    Expression<String>? id,
    Expression<String>? recordId,
    Expression<String>? profileId,
    Expression<String>? taskId,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? payload,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordId != null) 'record_id': recordId,
      if (profileId != null) 'profile_id': profileId,
      if (taskId != null) 'task_id': taskId,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (payload != null) 'payload': payload,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthTreatmentsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? recordId,
      Value<String>? profileId,
      Value<String?>? taskId,
      Value<DateTime>? startAt,
      Value<DateTime?>? endAt,
      Value<DateTime?>? completedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? payload,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return HealthTreatmentsTableCompanion(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      profileId: profileId ?? this.profileId,
      taskId: taskId ?? this.taskId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      payload: payload ?? this.payload,
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
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
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
    return (StringBuffer('HealthTreatmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('recordId: $recordId, ')
          ..write('profileId: $profileId, ')
          ..write('taskId: $taskId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('payload: $payload, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodTypesTableTable extends FoodTypesTable
    with TableInfo<$FoodTypesTableTable, FoodTypesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodTypesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
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
      [id, profileId, name, payload, createdAt, updatedAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_types_table';
  @override
  VerificationContext validateIntegrity(Insertable<FoodTypesTableData> instance,
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  FoodTypesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodTypesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $FoodTypesTableTable createAlias(String alias) {
    return $FoodTypesTableTable(attachedDatabase, alias);
  }
}

class FoodTypesTableData extends DataClass
    implements Insertable<FoodTypesTableData> {
  final int id;
  final String profileId;
  final String name;
  final String payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  const FoodTypesTableData(
      {required this.id,
      required this.profileId,
      required this.name,
      required this.payload,
      required this.createdAt,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  FoodTypesTableCompanion toCompanion(bool nullToAbsent) {
    return FoodTypesTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      payload: Value(payload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory FoodTypesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodTypesTableData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
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
      'name': serializer.toJson<String>(name),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  FoodTypesTableData copyWith(
          {int? id,
          String? profileId,
          String? name,
          String? payload,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncState}) =>
      FoodTypesTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        name: name ?? this.name,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  FoodTypesTableData copyWithCompanion(FoodTypesTableCompanion data) {
    return FoodTypesTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodTypesTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, profileId, name, payload, createdAt, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodTypesTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class FoodTypesTableCompanion extends UpdateCompanion<FoodTypesTableData> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  const FoodTypesTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
  });
  FoodTypesTableCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String name,
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
  })  : profileId = Value(profileId),
        name = Value(name),
        payload = Value(payload),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FoodTypesTableData> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
    });
  }

  FoodTypesTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? profileId,
      Value<String>? name,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncState}) {
    return FoodTypesTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('FoodTypesTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }
}

class $FoodStockTableTable extends FoodStockTable
    with TableInfo<$FoodStockTableTable, FoodStockTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodStockTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _foodTypeIdMeta =
      const VerificationMeta('foodTypeId');
  @override
  late final GeneratedColumn<int> foodTypeId = GeneratedColumn<int>(
      'food_type_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
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
      [id, profileId, foodTypeId, payload, createdAt, updatedAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_stock_table';
  @override
  VerificationContext validateIntegrity(Insertable<FoodStockTableData> instance,
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
    if (data.containsKey('food_type_id')) {
      context.handle(
          _foodTypeIdMeta,
          foodTypeId.isAcceptableOrUnknown(
              data['food_type_id']!, _foodTypeIdMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  FoodStockTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodStockTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      foodTypeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}food_type_id']),
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $FoodStockTableTable createAlias(String alias) {
    return $FoodStockTableTable(attachedDatabase, alias);
  }
}

class FoodStockTableData extends DataClass
    implements Insertable<FoodStockTableData> {
  final int id;
  final String profileId;
  final int? foodTypeId;
  final String payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  const FoodStockTableData(
      {required this.id,
      required this.profileId,
      this.foodTypeId,
      required this.payload,
      required this.createdAt,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    if (!nullToAbsent || foodTypeId != null) {
      map['food_type_id'] = Variable<int>(foodTypeId);
    }
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  FoodStockTableCompanion toCompanion(bool nullToAbsent) {
    return FoodStockTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      foodTypeId: foodTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodTypeId),
      payload: Value(payload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory FoodStockTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodStockTableData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      foodTypeId: serializer.fromJson<int?>(json['foodTypeId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
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
      'foodTypeId': serializer.toJson<int?>(foodTypeId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  FoodStockTableData copyWith(
          {int? id,
          String? profileId,
          Value<int?> foodTypeId = const Value.absent(),
          String? payload,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncState}) =>
      FoodStockTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        foodTypeId: foodTypeId.present ? foodTypeId.value : this.foodTypeId,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  FoodStockTableData copyWithCompanion(FoodStockTableCompanion data) {
    return FoodStockTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      foodTypeId:
          data.foodTypeId.present ? data.foodTypeId.value : this.foodTypeId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodStockTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('foodTypeId: $foodTypeId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, profileId, foodTypeId, payload, createdAt, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodStockTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.foodTypeId == this.foodTypeId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class FoodStockTableCompanion extends UpdateCompanion<FoodStockTableData> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<int?> foodTypeId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  const FoodStockTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.foodTypeId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
  });
  FoodStockTableCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    this.foodTypeId = const Value.absent(),
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
  })  : profileId = Value(profileId),
        payload = Value(payload),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FoodStockTableData> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<int>? foodTypeId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (foodTypeId != null) 'food_type_id': foodTypeId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
    });
  }

  FoodStockTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? profileId,
      Value<int?>? foodTypeId,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncState}) {
    return FoodStockTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      foodTypeId: foodTypeId ?? this.foodTypeId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
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
    if (foodTypeId.present) {
      map['food_type_id'] = Variable<int>(foodTypeId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('FoodStockTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('foodTypeId: $foodTypeId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }
}

class $DashboardPreferencesTableTable extends DashboardPreferencesTable
    with
        TableInfo<$DashboardPreferencesTableTable,
            DashboardPreferencesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DashboardPreferencesTableTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [profileId, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dashboard_preferences_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DashboardPreferencesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  DashboardPreferencesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DashboardPreferencesTableData(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DashboardPreferencesTableTable createAlias(String alias) {
    return $DashboardPreferencesTableTable(attachedDatabase, alias);
  }
}

class DashboardPreferencesTableData extends DataClass
    implements Insertable<DashboardPreferencesTableData> {
  final String profileId;
  final String payload;
  final DateTime updatedAt;
  const DashboardPreferencesTableData(
      {required this.profileId,
      required this.payload,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DashboardPreferencesTableCompanion toCompanion(bool nullToAbsent) {
    return DashboardPreferencesTableCompanion(
      profileId: Value(profileId),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory DashboardPreferencesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DashboardPreferencesTableData(
      profileId: serializer.fromJson<String>(json['profileId']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DashboardPreferencesTableData copyWith(
          {String? profileId, String? payload, DateTime? updatedAt}) =>
      DashboardPreferencesTableData(
        profileId: profileId ?? this.profileId,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DashboardPreferencesTableData copyWithCompanion(
      DashboardPreferencesTableCompanion data) {
    return DashboardPreferencesTableData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DashboardPreferencesTableData(')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DashboardPreferencesTableData &&
          other.profileId == this.profileId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class DashboardPreferencesTableCompanion
    extends UpdateCompanion<DashboardPreferencesTableData> {
  final Value<String> profileId;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DashboardPreferencesTableCompanion({
    this.profileId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DashboardPreferencesTableCompanion.insert({
    required String profileId,
    required String payload,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : profileId = Value(profileId),
        payload = Value(payload),
        updatedAt = Value(updatedAt);
  static Insertable<DashboardPreferencesTableData> custom({
    Expression<String>? profileId,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DashboardPreferencesTableCompanion copyWith(
      {Value<String>? profileId,
      Value<String>? payload,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DashboardPreferencesTableCompanion(
      profileId: profileId ?? this.profileId,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
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
    return (StringBuffer('DashboardPreferencesTableCompanion(')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
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

class $AnimalMediaTableTable extends AnimalMediaTable
    with TableInfo<$AnimalMediaTableTable, AnimalMediaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalMediaTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storagePathMeta =
      const VerificationMeta('storagePath');
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
      'storage_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
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
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        animalId,
        storagePath,
        payload,
        createdAt,
        updatedAt,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animal_media_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<AnimalMediaTableData> instance,
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
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('storage_path')) {
      context.handle(
          _storagePathMeta,
          storagePath.isAcceptableOrUnknown(
              data['storage_path']!, _storagePathMeta));
    } else if (isInserting) {
      context.missing(_storagePathMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  AnimalMediaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalMediaTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      storagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_path'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $AnimalMediaTableTable createAlias(String alias) {
    return $AnimalMediaTableTable(attachedDatabase, alias);
  }
}

class AnimalMediaTableData extends DataClass
    implements Insertable<AnimalMediaTableData> {
  final String id;
  final String profileId;
  final String animalId;
  final String storagePath;
  final String payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  const AnimalMediaTableData(
      {required this.id,
      required this.profileId,
      required this.animalId,
      required this.storagePath,
      required this.payload,
      required this.createdAt,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['animal_id'] = Variable<String>(animalId);
    map['storage_path'] = Variable<String>(storagePath);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  AnimalMediaTableCompanion toCompanion(bool nullToAbsent) {
    return AnimalMediaTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      animalId: Value(animalId),
      storagePath: Value(storagePath),
      payload: Value(payload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory AnimalMediaTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalMediaTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      animalId: serializer.fromJson<String>(json['animalId']),
      storagePath: serializer.fromJson<String>(json['storagePath']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
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
      'animalId': serializer.toJson<String>(animalId),
      'storagePath': serializer.toJson<String>(storagePath),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  AnimalMediaTableData copyWith(
          {String? id,
          String? profileId,
          String? animalId,
          String? storagePath,
          String? payload,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncState}) =>
      AnimalMediaTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        animalId: animalId ?? this.animalId,
        storagePath: storagePath ?? this.storagePath,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  AnimalMediaTableData copyWithCompanion(AnimalMediaTableCompanion data) {
    return AnimalMediaTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      storagePath:
          data.storagePath.present ? data.storagePath.value : this.storagePath,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalMediaTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('animalId: $animalId, ')
          ..write('storagePath: $storagePath, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, animalId, storagePath, payload,
      createdAt, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalMediaTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.animalId == this.animalId &&
          other.storagePath == this.storagePath &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class AnimalMediaTableCompanion extends UpdateCompanion<AnimalMediaTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> animalId;
  final Value<String> storagePath;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const AnimalMediaTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalMediaTableCompanion.insert({
    required String id,
    required String profileId,
    required String animalId,
    required String storagePath,
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        animalId = Value(animalId),
        storagePath = Value(storagePath),
        payload = Value(payload),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AnimalMediaTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? animalId,
    Expression<String>? storagePath,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (animalId != null) 'animal_id': animalId,
      if (storagePath != null) 'storage_path': storagePath,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalMediaTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<String>? animalId,
      Value<String>? storagePath,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return AnimalMediaTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      animalId: animalId ?? this.animalId,
      storagePath: storagePath ?? this.storagePath,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
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
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('AnimalMediaTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('animalId: $animalId, ')
          ..write('storagePath: $storagePath, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
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

class $LittersTableTable extends LittersTable
    with TableInfo<$LittersTableTable, LittersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LittersTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindlingDateMeta =
      const VerificationMeta('kindlingDate');
  @override
  late final GeneratedColumn<DateTime> kindlingDate = GeneratedColumn<DateTime>(
      'kindling_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
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
      [id, profileId, payload, kindlingDate, status, updatedAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'litters_table';
  @override
  VerificationContext validateIntegrity(Insertable<LittersTableData> instance,
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
    if (data.containsKey('kindling_date')) {
      context.handle(
          _kindlingDateMeta,
          kindlingDate.isAcceptableOrUnknown(
              data['kindling_date']!, _kindlingDateMeta));
    } else if (isInserting) {
      context.missing(_kindlingDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
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
  LittersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LittersTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      kindlingDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}kindling_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $LittersTableTable createAlias(String alias) {
    return $LittersTableTable(attachedDatabase, alias);
  }
}

class LittersTableData extends DataClass
    implements Insertable<LittersTableData> {
  final String id;
  final String profileId;
  final String payload;
  final DateTime kindlingDate;
  final String status;
  final DateTime updatedAt;
  final String syncState;
  const LittersTableData(
      {required this.id,
      required this.profileId,
      required this.payload,
      required this.kindlingDate,
      required this.status,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['payload'] = Variable<String>(payload);
    map['kindling_date'] = Variable<DateTime>(kindlingDate);
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LittersTableCompanion toCompanion(bool nullToAbsent) {
    return LittersTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      payload: Value(payload),
      kindlingDate: Value(kindlingDate),
      status: Value(status),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory LittersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LittersTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      payload: serializer.fromJson<String>(json['payload']),
      kindlingDate: serializer.fromJson<DateTime>(json['kindlingDate']),
      status: serializer.fromJson<String>(json['status']),
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
      'kindlingDate': serializer.toJson<DateTime>(kindlingDate),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LittersTableData copyWith(
          {String? id,
          String? profileId,
          String? payload,
          DateTime? kindlingDate,
          String? status,
          DateTime? updatedAt,
          String? syncState}) =>
      LittersTableData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        payload: payload ?? this.payload,
        kindlingDate: kindlingDate ?? this.kindlingDate,
        status: status ?? this.status,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  LittersTableData copyWithCompanion(LittersTableCompanion data) {
    return LittersTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      payload: data.payload.present ? data.payload.value : this.payload,
      kindlingDate: data.kindlingDate.present
          ? data.kindlingDate.value
          : this.kindlingDate,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LittersTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('kindlingDate: $kindlingDate, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, profileId, payload, kindlingDate, status, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LittersTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.payload == this.payload &&
          other.kindlingDate == this.kindlingDate &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class LittersTableCompanion extends UpdateCompanion<LittersTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> payload;
  final Value<DateTime> kindlingDate;
  final Value<String> status;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const LittersTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.payload = const Value.absent(),
    this.kindlingDate = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LittersTableCompanion.insert({
    required String id,
    required String profileId,
    required String payload,
    required DateTime kindlingDate,
    required String status,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        payload = Value(payload),
        kindlingDate = Value(kindlingDate),
        status = Value(status),
        updatedAt = Value(updatedAt);
  static Insertable<LittersTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? payload,
    Expression<DateTime>? kindlingDate,
    Expression<String>? status,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (payload != null) 'payload': payload,
      if (kindlingDate != null) 'kindling_date': kindlingDate,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LittersTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<String>? payload,
      Value<DateTime>? kindlingDate,
      Value<String>? status,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return LittersTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      payload: payload ?? this.payload,
      kindlingDate: kindlingDate ?? this.kindlingDate,
      status: status ?? this.status,
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
    if (kindlingDate.present) {
      map['kindling_date'] = Variable<DateTime>(kindlingDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('LittersTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('payload: $payload, ')
          ..write('kindlingDate: $kindlingDate, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueuedActionsTableTable extends QueuedActionsTable
    with TableInfo<$QueuedActionsTableTable, QueuedActionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueuedActionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rollbackTypeMeta =
      const VerificationMeta('rollbackType');
  @override
  late final GeneratedColumn<String> rollbackType = GeneratedColumn<String>(
      'rollback_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rollbackPayloadMeta =
      const VerificationMeta('rollbackPayload');
  @override
  late final GeneratedColumn<String> rollbackPayload = GeneratedColumn<String>(
      'rollback_payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        rollbackType,
        description,
        payload,
        rollbackPayload,
        priority,
        status,
        attempts,
        createdAt,
        updatedAt,
        scheduledAt,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queued_actions_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<QueuedActionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('rollback_type')) {
      context.handle(
          _rollbackTypeMeta,
          rollbackType.isAcceptableOrUnknown(
              data['rollback_type']!, _rollbackTypeMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('rollback_payload')) {
      context.handle(
          _rollbackPayloadMeta,
          rollbackPayload.isAcceptableOrUnknown(
              data['rollback_payload']!, _rollbackPayloadMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueuedActionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueuedActionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      rollbackType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rollback_type']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      rollbackPayload: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}rollback_payload']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at']),
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $QueuedActionsTableTable createAlias(String alias) {
    return $QueuedActionsTableTable(attachedDatabase, alias);
  }
}

class QueuedActionsTableData extends DataClass
    implements Insertable<QueuedActionsTableData> {
  final String id;
  final String type;
  final String? rollbackType;
  final String description;
  final String payload;
  final String? rollbackPayload;
  final int priority;
  final String status;
  final int attempts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? scheduledAt;
  final String? lastError;
  const QueuedActionsTableData(
      {required this.id,
      required this.type,
      this.rollbackType,
      required this.description,
      required this.payload,
      this.rollbackPayload,
      required this.priority,
      required this.status,
      required this.attempts,
      required this.createdAt,
      required this.updatedAt,
      this.scheduledAt,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || rollbackType != null) {
      map['rollback_type'] = Variable<String>(rollbackType);
    }
    map['description'] = Variable<String>(description);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || rollbackPayload != null) {
      map['rollback_payload'] = Variable<String>(rollbackPayload);
    }
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  QueuedActionsTableCompanion toCompanion(bool nullToAbsent) {
    return QueuedActionsTableCompanion(
      id: Value(id),
      type: Value(type),
      rollbackType: rollbackType == null && nullToAbsent
          ? const Value.absent()
          : Value(rollbackType),
      description: Value(description),
      payload: Value(payload),
      rollbackPayload: rollbackPayload == null && nullToAbsent
          ? const Value.absent()
          : Value(rollbackPayload),
      priority: Value(priority),
      status: Value(status),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory QueuedActionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueuedActionsTableData(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      rollbackType: serializer.fromJson<String?>(json['rollbackType']),
      description: serializer.fromJson<String>(json['description']),
      payload: serializer.fromJson<String>(json['payload']),
      rollbackPayload: serializer.fromJson<String?>(json['rollbackPayload']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'rollbackType': serializer.toJson<String?>(rollbackType),
      'description': serializer.toJson<String>(description),
      'payload': serializer.toJson<String>(payload),
      'rollbackPayload': serializer.toJson<String?>(rollbackPayload),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  QueuedActionsTableData copyWith(
          {String? id,
          String? type,
          Value<String?> rollbackType = const Value.absent(),
          String? description,
          String? payload,
          Value<String?> rollbackPayload = const Value.absent(),
          int? priority,
          String? status,
          int? attempts,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> scheduledAt = const Value.absent(),
          Value<String?> lastError = const Value.absent()}) =>
      QueuedActionsTableData(
        id: id ?? this.id,
        type: type ?? this.type,
        rollbackType:
            rollbackType.present ? rollbackType.value : this.rollbackType,
        description: description ?? this.description,
        payload: payload ?? this.payload,
        rollbackPayload: rollbackPayload.present
            ? rollbackPayload.value
            : this.rollbackPayload,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        attempts: attempts ?? this.attempts,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  QueuedActionsTableData copyWithCompanion(QueuedActionsTableCompanion data) {
    return QueuedActionsTableData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      rollbackType: data.rollbackType.present
          ? data.rollbackType.value
          : this.rollbackType,
      description:
          data.description.present ? data.description.value : this.description,
      payload: data.payload.present ? data.payload.value : this.payload,
      rollbackPayload: data.rollbackPayload.present
          ? data.rollbackPayload.value
          : this.rollbackPayload,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueuedActionsTableData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('rollbackType: $rollbackType, ')
          ..write('description: $description, ')
          ..write('payload: $payload, ')
          ..write('rollbackPayload: $rollbackPayload, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      type,
      rollbackType,
      description,
      payload,
      rollbackPayload,
      priority,
      status,
      attempts,
      createdAt,
      updatedAt,
      scheduledAt,
      lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueuedActionsTableData &&
          other.id == this.id &&
          other.type == this.type &&
          other.rollbackType == this.rollbackType &&
          other.description == this.description &&
          other.payload == this.payload &&
          other.rollbackPayload == this.rollbackPayload &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.scheduledAt == this.scheduledAt &&
          other.lastError == this.lastError);
}

class QueuedActionsTableCompanion
    extends UpdateCompanion<QueuedActionsTableData> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> rollbackType;
  final Value<String> description;
  final Value<String> payload;
  final Value<String?> rollbackPayload;
  final Value<int> priority;
  final Value<String> status;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> scheduledAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const QueuedActionsTableCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.rollbackType = const Value.absent(),
    this.description = const Value.absent(),
    this.payload = const Value.absent(),
    this.rollbackPayload = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueuedActionsTableCompanion.insert({
    required String id,
    required String type,
    this.rollbackType = const Value.absent(),
    required String description,
    required String payload,
    this.rollbackPayload = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.scheduledAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        description = Value(description),
        payload = Value(payload),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<QueuedActionsTableData> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? rollbackType,
    Expression<String>? description,
    Expression<String>? payload,
    Expression<String>? rollbackPayload,
    Expression<int>? priority,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? scheduledAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (rollbackType != null) 'rollback_type': rollbackType,
      if (description != null) 'description': description,
      if (payload != null) 'payload': payload,
      if (rollbackPayload != null) 'rollback_payload': rollbackPayload,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueuedActionsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String?>? rollbackType,
      Value<String>? description,
      Value<String>? payload,
      Value<String?>? rollbackPayload,
      Value<int>? priority,
      Value<String>? status,
      Value<int>? attempts,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? scheduledAt,
      Value<String?>? lastError,
      Value<int>? rowid}) {
    return QueuedActionsTableCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      rollbackType: rollbackType ?? this.rollbackType,
      description: description ?? this.description,
      payload: payload ?? this.payload,
      rollbackPayload: rollbackPayload ?? this.rollbackPayload,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rollbackType.present) {
      map['rollback_type'] = Variable<String>(rollbackType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rollbackPayload.present) {
      map['rollback_payload'] = Variable<String>(rollbackPayload.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueuedActionsTableCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('rollbackType: $rollbackType, ')
          ..write('description: $description, ')
          ..write('payload: $payload, ')
          ..write('rollbackPayload: $rollbackPayload, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('lastError: $lastError, ')
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
  late final $EventTemplatesTableTable eventTemplatesTable =
      $EventTemplatesTableTable(this);
  late final $TaskTemplatesTableTable taskTemplatesTable =
      $TaskTemplatesTableTable(this);
  late final $TaskTemplateStepsTableTable taskTemplateStepsTable =
      $TaskTemplateStepsTableTable(this);
  late final $TaskTemplateAssignmentsTableTable taskTemplateAssignmentsTable =
      $TaskTemplateAssignmentsTableTable(this);
  late final $TaskTemplateAssignmentEventsTableTable
      taskTemplateAssignmentEventsTable =
      $TaskTemplateAssignmentEventsTableTable(this);
  late final $AilmentsTableTable ailmentsTable = $AilmentsTableTable(this);
  late final $HealthRecordsTableTable healthRecordsTable =
      $HealthRecordsTableTable(this);
  late final $HealthTreatmentsTableTable healthTreatmentsTable =
      $HealthTreatmentsTableTable(this);
  late final $FoodTypesTableTable foodTypesTable = $FoodTypesTableTable(this);
  late final $FoodStockTableTable foodStockTable = $FoodStockTableTable(this);
  late final $DashboardPreferencesTableTable dashboardPreferencesTable =
      $DashboardPreferencesTableTable(this);
  late final $AnimalsTableTable animalsTable = $AnimalsTableTable(this);
  late final $AnimalMediaTableTable animalMediaTable =
      $AnimalMediaTableTable(this);
  late final $BreedingRecordsTableTable breedingRecordsTable =
      $BreedingRecordsTableTable(this);
  late final $EventsTableTable eventsTable = $EventsTableTable(this);
  late final $AnimalEventsTableTable animalEventsTable =
      $AnimalEventsTableTable(this);
  late final $LittersTableTable littersTable = $LittersTableTable(this);
  late final $QueuedActionsTableTable queuedActionsTable =
      $QueuedActionsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        profilesTable,
        speciesConfigsTable,
        eventTemplatesTable,
        taskTemplatesTable,
        taskTemplateStepsTable,
        taskTemplateAssignmentsTable,
        taskTemplateAssignmentEventsTable,
        ailmentsTable,
        healthRecordsTable,
        healthTreatmentsTable,
        foodTypesTable,
        foodStockTable,
        dashboardPreferencesTable,
        animalsTable,
        animalMediaTable,
        breedingRecordsTable,
        eventsTable,
        animalEventsTable,
        littersTable,
        queuedActionsTable
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

typedef $$EventTemplatesTableTableCreateCompanionBuilder
    = EventTemplatesTableCompanion Function({
  Value<int> id,
  required String profileId,
  required String templateName,
  required String eventType,
  required String payload,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncState,
});
typedef $$EventTemplatesTableTableUpdateCompanionBuilder
    = EventTemplatesTableCompanion Function({
  Value<int> id,
  Value<String> profileId,
  Value<String> templateName,
  Value<String> eventType,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncState,
});

class $$EventTemplatesTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $EventTemplatesTableTable,
    EventTemplatesTableData,
    $$EventTemplatesTableTableFilterComposer,
    $$EventTemplatesTableTableOrderingComposer,
    $$EventTemplatesTableTableCreateCompanionBuilder,
    $$EventTemplatesTableTableUpdateCompanionBuilder> {
  $$EventTemplatesTableTableTableManager(
      _$LocalDatabase db, $EventTemplatesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$EventTemplatesTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$EventTemplatesTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> templateName = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
          }) =>
              EventTemplatesTableCompanion(
            id: id,
            profileId: profileId,
            templateName: templateName,
            eventType: eventType,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String profileId,
            required String templateName,
            required String eventType,
            required String payload,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
          }) =>
              EventTemplatesTableCompanion.insert(
            id: id,
            profileId: profileId,
            templateName: templateName,
            eventType: eventType,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
          ),
        ));
}

class $$EventTemplatesTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $EventTemplatesTableTable> {
  $$EventTemplatesTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get templateName => $state.composableBuilder(
      column: $state.table.templateName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get eventType => $state.composableBuilder(
      column: $state.table.eventType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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

class $$EventTemplatesTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $EventTemplatesTableTable> {
  $$EventTemplatesTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get templateName => $state.composableBuilder(
      column: $state.table.templateName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get eventType => $state.composableBuilder(
      column: $state.table.eventType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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

typedef $$TaskTemplatesTableTableCreateCompanionBuilder
    = TaskTemplatesTableCompanion Function({
  required String id,
  required String profileId,
  required String payload,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$TaskTemplatesTableTableUpdateCompanionBuilder
    = TaskTemplatesTableCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> payload,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$TaskTemplatesTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $TaskTemplatesTableTable,
    TaskTemplatesTableData,
    $$TaskTemplatesTableTableFilterComposer,
    $$TaskTemplatesTableTableOrderingComposer,
    $$TaskTemplatesTableTableCreateCompanionBuilder,
    $$TaskTemplatesTableTableUpdateCompanionBuilder> {
  $$TaskTemplatesTableTableTableManager(
      _$LocalDatabase db, $TaskTemplatesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TaskTemplatesTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$TaskTemplatesTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTemplatesTableCompanion(
            id: id,
            profileId: profileId,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required String payload,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTemplatesTableCompanion.insert(
            id: id,
            profileId: profileId,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$TaskTemplatesTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $TaskTemplatesTableTable> {
  $$TaskTemplatesTableTableFilterComposer(super.$state);
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

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TaskTemplatesTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $TaskTemplatesTableTable> {
  $$TaskTemplatesTableTableOrderingComposer(super.$state);
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

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TaskTemplateStepsTableTableCreateCompanionBuilder
    = TaskTemplateStepsTableCompanion Function({
  Value<int> id,
  required String templateId,
  required String profileId,
  required int position,
  required String payload,
  required DateTime updatedAt,
  Value<String> syncState,
});
typedef $$TaskTemplateStepsTableTableUpdateCompanionBuilder
    = TaskTemplateStepsTableCompanion Function({
  Value<int> id,
  Value<String> templateId,
  Value<String> profileId,
  Value<int> position,
  Value<String> payload,
  Value<DateTime> updatedAt,
  Value<String> syncState,
});

class $$TaskTemplateStepsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $TaskTemplateStepsTableTable,
    TaskTemplateStepsTableData,
    $$TaskTemplateStepsTableTableFilterComposer,
    $$TaskTemplateStepsTableTableOrderingComposer,
    $$TaskTemplateStepsTableTableCreateCompanionBuilder,
    $$TaskTemplateStepsTableTableUpdateCompanionBuilder> {
  $$TaskTemplateStepsTableTableTableManager(
      _$LocalDatabase db, $TaskTemplateStepsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$TaskTemplateStepsTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$TaskTemplateStepsTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
          }) =>
              TaskTemplateStepsTableCompanion(
            id: id,
            templateId: templateId,
            profileId: profileId,
            position: position,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String templateId,
            required String profileId,
            required int position,
            required String payload,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
          }) =>
              TaskTemplateStepsTableCompanion.insert(
            id: id,
            templateId: templateId,
            profileId: profileId,
            position: position,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
          ),
        ));
}

class $$TaskTemplateStepsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $TaskTemplateStepsTableTable> {
  $$TaskTemplateStepsTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get templateId => $state.composableBuilder(
      column: $state.table.templateId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get position => $state.composableBuilder(
      column: $state.table.position,
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

class $$TaskTemplateStepsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $TaskTemplateStepsTableTable> {
  $$TaskTemplateStepsTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get templateId => $state.composableBuilder(
      column: $state.table.templateId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get position => $state.composableBuilder(
      column: $state.table.position,
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

typedef $$TaskTemplateAssignmentsTableTableCreateCompanionBuilder
    = TaskTemplateAssignmentsTableCompanion Function({
  required String id,
  required String profileId,
  required String templateId,
  required String scopeType,
  Value<String?> scopeId,
  required DateTime anchorDate,
  required String payload,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$TaskTemplateAssignmentsTableTableUpdateCompanionBuilder
    = TaskTemplateAssignmentsTableCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> templateId,
  Value<String> scopeType,
  Value<String?> scopeId,
  Value<DateTime> anchorDate,
  Value<String> payload,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$TaskTemplateAssignmentsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $TaskTemplateAssignmentsTableTable,
    TaskTemplateAssignmentsTableData,
    $$TaskTemplateAssignmentsTableTableFilterComposer,
    $$TaskTemplateAssignmentsTableTableOrderingComposer,
    $$TaskTemplateAssignmentsTableTableCreateCompanionBuilder,
    $$TaskTemplateAssignmentsTableTableUpdateCompanionBuilder> {
  $$TaskTemplateAssignmentsTableTableTableManager(
      _$LocalDatabase db, $TaskTemplateAssignmentsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$TaskTemplateAssignmentsTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$TaskTemplateAssignmentsTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<String> scopeType = const Value.absent(),
            Value<String?> scopeId = const Value.absent(),
            Value<DateTime> anchorDate = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTemplateAssignmentsTableCompanion(
            id: id,
            profileId: profileId,
            templateId: templateId,
            scopeType: scopeType,
            scopeId: scopeId,
            anchorDate: anchorDate,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required String templateId,
            required String scopeType,
            Value<String?> scopeId = const Value.absent(),
            required DateTime anchorDate,
            required String payload,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTemplateAssignmentsTableCompanion.insert(
            id: id,
            profileId: profileId,
            templateId: templateId,
            scopeType: scopeType,
            scopeId: scopeId,
            anchorDate: anchorDate,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$TaskTemplateAssignmentsTableTableFilterComposer extends FilterComposer<
    _$LocalDatabase, $TaskTemplateAssignmentsTableTable> {
  $$TaskTemplateAssignmentsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get templateId => $state.composableBuilder(
      column: $state.table.templateId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get scopeType => $state.composableBuilder(
      column: $state.table.scopeType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get scopeId => $state.composableBuilder(
      column: $state.table.scopeId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get anchorDate => $state.composableBuilder(
      column: $state.table.anchorDate,
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

class $$TaskTemplateAssignmentsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase,
        $TaskTemplateAssignmentsTableTable> {
  $$TaskTemplateAssignmentsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get templateId => $state.composableBuilder(
      column: $state.table.templateId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get scopeType => $state.composableBuilder(
      column: $state.table.scopeType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get scopeId => $state.composableBuilder(
      column: $state.table.scopeId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get anchorDate => $state.composableBuilder(
      column: $state.table.anchorDate,
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

typedef $$TaskTemplateAssignmentEventsTableTableCreateCompanionBuilder
    = TaskTemplateAssignmentEventsTableCompanion Function({
  required String assignmentId,
  required int stepId,
  required String eventId,
  required String profileId,
  required String payload,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$TaskTemplateAssignmentEventsTableTableUpdateCompanionBuilder
    = TaskTemplateAssignmentEventsTableCompanion Function({
  Value<String> assignmentId,
  Value<int> stepId,
  Value<String> eventId,
  Value<String> profileId,
  Value<String> payload,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$TaskTemplateAssignmentEventsTableTableTableManager
    extends RootTableManager<
        _$LocalDatabase,
        $TaskTemplateAssignmentEventsTableTable,
        TaskTemplateAssignmentEventsTableData,
        $$TaskTemplateAssignmentEventsTableTableFilterComposer,
        $$TaskTemplateAssignmentEventsTableTableOrderingComposer,
        $$TaskTemplateAssignmentEventsTableTableCreateCompanionBuilder,
        $$TaskTemplateAssignmentEventsTableTableUpdateCompanionBuilder> {
  $$TaskTemplateAssignmentEventsTableTableTableManager(
      _$LocalDatabase db, $TaskTemplateAssignmentEventsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TaskTemplateAssignmentEventsTableTableFilterComposer(
                  ComposerState(db, table)),
          orderingComposer:
              $$TaskTemplateAssignmentEventsTableTableOrderingComposer(
                  ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> assignmentId = const Value.absent(),
            Value<int> stepId = const Value.absent(),
            Value<String> eventId = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTemplateAssignmentEventsTableCompanion(
            assignmentId: assignmentId,
            stepId: stepId,
            eventId: eventId,
            profileId: profileId,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String assignmentId,
            required int stepId,
            required String eventId,
            required String profileId,
            required String payload,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTemplateAssignmentEventsTableCompanion.insert(
            assignmentId: assignmentId,
            stepId: stepId,
            eventId: eventId,
            profileId: profileId,
            payload: payload,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$TaskTemplateAssignmentEventsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase,
        $TaskTemplateAssignmentEventsTableTable> {
  $$TaskTemplateAssignmentEventsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get assignmentId => $state.composableBuilder(
      column: $state.table.assignmentId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get stepId => $state.composableBuilder(
      column: $state.table.stepId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
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

class $$TaskTemplateAssignmentEventsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase,
        $TaskTemplateAssignmentEventsTableTable> {
  $$TaskTemplateAssignmentEventsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get assignmentId => $state.composableBuilder(
      column: $state.table.assignmentId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get stepId => $state.composableBuilder(
      column: $state.table.stepId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
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

typedef $$AilmentsTableTableCreateCompanionBuilder = AilmentsTableCompanion
    Function({
  required String id,
  required String profileId,
  required String name,
  Value<String?> slug,
  Value<int?> speciesId,
  required String payload,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> archivedAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$AilmentsTableTableUpdateCompanionBuilder = AilmentsTableCompanion
    Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> name,
  Value<String?> slug,
  Value<int?> speciesId,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$AilmentsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $AilmentsTableTable,
    AilmentsTableData,
    $$AilmentsTableTableFilterComposer,
    $$AilmentsTableTableOrderingComposer,
    $$AilmentsTableTableCreateCompanionBuilder,
    $$AilmentsTableTableUpdateCompanionBuilder> {
  $$AilmentsTableTableTableManager(
      _$LocalDatabase db, $AilmentsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AilmentsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AilmentsTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> slug = const Value.absent(),
            Value<int?> speciesId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AilmentsTableCompanion(
            id: id,
            profileId: profileId,
            name: name,
            slug: slug,
            speciesId: speciesId,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required String name,
            Value<String?> slug = const Value.absent(),
            Value<int?> speciesId = const Value.absent(),
            required String payload,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AilmentsTableCompanion.insert(
            id: id,
            profileId: profileId,
            name: name,
            slug: slug,
            speciesId: speciesId,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$AilmentsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $AilmentsTableTable> {
  $$AilmentsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get slug => $state.composableBuilder(
      column: $state.table.slug,
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

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get archivedAt => $state.composableBuilder(
      column: $state.table.archivedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AilmentsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $AilmentsTableTable> {
  $$AilmentsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get slug => $state.composableBuilder(
      column: $state.table.slug,
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

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get archivedAt => $state.composableBuilder(
      column: $state.table.archivedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$HealthRecordsTableTableCreateCompanionBuilder
    = HealthRecordsTableCompanion Function({
  required String id,
  required String profileId,
  required String animalId,
  required String status,
  required String severity,
  required DateTime onsetDate,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String payload,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$HealthRecordsTableTableUpdateCompanionBuilder
    = HealthRecordsTableCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> animalId,
  Value<String> status,
  Value<String> severity,
  Value<DateTime> onsetDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> payload,
  Value<String> syncState,
  Value<int> rowid,
});

class $$HealthRecordsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $HealthRecordsTableTable,
    HealthRecordsTableData,
    $$HealthRecordsTableTableFilterComposer,
    $$HealthRecordsTableTableOrderingComposer,
    $$HealthRecordsTableTableCreateCompanionBuilder,
    $$HealthRecordsTableTableUpdateCompanionBuilder> {
  $$HealthRecordsTableTableTableManager(
      _$LocalDatabase db, $HealthRecordsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$HealthRecordsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$HealthRecordsTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<DateTime> onsetDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthRecordsTableCompanion(
            id: id,
            profileId: profileId,
            animalId: animalId,
            status: status,
            severity: severity,
            onsetDate: onsetDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            payload: payload,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required String animalId,
            required String status,
            required String severity,
            required DateTime onsetDate,
            required DateTime createdAt,
            required DateTime updatedAt,
            required String payload,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthRecordsTableCompanion.insert(
            id: id,
            profileId: profileId,
            animalId: animalId,
            status: status,
            severity: severity,
            onsetDate: onsetDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            payload: payload,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$HealthRecordsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $HealthRecordsTableTable> {
  $$HealthRecordsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get animalId => $state.composableBuilder(
      column: $state.table.animalId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get severity => $state.composableBuilder(
      column: $state.table.severity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get onsetDate => $state.composableBuilder(
      column: $state.table.onsetDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$HealthRecordsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $HealthRecordsTableTable> {
  $$HealthRecordsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get animalId => $state.composableBuilder(
      column: $state.table.animalId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get severity => $state.composableBuilder(
      column: $state.table.severity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get onsetDate => $state.composableBuilder(
      column: $state.table.onsetDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$HealthTreatmentsTableTableCreateCompanionBuilder
    = HealthTreatmentsTableCompanion Function({
  required String id,
  required String recordId,
  required String profileId,
  Value<String?> taskId,
  required DateTime startAt,
  Value<DateTime?> endAt,
  Value<DateTime?> completedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String payload,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$HealthTreatmentsTableTableUpdateCompanionBuilder
    = HealthTreatmentsTableCompanion Function({
  Value<String> id,
  Value<String> recordId,
  Value<String> profileId,
  Value<String?> taskId,
  Value<DateTime> startAt,
  Value<DateTime?> endAt,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> payload,
  Value<String> syncState,
  Value<int> rowid,
});

class $$HealthTreatmentsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $HealthTreatmentsTableTable,
    HealthTreatmentsTableData,
    $$HealthTreatmentsTableTableFilterComposer,
    $$HealthTreatmentsTableTableOrderingComposer,
    $$HealthTreatmentsTableTableCreateCompanionBuilder,
    $$HealthTreatmentsTableTableUpdateCompanionBuilder> {
  $$HealthTreatmentsTableTableTableManager(
      _$LocalDatabase db, $HealthTreatmentsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$HealthTreatmentsTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$HealthTreatmentsTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> recordId = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String?> taskId = const Value.absent(),
            Value<DateTime> startAt = const Value.absent(),
            Value<DateTime?> endAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthTreatmentsTableCompanion(
            id: id,
            recordId: recordId,
            profileId: profileId,
            taskId: taskId,
            startAt: startAt,
            endAt: endAt,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            payload: payload,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String recordId,
            required String profileId,
            Value<String?> taskId = const Value.absent(),
            required DateTime startAt,
            Value<DateTime?> endAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            required String payload,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthTreatmentsTableCompanion.insert(
            id: id,
            recordId: recordId,
            profileId: profileId,
            taskId: taskId,
            startAt: startAt,
            endAt: endAt,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            payload: payload,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$HealthTreatmentsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $HealthTreatmentsTableTable> {
  $$HealthTreatmentsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recordId => $state.composableBuilder(
      column: $state.table.recordId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get taskId => $state.composableBuilder(
      column: $state.table.taskId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startAt => $state.composableBuilder(
      column: $state.table.startAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get endAt => $state.composableBuilder(
      column: $state.table.endAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get completedAt => $state.composableBuilder(
      column: $state.table.completedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$HealthTreatmentsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $HealthTreatmentsTableTable> {
  $$HealthTreatmentsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recordId => $state.composableBuilder(
      column: $state.table.recordId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get taskId => $state.composableBuilder(
      column: $state.table.taskId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startAt => $state.composableBuilder(
      column: $state.table.startAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get endAt => $state.composableBuilder(
      column: $state.table.endAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get completedAt => $state.composableBuilder(
      column: $state.table.completedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncState => $state.composableBuilder(
      column: $state.table.syncState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$FoodTypesTableTableCreateCompanionBuilder = FoodTypesTableCompanion
    Function({
  Value<int> id,
  required String profileId,
  required String name,
  required String payload,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncState,
});
typedef $$FoodTypesTableTableUpdateCompanionBuilder = FoodTypesTableCompanion
    Function({
  Value<int> id,
  Value<String> profileId,
  Value<String> name,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncState,
});

class $$FoodTypesTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $FoodTypesTableTable,
    FoodTypesTableData,
    $$FoodTypesTableTableFilterComposer,
    $$FoodTypesTableTableOrderingComposer,
    $$FoodTypesTableTableCreateCompanionBuilder,
    $$FoodTypesTableTableUpdateCompanionBuilder> {
  $$FoodTypesTableTableTableManager(
      _$LocalDatabase db, $FoodTypesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FoodTypesTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FoodTypesTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
          }) =>
              FoodTypesTableCompanion(
            id: id,
            profileId: profileId,
            name: name,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String profileId,
            required String name,
            required String payload,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
          }) =>
              FoodTypesTableCompanion.insert(
            id: id,
            profileId: profileId,
            name: name,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
          ),
        ));
}

class $$FoodTypesTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $FoodTypesTableTable> {
  $$FoodTypesTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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

class $$FoodTypesTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $FoodTypesTableTable> {
  $$FoodTypesTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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

typedef $$FoodStockTableTableCreateCompanionBuilder = FoodStockTableCompanion
    Function({
  Value<int> id,
  required String profileId,
  Value<int?> foodTypeId,
  required String payload,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncState,
});
typedef $$FoodStockTableTableUpdateCompanionBuilder = FoodStockTableCompanion
    Function({
  Value<int> id,
  Value<String> profileId,
  Value<int?> foodTypeId,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncState,
});

class $$FoodStockTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $FoodStockTableTable,
    FoodStockTableData,
    $$FoodStockTableTableFilterComposer,
    $$FoodStockTableTableOrderingComposer,
    $$FoodStockTableTableCreateCompanionBuilder,
    $$FoodStockTableTableUpdateCompanionBuilder> {
  $$FoodStockTableTableTableManager(
      _$LocalDatabase db, $FoodStockTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FoodStockTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FoodStockTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<int?> foodTypeId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
          }) =>
              FoodStockTableCompanion(
            id: id,
            profileId: profileId,
            foodTypeId: foodTypeId,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String profileId,
            Value<int?> foodTypeId = const Value.absent(),
            required String payload,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
          }) =>
              FoodStockTableCompanion.insert(
            id: id,
            profileId: profileId,
            foodTypeId: foodTypeId,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
          ),
        ));
}

class $$FoodStockTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $FoodStockTableTable> {
  $$FoodStockTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get foodTypeId => $state.composableBuilder(
      column: $state.table.foodTypeId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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

class $$FoodStockTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $FoodStockTableTable> {
  $$FoodStockTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get foodTypeId => $state.composableBuilder(
      column: $state.table.foodTypeId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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

typedef $$DashboardPreferencesTableTableCreateCompanionBuilder
    = DashboardPreferencesTableCompanion Function({
  required String profileId,
  required String payload,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DashboardPreferencesTableTableUpdateCompanionBuilder
    = DashboardPreferencesTableCompanion Function({
  Value<String> profileId,
  Value<String> payload,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DashboardPreferencesTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $DashboardPreferencesTableTable,
    DashboardPreferencesTableData,
    $$DashboardPreferencesTableTableFilterComposer,
    $$DashboardPreferencesTableTableOrderingComposer,
    $$DashboardPreferencesTableTableCreateCompanionBuilder,
    $$DashboardPreferencesTableTableUpdateCompanionBuilder> {
  $$DashboardPreferencesTableTableTableManager(
      _$LocalDatabase db, $DashboardPreferencesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$DashboardPreferencesTableTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$DashboardPreferencesTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> profileId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DashboardPreferencesTableCompanion(
            profileId: profileId,
            payload: payload,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String profileId,
            required String payload,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DashboardPreferencesTableCompanion.insert(
            profileId: profileId,
            payload: payload,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$DashboardPreferencesTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $DashboardPreferencesTableTable> {
  $$DashboardPreferencesTableTableFilterComposer(super.$state);
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
}

class $$DashboardPreferencesTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $DashboardPreferencesTableTable> {
  $$DashboardPreferencesTableTableOrderingComposer(super.$state);
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

typedef $$AnimalMediaTableTableCreateCompanionBuilder
    = AnimalMediaTableCompanion Function({
  required String id,
  required String profileId,
  required String animalId,
  required String storagePath,
  required String payload,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$AnimalMediaTableTableUpdateCompanionBuilder
    = AnimalMediaTableCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> animalId,
  Value<String> storagePath,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$AnimalMediaTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $AnimalMediaTableTable,
    AnimalMediaTableData,
    $$AnimalMediaTableTableFilterComposer,
    $$AnimalMediaTableTableOrderingComposer,
    $$AnimalMediaTableTableCreateCompanionBuilder,
    $$AnimalMediaTableTableUpdateCompanionBuilder> {
  $$AnimalMediaTableTableTableManager(
      _$LocalDatabase db, $AnimalMediaTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AnimalMediaTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AnimalMediaTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> storagePath = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalMediaTableCompanion(
            id: id,
            profileId: profileId,
            animalId: animalId,
            storagePath: storagePath,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required String animalId,
            required String storagePath,
            required String payload,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalMediaTableCompanion.insert(
            id: id,
            profileId: profileId,
            animalId: animalId,
            storagePath: storagePath,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$AnimalMediaTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $AnimalMediaTableTable> {
  $$AnimalMediaTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get animalId => $state.composableBuilder(
      column: $state.table.animalId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get storagePath => $state.composableBuilder(
      column: $state.table.storagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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

class $$AnimalMediaTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $AnimalMediaTableTable> {
  $$AnimalMediaTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileId => $state.composableBuilder(
      column: $state.table.profileId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get animalId => $state.composableBuilder(
      column: $state.table.animalId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get storagePath => $state.composableBuilder(
      column: $state.table.storagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
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

typedef $$LittersTableTableCreateCompanionBuilder = LittersTableCompanion
    Function({
  required String id,
  required String profileId,
  required String payload,
  required DateTime kindlingDate,
  required String status,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$LittersTableTableUpdateCompanionBuilder = LittersTableCompanion
    Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> payload,
  Value<DateTime> kindlingDate,
  Value<String> status,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$LittersTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LittersTableTable,
    LittersTableData,
    $$LittersTableTableFilterComposer,
    $$LittersTableTableOrderingComposer,
    $$LittersTableTableCreateCompanionBuilder,
    $$LittersTableTableUpdateCompanionBuilder> {
  $$LittersTableTableTableManager(_$LocalDatabase db, $LittersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$LittersTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$LittersTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> kindlingDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LittersTableCompanion(
            id: id,
            profileId: profileId,
            payload: payload,
            kindlingDate: kindlingDate,
            status: status,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required String payload,
            required DateTime kindlingDate,
            required String status,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LittersTableCompanion.insert(
            id: id,
            profileId: profileId,
            payload: payload,
            kindlingDate: kindlingDate,
            status: status,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
        ));
}

class $$LittersTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $LittersTableTable> {
  $$LittersTableTableFilterComposer(super.$state);
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

  ColumnFilters<DateTime> get kindlingDate => $state.composableBuilder(
      column: $state.table.kindlingDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
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

class $$LittersTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $LittersTableTable> {
  $$LittersTableTableOrderingComposer(super.$state);
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

  ColumnOrderings<DateTime> get kindlingDate => $state.composableBuilder(
      column: $state.table.kindlingDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
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

typedef $$QueuedActionsTableTableCreateCompanionBuilder
    = QueuedActionsTableCompanion Function({
  required String id,
  required String type,
  Value<String?> rollbackType,
  required String description,
  required String payload,
  Value<String?> rollbackPayload,
  Value<int> priority,
  Value<String> status,
  Value<int> attempts,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> scheduledAt,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$QueuedActionsTableTableUpdateCompanionBuilder
    = QueuedActionsTableCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String?> rollbackType,
  Value<String> description,
  Value<String> payload,
  Value<String?> rollbackPayload,
  Value<int> priority,
  Value<String> status,
  Value<int> attempts,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> scheduledAt,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$QueuedActionsTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $QueuedActionsTableTable,
    QueuedActionsTableData,
    $$QueuedActionsTableTableFilterComposer,
    $$QueuedActionsTableTableOrderingComposer,
    $$QueuedActionsTableTableCreateCompanionBuilder,
    $$QueuedActionsTableTableUpdateCompanionBuilder> {
  $$QueuedActionsTableTableTableManager(
      _$LocalDatabase db, $QueuedActionsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$QueuedActionsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$QueuedActionsTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> rollbackType = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String?> rollbackPayload = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QueuedActionsTableCompanion(
            id: id,
            type: type,
            rollbackType: rollbackType,
            description: description,
            payload: payload,
            rollbackPayload: rollbackPayload,
            priority: priority,
            status: status,
            attempts: attempts,
            createdAt: createdAt,
            updatedAt: updatedAt,
            scheduledAt: scheduledAt,
            lastError: lastError,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            Value<String?> rollbackType = const Value.absent(),
            required String description,
            required String payload,
            Value<String?> rollbackPayload = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QueuedActionsTableCompanion.insert(
            id: id,
            type: type,
            rollbackType: rollbackType,
            description: description,
            payload: payload,
            rollbackPayload: rollbackPayload,
            priority: priority,
            status: status,
            attempts: attempts,
            createdAt: createdAt,
            updatedAt: updatedAt,
            scheduledAt: scheduledAt,
            lastError: lastError,
            rowid: rowid,
          ),
        ));
}

class $$QueuedActionsTableTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $QueuedActionsTableTable> {
  $$QueuedActionsTableTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get rollbackType => $state.composableBuilder(
      column: $state.table.rollbackType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get rollbackPayload => $state.composableBuilder(
      column: $state.table.rollbackPayload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get priority => $state.composableBuilder(
      column: $state.table.priority,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get attempts => $state.composableBuilder(
      column: $state.table.attempts,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get scheduledAt => $state.composableBuilder(
      column: $state.table.scheduledAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get lastError => $state.composableBuilder(
      column: $state.table.lastError,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$QueuedActionsTableTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $QueuedActionsTableTable> {
  $$QueuedActionsTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get rollbackType => $state.composableBuilder(
      column: $state.table.rollbackType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get rollbackPayload => $state.composableBuilder(
      column: $state.table.rollbackPayload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get priority => $state.composableBuilder(
      column: $state.table.priority,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get attempts => $state.composableBuilder(
      column: $state.table.attempts,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get scheduledAt => $state.composableBuilder(
      column: $state.table.scheduledAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get lastError => $state.composableBuilder(
      column: $state.table.lastError,
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
  $$EventTemplatesTableTableTableManager get eventTemplatesTable =>
      $$EventTemplatesTableTableTableManager(_db, _db.eventTemplatesTable);
  $$TaskTemplatesTableTableTableManager get taskTemplatesTable =>
      $$TaskTemplatesTableTableTableManager(_db, _db.taskTemplatesTable);
  $$TaskTemplateStepsTableTableTableManager get taskTemplateStepsTable =>
      $$TaskTemplateStepsTableTableTableManager(
          _db, _db.taskTemplateStepsTable);
  $$TaskTemplateAssignmentsTableTableTableManager
      get taskTemplateAssignmentsTable =>
          $$TaskTemplateAssignmentsTableTableTableManager(
              _db, _db.taskTemplateAssignmentsTable);
  $$TaskTemplateAssignmentEventsTableTableTableManager
      get taskTemplateAssignmentEventsTable =>
          $$TaskTemplateAssignmentEventsTableTableTableManager(
              _db, _db.taskTemplateAssignmentEventsTable);
  $$AilmentsTableTableTableManager get ailmentsTable =>
      $$AilmentsTableTableTableManager(_db, _db.ailmentsTable);
  $$HealthRecordsTableTableTableManager get healthRecordsTable =>
      $$HealthRecordsTableTableTableManager(_db, _db.healthRecordsTable);
  $$HealthTreatmentsTableTableTableManager get healthTreatmentsTable =>
      $$HealthTreatmentsTableTableTableManager(_db, _db.healthTreatmentsTable);
  $$FoodTypesTableTableTableManager get foodTypesTable =>
      $$FoodTypesTableTableTableManager(_db, _db.foodTypesTable);
  $$FoodStockTableTableTableManager get foodStockTable =>
      $$FoodStockTableTableTableManager(_db, _db.foodStockTable);
  $$DashboardPreferencesTableTableTableManager get dashboardPreferencesTable =>
      $$DashboardPreferencesTableTableTableManager(
          _db, _db.dashboardPreferencesTable);
  $$AnimalsTableTableTableManager get animalsTable =>
      $$AnimalsTableTableTableManager(_db, _db.animalsTable);
  $$AnimalMediaTableTableTableManager get animalMediaTable =>
      $$AnimalMediaTableTableTableManager(_db, _db.animalMediaTable);
  $$BreedingRecordsTableTableTableManager get breedingRecordsTable =>
      $$BreedingRecordsTableTableTableManager(_db, _db.breedingRecordsTable);
  $$EventsTableTableTableManager get eventsTable =>
      $$EventsTableTableTableManager(_db, _db.eventsTable);
  $$AnimalEventsTableTableTableManager get animalEventsTable =>
      $$AnimalEventsTableTableTableManager(_db, _db.animalEventsTable);
  $$LittersTableTableTableManager get littersTable =>
      $$LittersTableTableTableManager(_db, _db.littersTable);
  $$QueuedActionsTableTableTableManager get queuedActionsTable =>
      $$QueuedActionsTableTableTableManager(_db, _db.queuedActionsTable);
}
