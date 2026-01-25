import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dri_survey/services/database_service.dart';

class SurveyState {
  final int currentPage;
  final int totalPages;
  final Map<String, dynamic> surveyData;
  final bool isLoading;
  final String? phoneNumber;

  const SurveyState({
    required this.currentPage,
    required this.totalPages,
    required this.surveyData,
    required this.isLoading,
    this.phoneNumber,
  });

  SurveyState copyWith({
    int? currentPage,
    int? totalPages,
    Map<String, dynamic>? surveyData,
    bool? isLoading,
    String? phoneNumber,
  }) {
    return SurveyState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      surveyData: surveyData ?? this.surveyData,
      isLoading: isLoading ?? this.isLoading,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class SurveyNotifier extends Notifier<SurveyState> {
  final DatabaseService _databaseService = DatabaseService();

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
      );
      state = state.copyWith(phoneNumber: sessionId);

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
        case 2: // Land holding
          final landData = await _databaseService.getData('land_holding', state.phoneNumber!);
          if (landData.isNotEmpty) {
            data.addAll(landData.first);
          }
          break;
        case 3: // Irrigation
          final irrigationData = await _databaseService.getData('irrigation_facilities', state.phoneNumber!);
          if (irrigationData.isNotEmpty) {
            data.addAll(irrigationData.first);
          }
          break;
        case 4: // Crop productivity
          final cropData = await _databaseService.getData('crop_productivity', state.phoneNumber!);
          if (cropData.isNotEmpty) {
            data['crops'] = cropData;
          }
          break;
        case 5: // Fertilizer
          final fertilizerData = await _databaseService.getData('fertilizer_usage', state.phoneNumber!);
          if (fertilizerData.isNotEmpty) {
            data.addAll(fertilizerData.first);
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
        break;
      case 2: // Land holding
        await _databaseService.saveData('land_holding', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 3: // Irrigation
        await _databaseService.saveData('irrigation_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 4: // Crop productivity
        if (data['crops'] != null) {
          for (final crop in data['crops']) {
            await _databaseService.saveData('crop_productivity', {
              'phone_number': state.phoneNumber,
              ...crop,
            });
          }
        }
        break;
      case 5: // Fertilizer
        await _databaseService.saveData('fertilizer_usage', {
          'phone_number': state.phoneNumber,
          ...data,
        });
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
        break;
      case 7: // Equipment
        await _databaseService.saveData('agricultural_equipment', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 8: // Entertainment
        await _databaseService.saveData('entertainment_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 9: // Transport
        await _databaseService.saveData('transport_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 10: // Water sources
        await _databaseService.saveData('drinking_water_sources', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 11: // Medical
        await _databaseService.saveData('medical_treatment', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 12: // Disputes
        await _databaseService.saveData('disputes', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 13: // House conditions
        await _databaseService.saveData('house_conditions', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 14: // House facilities
        await _databaseService.saveData('house_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 15: // Nutritional garden
        await _databaseService.saveData('nutritional_garden', {
          'phone_number': state.phoneNumber,
          ...data,
        });
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
        break;
      // Add more cases for other pages...
      case 22: // Social consciousness
        await _databaseService.saveData('social_consciousness', {
          'phone_number': state.phoneNumber,
          ...data,
        });
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

  void reset() {
    state = const SurveyState(
      currentPage: 0,
      totalPages: 31,
      surveyData: {},
      isLoading: false,
    );
  }
}

final surveyProvider = NotifierProvider<SurveyNotifier, SurveyState>(() {
  return SurveyNotifier();
});
