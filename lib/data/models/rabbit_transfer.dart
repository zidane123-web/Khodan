import 'package:equatable/equatable.dart';

enum RabbitTransferStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected'),
  cancelled('cancelled'),
  completed('completed');

  const RabbitTransferStatus(this.key);
  final String key;

  static RabbitTransferStatus fromKey(String? raw) {
    return RabbitTransferStatus.values.firstWhere(
      (RabbitTransferStatus status) => status.key == raw,
      orElse: () => RabbitTransferStatus.pending,
    );
  }
}

class RabbitTransfer extends Equatable {
  const RabbitTransfer({
    required this.id,
    required this.profileId,
    required this.recipientProfileId,
    required this.animalId,
    required this.status,
    required this.transferFee,
    required this.createdAt,
    required this.updatedAt,
    this.contactId,
    this.financialTransactionId,
    this.expiresAt,
    this.processedAt,
    this.notes,
    this.archivedAt,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.animalTag,
  });

  factory RabbitTransfer.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? contactJson =
        json['contact'] as Map<String, dynamic>?;
    final Map<String, dynamic>? animalJson =
        json['animal'] as Map<String, dynamic>?;
    return RabbitTransfer(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      recipientProfileId: json['recipient_profile_id'] as String,
      animalId: json['animal_id'] as String,
      status: RabbitTransferStatus.fromKey(json['status'] as String?),
      transferFee: _parseDouble(json['transfer_fee']),
      contactId: json['contact_id'] as String?,
      financialTransactionId: json['financial_transaction_id'] as String?,
      expiresAt: _parseDate(json['expires_at']),
      processedAt: _parseDate(json['processed_at']),
      notes: json['notes'] as String?,
      archivedAt: _parseDate(json['archived_at']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      contactName: contactJson?['display_name'] as String?,
      contactPhone: contactJson?['phone'] as String?,
      contactEmail: contactJson?['email'] as String?,
      animalTag: animalJson?['tag_id'] as String?,
    );
  }

  final String id;
  final String profileId;
  final String recipientProfileId;
  final String animalId;
  final RabbitTransferStatus status;
  final double transferFee;
  final String? contactId;
  final String? financialTransactionId;
  final DateTime? expiresAt;
  final DateTime? processedAt;
  final String? notes;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final String? animalTag;

  RabbitTransfer copyWith({
    RabbitTransferStatus? status,
    DateTime? processedAt,
    DateTime? archivedAt,
  }) {
    return RabbitTransfer(
      id: id,
      profileId: profileId,
      recipientProfileId: recipientProfileId,
      animalId: animalId,
      status: status ?? this.status,
      transferFee: transferFee,
      contactId: contactId,
      financialTransactionId: financialTransactionId,
      expiresAt: expiresAt,
      processedAt: processedAt ?? this.processedAt,
      notes: notes,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      animalTag: animalTag,
    );
  }

  Map<String, dynamic> toInsertPayload() {
    return <String, dynamic>{
      'profile_id': profileId,
      'recipient_profile_id': recipientProfileId,
      'animal_id': animalId,
      'contact_id': contactId,
      'status': status.key,
      'transfer_fee': transferFee,
      'expires_at': expiresAt?.toIso8601String(),
      'notes': notes,
      'financial_transaction_id': financialTransactionId,
    };
  }

  static double _parseDouble(dynamic raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String && raw.isNotEmpty) {
      return double.tryParse(raw) ?? 0;
    }
    return 0;
  }

  static DateTime? _parseDate(dynamic input) {
    if (input == null) {
      return null;
    }
    if (input is DateTime) {
      return input;
    }
    if (input is String && input.isNotEmpty) {
      return DateTime.tryParse(input);
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        recipientProfileId,
        animalId,
        status,
        transferFee,
        contactId,
        financialTransactionId,
        expiresAt,
        processedAt,
        notes,
        archivedAt,
        createdAt,
        updatedAt,
        contactName,
        contactPhone,
        contactEmail,
        animalTag,
      ];
}

class RabbitTransferRequest {
  const RabbitTransferRequest({
    required this.animalId,
    required this.recipientProfileId,
    this.contactId,
    this.transferFee = 0,
    this.notes,
    this.expiresAt,
  });

  final String animalId;
  final String recipientProfileId;
  final String? contactId;
  final double transferFee;
  final String? notes;
  final DateTime? expiresAt;
}
