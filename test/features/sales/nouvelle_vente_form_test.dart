import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/models/animal.dart';
import 'package:khodan/data/models/contact.dart';
import 'package:khodan/data/models/rabbit_sale.dart';
import 'package:khodan/features/sales/presentation/widgets/nouvelle_vente_form.dart';

void main() {
  testWidgets('NouvelleVenteForm validates fields and submits draft',
      (WidgetTester tester) async {
    RabbitSaleDraft? submitted;
    final Completer<void> completer = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NouvelleVenteForm(
            animals: <Animal>[
              Animal(
                id: 'animal-1',
                profileId: 'profile-1',
                speciesId: 1,
                tagId: 'F01',
                birthDate: DateTime(2024, 1, 1),
                sex: 'F',
                status: 'active',
              ),
            ],
            contacts: <Contact>[
              Contact(
                id: 'contact-1',
                profileId: 'profile-1',
                displayName: 'Client Test',
                type: ContactType.client,
                email: 'client@example.com',
                phone: '+229000',
                address: null,
                notes: null,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ],
            onSubmit: (RabbitSaleDraft draft) async {
              submitted = draft;
              completer.complete();
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Select animal.
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('F01').last);
    await tester.pumpAndSettle();

    // Enter price.
    await tester.enterText(find.bySemanticsLabel('Prix'), '15000');

    // Confirm guard checkbox.
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    // Submit form.
    await tester.ensureVisible(find.text('Enregistrer la vente'));
    await tester.tap(find.text('Enregistrer la vente'));
    await tester.pump();

    await completer.future;
    expect(submitted, isNotNull);
    expect(submitted!.animalId, equals('animal-1'));
    expect(submitted!.price, equals(15000));
    expect(submitted!.paymentMethod, equals('cash'));
  });
}
