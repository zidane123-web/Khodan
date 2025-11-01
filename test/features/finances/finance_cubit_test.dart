import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/models/contact.dart';
import 'package:khodan/data/models/finance_flow.dart';
import 'package:khodan/data/models/financial_transaction.dart';
import 'package:khodan/data/repositories/finance_repository.dart';
import 'package:khodan/features/finances/presentation/cubit/finance_cubit.dart';
import 'package:khodan/features/finances/presentation/cubit/finance_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FinanceCubit', () {
    late InMemoryFinanceRepository repository;
    late FinanceCubit cubit;

    setUp(() {
      repository = InMemoryFinanceRepository();
      cubit = FinanceCubit(repository: repository);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('saves transaction linked to contact', () async {
      await cubit.load();
      final String categoryId = cubit.state.categories.first.id;

      final ContactDraft contactDraft = ContactDraft(
        displayName: 'Abena Feed',
        type: ContactType.supplier,
        email: 'abena@example.com',
        phone: '0777000000',
        address: 'Ferme centrale',
        notes: 'Livraison hebdo',
      );
      final Contact? savedContact = await cubit.saveContact(contactDraft);
      expect(savedContact, isNotNull);

      final TransactionDraft draft = TransactionDraft(
        title: 'Achat foin',
        amount: 45000,
        currency: 'XOF',
        occuredOn: DateTime(2025, 10, 30),
        categoryId: categoryId,
        contactId: savedContact!.id,
        flow: FinanceFlow.expense,
        paymentMethod: 'Mobile money',
        notes: 'Livraison semaine 44',
      );

      final FinancialTransaction? saved = await cubit.saveTransaction(draft);
      expect(saved, isNotNull);

      expect(saved!.contactId, equals(savedContact.id));
      expect(
        cubit.state.transactions.map((FinancialTransaction tx) => tx.id),
        contains(saved.id),
      );
      final FinanceState state = cubit.state;
      expect(
        state.transactions.first.contact?.displayName,
        equals('Abena Feed'),
      );
    });
  });
}
