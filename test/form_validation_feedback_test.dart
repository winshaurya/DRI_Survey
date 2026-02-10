import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dri_survey/components/form_validation_feedback.dart';

void main() {
  group('FormValidationFeedback Widget Tests', () {
    testWidgets('renders nothing when state is none', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FormValidationFeedback(
              state: ValidationState.none,
              message: 'Test message',
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Test message'), findsNothing);
    });

    testWidgets('renders nothing when message is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FormValidationFeedback(
              state: ValidationState.error,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byIcon(Icons.error), findsNothing);
    });

    testWidgets('renders success state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FormValidationFeedback(
              state: ValidationState.success,
              message: 'Success message',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Success message'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('renders warning state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FormValidationFeedback(
              state: ValidationState.warning,
              message: 'Warning message',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Warning message'), findsOneWidget);
    });

    testWidgets('renders error state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FormValidationFeedback(
              state: ValidationState.error,
              message: 'Error message',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('uses custom icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FormValidationFeedback(
              state: ValidationState.success,
              message: 'Success message',
              icon: Icons.thumb_up,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('applies correct colors for success state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FormValidationFeedback(
              state: ValidationState.success,
              message: 'Success message',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.green.shade50);
      expect((decoration.border! as Border).top.color, Colors.green.shade200);
    });

    testWidgets('applies correct colors for error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FormValidationFeedback(
              state: ValidationState.error,
              message: 'Error message',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red.shade50);
      expect((decoration.border! as Border).top.color, Colors.red.shade200);
    });

    testWidgets('applies correct colors for warning state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FormValidationFeedback(
              state: ValidationState.warning,
              message: 'Warning message',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.orange.shade50);
      expect((decoration.border! as Border).top.color, Colors.orange.shade200);
    });

    testWidgets('shows animation by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FormValidationFeedback(
              state: ValidationState.success,
              message: 'Success message',
            ),
          ),
        ),
      );

      // Should use FadeInUp animation
      expect(find.byType(FadeInUp), findsOneWidget);
    });

    testWidgets('skips animation when showAnimation is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FormValidationFeedback(
              state: ValidationState.success,
              message: 'Success message',
              showAnimation: false,
            ),
          ),
        ),
      );

      expect(find.byType(FadeInUp), findsNothing);
      expect(find.byType(Container), findsOneWidget);
    });
  });

  group('ValidatedTextField Widget Tests', () {
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
            body: ValidatedTextField(
              controller: controller,
              labelText: 'Test Field',
            ),
          ),
        ),
      );

      expect(find.text('Test Field'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows validation error on focus loss', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              labelText: 'Email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) {
                  return 'Invalid email format';
                }
                return null;
              },
            ),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextField), 'invalid-email');
      await tester.pump();

      // Lose focus
      await tester.tapAt(const Offset(0, 0));
      await tester.pump();

      expect(find.text('Invalid email format'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows success state for valid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              labelText: 'Email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) {
                  return 'Invalid email format';
                }
                return null;
              },
            ),
          ),
        ),
      );

      // Enter valid email
      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump();

      // Lose focus
      await tester.tapAt(const Offset(0, 0));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byType(FormValidationFeedback), findsOneWidget);
    });

    testWidgets('calls onChanged callback', (WidgetTester tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              labelText: 'Test Field',
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test input');
      expect(changedValue, 'test input');
    });

    testWidgets('respects maxLength', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              labelText: 'Test Field',
              maxLength: 5,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '123456789');
      expect(controller.text, '12345'); // Should be truncated to maxLength
    });

    testWidgets('handles obscureText', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              labelText: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, true);
    });

    testWidgets('respects enabled property', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              labelText: 'Test Field',
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('handles maxLines', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              labelText: 'Test Field',
              maxLines: 3,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 3);
    });

    testWidgets('shows prefix and suffix icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              labelText: 'Test Field',
              prefixIcon: const Icon(Icons.email),
              suffixIcon: const Icon(Icons.clear),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('shows validation icons in suffix when validation occurs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              labelText: 'Email',
              suffixIcon: const Icon(Icons.clear),
              validator: (value) {
                if (value != null && value.contains('@')) {
                  return null;
                }
                return 'Invalid email';
              },
            ),
          ),
        ),
      );

      // Enter valid email
      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump();

      // Lose focus to trigger validation
      await tester.tapAt(const Offset(0, 0));
      await tester.pump();

      // Should show check_circle instead of the original suffix icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('changes border color based on validation state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              labelText: 'Email',
              validator: (value) {
                if (value != null && value.contains('@')) {
                  return null;
                }
                return 'Invalid email';
              },
            ),
          ),
        ),
      );

      // Initially no validation state
      var textField = tester.widget<TextField>(find.byType(TextField));
      var decoration = textField.decoration!;
      expect(decoration.focusedBorder, isNotNull);

      // Enter invalid email and lose focus
      await tester.enterText(find.byType(TextField), 'invalid');
      await tester.tapAt(const Offset(0, 0));
      await tester.pump();

      // Border should be red for error state
      textField = tester.widget<TextField>(find.byType(TextField));
      decoration = textField.decoration!;
      final focusedBorder = decoration.focusedBorder as OutlineInputBorder;
      expect(focusedBorder.borderSide.color, Colors.red);
    });
  });
}