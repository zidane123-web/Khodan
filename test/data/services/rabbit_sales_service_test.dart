import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:khodan/data/models/finance_flow.dart';
import 'package:khodan/data/models/financial_transaction.dart';
import 'package:khodan/data/models/rabbit_sale.dart';
import 'package:khodan/data/models/transaction_category.dart';
import 'package:khodan/data/repositories/finance_repository.dart';
import 'package:khodan/data/services/api_client.dart';
import 'package:khodan/data/services/notification_hooks.dart';
import 'package:khodan/data/services/rabbit_sales_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final DateTime now = DateTime.now();

  setUpAll(() {
    registerFallbackValue(_FakeNotificationPayload());
    registerFallbackValue(
      FinancialTransaction(
        id: 'fake',
        profileId: 'profile',
        title: 'fake',
        flow: FinanceFlow.expense,
        amount: 0,
        currency: 'XOF',
        occuredOn: DateTime(2020),
      ),
    );
  });

  group('RabbitSalesService', () {
    late _MockFinanceRepository financeRepository;
    late _MockNotificationHook notificationHook;

    setUp(() {
      financeRepository = _MockFinanceRepository();
      notificationHook = _MockNotificationHook();
    });

    test('createLocalSale records ledger entry and notifies hooks', () async {
      final Map<String, dynamic> saleRow = _buildSaleRow(
        id: 'sale-1',
        status: 'pending',
        createdAt: now,
      );
      final RabbitSalesService service = RabbitSalesService(
        apiClient: _StubApiExecutor(responses: <String, dynamic>{
          'sales.create': saleRow,
        }),
        financeRepository: financeRepository,
        notificationHooks: <NotificationHook>[notificationHook],
        profileIdOverride: 'profile-1',
      );

      when(
        () => financeRepository.fetchCategories(includeInactive: false),
      ).thenAnswer(
        (_) async => <TransactionCategory>[
          _buildCategory(id: 'cat-sales', code: 'sales', flow: FinanceFlow.income),
        ],
      );
      when(() => notificationHook.dispatch(any())).thenAnswer((_) async {});
      when(() => financeRepository.createTransaction(any())).thenAnswer(
        (Invocation invocation) async {
          final FinancialTransaction tx =
              invocation.positionalArguments.first as FinancialTransaction;
          expect(tx.categoryId, equals('cat-sales'));
          expect(tx.amount, equals(25000));
          return tx.copyWith(id: 'txn-1');
        },
      );

      final RabbitSaleDraft draft = RabbitSaleDraft(
        animalId: 'animal-1',
        price: 25000,
        currency: 'XOF',
        contactId: 'contact-1',
        paymentMethod: 'cash',
      );

      final RabbitSale sale = await service.createLocalSale(draft);

      expect(sale.id, equals('sale-1'));
      expect(sale.status, equals(RabbitSaleStatus.pending));
      verify(() => financeRepository.createTransaction(any())).called(1);
      verify(() => notificationHook.dispatch(any())).called(1);
    });

    test('cancelSale cleans financial transaction', () async {
      final Map<String, dynamic> pendingRow = _buildSaleRow(
        id: 'sale-1',
        status: 'pending',
        createdAt: now,
        transactionId: 'txn-1',
      );
      final Map<String, dynamic> cancelledRow = _buildSaleRow(
        id: 'sale-1',
        status: 'cancelled',
        createdAt: now,
      );
      final RabbitSalesService service = RabbitSalesService(
        apiClient: _StubApiExecutor(responses: <String, dynamic>{
          'sales.fetch.single': pendingRow,
          'sales.cancel': cancelledRow,
          'sales.animals.archive': <String, dynamic>{'id': 'animal-1'},
        }),
        financeRepository: financeRepository,
        notificationHooks: <NotificationHook>[notificationHook],
        profileIdOverride: 'profile-1',
      );

      when(() => financeRepository.deleteTransaction('txn-1'))
          .thenAnswer((_) async {});

      final RabbitSale sale = await service.cancelSale('sale-1');

      expect(sale.status, RabbitSaleStatus.cancelled);
      verify(() => financeRepository.deleteTransaction('txn-1')).called(1);
    });
  });
}

class _MockFinanceRepository extends Mock implements FinanceRepository {}

class _MockNotificationHook extends Mock implements NotificationHook {}

class _FakeNotificationPayload extends Fake implements NotificationPayload {}

class _StubApiExecutor implements ApiExecutor {
  _StubApiExecutor({
    required Map<String, dynamic> responses,
  }) : _responses = responses;

  final Map<String, dynamic> _responses;

  @override
  SupabaseClient get client => throw UnimplementedError();

  @override
  Future<T> run<T>(
    Future<T> Function(SupabaseClient client) operation, {
    String? label,
  }) async {
    if (!_responses.containsKey(label)) {
      throw StateError('No stub registered for label $label');
    }
    return _responses[label] as T;
  }
}

Map<String, dynamic> _buildSaleRow({
  required String id,
  required String status,
  required DateTime createdAt,
  String? transactionId,
}) {
  return <String, dynamic>{
    'id': id,
    'profile_id': 'profile-1',
    'animal_id': 'animal-1',
    'contact_id': 'contact-1',
    'sale_type': 'local',
    'status': status,
    'price': 25000,
    'currency': 'XOF',
    'payment_method': 'cash',
    'financial_transaction_id': transactionId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': createdAt.toIso8601String(),
    'animal': <String, dynamic>{
      'tag_id': 'F01',
      'name': 'Neige',
    },
    'contact': <String, dynamic>{
      'display_name': 'Client Test',
      'phone': '+2290000',
      'email': 'client@example.com',
    },
  };
}

TransactionCategory _buildCategory({
  required String id,
  required String code,
  required FinanceFlow flow,
}) {
  final DateTime now = DateTime.now();
  return TransactionCategory(
    id: id,
    profileId: 'profile-1',
    code: code,
    label: code,
    defaultFlow: flow,
    isActive: true,
    isCustom: false,
    createdAt: now,
    updatedAt: now,
  );
}
