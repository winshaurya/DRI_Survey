import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static SupabaseService get instance => _instance;

  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    // Supabase is already initialized in main.dart
    // This method is kept for compatibility
    return;
  }

  // Authentication methods
  Future<void> signInWithPhone(String phoneNumber) async {
    await client.auth.signInWithOtp(
      phone: phoneNumber,
    );
  }

  Future<AuthResponse> verifyOTP(String phoneNumber, String otp) async {
    return await client.auth.verifyOTP(
      phone: phoneNumber,
      token: otp,
      type: OtpType.sms,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  // Check if user is online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Sync family survey data to Supabase (legacy method - kept for compatibility)
  Future<void> syncFamilySurveyToSupabase(String phoneNumber, Map<String, dynamic> surveyData) async {
    final trackingMap = <String, bool>{};
    await syncFamilySurveyToSupabaseWithTracking(phoneNumber, surveyData, trackingMap);
  }

  // Sync family survey data to Supabase with error tracking
  Future<bool> syncFamilySurveyToSupabaseWithTracking(
    String phoneNumber, 
    Map<String, dynamic> surveyData,
    Map<String, bool> tableSyncStatus,
  ) async {
    bool overallSuccess = true;

    try {
      // Get current user email for audit trail
      final userEmail = currentUser?.email ?? surveyData['surveyor_email'];

      // Insert main survey session data
      try {
        await client
            .from('family_survey_sessions')
            .upsert({
              'phone_number': phoneNumber,
              'surveyor_email': userEmail,
              'village_name': surveyData['village_name'],
              'village_number': surveyData['village_number'],
              'panchayat': surveyData['panchayat'],
              'block': surveyData['block'],
              'tehsil': surveyData['tehsil'],
              'district': surveyData['district'],
              'postal_address': surveyData['postal_address'],
              'pin_code': surveyData['pin_code'],
              'shine_code': surveyData['shine_code'],
              'latitude': surveyData['latitude'],
              'longitude': surveyData['longitude'],
              'location_accuracy': surveyData['location_accuracy'],
              'location_timestamp': surveyData['location_timestamp'],
              'surveyor_name': surveyData['surveyor_name'],
              'status': surveyData['status'] ?? 'in_progress',
              'created_by': userEmail,
              'updated_by': userEmail,
              'user_id': currentUser?.id,
            });
        tableSyncStatus['family_survey_sessions'] = true;
      } catch (e) {
        tableSyncStatus['family_survey_sessions'] = false;
        overallSuccess = false;
        print('✗ Failed to sync family_survey_sessions: $e');
      }

      // Sync related data tables in parallel for speed
      final syncTasks = <Future<void>>[];
      
      // Helper to wrap sync calls with error tracking
      Future<void> syncWithTracking(String tableName, Future<void> Function() syncFn) async {
        try {
          await syncFn();
          tableSyncStatus[tableName] = true;
        } catch (e) {
          tableSyncStatus[tableName] = false;
          overallSuccess = false;
          print('✗ Failed to sync $tableName: $e');
        }
      }

      // Add all sync tasks (parallel execution)
      syncTasks.add(syncWithTracking('family_members', () => _syncFamilyMembers(phoneNumber, surveyData['family_members'])));
      syncTasks.add(syncWithTracking('land_holding', () => _syncLandHolding(phoneNumber, surveyData['land_holding'])));
      syncTasks.add(syncWithTracking('irrigation_facilities', () => _syncIrrigationFacilities(phoneNumber, surveyData['irrigation_facilities'])));
      syncTasks.add(syncWithTracking('crop_productivity', () => _syncCropProductivity(phoneNumber, surveyData['crop_productivity'])));
      syncTasks.add(syncWithTracking('fertilizer_usage', () => _syncFertilizerUsage(phoneNumber, surveyData['fertilizer_usage'])));
      syncTasks.add(syncWithTracking('animals', () => _syncAnimals(phoneNumber, surveyData['animals'])));
      syncTasks.add(syncWithTracking('agricultural_equipment', () => _syncAgriculturalEquipment(phoneNumber, surveyData['agricultural_equipment'])));
      syncTasks.add(syncWithTracking('entertainment_facilities', () => _syncEntertainmentFacilities(phoneNumber, surveyData['entertainment_facilities'])));
      syncTasks.add(syncWithTracking('transport_facilities', () => _syncTransportFacilities(phoneNumber, surveyData['transport_facilities'])));
      syncTasks.add(syncWithTracking('drinking_water_sources', () => _syncDrinkingWaterSources(phoneNumber, surveyData['drinking_water_sources'])));
      syncTasks.add(syncWithTracking('medical_treatment', () => _syncMedicalTreatment(phoneNumber, surveyData['medical_treatment'])));
      syncTasks.add(syncWithTracking('disputes', () => _syncDisputes(phoneNumber, surveyData['disputes'])));
      syncTasks.add(syncWithTracking('house_conditions', () => _syncHouseConditions(phoneNumber, surveyData['house_conditions'])));
      syncTasks.add(syncWithTracking('house_facilities', () => _syncHouseFacilities(phoneNumber, surveyData['house_facilities'])));
      syncTasks.add(syncWithTracking('diseases', () => _syncDiseases(phoneNumber, surveyData['diseases'])));
      syncTasks.add(syncWithTracking('children_data', () => _syncChildrenData(phoneNumber, surveyData['children_data'])));
      syncTasks.add(syncWithTracking('malnourished_children_data', () => _syncMalnourishedChildrenData(phoneNumber, surveyData['malnourished_children_data'])));
      syncTasks.add(syncWithTracking('child_diseases', () => _syncChildDiseases(phoneNumber, surveyData['child_diseases'])));
      syncTasks.add(syncWithTracking('folklore_medicine', () => _syncFolkloreMedicine(phoneNumber, surveyData['folklore_medicine'])));
      syncTasks.add(syncWithTracking('health_programmes', () => _syncHealthProgrammes(phoneNumber, surveyData['health_programmes'])));
      syncTasks.add(syncWithTracking('malnutrition_data', () => _syncMalnutritionData(phoneNumber, surveyData['malnutrition_data'])));
      syncTasks.add(syncWithTracking('migration_data', () => _syncMigration(phoneNumber, surveyData['migration_data'])));
      syncTasks.add(syncWithTracking('training_data', () => _syncTraining(phoneNumber, surveyData['training_data'])));
      syncTasks.add(syncWithTracking('shg_members', () => _syncSelfHelpGroups(phoneNumber, surveyData['shg_members'])));
      syncTasks.add(syncWithTracking('fpo_members', () => _syncFpoMembership(phoneNumber, surveyData['fpo_members'])));
      syncTasks.add(syncWithTracking('bank_accounts', () => _syncBankAccounts(phoneNumber, surveyData['bank_accounts'])));
      syncTasks.add(syncWithTracking('social_consciousness', () => _syncSocialConsciousness(phoneNumber, surveyData['social_consciousness'])));
      syncTasks.add(syncWithTracking('tribal_questions', () => _syncTribalQuestions(phoneNumber, surveyData['tribal_questions'])));
      syncTasks.add(syncWithTracking('tulsi_plants', () => _syncTulsiPlants(phoneNumber, surveyData['house_facilities'])));
      syncTasks.add(syncWithTracking('nutritional_garden', () => _syncNutritionalGarden(phoneNumber, surveyData['house_facilities'])));

      // Sync government schemes (tracked separately)
      syncTasks.add(syncWithTracking('government_schemes', () => _syncGovernmentSchemesParallel(phoneNumber, surveyData, tableSyncStatus)));

      // Execute all syncs in parallel (don't fail fast - collect all errors)
      await Future.wait(syncTasks, eagerError: false);

      return overallSuccess;

    } catch (e) {
      print('✗ CRITICAL: Failed to sync family survey to Supabase: $e');
      return false;
    }
  }

// Helper methods for syncing family survey tables
  Future<void> _syncFamilyMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('family_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncLandHolding(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final allowedKeys = <String>{
      'id',
      'created_at',
      'irrigated_area',
      'cultivable_area',
      'unirrigated_area',
      'barren_land',
      'mango_trees',
      'guava_trees',
      'lemon_trees',
      'pomegranate_trees',
      'other_fruit_trees_name',
      'other_fruit_trees_count',
    };
    final filtered = <String, dynamic>{
      for (final entry in data.entries)
        if (allowedKeys.contains(entry.key)) entry.key: entry.value,
    };
    await client.from('land_holding').upsert({...filtered, 'phone_number': phoneNumber});
  }

  Future<void> _syncIrrigationFacilities(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('irrigation_facilities').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncCropProductivity(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('crop_productivity').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncFertilizerUsage(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('fertilizer_usage').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncAnimals(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('animals').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncAgriculturalEquipment(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('agricultural_equipment').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncEntertainmentFacilities(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('entertainment_facilities').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncTransportFacilities(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('transport_facilities').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncDrinkingWaterSources(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
await client.from('drinking_water_sources').upsert({
  ...data,
  'phone_number': phoneNumber,
  'hand_pumps_quality': data['hand_pumps_quality'],
  'well_quality': data['well_quality'],
  'tubewell_quality': data['tubewell_quality'],
  'nal_jaal_quality': data['nal_jaal_quality'],
  'other_sources_quality': data['other_sources_quality'],
});
  }

  Future<void> _syncMedicalTreatment(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('medical_treatment').upsert({
      'allopathic': data['allopathic'] ?? '0',
      'ayurvedic': data['ayurvedic'] ?? '0',
      'homeopathy': data['homeopathy'] ?? '0',
      'traditional': data['traditional'] ?? '0',
      'other_treatment': data['other_treatment'] ?? '0',
      'preferred_treatment': data['preferred_treatment'],
      'phone_number': phoneNumber
    });
  }

  Future<void> _syncDisputes(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('disputes').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncHouseConditions(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('house_conditions').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncHouseFacilities(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('house_facilities').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncDiseases(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('diseases').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncGovernmentSchemes(String phoneNumber, Map<String, dynamic> surveyData) async {
    // Legacy sequential method - kept for compatibility
    await _syncGovernmentSchemesParallel(phoneNumber, surveyData, {});
  }

  // Parallel sync for government schemes with error tracking
  Future<void> _syncGovernmentSchemesParallel(
    String phoneNumber, 
    Map<String, dynamic> surveyData,
    Map<String, bool> tableSyncStatus,
  ) async {
    final syncTasks = <Future<void>>[];

    // Helper to wrap sync with tracking
    Future<void> syncWithTracking(String tableName, Future<void> Function() syncFn) async {
      try {
        await syncFn();
        tableSyncStatus[tableName] = true;
      } catch (e) {
        tableSyncStatus[tableName] = false;
        print('✗ Failed to sync $tableName: $e');
      }
    }

    // Sync all government scheme tables in parallel
    syncTasks.add(syncWithTracking('aadhaar_info', () => _syncAadhaarInfo(phoneNumber, surveyData['aadhaar_info'])));
    syncTasks.add(syncWithTracking('aadhaar_scheme_members', () => _syncAadhaarSchemeMembers(phoneNumber, surveyData['aadhaar_scheme_members'])));
    syncTasks.add(syncWithTracking('ayushman_card', () => _syncAyushmanCard(phoneNumber, surveyData['ayushman_card'])));
    syncTasks.add(syncWithTracking('ayushman_scheme_members', () => _syncAyushmanSchemeMembers(phoneNumber, surveyData['ayushman_scheme_members'])));
    syncTasks.add(syncWithTracking('family_id', () => _syncFamilyId(phoneNumber, surveyData['family_id'])));
    syncTasks.add(syncWithTracking('family_id_scheme_members', () => _syncFamilyIdSchemeMembers(phoneNumber, surveyData['family_id_scheme_members'])));
    syncTasks.add(syncWithTracking('ration_card', () => _syncRationCard(phoneNumber, surveyData['ration_card'])));
    syncTasks.add(syncWithTracking('ration_scheme_members', () => _syncRationSchemeMembers(phoneNumber, surveyData['ration_scheme_members'])));
    syncTasks.add(syncWithTracking('samagra_id', () => _syncSamagraId(phoneNumber, surveyData['samagra_id'])));
    syncTasks.add(syncWithTracking('samagra_scheme_members', () => _syncSamagraSchemeMembers(phoneNumber, surveyData['samagra_scheme_members'])));
    syncTasks.add(syncWithTracking('tribal_card', () => _syncTribalCard(phoneNumber, surveyData['tribal_card'])));
    syncTasks.add(syncWithTracking('tribal_scheme_members', () => _syncTribalSchemeMembers(phoneNumber, surveyData['tribal_scheme_members'])));
    syncTasks.add(syncWithTracking('handicapped_allowance', () => _syncHandicappedAllowance(phoneNumber, surveyData['handicapped_allowance'])));
    syncTasks.add(syncWithTracking('handicapped_scheme_members', () => _syncHandicappedSchemeMembers(phoneNumber, surveyData['handicapped_scheme_members'])));
    syncTasks.add(syncWithTracking('pension_allowance', () => _syncPensionAllowance(phoneNumber, surveyData['pension_allowance'])));
    syncTasks.add(syncWithTracking('pension_scheme_members', () => _syncPensionSchemeMembers(phoneNumber, surveyData['pension_scheme_members'])));
    syncTasks.add(syncWithTracking('widow_allowance', () => _syncWidowAllowance(phoneNumber, surveyData['widow_allowance'])));
    syncTasks.add(syncWithTracking('widow_scheme_members', () => _syncWidowSchemeMembers(phoneNumber, surveyData['widow_scheme_members'])));
    syncTasks.add(syncWithTracking('vb_gram', () => _syncVbGram(phoneNumber, surveyData['vb_gram'])));
    syncTasks.add(syncWithTracking('vb_gram_members', () => _syncVbGramMembers(phoneNumber, surveyData['vb_gram_members'])));
    syncTasks.add(syncWithTracking('pm_kisan_nidhi', () => _syncPmKisanNidhi(phoneNumber, surveyData['pm_kisan_nidhi'])));
    syncTasks.add(syncWithTracking('pm_kisan_members', () => _syncPmKisanMembers(phoneNumber, surveyData['pm_kisan_members'])));
    syncTasks.add(syncWithTracking('merged_govt_schemes', () => _syncMergedGovtSchemes(phoneNumber, surveyData['merged_govt_schemes'])));

    // Execute all in parallel
    await Future.wait(syncTasks, eagerError: false);
  }

  Future<void> _syncChildrenData(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('children_data').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncMalnourishedChildrenData(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('malnourished_children_data').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncChildDiseases(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('child_diseases').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncMalnutritionData(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('malnutrition_data').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncMigration(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('migration_data').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncTraining(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('training_data').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncSelfHelpGroups(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('self_help_groups').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncFpoMembership(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('fpo_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncBankAccounts(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('bank_accounts').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncSocialConsciousness(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('social_consciousness').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncTribalQuestions(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('tribal_questions').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncFolkloreMedicine(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('folklore_medicine').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncHealthProgrammes(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('health_programmes').upsert({...data, 'phone_number': phoneNumber});
  }


  // Government scheme helper methods
  Future<void> _syncAadhaarInfo(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('aadhaar_info').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncAadhaarSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('aadhaar_scheme_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncAyushmanCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('ayushman_card').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncAyushmanSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('ayushman_scheme_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncFamilyId(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('family_id').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncFamilyIdSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('family_id_scheme_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncRationCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('ration_card').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncRationSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('ration_scheme_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncSamagraId(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('samagra_id').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncSamagraSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('samagra_scheme_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncTribalCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('tribal_card').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncTribalSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('tribal_scheme_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncHandicappedAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('handicapped_allowance').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncHandicappedSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('handicapped_scheme_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncPensionAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('pension_allowance').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncPensionSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('pension_scheme_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncWidowAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('widow_allowance').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncWidowSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('widow_scheme_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncVbGram(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('vb_gram').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncVbGramMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('vb_gram_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncPmKisanNidhi(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('pm_kisan_nidhi').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncPmKisanMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('pm_kisan_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncPmKisanSamman(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('pm_kisan_samman').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncKisanCreditCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('kisan_credit_card').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncSwachhBharat(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('swachh_bharat').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncFasalBima(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('fasal_bima').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncMergedGovtSchemes(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('merged_govt_schemes').upsert({...data, 'phone_number': phoneNumber});
  }

  // Extract and sync tulsi_plants from house_facilities
  Future<void> _syncTulsiPlants(String phoneNumber, Map<String, dynamic>? houseFacilitiesData) async {
    if (houseFacilitiesData == null || houseFacilitiesData.isEmpty) return;

    final tulsiData = {
      'phone_number': phoneNumber,
      'has_plants': houseFacilitiesData['tulsi_plants_available'] ?? 'no',
      'plant_count': houseFacilitiesData['tulsi_plants_count'] ?? 0,
    };

    await client.from('tulsi_plants').upsert(tulsiData);
  }

  // Extract and sync nutritional_garden from house_facilities
  Future<void> _syncNutritionalGarden(String phoneNumber, Map<String, dynamic>? houseFacilitiesData) async {
    if (houseFacilitiesData == null || houseFacilitiesData.isEmpty) return;

    final gardenData = {
      'phone_number': phoneNumber,
      'has_garden': houseFacilitiesData['nutritional_garden_available'] ?? 'no',
      'garden_size': houseFacilitiesData['garden_size'] ?? 0.0,
      'vegetables_grown': houseFacilitiesData['vegetables_grown'] ?? '',
    };

    await client.from('nutritional_garden').upsert(gardenData);
  }

  // Village survey helper methods
  Future<void> _syncVillagePopulation(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_population').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageFarmFamilies(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_farm_families').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageDrainageWaste(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_drainage_waste').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageHousing(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_housing').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageAgriculturalImplements(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_agricultural_implements').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageCropProductivity(String sessionId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_crop_productivity').upsert(
      data.map((item) => {...item, 'session_id': sessionId}).toList(),
    );
  }

  Future<void> _syncVillageAnimals(String sessionId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_animals').upsert(
      data.map((item) => {...item, 'session_id': sessionId}).toList(),
    );
  }

  Future<void> _syncVillageIrrigationFacilities(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_irrigation_facilities').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageDrinkingWater(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_drinking_water').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageTransport(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_transport').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageEntertainment(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_entertainment').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageMedicalTreatment(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_medical_treatment').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageDisputes(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_disputes').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageEducationalFacilities(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_educational_facilities').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageSocialConsciousness(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_social_consciousness').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageChildrenData(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_children_data').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageMalnutritionData(String sessionId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_malnutrition_data').upsert(
      data.map((item) => {...item, 'session_id': sessionId}).toList(),
    );
  }

  Future<void> _syncVillageBplFamilies(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_bpl_families').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageKitchenGardens(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_kitchen_gardens').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageSeedClubs(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_seed_clubs').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageBiodiversityRegister(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_biodiversity_register').upsert({...data, 'session_id': sessionId});
  }

  Future<void> _syncVillageTraditionalOccupations(String sessionId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_traditional_occupations').upsert(
      data.map((item) => {...item, 'session_id': sessionId}).toList(),
    );
  }

  Future<void> _syncVillageUnemployment(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('village_unemployment').upsert({...data, 'session_id': sessionId});
  }

  // Get survey statistics for dashboard
  Future<Map<String, dynamic>> getSurveyStatistics() async {
    try {
      final surveyCount = await client.from('family_survey_sessions').select('id').then((data) => data.length);
      final todaySurveys = await client
          .from('family_survey_sessions')
          .select('id')
          .gte('created_at', DateTime.now().toIso8601String().split('T')[0])
          .then((data) => data.length);

      return {
        'total_surveys': surveyCount,
        'today_surveys': todaySurveys,
      };
    } catch (e) {
      return {'total_surveys': 0, 'today_surveys': 0};
    }
  }

  // Get surveys for current user
  Future<List<Map<String, dynamic>>> getUserSurveys() async {
    if (currentUser == null) return [];

    try {
      return await client
          .from('surveys')
          .select('*')
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);
    } catch (e) {
      return [];
    }
  }

  // Save village data to Supabase (generic method used by screens)
  Future<void> saveVillageData(String tableName, Map<String, dynamic> data) async {
    try {
      await client.from(tableName).upsert(data);
    } catch (e) {
      throw Exception('Failed to save village data to $tableName: $e');
    }
  }

  Future<void> syncVillageSurveyToSupabase(String sessionId, Map<String, dynamic> data) async {
    // Extract main session data
    final mainTableData = Map<String, dynamic>.from(data);
    
    // List of child tables to separate from main data
    final childTables = [
      'village_population', 'village_farm_families', 'village_housing',
      'village_agricultural_implements', 'village_crop_productivity', 'village_animals',
      'village_irrigation_facilities', 'village_drinking_water', 'village_transport',
      'village_entertainment', 'village_medical_treatment', 'village_disputes',
      'village_educational_facilities', 'village_social_consciousness',
      'village_children_data', 'village_malnutrition_data', 'village_bpl_families',
      'village_kitchen_gardens', 'village_seed_clubs', 'village_biodiversity_register',
      'village_traditional_occupations', 'village_drainage_waste', 'village_signboards'
    ];
    
    // Remove child data from main session payload
    for (var table in childTables) {
      mainTableData.remove(table);
    }
    
    // Sync main session
    await saveVillageData('village_survey_sessions', mainTableData);
    
    // Sync child tables
    for (var table in childTables) {
      if (data.containsKey(table)) {
        final tableData = data[table];
        
        if (tableData is List) {
           for (var item in tableData) {
             // Ensure session_id is present (it should be from local DB)
              final mapItem = Map<String, dynamic>.from(item);
              if (!mapItem.containsKey('session_id')) {
                mapItem['session_id'] = sessionId;
              }
              await saveVillageData(table, mapItem);
           }
        } else if (tableData is Map<String, dynamic>) {
           final mapItem = Map<String, dynamic>.from(tableData);
           if (!mapItem.containsKey('session_id')) {
             mapItem['session_id'] = sessionId;
           }
           await saveVillageData(table, mapItem);
        }
      }
    }
  }
}
