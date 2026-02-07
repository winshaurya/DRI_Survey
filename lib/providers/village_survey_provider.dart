import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dri_survey/services/database_service.dart';
import 'package:dri_survey/services/supabase_service.dart';
import 'package:dri_survey/services/sync_service.dart';

class VillageSurveyState {
  final String? shineCode;  // PRIMARY KEY for village surveys
  final String? sessionId;  // Internal tracking ID
  final int currentScreen;  // 0-13 (14 screens total)
  final Map<String, dynamic> surveyData;
  final bool isLoading;
  final bool isEditMode;

  const VillageSurveyState({
    this.shineCode,
    this.sessionId,
    required this.currentScreen,
    required this.surveyData,
    required this.isLoading,
    this.isEditMode = false,
  });

  VillageSurveyState copyWith({
    String? shineCode,
    String? sessionId,
    int? currentScreen,
    Map<String, dynamic>? surveyData,
    bool? isLoading,
    bool? isEditMode,
  }) {
    return VillageSurveyState(
      shineCode: shineCode ?? this.shineCode,
      sessionId: sessionId ?? this.sessionId,
      currentScreen: currentScreen ?? this.currentScreen,
      surveyData: surveyData ?? this.surveyData,
      isLoading: isLoading ?? this.isLoading,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }
}

class VillageSurveyNotifier extends Notifier<VillageSurveyState> {
  final DatabaseService _databaseService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService.instance;
  final SyncService _syncService = SyncService.instance;

  @override
  VillageSurveyState build() {
    return const VillageSurveyState(
      currentScreen: 0,
      surveyData: {},
      isLoading: false,
    );
  }

  // Initialize new village survey
  Future<void> initializeVillageSurvey(Map<String, dynamic> formData) async {
    try {
      setLoading(true);

      final shineCode = formData['shine_code'] as String?;
      final sessionId = formData['session_id'] as String?;

      if (shineCode == null || sessionId == null) {
        throw Exception('Shine code and session ID are required');
      }

      // Store basic form data
      state = state.copyWith(
        shineCode: shineCode,
        sessionId: sessionId,
        surveyData: Map<String, dynamic>.from(formData),
      );

      // Create record in database
      await _databaseService.createVillageSurveySession(formData);

      // Try to sync to Supabase if online
      if (await _supabaseService.isOnline()) {
        try {
          await _supabaseService.client
              .from('village_survey_sessions')
              .upsert({
            ...formData,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'user_id': _supabaseService.currentUser?.id,
          });
        } catch (e) {
          print('Error syncing to Supabase: $e');
        }
      }
    } catch (e) {
      print('Error initializing village survey: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Load existing village survey by shine_code
  Future<void> loadVillageSurvey(String shineCode, {bool editMode = false}) async {
    try {
      setLoading(true);

      // Get session by shine_code
      final session = await _databaseService.getVillageSurveyByShineCode(shineCode);
      if (session == null) {
        throw Exception('Village survey not found for shine code: $shineCode');
      }

      state = state.copyWith(
        shineCode: shineCode,
        sessionId: session['session_id'] as String?,
        isEditMode: editMode,
      );

      // Load all data from database
      await _loadAllVillageData();
    } catch (e) {
      print('Error loading village survey: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Load all village survey data from SQLite
  Future<void> _loadAllVillageData() async {
    if (state.sessionId == null) return;

    try {
      final sessionId = state.sessionId!;
      Map<String, dynamic> allData = {};

      // Load basic session data
      final session = await _databaseService.getVillageSurveySession(sessionId);
      if (session != null) {
        allData.addAll(session);
      }

      // Load infrastructure data
      final infrastructure = await _databaseService.getData('village_infrastructure', sessionId);
      if (infrastructure.isNotEmpty) {
        allData.addAll(_prefixKeys(infrastructure.first, 'infrastructure_'));
      }

      // Load infrastructure details
      final infraDetails = await _databaseService.getData('village_infrastructure_details', sessionId);
      if (infraDetails.isNotEmpty) {
        allData.addAll(_prefixKeys(infraDetails.first, 'infra_details_'));
      }

      // Load educational facilities
      final educational = await _databaseService.getData('village_educational_facilities', sessionId);
      if (educational.isNotEmpty) {
        allData.addAll(_prefixKeys(educational.first, 'educational_'));
      }

      // Load drainage waste
      final drainage = await _databaseService.getData('village_drainage_waste', sessionId);
      if (drainage.isNotEmpty) {
        allData.addAll(_prefixKeys(drainage.first, 'drainage_'));
      }

      // Load irrigation facilities
      final irrigation = await _databaseService.getData('village_irrigation_facilities', sessionId);
      if (irrigation.isNotEmpty) {
        allData.addAll(_prefixKeys(irrigation.first, 'irrigation_'));
      }

      // Load seed clubs
      final seedClubs = await _databaseService.getData('village_seed_clubs', sessionId);
      if (seedClubs.isNotEmpty) {
        allData.addAll(_prefixKeys(seedClubs.first, 'seed_clubs_'));
      }

      // Load biodiversity register
      final biodiversity = await _databaseService.getData('village_biodiversity_register', sessionId);
      if (biodiversity.isNotEmpty) {
        allData.addAll(_prefixKeys(biodiversity.first, 'biodiversity_'));
      }

      // Load social map
      final socialMap = await _databaseService.getData('village_social_map', sessionId);
      if (socialMap.isNotEmpty) {
        allData.addAll(_prefixKeys(socialMap.first, 'social_map_'));
      }

      // Load traditional occupations
      final traditional = await _databaseService.getData('village_traditional_occupations', sessionId);
      if (traditional.isNotEmpty) {
        allData['traditional_occupations'] = traditional;
      }

      // Load cultural heritage
      final cultural = await _databaseService.getData('village_cultural_heritage', sessionId);
      if (cultural.isNotEmpty) {
        allData.addAll(_prefixKeys(cultural.first, 'cultural_'));
      }

      // Load PRA team
      final praTeam = await _databaseService.getData('village_pra_team', sessionId);
      if (praTeam.isNotEmpty) {
        allData.addAll(_prefixKeys(praTeam.first, 'pra_team_'));
      }

      // Load survey details
      final surveyDetails = await _databaseService.getData('village_survey_details', sessionId);
      if (surveyDetails.isNotEmpty) {
        allData.addAll(_prefixKeys(surveyDetails.first, 'survey_details_'));
      }

      // Update state with all loaded data
      state = state.copyWith(surveyData: allData);
    } catch (e) {
      print('Error loading all village data: $e');
    }
  }

  // Helper method to prefix keys to avoid collisions
  Map<String, dynamic> _prefixKeys(Map<String, dynamic> data, String prefix) {
    return data.map((key, value) => MapEntry(prefix + key, value));
  }

  // Save specific screen data
  Future<void> saveScreenData(int screenIndex, Map<String, dynamic> data) async {
    if (state.sessionId == null) {
      throw Exception('No active survey session');
    }

    try {
      setLoading(true);

      // Update state immediately
      final updatedData = Map<String, dynamic>.from(state.surveyData)..addAll(data);
      state = state.copyWith(surveyData: updatedData);

      // Save to SQLite based on screen index
      await _saveToDatabase(screenIndex, data);

      // Sync to Supabase
      await _syncService.syncVillagePageData(state.sessionId!, screenIndex, data);
    } catch (e) {
      print('Error saving screen data: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Save data to appropriate database table
  Future<void> _saveToDatabase(int screenIndex, Map<String, dynamic> data) async {
    final sessionId = state.sessionId!;
    final db = await _databaseService.database;

    switch (screenIndex) {
      case 0: // Village Form - already saved in initialization
        await db.update(
          'village_survey_sessions',
          data,
          where: 'session_id = ?',
          whereArgs: [sessionId],
        );
        break;
      case 1: // Infrastructure
        await _databaseService.insertOrUpdate('village_infrastructure', data, sessionId);
        break;
      case 2: // Infrastructure Availability
        await _databaseService.insertOrUpdate('village_infrastructure_details', data, sessionId);
        break;
      case 3: // Educational Facilities
        await _databaseService.insertOrUpdate('village_educational_facilities', data, sessionId);
        break;
      case 4: // Drainage Waste
        await _databaseService.insertOrUpdate('village_drainage_waste', data, sessionId);
        break;
      case 5: // Irrigation Facilities
        await _databaseService.insertOrUpdate('village_irrigation_facilities', data, sessionId);
        break;
      case 6: // Seed Clubs
        await _databaseService.insertOrUpdate('village_seed_clubs', data, sessionId);
        break;
      case 7: // Signboards
        await _databaseService.insertOrUpdate('village_signboards', data, sessionId);
        break;
      case 8: // Social Map
        await _databaseService.insertOrUpdate('village_social_map', data, sessionId);
        break;
      case 9: // Survey Details
        await _databaseService.insertOrUpdate('village_survey_details', data, sessionId);
        break;
      case 10: // Detailed Map
        await _databaseService.insertOrUpdate('village_detailed_map', data, sessionId);
        break;
      case 11: // Forest Map
        await _databaseService.insertOrUpdate('village_forest_map', data, sessionId);
        break;
      case 12: // Biodiversity Register
        await _databaseService.insertOrUpdate('village_biodiversity_register', data, sessionId);
        break;
      default:
        print('Unknown screen index: $screenIndex');
    }
  }

  // Update survey data in state
  void updateSurveyData(Map<String, dynamic> data) {
    final updatedData = Map<String, dynamic>.from(state.surveyData)..addAll(data);
    state = state.copyWith(surveyData: updatedData);
  }

  // Navigate to specific screen
  void setCurrentScreen(int screenIndex) {
    state = state.copyWith(currentScreen: screenIndex);
  }

  // Move to next screen
  void nextScreen() {
    if (state.currentScreen < 13) {
      state = state.copyWith(currentScreen: state.currentScreen + 1);
    }
  }

  // Move to previous screen
  void previousScreen() {
    if (state.currentScreen > 0) {
      state = state.copyWith(currentScreen: state.currentScreen - 1);
    }
  }

  // Set loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  // Complete survey
  Future<void> completeSurvey() async {
    if (state.sessionId == null) return;

    try {
      // Mark as completed in database
      await _databaseService.updateVillageSurveyStatus(
        state.sessionId!,
        'completed',
      );

      // Final sync to Supabase
      await _syncService.syncVillageSurveyToSupabase(state.sessionId!);
    } catch (e) {
      print('Error completing survey: $e');
      rethrow;
    }
  }

  // Reset survey state
  void reset() {
    state = const VillageSurveyState(
      currentScreen: 0,
      surveyData: {},
      isLoading: false,
    );
  }
}

final villageSurveyProvider = NotifierProvider<VillageSurveyNotifier, VillageSurveyState>(() {
  return VillageSurveyNotifier();
});
