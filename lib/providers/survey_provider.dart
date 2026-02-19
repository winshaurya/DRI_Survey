import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  int? _lastSavedPage;
  String? _lastSavedDataSignature;
  final SupabaseService _supabaseService = SupabaseService.instance;
  final SyncService _syncService = SyncService.instance;

  DateTime? _lastSaveTimestamp;

  @override
  SurveyState build() {
    return const SurveyState(
      currentPage: 0,
      totalPages: 32,
      surveyData: {},
      isLoading: false,
    );
  }

  // Save current page data to database
  Future<void> saveCurrentPageData() async {
    // Accept phone number from state OR from in-memory surveyData (page 0 may not have set state.phoneNumber yet)
    final fallbackPhone = state.surveyData['phone_number'] != null
        ? state.surveyData['phone_number'].toString().trim()
        : null;
    final effectivePhone = (state.phoneNumber ?? fallbackPhone)?.trim();

    if (effectivePhone == null || effectivePhone.isEmpty) {
      debugPrint('Cannot save page data: phone number not set (state & surveyData empty)');
      return;
    }

    // If provider state didn't yet contain phoneNumber, populate it now so other flows work
    if ((state.phoneNumber == null || state.phoneNumber!.isEmpty) && fallbackPhone != null && fallbackPhone.isNotEmpty) {
      state = state.copyWith(phoneNumber: fallbackPhone);
      debugPrint('Recovered phoneNumber from surveyData -> $fallbackPhone');
    }

    try {
      final pageData = _extractPageData(state.currentPage);
      if (pageData.isEmpty) {
        debugPrint('No data to save for page ${state.currentPage}');
        return;
      }

      if (state.currentPage == 0) {
        // Ensure we always persist a session row when we have an effective phone
        final sessionPayload = {
          ...pageData,
          'phone_number': effectivePhone,
          'surveyor_email': _supabaseService.currentUser?.email ?? 'unknown',
          'status': 'in_progress',
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _databaseService.saveData('family_survey_sessions', sessionPayload);
        await _syncService.syncFamilyPageData(effectivePhone, 0, pageData);
        await _updatePageCompletionStatus(0, true);
        debugPrint('Successfully upserted session for page 0 (phone: $effectivePhone)');
      } else {
        // All other pages: save and sync immediately. Use effectivePhone as FK for child tables.
        await _savePageDataToDatabase(state.currentPage, pageData, effectivePhone);
        await _updatePageCompletionStatus(state.currentPage, true);
        await _syncService.syncFamilyPageData(effectivePhone, state.currentPage, pageData);
        debugPrint('Successfully saved and synced data for page ${state.currentPage} (phone: $effectivePhone)');
      }
    } catch (e) {
      debugPrint('Error saving page data: $e');
      rethrow;
    }
  }

  // Load page data from database
  Future<void> loadPageData([int? pageIndex]) async {
    final targetPage = pageIndex ?? state.currentPage;
    if (state.phoneNumber == null) {
      debugPrint('Cannot load page data: phone number not set');
      return;
    }

    try {
      final pageData = await _loadPageDataFromDatabase(targetPage, state.phoneNumber!);
      if (pageData.isNotEmpty) {
        // Flatten nested DB page maps into the flat keys that page widgets expect
        final flattened = <String, dynamic>{};

        pageData.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            if (key == 'house_conditions') {
              // DB -> UI key mapping for house conditions
              if (value.containsKey('katcha')) flattened['katcha_house'] = value['katcha'];
              if (value.containsKey('pakka')) flattened['pakka_house'] = value['pakka'];
              if (value.containsKey('katcha_pakka')) flattened['katcha_pakka_house'] = value['katcha_pakka'];
              if (value.containsKey('hut')) flattened['hut_house'] = value['hut'];
              if (value.containsKey('toilet_in_use')) flattened['toilet_in_use'] = value['toilet_in_use'];
              if (value.containsKey('toilet_condition')) flattened['toilet_condition'] = value['toilet_condition'];
            } else if (key == 'house_facilities') {
              // normalize DB column names to page keys where necessary
              value.forEach((hk, hv) {
                if (hk == 'nutritional_garden_available') flattened['nutritional_garden'] = hv;
                else if (hk == 'tulsi_plants_available') flattened['tulsi_plants'] = hv;
                else flattened[hk] = hv;
              });
            } else if (key == 'folklore_medicine' && value is Map) {
              // some DB entries are stored as map but UI expects list under 'folklore_medicines'
              // keep the DB shape under the original key and also expose possible list under page key
              flattened.addAll(value);
            } else {
              // Most nested page tables use the same keys as the UI — merge them directly
              flattened.addAll(value);
            }
          } else {
            // simple value (e.g., lists or scalars) - keep as-is
            flattened[key] = value;
          }
        });

        state = state.copyWith(surveyData: {...state.surveyData, ...flattened});
      }
      debugPrint('Successfully loaded data for page $targetPage');
    } catch (e) {
      debugPrint('Error loading page data: $e');
      rethrow;
    }
  }

  // Update survey data map (called by pages when data changes)
  void updateSurveyDataMap(Map<String, dynamic> pageData) {
    state = state.copyWith(surveyData: {...state.surveyData, ...pageData});
  }

  // Extract data for a specific page from survey data
  Map<String, dynamic> _extractPageData(int pageIndex) {
    // helper to pick flat keys from state.surveyData
    Map<String, dynamic> pick(List<String> keys) {
      final out = <String, dynamic>{};
      for (final k in keys) {
        if (state.surveyData.containsKey(k)) out[k] = state.surveyData[k];
      }
      return out;
    }

    switch (pageIndex) {
      case 0: // Location
        return pick([
          'village_name',
          'village_number',
          'panchayat',
          'block',
          'tehsil',
          'district',
          'postal_address',
          'pin_code',
          'state',
          'shine_code',
          'latitude',
          'longitude',
          'location_accuracy',
          'location_timestamp',
        ]);

      case 1: // Family Details
        return {'family_members': state.surveyData['family_members']};

      case 2: // Social Consciousness (pages 2-4 combined)
      case 3:
      case 4:
        if (state.surveyData['social_consciousness'] is Map<String, dynamic>) {
          return {'social_consciousness': state.surveyData['social_consciousness']};
        }
        return {
          'social_consciousness': pick([
            'clothes_frequency',
            'clothes_other_specify',
            'food_waste_exists',
            'food_waste_amount',
            'waste_disposal',
            'waste_disposal_other',
            'separate_waste',
            'compost_pit',
            'recycle_used_items',
            'led_lights',
            'turn_off_devices',
            'fix_leaks',
            'avoid_plastics',
            'family_prayers',
            'family_meditation',
            'meditation_members',
            'family_yoga',
            'yoga_members',
            'community_activities',
            'community_activities_type',
            'shram_sadhana',
            'shram_sadhana_members',
            'spiritual_discourses',
            'discourses_members',
            'personal_happiness',
            'family_happiness',
            'happiness_family_who',
            'financial_problems',
            'family_disputes',
            'illness_issues',
            'unhappiness_reason',
            'addiction_smoke',
            'addiction_drink',
            'addiction_gutka',
            'addiction_gamble',
            'addiction_tobacco',
            'addiction_details',
            'savings_exists',
            'savings_percentage',
          ])
        };

      case 5: // Land Holding
        if (state.surveyData['land_holding'] is Map<String, dynamic>) return {'land_holding': state.surveyData['land_holding']};
        return {
          'land_holding': pick([
            'irrigated_area',
            'cultivable_area',
            'other_orchard_plants',
            'mango_trees',
            'guava_trees',
            'lemon_trees',
            'banana_plants',
            'papaya_trees',
            'other_fruit_trees',
            'other_fruit_trees_count',
          ])
        };

      case 6: // Irrigation
        if (state.surveyData['irrigation_facilities'] is Map<String, dynamic>) return {'irrigation_facilities': state.surveyData['irrigation_facilities']};
        return {
          'irrigation_facilities': pick(['canal', 'tube_well', 'pond', 'other_sources'])
        };

      case 7: // Crop Productivity
        return {'crop_productivity': state.surveyData['crop_productivity']};

      case 8: // Fertilizer
        if (state.surveyData['fertilizer_usage'] is Map<String, dynamic>) return {'fertilizer_usage': state.surveyData['fertilizer_usage']};
        return {
          'fertilizer_usage': pick(['urea_fertilizer', 'organic_fertilizer', 'fertilizer_types'])
        };

      case 9: // Animals
        return {'animals': state.surveyData['animals']};

      case 10: // Equipment
        return {'agricultural_equipment': state.surveyData['agricultural_equipment']};

      case 11: // Entertainment
        if (state.surveyData['entertainment_facilities'] is Map<String, dynamic>) return {'entertainment_facilities': state.surveyData['entertainment_facilities']};
        return {
          'entertainment_facilities': pick([
            'smart_mobile',
            'analog_mobile',
            'television',
            'radio',
            'games',
            'smart_mobile_count',
            'analog_mobile_count',
            'other_entertainment',
          ])
        };

      case 12: // Transport
        if (state.surveyData['transport_facilities'] is Map<String, dynamic>) return {'transport_facilities': state.surveyData['transport_facilities']};
        return {
          'transport_facilities': pick([
            'car_jeep',
            'motorcycle_scooter',
            'e_rickshaw',
            'cycle',
            'pickup_truck',
            'bullock_cart',
          ])
        };

      case 13: // Water Sources
        return {'drinking_water_sources': state.surveyData['drinking_water_sources']};

      case 14: // Medical
        return {'medical_treatment': state.surveyData['medical_treatment']};

      case 15: // Disputes
        return {'disputes': state.surveyData['disputes']};

      case 16: // House Conditions -> build two DB maps: house_conditions (DB column names) + house_facilities
        final houseConditionsMap = <String, dynamic>{};
        final houseFacilitiesMap = <String, dynamic>{};

        // convert UI keys -> DB keys for house_conditions
        if (state.surveyData.containsKey('katcha_house')) houseConditionsMap['katcha'] = state.surveyData['katcha_house'];
        if (state.surveyData.containsKey('pakka_house')) houseConditionsMap['pakka'] = state.surveyData['pakka_house'];
        if (state.surveyData.containsKey('katcha_pakka_house')) houseConditionsMap['katcha_pakka'] = state.surveyData['katcha_pakka_house'];
        if (state.surveyData.containsKey('hut_house')) houseConditionsMap['hut'] = state.surveyData['hut_house'];
        if (state.surveyData.containsKey('toilet_in_use')) houseConditionsMap['toilet_in_use'] = state.surveyData['toilet_in_use'];
        if (state.surveyData.containsKey('toilet_condition')) houseConditionsMap['toilet_condition'] = state.surveyData['toilet_condition'];

        // house facilities (keys mostly match DB but normalize a couple)
        if (state.surveyData.containsKey('toilet')) houseFacilitiesMap['toilet'] = state.surveyData['toilet'];
        if (state.surveyData.containsKey('drainage')) houseFacilitiesMap['drainage'] = state.surveyData['drainage'];
        if (state.surveyData.containsKey('soak_pit')) houseFacilitiesMap['soak_pit'] = state.surveyData['soak_pit'];
        if (state.surveyData.containsKey('cattle_shed')) houseFacilitiesMap['cattle_shed'] = state.surveyData['cattle_shed'];
        if (state.surveyData.containsKey('compost_pit')) houseFacilitiesMap['compost_pit'] = state.surveyData['compost_pit'];
        if (state.surveyData.containsKey('nadep')) houseFacilitiesMap['nadep'] = state.surveyData['nadep'];
        if (state.surveyData.containsKey('lpg_gas')) houseFacilitiesMap['lpg_gas'] = state.surveyData['lpg_gas'];
        if (state.surveyData.containsKey('biogas')) houseFacilitiesMap['biogas'] = state.surveyData['biogas'];
        if (state.surveyData.containsKey('solar_cooking')) houseFacilitiesMap['solar_cooking'] = state.surveyData['solar_cooking'];
        if (state.surveyData.containsKey('electric_connection')) houseFacilitiesMap['electric_connection'] = state.surveyData['electric_connection'];
        if (state.surveyData.containsKey('nutritional_garden')) houseFacilitiesMap['nutritional_garden_available'] = state.surveyData['nutritional_garden'];
        if (state.surveyData.containsKey('tulsi_plants')) houseFacilitiesMap['tulsi_plants_available'] = state.surveyData['tulsi_plants'];

        final result = <String, dynamic>{};
        if (houseConditionsMap.isNotEmpty) result['house_conditions'] = houseConditionsMap;
        if (houseFacilitiesMap.isNotEmpty) result['house_facilities'] = houseFacilitiesMap;
        return result;

      case 17: // Diseases
        return {'diseases': state.surveyData['diseases']};

      case 18: // Government Schemes
        return {'government_schemes': state.surveyData['government_schemes']};

      case 19: // Folklore Medicine
        // pages emit 'folklore_medicines' list but DB expects 'folklore_medicine'
        return {
          'folklore_medicine': state.surveyData['folklore_medicine'] ?? state.surveyData['folklore_medicines'] ?? []
        };

      case 20: // Health Programme
        if (state.surveyData['health_programme'] is Map<String, dynamic>) return {'health_programme': state.surveyData['health_programme']};
        return {
          'health_programme': pick([
            'vaccination_pregnancy',
            'child_vaccination',
            'vaccination_schedule',
            'balance_doses_schedule',
            'family_planning_awareness',
            'contraceptive_applied',
          ])
        };

      case 21: // Children
        return {'children': state.surveyData['children']};

      case 22: // Migration
        return {'migration': state.surveyData['migration']};

      case 23: // Training
        return {'training': state.surveyData['training']};

      case 24: // VB-G RAM-G
        return {'vb_g_ram_g_beneficiary': state.surveyData['vb_g_ram_g_beneficiary']};

      case 25: // PM Kisan Nidhi
        return {'pm_kisan_nidhi': state.surveyData['pm_kisan_nidhi']};

      case 26: // PM Kisan Samman
        return {'pm_kisan_samman_nidhi': state.surveyData['pm_kisan_samman_nidhi']};

      case 27: // Kisan Credit Card
        return {'kisan_credit_card': state.surveyData['kisan_credit_card']};

      case 28: // Swachh Bharat
        return {'swachh_bharat_mission': state.surveyData['swachh_bharat_mission']};

      case 29: // Fasal Bima
        return {'fasal_bima': state.surveyData['fasal_bima']};

      case 30: // Bank Account
        return {'bank_accounts': state.surveyData['bank_accounts']};

      default:
        return {};
    }
  }

  // Save page data to appropriate database tables
  Future<void> _savePageDataToDatabase(int pageIndex, Map<String, dynamic> pageData, String phoneNumber) async {
    switch (pageIndex) {
      case 0: // Location - already saved in family_survey_sessions
        await _databaseService.updateSurveySession(phoneNumber, pageData);
        break;
      case 1: // Family Members
        await _saveFamilyMembers(pageData['family_members'], phoneNumber);
        break;
      case 2: // Social Consciousness 1
      case 3: // Social Consciousness 2
      case 4: // Social Consciousness 3
        await _saveSocialConsciousness(pageData['social_consciousness'], phoneNumber);
        break;
      case 5: // Land Holding
        await _saveLandHolding(pageData['land_holding'], phoneNumber);
        break;
      case 6: // Irrigation
        await _saveIrrigationFacilities(pageData['irrigation_facilities'], phoneNumber);
        break;
      case 7: // Crop Productivity
        await _saveCropProductivity(pageData['crop_productivity'], phoneNumber);
        break;
      case 8: // Fertilizer
        await _saveFertilizerUsage(pageData['fertilizer_usage'], phoneNumber);
        break;
      case 9: // Animals
        await _saveAnimals(pageData['animals'], phoneNumber);
        break;
      case 10: // Equipment
        await _saveAgriculturalEquipment(pageData['agricultural_equipment'], phoneNumber);
        break;
      case 11: // Entertainment
        await _saveEntertainmentFacilities(pageData['entertainment_facilities'], phoneNumber);
        break;
      case 12: // Transport
        await _saveTransportFacilities(pageData['transport_facilities'], phoneNumber);
        break;
      case 13: // Water Sources
        await _saveDrinkingWaterSources(pageData['drinking_water_sources'], phoneNumber);
        break;
      case 14: // Medical
        await _saveMedicalTreatment(pageData['medical_treatment'], phoneNumber);
        break;
      case 15: // Disputes
        await _saveDisputes(pageData['disputes'], phoneNumber);
        break;
      case 16: // House Conditions
        await _saveHouseConditions(pageData['house_conditions'], phoneNumber);
        await _saveHouseFacilities(pageData['house_facilities'], phoneNumber);
        break;
      case 17: // Diseases
        await _saveDiseases(pageData['diseases'], phoneNumber);
        break;
      case 18: // Government Schemes
        await _saveGovernmentSchemes(pageData['government_schemes'], phoneNumber);
        break;
      case 19: // Folklore Medicine
        await _saveFolkloreMedicine(pageData['folklore_medicine'], phoneNumber);
        break;
      case 20: // Health Programme
        await _saveHealthProgramme(pageData['health_programme'], phoneNumber);
        break;
      case 21: // Children
        await _saveChildren(pageData['children'], phoneNumber);
        break;
      case 22: // Migration
        await _saveMigration(pageData['migration'], phoneNumber);
        break;
      case 23: // Training
        await _saveTraining(pageData['training'], phoneNumber);
        break;
      case 24: // VB-G RAM-G
        await _saveVbGRamGBeneficiary(pageData['vb_g_ram_g_beneficiary'], phoneNumber);
        break;
      case 25: // PM Kisan Nidhi
        await _savePmKisanNidhi(pageData['pm_kisan_nidhi'], phoneNumber);
        break;
      case 26: // PM Kisan Samman
        await _savePmKisanSammanNidhi(pageData['pm_kisan_samman_nidhi'], phoneNumber);
        break;
      case 27: // Kisan Credit Card
        await _saveKisanCreditCard(pageData['kisan_credit_card'], phoneNumber);
        break;
      case 28: // Swachh Bharat
        await _saveSwachhBharatMission(pageData['swachh_bharat_mission'], phoneNumber);
        break;
      case 29: // Fasal Bima
        await _saveFasalBima(pageData['fasal_bima'], phoneNumber);
        break;
      case 30: // Bank Account
        await _saveBankAccount(pageData['bank_accounts'], phoneNumber);
        break;
    }
  }

  // Load page data from database
  Future<Map<String, dynamic>> _loadPageDataFromDatabase(int pageIndex, String phoneNumber) async {
    switch (pageIndex) {
      case 0: // Location
        final session = await _databaseService.getSurveySession(phoneNumber);
        return session ?? {};
      case 1: // Family Members
        final members = await _databaseService.getData('family_members', phoneNumber);
        return {'family_members': members};
      case 2: // Social Consciousness 1
      case 3: // Social Consciousness 2
      case 4: // Social Consciousness 3
        final social = await _databaseService.getData('social_consciousness', phoneNumber);
        return {'social_consciousness': social.isNotEmpty ? social.first : {}};
      case 5: // Land Holding
        final land = await _databaseService.getData('land_holding', phoneNumber);
        return {'land_holding': land.isNotEmpty ? land.first : {}};
      case 6: // Irrigation
        final irrigation = await _databaseService.getData('irrigation_facilities', phoneNumber);
        return {'irrigation_facilities': irrigation.isNotEmpty ? irrigation.first : {}};
      case 7: // Crop Productivity
        final crops = await _databaseService.getData('crop_productivity', phoneNumber);
        return {'crop_productivity': crops};
      case 8: // Fertilizer
        final fertilizer = await _databaseService.getData('fertilizer_usage', phoneNumber);
        return {'fertilizer_usage': fertilizer.isNotEmpty ? fertilizer.first : {}};
      case 9: // Animals
        final animals = await _databaseService.getData('animals', phoneNumber);
        return {'animals': animals};
      case 10: // Equipment
        final equipment = await _databaseService.getData('agricultural_equipment', phoneNumber);
        return {'agricultural_equipment': equipment};
      case 11: // Entertainment
        final entertainment = await _databaseService.getData('entertainment_facilities', phoneNumber);
        return {'entertainment_facilities': entertainment.isNotEmpty ? entertainment.first : {}};
      case 12: // Transport
        final transport = await _databaseService.getData('transport_facilities', phoneNumber);
        return {'transport_facilities': transport.isNotEmpty ? transport.first : {}};
      case 13: // Water Sources
        final water = await _databaseService.getData('drinking_water_sources', phoneNumber);
        return {'drinking_water_sources': water};
      case 14: // Medical
        final medical = await _databaseService.getData('medical_treatment', phoneNumber);
        return {'medical_treatment': medical.isNotEmpty ? medical.first : {}};
      case 15: // Disputes
        final disputes = await _databaseService.getData('disputes', phoneNumber);
        return {'disputes': disputes.isNotEmpty ? disputes.first : {}};
      case 16: // House Conditions
        final houseConditions = await _databaseService.getData('house_conditions', phoneNumber);
        final houseFacilities = await _databaseService.getData('house_facilities', phoneNumber);
        return {
          'house_conditions': houseConditions.isNotEmpty ? houseConditions.first : {},
          'house_facilities': houseFacilities.isNotEmpty ? houseFacilities.first : {},
        };
      case 17: // Diseases
        final diseases = await _databaseService.getData('diseases', phoneNumber);
        return {'diseases': diseases.isNotEmpty ? diseases.first : {}};
      case 18: // Government Schemes
        final schemes = await _databaseService.getData('government_schemes', phoneNumber);
        return {'government_schemes': schemes.isNotEmpty ? schemes.first : {}};
      case 19: // Folklore Medicine
        final medicine = await _databaseService.getData('folklore_medicine', phoneNumber);
        return {'folklore_medicine': medicine.isNotEmpty ? medicine.first : {}};
      case 20: // Health Programme
        final health = await _databaseService.getData('health_programmes', phoneNumber);
        return {'health_programme': health.isNotEmpty ? health.first : {}};
      case 21: // Children
        final children = await _databaseService.getData('children_data', phoneNumber);
        return {'children': children};
      case 22: // Migration
        final migration = await _databaseService.getData('migration_data', phoneNumber);
        return {'migration': migration.isNotEmpty ? migration.first : {}};
      case 23: // Training
        final training = await _databaseService.getData('training_data', phoneNumber);
        return {'training': training.isNotEmpty ? training.first : {}};
      case 24: // VB-G RAM-G
        final vbG = await _databaseService.getData('vb_gram', phoneNumber);
        return {'vb_g_ram_g_beneficiary': vbG.isNotEmpty ? vbG.first : {}};
      case 25: // PM Kisan Nidhi
        final pmKisan = await _databaseService.getData('pm_kisan_nidhi', phoneNumber);
        return {'pm_kisan_nidhi': pmKisan.isNotEmpty ? pmKisan.first : {}};
      case 26: // PM Kisan Samman
        final pmKisanSamman = await _databaseService.getData('pm_kisan_samman_nidhi', phoneNumber);
        return {'pm_kisan_samman_nidhi': pmKisanSamman.isNotEmpty ? pmKisanSamman.first : {}};
      case 27: // Kisan Credit Card
        final kcc = await _databaseService.getData('kisan_credit_card', phoneNumber);
        return {'kisan_credit_card': kcc.isNotEmpty ? kcc.first : {}};
      case 28: // Swachh Bharat
        final swachh = await _databaseService.getData('swachh_bharat_mission', phoneNumber);
        return {'swachh_bharat_mission': swachh.isNotEmpty ? swachh.first : {}};
      case 29: // Fasal Bima
        final fasal = await _databaseService.getData('fasal_bima', phoneNumber);
        return {'fasal_bima': fasal.isNotEmpty ? fasal.first : {}};
      case 30: // Bank Account
        final bank = await _databaseService.getData('bank_accounts', phoneNumber);
        return {'bank_accounts': bank};
      default:
        return {};
    }
  }

  // Update page completion status
  Future<void> _updatePageCompletionStatus(int pageIndex, bool completed) async {
    if (state.phoneNumber == null) return;

    await _databaseService.updatePageStatus(state.phoneNumber!, pageIndex, completed);
  }

  // Save methods for each data type
  Future<void> _saveFamilyMembers(dynamic members, String phoneNumber) async {
    // Ensure phoneNumber exists (caller should guarantee this via effectivePhone)
    if (phoneNumber.isEmpty) {
      debugPrint('Skipping saveFamilyMembers: phoneNumber empty');
      return;
    }

    if (members is! List) return;

    for (int i = 0; i < members.length; i++) {
      final raw = members[i];
      if (raw is! Map<String, dynamic>) continue;

      final member = Map<String, dynamic>.from(raw);

      // Ensure required fields for DB
      // sr_no must be integer
      final sr = member['sr_no'];
      if (sr is String) {
        member['sr_no'] = int.tryParse(sr) ?? (i + 1);
      } else if (sr is num) {
        member['sr_no'] = sr.toInt();
      } else if (sr == null) {
        member['sr_no'] = i + 1;
      }

      // name must be present (DB allows empty string but not null)
      if (!member.containsKey('name') || member['name'] == null) member['name'] = '';

      // Ensure phone_number present and don't set 'id' locally — DB will assign gen_random_uuid()
      member['phone_number'] = phoneNumber;

      try {
        await _databaseService.insertOrUpdate('family_members', member, phoneNumber);
      } catch (e, st) {
        // Log and continue — do not throw to avoid blocking navigation for other pages
        debugPrint('Failed to save family_member (sr_no=${member['sr_no']}) for $phoneNumber: $e');
        debugPrint(st.toString());
      }
    }

    // After saving all members, refresh from DB so generated IDs (server defaults) are reflected in memory
    try {
      final refreshed = await _databaseService.getData('family_members', phoneNumber);
      state = state.copyWith(surveyData: {...state.surveyData, 'family_members': refreshed});
    } catch (e) {
      debugPrint('Failed to refresh family_members from DB: $e');
    }
  }

  Future<void> _saveSocialConsciousness(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      try {
        await _databaseService.insertOrUpdate('social_consciousness', data, phoneNumber);
      } catch (e, st) {
        debugPrint('Failed to save social_consciousness for $phoneNumber: $e');
        debugPrint(st.toString());
      }
    }
  }

  Future<void> _saveLandHolding(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('land_holding', data, phoneNumber);
    }
  }

  Future<void> _saveIrrigationFacilities(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('irrigation_facilities', data, phoneNumber);
    }
  }

  Future<void> _saveCropProductivity(dynamic crops, String phoneNumber) async {
    if (crops is! List) return;
    for (final crop in crops) {
      if (crop is Map<String, dynamic>) {
        try {
          await _databaseService.insertOrUpdate('crop_productivity', crop, phoneNumber);
        } catch (e, st) {
          debugPrint('Failed to save crop_productivity for $phoneNumber: $e');
          debugPrint(st.toString());
        }
      }
    }
  }

  Future<void> _saveFertilizerUsage(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('fertilizer_usage', data, phoneNumber);
    }
  }

  Future<void> _saveAnimals(dynamic animals, String phoneNumber) async {
    if (animals is! List) return;
    for (final animal in animals) {
      if (animal is Map<String, dynamic>) {
        await _databaseService.insertOrUpdate('animals', animal, phoneNumber);
      }
    }
  }

  Future<void> _saveAgriculturalEquipment(dynamic equipment, String phoneNumber) async {
    if (equipment is! List) return;
    for (final item in equipment) {
      if (item is Map<String, dynamic>) {
        await _databaseService.insertOrUpdate('agricultural_equipment', item, phoneNumber);
      }
    }
  }

  Future<void> _saveEntertainmentFacilities(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('entertainment_facilities', data, phoneNumber);
    }
  }

  Future<void> _saveTransportFacilities(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('transport_facilities', data, phoneNumber);
    }
  }

  Future<void> _saveDrinkingWaterSources(dynamic sources, String phoneNumber) async {
    if (sources is! List) return;
    for (final source in sources) {
      if (source is Map<String, dynamic>) {
        await _databaseService.insertOrUpdate('drinking_water_sources', source, phoneNumber);
      }
    }
  }

  Future<void> _saveMedicalTreatment(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('medical_treatment', data, phoneNumber);
    }
  }

  Future<void> _saveDisputes(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('disputes', data, phoneNumber);
    }
  }

  Future<void> _saveHouseConditions(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('house_conditions', data, phoneNumber);
    }
  }

  Future<void> _saveHouseFacilities(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('house_facilities', data, phoneNumber);
    }
  }

  Future<void> _saveDiseases(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('diseases', data, phoneNumber);
    }
  }

  Future<void> _saveGovernmentSchemes(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('government_schemes', data, phoneNumber);
    }
  }

  Future<void> _saveFolkloreMedicine(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('folklore_medicine', data, phoneNumber);
    }
  }

  Future<void> _saveHealthProgramme(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('health_programmes', data, phoneNumber);
    }
  }

  Future<void> _saveChildren(dynamic children, String phoneNumber) async {
    if (children is! List) return;
    for (final child in children) {
      if (child is Map<String, dynamic>) {
        await _databaseService.insertOrUpdate('children_data', child, phoneNumber);
      }
    }
  }

  Future<void> _saveMigration(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('migration_data', data, phoneNumber);
    }
  }

  Future<void> _saveTraining(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('training_data', data, phoneNumber);
    }
  }

  Future<void> _saveVbGRamGBeneficiary(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('vb_gram', data, phoneNumber);
    }
  }

  Future<void> _savePmKisanNidhi(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('pm_kisan_nidhi', data, phoneNumber);
    }
  }

  Future<void> _savePmKisanSammanNidhi(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('pm_kisan_samman_nidhi', data, phoneNumber);
    }
  }

  Future<void> _saveKisanCreditCard(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('kisan_credit_card', data, phoneNumber);
    }
  }

  Future<void> _saveSwachhBharatMission(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('swachh_bharat_mission', data, phoneNumber);
    }
  }

  Future<void> _saveFasalBima(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('fasal_bima', data, phoneNumber);
    }
  }

  Future<void> _saveBankAccount(dynamic data, String phoneNumber) async {
    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          try {
            await _databaseService.insertOrUpdate('bank_accounts', item, phoneNumber);
          } catch (e, st) {
            debugPrint('Failed to save bank_account item for $phoneNumber: $e');
            debugPrint(st.toString());
          }
        }
      }
    } else if (data is Map<String, dynamic>) {
      try {
        await _databaseService.insertOrUpdate('bank_accounts', data, phoneNumber);
      } catch (e, st) {
        debugPrint('Failed to save bank_account map for $phoneNumber: $e');
        debugPrint(st.toString());
      }
    }
  }

  // Jump to a specific page
  void jumpToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < state.totalPages) {
      state = state.copyWith(currentPage: pageIndex);
      debugPrint('Jumped to page $pageIndex');
    }
  }

  // Go to next page
  void nextPage() {
    if (state.currentPage < state.totalPages - 1) {
      state = state.copyWith(currentPage: state.currentPage + 1);
      debugPrint('Moved to next page: ${state.currentPage}');
    }
  }

  // Go to previous page
  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      debugPrint('Moved to previous page: ${state.currentPage}');
    }
  }

  // Complete survey
  Future<void> completeSurvey() async {
    if (state.phoneNumber == null) return;

    // Save any remaining data
    await saveCurrentPageData();

    // Update survey status to completed
    await _databaseService.updateSurveyStatus(state.phoneNumber!, 'completed');

    // Update all pages as completed
    for (int i = 0; i < state.totalPages; i++) {
      await _updatePageCompletionStatus(i, true);
    }

    // Trigger sync of all pending pages to Supabase
    _syncService.syncAllPendingPages()
        .catchError((e) {
      debugPrint('Page sync failed: $e');
    });

    debugPrint('Survey completed for phone number: ${state.phoneNumber}');
  }

  // Load an existing survey for preview (loads full dataset into provider state)
  Future<void> loadSurveySessionForPreview(String sessionId) async {
    if (sessionId.isEmpty) return;

    try {
      final session = await _databaseService.getSurveySession(sessionId);
      if (session == null) {
        debugPrint('Preview session not found: $sessionId');
        return;
      }

      // Aggregate commonly used tables (same shape as preview page expects)
      final familyMembers = await _databaseService.getData('family_members', sessionId);
      final social = await _databaseService.getData('social_consciousness', sessionId);
      final tribal = await _databaseService.getData('tribal_questions', sessionId);
      final land = await _databaseService.getData('land_holding', sessionId);
      final irrigation = await _databaseService.getData('irrigation_facilities', sessionId);
      final crops = await _databaseService.getData('crop_productivity', sessionId);
      final fertilizer = await _databaseService.getData('fertilizer_usage', sessionId);
      final animals = await _databaseService.getData('animals', sessionId);
      final equipment = await _databaseService.getData('agricultural_equipment', sessionId);
      final entertainment = await _databaseService.getData('entertainment_facilities', sessionId);
      final transport = await _databaseService.getData('transport_facilities', sessionId);
      final water = await _databaseService.getData('drinking_water_sources', sessionId);
      final medical = await _databaseService.getData('medical_treatment', sessionId);
      final disputes = await _databaseService.getData('disputes', sessionId);
      final houseConditions = await _databaseService.getData('house_conditions', sessionId);
      final houseFacilities = await _databaseService.getData('house_facilities', sessionId);
      final diseases = await _databaseService.getData('diseases', sessionId);
      final schemes = await _databaseService.getData('merged_govt_schemes', sessionId);

      // Government scheme info (only first row expected)
      final aadhaarInfo = await _databaseService.getData('aadhaar_info', sessionId);
      final ayushmanCard = await _databaseService.getData('ayushman_card', sessionId);
      final familyId = await _databaseService.getData('family_id', sessionId);
      final rationCard = await _databaseService.getData('ration_card', sessionId);
      final samagraId = await _databaseService.getData('samagra_id', sessionId);
      final tribalCard = await _databaseService.getData('tribal_card', sessionId);

      // Other lists
      final children = await _databaseService.getData('children_data', sessionId);
      final training = await _databaseService.getData('training_data', sessionId);
      final bank = await _databaseService.getData('bank_accounts', sessionId);

      final aggregated = <String, dynamic>{
        ...session,
        'family_members': familyMembers,
        'social_consciousness': social.isNotEmpty ? social.first : {},
        'tribal_questions': tribal.isNotEmpty ? tribal.first : {},
        'land_holding': land.isNotEmpty ? land.first : {},
        'irrigation_facilities': irrigation.isNotEmpty ? irrigation.first : {},
        'crop_productivity': crops,
        'fertilizer_usage': fertilizer.isNotEmpty ? fertilizer.first : {},
        'animals': animals,
        'agricultural_equipment': equipment.isNotEmpty ? equipment.first : {},
        'entertainment_facilities': entertainment.isNotEmpty ? entertainment.first : {},
        'transport_facilities': transport.isNotEmpty ? transport.first : {},
        'drinking_water_sources': water.isNotEmpty ? water.first : {},
        'medical_treatment': medical.isNotEmpty ? medical.first : {},
        'disputes': disputes.isNotEmpty ? disputes.first : {},
        'house_conditions': houseConditions.isNotEmpty ? houseConditions.first : {},
        'house_facilities': houseFacilities.isNotEmpty ? houseFacilities.first : {},
        'diseases': diseases,
        'merged_govt_schemes': schemes.isNotEmpty ? schemes.first : {},
        'aadhaar_info': aadhaarInfo.isNotEmpty ? aadhaarInfo.first : {},
        'ayushman_card': ayushmanCard.isNotEmpty ? ayushmanCard.first : {},
        'family_id': familyId.isNotEmpty ? familyId.first : {},
        'ration_card': rationCard.isNotEmpty ? rationCard.first : {},
        'samagra_id': samagraId.isNotEmpty ? samagraId.first : {},
        'tribal_card': tribalCard.isNotEmpty ? tribalCard.first : {},
        'children_data': children,
        'training_data': training,
        'bank_accounts': bank,
      };

      // Update provider state (phoneNumber kept as the session identifier)
      state = state.copyWith(
        phoneNumber: sessionId,
        surveyData: aggregated,
      );
    } catch (e) {
      debugPrint('Error loading preview session $sessionId: $e');
    }
  }

  // Load an existing survey for continuation (populate in-memory state and optionally jump to a page)
  Future<void> loadSurveySessionForContinuation(String sessionId, {int startPage = 0}) async {
    if (sessionId.isEmpty) return;

    try {
      final session = await _databaseService.getSurveySession(sessionId);
      if (session == null) {
        debugPrint('Continuation session not found: $sessionId');
        return;
      }

      // Set basic session data into state and set the current page
      state = state.copyWith(
        phoneNumber: sessionId,
        surveyData: {...state.surveyData, ...session},
        currentPage: startPage,
      );

      // Load the specific start page into memory so the UI can render it immediately
      await loadPageData(startPage);
    } catch (e) {
      debugPrint('Error loading continuation session $sessionId: $e');
    }
  }

  // Update locally stored surveys that are missing surveyor_email (called after login)
  Future<void> updateExistingSurveyEmails() async {
    final userEmail = _supabaseService.currentUser?.email;
    if (userEmail == null || userEmail.isEmpty) {
      debugPrint('No authenticated user available to update survey emails');
      return;
    }

    try {
      final sessions = await _databaseService.getAllSurveySessions();
      for (final s in sessions) {
        final phone = s['phone_number']?.toString();
        final existingEmail = s['surveyor_email']?.toString() ?? '';
        if (phone == null || phone.isEmpty) continue;

        if (existingEmail.isEmpty || existingEmail == 'unknown') {
          // Update locally
          await _databaseService.updateSurveySession(phone, {'surveyor_email': userEmail});

          // If online, also upsert to Supabase to keep server-side RLS satisfied
          try {
            if (await _supabaseService.isOnline()) {
              await _supabaseService.client.from('family_survey_sessions').upsert({
                'phone_number': phone,
                'surveyor_email': userEmail,
                'updated_at': DateTime.now().toIso8601String(),
              });
            }
          } catch (e) {
            // Queue via generic SyncService as a fallback
            await _syncService.queueSyncOperation('sync_session', {
              'phone_number': phone,
              'data': {'surveyor_email': userEmail},
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating existing survey emails: $e');
    }
  }

  // Initialize survey with basic info
  Future<void> initializeSurvey({
    String? villageName,
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
    if (phoneNumber == null) return;

    // Create or update survey session (include surveyor_email to satisfy DB NOT NULL)
    await _databaseService.saveData('family_survey_sessions', {
      'phone_number': phoneNumber,
      'surveyor_email': _supabaseService.currentUser?.email ?? 'unknown',
      'surveyor_name': surveyorName,
      'village_name': villageName,
      'village_number': villageNumber,
      'panchayat': panchayat,
      'block': block,
      'tehsil': tehsil,
      'district': district,
      'postal_address': postalAddress,
      'pin_code': pinCode,
      'status': 'in_progress',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Update state
    state = state.copyWith(
      phoneNumber: phoneNumber,
      surveyData: {
        ...state.surveyData,
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
      },
    );

    debugPrint('Survey initialized for phone number: $phoneNumber');
  }
}

// Provider declaration
final surveyProvider = NotifierProvider<SurveyNotifier, SurveyState>(() {
  return SurveyNotifier();
});