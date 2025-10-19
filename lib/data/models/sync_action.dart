import 'dart:convert';

import 'package:equatable/equatable.dart';

enum SyncActionType {
  updateProfile('profile.update'),
  createSupportRequest('support.create'),
  createSpecies('species.create'),
  updateSpecies('species.update'),
  deleteSpecies('species.delete'),
  createEventTemplate('eventTemplate.create'),
  updateEventTemplate('eventTemplate.update'),
  deleteEventTemplate('eventTemplate.delete'),
  createFoodType('foodType.create'),
  updateFoodType('foodType.update'),
  deleteFoodType('foodType.delete'),
  createFoodStock('foodStock.create'),
  updateFoodStock('foodStock.update'),
  deleteFoodStock('foodStock.delete'),
  createAnimal('animal.create'),
  updateAnimal('animal.update'),
  deleteAnimal('animal.delete'),
  uploadAnimalMedia('media.upload'),
  deleteAnimalMedia('media.delete'),
  createBreeding('breeding.create'),
  updateBreeding('breeding.update'),
  deleteBreeding('breeding.delete'),
  createEvent('event.create'),
  updateEvent('event.update'),
  deleteEvent('event.delete');

  const SyncActionType(this.key);

  final String key;

  static SyncActionType? fromKey(String value) {
    for (final SyncActionType type in SyncActionType.values) {
      if (type.key == value) {
        return type;
      }
    }
    return null;
  }
}

enum SyncActionStatus {
  pending,
  running,
  failed,
  completed;

  String get key => name;

  static SyncActionStatus fromKey(String value) {
    return SyncActionStatus.values.firstWhere(
      (SyncActionStatus status) => status.key == value,
      orElse: () => SyncActionStatus.pending,
    );
  }
}

class QueuedSyncAction extends Equatable {
  const QueuedSyncAction({
    required this.id,
    required this.type,
    required this.description,
    required this.payload,
    required this.priority,
    required this.status,
    required this.attempts,
    required this.createdAt,
    required this.updatedAt,
    this.rollbackType,
    this.rollbackPayload,
    this.scheduledAt,
    this.lastError,
  });

  final String id;
  final SyncActionType type;
  final SyncActionType? rollbackType;
  final String description;
  final Map<String, dynamic> payload;
  final Map<String, dynamic>? rollbackPayload;
  final int priority;
  final SyncActionStatus status;
  final int attempts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? scheduledAt;
  final String? lastError;

  bool get isReadyToRun {
    if (status != SyncActionStatus.pending) {
      return false;
    }
    if (scheduledAt == null) {
      return true;
    }
    return !scheduledAt!.isAfter(DateTime.now());
  }

  QueuedSyncAction copyWith({
    SyncActionStatus? status,
    int? attempts,
    DateTime? updatedAt,
    DateTime? scheduledAt,
    bool clearScheduledAt = false,
    String? lastError,
    bool clearLastError = false,
  }) {
    return QueuedSyncAction(
      id: id,
      type: type,
      rollbackType: rollbackType,
      description: description,
      payload: payload,
      rollbackPayload: rollbackPayload,
      priority: priority,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledAt: clearScheduledAt ? null : scheduledAt ?? this.scheduledAt,
      lastError: clearLastError ? null : lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toCompanionJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.key,
      'rollback_type': rollbackType?.key,
      'description': description,
      'payload': jsonEncode(payload),
      'rollback_payload':
          rollbackPayload == null ? null : jsonEncode(rollbackPayload),
      'priority': priority,
      'status': status.key,
      'attempts': attempts,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'last_error': lastError,
    };
  }

  factory QueuedSyncAction.fromRow(Map<String, dynamic> row) {
    final SyncActionType? type =
        SyncActionType.fromKey(row['type'] as String? ?? '');
    if (type == null) {
      throw StateError('Unknown sync action type: ${row['type']}');
    }
    final SyncActionType? rollbackType = SyncActionType.fromKey(
      row['rollback_type'] as String? ?? '',
    );
    return QueuedSyncAction(
      id: row['id'] as String,
      type: type,
      rollbackType: rollbackType,
      description: row['description'] as String,
      payload: _decode(row['payload'] as String),
      rollbackPayload: row['rollback_payload'] == null
          ? null
          : _decode(row['rollback_payload'] as String),
      priority: row['priority'] as int,
      status: SyncActionStatus.fromKey(row['status'] as String? ?? 'pending'),
      attempts: row['attempts'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      scheduledAt: row['scheduled_at'] == null
          ? null
          : DateTime.parse(row['scheduled_at'] as String),
      lastError: row['last_error'] as String?,
    );
  }

  static Map<String, dynamic> _decode(String data) {
    return jsonDecode(data) as Map<String, dynamic>;
  }

  @override
  List<Object?> get props => <Object?>[
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
        lastError,
      ];
}
