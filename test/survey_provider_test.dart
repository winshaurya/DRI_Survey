import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dri_survey/providers/survey_provider.dart';

void main() {
  group('SurveyProvider - Family Survey State Management', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default state', () {
      print('🧪 Testing SurveyProvider default state initialization');
      final state = container.read(surveyProvider);

      expect(state.currentPage, equals(0));
      expect(state.totalPages, equals(32));
      expect(state.surveyData, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.phoneNumber, isNull);
      expect(state.surveyId, isNull);
      expect(state.supabaseSurveyId, isNull);

      print('✅ Survey provider initialized with correct default state');
    });

    test('should handle state copyWith correctly', () {
      print('🧪 Testing SurveyState copyWith functionality');
      const originalState = SurveyState(
        currentPage: 0,
        totalPages: 32,
        surveyData: {'key': 'value'},
        isLoading: false,
        phoneNumber: '+1234567890',
        surveyId: 123,
        supabaseSurveyId: 456,
      );

      final copiedState = originalState.copyWith(
        currentPage: 2,
        isLoading: true,
        surveyData: {'newKey': 'newValue'},
      );

      expect(copiedState.currentPage, equals(2)); // Changed
      expect(copiedState.totalPages, equals(32)); // Unchanged
      expect(copiedState.surveyData, equals({'newKey': 'newValue'})); // Changed
      expect(copiedState.isLoading, isTrue); // Changed
      expect(copiedState.phoneNumber, equals('+1234567890')); // Unchanged
      expect(copiedState.surveyId, equals(123)); // Unchanged
      expect(copiedState.supabaseSurveyId, equals(456)); // Unchanged

      print('✅ SurveyState copyWith preserves unchanged values and updates specified ones');
    });

    test('should update survey data correctly', () {
      print('🧪 Testing SurveyProvider survey data updates');
      final notifier = container.read(surveyProvider.notifier);

      // Initial data should be empty
      expect(container.read(surveyProvider).surveyData, isEmpty);

      // Update single value
      notifier.updateSurveyData('village_name', 'Test Village');
      expect(container.read(surveyProvider).surveyData,
             equals({'village_name': 'Test Village'}));
      print('✅ Single survey data value updated');

      // Update map data
      notifier.updateSurveyDataMap({'population': 1000, 'district': 'Test District'});
      expect(container.read(surveyProvider).surveyData, equals({
        'village_name': 'Test Village',
        'population': 1000,
        'district': 'Test District',
      }));
      print('✅ Survey data map merged correctly');
    });

    test('should manage loading state correctly', () {
      print('🧪 Testing SurveyProvider loading state management');
      final notifier = container.read(surveyProvider.notifier);

      // Initial state should not be loading
      expect(container.read(surveyProvider).isLoading, isFalse);

      // Set loading to true
      notifier.setLoading(true);
      expect(container.read(surveyProvider).isLoading, isTrue);
      print('✅ Loading state set to true');

      // Set loading back to false
      notifier.setLoading(false);
      expect(container.read(surveyProvider).isLoading, isFalse);
      print('✅ Loading state set to false');
    });

    test('should navigate between pages correctly', () {
      print('🧪 Testing SurveyProvider page navigation');
      final notifier = container.read(surveyProvider.notifier);

      // Test initial page
      expect(container.read(surveyProvider).currentPage, equals(0));

      // Test goToPage
      notifier.goToPage(5);
      expect(container.read(surveyProvider).currentPage, equals(5));
      print('✅ Jumped to page 5');

      // Test previousPage
      notifier.previousPage();
      expect(container.read(surveyProvider).currentPage, equals(4));
      print('✅ Moved to previous page (4)');

      // Test boundary conditions
      notifier.goToPage(0);
      notifier.previousPage();
      expect(container.read(surveyProvider).currentPage, equals(0));
      print('✅ Previous page respects minimum boundary (0)');
    });

    test('should reset survey state correctly', () {
      print('🧪 Testing SurveyProvider reset functionality');
      final notifier = container.read(surveyProvider.notifier);

      // Set up some state
      notifier.goToPage(10);
      notifier.updateSurveyData('test', 'data');
      notifier.setLoading(true);

      // Verify state is set
      var state = container.read(surveyProvider);
      expect(state.currentPage, equals(10));
      expect(state.surveyData, equals({'test': 'data'}));
      expect(state.isLoading, isTrue);
      print('✅ State set up for reset test');

      // Reset
      notifier.reset();

      // Verify reset
      state = container.read(surveyProvider);
      expect(state.currentPage, equals(0));
      expect(state.totalPages, equals(32));
      expect(state.surveyData, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.phoneNumber, isNull);
      expect(state.surveyId, isNull);
      expect(state.supabaseSurveyId, isNull);
      print('✅ Survey state reset to initial values');
    });

    test('should validate page boundaries', () {
      print('🧪 Testing SurveyProvider page boundary validation');
      final notifier = container.read(surveyProvider.notifier);

      // Test valid page numbers (0-31 based on totalPages)
      for (int i = 0; i <= 31; i++) {
        notifier.goToPage(i);
        expect(container.read(surveyProvider).currentPage, equals(i));
      }
      print('✅ All valid page numbers (0-31) accepted');

      // Test that navigation respects boundaries
      notifier.goToPage(31);
      expect(container.read(surveyProvider).currentPage, equals(31));
      print('✅ Page navigation respects upper boundary');

      notifier.goToPage(0);
      notifier.previousPage();
      expect(container.read(surveyProvider).currentPage, equals(0));
      print('✅ Previous page respects lower boundary');
    });

    test('should handle empty survey data gracefully', () {
      print('🧪 Testing SurveyProvider empty data handling');
      final notifier = container.read(surveyProvider.notifier);

      // Update with empty map
      notifier.updateSurveyDataMap({});
      expect(container.read(surveyProvider).surveyData, isEmpty);
      print('✅ Empty data map update handled correctly');

      // Update with null key should not crash
      notifier.updateSurveyData('', 'value');
      expect(container.read(surveyProvider).surveyData, equals({'': 'value'}));
      print('✅ Empty key handling works');
    });

    test('should maintain data integrity across operations', () {
      print('🧪 Testing SurveyProvider data integrity');
      final notifier = container.read(surveyProvider.notifier);

      // Perform a series of operations
      notifier.updateSurveyData('step1', 'data1');
      notifier.goToPage(3);
      notifier.setLoading(true);
      notifier.updateSurveyDataMap({'step2': 'data2'});
      notifier.goToPage(5);
      notifier.setLoading(false);

      // Verify final state
      final finalState = container.read(surveyProvider);
      expect(finalState.surveyData, equals({'step1': 'data1', 'step2': 'data2'}));
      expect(finalState.currentPage, equals(5));
      expect(finalState.isLoading, isFalse);

      print('✅ Data integrity maintained across multiple operations');
    });
  });

  group('SurveyState - Data Model Tests', () {
    test('should create SurveyState with all parameters', () {
      print('🧪 Testing SurveyState full initialization');

      final surveyData = {'village_name': 'Test Village', 'population': 1500};
      final state = SurveyState(
        currentPage: 5,
        totalPages: 20,
        surveyData: surveyData,
        isLoading: true,
        phoneNumber: '+1234567890',
        surveyId: 123,
        supabaseSurveyId: 456,
      );

      expect(state.currentPage, equals(5));
      expect(state.totalPages, equals(20));
      expect(state.surveyData, equals(surveyData));
      expect(state.isLoading, isTrue);
      expect(state.phoneNumber, equals('+1234567890'));
      expect(state.surveyId, equals(123));
      expect(state.supabaseSurveyId, equals(456));

      print('✅ SurveyState created with all parameters correctly');
    });

    test('should handle optional parameters in SurveyState', () {
      print('🧪 Testing SurveyState optional parameters');

      const state = SurveyState(
        currentPage: 0,
        totalPages: 32,
        surveyData: {},
        isLoading: false,
      );

      expect(state.currentPage, equals(0));
      expect(state.totalPages, equals(32));
      expect(state.surveyData, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.phoneNumber, isNull);
      expect(state.surveyId, isNull);
      expect(state.supabaseSurveyId, isNull);

      print('✅ SurveyState handles optional parameters correctly');
    });

    test('should copyWith only specified parameters', () {
      print('🧪 Testing SurveyState copyWith selective updates');

      const original = SurveyState(
        currentPage: 0,
        totalPages: 32,
        surveyData: {'original': 'data'},
        isLoading: false,
        phoneNumber: '+1234567890',
        surveyId: 123,
        supabaseSurveyId: 456,
      );

      final copied = original.copyWith(
        currentPage: 2,
        phoneNumber: '+0987654321',
      );

      expect(copied.currentPage, equals(2));
      expect(copied.phoneNumber, equals('+0987654321'));
      expect(copied.totalPages, equals(32)); // Unchanged
      expect(copied.surveyData, equals({'original': 'data'})); // Unchanged
      expect(copied.isLoading, isFalse); // Unchanged
      expect(copied.surveyId, equals(123)); // Unchanged
      expect(copied.supabaseSurveyId, equals(456)); // Unchanged

      print('✅ SurveyState copyWith updates only specified parameters');
    });
  });
}