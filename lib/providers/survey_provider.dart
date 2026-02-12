import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dri_survey/services/database_service.dart';
import 'package:dri_survey/services/supabase_service.dart';
import 'package:dri_survey/services/sync_service.dart';
import 'package:dri_survey/services/family_sync_service.dart';
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
  final FamilySyncService _familySyncService = FamilySyncService.instance;
  final FormHistoryService _historyService = FormHistoryService();

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

    try {
      print('💾 saveCurrentPageData: Saving page ${state.currentPage} for phone ${state.phoneNumber}');
      print('📊 Survey data keys: ${state.surveyData.keys.toList()}');

      // Save data based on current page locally first (immediate)
      await _savePageData(state.currentPage, state.surveyData);

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
        case 25: // Social consciousness (later page)
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
            data['crop_productivity'] = cropData.map((row) {
              return {
                'id': row['sr_no'] ?? row['id'],
                'season': row['season'],
                'name': row['crop_name'],
                'area': row['area_hectares'],
                'productivity': row['productivity_quintal_per_hectare'],
                'total_production': row['total_production_quintal'],
                'sold': row['quantity_sold_quintal'],
              };
            }).toList();
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
              'toilet_in_use': conditions['toilet_in_use'],
              'toilet_condition': conditions['toilet_condition'],
            });
          }

          // Load house facilities data (toilet, drainage, etc.)
          final houseFacilitiesData = await _databaseService.getData('house_facilities', state.phoneNumber!);
          if (houseFacilitiesData.isNotEmpty) {
            final facilities = houseFacilitiesData.first;
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
          }

          final tulsiData = await _databaseService.getData('tulsi_plants', state.phoneNumber!);
          if (tulsiData.isNotEmpty) {
            data['tulsi_plant_count'] = tulsiData.first['plant_count'];
          }

          final nutritionData = await _databaseService.getData('nutritional_garden', state.phoneNumber!);
          if (nutritionData.isNotEmpty) {
            data['nutritional_garden_size'] = nutritionData.first['garden_size'];
            data['nutritional_garden_vegetables'] = nutritionData.first['vegetables_grown'];
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
            data.addAll(healthProgrammeData.first);
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

          final malnutritionData = await _databaseService.getData('malnutrition_data', state.phoneNumber!);
          if (malnutritionData.isNotEmpty) {
            data['malnutrition_data'] = malnutritionData;
          }
          break;
        case 22: // Migration
          final migration = await _databaseService.getData('migration_data', state.phoneNumber!);
          if (migration.isNotEmpty) {
            final row = migration.first;
            data.addAll(row);
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
        await _replaceTable('irrigation_facilities');
        await _databaseService.saveData('irrigation_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 7: // Crop Productivity
        await _replaceTable('crop_productivity');
        final cropList = data['crop_productivity'] ?? data['crops'];
        if (cropList != null) {
          int srNo = 0;
          for (final crop in cropList) {
            srNo++;
            await _databaseService.saveData('crop_productivity', {
              'phone_number': state.phoneNumber,
              'sr_no': crop['sr_no'] ?? crop['id'] ?? srNo,
              'season': crop['season'],
              'crop_name': crop['crop_name'] ?? crop['name'],
              'area_hectares': crop['area_hectares'] ?? crop['area'],
              'productivity_quintal_per_hectare': crop['productivity_quintal_per_hectare'] ?? crop['productivity'],
              'total_production_quintal': crop['total_production_quintal'] ?? crop['total_production'],
              'quantity_consumed_quintal': crop['quantity_consumed_quintal'] ?? crop['consumed'],
              'quantity_sold_quintal': crop['quantity_sold_quintal'] ?? crop['sold'],
            });
          }
        }
        break;
      case 8: // Fertilizer Usage
        await _replaceTable('fertilizer_usage');
        await _databaseService.saveData('fertilizer_usage', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 9: // Animals
        await _replaceTable('animals');
        if (data['animals'] != null) {
          int srNo = 0;
          for (final animal in data['animals']) {
            srNo++;
            await _databaseService.saveData('animals', {
              'phone_number': state.phoneNumber,
              'sr_no': animal['sr_no'] ?? srNo,
              'animal_type': animal['animal_type'],
              'number_of_animals': animal['number_of_animals'],
              'breed': animal['breed'],
              'production_per_animal': animal['production_per_animal'],
              'quantity_sold': animal['quantity_sold'],
            });
          }
        }
        break;
      case 10: // Agricultural Equipment
        await _replaceTable('agricultural_equipment');
        await _databaseService.saveData('agricultural_equipment', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 11: // Entertainment Facilities
        await _replaceTable('entertainment_facilities');
        await _databaseService.saveData('entertainment_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 12: // Transport Facilities
        await _replaceTable('transport_facilities');
        await _databaseService.saveData('transport_facilities', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 13: // Water Sources
        await _replaceTable('drinking_water_sources');
        await _databaseService.saveData('drinking_water_sources', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 14: // Medical Treatment
        await _replaceTable('medical_treatment');
        await _databaseService.saveData('medical_treatment', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 15: // Disputes
        await _replaceTable('disputes');
        await _databaseService.saveData('disputes', {
          'phone_number': state.phoneNumber,
          ...data,
        });
        break;
      case 16: // House Conditions
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

        break;
      case 17: // Diseases
        await _replaceTable('diseases');
        final diseaseList = data['diseases'] ?? data['members'];
        if (diseaseList != null) {
          int srNo = 0;
          for (final disease in diseaseList) {
            srNo++;
            await _databaseService.saveData('diseases', {
              'phone_number': state.phoneNumber,
              'sr_no': disease['sr_no'] ?? srNo,
              'family_member_name': disease['family_member_name'] ?? disease['name'],
              'disease_name': disease['disease_name'],
              'suffering_since': disease['suffering_since'],
              'treatment_taken': disease['treatment_taken'],
              'treatment_from_when': disease['treatment_from_when'],
              'treatment_from_where': disease['treatment_from_where'],
              'treatment_taken_from': disease['treatment_taken_from'],
            });
          }
        }
        break;
      case 18: // Government schemes
        await _replaceTable('aadhaar_scheme_members');
        await _replaceTable('aadhaar_info');
        await _replaceTable('ayushman_scheme_members');
        await _replaceTable('ayushman_card');
        await _replaceTable('ration_scheme_members');
        await _replaceTable('ration_card');
        await _replaceTable('family_id_scheme_members');
        await _replaceTable('family_id');
        await _replaceTable('samagra_scheme_members');
        await _replaceTable('samagra_id');
        await _replaceTable('handicapped_scheme_members');
        await _replaceTable('handicapped_allowance');
        await _replaceTable('tribal_scheme_members');
        await _replaceTable('tribal_card');
        await _replaceTable('pension_scheme_members');
        await _replaceTable('pension_allowance');
        await _replaceTable('widow_scheme_members');
        await _replaceTable('widow_allowance');
        await _replaceTable('vb_gram');
        await _replaceTable('vb_gram_members');
        await _replaceTable('pm_kisan_nidhi');
        await _replaceTable('pm_kisan_members');
        await _replaceTable('pm_kisan_samman_nidhi');
        await _replaceTable('pm_kisan_samman_members');
        if (data['aadhaar_scheme_members'] != null) {
          for (final member in data['aadhaar_scheme_members']) {
            await _databaseService.saveData('aadhaar_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['aadhaar_info'] != null) {
          await _databaseService.saveData('aadhaar_info', {
            'phone_number': state.phoneNumber,
            ...data['aadhaar_info'],
          });
        }

        if (data['ayushman_scheme_members'] != null) {
          for (final member in data['ayushman_scheme_members']) {
            await _databaseService.saveData('ayushman_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['ayushman_card'] != null) {
          await _databaseService.saveData('ayushman_card', {
            'phone_number': state.phoneNumber,
            ...data['ayushman_card'],
          });
        }

        if (data['ration_scheme_members'] != null) {
          for (final member in data['ration_scheme_members']) {
            await _databaseService.saveData('ration_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['ration_card'] != null) {
          await _databaseService.saveData('ration_card', {
            'phone_number': state.phoneNumber,
            ...data['ration_card'],
          });
        }

        if (data['family_id_scheme_members'] != null) {
          for (final member in data['family_id_scheme_members']) {
            await _databaseService.saveData('family_id_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['family_id'] != null) {
          await _databaseService.saveData('family_id', {
            'phone_number': state.phoneNumber,
            ...data['family_id'],
          });
        }

        if (data['samagra_scheme_members'] != null) {
          for (final member in data['samagra_scheme_members']) {
            await _databaseService.saveData('samagra_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['samagra_id'] != null) {
          await _databaseService.saveData('samagra_id', {
            'phone_number': state.phoneNumber,
            ...data['samagra_id'],
          });
        }

        if (data['handicapped_scheme_members'] != null) {
          for (final member in data['handicapped_scheme_members']) {
            await _databaseService.saveData('handicapped_scheme_members', {
              'phone_number': state.phoneNumber,
              ...member,
            });
          }
        }

        if (data['handicapped_allowance'] != null) {
          await _databaseService.saveData('handicapped_allowance', {
            'phone_number': state.phoneNumber,
            ...data['handicapped_allowance'],
          });
        }

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

        break;
      case 19: // Folklore Medicine
        await _replaceTable('folklore_medicine');
        if (data['folklore_medicines'] != null) {
          for (final medicine in data['folklore_medicines']) {
            await _databaseService.saveData('folklore_medicine', {
              'phone_number': state.phoneNumber,
              ...medicine,
            });
          }
        }
        break;
      case 20: // Health Programme Implemented
        await _replaceTable('health_programmes');
        await _databaseService.saveData('health_programmes', {
          'phone_number': state.phoneNumber,
          'vaccination_pregnancy': data['vaccination_pregnancy'],
          'child_vaccination': data['child_vaccination'],
          'vaccination_schedule': data['vaccination_schedule'],
          'balance_doses_schedule': data['balance_doses_schedule'],
          'family_planning_awareness': data['family_planning_awareness'],
          'contraceptive_applied': data['contraceptive_applied'],
        });
        break;
      case 21: // Children data
        await _replaceTable('children_data');
        await _replaceTable('malnourished_children_data');
        await _replaceTable('malnutrition_data');
        await _replaceTable('child_diseases');
        // Save basic children data
        await _databaseService.saveData('children_data', {
          'phone_number': state.phoneNumber,
          'births_last_3_years': data['births_last_3_years'],
          'infant_deaths_last_3_years': data['infant_deaths_last_3_years'],
          'malnourished_children': data['malnourished_children'],
        });

        // Save malnourished children data
        final childDiseases = <Map<String, dynamic>>[];
        final malnutritionRows = <Map<String, dynamic>>[];
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

            final malnutritionRow = {
              'phone_number': state.phoneNumber,
              'child_name': childData['child_name'],
              'age': childData['age'],
              'weight': childData['weight'],
              'height': childData['height'],
            };
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
                };
                childDiseases.add(diseaseRow);
                await _databaseService.saveData('child_diseases', diseaseRow);
              }
            }
          }
        }
        break;
      case 22: // Migration
        await _replaceTable('migration_data');
        final migratedMembers = List<Map<String, dynamic>>.from(data['migrated_members'] ?? []);
        await _databaseService.saveData('migration_data', {
          'phone_number': state.phoneNumber,
          'family_members_migrated': data['no_migration'] == true ? 0 : migratedMembers.length,
          'no_migration': data['no_migration'] == true ? 1 : 0,
          'reason': data['reason'],
          'duration': data['duration'],
          'destination': data['destination'],
          'migrated_members_json': jsonEncode(migratedMembers),
        });
        break;
      case 23: // Training
        await _replaceTable('training_data');
        await _replaceTable('shg_members');
        await _replaceTable('fpo_members');
        if (data['training_members'] != null) {
          for (final training in data['training_members']) {
            final mapped = {
              'member_name': training['member_name'],
              'training_topic': training['training_topic'] ?? training['training_type'],
              'training_duration': training['training_duration'],
              'training_date': training['training_date'] ?? training['pass_out_year'],
              'status': training['status'],
            };
            await _databaseService.saveData('training_data', {
              'phone_number': state.phoneNumber,
              ...mapped,
            });
          }
        }
        if (data['shg_members'] != null) {
          for (final shg in data['shg_members']) {
            await _databaseService.saveData('shg_members', {
              'phone_number': state.phoneNumber,
              'member_name': shg['member_name'],
              'shg_name': shg['shg_name'],
              'purpose': shg['purpose'],
              'agency': shg['agency'],
              'position': shg['position'],
              'monthly_saving': shg['monthly_saving'],
            });
          }
        }
        if (data['fpo_members'] != null) {
          for (final fpo in data['fpo_members']) {
            await _databaseService.saveData('fpo_members', {
              'phone_number': state.phoneNumber,
              'member_name': fpo['member_name'],
              'fpo_name': fpo['fpo_name'],
              'purpose': fpo['purpose'],
              'agency': fpo['agency'],
              'share_capital': fpo['share_capital'],
            });
          }
        }
        break;
      case 24: // VB Gram beneficiaries
        await _replaceTable('vb_gram');
        await _replaceTable('vb_gram_members');
        if (data['vb_gram'] != null) {
          final vb = Map<String, dynamic>.from(data['vb_gram']);
          final members = List<Map<String, dynamic>>.from(vb['members'] ?? []);
          await _databaseService.saveData('vb_gram', {
            'phone_number': state.phoneNumber,
            'is_member': vb['is_beneficiary'],
            'total_members': members.length,
          });
          for (final member in members) {
            await _databaseService.saveData('vb_gram_members', {
              'phone_number': state.phoneNumber,
              'sr_no': member['sr_no'],
              'member_name': member['name'],
              'name_included': member['name_included'],
              'details_correct': member['details_correct'],
              'incorrect_details': member['incorrect_details'],
              'received': member['received'],
              'days': member['days'],
            });
          }
        }
        break;
      case 25: // PM Kisan beneficiaries
        await _replaceTable('pm_kisan_nidhi');
        await _replaceTable('pm_kisan_members');
        if (data['pm_kisan_nidhi'] != null) {
          final pm = Map<String, dynamic>.from(data['pm_kisan_nidhi']);
          final members = List<Map<String, dynamic>>.from(pm['members'] ?? []);
          await _databaseService.saveData('pm_kisan_nidhi', {
            'phone_number': state.phoneNumber,
            'is_beneficiary': pm['is_beneficiary'],
            'total_members': members.length,
          });
          for (final member in members) {
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
            });
          }
        }
        break;
      case 26: // PM Kisan Samman Nidhi
        await _replaceTable('pm_kisan_samman_nidhi');
        await _replaceTable('pm_kisan_samman_members');
        if (data['pm_kisan_samman_nidhi'] != null) {
          final pmSamman = Map<String, dynamic>.from(data['pm_kisan_samman_nidhi']);
          final members = List<Map<String, dynamic>>.from(pmSamman['members'] ?? []);
          await _databaseService.saveData('pm_kisan_samman_nidhi', {
            'phone_number': state.phoneNumber,
            'is_beneficiary': pmSamman['is_beneficiary'],
            'total_members': members.length,
          });
          for (final member in members) {
            await _databaseService.saveData('pm_kisan_samman_members', {
              'phone_number': state.phoneNumber,
              'sr_no': member['sr_no'],
              'member_name': member['name'],
              'account_number': member['account_number'],
              'benefits_received': member['received'],
              'details_correct': member['details_correct'],
              'incorrect_details': member['incorrect_details'],
              'received': member['received'],
              'days': member['days'],
            });
          }
        }
        break;
      case 27: // Kisan Credit Card
        if (data['kisan_credit_card'] != null) {
          await _upsertMergedScheme(state.phoneNumber!, 'kisan_credit_card', Map<String, dynamic>.from(data['kisan_credit_card']));
        }
        break;
      case 28: // Swachh Bharat
        if (data['swachh_bharat'] != null) {
          await _upsertMergedScheme(state.phoneNumber!, 'swachh_bharat', Map<String, dynamic>.from(data['swachh_bharat']));
        }
        break;
      case 29: // Fasal Bima
        if (data['fasal_bima'] != null) {
          await _upsertMergedScheme(state.phoneNumber!, 'fasal_bima', Map<String, dynamic>.from(data['fasal_bima']));
        }
        break;
      case 30: // Bank accounts
        await _replaceTable('bank_accounts');
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

        int srNo = 0;
        for (final account in accounts) {
          srNo++;
          await _databaseService.saveData('bank_accounts', {
            'phone_number': state.phoneNumber,
            'sr_no': account['sr_no'] ?? srNo,
            'member_name': account['member_name'],
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
        break;
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
    newData.addAll(data);
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
      _familySyncService.savePageData(
        phoneNumber: state.phoneNumber!,
        page: state.currentPage,
        pageData: state.surveyData,
      ).catchError((e) {
        print('Error syncing partial survey: $e');
      });
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
