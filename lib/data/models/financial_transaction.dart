import 'package:equatable/equatable.dart';

import 'contact.dart';
import 'finance_flow.dart';
import 'transaction_category.dart';

class FinancialTransaction extends Equatable {
  const FinancialTransaction({
    required this.id,
    required this.profileId,
    required this.title,
    required this.flow,
    required this.amount,
    required this.currency,
    required this.occuredOn,
    this.categoryId,
    this.contactId,
    this.paymentMethod,
    this.notes,
    this.attachmentUrl,
    this.attachmentName,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.contact,
  });

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? categoryJson =
        json['category'] as Map<String, dynamic>?;
    final Map<String, dynamic>? contactJson =
        json['contact'] as Map<String, dynamic>?;
    return FinancialTransaction(
      id: json['id'] as String? ?? '',
      profileId: json['profile_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      flow: FinanceFlow.fromKey(json['flow'] as String? ?? 'expense'),
      amount: _parseAmount(json['amount']),
      currency: json['currency'] as String? ?? 'XOF',
      occuredOn: _parseDate(json['occured_on']),
      categoryId: json['category_id'] as String?,
      contactId: json['contact_id'] as String?,
      paymentMethod: json['payment_method'] as String?,
      notes: json['notes'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      attachmentName: json['attachment_name'] as String?,
      createdAt: _maybeParseDate(json['created_at']),
      updatedAt: _maybeParseDate(json['updated_at']),
      category: categoryJson != null
          ? TransactionCategory.fromJson(categoryJson)
          : null,
      contact: contactJson != null ? Contact.fromJson(contactJson) : null,
    );
  }

  final String id;
  final String profileId;
  final String title;
  final FinanceFlow flow;
  final double amount;
  final String currency;
  final DateTime occuredOn;
  final String? categoryId;
  final String? contactId;
  final String? paymentMethod;
  final String? notes;
  final String? attachmentUrl;
  final String? attachmentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TransactionCategory? category;
  final Contact? contact;

  FinancialTransaction copyWith({
    String? id,
    String? profileId,
    String? title,
    FinanceFlow? flow,
    double? amount,
    String? currency,
    DateTime? occuredOn,
    String? categoryId,
    String? contactId,
    String? paymentMethod,
    String? notes,
    String? attachmentUrl,
    String? attachmentName,
    DateTime? createdAt,
    DateTime? updatedAt,
    TransactionCategory? category,
    Contact? contact,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      flow: flow ?? this.flow,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      occuredOn: occuredOn ?? this.occuredOn,
      categoryId: categoryId ?? this.categoryId,
      contactId: contactId ?? this.contactId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      contact: contact ?? this.contact,
    );
  }

  Map<String, dynamic> toInsertPayload() {
    return <String, dynamic>{
      'profile_id': profileId,
      'category_id': categoryId,
      'contact_id': contactId,
      'title': title,
      'flow': flow.key,
      'amount': amount,
      'currency': currency,
      'occured_on': occuredOn.toIso8601String(),
      'payment_method': paymentMethod,
      'notes': notes,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return <String, dynamic>{
      'category_id': categoryId,
      'contact_id': contactId,
      'title': title,
      'flow': flow.key,
      'amount': amount,
      'currency': currency,
      'occured_on': occuredOnIsoString,
      'payment_method': paymentMethod,
      'notes': notes,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
    };
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'category_id': categoryId,
      'contact_id': contactId,
      'title': title,
      'flow': flow.key,
      'amount': amount,
      'currency': currency,
      'occured_on': occuredOn.toIso8601String(),
      'payment_method': paymentMethod,
      'notes': notes,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category': category?.toJson(),
      'contact': contact?.toJson(),
    };
  }

  String get occuredOnIsoString => occuredOn.toIso8601String();

  static double _parseAmount(dynamic raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String && raw.isNotEmpty) {
      return double.tryParse(raw) ?? 0;
    }
    return 0;
  }

  static DateTime _parseDate(dynamic input) {
    if (input is DateTime) {
      return input;
    }
    if (input is String && input.isNotEmpty) {
      return DateTime.tryParse(input)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  static DateTime? _maybeParseDate(dynamic input) {
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
    title,
    flow,
    amount,
    currency,
    occuredOn,
    categoryId,
    contactId,
    paymentMethod,
    notes,
    attachmentUrl,
    attachmentName,
    createdAt,
    updatedAt,
    category,
    contact,
  ];
}
