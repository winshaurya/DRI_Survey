import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dri_survey/services/database_service.dart';
import 'package:dri_survey/services/supabase_service.dart';
import 'package:dri_survey/services/sync_service.dart';
import 'package:dri_survey/services/form_history_service.dart';

class SurveyState {
  final int currentPage;
  final int totalPages;
  final Map<String, dynamic> surveyData;
  final bool isLoading;
  final String? phoneNumber;
  final int? surveyId;
  final int? supabaseSurveyId;

  const SurveyState({
    required this.currentPage,
    required this.totalPages,
    required this.surveyData,
    required this.isLoading,
    this.phoneNumber,
    this.surveyId,
    this.supabaseSurveyId,
  });

  SurveyState copyWith({
    int? currentPage,
    int? totalPages,
    Map<String, dynamic>? surveyData,
    bool? isLoading,
    String? phoneNumber,
    int? surveyId,
    int? supabaseSurveyId,
  }) {
    return SurveyState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      surveyData: surveyData ?? this.surveyData,
      isLoading: isLoading ?? this.isLoading,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      surveyId: surveyId ?? this.surveyId,
      supabaseSurveyId: supabaseSurveyId ?? this.supabaseSurveyId,
    );
  }
}

class SurveyNotifier extends Notifier<SurveyState> {
  final DatabaseService _databaseService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService.instance;
  final SyncService _syncService = SyncService.instance;
  final FormHistoryService _historyService = FormHistoryService();

  @override
  SurveyState build() {
    return const SurveyState(
      currentPage: 0,
      totalPages: 31, // Based on survey_page.dart switch cases (0-30)
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

      // Create local survey record first
      final surveyId = await _databaseService.createNewSurveyRecord({
        'village_name': villageName,
        'village_number': villageNumber,
        'panchayat': panchayat,
        'block': block,
        'tehsil': tehsil,
        'district': district,
        'postal_address': postalAddress,
        'pin_code': pinCode,
        'surveyor_name': surveyorName,
        'phone_number': phoneNumber,
        'surveyor_email': surveyorEmail,
        'survey_date': DateTime.now().toIso8601String(), // Ensure survey_date is set
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      state = state.copyWith(surveyId: surveyId, phoneNumber: phoneNumber);

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
        case 2: // Social Consciousness 1
        case 3: // Social Consciousness 2
        case 4: // Social Consciousness 3
          final socialData = await _databaseService.getData('social_consciousness', state.phoneNumber!);
          if (socialData.isNotEmpty) {
            data.addAll(socialData.first);
          }
          break;
        case 5: // Land Holding
          final landData = await _databaseService.getData('land_holding', state.phoneNumber!);
          if (landData.isNotEmpty) {
            data.addAll(landData.first);
          }
          break;
        case 6: // Irrigation
          final irrigationData = await _databaseService.getData('irrigation_facilities', state.phoneNumber!);
          if (irrigationData.isNotEmpty) {
            data.addAll(irrigationData.first);
          }
          break;
        case 7: // Crop productivity
          final cropData = await _databaseService.getData('crop_productivity', state.phoneNumber!);
          if (cropData.isNotEmpty) {
            data['crops'] = cropData;
          }
          break;
        case 8: // Fertilizer usage
          final fertilizerData = await _databaseService.getData('fertilizer_usage', state.phoneNumber!);
          if (fertilizerData.isNotEmpty) {
            data.addAll(fertilizerData.first);
          }
          break;
        case 9: // Animals
          final animalData = await _databaseService.getData('animals', state.phoneNumber!);
          if (animalData.isNotEmpty) {
            data['animals'] = animalData;
          }
          break;
        case 10: // Agricultural Equipment
          final equipmentData = await _databaseService.getData('agricultural_equipment', state.phoneNumber!);
          if (equipmentData.isNotEmpty) {
            data.addAll(equipmentData.first);
          }
          break;
        case 11: // Entertainment Facilities
          final entertainmentData = await _databaseService.getData('entertainment_facilities', state.phoneNumber!);
          if (entertainmentData.isNotEmpty) {
            data.addAll(entertainmentData.first);
          }
          break;
        case 12: // Transport Facilities
          final transportData = await _databaseService.getData('transport_facilities', state.phoneNumber!);
          if (transportData.isNotEmpty) {
            data.addAll(transportData.first);
          }
          break;
        case 13: // Drinking Water Sources
          final waterData = await _databaseService.getData('drinking_water_sources', state.phoneNumber!);
          if (waterData.isNotEmpty) {
            data.addAll(waterData.first);
          }
          break;
        case 14: // Medical Treatment
          final medicalData = await _databaseService.getData('medical_treatment', state.phoneNumber!);
          if (medicalData.isNotEmpty) {
            data.addAll(medicalData.first);
          }
          break;
        case 15: // Disputes
          final disputeData = await _databaseService.getData('disputes', state.phoneNumber!);
          if (disputeData.isNotEmpty) {
            data.addAll(disputeData.first);
          }
          break;
        case 16: // House conditions
          // Load house conditions data (katcha, pakka, etc.)
          final houseConditionData = await _databaseService.getData('house_conditions', state.phoneNumber!);
          if (houseConditionData.isNotEmpty) {
            final conditions = houseConditionData.first;
            data.addAll({
              'katcha_house': conditions['katcha'] ?? false,
              'pakka_house': conditions['pakka'] ?? false,
              'katcha_pakka_house': conditions['katcha_pakka'] ?? false,
              'hut_house': conditions['hut'] ?? false,
            });
          }

          // Load house facilities data (toilet, drainage, etc.)
          final houseFacilitiesData = await _databaseService.getData('house_facilities', state.phoneNumber!);
          if (houseFacilitiesData.isNotEmpty) {
            final facilities = houseFacilitiesData.first;
            data.addAll({
              'toilet': facilities['toilet'] ?? false,
              'toilet_in_use': facilities['toilet_in_use'],
              'toilet_condition': facilities['toilet_condition'],
              'drainage': facilities['drainage'] ?? false,
              'soak_pit': facilities['soak_pit'] ?? false,
              'cattle_shed': facilities['cattle_shed'] ?? false,
              'compost_pit': facilities['compost_pit'] ?? false,
              'nadep': facilities['nadep'] ?? false,
              'lpg_gas': facilities['lpg_gas'] ?? false,
              'biogas': facilities['biogas'] ?? false,
              'solar_cooking': facilities['solar_cooking'] ?? false,
              'electric_connection': facilities['electric_connection'] ?? false,
              'nutritional_garden': facilities['nutritional_garden_available'] ?? false,
              'tulsi_plants': facilities['tulsi_plants_available'],
            });
          }
          break;
        case 17: // Diseases
          final diseaseData = await _databaseService.getData('diseases', state.phoneNumber!);
          if (diseaseData.isNotEmpty) {
            data['diseases'] = diseaseData;
          }
          break;
        case 18: // Folklore Medicine
          final folkloreData = await _databaseService.getData('folklore_medicine', state.phoneNumber!);
          if (folkloreData.isNotEmpty) {
            data['folklore_medicines'] = folkloreData;
          }
          break;
        case 19: // Health Programme Implemented
          final healthProgrammeData = await _databaseService.getData('health_programmes', state.phoneNumber!);
          if (healthProgrammeData.isNotEmpty) {
            data.addAll(healthProgrammeData.first);
          }
          break;
        case 20: // Beneficiary Programs
          final beneficiaryData = await _databaseService.getData('beneficiary_programs', state.phoneNumber!);
          if (beneficiaryData.isNotEmpty) {
            data['beneficiary_programs'] = beneficiaryData;
          }

          // Load government scheme member data
          final aadhaarMembers = await _databaseService.getData('aadhaar_scheme_members', state.phoneNumber!);
          if (aadhaarMembers.isNotEmpty) {
            data['aadhaar_scheme_members'] = aadhaarMembers;
          }

          final tribalMembers = await _databaseService.getData('tribal_scheme_members', state.phoneNumber!);
          if (tribalMembers.isNotEmpty) {
            data['tribal_scheme_members'] = tribalMembers;
          }

          final pensionMembers = await _databaseService.getData('pension_scheme_members', state.phoneNumber!);
          if (pensionMembers.isNotEmpty) {
            data['pension_scheme_members'] = pensionMembers;
          }

          final widowMembers = await _databaseService.getData('widow_scheme_members', state.phoneNumber!);
          if (widowMembers.isNotEmpty) {
            data['widow_scheme_members'] = widowMembers;
          }
          break;
        case 21: // Children data
          final childrenData = await _databaseService.getData('children_data', state.phoneNumber!);
          if (childrenData.isNotEmpty) {
            data.addAll(childrenData.first);
          }

          // Load malnourished children data
          final malnourishedChildren = await _databaseService.getData('malnourished_children_data', state.phoneNumber!);
          if (malnourishedChildren.isNotEmpty) {
            final childrenWithDiseases = <Map<String, dynamic>>[];

            for (final child in malnourishedChildren) {
              final childId = child['child_id'];
              final allDiseases = await _databaseService.getData('child_diseases', state.phoneNumber!);
              final diseases = allDiseases.where((d) => d['child_id'] == childId).toList();

              childrenWithDiseases.add({
                ...child,
                'diseases': diseases.map((d) => {'name': d['disease_name']}).toList(),
              });
            }

            data['malnourished_children_data'] = childrenWithDiseases;
          }
          break;
        case 26: // Training
          // Load training data
          final trainingData = await _databaseService.getData('training_data', state.phoneNumber!);
          if (trainingData.isNotEmpty) {
            data['training_entries'] = trainingData;
          }

          // Load SHG data
          final shgData = await _databaseService.getData('self_help_groups', state.phoneNumber!);
          if (shgData.isNotEmpty) {
            data['shg_entries'] = shgData;
          }

          // Load FPO data
          final fpoData = await _databaseService.getData('fpo_members', state.phoneNumber!);
          if (fpoData.isNotEmpty) {
            data['fpo_entries'] = fpoData;
          }
          break;
        case 29: // Bank accounts
          final bankAccountData = await _databaseService.getData('bank_accounts', state.phoneNumber!);
          if (bankAccountData.isNotEmpty) {
            data['bank_accounts'] = bankAccountData;
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
      case 2: // Social Consciousness 1
      case 3: // Social Consciousness 2
      case 4: // Social Consciousness 3
        await _databaseService.saveData('social_consciousness', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 5: // Land Holding
        await _databaseService.saveData('land_holding', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 6: // Irrigation
        await _databaseService.saveData('irrigation_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 7: // Crop Productivity
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
      case 8: // Fertilizer Usage
        await _databaseService.saveData('fertilizer_usage', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 9: // Animals
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
      case 10: // Agricultural Equipment
        await _databaseService.saveData('agricultural_equipment', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 11: // Entertainment Facilities
        await _databaseService.saveData('entertainment_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 12: // Transport Facilities
        await _databaseService.saveData('transport_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 13: // Water Sources
        await _databaseService.saveData('drinking_water_sources', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 14: // Medical Treatment
        await _databaseService.saveData('medical_treatment', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 15: // Disputes
        await _databaseService.saveData('disputes', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 16: // House Conditions
        // Save house conditions data (katcha, pakka, etc.)
        final houseConditionsData = {
          'phone_number': state.phoneNumber,
          'katcha': data['katcha_house'] ?? false,
          'pakka': data['pakka_house'] ?? false,
          'katcha_pakka': data['katcha_pakka_house'] ?? false,
          'hut': data['hut_house'] ?? false,
        };
        await _databaseService.saveData('house_conditions', houseConditionsData);

        // Save house facilities data (toilet, drainage, etc.)
        final houseFacilitiesData = {
          'phone_number': state.phoneNumber,
          'toilet': data['toilet'] ?? false,
          'toilet_in_use': data['toilet_in_use'],
          'toilet_condition': data['toilet_condition'],
          'drainage': data['drainage'] ?? false,
          'soak_pit': data['soak_pit'] ?? false,
          'cattle_shed': data['cattle_shed'] ?? false,
          'compost_pit': data['compost_pit'] ?? false,
          'nadep': data['nadep'] ?? false,
          'lpg_gas': data['lpg_gas'] ?? false,
          'biogas': data['biogas'] ?? false,
          'solar_cooking': data['solar_cooking'] ?? false,
          'electric_connection': data['electric_connection'] ?? false,
          'nutritional_garden_available': data['nutritional_garden'] ?? false,
          'tulsi_plants_available': data['tulsi_plants'],
        };
        await _databaseService.saveData('house_facilities', houseFacilitiesData);

        await _syncPageDataToSupabase(page, data);
        break;
      case 17: // Diseases
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
      case 18: // Folklore Medicine
        if (data['folklore_medicines'] != null) {
          for (final medicine in data['folklore_medicines']) {
            await _databaseService.saveData('folklore_medicine', {
              'phone_number': state.phoneNumber,
              ...medicine,
            });
          }
        }
        await _syncPageDataToSupabase(page, data);
        break;
      case 19: // Health Programme Implemented
        await _databaseService.saveData('health_programmes', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 20: // Beneficiary Programs
        // Save beneficiary program data
        if (data['beneficiary_programs'] != null) {
          for (final program in data['beneficiary_programs']) {
            await _databaseService.saveData('beneficiary_programs', {
              'phone_number': state.phoneNumber,
              ...program,
            });
          }
        }

        // Save government scheme member data
        if (data['aadhaar_scheme_members'] != null) {
          for (final member in data['aadhaar_scheme_members']) {
            await _databaseService.saveData('aadhaar_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['tribal_scheme_members'] != null) {
          for (final member in data['tribal_scheme_members']) {
            await _databaseService.saveData('tribal_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['pension_scheme_members'] != null) {
          for (final member in data['pension_scheme_members']) {
            await _databaseService.saveData('pension_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['widow_scheme_members'] != null) {
          for (final member in data['widow_scheme_members']) {
            await _databaseService.saveData('widow_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        await _syncPageDataToSupabase(page, data);
        break;
      case 21: // Beneficiary programs
        await _databaseService.saveData('beneficiary_programs', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 22: // Children data
        // Save basic children data
        await _databaseService.saveData('children_data', {
          'phone_number': state.phoneNumber,
          'births_last_3_years': data['births_last_3_years'],
          'infant_deaths_last_3_years': data['infant_deaths_last_3_years'],
          'malnourished_children': data['malnourished_children'],
        });

        // Save malnourished children data
        if (data['malnourished_children_data'] != null) {
          for (final childData in data['malnourished_children_data']) {
            // Save child basic info
            final childId = childData['child_id'] ?? childData['child_name'];
            await _databaseService.saveData('malnourished_children_data', {
              'phone_number': state.phoneNumber,
              'child_id': childId,
              'child_name': childData['child_name'],
              'height': childData['height'],
              'weight': childData['weight'],
            });

            // Save diseases for this child
            if (childData['diseases'] != null) {
              int diseaseIndex = 0;
              for (final disease in childData['diseases']) {
                await _databaseService.saveData('child_diseases', {
                  'phone_number': state.phoneNumber,
                  'child_id': childId,
                  'disease_name': disease['name'],
                  'sr_no': diseaseIndex++,
                });
              }
            }
          }
        }
        await _syncPageDataToSupabase(page, data);
        break;
      case 23: // Malnutrition data
        await _databaseService.saveData('malnutrition_data', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 24: // Migration
        await _databaseService.saveData('migration', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 25: // Social consciousness
        await _databaseService.saveData('social_consciousness', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 26: // Training
        // Save training data with new fields
        if (data['training_entries'] != null) {
          for (final training in data['training_entries']) {
            await _databaseService.saveData('training_data', {
              'phone_number': state.phoneNumber,
              ...training,
            });
          }
        }
        // Save SHG data
        if (data['shg_entries'] != null) {
          for (final shg in data['shg_entries']) {
            await _databaseService.saveData('self_help_groups', {
              'phone_number': state.phoneNumber,
              ...shg,
            });
          }
        }
        // Save FPO data
        if (data['fpo_entries'] != null) {
          for (final fpo in data['fpo_entries']) {
            await _databaseService.saveData('fpo_members', {
              'phone_number': state.phoneNumber,
              ...fpo,
            });
          }
        }
        await _syncPageDataToSupabase(page, data);
        break;
      case 27: // Self help groups
        await _databaseService.saveData('self_help_groups', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 28: // FPO membership
        await _databaseService.saveData('fpo_membership', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
        case 29: // Bank accounts
        // Save bank account data with new structure
        if (data['bank_accounts'] != null) {
          for (final account in data['bank_accounts']) {
            await _databaseService.saveData('bank_accounts', {
              'phone_number': state.phoneNumber,
              ...account,
            });
          }
        }
        await _syncPageDataToSupabase(page, data);
        break;
      case 30: // Health programs
        await _databaseService.saveData('health_programs', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 31: // Folklore medicine
        await _databaseService.saveData('folklore_medicine', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        await _syncPageDataToSupabase(page, data);
        break;
      case 32: // Tulsi plants
        await _databaseService.saveData('tulsi_plants', {
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

  Future<void> savePageData(int page, Map<String, dynamic> data) async {
    await _savePageData(page, data);
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

  Future<void> loadSurveySessionForContinuation(String sessionId) async {
    try {
      setLoading(true);

      // Load session data
      final sessionData = await _databaseService.getSurveySession(sessionId);
      if (sessionData != null) {
        state = state.copyWith(phoneNumber: sessionId);

        // Load all survey data for this session
        await _loadAllSurveyData();

        // For continuation, start from page 0 but with existing data loaded
        // The user can navigate through pages and continue filling
        state = state.copyWith(currentPage: 0);
      }
    } catch (e) {
      print('Error loading survey session for continuation: $e');
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
      totalPages: 23, // Based on survey_page.dart switch cases (0-22)
      surveyData: {},
      isLoading: false,
    );
  }
}

final surveyProvider = NotifierProvider<SurveyNotifier, SurveyState>(() {
  return SurveyNotifier();
});
