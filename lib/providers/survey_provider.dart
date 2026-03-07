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

  final SupabaseService _supabaseService = SupabaseService.instance;
  final SyncService _syncService = SyncService.instance;

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
        if (sessionPayload['surveyor_email'] == null || sessionPayload['surveyor_email'].toString().isEmpty) {
          sessionPayload['surveyor_email'] = 'unknown';
        }

        await _databaseService.insertOrUpdate('family_survey_sessions', sessionPayload, effectivePhone);
        await _syncService.syncFamilyPageData(effectivePhone, 0, pageData);
        await _updatePageCompletionStatus(0, true);
        debugPrint('Started family session upsert for page 0 (phone: $effectivePhone) — result will be reported by SyncService');
      } else {
        // All other pages: save locally and start a background cloud sync.
        // We await the local DB work to ensure durability, but do not await
        // the remote upsert so navigation is not blocked.
        await _savePageDataToDatabase(state.currentPage, pageData, effectivePhone);
        await _updatePageCompletionStatus(state.currentPage, true);

        // Fire-and-forget remote sync; log any startup errors but don't await.
        try {
          _syncService.syncFamilyPageData(effectivePhone, state.currentPage, pageData)
              .catchError((e, st) {
            debugPrint('Background syncFamilyPageData failed to start for $effectivePhone page ${state.currentPage}: $e');
            debugPrint(st.toString());
          });
        } catch (e, st) {
          debugPrint('Failed to initiate background syncFamilyPageData: $e');
          debugPrint(st.toString());
        }

        debugPrint('Saved page ${state.currentPage} locally and started background cloud sync for phone: $effectivePhone');
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
            } else if (key == 'folklore_medicine') {
              // pages expect a list called 'folklore_medicines'; turn map/list into list
              // `value` is guaranteed to be a Map<String, dynamic> because of outer if
              flattened['folklore_medicines'] = [Map<String, dynamic>.from(value)];
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

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value.map<Map<String, dynamic>>((item) => _asMap(item)).toList();
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().trim().toLowerCase();
    return text == 'yes' || text == 'true' || text == '1';
  }

  String _toYesNo(dynamic value) => _isTruthy(value) ? 'yes' : 'no';

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
        final equipmentMap = <String, dynamic>{};
        if (state.surveyData['agricultural_equipment'] is Map) {
          equipmentMap.addAll(state.surveyData['agricultural_equipment']);
        }
        for (final k in [
          'tractor', 'tractor_condition',
          'thresher', 'thresher_condition',
          'seed_drill', 'seed_drill_condition',
          'sprayer', 'sprayer_condition',
          'duster', 'duster_condition',
          'diesel_engine', 'diesel_engine_condition',
          'other_equipment',
        ]) {
          if (state.surveyData.containsKey(k)) equipmentMap[k] = state.surveyData[k];
        }
        return {'agricultural_equipment': equipmentMap};

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
        final sources = <String, dynamic>{};
        if (state.surveyData['drinking_water_sources'] is Map) {
          sources.addAll(state.surveyData['drinking_water_sources']);
        }
        for (final k in [
          'hand_pumps','hand_pumps_distance','hand_pumps_quality',
          'well','well_distance','well_quality',
          'tubewell','tubewell_distance','tubewell_quality',
          'nal_jaal','nal_jaal_quality',
          'other_source','other_distance','other_sources_quality',
        ]) {
          if (state.surveyData.containsKey(k)) sources[k] = state.surveyData[k];
        }
        return {'drinking_water_sources': sources};

      case 14: // Medical
        final medMap = <String, dynamic>{};
        if (state.surveyData['medical_treatment'] is Map) {
          medMap.addAll(state.surveyData['medical_treatment']);
        }
        for (final k in ['allopathic','ayurvedic','homeopathy','traditional','other_treatment','preferred_treatment']) {
          if (state.surveyData.containsKey(k)) medMap[k] = state.surveyData[k];
        }
        return {'medical_treatment': medMap};

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
        final diseaseData = state.surveyData['diseases'];
        if (diseaseData is Map || diseaseData is List) {
          return {'diseases': diseaseData};
        }
        final flatMembers = _asMapList(state.surveyData['members']);
        if (flatMembers.isNotEmpty) {
          return {
            'diseases': {
              'is_beneficiary': state.surveyData['is_beneficiary'] ?? true,
              'members': flatMembers,
            }
          };
        }
        return {'diseases': const <Map<String, dynamic>>[]};

      case 18: // Government Schemes
        if (state.surveyData['government_schemes'] is Map<String, dynamic>) {
          return {'government_schemes': state.surveyData['government_schemes']};
        }
        return {
          'government_schemes': {
            'aadhaar_scheme_members': state.surveyData['aadhaar_scheme_members'] ?? [],
            'ayushman_scheme_members': state.surveyData['ayushman_scheme_members'] ?? [],
            'ration_scheme_members': state.surveyData['ration_scheme_members'] ?? [],
            'family_id_scheme_members': state.surveyData['family_id_scheme_members'] ?? [],
            'samagra_scheme_members': state.surveyData['samagra_scheme_members'] ?? [],
            'handicapped_scheme_members': state.surveyData['handicapped_scheme_members'] ?? [],
            'tribal_scheme_members': state.surveyData['tribal_scheme_members'] ?? [],
            'pension_scheme_members': state.surveyData['pension_scheme_members'] ?? [],
            'widow_scheme_members': state.surveyData['widow_scheme_members'] ?? [],
          }
        };

      case 19: // Folklore Medicine
        return {
          'folklore_medicines': state.surveyData['folklore_medicines'] ?? state.surveyData['folklore_medicine'] ?? []
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
        if (state.surveyData['children'] is Map<String, dynamic>) {
          return {
            'children': state.surveyData['children'],
            'malnourished_children_data': state.surveyData['malnourished_children_data'],
          };
        }
        final children = pick([
          'births_last_3_years',
          'infant_deaths_last_3_years',
          'malnourished_children',
        ]);
        final childrenResult = <String, dynamic>{};
        if (children.isNotEmpty) {
          childrenResult['children'] = children;
        }
        if (state.surveyData['malnourished_children_data'] != null) {
          childrenResult['malnourished_children_data'] = state.surveyData['malnourished_children_data'];
        }
        return childrenResult;

      case 22: // Migration
        if (state.surveyData['migration'] is Map<String, dynamic>) {
          return {'migration': state.surveyData['migration']};
        }
        return {
          'migration': {
            ...pick([
              'family_members_migrated',
              'reason',
              'duration',
              'destination',
              'no_migration',
              'migrated_members_json',
            ]),
            if (state.surveyData['migrated_members'] != null)
              'migrated_members': state.surveyData['migrated_members'],
          }
        };

      case 23: // Training
        if (state.surveyData['training'] is Map<String, dynamic>) {
          return {'training': state.surveyData['training']};
        }
        return {
          'training': {
            'training_members': state.surveyData['training_members'] ?? [],
            'want_training': state.surveyData['want_training'] ?? false,
            'shg_members': state.surveyData['shg_members'] ?? [],
            'fpo_members': state.surveyData['fpo_members'] ?? [],
          }
        };

      case 24: // VB-G RAM-G
        return {'vb_gram': state.surveyData['vb_gram'] ?? state.surveyData['vb_g_ram_g_beneficiary']};

      case 25: // PM Kisan Nidhi
        return {'pm_kisan_nidhi': state.surveyData['pm_kisan_nidhi']};

      case 26: // PM Kisan Samman
        return {'pm_kisan_samman_nidhi': state.surveyData['pm_kisan_samman_nidhi']};

      case 27: // Kisan Credit Card
        return {'kisan_credit_card': state.surveyData['kisan_credit_card']};

      case 28: // Swachh Bharat
        return {'swachh_bharat_mission': state.surveyData['swachh_bharat_mission'] ?? state.surveyData['swachh_bharat']};

      case 29: // Fasal Bima
        return {'fasal_bima': state.surveyData['fasal_bima']};

      case 30: // Bank Account
        final ba = <String, dynamic>{};
        if (state.surveyData['bank_accounts'] is Map) {
          ba.addAll(state.surveyData['bank_accounts']);
        }
        if (state.surveyData.containsKey('members')) ba['members'] = state.surveyData['members'];
        if (state.surveyData.containsKey('is_beneficiary')) ba['is_beneficiary'] = state.surveyData['is_beneficiary'];
        return {'bank_accounts': ba};

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
        // UI always sends a list under "crop_productivity" but we tolerate flat payloads
        final cropData = pageData['crop_productivity'] ?? pageData;
        await _saveCropProductivity(cropData, phoneNumber);
        break;
      case 8: // Fertilizer
        await _saveFertilizerUsage(pageData['fertilizer_usage'], phoneNumber);
        break;
      case 9: // Animals
        await _saveAnimals(pageData['animals'], phoneNumber);
        break;
      case 10: // Equipment
        // equipment page returns flat keys rather than a nested map
        final equipData = pageData['agricultural_equipment'] ?? pageData;
        await _saveAgriculturalEquipment(equipData, phoneNumber);
        break;
      case 11: // Entertainment
        await _saveEntertainmentFacilities(pageData['entertainment_facilities'], phoneNumber);
        break;
      case 12: // Transport
        await _saveTransportFacilities(pageData['transport_facilities'], phoneNumber);
        break;
      case 13: // Water Sources
        final waterData = pageData['drinking_water_sources'] ?? pageData;
        await _saveDrinkingWaterSources(waterData, phoneNumber);
        break;
      case 14: // Medical
        final medData = pageData['medical_treatment'] ?? pageData;
        await _saveMedicalTreatment(medData, phoneNumber);
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
        await _saveGovernmentSchemes(pageData['government_schemes'] ?? pageData, phoneNumber);
        break;
      case 19: // Folklore Medicine
        // pages currently emit list under 'folklore_medicines'
        final folData = pageData['folklore_medicine'] ?? pageData['folklore_medicines'] ?? pageData;
        await _saveFolkloreMedicine(folData, phoneNumber);
        break;
      case 20: // Health Programme
        await _saveHealthProgramme(pageData['health_programme'], phoneNumber);
        break;
      case 21: // Children
        // top‑level keys are used rather than a nested 'children' map
        final childrenMap = pageData['children'] ?? pageData['children_data'] ?? pageData;
        if (childrenMap is Map) {
          await _databaseService.insertOrUpdate('children_data', _asMap(childrenMap), phoneNumber);
        }
        await _saveMalnourishedChildrenData(pageData['malnourished_children_data'] ?? [], phoneNumber);
        break;
      case 22: // Migration
        await _saveMigration(pageData['migration'], phoneNumber);
        break;
      case 23: // Training
        await _saveTraining(pageData['training'] ?? pageData, phoneNumber);
        break;
      case 24: // VB-G RAM-G
        await _saveVbGRamGBeneficiary(pageData['vb_gram'] ?? pageData['vb_g_ram_g_beneficiary'], phoneNumber);
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
        final bankData = pageData['bank_accounts'] ?? pageData;
        await _saveBankAccount(bankData, phoneNumber);
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
        // UI expects flat keys, not a nested list
        if (equipment.isNotEmpty) {
          return Map<String, dynamic>.from(equipment.first);
        }
        return {}; 
      case 11: // Entertainment
        final entertainment = await _databaseService.getData('entertainment_facilities', phoneNumber);
        return {'entertainment_facilities': entertainment.isNotEmpty ? entertainment.first : {}};
      case 12: // Transport
        final transport = await _databaseService.getData('transport_facilities', phoneNumber);
        return {'transport_facilities': transport.isNotEmpty ? transport.first : {}};
      case 13: // Water Sources
        final water = await _databaseService.getData('drinking_water_sources', phoneNumber);
        return water.isNotEmpty ? Map<String, dynamic>.from(water.first) : {};
      case 14: // Medical
        final medical = await _databaseService.getData('medical_treatment', phoneNumber);
        return medical.isNotEmpty ? Map<String, dynamic>.from(medical.first) : {}; 
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
        return {
          'diseases': {
            'is_beneficiary': diseases.isNotEmpty,
            'members': diseases,
          }
        };
      case 18: // Government Schemes
        // load each scheme member list separately
        final aadhaar = await _databaseService.getData('aadhaar_scheme_members', phoneNumber);
        final ayushman = await _databaseService.getData('ayushman_scheme_members', phoneNumber);
        final ration = await _databaseService.getData('ration_scheme_members', phoneNumber);
        final familyId = await _databaseService.getData('family_id_scheme_members', phoneNumber);
        final samagra = await _databaseService.getData('samagra_scheme_members', phoneNumber);
        final handicapped = await _databaseService.getData('handicapped_scheme_members', phoneNumber);
        final tribal = await _databaseService.getData('tribal_scheme_members', phoneNumber);
        final pension = await _databaseService.getData('pension_scheme_members', phoneNumber);
        final widow = await _databaseService.getData('widow_scheme_members', phoneNumber);
        return {
          'aadhaar_scheme_members': aadhaar,
          'ayushman_scheme_members': ayushman,
          'ration_scheme_members': ration,
          'family_id_scheme_members': familyId,
          'samagra_scheme_members': samagra,
          'handicapped_scheme_members': handicapped,
          'tribal_scheme_members': tribal,
          'pension_scheme_members': pension,
          'widow_scheme_members': widow,
        };
      case 19: // Folklore Medicine
        final medicine = await _databaseService.getData('folklore_medicine', phoneNumber);
        // page wants a list under folklore_medicines
        return {'folklore_medicines': medicine};
      case 20: // Health Programme
        final health = await _databaseService.getData('health_programmes', phoneNumber);
        return {'health_programme': health.isNotEmpty ? health.first : {}};
      case 21: // Children
        final children = await _databaseService.getData('children_data', phoneNumber);
        final mal = await _databaseService.getData('malnourished_children_data', phoneNumber);
        final childDiseases = await _databaseService.getData('child_diseases', phoneNumber);
        final familyMembers = await _databaseService.getData('family_members', phoneNumber);
        final familyNameByKey = <String, String>{};
        for (final raw in familyMembers) {
          final member = _asMap(raw);
          final name = member['name']?.toString().trim();
          if (name == null || name.isEmpty) continue;
          familyNameByKey[name] = name;
          final srNo = member['sr_no']?.toString();
          if (srNo != null && srNo.isNotEmpty) {
            familyNameByKey[srNo] = name;
          }
        }
        final groupedDiseases = <String, List<Map<String, dynamic>>>{};
        for (final raw in childDiseases) {
          final row = _asMap(raw);
          final childId = row['child_id']?.toString();
          if (childId == null || childId.isEmpty) continue;
          groupedDiseases.putIfAbsent(childId, () => <Map<String, dynamic>>[]).add({
            'name': row['disease_name'],
            'disease_name': row['disease_name'],
          });
        }
        final enrichedMalnourished = mal.map((raw) {
          final row = _asMap(raw);
          final childId = row['child_id']?.toString();
          return {
            ...row,
            'child_name': row['child_name'] ?? (childId == null ? null : familyNameByKey[childId] ?? childId),
            'diseases': childId == null ? <Map<String, dynamic>>[] : (groupedDiseases[childId] ?? <Map<String, dynamic>>[]),
          };
        }).toList();
        if (children.isNotEmpty) {
          final row = Map<String, dynamic>.from(children.first);
          row['malnourished_children_data'] = enrichedMalnourished;
          // translate to page's expected flat structure
          return {
            'births_last_3_years': row['births_last_3_years'],
            'infant_deaths_last_3_years': row['infant_deaths_last_3_years'],
            'malnourished_children': row['malnourished_children'],
            'malnourished_children_data': enrichedMalnourished,
          };
        }
        return {}; 
      case 22: // Migration
        final migration = await _databaseService.getData('migration_data', phoneNumber);
        final migrationRow = migration.isNotEmpty ? _asMap(migration.first) : <String, dynamic>{};
        if (migrationRow['migrated_members_json'] is String) {
          try {
            final decoded = jsonDecode(migrationRow['migrated_members_json'] as String);
            if (decoded is List) {
              migrationRow['migrated_members'] = decoded;
            }
          } catch (_) {}
        }
        return {'migration': migrationRow};
      case 23: // Training
        final trainingRows = await _databaseService.getData('training_data', phoneNumber);
        final needRows = await _databaseService.getData('training_needs', phoneNumber);
        final shgRows = await _databaseService.getData('shg_members', phoneNumber);
        final fpoRows = await _databaseService.getData('fpo_members', phoneNumber);
        final allMembers = <Map<String, dynamic>>[];
        for (final r in trainingRows) {
          final row = Map<String, dynamic>.from(r);
          row['status'] = 'taken';
          row['training_type'] = row['training_type'] ?? row['training_topic'];
          row['pass_out_year'] = row['pass_out_year'] ?? row['training_date'];
          allMembers.add(row);
        }
        for (final r in needRows) {
          final row = Map<String, dynamic>.from(r);
          row['status'] = 'needed';
          row['training_type'] = row['training_type'] ?? row['preferred_training'];
          allMembers.add(row);
        }
        return {
          'training': {
            'training_members': allMembers,
            'want_training': needRows.isNotEmpty,
            'shg_members': shgRows,
            'fpo_members': fpoRows,
          }
        };
      case 24: // VB-G RAM-G
        return {
          'vb_gram': await _loadSchemeWithMembers(
            phoneNumber: phoneNumber,
            summaryTable: 'vb_gram',
            membersTable: 'vb_gram_members',
            beneficiaryKeys: const ['is_member', 'is_beneficiary'],
          )
        };
      case 25: // PM Kisan Nidhi
        return {
          'pm_kisan_nidhi': await _loadSchemeWithMembers(
            phoneNumber: phoneNumber,
            summaryTable: 'pm_kisan_nidhi',
            membersTable: 'pm_kisan_members',
            beneficiaryKeys: const ['is_beneficiary'],
          )
        };
      case 26: // PM Kisan Samman
        return {
          'pm_kisan_samman_nidhi': await _loadSchemeWithMembers(
            phoneNumber: phoneNumber,
            summaryTable: 'pm_kisan_samman_nidhi',
            membersTable: 'pm_kisan_samman_members',
            beneficiaryKeys: const ['is_beneficiary'],
          )
        };
      case 27: // Kisan Credit Card
        return {
          'kisan_credit_card': await _loadSchemeWithMembers(
            phoneNumber: phoneNumber,
            summaryTable: 'kisan_credit_card',
            membersTable: 'kisan_credit_card_members',
            beneficiaryKeys: const ['has_card', 'is_beneficiary'],
          )
        };
      case 28: // Swachh Bharat
        return {
          'swachh_bharat_mission': await _loadSchemeWithMembers(
            phoneNumber: phoneNumber,
            summaryTable: 'swachh_bharat_mission',
            membersTable: 'swachh_bharat_mission_members',
            beneficiaryKeys: const ['has_toilet', 'is_beneficiary'],
          )
        };
      case 29: // Fasal Bima
        return {
          'fasal_bima': await _loadSchemeWithMembers(
            phoneNumber: phoneNumber,
            summaryTable: 'fasal_bima',
            membersTable: 'fasal_bima_members',
            beneficiaryKeys: const ['has_insurance', 'is_beneficiary'],
          )
        };
      case 30: // Bank Account
        final bank = await _databaseService.getData('bank_accounts', phoneNumber);
        final grouped = <String, Map<String, dynamic>>{};
        for (final raw in bank) {
          final row = _asMap(raw);
          final memberName = row['member_name']?.toString() ?? '';
          final key = memberName.isEmpty ? (row['sr_no']?.toString() ?? 'member_${grouped.length + 1}') : memberName;
          grouped.putIfAbsent(key, () => {
            'sr_no': grouped.length + 1,
            'name': memberName,
            'bank_accounts': <Map<String, dynamic>>[],
          });
          (grouped[key]!['bank_accounts'] as List<Map<String, dynamic>>).add({
            'sr_no': row['sr_no'],
            'bank_name': row['bank_name'],
            'account_number': row['account_number'],
            'ifsc_code': row['ifsc_code'],
            'branch_name': row['branch_name'],
            'account_type': row['account_type'],
            'has_account': row['has_account'],
            'details_correct': row['details_correct'],
            'incorrect_details': row['incorrect_details'],
          });
        }
        return {
          'is_beneficiary': bank.isNotEmpty,
          'members': grouped.values.toList(),
        };
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
    await _databaseService.deleteByPhone('crop_productivity', phoneNumber);
    for (var i = 0; i < crops.length; i++) {
      final crop = crops[i];
      if (crop is! Map<String, dynamic>) continue;

      final row = Map<String, dynamic>.from(crop);

      // Ensure sr_no exists (primary key with phone_number)
      final sr = row['sr_no'] ?? row['srno'] ?? row['id'] ?? row['index'];
      if (sr is String) {
        row['sr_no'] = int.tryParse(sr) ?? (i + 1);
      } else if (sr is num) {
        row['sr_no'] = sr.toInt();
      } else {
        row['sr_no'] = i + 1;
      }

      // Map common UI/local keys to DB column names
      if (row.containsKey('name') && !row.containsKey('crop_name')) {
        row['crop_name'] = row['name'];
      }
      if (row.containsKey('area') && !row.containsKey('area_hectares')) {
        row['area_hectares'] = row['area'];
      }
      if (row.containsKey('productivity') && !row.containsKey('productivity_quintal_per_hectare')) {
        row['productivity_quintal_per_hectare'] = row['productivity'];
      }
      if (row.containsKey('total_production') && !row.containsKey('total_production_quintal')) {
        row['total_production_quintal'] = row['total_production'];
      }
      if (row.containsKey('sold') && !row.containsKey('quantity_sold_quintal')) {
        row['quantity_sold_quintal'] = row['sold'];
      }
      if (row.containsKey('quantity_consumed') && !row.containsKey('quantity_consumed_quintal')) {
        row['quantity_consumed_quintal'] = row['quantity_consumed'];
      }

      // Ensure phone_number present
      row['phone_number'] = phoneNumber;

      try {
        await _databaseService.insertOrUpdate('crop_productivity', row, phoneNumber);
      } catch (e, st) {
        debugPrint('Failed to save crop_productivity for $phoneNumber: $e');
        debugPrint(st.toString());
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
    await _databaseService.deleteByPhone('animals', phoneNumber);
    for (int i = 0; i < animals.length; i++) {
      final animal = animals[i];
      if (animal is Map<String, dynamic>) {
        // Ensure sr_no exists
        final sr = animal['sr_no'] ?? animal['srno'] ?? animal['id'];
        if (sr is String) {
          animal['sr_no'] = int.tryParse(sr) ?? (i + 1);
        } else if (sr is num) {
          animal['sr_no'] = sr.toInt();
        } else {
          animal['sr_no'] = i + 1;
        }
        
        await _databaseService.insertOrUpdate('animals', animal, phoneNumber);
      }
    }
  }

  Future<void> _saveAgriculturalEquipment(dynamic equipment, String phoneNumber) async {
    // agricultural_equipment was migrated to single-row per phone_number table
    // but the UI might still send a list. Take the first item or iterate if the DB supports it?
    // DB schema: CREATE TABLE agricultural_equipment (phone_number INTEGER PRIMARY KEY...)
    // So distinct rows by equipment type are NOT supported anymore unless migrated back.
    // Assuming UI sends one combined object or list of ONE object.
    
    if (equipment is Map) {
        await _databaseService.insertOrUpdate('agricultural_equipment', _asMap(equipment), phoneNumber);
    } else if (equipment is List && equipment.isNotEmpty) {
      // Take first item if list
      final item = equipment.first;
      if (item is Map) {
        await _databaseService.insertOrUpdate('agricultural_equipment', _asMap(item), phoneNumber);
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
    // drinking_water_sources was migrated to single-row
    if (sources is Map) {
        await _databaseService.insertOrUpdate('drinking_water_sources', _asMap(sources), phoneNumber);
    } else if (sources is List && sources.isNotEmpty) {
      final item = sources.first;
      if (item is Map) {
        await _databaseService.insertOrUpdate('drinking_water_sources', _asMap(item), phoneNumber);
      }
    }
  }

  Future<void> _saveMedicalTreatment(dynamic data, String phoneNumber) async {
    if (data is Map) {
      await _databaseService.insertOrUpdate('medical_treatment', _asMap(data), phoneNumber);
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
    final rows = <Map<String, dynamic>>[];

    if (data is List) {
      rows.addAll(_asMapList(data));
    } else if (data is Map) {
      final diseaseMap = _asMap(data);
      final members = _asMapList(diseaseMap['members']);
      if (members.isNotEmpty) {
        rows.addAll(members);
      } else {
        rows.add(diseaseMap);
      }
    }

    await _databaseService.deleteByPhone('diseases', phoneNumber);

    for (int i = 0; i < rows.length; i++) {
      final row = _asMap(rows[i]);
      final payload = <String, dynamic>{
        'sr_no': row['sr_no'] is String
            ? int.tryParse(row['sr_no']) ?? (i + 1)
            : (row['sr_no'] ?? (i + 1)),
        'family_member_name': row['family_member_name'] ?? row['member_name'] ?? row['name'],
        'disease_name': row['disease_name'],
        'suffering_since': row['suffering_since'],
        'treatment_taken': row['treatment_taken'],
        'treatment_from_when': row['treatment_from_when'],
        'treatment_from_where': row['treatment_from_where'],
        'treatment_taken_from': row['treatment_taken_from'],
        'created_at': row['created_at'] ?? DateTime.now().toIso8601String(),
      };

      final isMeaningful =
          (payload['family_member_name']?.toString().trim().isNotEmpty ?? false) ||
          (payload['disease_name']?.toString().trim().isNotEmpty ?? false) ||
          (payload['suffering_since']?.toString().trim().isNotEmpty ?? false) ||
          (payload['treatment_taken']?.toString().trim().isNotEmpty ?? false) ||
          (payload['treatment_from_when']?.toString().trim().isNotEmpty ?? false) ||
          (payload['treatment_from_where']?.toString().trim().isNotEmpty ?? false) ||
          (payload['treatment_taken_from']?.toString().trim().isNotEmpty ?? false);

      if (!isMeaningful) continue;
      await _databaseService.insertOrUpdate('diseases', payload, phoneNumber);
    }
  }

  Future<void> _saveGovernmentSchemes(dynamic data, String phoneNumber) async {
    if (data is Map) {
      final source = _asMap(data);
      final map = source['government_schemes'] is Map ? _asMap(source['government_schemes']) : source;
      // save each scheme member list to its dedicated table
      final tableMap = {
        'aadhaar_scheme_members': 'aadhaar_scheme_members',
        'ayushman_scheme_members': 'ayushman_scheme_members',
        'ration_scheme_members': 'ration_scheme_members',
        'family_id_scheme_members': 'family_id_scheme_members',
        'samagra_scheme_members': 'samagra_scheme_members',
        'handicapped_scheme_members': 'handicapped_scheme_members',
        'tribal_scheme_members': 'tribal_scheme_members',
        'pension_scheme_members': 'pension_scheme_members',
        'widow_scheme_members': 'widow_scheme_members',
        'vb_gram_members': 'vb_gram_members',
        'pm_kisan_members': 'pm_kisan_members',
        'pm_kisan_samman_members': 'pm_kisan_samman_members',
      };

      String _yesNoFromMembers(List list, {String key = 'have_card'}) {
        for (final item in list) {
          if (item is! Map) continue;
          final value = item[key];
          if (value == true || value == 1 || value == '1') return 'yes';
          if (value is String) {
            final normalized = value.toLowerCase().trim();
            if (normalized == 'yes' || normalized == 'true') return 'yes';
          }
        }
        return list.isNotEmpty ? 'yes' : 'no';
      }

      for (final entry in tableMap.entries) {
        final list = map[entry.key];
        if (list is List) {
          await _databaseService.deleteByPhone(entry.value, phoneNumber);
          for (int i = 0; i < list.length; i++) {
            final item = list[i];
            if (item is Map) {
              final row = _asMap(item);
              // ensure sr_no exists
              final sr = row['sr_no'];
              if (sr == null) {
                row['sr_no'] = i + 1;
              } else if (sr is String) {
                row['sr_no'] = int.tryParse(sr) ?? (i + 1);
              } else if (sr is num) {
                row['sr_no'] = sr.toInt();
              } else {
                row['sr_no'] = i + 1;
              }

              await _databaseService.insertOrUpdate(entry.value, row, phoneNumber);
            }
          }
        }
      }

      final summaryTables = <String, Map<String, dynamic>>{
        'aadhaar_info': {
          'has_aadhaar': _yesNoFromMembers(map['aadhaar_scheme_members'] is List ? map['aadhaar_scheme_members'] : const []),
          'total_members': map['aadhaar_scheme_members'] is List ? (map['aadhaar_scheme_members'] as List).length : 0,
        },
        'ayushman_card': {
          'has_card': _yesNoFromMembers(map['ayushman_scheme_members'] is List ? map['ayushman_scheme_members'] : const []),
          'total_members': map['ayushman_scheme_members'] is List ? (map['ayushman_scheme_members'] as List).length : 0,
        },
        'family_id': {
          'has_id': _yesNoFromMembers(map['family_id_scheme_members'] is List ? map['family_id_scheme_members'] : const []),
          'total_members': map['family_id_scheme_members'] is List ? (map['family_id_scheme_members'] as List).length : 0,
        },
        'ration_card': {
          'has_card': _yesNoFromMembers(map['ration_scheme_members'] is List ? map['ration_scheme_members'] : const []),
          'total_members': map['ration_scheme_members'] is List ? (map['ration_scheme_members'] as List).length : 0,
        },
        'samagra_id': {
          'has_id': _yesNoFromMembers(map['samagra_scheme_members'] is List ? map['samagra_scheme_members'] : const []),
          'total_children': map['samagra_scheme_members'] is List ? (map['samagra_scheme_members'] as List).length : 0,
        },
        'tribal_card': {
          'has_card': _yesNoFromMembers(map['tribal_scheme_members'] is List ? map['tribal_scheme_members'] : const []),
          'total_members': map['tribal_scheme_members'] is List ? (map['tribal_scheme_members'] as List).length : 0,
        },
        'handicapped_allowance': {
          'has_allowance': _yesNoFromMembers(map['handicapped_scheme_members'] is List ? map['handicapped_scheme_members'] : const []),
          'total_members': map['handicapped_scheme_members'] is List ? (map['handicapped_scheme_members'] as List).length : 0,
        },
        'pension_allowance': {
          'has_pension': _yesNoFromMembers(map['pension_scheme_members'] is List ? map['pension_scheme_members'] : const []),
          'total_members': map['pension_scheme_members'] is List ? (map['pension_scheme_members'] as List).length : 0,
        },
        'widow_allowance': {
          'has_allowance': _yesNoFromMembers(map['widow_scheme_members'] is List ? map['widow_scheme_members'] : const []),
          'total_members': map['widow_scheme_members'] is List ? (map['widow_scheme_members'] as List).length : 0,
        },
        'vb_gram': {
          'is_member': _yesNoFromMembers(map['vb_gram_members'] is List ? map['vb_gram_members'] : const [], key: 'is_member'),
          'total_members': map['vb_gram_members'] is List ? (map['vb_gram_members'] as List).length : 0,
        },
        'pm_kisan_nidhi': {
          'is_beneficiary': _yesNoFromMembers(map['pm_kisan_members'] is List ? map['pm_kisan_members'] : const [], key: 'is_beneficiary'),
          'total_members': map['pm_kisan_members'] is List ? (map['pm_kisan_members'] as List).length : 0,
        },
        'pm_kisan_samman_nidhi': {
          'is_beneficiary': _yesNoFromMembers(map['pm_kisan_samman_members'] is List ? map['pm_kisan_samman_members'] : const [], key: 'is_beneficiary'),
          'total_members': map['pm_kisan_samman_members'] is List ? (map['pm_kisan_samman_members'] as List).length : 0,
        },
      };

      for (final entry in summaryTables.entries) {
        await _databaseService.insertOrUpdate(entry.key, entry.value, phoneNumber);
      }
    }
  }

  Future<void> _saveFolkloreMedicine(dynamic data, String phoneNumber) async {
    final entries = data is List
        ? _asMapList(data)
        : (data is Map<String, dynamic> ? <Map<String, dynamic>>[_asMap(data)] : <Map<String, dynamic>>[]);

    final normalized = entries
        .map((row) => <String, dynamic>{
              'person_name': row['person_name'] ?? row['member_name'] ?? row['name'],
              'plant_local_name': row['plant_local_name'],
              'plant_botanical_name': row['plant_botanical_name'],
              'uses': row['uses'],
            })
        .where((payload) =>
            !((payload['person_name']?.toString().trim().isEmpty ?? true) &&
                (payload['plant_local_name']?.toString().trim().isEmpty ?? true) &&
                (payload['plant_botanical_name']?.toString().trim().isEmpty ?? true) &&
                (payload['uses']?.toString().trim().isEmpty ?? true)))
        .toList();

    if (normalized.isEmpty) {
      await _databaseService.deleteByPhone('folklore_medicine', phoneNumber);
      return;
    }

    // Source-of-truth PK for folklore_medicine is phone_number.
    // Persist the latest meaningful row for this family.
    await _databaseService.deleteByPhone('folklore_medicine', phoneNumber);
    await _databaseService.insertOrUpdate('folklore_medicine', normalized.last, phoneNumber);
  }

  Future<void> _saveHealthProgramme(dynamic data, String phoneNumber) async {
    if (data is Map<String, dynamic>) {
      await _databaseService.insertOrUpdate('health_programmes', data, phoneNumber);
    }
  }


  String? _resolveChildName(String? childId, List<Map<String, dynamic>> familyMembers) {
    if (childId == null || childId.isEmpty) return null;
    for (final member in familyMembers) {
      final name = member['name']?.toString();
      if (name != null && name == childId) return name;
      final srNo = member['sr_no']?.toString();
      if (srNo != null && srNo == childId) return name;
    }
    return childId;
  }

  Future<void> _saveMalnourishedChildrenData(dynamic data, String phoneNumber) async {
    if (data is! List) return;
    final familyMembers = (await _databaseService.getData('family_members', phoneNumber))
        .map((row) => _asMap(row))
        .toList();

    await _databaseService.deleteByPhone('malnourished_children_data', phoneNumber);
    await _databaseService.deleteByPhone('child_diseases', phoneNumber);

    int diseaseSrNo = 0;
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is! Map<String, dynamic>) continue;

      final row = _asMap(item);
      final childId = row['child_id']?.toString();
      await _databaseService.insertOrUpdate('malnourished_children_data', {
        'sr_no': i + 1,
        'child_id': childId,
        'child_name': row['child_name'] ?? _resolveChildName(childId, familyMembers),
        'height': row['height'],
        'weight': row['weight'],
        'created_at': row['created_at'] ?? DateTime.now().toIso8601String(),
      }, phoneNumber);

      for (final disease in _asMapList(row['diseases'])) {
        final diseaseName = disease['name'] ?? disease['disease_name'];
        if (diseaseName == null || diseaseName.toString().trim().isEmpty) continue;
        diseaseSrNo++;
        await _databaseService.insertOrUpdate('child_diseases', {
          'child_id': childId,
          'disease_name': diseaseName,
          'sr_no': diseaseSrNo,
          'created_at': DateTime.now().toIso8601String(),
        }, phoneNumber);
      }
    }
  }

  Future<void> _saveMigration(dynamic data, String phoneNumber) async {
    if (data is Map) {
      final payload = _asMap(data);
      if (payload.containsKey('migrated_members') && payload['migrated_members'] is List) {
        payload['migrated_members_json'] = jsonEncode(payload['migrated_members']);
      }
      payload['sr_no'] = 1;
      await _databaseService.insertOrUpdate('migration_data', payload, phoneNumber);
    }
  }

  Future<void> _saveTraining(dynamic data, String phoneNumber) async {
    if (data is Map) {
      final trainingData = _asMap(data);
      await _databaseService.deleteByPhone('training_data', phoneNumber);
      await _databaseService.deleteByPhone('training_needs', phoneNumber);
      await _databaseService.deleteByPhone('shg_members', phoneNumber);
      await _databaseService.deleteByPhone('fpo_members', phoneNumber);

      // Save training members (both taken and needed separately)
      if (trainingData['training_members'] is List) {
        for (int i = 0; i < (trainingData['training_members'] as List).length; i++) {
          final item = trainingData['training_members'][i];
          if (item is Map) {
            final row = _asMap(item);
            // ensure sr_no exists and is numeric, fallback to index+1
            if (row['sr_no'] == null) {
              row['sr_no'] = i + 1;
            } else if (row['sr_no'] is String) {
              row['sr_no'] = int.tryParse(row['sr_no']) ?? (i + 1);
            }
            final status = row['status'];
            if (status == 'taken') {
              await _databaseService.insertOrUpdate('training_data', {
                'sr_no': row['sr_no'],
                'member_name': row['member_name'],
                'training_topic': row['training_topic'] ?? row['training_type'],
                'training_duration': row['training_duration'],
                'training_date': row['training_date'] ?? row['pass_out_year'],
                'status': 'taken',
                'created_at': row['created_at'] ?? DateTime.now().toIso8601String(),
              }, phoneNumber);
            } else if (status == 'needed') {
              await _databaseService.insertOrUpdate('training_needs', {
                'sr_no': row['sr_no'],
                'wants_training': 1,
                'preferred_training': row['preferred_training'] ?? row['training_type'],
                'created_at': row['created_at'] ?? DateTime.now().toIso8601String(),
              }, phoneNumber);
            }
          }
        }
      }
      
      // Save SHG members
      if (trainingData['shg_members'] is List) {
        final shgMembers = trainingData['shg_members'] as List;
        for (int i = 0; i < shgMembers.length; i++) {
          final item = shgMembers[i];
          if (item is Map) {
            final row = _asMap(item);
            final srNo = row['sr_no'] is String
                ? int.tryParse(row['sr_no']) ?? (i + 1)
                : (row['sr_no'] ?? (i + 1));
            await _databaseService.insertOrUpdate('shg_members', {
              'sr_no': srNo,
              'member_name': row['member_name'],
              'shg_name': row['shg_name'],
              'purpose': row['purpose'],
              'agency': row['agency'],
              'position': row['position'],
              'monthly_saving': row['monthly_saving'],
              'created_at': row['created_at'] ?? DateTime.now().toIso8601String(),
            }, phoneNumber);
          }
        }
      }
      
      // Save FPO members
      if (trainingData['fpo_members'] is List) {
        final fpoMembers = trainingData['fpo_members'] as List;
        for (int i = 0; i < fpoMembers.length; i++) {
          final item = fpoMembers[i];
          if (item is Map) {
            final row = _asMap(item);
            final srNo = row['sr_no'] is String
                ? int.tryParse(row['sr_no']) ?? (i + 1)
                : (row['sr_no'] ?? (i + 1));
            await _databaseService.insertOrUpdate('fpo_members', {
              'sr_no': srNo,
              'member_name': row['member_name'],
              'fpo_name': row['fpo_name'],
              'purpose': row['purpose'],
              'agency': row['agency'],
              'share_capital': row['share_capital'],
              'created_at': row['created_at'] ?? DateTime.now().toIso8601String(),
            }, phoneNumber);
          }
        }
      }
    }
  }

  Future<Map<String, dynamic>> _loadSchemeWithMembers({
    required String phoneNumber,
    required String summaryTable,
    required String membersTable,
    required List<String> beneficiaryKeys,
  }) async {
    final summaryRows = await _databaseService.getData(summaryTable, phoneNumber);
    final memberRows = await _databaseService.getData(membersTable, phoneNumber);

    final members = memberRows.map((raw) {
      final row = _asMap(raw);
      return <String, dynamic>{
        'sr_no': row['sr_no'],
        'name': row['name'] ?? row['member_name'] ?? row['family_member_name'],
        'name_included': row['name_included'],
        'details_correct': row['details_correct'],
        'incorrect_details': row['incorrect_details'],
        'received': row['received'],
        'days': row['days'],
      };
    }).toList();

    bool isBeneficiary = members.isNotEmpty;
    if (summaryRows.isNotEmpty) {
      final summary = _asMap(summaryRows.first);
      for (final key in beneficiaryKeys) {
        if (summary.containsKey(key)) {
          isBeneficiary = _isTruthy(summary[key]);
          break;
        }
      }
    }

    return {
      'is_beneficiary': isBeneficiary,
      'members': members,
    };
  }

  Future<void> _saveSchemeMembers({
    required String membersTable,
    required String phoneNumber,
    required List<Map<String, dynamic>> members,
  }) async {
    await _databaseService.deleteByPhone(membersTable, phoneNumber);
    for (int i = 0; i < members.length; i++) {
      final row = _asMap(members[i]);
      await _databaseService.insertOrUpdate(membersTable, {
        'sr_no': row['sr_no'] is String
            ? int.tryParse(row['sr_no']) ?? (i + 1)
            : (row['sr_no'] ?? (i + 1)),
        'member_name': row['member_name'] ?? row['name'] ?? row['family_member_name'],
        'name_included': row['name_included'],
        'details_correct': row['details_correct'],
        'incorrect_details': row['incorrect_details'],
        'received': row['received'],
        'days': row['days'],
        'benefits_received': row['benefits_received'],
        'account_number': row['account_number'],
        'membership_details': row['membership_details'],
        'created_at': row['created_at'] ?? DateTime.now().toIso8601String(),
      }, phoneNumber);
    }
  }

  Future<void> _saveVbGRamGBeneficiary(dynamic data, String phoneNumber) async {
    if (data is! Map) return;
    final payload = _asMap(data);
    final members = _asMapList(payload['members']);
    await _saveSchemeMembers(
      membersTable: 'vb_gram_members',
      phoneNumber: phoneNumber,
      members: members,
    );

    await _databaseService.insertOrUpdate('vb_gram', {
      'is_member': _toYesNo(payload['is_beneficiary'] ?? payload['is_member'] ?? members.isNotEmpty),
      'total_members': members.length,
      'created_at': payload['created_at'] ?? DateTime.now().toIso8601String(),
    }, phoneNumber);
  }

  Future<void> _savePmKisanNidhi(dynamic data, String phoneNumber) async {
    if (data is! Map) return;
    final payload = _asMap(data);
    final members = _asMapList(payload['members']);
    await _saveSchemeMembers(
      membersTable: 'pm_kisan_members',
      phoneNumber: phoneNumber,
      members: members,
    );

    await _databaseService.insertOrUpdate('pm_kisan_nidhi', {
      'is_beneficiary': _toYesNo(payload['is_beneficiary'] ?? members.isNotEmpty),
      'total_members': members.length,
      'created_at': payload['created_at'] ?? DateTime.now().toIso8601String(),
    }, phoneNumber);
  }

  Future<void> _savePmKisanSammanNidhi(dynamic data, String phoneNumber) async {
    if (data is! Map) return;
    final payload = _asMap(data);
    final members = _asMapList(payload['members']);
    await _saveSchemeMembers(
      membersTable: 'pm_kisan_samman_members',
      phoneNumber: phoneNumber,
      members: members,
    );

    await _databaseService.insertOrUpdate('pm_kisan_samman_nidhi', {
      'is_beneficiary': _toYesNo(payload['is_beneficiary'] ?? members.isNotEmpty),
      'total_members': members.length,
      'created_at': payload['created_at'] ?? DateTime.now().toIso8601String(),
    }, phoneNumber);
  }

  Future<void> _saveKisanCreditCard(dynamic data, String phoneNumber) async {
    if (data is! Map) return;
    final payload = _asMap(data);
    final members = _asMapList(payload['members']);
    await _saveSchemeMembers(
      membersTable: 'kisan_credit_card_members',
      phoneNumber: phoneNumber,
      members: members,
    );

    await _databaseService.insertOrUpdate('kisan_credit_card', {
      'has_card': _toYesNo(payload['is_beneficiary'] ?? payload['has_card'] ?? members.isNotEmpty),
      'card_number': payload['card_number'],
      'credit_limit': payload['credit_limit'],
      'outstanding_amount': payload['outstanding_amount'],
      'created_at': payload['created_at'] ?? DateTime.now().toIso8601String(),
    }, phoneNumber);
  }

  Future<void> _saveSwachhBharatMission(dynamic data, String phoneNumber) async {
    if (data is! Map) return;
    final payload = _asMap(data);
    final members = _asMapList(payload['members']);
    await _saveSchemeMembers(
      membersTable: 'swachh_bharat_mission_members',
      phoneNumber: phoneNumber,
      members: members,
    );

    await _databaseService.insertOrUpdate('swachh_bharat_mission', {
      'has_toilet': _toYesNo(payload['is_beneficiary'] ?? payload['has_toilet'] ?? members.isNotEmpty),
      'toilet_type': payload['toilet_type'],
      'construction_year': payload['construction_year'],
      'subsidy_received': payload['subsidy_received'],
      'created_at': payload['created_at'] ?? DateTime.now().toIso8601String(),
    }, phoneNumber);
  }

  Future<void> _saveFasalBima(dynamic data, String phoneNumber) async {
    if (data is! Map) return;
    final payload = _asMap(data);
    final members = _asMapList(payload['members']);
    await _saveSchemeMembers(
      membersTable: 'fasal_bima_members',
      phoneNumber: phoneNumber,
      members: members,
    );

    await _databaseService.insertOrUpdate('fasal_bima', {
      'has_insurance': _toYesNo(payload['is_beneficiary'] ?? payload['has_insurance'] ?? members.isNotEmpty),
      'insurance_type': payload['insurance_type'],
      'crop_insured': payload['crop_insured'],
      'premium_amount': payload['premium_amount'],
      'claim_received': payload['claim_received'],
      'created_at': payload['created_at'] ?? DateTime.now().toIso8601String(),
    }, phoneNumber);
  }

  Future<void> _saveBankAccount(dynamic data, String phoneNumber) async {
    final rows = <Map<String, dynamic>>[];

    if (data is List) {
      rows.addAll(_asMapList(data));
    } else if (data is Map<String, dynamic>) {
      if (data['members'] is List) {
        int srNo = 0;
        for (final memberRaw in data['members'] as List) {
          final member = _asMap(memberRaw);
          final memberName = member['member_name'] ?? member['name'];
          final accounts = _asMapList(member['bank_accounts']);
          for (final account in accounts) {
            srNo++;
            rows.add({
              'sr_no': account['sr_no'] ?? srNo,
              'member_name': memberName,
              'account_number': account['account_number'],
              'bank_name': account['bank_name'],
              'ifsc_code': account['ifsc_code'],
              'branch_name': account['branch_name'],
              'account_type': account['account_type'],
              'has_account': account['has_account'],
              'details_correct': account['details_correct'],
              'incorrect_details': account['incorrect_details'],
            });
          }
        }
      } else {
        rows.add(_asMap(data));
      }
    }

    await _databaseService.deleteByPhone('bank_accounts', phoneNumber);
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      try {
        await _databaseService.insertOrUpdate('bank_accounts', {
          'sr_no': row['sr_no'] ?? (i + 1),
          'member_name': row['member_name'],
          'account_number': row['account_number'],
          'bank_name': row['bank_name'],
          'ifsc_code': row['ifsc_code'],
          'branch_name': row['branch_name'],
          'account_type': row['account_type'],
          'has_account': row['has_account'],
          'details_correct': row['details_correct'],
          'incorrect_details': row['incorrect_details'],
          'created_at': row['created_at'] ?? DateTime.now().toIso8601String(),
        }, phoneNumber);
      } catch (e, st) {
        debugPrint('Failed to save bank_account row for $phoneNumber: $e');
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

      // Government scheme info (only first row expected)
      final aadhaarInfo = await _databaseService.getData('aadhaar_info', sessionId);
      final ayushmanCard = await _databaseService.getData('ayushman_card', sessionId);
      final familyId = await _databaseService.getData('family_id', sessionId);
      final rationCard = await _databaseService.getData('ration_card', sessionId);
      final samagraId = await _databaseService.getData('samagra_id', sessionId);
      final tribalCard = await _databaseService.getData('tribal_card', sessionId);

      // Other lists
      final children = await _databaseService.getData('children_data', sessionId);
      final malChildren = await _databaseService.getData('malnourished_children_data', sessionId);
      final childDiseases = await _databaseService.getData('child_diseases', sessionId);
      final migration = await _databaseService.getData('migration_data', sessionId);
      final training = await _databaseService.getData('training_data', sessionId);
      final trainingNeeds = await _databaseService.getData('training_needs', sessionId);
      final shg = await _databaseService.getData('shg_members', sessionId);
      final fpo = await _databaseService.getData('fpo_members', sessionId);
      final bank = await _databaseService.getData('bank_accounts', sessionId);
      final folklore = await _databaseService.getData('folklore_medicine', sessionId);

      final groupedDiseases = <String, List<Map<String, dynamic>>>{};
      for (final raw in childDiseases) {
        final row = _asMap(raw);
        final childId = row['child_id']?.toString();
        if (childId == null || childId.isEmpty) continue;
        groupedDiseases.putIfAbsent(childId, () => <Map<String, dynamic>>[]).add({
          'name': row['disease_name'],
          'disease_name': row['disease_name'],
        });
      }

      final enrichedMalChildren = malChildren.map((raw) {
        final row = _asMap(raw);
        final childId = row['child_id']?.toString();
        return {
          ...row,
          'child_name': row['child_name'] ?? childId,
          'diseases': childId == null ? <Map<String, dynamic>>[] : (groupedDiseases[childId] ?? <Map<String, dynamic>>[]),
        };
      }).toList();

      final mergedTraining = <Map<String, dynamic>>[];
      for (final raw in training) {
        final row = _asMap(raw);
        mergedTraining.add({
          ...row,
          'status': 'taken',
          'training_type': row['training_topic'] ?? row['training_type'],
          'pass_out_year': row['training_date'] ?? row['pass_out_year'],
        });
      }
      for (final raw in trainingNeeds) {
        final row = _asMap(raw);
        mergedTraining.add({
          ...row,
          'status': 'needed',
          'training_type': row['preferred_training'] ?? row['training_type'],
        });
      }

      final migrationRow = migration.isNotEmpty ? _asMap(migration.first) : <String, dynamic>{};
      if (migrationRow['migrated_members_json'] is String) {
        try {
          final decoded = jsonDecode(migrationRow['migrated_members_json'] as String);
          if (decoded is List) {
            migrationRow['migrated_members'] = decoded;
          }
        } catch (_) {}
      }

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
        'aadhaar_info': aadhaarInfo.isNotEmpty ? aadhaarInfo.first : {},
        'ayushman_card': ayushmanCard.isNotEmpty ? ayushmanCard.first : {},
        'family_id': familyId.isNotEmpty ? familyId.first : {},
        'ration_card': rationCard.isNotEmpty ? rationCard.first : {},
        'samagra_id': samagraId.isNotEmpty ? samagraId.first : {},
        'tribal_card': tribalCard.isNotEmpty ? tribalCard.first : {},
        'children': children,
        'children_data': children,
        'malnourished_children_data': enrichedMalChildren,
        'child_diseases': childDiseases,
        'migration': migrationRow,
        'training': {
          'training_members': mergedTraining,
          'want_training': trainingNeeds.isNotEmpty,
          'shg_members': shg,
          'fpo_members': fpo,
        },
        'training_data': training,
        'training_needs': trainingNeeds,
        'shg_members': shg,
        'fpo_members': fpo,
        'bank_accounts': bank,
        'folklore_medicine': folklore,
        'folklore_medicines': folklore,
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
            // Queue via generic SyncService as a fallback.  `sync_family_survey`
            // knows how to pull a record from the local database using the
            // phone number, so we only need to enqueue the key.
            await _syncService.queueSyncOperation('sync_family_survey', {
              'phone_number': phone,
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
    await _databaseService.insertOrUpdate('family_survey_sessions', {
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
    }, phoneNumber);

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