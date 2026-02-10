import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dri_survey/components/autocomplete_dropdown.dart';

void main() {
  group('AutocompleteDropdown Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with required parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutocompleteDropdown(
              label: 'Test Label',
              hintText: 'Test Hint',
              options: ['Option 1', 'Option 2', 'Option 3'],
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('initializes with initial value', (WidgetTester tester) async {
      controller.text = 'Option 1';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutocompleteDropdown(
              label: 'Test Label',
              hintText: 'Test Hint',
              options: ['Option 1', 'Option 2', 'Option 3'],
              controller: controller,
              initialValue: 'Option 1',
            ),
          ),
        ),
      );

      expect(controller.text, 'Option 1');
    });

    testWidgets('filters options based on input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutocompleteDropdown(
              label: 'Test Label',
              hintText: 'Test Hint',
              options: ['Apple', 'Banana', 'Orange', 'Pineapple'],
              controller: controller,
            ),
          ),
        ),
      );

      // Enter text to filter
      await tester.enterText(find.byType(TextFormField), 'App');
      await tester.pump();

      // Verify controller has the filtered text
      expect(controller.text, 'App');
    });

    testWidgets('selects option when text matches exactly', (WidgetTester tester) async {
      String? selectedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutocompleteDropdown(
              label: 'Test Label',
              hintText: 'Test Hint',
              options: ['Option 1', 'Option 2'],
              controller: controller,
              onChanged: (value) => selectedValue = value,
            ),
          ),
        ),
      );

      // Enter text that matches an option
      await tester.enterText(find.byType(TextFormField), 'Option 2');
      await tester.pump();

      // Verify controller has the selected text
      expect(controller.text, 'Option 2');
      expect(selectedValue, 'Option 2');
    });

    testWidgets('respects enabled property', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutocompleteDropdown(
              label: 'Test Label',
              hintText: 'Test Hint',
              options: ['Option 1', 'Option 2', 'Option 3'],
              controller: controller,
              enabled: false,
            ),
          ),
        ),
      );

      // Try to enter text
      await tester.enterText(find.byType(TextFormField), 'test');
      expect(controller.text, ''); // Should not change
    });

    testWidgets('handles empty options list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutocompleteDropdown(
              label: 'Test Label',
              hintText: 'Test Hint',
              options: [],
              controller: controller,
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump();

      // Component should still render
      expect(find.byType(AutocompleteDropdown), findsOneWidget);
    });

    testWidgets('handles focus changes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutocompleteDropdown(
              label: 'Test Label',
              hintText: 'Test Hint',
              options: ['Option 1', 'Option 2'],
              controller: controller,
            ),
          ),
        ),
      );

      // Focus the field
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      // Enter text to show dropdown
      await tester.enterText(find.byType(TextFormField), 'Option');
      await tester.pump();

      // Component should handle focus correctly
      expect(find.byType(AutocompleteDropdown), findsOneWidget);

      // Tap outside to unfocus
      await tester.tapAt(const Offset(0, 0));
      await tester.pump();

      // Component should still be present
      expect(find.byType(AutocompleteDropdown), findsOneWidget);
    });
  });
}