import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dri_survey/components/logo_widget.dart';

void main() {
  group('LogoWidget Widget Tests', () {
    testWidgets('renders with default size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LogoWidget(),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('applies custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LogoWidget(size: 100),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 100);
      expect(container.constraints?.maxHeight, 100);
    });

    testWidgets('loads logo image from assets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LogoWidget(),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      final assetImage = image.image as AssetImage;
      expect(assetImage.assetName, 'assets/images/logo.png');
    });

    testWidgets('uses BoxFit.contain for image', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LogoWidget(),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.contain);
    });

    testWidgets('applies correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LogoWidget(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, Colors.white);
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
    });
  });

  group('LogoWithCircle Widget Tests', () {
    testWidgets('renders with default size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LogoWithCircle(),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('applies custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LogoWithCircle(size: 120),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 120);
      expect(container.constraints?.maxHeight, 120);
    });

    testWidgets('uses circular shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LogoWithCircle(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.shape, BoxShape.circle);
      expect(decoration.border, isNotNull);
    });

    testWidgets('loads logo image from assets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LogoWithCircle(),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      final assetImage = image.image as AssetImage;
      expect(assetImage.assetName, 'assets/images/logo.png');
    });
  });

  group('AppHeader Widget Tests', () {
    testWidgets('renders app header with logo and title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const AppHeader(),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.text('Deendayal Research Institute'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byType(LogoWidget), findsOneWidget);
    });

    testWidgets('uses correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const AppHeader(),
            body: const SizedBox(),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Deendayal Research Institute'));
      expect(text.style?.color, const Color(0xFF2E7D32));

      final icon = tester.widget<Icon>(find.byIcon(Icons.menu));
      expect(icon.color, const Color(0xFF2E7D32));
    });

    testWidgets('opens drawer when menu button is tapped', (WidgetTester tester) async {
      bool drawerOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const AppHeader(),
            drawer: Drawer(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    drawerOpened = true;
                    Navigator.pop(context);
                  },
                  child: const Text('Test Button'),
                ),
              ),
            ),
            body: const SizedBox(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Drawer should be open
      expect(find.text('Test Button'), findsOneWidget);

      // Tap the test button to close drawer and set flag
      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();

      expect(drawerOpened, true);
    });
  });

  group('VillageAppHeader Widget Tests', () {
    testWidgets('renders village app header with logo and title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const VillageAppHeader(),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.text('Deendayal Research Institute'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byType(LogoWidget), findsOneWidget);
    });

    testWidgets('uses purple color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const VillageAppHeader(),
            body: const SizedBox(),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Deendayal Research Institute'));
      expect(text.style?.color, const Color(0xFF800080));

      final icon = tester.widget<Icon>(find.byIcon(Icons.menu));
      expect(icon.color, const Color(0xFF800080));
    });

    testWidgets('opens drawer when menu button is tapped', (WidgetTester tester) async {
      bool drawerOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const VillageAppHeader(),
            drawer: Drawer(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    drawerOpened = true;
                    Navigator.pop(context);
                  },
                  child: const Text('Test Button'),
                ),
              ),
            ),
            body: const SizedBox(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Drawer should be open
      expect(find.text('Test Button'), findsOneWidget);

      // Tap the test button to close drawer and set flag
      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();

      expect(drawerOpened, true);
    });
  });
}