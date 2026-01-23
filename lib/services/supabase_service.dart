import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  User? get currentUser => client.auth.currentUser;

  // Check if user is online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Sync survey data to Supabase
  Future<void> syncSurveyToSupabase(int surveyId, Map<String, dynamic> surveyData) async {
    try {
      // Insert main survey data
      final surveyResponse = await client
          .from('surveys')
          .insert({
            'village_name': surveyData['village_name'],
            'panchayat': surveyData['panchayat'],
            'block': surveyData['block'],
            'tehsil': surveyData['tehsil'],
            'district': surveyData['district'],
            'postal_address': surveyData['postal_address'],
            'pin_code': surveyData['pin_code'],
            'survey_date': surveyData['survey_date'],
            'created_at': surveyData['created_at'],
            'updated_at': surveyData['updated_at'],
            'user_id': currentUser?.id,
          })
          .select()
          .single();

      final newSurveyId = surveyResponse['id'];

      // Sync related data tables
      await _syncFamilyDetails(newSurveyId, surveyData['family_details']);
      await _syncLandHolding(newSurveyId, surveyData['land_holding']);
      await _syncIrrigationFacilities(newSurveyId, surveyData['irrigation_facilities']);
      await _syncCropProductivity(newSurveyId, surveyData['crop_productivity']);
      await _syncFertilizerUsage(newSurveyId, surveyData['fertilizer_usage']);
      await _syncAnimals(newSurveyId, surveyData['animals']);
      await _syncAgriculturalEquipment(newSurveyId, surveyData['agricultural_equipment']);
      await _syncEntertainmentFacilities(newSurveyId, surveyData['entertainment_facilities']);
      await _syncTransportFacilities(newSurveyId, surveyData['transport_facilities']);
      await _syncDrinkingWaterSources(newSurveyId, surveyData['drinking_water_sources']);
      await _syncMedicalTreatment(newSurveyId, surveyData['medical_treatment']);
      await _syncDisputes(newSurveyId, surveyData['disputes']);
      await _syncHouseConditions(newSurveyId, surveyData['house_conditions']);
      await _syncHouseFacilities(newSurveyId, surveyData['house_facilities']);
      await _syncSeriousDiseases(newSurveyId, surveyData['serious_diseases']);
      await _syncGovernmentSchemes(newSurveyId, surveyData['government_schemes']);
      await _syncBeneficiaryPrograms(newSurveyId, surveyData['beneficiary_programs']);
      await _syncChildrenData(newSurveyId, surveyData['children_data']);
      await _syncMalnutritionData(newSurveyId, surveyData['malnutrition_data']);
      await _syncMigration(newSurveyId, surveyData['migration']);
      await _syncTraining(newSurveyId, surveyData['training']);
      await _syncSelfHelpGroups(newSurveyId, surveyData['self_help_groups']);
      await _syncFpoMembership(newSurveyId, surveyData['fpo_membership']);
      await _syncBankAccounts(newSurveyId, surveyData['bank_accounts']);
      await _syncSocialConsciousness(newSurveyId, surveyData['social_consciousness']);
      await _syncTribalQuestions(newSurveyId, surveyData['tribal_questions']);
      await _syncHealthPrograms(newSurveyId, surveyData['health_programs']);
      await _syncFolkloreMedicine(newSurveyId, surveyData['folklore_medicine']);
      await _syncTulsiPlants(newSurveyId, surveyData['tulsi_plants']);
      await _syncNutritionalGarden(newSurveyId, surveyData['nutritional_garden']);

    } catch (e) {
      throw Exception('Failed to sync survey to Supabase: $e');
    }
  }

  // Helper methods for syncing individual tables
  Future<void> _syncFamilyDetails(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('family_details').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncLandHolding(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('land_holding').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncIrrigationFacilities(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('irrigation_facilities').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncCropProductivity(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('crop_productivity').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncFertilizerUsage(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('fertilizer_usage').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncAnimals(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('animals').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncAgriculturalEquipment(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('agricultural_equipment').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncEntertainmentFacilities(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('entertainment_facilities').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncTransportFacilities(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('transport_facilities').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncDrinkingWaterSources(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('drinking_water_sources').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncMedicalTreatment(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('medical_treatment').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncDisputes(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('disputes').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncHouseConditions(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('house_conditions').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncHouseFacilities(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('house_facilities').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncSeriousDiseases(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('serious_diseases').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncGovernmentSchemes(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('government_schemes').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncBeneficiaryPrograms(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('beneficiary_programs').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncChildrenData(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('children_data').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncMalnutritionData(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('malnutrition_data').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncMigration(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('migration').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncTraining(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('training').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncSelfHelpGroups(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('self_help_groups').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncFpoMembership(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('fpo_membership').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncBankAccounts(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('bank_accounts').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncSocialConsciousness(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('social_consciousness').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncTribalQuestions(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('tribal_questions').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncHealthPrograms(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('health_programs').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncFolkloreMedicine(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('folklore_medicine').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncTulsiPlants(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('tulsi_plants').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  Future<void> _syncNutritionalGarden(int surveyId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await client.from('nutritional_garden').insert(
      data.map((item) => {...item, 'survey_id': surveyId}).toList(),
    );
  }

  // Get survey statistics for dashboard
  Future<Map<String, dynamic>> getSurveyStatistics() async {
    try {
      final surveyCount = await client.from('surveys').select('id').then((data) => data.length);
      final todaySurveys = await client
          .from('surveys')
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
}
