import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dri_survey/services/database_service.dart';
import 'package:dri_survey/services/supabase_service.dart';
import 'package:dri_survey/services/sync_service.dart';

class SurveyState {
  final int currentPage;
  final int totalPages;
  final Map<String, dynamic> surveyData;
  final bool isLoading;
  final String? phoneNumber;
  final int? supabaseSurveyId;

  const SurveyState({
    required this.currentPage,
    required this.totalPages,
    required this.surveyData,
    required this.isLoading,
    this.phoneNumber,
    this.supabaseSurveyId,
  });

  SurveyState copyWith({
    int? currentPage,
    int? totalPages,
    Map<String, dynamic>? surveyData,
    bool? isLoading,
    String? phoneNumber,
    int? supabaseSurveyId,
  }) {
    return SurveyState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      surveyData: surveyData ?? this.surveyData,
      isLoading: isLoading ?? this.isLoading,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      supabaseSurveyId: supabaseSurveyId ?? this.supabaseSurveyId,
    );
  }
}

class SurveyNotifier extends Notifier<SurveyState> {
  final DatabaseService _databaseService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService.instance;
  final SyncService _syncService = SyncService.instance;

  @override
  SurveyState build() {
    return const SurveyState(
      currentPage: 0,
      totalPages: 31, // Based on questionnaire sections (added 9 new pages for government schemes)
      surveyData: {},
      isLoading: false,
    );
  }

  Future<void> initializeSurvey({
    required String villageName,
    String? villageNumber,
    String? panchayat,
    String? block,
    String? tehsil,
    String? district,
    String? postalAddress,
    String? pinCode,
    String? surveyorName,
    String? phoneNumber,
    String? surveyorEmail,
  }) async {
    try {
      setLoading(true);
      final sessionId = await _databaseService.createNewSurveySession(
        villageName: villageName,
        villageNumber: villageNumber,
        panchayat: panchayat,
        block: block,
        tehsil: tehsil,
        district: district,
        postalAddress: postalAddress,
        pinCode: pinCode,
        surveyorName: surveyorName,
        phoneNumber: phoneNumber,
        surveyorEmail: surveyorEmail,
      );
      state = state.copyWith(phoneNumber: sessionId);

      // Create survey in Supabase if online
      if (await _supabaseService.isOnline()) {
        try {
          final surveyResponse = await _supabaseService.client
              .from('surveys')
              .insert({
                'village_name': villageName,
                'village_number': villageNumber,
                'panchayat': panchayat,
                'block': block,
                'tehsil': tehsil,
                'district': district,
                'postal_address': postalAddress,
                'pin_code': pinCode,
                'surveyor_name': surveyorName,
                'survey_date': DateTime.now().toIso8601String(),
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
                'user_id': _supabaseService.currentUser?.id,
              })
              .select()
              .single();
          final supabaseId = surveyResponse['id'] as int;
          state = state.copyWith(supabaseSurveyId: supabaseId);
        } catch (e) {
          print('Error creating survey in Supabase: $e');
        }
      }

      // Load existing data for all pages if any
      await _loadAllSurveyData();
    } catch (e) {
      // Handle error
      print('Error initializing survey: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> _loadAllSurveyData() async {
    if (state.phoneNumber == null) return;

    try {
      // Load data for all pages that might have data
      for (int page = 0; page < state.totalPages; page++) {
        final pageData = await _loadPageData(page);
        if (pageData.isNotEmpty) {
          updateSurveyDataMap(pageData);
        }
      }
    } catch (e) {
      print('Error loading all survey data: $e');
    }
  }

  Future<void> saveCurrentPageData() async {
    if (state.phoneNumber == null) return;

    try {
      // Save data based on current page
      await _savePageData(state.currentPage, state.surveyData);
    } catch (e) {
      print('Error saving page data: $e');
    }
  }

  Future<void> loadPageData(int page) async {
    if (state.phoneNumber == null) return;

    try {
      // Load data for the specific page from database
      final pageData = await _loadPageData(page);
      if (pageData.isNotEmpty) {
        updateSurveyDataMap(pageData);
      }
    } catch (e) {
      print('Error loading page data: $e');
    }
  }

  Future<Map<String, dynamic>> _loadPageData(int page) async {
    if (state.phoneNumber == null) return {};

    final data = <String, dynamic>{};

    try {
      // Load data based on page number
      switch (page) {
        case 0: // Location page
          final sessionData = await _databaseService.getSurveySession(state.phoneNumber!);
          if (sessionData != null) {
            data.addAll({
              'village_name': sessionData['village_name'],
              'village_number': sessionData['village_number'],
              'panchayat': sessionData['panchayat'],
              'block': sessionData['block'],
              'tehsil': sessionData['tehsil'],
              'district': sessionData['district'],
              'postal_address': sessionData['postal_address'],
              'pin_code': sessionData['pin_code'],
              'surveyor_name': sessionData['surveyor_name'],
            });
          }
          break;
        case 1: // Family details page
          final familyMembers = await _databaseService.getData('family_members', state.phoneNumber!);
          if (familyMembers.isNotEmpty) {
            data['family_members'] = familyMembers;
          }
          break;
        case 2: // Agriculture data (merged: land holding, irrigation, fertilizer)
          final agricultureData = await _databaseService.getData('agriculture_data', state.phoneNumber!);
          if (agricultureData.isNotEmpty) {
            data.addAll(agricultureData.first);
          }
          break;
        case 3: // Crop productivity
          final cropData = await _databaseService.getData('crop_productivity', state.phoneNumber!);
          if (cropData.isNotEmpty) {
            data['crops'] = cropData;
          }
          break;
        case 6: // Animals
          final animalData = await _databaseService.getData('animals', state.phoneNumber!);
          if (animalData.isNotEmpty) {
            data['animals'] = animalData;
          }
          break;
        case 7: // Equipment
          final equipmentData = await _databaseService.getData('agricultural_equipment', state.phoneNumber!);
          if (equipmentData.isNotEmpty) {
            data.addAll(equipmentData.first);
          }
          break;
        case 8: // Entertainment
          final entertainmentData = await _databaseService.getData('entertainment_facilities', state.phoneNumber!);
          if (entertainmentData.isNotEmpty) {
            data.addAll(entertainmentData.first);
          }
          break;
        case 9: // Transport
          final transportData = await _databaseService.getData('transport_facilities', state.phoneNumber!);
          if (transportData.isNotEmpty) {
            data.addAll(transportData.first);
          }
          break;
        case 10: // Water sources
          final waterData = await _databaseService.getData('drinking_water_sources', state.phoneNumber!);
          if (waterData.isNotEmpty) {
            data.addAll(waterData.first);
          }
          break;
        case 11: // Medical
          final medicalData = await _databaseService.getData('medical_treatment', state.phoneNumber!);
          if (medicalData.isNotEmpty) {
            data.addAll(medicalData.first);
          }
          break;
        case 12: // Disputes
          final disputeData = await _databaseService.getData('disputes', state.phoneNumber!);
          if (disputeData.isNotEmpty) {
            data.addAll(disputeData.first);
          }
          break;
        case 13: // House conditions
          final houseConditionData = await _databaseService.getData('house_conditions', state.phoneNumber!);
          if (houseConditionData.isNotEmpty) {
            data.addAll(houseConditionData.first);
          }
          break;
        case 14: // House facilities
          final houseFacilityData = await _databaseService.getData('house_facilities', state.phoneNumber!);
          if (houseFacilityData.isNotEmpty) {
            data.addAll(houseFacilityData.first);
          }
          break;
        case 15: // Nutritional garden
          final gardenData = await _databaseService.getData('nutritional_garden', state.phoneNumber!);
          if (gardenData.isNotEmpty) {
            data.addAll(gardenData.first);
          }
          break;
        case 16: // Diseases
          final diseaseData = await _databaseService.getData('diseases', state.phoneNumber!);
          if (diseaseData.isNotEmpty) {
            data['diseases'] = diseaseData;
          }
          break;
        // Add more cases for other pages...
        case 22: // Social consciousness
          final socialData = await _databaseService.getData('social_consciousness', state.phoneNumber!);
          if (socialData.isNotEmpty) {
            data.addAll(socialData.first);
          }
          break;
      }
    } catch (e) {
      print('Error loading page data for page $page: $e');
    }

    return data;
  }

  Future<void> _savePageData(int page, Map<String, dynamic> data) async {
    if (state.phoneNumber == null) return;

    // Map page numbers to database tables and save accordingly
    switch (page) {
      case 0: // Location page
        await _databaseService.saveData('survey_sessions', {
          'phone_number': state.phoneNumber,
          'village_name': data['village_name'],
          'village_number': data['village_number'],
          'panchayat': data['panchayat'],
          'block': data['block'],
          'tehsil': data['tehsil'],
          'district': data['district'],
          'postal_address': data['postal_address'],
          'pin_code': data['pin_code'],
          'surveyor_name': data['surveyor_name'],
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 1: // Family details page
        if (data['family_members'] != null) {
          for (final member in data['family_members']) {
            await _databaseService.saveData('family_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }
        await _syncPageDataToSupabase(page, data);
        break;
      case 2: // Agriculture data (merged)
        await _databaseService.saveData('agriculture_data', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 3: // Crop productivity
        if (data['crops'] != null) {
          for (final crop in data['crops']) {
            await _databaseService.saveData('crop_productivity', {
              'phone_number': state.phoneNumber,
              ...crop,
            });
          }
        }
        await _syncPageDataToSupabase(page, data);
        break;
      case 6: // Animals
        if (data['animals'] != null) {
          for (final animal in data['animals']) {
            await _databaseService.saveData('animals', {
              'phone_number': state.phoneNumber,
              ...animal,
            });
          }
        }
        await _syncPageDataToSupabase(page, data);
        break;
      case 7: // Equipment
        await _databaseService.saveData('agricultural_equipment', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 8: // Entertainment
        await _databaseService.saveData('entertainment_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 9: // Transport
        await _databaseService.saveData('transport_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 10: // Water sources
        await _databaseService.saveData('drinking_water_sources', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 11: // Medical
        await _databaseService.saveData('medical_treatment', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 12: // Disputes
        await _databaseService.saveData('disputes', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 13: // House conditions
        await _databaseService.saveData('house_conditions', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 14: // House facilities
        await _databaseService.saveData('house_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 15: // Nutritional garden
        await _databaseService.saveData('nutritional_garden', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 16: // Diseases
        if (data['diseases'] != null) {
          for (final disease in data['diseases']) {
            await _databaseService.saveData('diseases', {
              'phone_number': state.phoneNumber,
              ...disease,
            });
          }
        }
        await _syncPageDataToSupabase(page, data);
        break;
      // Add more cases for other pages...
      case 17: // Government schemes
        await _databaseService.saveData('government_schemes', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 18: // Beneficiary programs
        await _databaseService.saveData('beneficiary_programs', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 19: // Children data
        if (data['children'] != null) {
          for (final child in data['children']) {
            await _databaseService.saveData('children_data', {
              'phone_number': state.phoneNumber,
              ...child,
            });
          }
        }
        await _syncPageDataToSupabase(page, data);
        break;
      case 20: // Malnutrition data
        await _databaseService.saveData('malnutrition_data', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 21: // Migration
        await _databaseService.saveData('migration', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 22: // Social consciousness
        await _databaseService.saveData('social_consciousness', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 23: // Training
        await _databaseService.saveData('training', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 24: // Self help groups
        await _databaseService.saveData('self_help_groups', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 25: // FPO membership
        await _databaseService.saveData('fpo_membership', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 26: // Bank accounts
        await _databaseService.saveData('bank_accounts', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 27: // Health programs
        await _databaseService.saveData('health_programs', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 28: // Folklore medicine
        await _databaseService.saveData('folklore_medicine', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 29: // Tulsi plants
        await _databaseService.saveData('tulsi_plants', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 30: // Nutritional garden (duplicate, but keeping for completeness)
        await _databaseService.saveData('nutritional_garden', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
    }
  }

  Future<void> nextPage() async {
    if (state.currentPage < state.totalPages - 1) {
      // Save current page data before moving to next
      await saveCurrentPageData();
      // Update the survey session timestamp
      if (state.phoneNumber != null) {
        await _databaseService.saveData('survey_sessions', {
          'phone_number': state.phoneNumber,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }

  void updateSurveyData(String key, dynamic value) {
    final newData = Map<String, dynamic>.from(state.surveyData);
    newData[key] = value;
    state = state.copyWith(surveyData: newData);
  }

  void updateSurveyDataMap(Map<String, dynamic> data) {
    final newData = Map<String, dynamic>.from(state.surveyData);
    newData.addAll(data);
    state = state.copyWith(surveyData: newData);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  Future<void> completeSurvey() async {
    if (state.phoneNumber != null) {
      await saveCurrentPageData();
      await _databaseService.updateSurveyStatus(state.phoneNumber!, 'completed');
      
      // Sync complete survey to Supabase if online
      if (await _supabaseService.isOnline() && state.supabaseSurveyId != null) {
        try {
          await _supabaseService.client
              .from('surveys')
              .update({
                'status': 'completed',
                'completed_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', state.supabaseSurveyId!);
        } catch (e) {
          print('Error updating survey completion status in Supabase: $e');
        }
      }
    }
  }

  Future<void> loadSurveySessionForPreview(String sessionId) async {
    try {
      setLoading(true);

      // Load session data
      final sessionData = await _databaseService.getSurveySession(sessionId);
      if (sessionData != null) {
        state = state.copyWith(phoneNumber: sessionId);

        // Load all survey data for this session
        await _loadAllSurveyData();

        // Set current page to final page for preview
        state = state.copyWith(currentPage: state.totalPages - 1);
      }
    } catch (e) {
      print('Error loading survey session for preview: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> _syncPageDataToSupabase(int page, Map<String, dynamic> data) async {
    if (state.phoneNumber == null) return;

    // Queue the sync operation - sync service will handle it when online
    await _syncService.queueSyncOperation('update_survey_data', {
      'phone_number': state.phoneNumber,
      'page': page,
      'data': data,
    });
  }

  void reset() {
    state = const SurveyState(
      currentPage: 0,
      totalPages: 5, // Family survey has 5 pages
      surveyData: {},
      isLoading: false,
    );
  }
}

final surveyProvider = NotifierProvider<SurveyNotifier, SurveyState>(() {
  return SurveyNotifier();
});
