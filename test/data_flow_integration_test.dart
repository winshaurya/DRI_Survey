import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dri_survey/services/database_service.dart';
import 'package:dri_survey/services/supabase_service.dart';
import 'package:dri_survey/services/sync_service.dart';
import 'package:dri_survey/services/file_upload_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Mock SupabaseService for testing
class MockSupabaseService {
  final List<Map<String, dynamic>> syncedFamilySurveys = [];
  final List<Map<String, dynamic>> syncedVillageSurveys = [];
  final List<Map<String, dynamic>> syncedFamilyPages = [];
  final List<Map<String, dynamic>> syncedVillagePages = [];

  Future<bool> syncFamilySurveyToSupabaseWithTracking(
    String phoneNumber,
    Map<String, dynamic> surveyData,
    Map<String, dynamic> trackingMap,
  ) async {
    syncedFamilySurveys.add({
      'phone_number': phoneNumber,
      'survey_data': surveyData,
      'tracking_map': trackingMap,
    });
    return true;
  }

  Future<void> syncFamilyPageToSupabase(String phoneNumber, int page, Map<String, dynamic> data) async {
    syncedFamilyPages.add({
      'phone_number': phoneNumber,
      'page': page,
      'data': data,
    });
  }

  Future<void> syncVillageSurveyToSupabase(String sessionId, Map<String, dynamic> data) async {
    syncedVillageSurveys.add({
      'session_id': sessionId,
      'data': data,
    });
  }

  Future<void> syncVillagePageToSupabase(String sessionId, int page, Map<String, dynamic> data) async {
    syncedVillagePages.add({
      'session_id': sessionId,
      'page': page,
      'data': data,
    });
  }
}

// Mock FileUploadService for testing
class MockFileUploadService {
  final List<String> processedUploads = [];

  Future<void> processPendingUploads() async {
    processedUploads.add('processed');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  late MockSupabaseService mockSupabaseService;
  late MockFileUploadService mockFileUploadService;
  late SyncService syncService;

  setUpAll(() async {
    // Initialize FFI for desktop testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Try to load environment variables for testing, but don't fail if .env doesn't exist
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // .env file may not exist in test environment, which is expected
      print('⚠️  .env file not found in test environment, using default values');
    }

    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});

    // Create mock services
    mockSupabaseService = MockSupabaseService();
    mockFileUploadService = MockFileUploadService();
  });

  setUp(() async {
    // Create a fresh database service for each test
    databaseService = DatabaseService();

    // Use the singleton SyncService instance
    syncService = SyncService.instance;
  });

  tearDown(() async {
    // Clean up database after each test
    await databaseService.close();
  });

  group('Complete Data Flow Integration Tests - Local Save → Sync → Supabase', () {
    test('Family Survey: Complete data flow from local save to Supabase sync', () async {
      print('🚀 Testing complete family survey data flow: Local Save → Sync → Supabase');

      // Step 1: Save survey data locally
      print('📝 Step 1: Saving family survey data locally');
      const phoneNumber = '+1234567890';
      final surveyData = {
        'phone_number': phoneNumber,
        'village_name': 'Test Village',
        'created_at': DateTime.now().toIso8601String(),
      };

      final surveyId = await databaseService.createNewSurveyRecord(surveyData);
      expect(surveyId, isNotNull);
      expect(surveyId, greaterThan(0));
      print('✅ Survey saved locally with ID: $surveyId');

      // Step 2: Add survey page data
      print('📝 Step 2: Adding family survey page data');
      final pageData = {
        'family_members': 4,
        'income_source': 'agriculture',
        'house_type': 'pucca',
      };

      await databaseService.saveData('family_survey_responses', {
        'phone_number': phoneNumber,
        'page_number': 1,
        'data': pageData,
      });

      // Mark page as completed
      await databaseService.markFamilyPageCompleted(phoneNumber, 1);
      print('✅ Family survey page data saved and marked as completed');

      // Step 3: Verify data is stored locally with correct sync status
      print('🔍 Step 3: Verifying local data storage and sync status');
      final storedSurvey = await databaseService.getSurveySession(phoneNumber);
      expect(storedSurvey, isNotNull);
      expect(storedSurvey!['phone_number'], equals(phoneNumber));
      expect(storedSurvey['status'], equals('incomplete'));
      expect(storedSurvey['sync_status'], equals('pending'));
      print('✅ Local survey data verified with pending sync status');

      // Step 4: Get unsynced surveys (simulate what sync service does)
      print('🔍 Step 4: Retrieving unsynced surveys');
      final unsyncedSurveys = await databaseService.getUnsyncedFamilySurveys();
      expect(unsyncedSurveys.length, greaterThan(0));
      final unsyncedSurvey = unsyncedSurveys.firstWhere(
        (s) => s['phone_number'] == phoneNumber,
        orElse: () => {},
      );
      expect(unsyncedSurvey.isNotEmpty, isTrue);
      print('✅ Found unsynced survey in local database');

      // Step 5: Simulate sync to Supabase (using mock service)
      print('🔄 Step 5: Simulating sync to Supabase');
      final syncSuccess = await mockSupabaseService.syncFamilySurveyToSupabaseWithTracking(
        phoneNumber,
        surveyData,
        {'survey_id': surveyId},
      );
      expect(syncSuccess, isTrue);
      expect(mockSupabaseService.syncedFamilySurveys.length, equals(1));
      expect(mockSupabaseService.syncedFamilySurveys.first['phone_number'], equals(phoneNumber));
      print('✅ Survey data successfully synced to Supabase (mocked)');

      // Step 6: Update local sync status after successful sync
      print('📝 Step 6: Updating local sync status to synced');
      await databaseService.updateSurveySyncStatus(phoneNumber, 'synced');

      // Step 7: Verify sync status is updated locally
      print('🔍 Step 7: Verifying sync status updated locally');
      final updatedSurvey = await databaseService.getSurveySession(phoneNumber);
      expect(updatedSurvey, isNotNull);
      expect(updatedSurvey!['sync_status'], equals('synced'));
      print('✅ Local sync status updated to synced');

      // Step 8: Verify survey no longer appears in unsynced list
      print('🔍 Step 8: Verifying survey removed from unsynced list');
      final updatedUnsyncedSurveys = await databaseService.getUnsyncedFamilySurveys();
      final stillUnsynced = updatedUnsyncedSurveys.where((s) => s['phone_number'] == phoneNumber);
      expect(stillUnsynced.isEmpty, isTrue);
      print('✅ Survey successfully removed from unsynced list');

      print('🎉 Complete family survey data flow test PASSED!');
      print('📊 Summary: Local Save → Sync Status Check → Supabase Sync → Status Update → Verification');
    });

    test('Village Survey: Complete data flow from local save to Supabase sync', () async {
      print('🚀 Testing complete village survey data flow: Local Save → Sync → Supabase');

      // Step 1: Create village survey session
      print('📝 Step 1: Creating village survey session locally');
      const sessionId = 'test-session-village-001';
      const shineCode = 12345;
      const villageName = 'Test Village';

      final sessionData = {
        'session_id': sessionId,
        'shine_code': shineCode,
        'village_name': villageName,
        'created_at': DateTime.now().toIso8601String(),
      };

      await databaseService.createNewVillageSurveySession(sessionData);
      print('✅ Village survey session created locally');

      // Step 2: Add village survey data
      print('📝 Step 2: Adding village survey data');
      final villageData = {
        'infrastructure_available': true,
        'water_source': 'well',
        'electricity_available': true,
      };

      await databaseService.saveData('village_infrastructure', {
        'session_id': sessionId,
        'data': villageData,
      });

      // Mark page as completed
      await databaseService.markVillagePageCompleted(sessionId, 1);
      print('✅ Village survey data saved and marked as completed');

      // Step 3: Verify data is stored locally with correct sync status
      print('🔍 Step 3: Verifying local village data storage and sync status');
      final storedSession = await databaseService.getVillageSurveySession(sessionId);
      expect(storedSession, isNotNull);
      expect(storedSession!['session_id'], equals(sessionId));
      expect(storedSession['status'], equals('incomplete'));
      expect(storedSession['sync_status'], equals('pending'));
      print('✅ Local village survey data verified with pending sync status');

      // Step 4: Get unsynced village surveys
      print('🔍 Step 4: Retrieving unsynced village surveys');
      final unsyncedVillageSurveys = await databaseService.getUnsyncedVillageSurveys();
      expect(unsyncedVillageSurveys.length, greaterThan(0));
      final unsyncedVillageSurvey = unsyncedVillageSurveys.firstWhere(
        (s) => s['session_id'] == sessionId,
        orElse: () => {},
      );
      expect(unsyncedVillageSurvey.isNotEmpty, isTrue);
      print('✅ Found unsynced village survey in local database');

      // Step 5: Simulate sync to Supabase
      print('🔄 Step 5: Simulating village survey sync to Supabase');
      await mockSupabaseService.syncVillageSurveyToSupabase(sessionId, villageData);
      expect(mockSupabaseService.syncedVillageSurveys.length, equals(1));
      expect(mockSupabaseService.syncedVillageSurveys.first['session_id'], equals(sessionId));
      print('✅ Village survey data successfully synced to Supabase (mocked)');

      // Step 6: Update local sync status after successful sync
      print('📝 Step 6: Updating local village sync status to synced');
      await databaseService.updateVillageSurveySyncStatus(sessionId, 'synced');

      // Step 7: Verify sync status is updated locally
      print('🔍 Step 7: Verifying village sync status updated locally');
      final updatedSession = await databaseService.getVillageSurveySession(sessionId);
      expect(updatedSession, isNotNull);
      expect(updatedSession!['sync_status'], equals('synced'));
      print('✅ Local village sync status updated to synced');

      // Step 8: Verify survey no longer appears in unsynced list
      print('🔍 Step 8: Verifying village survey removed from unsynced list');
      final updatedUnsyncedVillageSurveys = await databaseService.getUnsyncedVillageSurveys();
      final stillUnsynced = updatedUnsyncedVillageSurveys.where((s) => s['session_id'] == sessionId);
      expect(stillUnsynced.isEmpty, isTrue);
      print('✅ Village survey successfully removed from unsynced list');

      print('🎉 Complete village survey data flow test PASSED!');
      print('📊 Summary: Local Save → Sync Status Check → Supabase Sync → Status Update → Verification');
    });

    test('Family Survey Pages: Complete page data flow from local save to Supabase sync', () async {
      print('🚀 Testing complete family survey pages data flow: Local Save → Sync → Supabase');

      // Step 1: Create survey and add page data
      print('📝 Step 1: Creating survey and adding page data locally');
      const phoneNumber = '+1234567891';
      final surveyData = {'village_name': 'Test Village', 'created_at': DateTime.now().toIso8601String()};
      await databaseService.createNewSurveyRecord(surveyData);

      final page1Data = {'member_name': 'John Doe', 'age': 30, 'relation': 'head'};
      final page2Data = {'member_name': 'Jane Doe', 'age': 28, 'relation': 'spouse'};

      await databaseService.saveData('family_members', {'phone_number': phoneNumber, 'page_number': 1, 'data': page1Data});
      await databaseService.saveData('family_members', {'phone_number': phoneNumber, 'page_number': 2, 'data': page2Data});

      await databaseService.markFamilyPageCompleted(phoneNumber, 1);
      await databaseService.markFamilyPageCompleted(phoneNumber, 2);
      print('✅ Family survey pages created and marked as completed');

      // Step 2: Verify page status locally
      print('🔍 Step 2: Verifying page completion status locally');
      final pageStatus = await databaseService.getFamilyPageStatus(phoneNumber);
      expect(pageStatus['page_completion_status']['1']['completed'], isTrue);
      expect(pageStatus['page_completion_status']['1']['synced'], isFalse);
      expect(pageStatus['page_completion_status']['2']['completed'], isTrue);
      expect(pageStatus['page_completion_status']['2']['synced'], isFalse);
      print('✅ Page completion status verified locally');

      // Step 3: Simulate page sync to Supabase
      print('🔄 Step 3: Simulating page sync to Supabase');
      await mockSupabaseService.syncFamilyPageToSupabase(phoneNumber, 1, page1Data);
      await mockSupabaseService.syncFamilyPageToSupabase(phoneNumber, 2, page2Data);

      expect(mockSupabaseService.syncedFamilyPages.length, equals(2));
      expect(mockSupabaseService.syncedFamilyPages[0]['phone_number'], equals(phoneNumber));
      expect(mockSupabaseService.syncedFamilyPages[0]['page'], equals(1));
      expect(mockSupabaseService.syncedFamilyPages[1]['page'], equals(2));
      print('✅ Family survey pages successfully synced to Supabase (mocked)');

      // Step 4: Update page sync status locally
      print('📝 Step 4: Updating page sync status locally');
      await databaseService.markFamilyPageSynced(phoneNumber, 1);
      await databaseService.markFamilyPageSynced(phoneNumber, 2);

      // Step 5: Verify page sync status updated
      print('🔍 Step 5: Verifying page sync status updated locally');
      final updatedPageStatus = await databaseService.getFamilyPageStatus(phoneNumber);
      expect(updatedPageStatus['page_completion_status']['1']['synced'], isTrue);
      expect(updatedPageStatus['page_completion_status']['2']['synced'], isTrue);
      print('✅ Page sync status updated locally');

      print('🎉 Complete family survey pages data flow test PASSED!');
      print('📊 Summary: Page Save → Completion Mark → Supabase Sync → Sync Mark → Verification');
    });

    test('Data Consistency: Verify data integrity across save-sync-update cycle', () async {
      print('🚀 Testing data consistency across complete save-sync-update cycle');

      // Step 1: Create and save complex survey data
      print('📝 Step 1: Creating complex survey with multiple data points');
      const phoneNumber = '+1234567892';
      final surveyData = {
        'village_name': 'Consistency Test Village',
        'created_at': DateTime.now().toIso8601String(),
      };

      final surveyId = await databaseService.createNewSurveyRecord(surveyData);

      // Add multiple types of data
      final familyData = {'total_members': 5, 'caste': 'general', 'religion': 'hindu'};
      final economicData = {'primary_occupation': 'farming', 'annual_income': 150000};
      final assetData = {'land_holding': 2.5, 'house_type': 'semi_pucca'};

      await databaseService.saveData('family_details', {'phone_number': phoneNumber, 'data': familyData});
      await databaseService.saveData('economic_details', {'phone_number': phoneNumber, 'data': economicData});
      await databaseService.saveData('asset_details', {'phone_number': phoneNumber, 'data': assetData});

      await databaseService.markFamilyPageCompleted(phoneNumber, 1);
      print('✅ Complex survey data saved locally');

      // Step 2: Retrieve and verify data before sync
      print('🔍 Step 2: Verifying data integrity before sync');
      final preSyncSurvey = await databaseService.getSurveySession(phoneNumber);
      expect(preSyncSurvey!['sync_status'], equals('pending'));

      final preSyncFamilyData = await databaseService.getData('family_details', phoneNumber);
      final preSyncEconomicData = await databaseService.getData('economic_details', phoneNumber);
      final preSyncAssetData = await databaseService.getData('asset_details', phoneNumber);

      expect(preSyncFamilyData.isNotEmpty, isTrue);
      expect(preSyncEconomicData.isNotEmpty, isTrue);
      expect(preSyncAssetData.isNotEmpty, isTrue);
      print('✅ Data integrity verified before sync');

      // Step 3: Simulate sync process
      print('🔄 Step 3: Simulating complete sync process');
      final syncSuccess = await mockSupabaseService.syncFamilySurveyToSupabaseWithTracking(
        phoneNumber,
        {
          ...surveyData,
          'family_details': familyData,
          'economic_details': economicData,
          'asset_details': assetData,
        },
        {'survey_id': surveyId},
      );
      expect(syncSuccess, isTrue);
      print('✅ Sync process completed successfully');

      // Step 4: Update sync status
      print('📝 Step 4: Updating sync status');
      await databaseService.updateSurveySyncStatus(phoneNumber, 'synced');

      // Step 5: Verify data consistency after sync
      print('🔍 Step 5: Verifying data consistency after sync');
      final postSyncSurvey = await databaseService.getSurveySession(phoneNumber);
      expect(postSyncSurvey!['sync_status'], equals('synced'));

      final postSyncFamilyData = await databaseService.getData('family_details', phoneNumber);
      final postSyncEconomicData = await databaseService.getData('economic_details', phoneNumber);
      final postSyncAssetData = await databaseService.getData('asset_details', phoneNumber);

      // Verify data hasn't changed during sync process
      expect(postSyncFamilyData.length, equals(preSyncFamilyData.length));
      expect(postSyncEconomicData.length, equals(preSyncEconomicData.length));
      expect(postSyncAssetData.length, equals(preSyncAssetData.length));

      // Verify specific data points
      expect(postSyncFamilyData.first['data']['total_members'], equals(5));
      expect(postSyncEconomicData.first['data']['annual_income'], equals(150000));
      expect(postSyncAssetData.first['data']['land_holding'], equals(2.5));
      print('✅ Data consistency maintained throughout sync cycle');

      // Step 6: Verify survey no longer in unsynced list
      print('🔍 Step 6: Final verification - survey removed from unsynced list');
      final finalUnsyncedSurveys = await databaseService.getUnsyncedFamilySurveys();
      final stillUnsynced = finalUnsyncedSurveys.where((s) => s['phone_number'] == phoneNumber);
      expect(stillUnsynced.isEmpty, isTrue);
      print('✅ Survey successfully processed and removed from unsynced list');

      print('🎉 Data consistency test PASSED!');
      print('📊 Summary: Complex Data Save → Pre-sync Verification → Sync → Status Update → Post-sync Verification');
    });
  });
}