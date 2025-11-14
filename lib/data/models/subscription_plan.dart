import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  SubscriptionPlan({
    required this.id,
    required this.code,
    required this.label,
    this.description,
    required this.monthlyPriceCents,
    required this.currency,
    this.maxBreeders,
    this.maxMembers,
    this.storageLimitMb,
    List<String>? modules,
    Map<String, dynamic>? metadata,
    this.isActive = true,
    this.sortOrder = 0,
  })  : modules = List<String>.unmodifiable(modules ?? const <String>[]),
        metadata = Map<String, dynamic>.unmodifiable(
          Map<String, dynamic>.from(metadata ?? const <String, dynamic>{}),
        );

  final String id;
  final String code;
  final String label;
  final String? description;
  final int monthlyPriceCents;
  final String currency;
  final int? maxBreeders;
  final int? maxMembers;
  final int? storageLimitMb;
  final List<String> modules;
  final Map<String, dynamic> metadata;
  final bool isActive;
  final int sortOrder;

  bool get isFree => monthlyPriceCents == 0;

  bool get isEnterprise => code == 'enterprise';

  SubscriptionPlan copyWith({
    String? id,
    String? code,
    String? label,
    String? description,
    int? monthlyPriceCents,
    String? currency,
    int? maxBreeders,
    bool clearMaxBreeders = false,
    int? maxMembers,
    bool clearMaxMembers = false,
    int? storageLimitMb,
    bool clearStorage = false,
    List<String>? modules,
    Map<String, dynamic>? metadata,
    bool? isActive,
    int? sortOrder,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      code: code ?? this.code,
      label: label ?? this.label,
      description: description ?? this.description,
      monthlyPriceCents: monthlyPriceCents ?? this.monthlyPriceCents,
      currency: currency ?? this.currency,
      maxBreeders: clearMaxBreeders ? null : (maxBreeders ?? this.maxBreeders),
      maxMembers: clearMaxMembers ? null : (maxMembers ?? this.maxMembers),
      storageLimitMb: clearStorage ? null : (storageLimitMb ?? this.storageLimitMb),
      modules: modules ?? this.modules,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawModules = json['modules'] as List<dynamic>?;
    final dynamic rawMetadata = json['metadata'];
    return SubscriptionPlan(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
      description: json['description'] as String?,
      monthlyPriceCents: (json['monthly_price_cents'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
      maxBreeders: json['max_breeders'] as int?,
      maxMembers: json['max_members'] as int?,
      storageLimitMb: json['storage_limit_mb'] as int?,
      modules: rawModules == null
          ? const <String>[]
          : rawModules.whereType<String>().toList(),
      metadata: rawMetadata is Map<String, dynamic>
          ? Map<String, dynamic>.from(rawMetadata)
          : const <String, dynamic>{},
      isActive: (json['is_active'] as bool?) ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'label': label,
      'description': description,
      'monthly_price_cents': monthlyPriceCents,
      'currency': currency,
      'max_breeders': maxBreeders,
      'max_members': maxMembers,
      'storage_limit_mb': storageLimitMb,
      'modules': modules,
      'metadata': metadata,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        code,
        label,
        description,
        monthlyPriceCents,
        currency,
        maxBreeders,
        maxMembers,
        storageLimitMb,
        modules,
        metadata,
        isActive,
        sortOrder,
      ];
}
