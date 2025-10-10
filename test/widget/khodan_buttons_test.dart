import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khodan/app/config/theme.dart';
import 'package:khodan/app/core/widgets/khodan_primary_button.dart';

void main() {
  Widget createHarness(Widget child) {
    return MaterialApp(
      theme: buildKhodanTheme(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('KhodanPrimaryButton triggers callback', (WidgetTester tester) async {
    var pressed = false;

    await tester.pumpWidget(
      createHarness(
        KhodanPrimaryButton(
          label: 'Valider',
          onPressed: () {
            pressed = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });

  testWidgets('KhodanSecondaryButton renders icon and respects outline style', (WidgetTester tester) async {
    await tester.pumpWidget(
      createHarness(
        const KhodanSecondaryButton(
          label: 'Options',
          icon: Icons.filter_list,
        ),
      ),
    );

    final Finder buttonFinder =
        find.byWidgetPredicate((Widget widget) => widget is OutlinedButton);
    expect(buttonFinder, findsOneWidget);
    expect(find.byIcon(Icons.filter_list), findsOneWidget);

    final ButtonStyleButton button =
        tester.widget<ButtonStyleButton>(buttonFinder);
    final MaterialStateProperty<Color?>? foreground =
        button.style?.foregroundColor;
    final BuildContext context = tester.element(find.text('Options'));
    final Color expected = Theme.of(context).colorScheme.primary;

    expect(foreground?.resolve(<MaterialState>{}), equals(expected));
  });

  testWidgets('KhodanGhostButton expands when requested', (WidgetTester tester) async {
    await tester.pumpWidget(
      createHarness(
        const SizedBox(
          width: 200,
          child: KhodanGhostButton(
            label: 'Voir plus',
            fullWidth: true,
          ),
        ),
      ),
    );

    final TextButton button =
        tester.widget<TextButton>(find.byType(TextButton));
    final Size? minSize = button.style?.minimumSize?.resolve(<MaterialState>{});

    expect(minSize?.height, equals(48));
  });

  testWidgets('KhodanDangerButton uses error color', (WidgetTester tester) async {
    await tester.pumpWidget(
      createHarness(
        const KhodanDangerButton(
          label: 'Supprimer',
        ),
      ),
    );

    final FilledButton button =
        tester.widget<FilledButton>(find.byType(FilledButton));
    final MaterialStateProperty<Color?>? background =
        button.style?.backgroundColor;

    final BuildContext context = tester.element(find.text('Supprimer'));
    final Color expectedError = Theme.of(context).colorScheme.error;

    expect(background?.resolve(<MaterialState>{}), equals(expectedError));
  });
}
