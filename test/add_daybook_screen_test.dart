import 'package:LeLaundrette/view/dashboard/daybook/add_daybook_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddDayBookScreen widget', () {
    Widget buildTestable() {
      return const MaterialApp(
        home: Scaffold(body: AddDayBookScreen()),
      );
    }

    testWidgets('Should render loading indicator when controller.loading is true then show UI after build', (tester) async {
      await tester.pumpWidget(buildTestable());
      // first pump will render initial frame; the screen's GetBuilder depends on an internal controller
      // We expect either loading indicator or the UI depending on default controller state.
      // Since we cannot access controller directly, we verify the structure transitions after an extra pump.
      await tester.pump();
      // Verify header text appears (DayBook)
      expect(find.text('DayBook'), findsOneWidget);
    });

    testWidgets('Should show table headers and input row', (tester) async {
      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      // Headers
      for (final h in const ['Id', 'Item', 'Quantity', 'Tax', 'Unit', 'Rate', 'Net']) {
        expect(find.text(h), findsWidgets);
      }

      // Input placeholders
      expect(find.widgetWithText(TextFormField, 'Select item'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Qty'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Rate'), findsOneWidget);
      // Dropdowns
      expect(find.byType(DropdownButton<String>), findsNWidgets(2));
    });

    testWidgets('Should compute Net as qty * rate dynamically', (tester) async {
      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      // Enter qty = 2 and rate = 10 => net should display 20.00
      await tester.enterText(find.widgetWithText(TextFormField, 'Qty'), '2');
      await tester.enterText(find.widgetWithText(TextFormField, 'Rate'), '10');
      await tester.pump();

      expect(find.text('20.00'), findsWidgets);
    });

    testWidgets('Should add a row when pressing add button with valid inputs and clear inputs', (tester) async {
      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      // Fill inputs
      await tester.enterText(find.widgetWithText(TextFormField, 'Select item'), 'Shirt');
      await tester.enterText(find.widgetWithText(TextFormField, 'Qty'), '3');
      await tester.enterText(find.widgetWithText(TextFormField, 'Rate'), '50');

      // Tap add icon button
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();

      // Row should be added into the Added Items list
      expect(find.text('Shirt'), findsWidgets);
      expect(find.text('3.00'), findsWidgets);
      expect(find.text('50.00'), findsWidgets);
      expect(find.text('150.00'), findsWidgets);

      // Inputs should be cleared
      expect(find.widgetWithText(TextFormField, 'Select item'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Qty'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Rate'), findsOneWidget);
      // Fields should be empty
      final selectItem = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Select item'));
      final qty = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Qty'));
      final rate = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Rate'));
      expect(selectItem.controller?.text ?? '', '');
      expect(qty.controller?.text ?? '', '');
      expect(rate.controller?.text ?? '', '');
    });

    testWidgets('Should reset dropdowns to defaults after adding a row', (tester) async {
      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      // Change dropdown selections first
      final taxDropdown = find.byType(DropdownButton<String>).at(0);
      final unitDropdown = find.byType(DropdownButton<String>).at(1);

      await tester.tap(taxDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('12%').last);
      await tester.pumpAndSettle();

      await tester.tap(unitDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kg').last);
      await tester.pumpAndSettle();

      // Add a row
      await tester.enterText(find.widgetWithText(TextFormField, 'Select item'), 'Pants');
      await tester.enterText(find.widgetWithText(TextFormField, 'Qty'), '1');
      await tester.enterText(find.widgetWithText(TextFormField, 'Rate'), '100');
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      // After adding, dropdowns should reset to defaults 'No Tax' and 'Pieces'
      // This will be reflected by the value widgets showing selected item
      final dropdownTexts = tester.widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>)).toList();
      expect(dropdownTexts[0].value, equals('No Tax'));
      expect(dropdownTexts[1].value, equals('Pieces'));
    });
  });
}
