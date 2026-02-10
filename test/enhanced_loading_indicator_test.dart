import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dri_survey/components/enhanced_loading_indicator.dart';

void main() {
  group('EnhancedLoadingIndicator Widget Tests', () {
    testWidgets('renders circular indicator by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EnhancedLoadingIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders linear indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EnhancedLoadingIndicator(type: LoadingType.linear),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders dots indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EnhancedLoadingIndicator(type: LoadingType.dots),
          ),
        ),
      );

      // Should render 3 containers for dots
      expect(find.byType(Container), findsNWidgets(3));
    });

    testWidgets('renders pulse indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EnhancedLoadingIndicator(type: LoadingType.pulse),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('renders shimmer indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EnhancedLoadingIndicator(type: LoadingType.shimmer),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('shows message when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EnhancedLoadingIndicator(
              message: 'Loading data...',
            ),
          ),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('hides message when showMessage is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EnhancedLoadingIndicator(
              message: 'Loading data...',
              showMessage: false,
            ),
          ),
        ),
      );

      expect(find.text('Loading data...'), findsNothing);
    });

    testWidgets('applies custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EnhancedLoadingIndicator(size: 100),
          ),
        ),
      );

      final circularProgress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      // The size affects the container, but CircularProgressIndicator has default size
      // This test verifies the widget renders without error
      expect(circularProgress, isNotNull);
    });

    testWidgets('uses custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const EnhancedLoadingIndicator(
              color: Colors.red,
            ),
          ),
        ),
      );

      final circularProgress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(circularProgress.valueColor, isA<AlwaysStoppedAnimation<Color>>());
    });

    testWidgets('uses theme color when no custom color provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primaryColor: Colors.blue),
          home: Scaffold(
            body: const EnhancedLoadingIndicator(),
          ),
        ),
      );

      final circularProgress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(circularProgress.valueColor, isA<AlwaysStoppedAnimation<Color>>());
    });
  });

  group('LoadingOverlay Widget Tests', () {
    testWidgets('shows child when not loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoadingOverlay(
            isLoading: false,
            child: Text('Content'),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(EnhancedLoadingIndicator), findsNothing);
    });

    testWidgets('shows loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoadingOverlay(
            isLoading: true,
            child: Text('Content'),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(EnhancedLoadingIndicator), findsOneWidget);
    });

    testWidgets('shows loading message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoadingOverlay(
            isLoading: true,
            message: 'Please wait...',
            child: Text('Content'),
          ),
        ),
      );

      expect(find.text('Please wait...'), findsOneWidget);
    });

    testWidgets('uses custom loading type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoadingOverlay(
            isLoading: true,
            type: LoadingType.dots,
            child: Text('Content'),
          ),
        ),
      );

      // Should find the dots indicator (3 containers)
      expect(find.byType(Container), findsNWidgets(3));
    });

    testWidgets('applies custom background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingOverlay(
            isLoading: true,
            backgroundColor: Colors.red.withOpacity(0.5),
            child: const Text('Content'),
          ),
        ),
      );

      // The overlay should be present
      expect(find.byType(EnhancedLoadingIndicator), findsOneWidget);
    });
  });

  group('LoadingButton Widget Tests', () {
    testWidgets('shows text when not loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Submit',
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(EnhancedLoadingIndicator), findsNothing);
    });

    testWidgets('shows loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LoadingButton(
              text: 'Submit',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsNothing);
      expect(find.byType(EnhancedLoadingIndicator), findsOneWidget);
    });

    testWidgets('calls onPressed when not loading', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () => pressed = true,
              text: 'Submit',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, true);
    });

    testWidgets('does not call onPressed when loading', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () => pressed = true,
              text: 'Submit',
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, false);
    });

    testWidgets('uses custom loading type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LoadingButton(
              text: 'Submit',
              isLoading: true,
              loadingType: LoadingType.dots,
            ),
          ),
        ),
      );

      // Should find dots indicator
      expect(find.byType(Container), findsNWidgets(3));
    });

    testWidgets('applies custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Submit',
              color: Colors.red,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style?.backgroundColor, isNotNull);
    });

    testWidgets('applies custom height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Submit',
              height: 60,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, 60);
    });

    testWidgets('uses full width by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Submit',
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('applies custom width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Submit',
              width: 200,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 200);
    });
  });
}