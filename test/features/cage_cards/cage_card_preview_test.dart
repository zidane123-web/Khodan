import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:khodan/data/models/cage_card_template.dart';
import 'package:khodan/features/cage_cards/presentation/widgets/cage_card_preview.dart';

void main() {
  testWidgets('CageCardPreviewCard shows basic info and QR', (WidgetTester tester) async {
    final CageCardTemplate template = CageCardTemplate(
      id: 'tpl',
      label: 'Test',
      format: CageCardFormat.a4,
    );
    final CageCardRecord record = CageCardRecord(
      id: 'breeder-1',
      title: 'Neige #B14',
      subtitle: 'Californien',
      cageLabel: 'C12',
      subjectType: CageCardSubjectType.breeder,
      deepLink: Uri.parse('https://example.com/breeders/breeder-1'),
      birthDate: DateTime(2024, 7, 12),
      latestWeightKg: 3.2,
      includeSensitive: true,
      sensitiveNote: 'Coût achat : 12 000 FCFA',
      tags: const <String>['Actif', 'Lapine'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CageCardPreviewCard(
            record: record,
            template: template,
            hideSensitive: false,
          ),
        ),
      ),
    );

    expect(find.textContaining('Neige #B14'), findsOneWidget);
    expect(find.textContaining('Cage : C12'), findsOneWidget);
    expect(find.textContaining('Poids : 3.20 kg'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
  });
}
