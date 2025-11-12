import 'package:equatable/equatable.dart';

enum RabbitSaleStatus {
  draft('draft'),
  pending('pending'),
  completed('completed'),
  cancelled('cancelled');

  const RabbitSaleStatus(this.key);
  final String key;

  static RabbitSaleStatus fromKey(String? raw) {
    return RabbitSaleStatus.values.firstWhere(
      (RabbitSaleStatus status) => status.key == raw,
      orElse: () => RabbitSaleStatus.pending,
    );
  }
}

enum RabbitSaleType {
  local('local'),
  marketplace('marketplace');

  const RabbitSaleType(this.key);
  final String key;

  static RabbitSaleType fromKey(String? raw) {
    return RabbitSaleType.values.firstWhere(
      (RabbitSaleType type) => type.key == raw,
      orElse: () => RabbitSaleType.local,
    );
  }
}

class RabbitSale extends Equatable {
  const RabbitSale({
    required this.id,
    required this.profileId,
    required this.animalId,
    required this.saleType,
    required this.status,
    required this.price,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.contactId,
    this.financialTransactionId,
    this.paymentMethod,
    this.proofUrl,
    this.proofName,
    this.expectedCloseDate,
    this.closedAt,
    this.notes,
    this.archivedAt,
    this.animalTag,
    this.animalName,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
  });

  factory RabbitSale.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? animalJson =
        json['animal'] as Map<String, dynamic>?;
    final Map<String, dynamic>? contactJson =
        json['contact'] as Map<String, dynamic>?;
    return RabbitSale(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      animalId: json['animal_id'] as String,
      saleType: RabbitSaleType.fromKey(json['sale_type'] as String?),
      status: RabbitSaleStatus.fromKey(json['status'] as String?),
      price: _parseDouble(json['price']),
      currency: json['currency'] as String? ?? 'XOF',
      contactId: json['contact_id'] as String?,
      financialTransactionId: json['financial_transaction_id'] as String?,
      paymentMethod: json['payment_method'] as String?,
      proofUrl: json['proof_url'] as String?,
      proofName: json['proof_name'] as String?,
      expectedCloseDate: _parseDate(json['expected_close_date']),
      closedAt: _parseDate(json['closed_at']),
      notes: json['notes'] as String?,
      archivedAt: _parseDate(json['archived_at']),
      createdAt: _parseDate(json['created_at'])!,
      updatedAt: _parseDate(json['updated_at'])!,
      animalTag: animalJson?['tag_id'] as String?,
      animalName: animalJson?['name'] as String?,
      contactName: contactJson?['display_name'] as String?,
      contactPhone: contactJson?['phone'] as String?,
      contactEmail: contactJson?['email'] as String?,
    );
  }

  final String id;
  final String profileId;
  final String animalId;
  final RabbitSaleType saleType;
  final RabbitSaleStatus status;
  final double price;
  final String currency;
  final String? contactId;
  final String? financialTransactionId;
  final String? paymentMethod;
  final String? proofUrl;
  final String? proofName;
  final DateTime? expectedCloseDate;
  final DateTime? closedAt;
  final String? notes;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? animalTag;
  final String? animalName;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;

  RabbitSale copyWith({
    RabbitSaleStatus? status,
    String? financialTransactionId,
    DateTime? closedAt,
    DateTime? archivedAt,
  }) {
    return RabbitSale(
      id: id,
      profileId: profileId,
      animalId: animalId,
      saleType: saleType,
      status: status ?? this.status,
      price: price,
      currency: currency,
      contactId: contactId,
      financialTransactionId:
          financialTransactionId ?? this.financialTransactionId,
      paymentMethod: paymentMethod,
      proofUrl: proofUrl,
      proofName: proofName,
      expectedCloseDate: expectedCloseDate,
      closedAt: closedAt ?? this.closedAt,
      notes: notes,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      animalTag: animalTag,
      animalName: animalName,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
    );
  }

  Map<String, dynamic> toInsertPayload() {
    return <String, dynamic>{
      'profile_id': profileId,
      'animal_id': animalId,
      'contact_id': contactId,
      'sale_type': saleType.key,
      'status': status.key,
      'price': price,
      'currency': currency,
      'payment_method': paymentMethod,
      'proof_url': proofUrl,
      'proof_name': proofName,
      'expected_close_date': expectedCloseDate?.toIso8601String(),
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
        animalId,
        saleType,
        status,
        price,
        currency,
        contactId,
        financialTransactionId,
        paymentMethod,
        proofUrl,
        proofName,
        expectedCloseDate,
        closedAt,
        notes,
        archivedAt,
        createdAt,
        updatedAt,
        animalTag,
        animalName,
        contactName,
        contactPhone,
        contactEmail,
      ];
}

class RabbitSaleDraft {
  const RabbitSaleDraft({
    required this.animalId,
    required this.price,
    required this.currency,
    this.contactId,
    this.paymentMethod,
    this.saleType = RabbitSaleType.local,
    this.expectedCloseDate,
    this.notes,
    this.proofUrl,
    this.proofName,
  });

  final String animalId;
  final double price;
  final String currency;
  final String? contactId;
  final String? paymentMethod;
  final RabbitSaleType saleType;
  final DateTime? expectedCloseDate;
  final String? notes;
  final String? proofUrl;
  final String? proofName;
}
