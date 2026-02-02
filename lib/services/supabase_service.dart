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

  // Sync family survey data to Supabase
  Future<void> syncFamilySurveyToSupabase(String phoneNumber, Map<String, dynamic> surveyData) async {
    try {
      // Get current user email for audit trail
      final userEmail = currentUser?.email ?? surveyData['surveyor_email'];

      // Insert main survey session data
      await client
          .from('family_survey_sessions')
          .upsert({
            'phone_number': phoneNumber,
            'surveyor_email': userEmail, // For RLS and audit trails
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
            'status': 'completed',
            'created_by': userEmail,
            'updated_by': userEmail,
            'user_id': currentUser?.id,
          });

      // Sync related data tables using phone_number as foreign key
      await _syncFamilyMembers(phoneNumber, surveyData['family_members']);
      await _syncLandHolding(phoneNumber, surveyData['land_holding']);
      await _syncIrrigationFacilities(phoneNumber, surveyData['irrigation_facilities']);
      await _syncCropProductivity(phoneNumber, surveyData['crop_productivity']);
      await _syncFertilizerUsage(phoneNumber, surveyData['fertilizer_usage']);
      await _syncAnimals(phoneNumber, surveyData['animals']);
      await _syncAgriculturalEquipment(phoneNumber, surveyData['agricultural_equipment']);
      await _syncEntertainmentFacilities(phoneNumber, surveyData['entertainment_facilities']);
      await _syncTransportFacilities(phoneNumber, surveyData['transport_facilities']);
      await _syncDrinkingWaterSources(phoneNumber, surveyData['drinking_water_sources']);
      await _syncMedicalTreatment(phoneNumber, surveyData['medical_treatment']);
      await _syncDisputes(phoneNumber, surveyData['disputes']);
      await _syncHouseConditions(phoneNumber, surveyData['house_conditions']);
      await _syncHouseFacilities(phoneNumber, surveyData['house_facilities']);
      await _syncDiseases(phoneNumber, surveyData['diseases']);
      await _syncGovernmentSchemes(phoneNumber, surveyData);
      await _syncChildrenData(phoneNumber, surveyData['children_data']);
      await _syncMalnourishedChildrenData(phoneNumber, surveyData['malnourished_children_data']);
      await _syncChildDiseases(phoneNumber, surveyData['child_diseases']);
      await _syncFolkloreMedicine(phoneNumber, surveyData['folklore_medicine']);
      await _syncHealthProgrammes(phoneNumber, surveyData['health_programmes']);
      await _syncMalnutritionData(phoneNumber, surveyData['malnutrition_data']);
      await _syncMigration(phoneNumber, surveyData['migration']);
      await _syncTraining(phoneNumber, surveyData['training']);
      await _syncSelfHelpGroups(phoneNumber, surveyData['self_help_groups']);
      await _syncFpoMembership(phoneNumber, surveyData['fpo_membership']);
      await _syncBankAccounts(phoneNumber, surveyData['bank_accounts']);
      await _syncSocialConsciousness(phoneNumber, surveyData['social_consciousness']);
      await _syncTribalQuestions(phoneNumber, surveyData['tribal_questions']);
      await _syncHealthPrograms(phoneNumber, surveyData['health_programmes']);
      await _syncFolkloreMedicine(phoneNumber, surveyData['folklore_medicine']);
      await _syncTulsiPlants(phoneNumber, surveyData['tulsi_plants']);
      await _syncNutritionalGarden(phoneNumber, surveyData['nutritional_garden']);

    } catch (e) {
      throw Exception('Failed to sync family survey to Supabase: $e');
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
    await client.from('land_holding').upsert({...data, 'phone_number': phoneNumber});
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
    // Sync individual government scheme tables
    await _syncAadhaarInfo(phoneNumber, surveyData['aadhaar_info']);
    await _syncAadhaarMembers(phoneNumber, surveyData['aadhaar_members']);
    await _syncAyushmanCard(phoneNumber, surveyData['ayushman_card']);
    await _syncAyushmanMembers(phoneNumber, surveyData['ayushman_members']);
    await _syncFamilyId(phoneNumber, surveyData['family_id']);
    await _syncFamilyIdMembers(phoneNumber, surveyData['family_id_members']);
    await _syncRationCard(phoneNumber, surveyData['ration_card']);
    await _syncRationCardMembers(phoneNumber, surveyData['ration_card_members']);
    await _syncSamagraId(phoneNumber, surveyData['samagra_id']);
    await _syncSamagraChildren(phoneNumber, surveyData['samagra_children']);
    await _syncTribalCard(phoneNumber, surveyData['tribal_card']);
    await _syncTribalCardMembers(phoneNumber, surveyData['tribal_card_members']);
    await _syncHandicappedAllowance(phoneNumber, surveyData['handicapped_allowance']);
    await _syncHandicappedMembers(phoneNumber, surveyData['handicapped_members']);
    await _syncPensionAllowance(phoneNumber, surveyData['pension_allowance']);
    await _syncPensionMembers(phoneNumber, surveyData['pension_members']);
    await _syncWidowAllowance(phoneNumber, surveyData['widow_allowance']);
    await _syncWidowMembers(phoneNumber, surveyData['widow_members']);
    await _syncVbGram(phoneNumber, surveyData['vb_gram']);
    await _syncVbGramMembers(phoneNumber, surveyData['vb_gram_members']);
    await _syncPmKisanNidhi(phoneNumber, surveyData['pm_kisan_nidhi']);
    await _syncPmKisanMembers(phoneNumber, surveyData['pm_kisan_members']);
    // Merged small schemes into one table
    await _syncMergedGovtSchemes(phoneNumber, surveyData['merged_govt_schemes']);
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

  Future<void> _syncHealthPrograms(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('health_programmes').upsert({...data, 'phone_number': phoneNumber});
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

  Future<void> _syncTulsiPlants(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('tulsi_plants').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncNutritionalGarden(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('nutritional_garden').upsert({...data, 'phone_number': phoneNumber});
  }

  // Government scheme helper methods
  Future<void> _syncAadhaarInfo(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('aadhaar_info').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncAadhaarMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('aadhaar_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncAyushmanCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('ayushman_card').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncAyushmanMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('ayushman_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncFamilyId(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('family_id').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncFamilyIdMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('family_id_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncRationCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('ration_card').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncRationCardMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('ration_card_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncSamagraId(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('samagra_id').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncSamagraChildren(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('samagra_children').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncTribalCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('tribal_card').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncTribalCardMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('tribal_card_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncHandicappedAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('handicapped_allowance').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncHandicappedMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('handicapped_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncPensionAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('pension_allowance').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncPensionMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('pension_members').upsert(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
  }

  Future<void> _syncWidowAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('widow_allowance').upsert({...data, 'phone_number': phoneNumber});
  }

  Future<void> _syncWidowMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('widow_members').upsert(
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
      'vile fillelage_irrigation_facilities', 'village_drinking_water', 'village_transport',
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
