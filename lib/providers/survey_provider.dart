import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dri_survey/services/database_service.dart';
import 'package:dri_survey/services/supabase_service.dart';
import 'package:dri_survey/services/sync_service.dart';
import 'package:dri_survey/services/family_sync_service.dart';

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
  final FamilySyncService _familySyncService = FamilySyncService.instance;

  // Guard to avoid accidental duplicate saves when saveCurrentPageData is called rapidly
  DateTime? _lastSaveTimestamp;

  @override
  SurveyState build() {
    return const SurveyState(
      currentPage: 0,
      totalPages: 32, // Pages indexed 0-31 in survey_page.dart
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

      if (phoneNumber == null || phoneNumber.isEmpty) {
        throw Exception('Phone number is required to create a survey');
      }

      // Get authenticated user's email - this should be available after login
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Authentication required. Please login first.');
      }

      final resolvedEmail = currentUser.email;
      if (resolvedEmail == null || resolvedEmail.isEmpty) {
        throw Exception('User email not available. Please check your authentication.');
      }

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
        'surveyor_email': resolvedEmail,
        'survey_date': DateTime.now().toIso8601String(), // Ensure survey_date is set
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      state = state.copyWith(surveyId: surveyId, phoneNumber: phoneNumber);

      // Create survey in Supabase if online
      if (await _supabaseService.isOnline()) {
        try {
          await _supabaseService.client
              .from('family_survey_sessions')
              .insert({
                'phone_number': phoneNumber,
                'surveyor_email': resolvedEmail,
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
                'created_by': _supabaseService.currentUser?.id,
              });
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
    if (state.phoneNumber == null) {
      print('❌ saveCurrentPageData: phoneNumber is null, skipping save');
      return;
    }

    final now = DateTime.now();

    // Prevent very quick duplicate saves
    if (_lastSaveTimestamp != null && now.difference(_lastSaveTimestamp!) < const Duration(milliseconds: 500)) {
      print('⚠️ saveCurrentPageData: Skipping duplicate save (called too quickly)');
      return;
    }

    // IDEMPOTENCY CHECK: if same page + same surveyData snapshot was saved recently, skip.
    final dataSignature = jsonEncode(state.surveyData);
    if (_lastSaveTimestamp != null &&
        _lastSavedPage == state.currentPage &&
        _lastSavedDataSignature == dataSignature &&
        now.difference(_lastSaveTimestamp!) < const Duration(seconds: 2)) {
      print('⚠️ saveCurrentPageData: Skipping identical repeated save for page ${state.currentPage}');
      _lastSaveTimestamp = now;
      return;
    }

    // mark attempt time early (avoids races)
    _lastSaveTimestamp = now;

    try {
      print('💾 saveCurrentPageData: Saving page ${state.currentPage} for phone ${state.phoneNumber}');
      print('📊 Survey data keys: ${state.surveyData.keys.toList()}');

      // Save data based on current page locally first (immediate)
      await _savePageData(state.currentPage, state.surveyData);

      // Update idempotency markers after successful save
      _lastSavedPage = state.currentPage;
      _lastSavedDataSignature = dataSignature;
      _lastSaveTimestamp = DateTime.now();

      // Trigger background sync (non-blocking)
      syncPartialSurvey();

      print('✅ saveCurrentPageData: Successfully saved page ${state.currentPage} locally');
    } catch (e) {
      print('❌ saveCurrentPageData: Error saving page data: $e');
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
              'state': sessionData['state'],
              'panchayat': sessionData['panchayat'],
              'block': sessionData['block'],
              'tehsil': sessionData['tehsil'],
              'district': sessionData['district'],
              'postal_address': sessionData['postal_address'],
              'pin_code': sessionData['pin_code'],
              'lgd_code': sessionData['lgd_code'],
              'shine_code': sessionData['shine_code'],
              'latitude': sessionData['latitude'],
              'longitude': sessionData['longitude'],
              'location_accuracy': sessionData['location_accuracy'],
              'location_timestamp': sessionData['location_timestamp'],
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
          final tribalQuestions = await _databaseService.getData('tribal_questions', state.phoneNumber!);
          if (tribalQuestions.isNotEmpty) {
            data['tribal_questions'] = tribalQuestions.first;
          }
          break;
        case 5: // Land Holding
          final landData = await _databaseService.getData('land_holding', state.phoneNumber!);
          if (landData.isNotEmpty) {
            data['land_holding'] = landData.first;
          }
          break;
        case 6: // Irrigation
          final irrigationData = await _databaseService.getData('irrigation_facilities', state.phoneNumber!);
          if (irrigationData.isNotEmpty) {
            data['irrigation'] = irrigationData.first;
          }
          break;
        case 7: // Crop productivity
          final cropData = await _databaseService.getData('crop_productivity', state.phoneNumber!);
          if (cropData.isNotEmpty) {
            data['crops'] = cropData.map((row) {
              return {
                'sr_no': row['sr_no'] ?? row['id'],
                'season': row['season'],
                'crop_name': row['crop_name'],
                'area_hectares': row['area_hectares'],
                'productivity_quintal_per_hectare': row['productivity_quintal_per_hectare'],
                'total_production_quintal': row['total_production_quintal'],
                'quantity_consumed_quintal': row['quantity_consumed_quintal'],
                'quantity_sold_quintal': row['quantity_sold_quintal'],
              };
            }).toList();
          }
          break;
        case 8: // Fertilizer usage
          final fertilizerData = await _databaseService.getData('fertilizer_usage', state.phoneNumber!);
          if (fertilizerData.isNotEmpty) {
            data['fertilizer'] = fertilizerData.first;
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
            data['equipment'] = equipmentData.first;
          }
          break;
        case 11: // Entertainment Facilities
          final entertainmentData = await _databaseService.getData('entertainment_facilities', state.phoneNumber!);
          if (entertainmentData.isNotEmpty) {
            data['entertainment'] = entertainmentData.first;
          }
          break;
        case 12: // Transport Facilities
          final transportData = await _databaseService.getData('transport_facilities', state.phoneNumber!);
          if (transportData.isNotEmpty) {
            data['transport'] = transportData.first;
          }
          break;
        case 13: // Drinking Water Sources
          final waterData = await _databaseService.getData('drinking_water_sources', state.phoneNumber!);
          if (waterData.isNotEmpty) {
            // place DB row under both a nested `water_sources` key (for preview/export)
            // and also spread top-level keys so the page widgets receive values via `pageData`.
            final row = Map<String, dynamic>.from(waterData.first);
            data['water_sources'] = row;
            data.addAll(row);
          }
          break;
        case 14: // Medical Treatment
          final medicalData = await _databaseService.getData('medical_treatment', state.phoneNumber!);
          if (medicalData.isNotEmpty) {
            data['medical'] = medicalData.first;
          }
          break;
        case 15: // Disputes
          final disputeData = await _databaseService.getData('disputes', state.phoneNumber!);
          if (disputeData.isNotEmpty) {
            data['disputes'] = disputeData.first;
          }
          break;
        case 16: // House conditions
          // Load house conditions data (katcha, pakka, etc.)
          final houseConditionData = await _databaseService.getData('house_conditions', state.phoneNumber!);
          if (houseConditionData.isNotEmpty) {
            final conditions = houseConditionData.first;

            // Top-level keys (used by page widgets)
            data.addAll({
              'katcha_house': conditions['katcha'] ?? false,
              'pakka_house': conditions['pakka'] ?? false,
              'katcha_pakka_house': conditions['katcha_pakka'] ?? false,
              'hut_house': conditions['hut'] ?? false,
              'toilet_in_use': conditions['toilet_in_use'],
              'toilet_condition': conditions['toilet_condition'],
            });

            // Nested `house` map for preview/export (matches preview expectations)
            data['house'] = {
              'katcha': conditions['katcha'] ?? false,
              'pakka': conditions['pakka'] ?? false,
              'katcha_pakka': conditions['katcha_pakka'] ?? false,
              'hut': conditions['hut'] ?? false,
              'toilet_in_use': conditions['toilet_in_use'],
              'toilet_condition': conditions['toilet_condition'],
            };
          }

          // Load house facilities data (toilet, drainage, etc.)
          final houseFacilitiesData = await _databaseService.getData('house_facilities', state.phoneNumber!);
          if (houseFacilitiesData.isNotEmpty) {
            final facilities = houseFacilitiesData.first;

            // Top-level keys for page widgets
            data.addAll({
              'toilet': facilities['toilet'] ?? false,
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

            // Nested `facilities` map for preview/export
            data['facilities'] = {
              'toilet': facilities['toilet'] ?? false,
              'drainage': facilities['drainage'] ?? false,
              'soak_pit': facilities['soak_pit'] ?? false,
              'cattle_shed': facilities['cattle_shed'] ?? false,
              'compost_pit': facilities['compost_pit'] ?? false,
              'nadep': facilities['nadep'] ?? false,
              'lpg_gas': facilities['lpg_gas'] ?? false,
              'biogas': facilities['biogas'] ?? false,
              'solar_cooking': facilities['solar_cooking'] ?? false,
              'electric_connection': facilities['electric_connection'] ?? false,
              'nutritional_garden_available': facilities['nutritional_garden_available'] ?? false,
              'tulsi_plants_available': facilities['tulsi_plants_available'],
            };
          }

          final tulsiData = await _databaseService.getData('tulsi_plants', state.phoneNumber!);
          if (tulsiData.isNotEmpty) {
            data['tulsi_plant_count'] = tulsiData.first['plant_count'];
            // also expose under nested `facilities` for preview if present
            data['facilities'] = (data['facilities'] as Map<String, dynamic>? ?? {})..addAll({'tulsi_plant_count': tulsiData.first['plant_count']});
          }

          final nutritionData = await _databaseService.getData('nutritional_garden', state.phoneNumber!);
          if (nutritionData.isNotEmpty) {
            data['nutritional_garden_size'] = nutritionData.first['garden_size'];
            data['nutritional_garden_vegetables'] = nutritionData.first['vegetables_grown'];
            data['facilities'] = (data['facilities'] as Map<String, dynamic>? ?? {})..addAll({'nutritional_garden_size': nutritionData.first['garden_size'], 'nutritional_garden_vegetables': nutritionData.first['vegetables_grown']});
          }
          break;
        case 17: // Diseases
          final diseaseData = await _databaseService.getData('diseases', state.phoneNumber!);
          if (diseaseData.isNotEmpty) {
            data['members'] = diseaseData.map((row) {
              return {
                'sr_no': row['sr_no'],
                'name': row['family_member_name'],
                'disease_name': row['disease_name'],
                'suffering_since': row['suffering_since'],
                'treatment_taken': row['treatment_taken'],
                'treatment_from_when': row['treatment_from_when'],
                'treatment_from_where': row['treatment_from_where'],
                'treatment_taken_from': row['treatment_taken_from'],
              };
            }).toList();
            data['is_beneficiary'] = true;
          }
          break;
        case 18: // Government schemes
          final aadhaarInfo = await _databaseService.getData('aadhaar_info', state.phoneNumber!);
          if (aadhaarInfo.isNotEmpty) {
            data['aadhaar_info'] = aadhaarInfo.first;
          }

          final ayushmanCard = await _databaseService.getData('ayushman_card', state.phoneNumber!);
          if (ayushmanCard.isNotEmpty) {
            data['ayushman_card'] = ayushmanCard.first;
          }

          final familyId = await _databaseService.getData('family_id', state.phoneNumber!);
          if (familyId.isNotEmpty) {
            data['family_id'] = familyId.first;
          }

          final rationCard = await _databaseService.getData('ration_card', state.phoneNumber!);
          if (rationCard.isNotEmpty) {
            data['ration_card'] = rationCard.first;
          }

          final samagraId = await _databaseService.getData('samagra_id', state.phoneNumber!);
          if (samagraId.isNotEmpty) {
            data['samagra_id'] = samagraId.first;
          }

          final tribalCard = await _databaseService.getData('tribal_card', state.phoneNumber!);
          if (tribalCard.isNotEmpty) {
            data['tribal_card'] = tribalCard.first;
          }

          final handicappedAllowance = await _databaseService.getData('handicapped_allowance', state.phoneNumber!);
          if (handicappedAllowance.isNotEmpty) {
            data['handicapped_allowance'] = handicappedAllowance.first;
          }

          final pensionAllowance = await _databaseService.getData('pension_allowance', state.phoneNumber!);
          if (pensionAllowance.isNotEmpty) {
            data['pension_allowance'] = pensionAllowance.first;
          }

          final widowAllowance = await _databaseService.getData('widow_allowance', state.phoneNumber!);
          if (widowAllowance.isNotEmpty) {
            data['widow_allowance'] = widowAllowance.first;
          }

          final vbGram = await _databaseService.getData('vb_gram', state.phoneNumber!);
          if (vbGram.isNotEmpty) {
            data['vb_gram'] = vbGram.first;
          }

          final pmKisan = await _databaseService.getData('pm_kisan_nidhi', state.phoneNumber!);
          if (pmKisan.isNotEmpty) {
            data['pm_kisan_nidhi'] = pmKisan.first;
          }

          final mergedSchemes = await _databaseService.getData('merged_govt_schemes', state.phoneNumber!);
          if (mergedSchemes.isNotEmpty) {
            data['merged_govt_schemes'] = mergedSchemes.first;
          }

          // Load government scheme member data
          final aadhaarMembers = await _databaseService.getData('aadhaar_scheme_members', state.phoneNumber!);
          if (aadhaarMembers.isNotEmpty) {
            data['aadhaar_scheme_members'] = aadhaarMembers;
          }

          final ayushmanMembers = await _databaseService.getData('ayushman_scheme_members', state.phoneNumber!);
          if (ayushmanMembers.isNotEmpty) {
            data['ayushman_scheme_members'] = ayushmanMembers;
          }

          final rationMembers = await _databaseService.getData('ration_scheme_members', state.phoneNumber!);
          if (rationMembers.isNotEmpty) {
            data['ration_scheme_members'] = rationMembers;
          }

          final familyIdMembers = await _databaseService.getData('family_id_scheme_members', state.phoneNumber!);
          if (familyIdMembers.isNotEmpty) {
            data['family_id_scheme_members'] = familyIdMembers;
          }

          final samagraMembers = await _databaseService.getData('samagra_scheme_members', state.phoneNumber!);
          if (samagraMembers.isNotEmpty) {
            data['samagra_scheme_members'] = samagraMembers;
          }

          final handicappedMembers = await _databaseService.getData('handicapped_scheme_members', state.phoneNumber!);
          if (handicappedMembers.isNotEmpty) {
            data['handicapped_scheme_members'] = handicappedMembers;
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

          final vbGramMembers = await _databaseService.getData('vb_gram_members', state.phoneNumber!);
          if (vbGramMembers.isNotEmpty) {
            data['vb_gram_members'] = vbGramMembers;
          }

          final pmKisanMembers = await _databaseService.getData('pm_kisan_members', state.phoneNumber!);
          if (pmKisanMembers.isNotEmpty) {
            data['pm_kisan_members'] = pmKisanMembers;
          }
          break;
        case 19: // Folklore Medicine
          final folkloreData = await _databaseService.getData('folklore_medicine', state.phoneNumber!);
          if (folkloreData.isNotEmpty) {
            data['folklore_medicines'] = folkloreData;
          }
          break;
        case 20: // Health Programme Implemented
          final healthProgrammeData = await _databaseService.getData('health_programmes', state.phoneNumber!);
          if (healthProgrammeData.isNotEmpty) {
            final row = Map<String, dynamic>.from(healthProgrammeData.first);
            // keep top-level keys for page widgets and nested map for preview/export
            data.addAll(row);
            data['health_programmes'] = row;
          }
          break;
        case 21: // Children data
          final childrenData = await _databaseService.getData('children_data', state.phoneNumber!);
          if (childrenData.isNotEmpty) {
            final row = Map<String, dynamic>.from(childrenData.first);
            // top-level keys for page widgets
            data.addAll(row);
            // nested list for preview/export (keep shape consistent with saving/mirroring)
            data['children'] = [row];
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

          final malnutritionData = await _databaseService.getData('malnutrition_data', state.phoneNumber!);
          if (malnutritionData.isNotEmpty) {
            data['malnutrition_data'] = malnutritionData;
          }
          break;
        case 22: // Migration
          final migration = await _databaseService.getData('migration_data', state.phoneNumber!);
          if (migration.isNotEmpty) {
            final row = Map<String, dynamic>.from(migration.first);
            // top-level keys for page widgets
            data.addAll(row);
            // nested map for preview/export
            data['migration'] = row;

            final rawMembers = row['migrated_members_json'];
            try {
              if (rawMembers is String && rawMembers.trim().isNotEmpty) {
                final decoded = jsonDecode(rawMembers);
                if (decoded is List) {
                  data['migrated_members'] = decoded;
                }
              }
            } catch (_) {}
          }
          break;
        case 23: // Training
          // Load training data
          final trainingData = await _databaseService.getData('training_data', state.phoneNumber!);
          if (trainingData.isNotEmpty) {
            data['training_members'] = trainingData.map((t) {
              return {
                ...t,
                'training_type': t['training_topic'] ?? t['training_type'],
                'pass_out_year': t['training_date'] ?? t['pass_out_year'],
              };
            }).toList();
          }

          // Load SHG data
          final shgData = await _databaseService.getData('shg_members', state.phoneNumber!);
          if (shgData.isNotEmpty) {
            data['shg_members'] = shgData;
          }

          // Load FPO data
          final fpoData = await _databaseService.getData('fpo_members', state.phoneNumber!);
          if (fpoData.isNotEmpty) {
            data['fpo_members'] = fpoData;
          }
          break;
        case 24: // VB Gram beneficiaries
          final vbGramData = await _databaseService.getData('vb_gram', state.phoneNumber!);
          final vbGramMembers = await _databaseService.getData('vb_gram_members', state.phoneNumber!);
          data['vb_gram'] = {
            'is_beneficiary': vbGramData.isNotEmpty ? (vbGramData.first['is_member'] ?? false) : false,
            'members': vbGramMembers
                .map((m) => {
                      'sr_no': m['sr_no'],
                      'name': m['member_name'],
                      'name_included': m['name_included'],
                      'details_correct': m['details_correct'],
                      'incorrect_details': m['incorrect_details'],
                      'received': m['received'],
                      'days': m['days'],
                    })
                .toList(),
          };
          break;
        case 25: // PM Kisan beneficiaries
          final pmKisanData = await _databaseService.getData('pm_kisan_nidhi', state.phoneNumber!);
          final pmKisanMembers = await _databaseService.getData('pm_kisan_members', state.phoneNumber!);
          data['pm_kisan_nidhi'] = {
            'is_beneficiary': pmKisanData.isNotEmpty ? (pmKisanData.first['is_beneficiary'] ?? false) : false,
            'members': pmKisanMembers
                .map((m) => {
                      'sr_no': m['sr_no'],
                      'name': m['member_name'],
                      'details_correct': m['details_correct'],
                      'incorrect_details': m['incorrect_details'],
                      'received': m['received'],
                      'days': m['days'],
                    })
                .toList(),
          };
          break;
        case 26: // PM Kisan Samman Nidhi
          final pmSammanData = await _databaseService.getData('pm_kisan_samman_nidhi', state.phoneNumber!);
          final pmSammanMembers = await _databaseService.getData('pm_kisan_samman_members', state.phoneNumber!);
          data['pm_kisan_samman_nidhi'] = {
            'is_beneficiary': pmSammanData.isNotEmpty ? (pmSammanData.first['is_beneficiary'] ?? false) : false,
            'members': pmSammanMembers
                .map((m) => {
                      'sr_no': m['sr_no'],
                      'name': m['member_name'],
                      'details_correct': m['details_correct'],
                      'incorrect_details': m['incorrect_details'],
                      'received': m['received'],
                      'days': m['days'],
                    })
                .toList(),
          };
          break;
        case 27: // Kisan Credit Card
          data['kisan_credit_card'] = await _getMergedSchemeByKey(state.phoneNumber!, 'kisan_credit_card');
          break;
        case 28: // Swachh Bharat
          data['swachh_bharat'] = await _getMergedSchemeByKey(state.phoneNumber!, 'swachh_bharat');
          break;
        case 29: // Fasal Bima
          data['fasal_bima'] = await _getMergedSchemeByKey(state.phoneNumber!, 'fasal_bima');
          break;
        case 30: // Bank accounts
          final bankAccountData = await _databaseService.getData('bank_accounts', state.phoneNumber!);
          if (bankAccountData.isNotEmpty) {
            final membersMap = <String, List<Map<String, dynamic>>>{};
            for (final row in bankAccountData) {
              final memberName = row['member_name']?.toString() ?? '';
              membersMap.putIfAbsent(memberName, () => []);
              membersMap[memberName]!.add({
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
            data['members'] = membersMap.entries.map((entry) {
              return {
                'name': entry.key,
                'bank_accounts': entry.value,
              };
            }).toList();
            data['is_beneficiary'] = true;
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

    Future<void> _replaceTable(String tableName) async {
      await _databaseService.deleteByPhone(tableName, state.phoneNumber!);
    }

    // Map page numbers to database tables and save accordingly
    switch (page) {
      case 0: // Location page
        final existing = await _databaseService.getSurveySession(state.phoneNumber!);
        final resolvedEmail =
          existing?['surveyor_email'] ?? _supabaseService.currentUser?.email ?? 'unknown';

        await _databaseService.saveData('family_survey_sessions', {
          'phone_number': state.phoneNumber,
          'surveyor_email': resolvedEmail,
          'village_name': data['village_name'],
          'village_number': data['village_number'],
          'state': data['state'],
          'panchayat': data['panchayat'],
          'block': data['block'],
          'tehsil': data['tehsil'],
          'district': data['district'],
          'postal_address': data['postal_address'],
          'pin_code': data['pin_code'],
          'lgd_code': data['lgd_code'],
          'surveyor_name': data['surveyor_name'],
          'shine_code': data['shine_code'],
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'location_accuracy': data['location_accuracy'] ?? data['accuracy'],
          'location_timestamp': data['location_timestamp'],
          'updated_at': DateTime.now().toIso8601String(),
        });
        break;
      case 1: // Family details page
        await _replaceTable('family_members');
        if (data['family_members'] != null) {
          print('👥 _savePageData: Saving ${data['family_members'].length} family members');
          int srNo = 0;
          for (final member in data['family_members']) {
            srNo++;
            await _databaseService.saveData('family_members', {
              'phone_number': state.phoneNumber,
              'sr_no': member['sr_no'] ?? srNo,
              'name': member['name'],
              'fathers_name': member['fathers_name'],
              'mothers_name': member['mothers_name'],
              'relationship_with_head': member['relationship_with_head'],
              'age': member['age'],
              'sex': member['sex'],
              'physically_fit': member['physically_fit'],
              'physically_fit_cause': member['physically_fit_cause'],
              'educational_qualification': member['educational_qualification'],
              'inclination_self_employment': member['inclination_self_employment'],
              'occupation': member['occupation'],
              'days_employed': member['days_employed'],
              'income': member['income'],
              'awareness_about_village': member['awareness_about_village'],
              'participate_gram_sabha': member['participate_gram_sabha'],
              'insured': member['insured'],
              'insurance_company': member['insurance_company'],
            });
          }
        } else {
          print('❌ _savePageData: No family_members data found');
        }
        break;
      case 2: // Social Consciousness 1
      case 3: // Social Consciousness 2
      case 4: // Social Consciousness 3
        try {
          await _replaceTable('social_consciousness');
          await _replaceTable('tribal_questions');
          await _databaseService.saveData('social_consciousness', {
            'phone_number': state.phoneNumber,
            ...data,
          });
          if (data['tribal_questions'] != null) {
            await _databaseService.saveData('tribal_questions', {
              'phone_number': state.phoneNumber,
              ...data['tribal_questions'],
            });
          } else if (data.containsKey('deity_name') || data.containsKey('festival_name')) {
            await _databaseService.saveData('tribal_questions', {
              'phone_number': state.phoneNumber,
              'deity_name': data['deity_name'],
              'festival_name': data['festival_name'],
              'dance_name': data['dance_name'],
              'language': data['language'],
            });
          }
        } catch (e) {
          print('Error saving social data: $e');
        }
        break;
      case 5: // Land Holding
        print('🌾 _savePageData: Saving land holding data');
        print('📊 Land data keys: ${data.keys.where((k) => k.contains('land') || k.contains('irrigated') || k.contains('cultivable') || k.contains('mango') || k.contains('guava')).toList()}');
        await _replaceTable('land_holding');
        await _databaseService.saveData('land_holding', {
          'phone_number': state.phoneNumber,
          'irrigated_area': data['irrigated_area'],
          'cultivable_area': data['cultivable_area'],
          'unirrigated_area': data['unirrigated_area'],
          'barren_land': data['barren_land'],
          'mango_trees': data['mango_trees'],
          'guava_trees': data['guava_trees'],
          'lemon_trees': data['lemon_trees'],
          'banana_plants': data['banana_plants'],
          'papaya_trees': data['papaya_trees'],
          'pomegranate_trees': data['pomegranate_trees'],
          'other_fruit_trees_name': data['other_orchard_plants'] ?? data['other_fruit_trees_name'],
          'other_fruit_trees_count': data['other_fruit_trees_count'] ?? (data['other_fruit_trees'] == true || data['other_fruit_trees'] == 1 ? 1 : 0),
          'other_orchard_plants': data['other_orchard_plants'],
        });
        break;
      case 6: // Irrigation
        try {
          await _replaceTable('irrigation_facilities');
          await _databaseService.saveData('irrigation_facilities', {
            'phone_number': state.phoneNumber,
            'canal': data['canal'],
            'tube_well': data['tube_well'],
            'pond': data['pond'],
            'other_sources': data['other_sources'],
          });
        } catch (e) {
          print('Error saving irrigation data: $e');
        }
        break;
      case 7: // Crop Productivity
        try {
          await _replaceTable('crop_productivity');
          final cropList = data['crop_productivity'] ?? data['crops'];
          if (cropList != null) {
            final crops = cropList as List<Map<String, dynamic>>;
            final uniqueCrops = <String, Map<String, dynamic>>{};
            for (final crop in crops) {
              final key = '${crop['season']}-${crop['crop_name'] ?? crop['name']}-${crop['area_hectares'] ?? crop['area']}-${crop['productivity_quintal_per_hectare'] ?? crop['productivity']}-${crop['total_production_quintal'] ?? crop['total_production']}-${crop['quantity_sold_quintal'] ?? crop['sold']}';
              uniqueCrops[key] = crop;
            }
            int srNo = 0;
            for (final crop in uniqueCrops.values) {
              srNo++;
              await _databaseService.saveData('crop_productivity', {
                'phone_number': state.phoneNumber,
                'sr_no': srNo,
                'season': crop['season'],
                'crop_name': crop['crop_name'] ?? crop['name'],
                'area_hectares': crop['area_hectares'] ?? crop['area'],
                'productivity_quintal_per_hectare': crop['productivity_quintal_per_hectare'] ?? crop['productivity'],
                'total_production_quintal': crop['total_production_quintal'] ?? crop['total_production'],
                'quantity_consumed_quintal': crop['quantity_consumed_quintal'] ?? crop['consumed'],
                'quantity_sold_quintal': crop['quantity_sold_quintal'] ?? crop['sold'],
              });
            }
            // Update state with deduped data
            state.surveyData['crops'] = uniqueCrops.values.toList();
          }
        } catch (e) {
          print('Error saving crop data: $e');
        }
        break;
      case 8: // Fertilizer Usage
        try {
          await _replaceTable('fertilizer_usage');
          await _databaseService.saveData('fertilizer_usage', {
            'phone_number': state.phoneNumber,
            'urea_fertilizer': data['urea_fertilizer'],
            'organic_fertilizer': data['organic_fertilizer'],
            'fertilizer_types': data['fertilizer_types'],
          });
        } catch (e) {
          print('Error saving fertilizer data: $e');
        }
        break;
      case 9: // Animals
        try {
          await _replaceTable('animals');
          final animals = data['animals'] as List<Map<String, dynamic>>? ?? [];
          final uniqueAnimals = <String, Map<String, dynamic>>{};
          for (final animal in animals) {
            final key = '${animal['animal_type']}-${animal['number_of_animals']}-${animal['breed']}-${animal['production_per_animal']}-${animal['quantity_sold']}';
            uniqueAnimals[key] = animal;
          }
          int srNo = 0;
          for (final animal in uniqueAnimals.values) {
            srNo++;
            await _databaseService.saveData('animals', {
              'phone_number': state.phoneNumber,
              'sr_no': srNo,
              'animal_type': animal['animal_type'],
              'number_of_animals': animal['number_of_animals'],
              'breed': animal['breed'],
              'production_per_animal': animal['production_per_animal'],
              'quantity_sold': animal['quantity_sold'],
            });
          }
          // Update state with deduped data
          state.surveyData['animals'] = uniqueAnimals.values.toList();
        } catch (e) {
          print('Error saving animals data: $e');
        }
        break;
      case 10: // Agricultural Equipment
        try {
          await _replaceTable('agricultural_equipment');
          await _databaseService.saveData('agricultural_equipment', {
            'phone_number': state.phoneNumber,
            'tractor': data['tractor'],
            'tractor_condition': data['tractor_condition'],
            'thresher': data['thresher'],
            'thresher_condition': data['thresher_condition'],
            'seed_drill': data['seed_drill'],
            'seed_drill_condition': data['seed_drill_condition'],
            'sprayer': data['sprayer'],
            'sprayer_condition': data['sprayer_condition'],
            'duster': data['duster'],
            'duster_condition': data['duster_condition'],
            'diesel_engine': data['diesel_engine'],
            'diesel_engine_condition': data['diesel_engine_condition'],
            'other_equipment': data['other_equipment'],
          });
        } catch (e) {
          print('Error saving equipment data: $e');
        }
        break;
      case 11: // Entertainment Facilities
        try {
          await _replaceTable('entertainment_facilities');
          await _databaseService.saveData('entertainment_facilities', {
            'phone_number': state.phoneNumber,
            ...data,
          });
        } catch (e) {
          print('Error saving entertainment data: $e');
        }
        break;
      case 12: // Transport Facilities
        try {
          await _replaceTable('transport_facilities');
          await _databaseService.saveData('transport_facilities', {
            'phone_number': state.phoneNumber,
            ...data,
          });
        } catch (e) {
          print('Error saving transport data: $e');
        }
        break;
      case 13: // Water Sources
        try {
          await _replaceTable('drinking_water_sources');

          // Accept either a nested map (`water_sources`) or top-level keys (page uses top-level).
          final raw = data['water_sources'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(data['water_sources'])
              : Map<String, dynamic>.from(data);

          final rowToSave = {
            'phone_number': state.phoneNumber,
            'hand_pumps': raw['hand_pumps'],
            'hand_pumps_distance': raw['hand_pumps_distance'],
            'hand_pumps_quality': raw['hand_pumps_quality'],
            'well': raw['well'],
            'well_distance': raw['well_distance'],
            'well_quality': raw['well_quality'],
            'tubewell': raw['tubewell'],
            'tubewell_distance': raw['tubewell_distance'],
            'tubewell_quality': raw['tubewell_quality'],
            'nal_jaal': raw['nal_jaal'],
            'nal_jaal_quality': raw['nal_jaal_quality'],
            'other_source': raw['other_source'],
            'other_distance': raw['other_distance'],
            'other_sources_quality': raw['other_sources_quality'],
            'created_at': DateTime.now().toIso8601String(),
          };

          await _databaseService.saveData('drinking_water_sources', rowToSave);

          // Keep provider state consistent: update nested and top-level keys so UI/preview match.
          final newData = Map<String, dynamic>.from(state.surveyData);
          newData['water_sources'] = Map<String, dynamic>.from(rowToSave);
          // also expose top-level entries for page widgets
          newData.addAll(rowToSave);
          state = state.copyWith(surveyData: newData);
        } catch (e) {
          print('Error saving water sources data: $e');
        }
        break;
      case 14: // Medical Treatment
        try {
          await _replaceTable('medical_treatment');

          // Accept either nested `medical` map or top-level keys
          final raw = data['medical'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(data['medical'])
              : Map<String, dynamic>.from(data);

          final rowToSave = {
            'phone_number': state.phoneNumber,
            'allopathic': raw['allopathic'],
            'ayurvedic': raw['ayurvedic'],
            'homeopathy': raw['homeopathy'],
            'traditional': raw['traditional'],
            'other_treatment': raw['other_treatment'],
            'preferred_treatment': raw['preferred_treatment'],
            'created_at': DateTime.now().toIso8601String(),
          };

          await _databaseService.saveData('medical_treatment', rowToSave);

          // Keep provider state consistent for both page widgets (top-level keys)
          // and preview/export (nested `medical` map).
          final newData = Map<String, dynamic>.from(state.surveyData);
          newData['medical'] = Map<String, dynamic>.from(rowToSave);
          // expose top-level keys as well (so page widgets that read top-level keep working)
          newData.addAll(rowToSave);
          state = state.copyWith(surveyData: newData);
        } catch (e) {
          print('Error saving medical data: $e');
        }
        break;
      case 15: // Disputes
        try {
          await _replaceTable('disputes');

          // Accept either nested `disputes` map or flat top-level keys
          final raw = data['disputes'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(data['disputes'])
              : Map<String, dynamic>.from(data);

          final rowToSave = {
            'phone_number': state.phoneNumber,
            'family_disputes': raw['family_disputes'],
            'family_registered': raw['family_registered'],
            'family_period': raw['family_period'],
            'revenue_disputes': raw['revenue_disputes'],
            'revenue_registered': raw['revenue_registered'],
            'revenue_period': raw['revenue_period'],
            'criminal_disputes': raw['criminal_disputes'],
            'criminal_registered': raw['criminal_registered'],
            'criminal_period': raw['criminal_period'],
            'other_disputes': raw['other_disputes'],
            'other_description': raw['other_description'],
            'other_registered': raw['other_registered'],
            'other_period': raw['other_period'],
            'created_at': DateTime.now().toIso8601String(),
          };

          await _databaseService.saveData('disputes', rowToSave);

          // Keep provider state consistent for preview (nested `disputes`) and page widgets (top-level keys)
          final newData = Map<String, dynamic>.from(state.surveyData);
          newData['disputes'] = Map<String, dynamic>.from(rowToSave);
          newData.addAll(rowToSave);
          state = state.copyWith(surveyData: newData);
        } catch (e) {
          print('Error saving disputes data: $e');
        }
        break;
      case 16: // House Conditions
        try {
          await _replaceTable('house_conditions');
          await _replaceTable('house_facilities');
          await _replaceTable('tulsi_plants');
          await _replaceTable('nutritional_garden');

          // Save house conditions data (katcha, pakka, etc.)
          final houseConditionsData = {
            'phone_number': state.phoneNumber,
            'katcha': data['katcha_house'] ?? false,
            'pakka': data['pakka_house'] ?? false,
            'katcha_pakka': data['katcha_pakka_house'] ?? false,
            'hut': data['hut_house'] ?? false,
            'toilet_in_use': data['toilet_in_use'],
            'toilet_condition': data['toilet_condition'],
            'created_at': DateTime.now().toIso8601String(),
          };
          await _databaseService.saveData('house_conditions', houseConditionsData);

          // Save house facilities data (toilet, drainage, etc.)
          final houseFacilitiesData = {
            'phone_number': state.phoneNumber,
            'toilet': data['toilet'] ?? false,
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
            'created_at': DateTime.now().toIso8601String(),
          };
          await _databaseService.saveData('house_facilities', houseFacilitiesData);

          if (data['tulsi_plants'] != null) {
            await _databaseService.saveData('tulsi_plants', {
              'phone_number': state.phoneNumber,
              'has_plants': data['tulsi_plants'],
              'plant_count': data['tulsi_plant_count'],
            });
          }

          if (data['nutritional_garden'] != null) {
            await _databaseService.saveData('nutritional_garden', {
              'phone_number': state.phoneNumber,
              'has_garden': data['nutritional_garden'],
              'garden_size': data['nutritional_garden_size'],
              'vegetables_grown': data['nutritional_garden_vegetables'],
            });
          }

          // Keep provider state consistent for preview and page widgets
          final newData = Map<String, dynamic>.from(state.surveyData);
          newData['house'] = {
            'katcha': houseConditionsData['katcha'],
            'pakka': houseConditionsData['pakka'],
            'katcha_pakka': houseConditionsData['katcha_pakka'],
            'hut': houseConditionsData['hut'],
            'toilet_in_use': houseConditionsData['toilet_in_use'],
            'toilet_condition': houseConditionsData['toilet_condition'],
          };
          newData['facilities'] = {
            ...houseFacilitiesData,
          };

          // also keep top-level keys (page widgets read top-level)
          newData.addAll({
            'katcha_house': houseConditionsData['katcha'],
            'pakka_house': houseConditionsData['pakka'],
            'katcha_pakka_house': houseConditionsData['katcha_pakka'],
            'hut_house': houseConditionsData['hut'],
            'toilet': houseFacilitiesData['toilet'],
            'drainage': houseFacilitiesData['drainage'],
            'soak_pit': houseFacilitiesData['soak_pit'],
            'cattle_shed': houseFacilitiesData['cattle_shed'],
            'compost_pit': houseFacilitiesData['compost_pit'],
            'nadep': houseFacilitiesData['nadep'],
            'lpg_gas': houseFacilitiesData['lpg_gas'],
            'biogas': houseFacilitiesData['biogas'],
            'solar_cooking': houseFacilitiesData['solar_cooking'],
            'electric_connection': houseFacilitiesData['electric_connection'],
            'nutritional_garden': houseFacilitiesData['nutritional_garden_available'],
            'tulsi_plants': houseFacilitiesData['tulsi_plants_available'],
            'tulsi_plant_count': data['tulsi_plant_count'],
            'nutritional_garden_size': data['nutritional_garden_size'],
            'nutritional_garden_vegetables': data['nutritional_garden_vegetables'],
          });

          state = state.copyWith(surveyData: newData);
        } catch (e) {
          print('Error saving house conditions data: $e');
        }
        break;
      case 17: // Diseases
        // Normalize incoming shapes: allow `diseases` as List, `diseases` as Map with `members`,
        // or top-level `members` (what the page widget emits). Then save each row.
        await _replaceTable('diseases');

        final raw = data['diseases'] ?? data['members'];
        List<Map<String, dynamic>> diseaseEntries = [];

        if (raw is List) {
          diseaseEntries = raw.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
        } else if (raw is Map && raw['members'] is List) {
          diseaseEntries = (raw['members'] as List).map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
        }

        // Debug/log so we can see what's being saved during runtime
        print('💾 _savePageData(case 17): saving ${diseaseEntries.length} disease entries');

        if (diseaseEntries.isNotEmpty) {
          int srNo = 0;
          for (final disease in diseaseEntries) {
            srNo++;
            try {
              await _databaseService.saveData('diseases', {
                'phone_number': state.phoneNumber,
                'sr_no': disease['sr_no'] ?? srNo,
                'family_member_name': disease['family_member_name'] ?? disease['name'],
                'disease_name': disease['disease_name'] ?? disease['name'],
                'suffering_since': disease['suffering_since'],
                'treatment_taken': disease['treatment_taken'],
                'treatment_from_when': disease['treatment_from_when'],
                'treatment_from_where': disease['treatment_from_where'],
                'treatment_taken_from': disease['treatment_taken_from'],
                'created_at': DateTime.now().toIso8601String(),
              });
            } catch (e) {
              print('Error saving diseases row (sr_no=$srNo): $e');
            }
          }

          // Keep provider state consistent for preview and page widgets
          final newData = Map<String, dynamic>.from(state.surveyData);
          newData['diseases'] = diseaseEntries.map((d) {
            return {
              'sr_no': d['sr_no'] ?? (diseaseEntries.indexOf(d) + 1),
              'family_member_name': d['family_member_name'] ?? d['name'],
              'disease_name': d['disease_name'] ?? d['name'],
              'suffering_since': d['suffering_since'],
              'treatment_taken': d['treatment_taken'],
              'treatment_from_when': d['treatment_from_when'],
              'treatment_from_where': d['treatment_from_where'],
              'treatment_taken_from': d['treatment_taken_from'],
            };
          }).toList();

          // also keep top-level members key because the page widget reads `members`
          newData['members'] = diseaseEntries;
          newData['is_beneficiary'] = (data['is_beneficiary'] ?? true);
          state = state.copyWith(surveyData: newData);
        }
        break;
      case 18: // Government schemes
        // Save each scheme/table only when incoming data differs from DB (idempotency)
        // and mirror into provider state so preview updates immediately.

        String _sortedJson(List<Map<String, dynamic>> list) {
          final jsonList = list.map((m) => jsonEncode(m)).toList()..sort();
          return jsonEncode(jsonList);
        }

        // --- Aadhaar members + info ---
        final incomingAadhaarMembers = List<Map<String, dynamic>>.from(data['aadhaar_scheme_members'] ?? []);
        try {
          final existing = await _databaseService.getData('aadhaar_scheme_members', state.phoneNumber!);
          final cmpExisting = existing.map((e) => {
            'sr_no': e['sr_no'],
            'family_member_name': e['family_member_name'],
            'have_card': e['have_card'],
            'card_number': e['card_number'],
            'details_correct': e['details_correct'],
            'what_incorrect': e['what_incorrect'],
            'benefits_received': e['benefits_received'],
          }).toList();

          if (incomingAadhaarMembers.isNotEmpty && _sortedJson(incomingAadhaarMembers) != _sortedJson(cmpExisting)) {
            await _replaceTable('aadhaar_scheme_members');
            for (final member in incomingAadhaarMembers) {
              await _databaseService.saveData('aadhaar_scheme_members', {
                'phone_number': state.phoneNumber,
                ...member,
              });
            }
          }
        } catch (e) {
          print('Warning: Aadhaar members save failed: $e');
        }

        if (data['aadhaar_info'] != null) {
          final incoming = Map<String, dynamic>.from(data['aadhaar_info']);
          try {
            final existing = await _databaseService.getData('aadhaar_info', state.phoneNumber!);
            if (existing.isEmpty || !mapEquals(Map<String, dynamic>.from(existing.first)..remove('id'), incoming)) {
              await _replaceTable('aadhaar_info');
              await _databaseService.saveData('aadhaar_info', {
                'phone_number': state.phoneNumber,
                ...incoming,
              });
            }
          } catch (e) {
            print('Warning: Aadhaar info save failed: $e');
            await _databaseService.saveData('aadhaar_info', {'phone_number': state.phoneNumber, ...incoming});
          }
        }

        // --- Ayushman members + card ---
        final incomingAyushman = List<Map<String, dynamic>>.from(data['ayushman_scheme_members'] ?? []);
        try {
          final existing = await _databaseService.getData('ayushman_scheme_members', state.phoneNumber!);
          final cmpExisting = existing.map((e) => {
            'sr_no': e['sr_no'],
            'family_member_name': e['family_member_name'],
            'have_card': e['have_card'],
            'card_number': e['card_number'],
            'details_correct': e['details_correct'],
            'what_incorrect': e['what_incorrect'],
            'benefits_received': e['benefits_received'],
          }).toList();

          if (incomingAyushman.isNotEmpty && _sortedJson(incomingAyushman) != _sortedJson(cmpExisting)) {
            await _replaceTable('ayushman_scheme_members');
            for (final member in incomingAyushman) {
              await _databaseService.saveData('ayushman_scheme_members', {
                'phone_number': state.phoneNumber,
                ...member,
              });
            }
          }
        } catch (e) {
          print('Warning: Ayushman members save failed: $e');
        }

        if (data['ayushman_card'] != null) {
          final incoming = Map<String, dynamic>.from(data['ayushman_card']);
          try {
            final existing = await _databaseService.getData('ayushman_card', state.phoneNumber!);
            if (existing.isEmpty || !mapEquals(Map<String, dynamic>.from(existing.first)..remove('id'), incoming)) {
              await _replaceTable('ayushman_card');
              await _databaseService.saveData('ayushman_card', {'phone_number': state.phoneNumber, ...incoming});
            }
          } catch (e) {
            print('Warning: Ayushman card save failed: $e');
            await _databaseService.saveData('ayushman_card', {'phone_number': state.phoneNumber, ...incoming});
          }
        }

        // --- Ration card ---
        final incomingRationMembers = List<Map<String, dynamic>>.from(data['ration_scheme_members'] ?? []);
        try {
          final existing = await _databaseService.getData('ration_scheme_members', state.phoneNumber!);
          if (incomingRationMembers.isNotEmpty && _sortedJson(incomingRationMembers) != _sortedJson(existing.map((e) => e as Map<String, dynamic>).toList())) {
            await _replaceTable('ration_scheme_members');
            for (final member in incomingRationMembers) {
              await _databaseService.saveData('ration_scheme_members', {'phone_number': state.phoneNumber, ...member});
            }
          }
        } catch (e) {
          print('Warning: Ration members save failed: $e');
        }
        if (data['ration_card'] != null) {
          final incoming = Map<String, dynamic>.from(data['ration_card']);
          try {
            final existing = await _databaseService.getData('ration_card', state.phoneNumber!);
            if (existing.isEmpty || !mapEquals(Map<String, dynamic>.from(existing.first)..remove('id'), incoming)) {
              await _replaceTable('ration_card');
              await _databaseService.saveData('ration_card', {'phone_number': state.phoneNumber, ...incoming});
            }
          } catch (e) {
            print('Warning: Ration card save failed: $e');
            await _databaseService.saveData('ration_card', {'phone_number': state.phoneNumber, ...incoming});
          }
        }

        // --- Family ID, Samagra, Handicapped, Tribal, Pension, Widow (members + rows) ---
        final groups = [
          {'membersKey': 'family_id_scheme_members', 'table': 'family_id_scheme_members', 'rowKey': 'family_id', 'rowTable': 'family_id'},
          {'membersKey': 'samagra_scheme_members', 'table': 'samagra_scheme_members', 'rowKey': 'samagra_id', 'rowTable': 'samagra_id'},
          {'membersKey': 'handicapped_scheme_members', 'table': 'handicapped_scheme_members', 'rowKey': 'handicapped_allowance', 'rowTable': 'handicapped_allowance'},
          {'membersKey': 'tribal_scheme_members', 'table': 'tribal_scheme_members', 'rowKey': 'tribal_card', 'rowTable': 'tribal_card'},
          {'membersKey': 'pension_scheme_members', 'table': 'pension_scheme_members', 'rowKey': 'pension_allowance', 'rowTable': 'pension_allowance'},
          {'membersKey': 'widow_scheme_members', 'table': 'widow_scheme_members', 'rowKey': 'widow_allowance', 'rowTable': 'widow_allowance'},
        ];

        for (final g in groups) {
          final List<Map<String, dynamic>> incomingMembers = List<Map<String, dynamic>>.from(data[g['membersKey']] ?? []);
          try {
            final existing = await _databaseService.getData(g['table'] as String, state.phoneNumber!);
            if (incomingMembers.isNotEmpty && _sortedJson(incomingMembers) != _sortedJson(existing.map((e) => e as Map<String, dynamic>).toList())) {
              await _replaceTable(g['table'] as String);
              for (final member in incomingMembers) {
                await _databaseService.saveData(g['table'] as String, {'phone_number': state.phoneNumber, ...member});
              }
            }
          } catch (e) {
            print('Warning: ${g['table']} save failed: $e');
          }

          if (data[g['rowKey']] != null) {
            final incomingRow = Map<String, dynamic>.from(data[g['rowKey']] as Map<String, dynamic>);
            try {
              final existingRow = await _databaseService.getData(g['rowTable'] as String, state.phoneNumber!);
              if (existingRow.isEmpty || !mapEquals(Map<String, dynamic>.from(existingRow.first)..remove('id'), incomingRow)) {
                await _replaceTable(g['rowTable'] as String);
                await _databaseService.saveData(g['rowTable'] as String, {'phone_number': state.phoneNumber, ...incomingRow});
              }
            } catch (e) {
              print('Warning: ${g['rowTable']} save failed: $e');
              await _databaseService.saveData(g['rowTable'] as String, {'phone_number': state.phoneNumber, ...incomingRow});
            }
          }
        }

        // VB Gram and PM Kisan handled elsewhere with their own logic; keep current behavior

        // Mirror government-schemes data back into provider state for immediate preview
        try {
          final newData = Map<String, dynamic>.from(state.surveyData);
          for (final k in data.keys) {
            // only mirror known scheme keys to avoid noise
            if ([
              'aadhaar_scheme_members',
              'aadhaar_info',
              'ayushman_scheme_members',
              'ayushman_card',
              'ration_scheme_members',
              'ration_card',
              'family_id_scheme_members',
              'family_id',
              'samagra_scheme_members',
              'samagra_id',
              'handicapped_scheme_members',
              'handicapped_allowance',
              'tribal_scheme_members',
              'tribal_card',
              'pension_scheme_members',
              'pension_allowance',
              'widow_scheme_members',
              'widow_allowance',
            ].contains(k)) {
              newData[k] = data[k];
            }
          }
          state = state.copyWith(surveyData: newData);
        } catch (e) {
          print('Warning: failed to mirror government-schemes data into provider state: $e');
        }

        print('💾 _savePageData(case 18): saved government-schemes related rows (phone=${state.phoneNumber})');
        break;
        if (data['tribal_scheme_members'] != null) {
          for (final member in data['tribal_scheme_members']) {
            await _databaseService.saveData('tribal_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['tribal_card'] != null) {
          await _databaseService.saveData('tribal_card', {
            'phone_number': state.phoneNumber,
            ...data['tribal_card'],
          });
        }

        if (data['pension_scheme_members'] != null) {
          for (final member in data['pension_scheme_members']) {
            await _databaseService.saveData('pension_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['pension_allowance'] != null) {
          await _databaseService.saveData('pension_allowance', {
            'phone_number': state.phoneNumber,
            ...data['pension_allowance'],
          });
        }

        if (data['widow_scheme_members'] != null) {
          for (final member in data['widow_scheme_members']) {
            await _databaseService.saveData('widow_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['widow_allowance'] != null) {
          await _databaseService.saveData('widow_allowance', {
            'phone_number': state.phoneNumber,
            ...data['widow_allowance'],
          });
        }

        if (data['vb_gram'] != null) {
          await _databaseService.saveData('vb_gram', {
            'phone_number': state.phoneNumber,
            ...data['vb_gram'],
          });
        }

        if (data['vb_gram_members'] != null) {
          for (final member in data['vb_gram_members']) {
            await _databaseService.saveData('vb_gram_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['pm_kisan_nidhi'] != null) {
          await _databaseService.saveData('pm_kisan_nidhi', {
            'phone_number': state.phoneNumber,
            ...data['pm_kisan_nidhi'],
          });
        }

        if (data['pm_kisan_members'] != null) {
          for (final member in data['pm_kisan_members']) {
            await _databaseService.saveData('pm_kisan_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['merged_govt_schemes'] != null) {
          final merged = data['merged_govt_schemes'];
          if (merged is Map<String, dynamic>) {
            await _databaseService.saveData('merged_govt_schemes', {
              'phone_number': state.phoneNumber,
              'scheme_data': jsonEncode(merged),
            });
          }
        }

        if (data['vb_gram'] != null) {
          await _databaseService.saveData('vb_gram', {
            'phone_number': state.phoneNumber,
            ...data['vb_gram'],
          });
        }

        if (data['vb_gram_members'] != null) {
          for (final member in data['vb_gram_members']) {
            await _databaseService.saveData('vb_gram_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['pm_kisan_nidhi'] != null) {
          await _databaseService.saveData('pm_kisan_nidhi', {
            'phone_number': state.phoneNumber,
            ...data['pm_kisan_nidhi'],
          });
        }

        if (data['pm_kisan_members'] != null) {
          for (final member in data['pm_kisan_members']) {
            await _databaseService.saveData('pm_kisan_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['pm_kisan_samman_nidhi'] != null) {
          await _databaseService.saveData('pm_kisan_samman_nidhi', {
            'phone_number': state.phoneNumber,
            ...data['pm_kisan_samman_nidhi'],
          });
        }

        if (data['pm_kisan_samman_members'] != null) {
          for (final member in data['pm_kisan_samman_members']) {
            await _databaseService.saveData('pm_kisan_samman_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        // Keep provider state consistent so preview and immediate reads reflect saved rows
        try {
          final newData = Map<String, dynamic>.from(state.surveyData);
          // copy back any members/lone rows that were present in `data`
          final keysToMirror = [
            'aadhaar_scheme_members',
            'aadhaar_info',
            'ayushman_scheme_members',
            'ayushman_card',
            'ration_scheme_members',
            'ration_card',
            'family_id_scheme_members',
            'family_id',
            'samagra_scheme_members',
            'samagra_id',
            'handicapped_scheme_members',
            'handicapped_allowance',
            'tribal_scheme_members',
            'tribal_card',
            'pension_scheme_members',
            'pension_allowance',
            'widow_scheme_members',
            'widow_allowance',
            'vb_gram',
            'vb_gram_members',
            'pm_kisan_nidhi',
            'pm_kisan_members',
            'pm_kisan_samman_nidhi',
            'pm_kisan_samman_members',
            'merged_govt_schemes',
          ];

          for (final k in keysToMirror) {
            if (data[k] != null) newData[k] = data[k];
          }

          state = state.copyWith(surveyData: newData);
        } catch (e) {
          print('Warning: failed to mirror government schemes data into provider state: $e');
        }

        print('💾 _savePageData(case 18): saved government-schemes related rows (phone=${state.phoneNumber})');
        break;
      case 19: // Folklore Medicine
        // Log + ensure provider state mirrors what's being saved so preview shows it immediately.
        final entriesCount = (data['folklore_medicines'] as List<dynamic>?)?.length ?? 0;
        print('💾 _savePageData(case 19): saving $entriesCount folklore entries for phone=${state.phoneNumber}');

        await _replaceTable('folklore_medicine');
        if (data['folklore_medicines'] != null) {
          for (final medicine in data['folklore_medicines']) {
            await _databaseService.saveData('folklore_medicine', {
              'phone_number': state.phoneNumber,
              ...medicine,
            });
          }
        }

        // Mirror back into provider state so preview/read-after-save sees the rows immediately.
        try {
          final newData = Map<String, dynamic>.from(state.surveyData);
          if (data['folklore_medicines'] != null) newData['folklore_medicines'] = data['folklore_medicines'];
          state = state.copyWith(surveyData: newData);
        } catch (e) {
          print('Warning: failed to mirror folklore_medicines into provider state: $e');
        }

        break;
      case 20: // Health Programme Implemented
        // Defensive: trim string fields and skip saving when data is empty.
        final Map<String, dynamic> row = {
          'phone_number': state.phoneNumber,
          'vaccination_pregnancy': data['vaccination_pregnancy'],
          'child_vaccination': data['child_vaccination'],
          'vaccination_schedule': data['vaccination_schedule'],
          'balance_doses_schedule': (data['balance_doses_schedule'] is String) ? (data['balance_doses_schedule'] as String).trim() : data['balance_doses_schedule'],
          'family_planning_awareness': data['family_planning_awareness'],
          'contraceptive_applied': data['contraceptive_applied'],
          'created_at': DateTime.now().toIso8601String(),
        }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

        // If nothing meaningful to save, skip
        if (row.keys.length <= 2) {
          print('⚠️ _savePageData(case 20): no meaningful health_programmes data to save for phone=${state.phoneNumber}');
          break;
        }

        // Idempotency check: compare existing DB row, skip if identical to avoid double-insert churn
        try {
          final existing = await _databaseService.getData('health_programmes', state.phoneNumber!);
          if (existing.isNotEmpty) {
            final existingRow = Map<String, dynamic>.from(existing.first);
            // remove metadata keys for comparison
            existingRow.remove('id');
            existingRow.remove('phone_number');
            existingRow.remove('created_at');

            final compareNew = Map<String, dynamic>.from(row);
            compareNew.remove('phone_number');
            compareNew.remove('created_at');

            if (mapEquals(existingRow, compareNew)) {
              print('⚠️ _savePageData(case 20): incoming health_programmes identical to existing row — skipping write');

              // Ensure provider state mirrors current DB shape for preview
              final newData = Map<String, dynamic>.from(state.surveyData);
              newData['health_programmes'] = existing.first;
              state = state.copyWith(surveyData: newData);
              break;
            }
          }
        } catch (e) {
          print('Warning: failed to compare existing health_programmes row: $e');
        }

        print('💾 _savePageData(case 20): writing health_programmes for phone=${state.phoneNumber} -> $row');
        await _replaceTable('health_programmes');
        await _databaseService.saveData('health_programmes', row);

        // Mirror into provider state so preview shows saved values immediately
        try {
          final newData = Map<String, dynamic>.from(state.surveyData);
          newData['health_programmes'] = row;
          state = state.copyWith(surveyData: newData);
        } catch (e) {
          print('Warning: failed to mirror health_programmes into provider state: $e');
        }

        break;
      case 21: // Children data
        // Normalize and trim incoming values
        final births = data['births_last_3_years'] is String ? (data['births_last_3_years'] as String).trim() : data['births_last_3_years'];
        final infantDeaths = data['infant_deaths_last_3_years'] is String ? (data['infant_deaths_last_3_years'] as String).trim() : data['infant_deaths_last_3_years'];
        final malnourishedCount = data['malnourished_children'] is String ? (data['malnourished_children'] as String).trim() : data['malnourished_children'];

        final row = {
          'phone_number': state.phoneNumber,
          'births_last_3_years': births,
          'infant_deaths_last_3_years': infantDeaths,
          'malnourished_children': malnourishedCount,
          'created_at': DateTime.now().toIso8601String(),
        }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

        if (row.keys.length <= 2) {
          print('⚠️ _savePageData(case 21): no meaningful children data to save for phone=${state.phoneNumber}');
        } else {
          // Idempotency: compare with existing DB row and skip if identical
          try {
            final existing = await _databaseService.getData('children_data', state.phoneNumber!);
            if (existing.isNotEmpty) {
              final existingRow = Map<String, dynamic>.from(existing.first);
              existingRow.remove('id');
              existingRow.remove('phone_number');
              existingRow.remove('created_at');

              final compareNew = Map<String, dynamic>.from(row);
              compareNew.remove('phone_number');
              compareNew.remove('created_at');

              if (mapEquals(existingRow, compareNew)) {
                print('⚠️ _savePageData(case 21): incoming children_data identical to existing row — skipping write');
              } else {
                await _replaceTable('children_data');
                await _databaseService.saveData('children_data', row);
                print('💾 _savePageData(case 21): wrote children_data for phone=${state.phoneNumber} -> $row');
              }
            } else {
              await _replaceTable('children_data');
              await _databaseService.saveData('children_data', row);
              print('💾 _savePageData(case 21): wrote children_data for phone=${state.phoneNumber} -> $row');
            }
          } catch (e) {
            print('Error saving children_data: $e');
          }
        }

        // Replace related tables so repeated saves don't duplicate rows
        await _replaceTable('malnourished_children_data');
        await _replaceTable('malnutrition_data');
        await _replaceTable('child_diseases');

        // Save malnourished children data and related rows
        final childDiseases = <Map<String, dynamic>>[];
        final malnutritionRows = <Map<String, dynamic>>[];
        if (data['malnourished_children_data'] != null) {
          for (final childData in data['malnourished_children_data']) {
            // Save child basic info
            final childId = childData['child_id'] ?? childData['child_name'];
            final malnChildRow = {
              'phone_number': state.phoneNumber,
              'child_id': childId,
              'child_name': childData['child_name'],
              'height': childData['height'],
              'weight': childData['weight'],
              'created_at': DateTime.now().toIso8601String(),
            }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

            await _databaseService.saveData('malnourished_children_data', malnChildRow);

            final malnutritionRow = {
              'phone_number': state.phoneNumber,
              'child_name': childData['child_name'],
              'age': childData['age'],
              'weight': childData['weight'],
              'height': childData['height'],
            }..removeWhere((k, v) => v == null);

            malnutritionRows.add(malnutritionRow);
            await _databaseService.saveData('malnutrition_data', malnutritionRow);

            // Save diseases for this child
            if (childData['diseases'] != null) {
              int diseaseIndex = 0;
              for (final disease in childData['diseases']) {
                final diseaseRow = {
                  'phone_number': state.phoneNumber,
                  'child_id': childId,
                  'disease_name': disease['name'],
                  'sr_no': diseaseIndex++,
                }..removeWhere((k, v) => v == null);

                childDiseases.add(diseaseRow);
                await _databaseService.saveData('child_diseases', diseaseRow);
              }
            }
          }
        }

        // Mirror saved values into provider state for immediate preview
        try {
          final newData = Map<String, dynamic>.from(state.surveyData);
          // mirror simple top-level keys
          if (row.isNotEmpty) {
            newData['births_last_3_years'] = row['births_last_3_years'];
            newData['infant_deaths_last_3_years'] = row['infant_deaths_last_3_years'];
            newData['malnourished_children'] = row['malnourished_children'];
          }

          if (data['malnourished_children_data'] != null) newData['malnourished_children_data'] = data['malnourished_children_data'];
          if (malnutritionRows.isNotEmpty) newData['malnutrition_data'] = malnutritionRows;
          if (childDiseases.isNotEmpty) newData['child_diseases'] = childDiseases;

          // also keep nested `children` map for preview/export expectations
          newData['children'] = [
            {
              'births_last_3_years': row['births_last_3_years'],
              'infant_deaths_last_3_years': row['infant_deaths_last_3_years'],
              'malnourished_children': row['malnourished_children'],
            }
          ]..removeWhere((e) => e.isEmpty);

          state = state.copyWith(surveyData: newData);
        } catch (e) {
          print('Warning: failed to mirror children data into provider state: $e');
        }

        break;
      case 22: // Migration
        final migratedMembers = List<Map<String, dynamic>>.from(data['migrated_members'] ?? []);

        final row = {
          'phone_number': state.phoneNumber,
          'family_members_migrated': data['no_migration'] == true ? 0 : migratedMembers.length,
          'no_migration': data['no_migration'] == true ? 1 : 0,
          'reason': data['reason'],
          'duration': data['duration'],
          'destination': data['destination'],
          'migrated_members_json': jsonEncode(migratedMembers),
          'created_at': DateTime.now().toIso8601String(),
        }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

        // Idempotency: compare existing DB row and skip if identical
        try {
          final existing = await _databaseService.getData('migration_data', state.phoneNumber!);
          if (existing.isNotEmpty) {
            final existingRow = Map<String, dynamic>.from(existing.first);
            existingRow.remove('id');
            existingRow.remove('phone_number');
            existingRow.remove('created_at');

            final compareNew = Map<String, dynamic>.from(row);
            compareNew.remove('phone_number');
            compareNew.remove('created_at');

            if (mapEquals(existingRow, compareNew)) {
              print('⚠️ _savePageData(case 22): incoming migration_data identical to existing row — skipping write');

              // Mirror existing DB row into provider state for immediate preview
              try {
                final newData = Map<String, dynamic>.from(state.surveyData);
                newData['migration'] = existing.first;
                // keep migrated_members in top-level state too
                if (data['migrated_members'] != null) newData['migrated_members'] = data['migrated_members'];
                newData['family_members_migrated'] = existing.first['family_members_migrated'];
                state = state.copyWith(surveyData: newData);
              } catch (e) {
                print('Warning: failed to mirror existing migration into provider state: $e');
              }

              break;
            }
          }
        } catch (e) {
          print('Warning: failed to compare existing migration_data row: $e');
        }

        print('💾 _savePageData(case 22): writing migration_data for phone=${state.phoneNumber} -> $row');
        await _replaceTable('migration_data');
        await _databaseService.saveData('migration_data', row);

        // Mirror saved values into provider state so preview shows them immediately
        try {
          final newData = Map<String, dynamic>.from(state.surveyData);
          newData['migration'] = row;
          newData['migrated_members'] = migratedMembers;
          newData['family_members_migrated'] = row['family_members_migrated'];
          state = state.copyWith(surveyData: newData);
        } catch (e) {
          print('Warning: failed to mirror migration into provider state: $e');
        }

        break;
      case 23: // Training
        // Normalize incoming lists
        final incomingTrainings = (data['training_members'] as List<dynamic>?)
            ?.map((t) => {
                  'member_name': t['member_name'],
                  'training_topic': t['training_topic'] ?? t['training_type'],
                  'training_duration': t['training_duration'],
                  'training_date': t['training_date'] ?? t['pass_out_year'],
                  'status': t['status'] ?? 'taken',
                })
            .toList(growable: false) ?? [];
        final incomingShg = List<Map<String, dynamic>>.from(data['shg_members'] ?? []);
        final incomingFpo = List<Map<String, dynamic>>.from(data['fpo_members'] ?? []);

        // Idempotency: if DB already contains the same set of training rows, skip write
        try {
          final existing = await _databaseService.getData('training_data', state.phoneNumber!);
          final existingNormalized = existing.map((e) {
            return {
              'member_name': e['member_name'],
              'training_topic': e['training_topic'],
              'training_duration': e['training_duration'],
              'training_date': e['training_date'],
              'status': e['status'],
            };
          }).toList();

          // Compare by JSON-serializing sorted lists to be order-insensitive
          String _sortedJson(List<Map<String, dynamic>> list) {
            final jsonList = list.map((m) => jsonEncode(m)).toList()..sort();
            return jsonEncode(jsonList);
          }

          final incomingJson = _sortedJson(incomingTrainings.cast<Map<String, dynamic>>());
          final existingJson = _sortedJson(existingNormalized.cast<Map<String, dynamic>>());

          if (incomingJson == existingJson) {
            print('⚠️ _savePageData(case 23): incoming training_members identical to DB — skipping write');
          } else {
            // replace table then write incoming rows
            await _replaceTable('training_data');
            for (final mapped in incomingTrainings) {
              await _databaseService.saveData('training_data', {
                'phone_number': state.phoneNumber,
                ...mapped,
                'created_at': DateTime.now().toIso8601String(),
              });
            }
          }
        } catch (e) {
          print('Warning: failed training_data idempotency check: $e');
          // fallback: write data (ensure table cleared first)
          await _replaceTable('training_data');
          for (final mapped in incomingTrainings) {
            await _databaseService.saveData('training_data', {
              'phone_number': state.phoneNumber,
              ...mapped,
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        }

        // Replace SHG and FPO member tables (always replace to avoid duplicates)
        await _replaceTable('shg_members');
        for (final shg in incomingShg) {
          await _databaseService.saveData('shg_members', {
            'phone_number': state.phoneNumber,
            'member_name': shg['member_name'],
            'shg_name': shg['shg_name'],
            'purpose': shg['purpose'],
            'agency': shg['agency'],
            'position': shg['position'],
            'monthly_saving': shg['monthly_saving'],
            'created_at': DateTime.now().toIso8601String(),
          });
        }

        await _replaceTable('fpo_members');
        for (final fpo in incomingFpo) {
          await _databaseService.saveData('fpo_members', {
            'phone_number': state.phoneNumber,
            'member_name': fpo['member_name'],
            'fpo_name': fpo['fpo_name'],
            'purpose': fpo['purpose'],
            'agency': fpo['agency'],
            'share_capital': fpo['share_capital'],
            'created_at': DateTime.now().toIso8601String(),
          });
        }

        // Mirror saved values into provider state so preview shows them immediately
        try {
          final newData = Map<String, dynamic>.from(state.surveyData);
          if (incomingTrainings.isNotEmpty) newData['training_members'] = incomingTrainings;
          if (incomingShg.isNotEmpty) newData['shg_members'] = incomingShg;
          if (incomingFpo.isNotEmpty) newData['fpo_members'] = incomingFpo;
          newData['want_training'] = data['want_training'] ?? newData['want_training'];
          state = state.copyWith(surveyData: newData);
          print('💾 _savePageData(case 23): mirrored training/shg/fpo into provider state');
        } catch (e) {
          print('Warning: failed to mirror training data into provider state: $e');
        }

        break;
      case 24: // VB Gram beneficiaries
        final incoming = data['vb_gram'] != null ? Map<String, dynamic>.from(data['vb_gram']) : null;
        final incomingMembers = incoming != null ? List<Map<String, dynamic>>.from(incoming['members'] ?? []) : <Map<String, dynamic>>[];

        // Build normalized row to compare/store
        final vbRow = incoming == null
            ? {}
            : {
                'phone_number': state.phoneNumber,
                'is_member': incoming['is_beneficiary'],
                'total_members': incomingMembers.length,
                'created_at': DateTime.now().toIso8601String(),
              }..removeWhere((k, v) => v == null);

        // Idempotency: compare existing DB rows
        try {
          final existingVb = await _databaseService.getData('vb_gram', state.phoneNumber!);
          final existingMembers = await _databaseService.getData('vb_gram_members', state.phoneNumber!);

          bool identical = false;
          if (incoming != null && existingVb.isNotEmpty) {
            final e = Map<String, dynamic>.from(existingVb.first);
            // compare member count and is_member flag
            if ((e['is_member'] == vbRow['is_member']) && (e['total_members'] == vbRow['total_members'])) {
              // compare members list (order-insensitive by sr_no)
              final cmpIncoming = incomingMembers.map((m) => jsonEncode({
                    'sr_no': m['sr_no'],
                    'member_name': m['name'],
                    'name_included': m['name_included'],
                    'details_correct': m['details_correct'],
                    'incorrect_details': m['incorrect_details'],
                    'received': m['received'],
                    'days': m['days'],
                  })).toList()
                ..sort();
              final cmpExisting = existingMembers.map((m) => jsonEncode({
                    'sr_no': m['sr_no'],
                    'member_name': m['member_name'],
                    'name_included': m['name_included'],
                    'details_correct': m['details_correct'],
                    'incorrect_details': m['incorrect_details'],
                    'received': m['received'],
                    'days': m['days'],
                  })).toList()
                ..sort();

              identical = listEquals(cmpIncoming, cmpExisting);
            }
          }

          if (identical) {
            print('⚠️ _savePageData(case 24): incoming vb_gram identical to DB — skipping write');

            // Mirror DB rows into provider state for immediate preview
            try {
              final newData = Map<String, dynamic>.from(state.surveyData);
              newData['vb_gram'] = existingVb.isNotEmpty ? existingVb.first : {};
              newData['vb_gram_members'] = existingMembers;
              state = state.copyWith(surveyData: newData);
            } catch (e) {
              print('Warning: failed to mirror existing vb_gram into provider state: $e');
            }

            break;
          }
        } catch (e) {
          print('Warning: failed to perform vb_gram idempotency check: $e');
        }

        // Not identical (or incoming is null) — replace tables and write new rows
        await _replaceTable('vb_gram');
        await _replaceTable('vb_gram_members');

        if (incoming != null) {
          await _databaseService.saveData('vb_gram', {
            'phone_number': state.phoneNumber,
            'is_member': incoming['is_beneficiary'],
            'total_members': incomingMembers.length,
            'created_at': DateTime.now().toIso8601String(),
          });

          for (final member in incomingMembers) {
            await _databaseService.saveData('vb_gram_members', {
              'phone_number': state.phoneNumber,
              'sr_no': member['sr_no'],
              'member_name': member['name'],
              'name_included': member['name_included'],
              'details_correct': member['details_correct'],
              'incorrect_details': member['incorrect_details'],
              'received': member['received'],
              'days': member['days'],
              'created_at': DateTime.now().toIso8601String(),
            });
          }

          // Mirror saved values into provider state so preview shows them immediately
          try {
            final newData = Map<String, dynamic>.from(state.surveyData);
            newData['vb_gram'] = {
              'is_member': incoming['is_beneficiary'],
              'total_members': incomingMembers.length,
            };
            newData['vb_gram_members'] = incomingMembers.map((m) => {
              'sr_no': m['sr_no'],
              'member_name': m['name'],
              'name_included': m['name_included'],
              'details_correct': m['details_correct'],
              'incorrect_details': m['incorrect_details'],
              'received': m['received'],
              'days': m['days'],
            }).toList();
            state = state.copyWith(surveyData: newData);
          } catch (e) {
            print('Warning: failed to mirror vb_gram into provider state: $e');
          }
        }

        break;
      case 25: // PM Kisan beneficiaries
        final incoming = data['pm_kisan_nidhi'] != null ? Map<String, dynamic>.from(data['pm_kisan_nidhi']) : null;
        final incomingMembers = incoming != null ? List<Map<String, dynamic>>.from(incoming['members'] ?? []) : <Map<String, dynamic>>[];

        // Prepare normalized DB row
        final pmRow = incoming == null
            ? {}
            : {
                'phone_number': state.phoneNumber,
                'is_beneficiary': incoming['is_beneficiary'],
                'total_members': incomingMembers.length,
                'created_at': DateTime.now().toIso8601String(),
              }..removeWhere((k, v) => v == null);

        // Idempotency: compare with existing DB rows and skip if identical
        try {
          final existingPm = await _databaseService.getData('pm_kisan_nidhi', state.phoneNumber!);
          final existingMembers = await _databaseService.getData('pm_kisan_members', state.phoneNumber!);

          bool identical = false;
          if (incoming != null && existingPm.isNotEmpty) {
            final e = Map<String, dynamic>.from(existingPm.first);
            if ((e['is_beneficiary'] == pmRow['is_beneficiary']) && (e['total_members'] == pmRow['total_members'])) {
              final cmpIncoming = incomingMembers.map((m) => jsonEncode({
                    'sr_no': m['sr_no'],
                    'member_name': m['name'],
                    'account_number': m['account_number'],
                    'benefits_received': m['received'],
                    'details_correct': m['details_correct'],
                    'incorrect_details': m['incorrect_details'],
                    'days': m['days'],
                  })).toList()
                ..sort();
              final cmpExisting = existingMembers.map((m) => jsonEncode({
                    'sr_no': m['sr_no'],
                    'member_name': m['member_name'],
                    'account_number': m['account_number'],
                    'benefits_received': m['benefits_received'],
                    'details_correct': m['details_correct'],
                    'incorrect_details': m['incorrect_details'],
                    'days': m['days'],
                  })).toList()
                ..sort();

              identical = listEquals(cmpIncoming, cmpExisting);
            }
          }

          if (identical) {
            print('⚠️ _savePageData(case 25): incoming pm_kisan_nidhi identical to DB — skipping write');

            // Mirror existing DB rows into provider state for immediate preview
            try {
              final newData = Map<String, dynamic>.from(state.surveyData);
              newData['pm_kisan_nidhi'] = existingPm.isNotEmpty ? existingPm.first : {};
              newData['pm_kisan_members'] = existingMembers;
              state = state.copyWith(surveyData: newData);
            } catch (e) {
              print('Warning: failed to mirror existing pm_kisan into provider state: $e');
            }

            break;
          }
        } catch (e) {
          print('Warning: failed pm_kisan idempotency check: $e');
        }

        // Not identical — replace and write
        await _replaceTable('pm_kisan_nidhi');
        await _replaceTable('pm_kisan_members');

        if (incoming != null) {
          await _databaseService.saveData('pm_kisan_nidhi', {
            'phone_number': state.phoneNumber,
            'is_beneficiary': incoming['is_beneficiary'],
            'total_members': incomingMembers.length,
            'created_at': DateTime.now().toIso8601String(),
          });

          for (final member in incomingMembers) {
            await _databaseService.saveData('pm_kisan_members', {
              'phone_number': state.phoneNumber,
              'sr_no': member['sr_no'],
              'member_name': member['name'],
              'account_number': member['account_number'],
              'benefits_received': member['received'],
              'details_correct': member['details_correct'],
              'incorrect_details': member['incorrect_details'],
              'received': member['received'],
              'days': member['days'],
              'created_at': DateTime.now().toIso8601String(),
            });
          }

          // Mirror saved values into provider state so preview shows them immediately
          try {
            final newData = Map<String, dynamic>.from(state.surveyData);
            newData['pm_kisan_nidhi'] = {
              'is_beneficiary': incoming['is_beneficiary'],
              'total_members': incomingMembers.length,
            };
            newData['pm_kisan_members'] = incomingMembers.map((m) => {
              'sr_no': m['sr_no'],
              'member_name': m['name'],
              'account_number': m['account_number'],
              'benefits_received': m['received'],
              'details_correct': m['details_correct'],
              'incorrect_details': m['incorrect_details'],
              'days': m['days'],
            }).toList();
            state = state.copyWith(surveyData: newData);
          } catch (e) {
            print('Warning: failed to mirror pm_kisan into provider state: $e');
          }
        }

        break;
      case 26: // PM Kisan Samman Nidhi
        final incoming = data['pm_kisan_samman_nidhi'] != null ? Map<String, dynamic>.from(data['pm_kisan_samman_nidhi']) : null;
        final incomingMembers = incoming != null ? List<Map<String, dynamic>>.from(incoming['members'] ?? []) : <Map<String, dynamic>>[];

        // Build normalized PM Samman row
        final pmRow = incoming == null
            ? {}
            : {
                'phone_number': state.phoneNumber,
                'is_beneficiary': incoming['is_beneficiary'],
                'total_members': incomingMembers.length,
                'created_at': DateTime.now().toIso8601String(),
              }..removeWhere((k, v) => v == null);

        // Idempotency: compare with DB and skip identical writes
        try {
          final existingPm = await _databaseService.getData('pm_kisan_samman_nidhi', state.phoneNumber!);
          final existingMembers = await _databaseService.getData('pm_kisan_samman_members', state.phoneNumber!);

          bool identical = false;
          if (incoming != null && existingPm.isNotEmpty) {
            final e = Map<String, dynamic>.from(existingPm.first);
            if ((e['is_beneficiary'] == pmRow['is_beneficiary']) && (e['total_members'] == pmRow['total_members'])) {
              final cmpIncoming = incomingMembers.map((m) => jsonEncode({
                    'sr_no': m['sr_no'],
                    'member_name': m['name'],
                    'account_number': m['account_number'],
                    'benefits_received': m['received'],
                    'details_correct': m['details_correct'],
                    'incorrect_details': m['incorrect_details'],
                    'days': m['days'],
                  })).toList()
                ..sort();
              final cmpExisting = existingMembers.map((m) => jsonEncode({
                    'sr_no': m['sr_no'],
                    'member_name': m['member_name'],
                    'account_number': m['account_number'],
                    'benefits_received': m['benefits_received'],
                    'details_correct': m['details_correct'],
                    'incorrect_details': m['incorrect_details'],
                    'days': m['days'],
                  })).toList()
                ..sort();

              identical = listEquals(cmpIncoming, cmpExisting);
            }
          }

          if (identical) {
            print('⚠️ _savePageData(case 26): incoming pm_kisan_samman_nidhi identical to DB — skipping write');

            // Mirror DB into provider state for immediate preview
            try {
              final newData = Map<String, dynamic>.from(state.surveyData);
              newData['pm_kisan_samman_nidhi'] = existingPm.isNotEmpty ? existingPm.first : {};
              newData['pm_kisan_samman_members'] = existingMembers;
              state = state.copyWith(surveyData: newData);
            } catch (e) {
              print('Warning: failed to mirror existing pm_kisan_samman into provider state: $e');
            }

            break;
          }
        } catch (e) {
          print('Warning: failed pm_kisan_samman idempotency check: $e');
        }

        // Replace tables and write incoming values
        await _replaceTable('pm_kisan_samman_nidhi');
        await _replaceTable('pm_kisan_samman_members');

        if (incoming != null) {
          await _databaseService.saveData('pm_kisan_samman_nidhi', {
            'phone_number': state.phoneNumber,
            'is_beneficiary': incoming['is_beneficiary'],
            'total_members': incomingMembers.length,
            'created_at': DateTime.now().toIso8601String(),
          });

          for (final member in incomingMembers) {
            await _databaseService.saveData('pm_kisan_samman_members', {
              'phone_number': state.phoneNumber,
              'sr_no': member['sr_no'],
              'member_name': member['name'],
              'account_number': member['account_number'],
              'benefits_received': member['received'],
              'name_included': member['name_included'],
              'details_correct': member['details_correct'],
              'incorrect_details': member['incorrect_details'],
              'received': member['received'],
              'days': member['days'],
              'created_at': DateTime.now().toIso8601String(),
            });
          }

          // Mirror saved values into provider state so preview shows them immediately
          try {
            final newData = Map<String, dynamic>.from(state.surveyData);
            newData['pm_kisan_samman_nidhi'] = {
              'is_beneficiary': incoming['is_beneficiary'],
              'total_members': incomingMembers.length,
            };
            newData['pm_kisan_samman_members'] = incomingMembers.map((m) => {
              'sr_no': m['sr_no'],
              'member_name': m['name'],
              'account_number': m['account_number'],
              'benefits_received': m['received'],
              'details_correct': m['details_correct'],
              'incorrect_details': m['incorrect_details'],
              'days': m['days'],
            }).toList();
            state = state.copyWith(surveyData: newData);
          } catch (e) {
            print('Warning: failed to mirror pm_kisan_samman into provider state: $e');
          }
        }

        break;
      case 27: // Kisan Credit Card
        if (data['kisan_credit_card'] != null) {
          final incoming = Map<String, dynamic>.from(data['kisan_credit_card']);

          // Idempotency: compare with existing merged-scheme value and skip identical writes
          try {
            final existing = await _getMergedSchemeByKey(state.phoneNumber!, 'kisan_credit_card');
            if (existing.isNotEmpty && mapEquals(existing, incoming)) {
              print('⚠️ _savePageData(case 27): incoming kisan_credit_card identical to existing merged scheme — skipping write');

              // Mirror existing merged scheme into provider state so preview shows it immediately
              final newData = Map<String, dynamic>.from(state.surveyData);
              newData['kisan_credit_card'] = existing;
              state = state.copyWith(surveyData: newData);
              break;
            }
          } catch (e) {
            print('Warning: failed to compare existing kisan_credit_card merged scheme: $e');
          }

          // Write merged scheme and mirror into provider state
          await _upsertMergedScheme(state.phoneNumber!, 'kisan_credit_card', incoming);
          try {
            final newData = Map<String, dynamic>.from(state.surveyData);
            newData['kisan_credit_card'] = incoming;
            state = state.copyWith(surveyData: newData);
          } catch (e) {
            print('Warning: failed to mirror kisan_credit_card into provider state: $e');
          }
        }
        break;
      case 28: // Swachh Bharat
        if (data['swachh_bharat'] != null) {
          final incoming = Map<String, dynamic>.from(data['swachh_bharat']);

          // Idempotency: compare with existing merged-scheme and skip if identical
          try {
            final existing = await _getMergedSchemeByKey(state.phoneNumber!, 'swachh_bharat');
            if (existing.isNotEmpty && mapEquals(existing, incoming)) {
              print('⚠️ _savePageData(case 28): incoming swachh_bharat identical to existing merged scheme — skipping write');

              // Mirror existing merged scheme into provider state for immediate preview
              try {
                final newData = Map<String, dynamic>.from(state.surveyData);
                newData['swachh_bharat'] = existing;
                state = state.copyWith(surveyData: newData);
              } catch (e) {
                print('Warning: failed to mirror existing swachh_bharat into provider state: $e');
              }

              break;
            }
          } catch (e) {
            print('Warning: failed to compare existing swachh_bharat merged scheme: $e');
          }

          // Write merged scheme and mirror into provider state
          await _upsertMergedScheme(state.phoneNumber!, 'swachh_bharat', incoming);
          try {
            final newData = Map<String, dynamic>.from(state.surveyData);
            newData['swachh_bharat'] = incoming;
            state = state.copyWith(surveyData: newData);
          } catch (e) {
            print('Warning: failed to mirror swachh_bharat into provider state: $e');
          }
        }
        break;
      case 29: // Fasal Bima
        if (data['fasal_bima'] != null) {
          final incoming = Map<String, dynamic>.from(data['fasal_bima']);

          // Idempotency: compare with existing merged-scheme and skip if identical
          try {
            final existing = await _getMergedSchemeByKey(state.phoneNumber!, 'fasal_bima');
            if (existing.isNotEmpty && mapEquals(existing, incoming)) {
              print('⚠️ _savePageData(case 29): incoming fasal_bima identical to existing merged scheme — skipping write');

              // Mirror existing merged scheme into provider state for immediate preview
              try {
                final newData = Map<String, dynamic>.from(state.surveyData);
                newData['fasal_bima'] = existing;
                state = state.copyWith(surveyData: newData);
              } catch (e) {
                print('Warning: failed to mirror existing fasal_bima into provider state: $e');
              }

              break;
            }
          } catch (e) {
            print('Warning: failed to compare existing fasal_bima merged scheme: $e');
          }

          // Write merged scheme and mirror into provider state
          await _upsertMergedScheme(state.phoneNumber!, 'fasal_bima', incoming);
          try {
            final newData = Map<String, dynamic>.from(state.surveyData);
            newData['fasal_bima'] = incoming;
            state = state.copyWith(surveyData: newData);
          } catch (e) {
            print('Warning: failed to mirror fasal_bima into provider state: $e');
          }
        }
        break;
      case 30: // Bank accounts
        // Build normalized list of account rows from either `bank_accounts` or `members`.
        final accounts = <Map<String, dynamic>>[];
        if (data['bank_accounts'] != null) {
          for (final account in data['bank_accounts']) {
            accounts.add(Map<String, dynamic>.from(account));
          }
        } else if (data['members'] != null) {
          for (final member in data['members']) {
            final memberName = member['name']?.toString() ?? '';
            final bankList = member['bank_accounts'] ?? [];
            for (final account in bankList) {
              accounts.add({
                'member_name': memberName,
                'bank_name': account['bank_name'],
                'account_number': account['account_number'],
                'ifsc_code': account['ifsc_code'],
                'branch_name': account['branch_name'],
                'account_type': account['account_type'],
                'has_account': account['has_account'],
                'details_correct': account['details_correct'],
                'incorrect_details': account['incorrect_details'],
              });
            }
          }
        }

        // Helper to create a stable signature for comparison
        String _sortedJson(List<Map<String, dynamic>> list) {
          final jsonList = list.map((m) => jsonEncode(m)).toList()..sort();
          return jsonEncode(jsonList);
        }

        try {
          final existing = await _databaseService.getData('bank_accounts', state.phoneNumber!);
          final existingNormalized = existing.map((e) => {
            'member_name': e['member_name'],
            'bank_name': e['bank_name'],
            'account_number': e['account_number'],
            'ifsc_code': e['ifsc_code'],
            'branch_name': e['branch_name'],
            'account_type': e['account_type'],
            'has_account': e['has_account'],
            'details_correct': e['details_correct'],
            'incorrect_details': e['incorrect_details'],
          }).toList();

          if (accounts.isNotEmpty && _sortedJson(accounts) == _sortedJson(existingNormalized)) {
            print('⚠️ _savePageData(case 30): incoming bank_accounts identical to DB — skipping write');

            // Mirror existing DB rows into provider state so Preview shows data immediately
            final membersMap = <String, List<Map<String, dynamic>>>{};
            for (final row in existing) {
              final memberName = row['member_name']?.toString() ?? '';
              membersMap.putIfAbsent(memberName, () => []);
              membersMap[memberName]!.add({
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

            final membersList = membersMap.entries.map((entry) {
              return {
                'name': entry.key,
                'bank_accounts': entry.value,
              };
            }).toList();

            try {
              final newData = Map<String, dynamic>.from(state.surveyData);
              newData['members'] = membersList;
              state = state.copyWith(surveyData: newData);
            } catch (e) {
              print('Warning: failed to mirror existing bank_accounts into provider state: $e');
            }

            break;
          }
        } catch (e) {
          print('Warning: failed to compare existing bank_accounts: $e');
        }

        // Replace table and write new rows
        await _replaceTable('bank_accounts');
        int srNo = 0;
        for (final account in accounts) {
          srNo++;
          await _databaseService.saveData('bank_accounts', {
            'phone_number': state.phoneNumber,
            'sr_no': account['sr_no'] ?? srNo,
            'member_name': account['member_name'],
            'bank_name': account['bank_name'],
            'account_number': account['account_number'],
            'ifsc_code': account['ifsc_code'],
            'branch_name': account['branch_name'],
            'account_type': account['account_type'],
            'has_account': account['has_account'],
            'details_correct': account['details_correct'],
            'incorrect_details': account['incorrect_details'],
          });
        }

        // Mirror saved rows into provider state for immediate preview
        try {
          final membersMap = <String, List<Map<String, dynamic>>>{};
          for (final account in accounts) {
            final memberName = account['member_name']?.toString() ?? '';
            membersMap.putIfAbsent(memberName, () => []);
            membersMap[memberName]!.add({
              'bank_name': account['bank_name'],
              'account_number': account['account_number'],
              'ifsc_code': account['ifsc_code'],
              'branch_name': account['branch_name'],
              'account_type': account['account_type'],
              'has_account': account['has_account'],
              'details_correct': account['details_correct'],
              'incorrect_details': account['incorrect_details'],
            });
          }

          final membersList = membersMap.entries.map((entry) {
            return {
              'name': entry.key,
              'bank_accounts': entry.value,
            };
          }).toList();

          final newData = Map<String, dynamic>.from(state.surveyData);
          newData['members'] = membersList;
          state = state.copyWith(surveyData: newData);
        } catch (e) {
          print('Warning: failed to mirror bank_accounts into provider state: $e');
        }

        print('💾 _savePageData(case 30): wrote ${accounts.length} bank account rows for phone=${state.phoneNumber}');
        break;
      }
    }
  }


  Map<String, dynamic> _decodeMergedSchemeData(Map<String, dynamic> row) {
    final raw = row['scheme_data'];
    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  Future<Map<String, dynamic>> _getMergedSchemeByKey(String phoneNumber, String schemeKey) async {
    final merged = await _databaseService.getData('merged_govt_schemes', phoneNumber);
    if (merged.isEmpty) return {};
    final decoded = _decodeMergedSchemeData(merged.first);
    final value = decoded[schemeKey];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }

  Future<void> _upsertMergedScheme(String phoneNumber, String schemeKey, Map<String, dynamic> schemeData) async {
    final merged = await _databaseService.getData('merged_govt_schemes', phoneNumber);
    final decoded = merged.isNotEmpty ? _decodeMergedSchemeData(merged.first) : <String, dynamic>{};
    decoded[schemeKey] = schemeData;
    await _databaseService.saveData('merged_govt_schemes', {
      'phone_number': phoneNumber,
      'scheme_data': jsonEncode(decoded),
    });
  }

  Future<void> nextPage() async {
    if (state.currentPage < state.totalPages - 1) {
      // Save current page data before moving to next (non-blocking)
      saveCurrentPageData();
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

  Future<void> jumpToPage(int page) async {
    if (page >= 0 && page < state.totalPages) {
      // Save current page data before jumping (non-blocking)
      saveCurrentPageData();
      // Update the survey session timestamp
      if (state.phoneNumber != null) {
        await _databaseService.saveData('survey_sessions', {
          'phone_number': state.phoneNumber,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      state = state.copyWith(currentPage: page);
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
    print('📝 updateSurveyDataMap: Updating survey data with ${data.keys.length} keys');
    final newData = Map<String, dynamic>.from(state.surveyData);

    // Only merge meaningful values to avoid polluting state with empty placeholders.
    data.forEach((k, v) {
      if (v == null) return; // skip nulls
      if (v is String && v.trim().isEmpty) return; // skip empty strings
      if (v is Iterable && v.isEmpty) return; // skip empty lists/sets
      if (v is Map && v.isEmpty) return; // skip empty maps
      newData[k] = v;
    });

    state = state.copyWith(surveyData: newData);
    print('✅ updateSurveyDataMap: Survey data now has ${state.surveyData.keys.length} keys');
  }

  Future<void> savePageData(int page, Map<String, dynamic> data) async {
    await _savePageData(page, data);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void syncPartialSurvey() {
    if (state.phoneNumber != null) {
      // Start background sync (non-blocking)
      try {
        _familySyncService.savePageData(
          phoneNumber: state.phoneNumber!,
          page: state.currentPage,
          pageData: state.surveyData,
        );
      } catch (e) {
        print('Error syncing partial survey: $e');
      }
    }
  }

  Future<void> completeSurvey() async {
    if (state.phoneNumber != null) {
      await saveCurrentPageData();
      await _databaseService.updateSurveyStatus(state.phoneNumber!, 'completed');

      // Sync complete survey to Supabase if online
      if (await _supabaseService.isOnline()) {
        try {
          // Update status in Supabase
          await _supabaseService.client
              .from('family_survey_sessions')
              .update({
                'status': 'completed',
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('phone_number', state.phoneNumber!);

          // Immediately trigger full sync of the survey to Supabase
          await _syncService.syncSurveyImmediately(state.phoneNumber!);
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

  Future<void> loadSurveySessionForContinuation(String sessionId, {int startPage = 0}) async {
    try {
      setLoading(true);

      // Load session data
      final sessionData = await _databaseService.getSurveySession(sessionId);
      if (sessionData != null) {
        state = state.copyWith(phoneNumber: sessionId);

        // Load all survey data for this session
        await _loadAllSurveyData();

        // For continuation, start from requested page with existing data loaded
        state = state.copyWith(currentPage: startPage);
      }
    } catch (e) {
      print('Error loading survey session for continuation: $e');
    } finally {
      setLoading(false);
    }
  }



  /// Update existing surveys with correct surveyor email after authentication
  Future<void> updateExistingSurveyEmails() async {
    try {
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null || currentUser.email == null) {
        print('No authenticated user found for email update');
        return;
      }

      final userEmail = currentUser.email!;
      print('Updating existing surveys with email: $userEmail');

      // Get all surveys that have 'unknown' or null surveyor_email
      final db = await _databaseService.database;
      final surveysToUpdate = await db.query(
        'family_survey_sessions',
        where: 'surveyor_email IS NULL OR surveyor_email = ?',
        whereArgs: ['unknown'],
      );

      print('Found ${surveysToUpdate.length} surveys to update');

      for (final survey in surveysToUpdate) {
        final phoneNumber = survey['phone_number'] as String?;
        if (phoneNumber != null) {
          await db.update(
            'family_survey_sessions',
            {
              'surveyor_email': userEmail,
              'updated_at': DateTime.now().toIso8601String(),
            },
            where: 'phone_number = ?',
            whereArgs: [phoneNumber],
          );
          print('Updated survey $phoneNumber with email $userEmail');
        }
      }

      // Now try to sync any surveys that were previously blocked due to auth issues
      if (await _supabaseService.isOnline()) {
        for (final survey in surveysToUpdate) {
          final phoneNumber = survey['phone_number'] as String?;
          if (phoneNumber != null) {
            try {
              await _syncService.syncSurveyImmediately(phoneNumber);
              print('Successfully synced updated survey: $phoneNumber');
            } catch (e) {
              print('Failed to sync survey $phoneNumber: $e');
            }
          }
        }
      }

    } catch (e) {
      print('Error updating existing survey emails: $e');
    }
  }

  void reset() {
    state = const SurveyState(
      currentPage: 0,
      totalPages: 32, // Pages indexed 0-31 in survey_page.dart
      surveyData: {},
      isLoading: false,
    );
  }
}

final surveyProvider = NotifierProvider<SurveyNotifier, SurveyState>(() {
  return SurveyNotifier();
});
