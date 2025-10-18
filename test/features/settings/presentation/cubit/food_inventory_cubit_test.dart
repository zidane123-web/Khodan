import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:khodan/data/models/food_stock.dart';
import 'package:khodan/data/models/food_type.dart';
import 'package:khodan/data/repositories/food_inventory_repository.dart';
import 'package:khodan/features/settings/presentation/cubit/food_inventory_cubit.dart';

class _MockFoodInventoryRepository extends Mock
    implements FoodInventoryRepository {}

FoodType _buildType({int id = 1, String name = 'Granules'}) {
  final DateTime now = DateTime(2025, 1, 1);
  return FoodType(
    id: id,
    profileId: 'profile',
    name: name,
    createdAt: now,
    updatedAt: now,
  );
}

FoodStockEntry _buildStock({int id = 10, int? typeId = 1}) {
  final DateTime now = DateTime(2025, 2, 1);
  return FoodStockEntry(
    id: id,
    profileId: 'profile',
    foodTypeId: typeId,
    quantityKg: 15,
    cost: 25,
    purchaseDate: now,
    createdAt: now,
    updatedAt: now,
  );
}

const InventorySummary _emptySummary = InventorySummary(
  totalQuantityKg: 0,
  totalCost: 0,
  entriesCount: 0,
  estimatedMonthlyConsumptionKg: 0,
);

void main() {
  late _MockFoodInventoryRepository repository;
  late FoodInventoryCubit cubit;

  setUpAll(() {
    registerFallbackValue(_buildType());
    registerFallbackValue(_buildStock());
  });

  setUp(() {
    repository = _MockFoodInventoryRepository();
    when(
      () => repository.fetchFoodTypes('profile'),
    ).thenAnswer((_) async => <FoodType>[]);
    when(
      () => repository.fetchFoodStock('profile'),
    ).thenAnswer((_) async => <FoodStockEntry>[]);
    when(
      () => repository.computeSummary('profile'),
    ).thenAnswer((_) async => _emptySummary);
    cubit = FoodInventoryCubit(repository, profileId: 'profile');
  });

  test('initialize loads inventory', () async {
    await cubit.initialize();

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.types, isEmpty);
    expect(cubit.state.stock, isEmpty);
    verify(() => repository.fetchFoodTypes('profile')).called(1);
    verify(() => repository.fetchFoodStock('profile')).called(1);
  });

  test('saveFoodType creates new type and refreshes state', () async {
    await cubit.initialize();

    final FoodType created = _buildType(id: 99, name: 'Foin');
    when(
      () => repository.createFoodType(any()),
    ).thenAnswer((_) async => created);
    when(
      () => repository.fetchFoodTypes('profile'),
    ).thenAnswer((_) async => <FoodType>[created]);

    await cubit.saveFoodType(name: 'Foin');

    expect(cubit.state.types, <FoodType>[created]);
    expect(cubit.state.successMessage, isNotNull);
    verify(() => repository.createFoodType(any())).called(1);
  });

  test('saveFoodStock adds entry and refreshes summary', () async {
    await cubit.initialize();
    final FoodType type = _buildType(id: 5, name: 'Granules');
    when(
      () => repository.fetchFoodTypes('profile'),
    ).thenAnswer((_) async => <FoodType>[type]);
    when(() => repository.computeSummary('profile')).thenAnswer(
      (_) async => const InventorySummary(
        totalQuantityKg: 12,
        totalCost: 30,
        entriesCount: 1,
        estimatedMonthlyConsumptionKg: 12,
      ),
    );
    final FoodStockEntry created = _buildStock(
      id: 200,
      typeId: type.id,
    ).copyWith(quantityKg: 12, cost: 30);
    when(
      () => repository.createFoodStock(any()),
    ).thenAnswer((_) async => created);
    when(
      () => repository.fetchFoodStock('profile'),
    ).thenAnswer((_) async => <FoodStockEntry>[created]);

    await cubit.saveFoodStock(
      foodTypeId: type.id,
      quantityKg: 12,
      cost: 30,
      purchaseDate: created.purchaseDate,
    );

    expect(cubit.state.stock, <FoodStockEntry>[created]);
    expect(cubit.state.summary.totalQuantityKg, 12);
    expect(cubit.state.summary.totalCost, 30);
    expect(cubit.state.summary.estimatedMonthlyConsumptionKg, 12);
    verify(() => repository.createFoodStock(any())).called(1);
  });

  test('deleteFoodType triggers repository call', () async {
    final FoodType type = _buildType(id: 7);
    when(
      () => repository.fetchFoodTypes('profile'),
    ).thenAnswer((_) async => <FoodType>[type]);
    await cubit.initialize();
    when(
      () => repository.fetchFoodTypes('profile'),
    ).thenAnswer((_) async => <FoodType>[]);
    when(() => repository.deleteFoodType(type.id)).thenAnswer((_) async {});

    await cubit.deleteFoodType(type.id);

    expect(cubit.state.types, isEmpty);
    verify(() => repository.deleteFoodType(type.id)).called(1);
  });
}
