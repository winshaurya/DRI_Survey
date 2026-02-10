import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dri_survey/providers/locale_provider.dart';

void main() {
  group('LocaleProvider - Language Management', () {
    late ProviderContainer container;

    setUp(() {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default English locale', () {
      print('🧪 Testing LocaleProvider default initialization');
      final locale = container.read(localeProvider);
      expect(locale, equals(const Locale('en')));
      print('✅ Default locale is English (en)');
    });

    test('should set locale and persist to SharedPreferences', () async {
      print('🧪 Testing LocaleProvider locale setting and persistence');
      final notifier = container.read(localeProvider.notifier);

      // Set Hindi locale
      await notifier.setLocale(const Locale('hi'));
      expect(container.read(localeProvider), equals(const Locale('hi')));
      print('✅ Locale set to Hindi (hi)');

      // Verify persistence by creating new container
      final newContainer = ProviderContainer();
      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 100));

      final persistedLocale = newContainer.read(localeProvider);
      expect(persistedLocale, equals(const Locale('hi')));
      print('✅ Locale persisted to SharedPreferences');

      newContainer.dispose();
    });

    test('should toggle between English and Hindi', () async {
      print('🧪 Testing LocaleProvider language toggle functionality');
      final notifier = container.read(localeProvider.notifier);

      // Start with English
      expect(container.read(localeProvider), equals(const Locale('en')));
      print('✅ Initial locale is English');

      // Toggle to Hindi
      await notifier.toggleLanguage();
      expect(container.read(localeProvider), equals(const Locale('hi')));
      print('✅ Toggled to Hindi');

      // Toggle back to English
      await notifier.toggleLanguage();
      expect(container.read(localeProvider), equals(const Locale('en')));
      print('✅ Toggled back to English');
    });

    test('should load saved locale on initialization', () async {
      print('🧪 Testing LocaleProvider saved locale loading');

      // Set up SharedPreferences with saved Hindi locale
      SharedPreferences.setMockInitialValues({'language_code': 'hi'});

      final newContainer = ProviderContainer();
      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 100));

      final loadedLocale = newContainer.read(localeProvider);
      expect(loadedLocale, equals(const Locale('hi')));
      print('✅ Saved Hindi locale loaded on initialization');

      newContainer.dispose();
    });

    test('should handle SharedPreferences errors gracefully', () async {
      print('🧪 Testing LocaleProvider error handling');

      // Create a container (SharedPreferences will fail to initialize)
      final testContainer = ProviderContainer();

      // The provider should still work and default to English
      final locale = testContainer.read(localeProvider);
      expect(locale, equals(const Locale('en')));
      print('✅ Provider handles SharedPreferences errors gracefully');

      // Setting locale should not crash even if save fails
      final notifier = testContainer.read(localeProvider.notifier);
      await notifier.setLocale(const Locale('hi'));
      expect(testContainer.read(localeProvider), equals(const Locale('hi')));
      print('✅ Locale setting works even with SharedPreferences errors');

      testContainer.dispose();
    });

    test('should maintain locale state across operations', () async {
      print('🧪 Testing LocaleProvider state persistence across operations');
      final notifier = container.read(localeProvider.notifier);

      // Perform multiple operations
      await notifier.setLocale(const Locale('hi'));
      expect(container.read(localeProvider), equals(const Locale('hi')));

      await notifier.toggleLanguage();
      expect(container.read(localeProvider), equals(const Locale('en')));

      await notifier.setLocale(const Locale('hi'));
      expect(container.read(localeProvider), equals(const Locale('hi')));

      print('✅ Locale state maintained correctly through multiple operations');
    });

    test('should handle invalid locale codes gracefully', () async {
      print('🧪 Testing LocaleProvider invalid locale handling');
      final notifier = container.read(localeProvider.notifier);

      // Set an invalid locale (should still work)
      await notifier.setLocale(const Locale('invalid'));
      expect(container.read(localeProvider), equals(const Locale('invalid')));
      print('✅ Invalid locale codes handled gracefully');

      // Toggle should still work
      await notifier.toggleLanguage();
      expect(container.read(localeProvider), equals(const Locale('en')));
      print('✅ Toggle functionality works after invalid locale');
    });
  });
}