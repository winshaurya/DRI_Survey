import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dri_survey/providers/font_size_provider.dart';

void main() {
  group('FontSizeProvider - Font Scaling Management', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default font scale', () {
      print('🧪 Testing FontSizeProvider default initialization');
      final fontSize = container.read(fontSizeProvider);
      expect(fontSize, equals(0.7));
      print('✅ Default font scale is 0.7 (30% smaller)');
    });

    test('should allow setting custom font scale within valid range', () {
      print('🧪 Testing FontSizeProvider custom scale setting');
      final notifier = container.read(fontSizeProvider.notifier);

      // Test setting valid scale
      notifier.setFontSize(1.0);
      expect(container.read(fontSizeProvider), equals(1.0));
      print('✅ Font scale set to 1.0 (normal size)');

      // Test setting larger scale
      notifier.setFontSize(1.2);
      expect(container.read(fontSizeProvider), equals(1.2));
      print('✅ Font scale set to 1.2 (20% larger)');

      // Test setting smaller scale
      notifier.setFontSize(0.8);
      expect(container.read(fontSizeProvider), equals(0.8));
      print('✅ Font scale set to 0.8 (20% smaller)');
    });

    test('should clamp font scale to valid range', () {
      print('🧪 Testing FontSizeProvider scale clamping');
      final notifier = container.read(fontSizeProvider.notifier);

      // Test minimum clamp
      notifier.setFontSize(0.3); // Below minimum
      expect(container.read(fontSizeProvider), equals(0.5));
      print('✅ Font scale clamped to minimum 0.5');

      // Test maximum clamp
      notifier.setFontSize(2.0); // Above maximum
      expect(container.read(fontSizeProvider), equals(1.5));
      print('✅ Font scale clamped to maximum 1.5');
    });

    test('should reset to default font scale', () {
      print('🧪 Testing FontSizeProvider reset functionality');
      final notifier = container.read(fontSizeProvider.notifier);

      // Change scale first
      notifier.setFontSize(1.3);
      expect(container.read(fontSizeProvider), equals(1.3));
      print('✅ Font scale changed to 1.3');

      // Reset to default
      notifier.resetToDefault();
      expect(container.read(fontSizeProvider), equals(0.7));
      print('✅ Font scale reset to default 0.7');
    });

    test('should maintain state across multiple operations', () {
      print('🧪 Testing FontSizeProvider state persistence');
      final notifier = container.read(fontSizeProvider.notifier);

      // Perform multiple operations
      notifier.setFontSize(1.1);
      expect(container.read(fontSizeProvider), equals(1.1));

      notifier.setFontSize(0.9);
      expect(container.read(fontSizeProvider), equals(0.9));

      notifier.resetToDefault();
      expect(container.read(fontSizeProvider), equals(0.7));

      print('✅ Font scale state maintained correctly through multiple operations');
    });
  });

  group('FontSizeExtension - TextStyle Scaling', () {
    test('should scale TextStyle fontSize correctly', () {
      print('🧪 Testing FontSizeExtension TextStyle scaling');

      const baseStyle = TextStyle(fontSize: 16.0, color: null);

      // Test scaling up
      final scaledUp = baseStyle.scaled(1.25);
      expect(scaledUp.fontSize, equals(20.0));
      print('✅ TextStyle scaled up from 16.0 to 20.0 (1.25x)');

      // Test scaling down
      final scaledDown = baseStyle.scaled(0.75);
      expect(scaledDown.fontSize, equals(12.0));
      print('✅ TextStyle scaled down from 16.0 to 12.0 (0.75x)');

      // Test with null fontSize (should use default 14)
      const nullSizeStyle = TextStyle(color: null);
      final scaledNull = nullSizeStyle.scaled(1.5);
      expect(scaledNull.fontSize, equals(21.0));
      print('✅ TextStyle with null fontSize scaled from 14.0 to 21.0 (1.5x)');
    });

    test('should preserve other TextStyle properties when scaling', () {
      print('🧪 Testing FontSizeExtension property preservation');

      const originalStyle = TextStyle(
        fontSize: 18.0,
        color: null,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        letterSpacing: 1.0,
      );

      final scaledStyle = originalStyle.scaled(1.2);

      expect(scaledStyle.fontSize, equals(21.6));
      expect(scaledStyle.fontWeight, equals(FontWeight.bold));
      expect(scaledStyle.fontStyle, equals(FontStyle.italic));
      expect(scaledStyle.letterSpacing, equals(1.0));
      expect(scaledStyle.color, isNull);

      print('✅ All TextStyle properties preserved during scaling');
    });
  });
}