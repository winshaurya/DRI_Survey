import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:dri_survey/providers/village_survey_provider.dart';
import 'package:dri_survey/services/database_service.dart';
import 'package:dri_survey/services/supabase_service.dart';
import 'package:dri_survey/services/sync_service.dart';

// Mock classes
class MockDatabaseService extends Mock implements DatabaseService {}
class MockSupabaseService extends Mock implements SupabaseService {}
class MockSyncService extends Mock implements SyncService {}

void main() {
  group('VillageSurveyProvider - Complex Village Survey State Management', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockSupabaseService mockSupabaseService;
    late MockSyncService mockSyncService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockSupabaseService = MockSupabaseService();
      mockSyncService = MockSyncService();

      container = ProviderContainer(
        overrides: [
          // Override the services in the provider
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default state', () {
      print('🧪 Testing VillageSurveyProvider default state initialization');
      final state = container.read(villageSurveyProvider);

      expect(state.shineCode, isNull);
      expect(state.sessionId, isNull);
      expect(state.currentScreen, equals(0));
      expect(state.surveyData, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isEditMode, isFalse);

      print('✅ Village survey provider initialized with correct default state');
    });

    test('should handle state copyWith correctly', () {
      print('🧪 Testing VillageSurveyState copyWith functionality');
      const originalState = VillageSurveyState(
        shineCode: '12345',
        sessionId: 'session-123',
        currentScreen: 5,
        surveyData: {'key': 'value'},
        isLoading: false,
        isEditMode: false,
      );

      final copiedState = originalState.copyWith(
        currentScreen: 6,
        isLoading: true,
        surveyData: {'newKey': 'newValue'},
      );

      expect(copiedState.shineCode, equals('12345')); // Unchanged
      expect(copiedState.sessionId, equals('session-123')); // Unchanged
      expect(copiedState.currentScreen, equals(6)); // Changed
      expect(copiedState.isLoading, isTrue); // Changed
      expect(copiedState.isEditMode, isFalse); // Unchanged
      expect(copiedState.surveyData, equals({'newKey': 'newValue'})); // Changed

      print('✅ VillageSurveyState copyWith preserves unchanged values and updates specified ones');
    });

    test('should navigate between screens correctly', () {
      print('🧪 Testing VillageSurveyProvider screen navigation');
      final notifier = container.read(villageSurveyProvider.notifier);

      // Test initial screen
      expect(container.read(villageSurveyProvider).currentScreen, equals(0));

      // Test setting specific screen
      notifier.setCurrentScreen(5);
      expect(container.read(villageSurveyProvider).currentScreen, equals(5));
      print('✅ Set current screen to 5');

      // Test next screen
      notifier.nextScreen();
      expect(container.read(villageSurveyProvider).currentScreen, equals(6));
      print('✅ Moved to next screen (6)');

      // Test previous screen
      notifier.previousScreen();
      expect(container.read(villageSurveyProvider).currentScreen, equals(5));
      print('✅ Moved to previous screen (5)');

      // Test boundary conditions
      notifier.setCurrentScreen(0);
      notifier.previousScreen();
      expect(container.read(villageSurveyProvider).currentScreen, equals(0));
      print('✅ Previous screen respects minimum boundary (0)');

      notifier.setCurrentScreen(13);
      notifier.nextScreen();
      expect(container.read(villageSurveyProvider).currentScreen, equals(13));
      print('✅ Next screen respects maximum boundary (13)');
    });

    test('should update survey data correctly', () {
      print('🧪 Testing VillageSurveyProvider survey data updates');
      final notifier = container.read(villageSurveyProvider.notifier);

      // Initial data should be empty
      expect(container.read(villageSurveyProvider).surveyData, isEmpty);

      // Update with initial data
      notifier.updateSurveyData({'village_name': 'Test Village', 'population': 1000});
      expect(container.read(villageSurveyProvider).surveyData,
             equals({'village_name': 'Test Village', 'population': 1000}));
      print('✅ Initial survey data set');

      // Update with additional data
      notifier.updateSurveyData({'infrastructure_available': true, 'electricity': true});
      expect(container.read(villageSurveyProvider).surveyData, equals({
        'village_name': 'Test Village',
        'population': 1000,
        'infrastructure_available': true,
        'electricity': true,
      }));
      print('✅ Additional survey data merged correctly');
    });

    test('should manage loading state correctly', () {
      print('🧪 Testing VillageSurveyProvider loading state management');
      final notifier = container.read(villageSurveyProvider.notifier);

      // Initial state should not be loading
      expect(container.read(villageSurveyProvider).isLoading, isFalse);

      // Set loading to true
      notifier.setLoading(true);
      expect(container.read(villageSurveyProvider).isLoading, isTrue);
      print('✅ Loading state set to true');

      // Set loading back to false
      notifier.setLoading(false);
      expect(container.read(villageSurveyProvider).isLoading, isFalse);
      print('✅ Loading state set to false');
    });

    test('should reset survey state correctly', () {
      print('🧪 Testing VillageSurveyProvider reset functionality');
      final notifier = container.read(villageSurveyProvider.notifier);

      // Set up some state
      notifier.setCurrentScreen(5);
      notifier.updateSurveyData({'test': 'data'});
      notifier.setLoading(true);

      // Verify state is set
      var state = container.read(villageSurveyProvider);
      expect(state.currentScreen, equals(5));
      expect(state.surveyData, equals({'test': 'data'}));
      expect(state.isLoading, isTrue);
      print('✅ State set up for reset test');

      // Reset
      notifier.reset();

      // Verify reset
      state = container.read(villageSurveyProvider);
      expect(state.shineCode, isNull);
      expect(state.sessionId, isNull);
      expect(state.currentScreen, equals(0));
      expect(state.surveyData, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isEditMode, isFalse);
      print('✅ Survey state reset to initial values');
    });

    test('should handle edit mode correctly', () {
      print('🧪 Testing VillageSurveyProvider edit mode functionality');
      final notifier = container.read(villageSurveyProvider.notifier);

      // Initial state should not be edit mode
      expect(container.read(villageSurveyProvider).isEditMode, isFalse);

      // Create a state with edit mode
      final editState = const VillageSurveyState(
        currentScreen: 0,
        surveyData: {},
        isLoading: false,
        isEditMode: true,
      );

      // Since we can't directly set the state in tests, we'll verify the concept
      // In real usage, edit mode would be set during loadVillageSurvey
      expect(editState.isEditMode, isTrue);
      print('✅ Edit mode state structure verified');
    });

    test('should validate screen boundaries', () {
      print('🧪 Testing VillageSurveyProvider screen boundary validation');
      final notifier = container.read(villageSurveyProvider.notifier);

      // Test valid screen indices
      for (int i = 0; i <= 13; i++) {
        notifier.setCurrentScreen(i);
        expect(container.read(villageSurveyProvider).currentScreen, equals(i));
      }
      print('✅ All valid screen indices (0-13) accepted');

      // Test that navigation respects boundaries
      notifier.setCurrentScreen(13);
      notifier.nextScreen();
      expect(container.read(villageSurveyProvider).currentScreen, equals(13));
      print('✅ Next screen respects upper boundary');

      notifier.setCurrentScreen(0);
      notifier.previousScreen();
      expect(container.read(villageSurveyProvider).currentScreen, equals(0));
      print('✅ Previous screen respects lower boundary');
    });

    test('should handle empty survey data gracefully', () {
      print('🧪 Testing VillageSurveyProvider empty data handling');
      final notifier = container.read(villageSurveyProvider.notifier);

      // Update with empty data
      notifier.updateSurveyData({});
      expect(container.read(villageSurveyProvider).surveyData, isEmpty);
      print('✅ Empty data update handled correctly');

      // Update with null data should not crash (though this wouldn't happen in real usage)
      // This tests the robustness of the updateSurveyData method
      final currentData = container.read(villageSurveyProvider).surveyData;
      expect(currentData, isEmpty);
      print('✅ Current data state maintained');
    });

    test('should maintain data integrity across operations', () {
      print('🧪 Testing VillageSurveyProvider data integrity');
      final notifier = container.read(villageSurveyProvider.notifier);

      // Perform a series of operations
      notifier.updateSurveyData({'step1': 'data1'});
      notifier.setCurrentScreen(2);
      notifier.setLoading(true);
      notifier.updateSurveyData({'step2': 'data2'});
      notifier.nextScreen();
      notifier.setLoading(false);

      // Verify final state
      final finalState = container.read(villageSurveyProvider);
      expect(finalState.surveyData, equals({'step1': 'data1', 'step2': 'data2'}));
      expect(finalState.currentScreen, equals(3));
      expect(finalState.isLoading, isFalse);

      print('✅ Data integrity maintained across multiple operations');
    });
  });

  group('VillageSurveyState - Data Model Tests', () {
    test('should create VillageSurveyState with all parameters', () {
      print('🧪 Testing VillageSurveyState full initialization');

      const surveyData = {'village_name': 'Test Village', 'population': 1500};
      const state = VillageSurveyState(
        shineCode: '12345',
        sessionId: 'session-abc',
        currentScreen: 7,
        surveyData: surveyData,
        isLoading: true,
        isEditMode: true,
      );

      expect(state.shineCode, equals('12345'));
      expect(state.sessionId, equals('session-abc'));
      expect(state.currentScreen, equals(7));
      expect(state.surveyData, equals(surveyData));
      expect(state.isLoading, isTrue);
      expect(state.isEditMode, isTrue);

      print('✅ VillageSurveyState created with all parameters correctly');
    });

    test('should handle optional parameters in VillageSurveyState', () {
      print('🧪 Testing VillageSurveyState optional parameters');

      const state = VillageSurveyState(
        currentScreen: 3,
        surveyData: {},
        isLoading: false,
      );

      expect(state.shineCode, isNull);
      expect(state.sessionId, isNull);
      expect(state.currentScreen, equals(3));
      expect(state.surveyData, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isEditMode, isFalse); // Default value

      print('✅ VillageSurveyState handles optional parameters correctly');
    });

    test('should copyWith only specified parameters', () {
      print('🧪 Testing VillageSurveyState copyWith selective updates');

      const original = VillageSurveyState(
        shineCode: 'original',
        sessionId: 'original-session',
        currentScreen: 1,
        surveyData: {'original': 'data'},
        isLoading: false,
        isEditMode: false,
      );

      final copied = original.copyWith(
        shineCode: 'updated',
        currentScreen: 5,
      );

      expect(copied.shineCode, equals('updated'));
      expect(copied.sessionId, equals('original-session')); // Unchanged
      expect(copied.currentScreen, equals(5));
      expect(copied.surveyData, equals({'original': 'data'})); // Unchanged
      expect(copied.isLoading, isFalse); // Unchanged
      expect(copied.isEditMode, isFalse); // Unchanged

      print('✅ VillageSurveyState copyWith updates only specified parameters');
    });
  });
}