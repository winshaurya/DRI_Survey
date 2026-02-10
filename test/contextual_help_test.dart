import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dri_survey/components/contextual_help.dart';
import 'package:dri_survey/l10n/app_localizations.dart';

void main() {
  group('ContextualHelp Widget Tests', () {
    late AppLocalizations l10n;

    setUp(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    testWidgets('does not show tooltip when showHelp is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ContextualHelp(
              title: 'Test Title',
              message: 'Test Message',
              showHelp: false,
              child: const Text('Child Widget'),
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsNothing);
      expect(find.text('Test Message'), findsNothing);
    });

    testWidgets('shows tooltip when showHelp is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ContextualHelp(
              title: 'Test Title',
              message: 'Test Message',
              showHelp: true,
              child: const Text('Child Widget'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ContextualHelp(
              title: 'Test Title',
              message: 'Test Message',
              showHelp: false,
              child: const Text('Child Widget'),
            ),
          ),
        ),
      );

      expect(find.text('Child Widget'), findsOneWidget);
    });

    testWidgets('dismisses tooltip when tapped outside', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ContextualHelp(
              title: 'Test Title',
              message: 'Test Message',
              showHelp: true,
              child: const Text('Child Widget'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test Title'), findsOneWidget);

      // Tap outside the tooltip
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsNothing);
    });

    testWidgets('calls onDismiss callback when tooltip is dismissed', (WidgetTester tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ContextualHelp(
              title: 'Test Title',
              message: 'Test Message',
              showHelp: true,
              onDismiss: () => dismissed = true,
              child: const Text('Child Widget'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the "Got it" button
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(dismissed, true);
    });

    testWidgets('auto-hides after specified duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ContextualHelp(
              title: 'Test Title',
              message: 'Test Message',
              showHelp: true,
              autoHideDuration: const Duration(milliseconds: 100),
              child: const Text('Child Widget'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test Title'), findsOneWidget);

      // Wait for auto-hide duration
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Test Title'), findsNothing);
    });

    testWidgets('updates when showHelp changes', (WidgetTester tester) async {
      bool showHelp = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => showHelp = !showHelp),
                    child: const Text('Toggle Help'),
                  ),
                  ContextualHelp(
                    title: 'Test Title',
                    message: 'Test Message',
                    showHelp: showHelp,
                    child: const Text('Child Widget'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsNothing);

      // Show help
      await tester.tap(find.text('Toggle Help'));
      await tester.pumpAndSettle();
      expect(find.text('Test Title'), findsOneWidget);

      // Hide help
      await tester.tap(find.text('Toggle Help'));
      await tester.pumpAndSettle();
      expect(find.text('Test Title'), findsNothing);
    });
  });

  group('ExpandableHelp Widget Tests', () {
    testWidgets('renders summary text initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const ExpandableHelp(
              summary: 'Summary Text',
              details: 'Detailed explanation here',
            ),
          ),
        ),
      );

      expect(find.text('Summary Text'), findsOneWidget);
      expect(find.text('Detailed explanation here'), findsNothing);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('expands to show details when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const ExpandableHelp(
              summary: 'Summary Text',
              details: 'Detailed explanation here',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Summary Text'));
      await tester.pump();

      expect(find.text('Summary Text'), findsOneWidget);
      expect(find.text('Detailed explanation here'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });

    testWidgets('uses custom icon and color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const ExpandableHelp(
              summary: 'Summary Text',
              details: 'Detailed explanation here',
              icon: Icons.info,
              color: Colors.red,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
      // The color would be verified by checking the widget's properties in a more complex test
    });
  });

  group('FloatingHelpButton Widget Tests', () {
    testWidgets('renders with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FloatingHelpButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FloatingHelpButton(
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      expect(pressed, true);
    });

    testWidgets('uses custom tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FloatingHelpButton(
              onPressed: () {},
              tooltip: 'Custom Help',
            ),
          ),
        ),
      );

      // Tooltip can be verified by checking the FloatingActionButton's tooltip property
      final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(fab.tooltip, 'Custom Help');
    });
  });

  group('SurveyProgressWithHelp Widget Tests', () {
    testWidgets('renders progress indicator and help text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: const SurveyProgressWithHelp(
              currentStep: 2,
              totalSteps: 5,
              currentStepHelp: 'This is step 2 help',
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('This is step 2 help'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('calculates progress correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: const SurveyProgressWithHelp(
              currentStep: 3,
              totalSteps: 10,
              currentStepHelp: 'Help text',
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, 0.3); // 3/10 = 0.3
    });
  });
}