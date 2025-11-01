import 'package:equatable/equatable.dart';

import 'finance_flow.dart';

class TransactionCategory extends Equatable {
  const TransactionCategory({
    required this.id,
    required this.profileId,
    required this.code,
    required this.label,
    required this.defaultFlow,
    required this.isActive,
    required this.isCustom,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    return TransactionCategory(
      id: json['id'] as String? ?? '',
      profileId: json['profile_id'] as String?,
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
      defaultFlow: FinanceFlow.fromKey(
        json['default_flow'] as String? ?? 'expense',
      ),
      isActive: json['is_active'] as bool? ?? true,
      isCustom: json['is_custom'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  final String id;
  final String? profileId;
  final String code;
  final String label;
  final FinanceFlow defaultFlow;
  final bool isActive;
  final bool isCustom;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionCategory copyWith({
    String? id,
    String? profileId,
    String? code,
    String? label,
    FinanceFlow? defaultFlow,
    bool? isActive,
    bool? isCustom,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionCategory(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      code: code ?? this.code,
      label: label ?? this.label,
      defaultFlow: defaultFlow ?? this.defaultFlow,
      isActive: isActive ?? this.isActive,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toInsertPayload({required String? profileId}) {
    return <String, dynamic>{
      'profile_id': profileId,
      'code': code,
      'label': label,
      'default_flow': defaultFlow.key,
      'is_active': isActive,
      'is_custom': isCustom,
    };
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'code': code,
      'label': label,
      'default_flow': defaultFlow.key,
      'is_active': isActive,
      'is_custom': isCustom,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic input) {
    if (input is DateTime) {
      return input;
    }
    if (input is String && input.isNotEmpty) {
      return DateTime.tryParse(input) ?? DateTime.now();
    }
    return DateTime.now();
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    profileId,
    code,
    label,
    defaultFlow,
    isActive,
    isCustom,
    createdAt,
    updatedAt,
  ];
}
