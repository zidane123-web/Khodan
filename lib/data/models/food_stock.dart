import 'package:equatable/equatable.dart';

class FoodStockEntry extends Equatable {
  const FoodStockEntry({
    required this.id,
    required this.profileId,
    this.foodTypeId,
    required this.quantityKg,
    this.cost,
    this.purchaseDate,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  final int id;
  final String profileId;
  final int? foodTypeId;
  final double quantityKg;
  final double? cost;
  final DateTime? purchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodStockEntry copyWith({
    int? id,
    String? profileId,
    int? foodTypeId,
    bool clearFoodType = false,
    double? quantityKg,
    double? cost,
    bool clearCost = false,
    DateTime? purchaseDate,
    bool clearPurchaseDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodStockEntry(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      foodTypeId: clearFoodType ? null : foodTypeId ?? this.foodTypeId,
      quantityKg: quantityKg ?? this.quantityKg,
      cost: clearCost ? null : cost ?? this.cost,
      purchaseDate:
          clearPurchaseDate ? null : purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FoodStockEntry.fromJson(Map<String, dynamic> json) {
    return FoodStockEntry(
      id: json['id'] as int,
      profileId: json['user_id'] as String,
      foodTypeId: json['food_type_id'] as int?,
      quantityKg: (json['quantity_kg'] as num).toDouble(),
      cost: (json['cost'] as num?)?.toDouble(),
      purchaseDate: json['purchase_date'] == null
          ? null
          : DateTime.parse(json['purchase_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(
        (json['updated_at'] as String?) ?? json['created_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': profileId,
      'food_type_id': foodTypeId,
      'quantity_kg': quantityKg,
      'cost': cost,
      'purchase_date': purchaseDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        foodTypeId,
        quantityKg,
        cost,
        purchaseDate,
        createdAt,
        updatedAt,
      ];
}
