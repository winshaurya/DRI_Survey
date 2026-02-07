import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static SupabaseService get instance => _instance;

  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Retry configuration
  static const int _maxRetryAttempts = 4;
  static const int _initialBackoffMs = 500;
  static const int _maxBackoffMs = 8000;

  // Field normalization helpers
  static const Set<String> _boolFields = {
    'is_deleted',
    'has_account',
    'details_correct',
    'name_included',
    'received',
    'is_auto_save',
  };

  Future<void> initialize() async {
    // Supabase is already initialized in main.dart
    // This method is kept for compatibility
    return;
  }

  Future<T> _withRetry<T>(Future<T> Function() action, {String? operation}) async {
    int attempt = 0;
    int delayMs = _initialBackoffMs;
    final rng = Random();

    while (true) {
      try {
        return await action();
      } catch (e) {
        attempt++;
        if (attempt >= _maxRetryAttempts) {
          rethrow;
        }
        final jitter = rng.nextInt(250);
        await Future.delayed(Duration(milliseconds: delayMs + jitter));
        delayMs = (delayMs * 2).clamp(_initialBackoffMs, _maxBackoffMs);
        if (operation != null) {
          print('⚠ Retry $attempt for $operation after error: $e');
        }
      }
    }
  }

  dynamic _normalizeValue(String key, dynamic value) {
    if (value == null) return null;

    if (value is bool) {
      return _boolFields.contains(key) ? (value ? 1 : 0) : value;
    }

    if (value is num) return value;

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final lower = trimmed.toLowerCase();

      if (_boolFields.contains(key)) {
        if (lower == 'true' || lower == 'yes' || lower == '1') return 1;
        if (lower == 'false' || lower == 'no' || lower == '0') return 0;
      }

      if (_shouldParseNumber(key) && _isNumericString(trimmed)) {
        return _parseNumber(trimmed);
      }

      return trimmed;
    }

    return value;
  }

  bool _isNumericString(String value) {
    return double.tryParse(value) != null;
  }

  bool _shouldParseNumber(String key) {
    final lower = key.toLowerCase();
    return lower.contains('count') ||
        lower.contains('number') ||
        lower.contains('total') ||
        lower.contains('age') ||
        lower.contains('area') ||
        lower.contains('income') ||
        lower.contains('lat') ||
        lower.contains('long') ||
        lower.contains('distance') ||
        lower.contains('sr_no') ||
        lower.contains('population') ||
        lower.contains('members') ||
        lower.contains('years') ||
        lower.contains('height') ||
        lower.contains('weight') ||
        lower.contains('percentage') ||
        lower.contains('amount') ||
        lower.contains('quantity') ||
        lower.contains('duration') ||
        lower.contains('rate') ||
        lower.contains('size');
  }

  num _parseNumber(String value) {
    if (value.contains('.')) {
      return double.tryParse(value) ?? 0.0;
    }
    return int.tryParse(value) ?? 0;
  }

  Map<String, dynamic> _normalizeMap(Map<String, dynamic> data) {
    final normalized = <String, dynamic>{};
    for (final entry in data.entries) {
      normalized[entry.key] = _normalizeValue(entry.key, entry.value);
    }
    return normalized;
  }

  List<Map<String, dynamic>> _normalizeList(List<dynamic> data) {
    final normalized = <Map<String, dynamic>>[];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        normalized.add(_normalizeMap(item));
      } else if (item is Map) {
        final casted = <String, dynamic>{};
        for (final entry in item.entries) {
          casted[entry.key.toString()] = entry.value;
        }
        normalized.add(_normalizeMap(casted));
      }
    }
    return normalized;
  }

  Future<void> _upsertWithRetry(String table, dynamic data) async {
    if (data == null) return;
    if (data is List && data.isEmpty) return;
    await _withRetry(() => client.from(table).upsert(data), operation: 'upsert $table');
  }

  Future<Map<String, String>> validateSchema(List<String> tableNames) async {
    final errors = <String, String>{};

    for (final table in tableNames) {
      try {
        await _withRetry(
          () => client.from(table).select('id').limit(1),
          operation: 'schema check $table',
        );
      } catch (e) {
        errors[table] = e.toString();
      }
    }

    return errors;
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
        final payload = _normalizeMap({
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
        });
        await _upsertWithRetry('family_survey_sessions', payload);
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

  Future<void> syncFamilyPageToSupabase(String phoneNumber, int page, Map<String, dynamic> data) async {
    if (phoneNumber.isEmpty) return;

    final userEmail = currentUser?.email ?? data['surveyor_email'];

    if (page == 0) {
      final payload = _normalizeMap({
        'phone_number': phoneNumber,
        'surveyor_email': userEmail,
        'village_name': data['village_name'],
        'village_number': data['village_number'],
        'panchayat': data['panchayat'],
        'block': data['block'],
        'tehsil': data['tehsil'],
        'district': data['district'],
        'postal_address': data['postal_address'],
        'pin_code': data['pin_code'],
        'shine_code': data['shine_code'],
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'location_accuracy': data['location_accuracy'],
        'location_timestamp': data['location_timestamp'],
        'surveyor_name': data['surveyor_name'],
        'status': data['status'] ?? 'in_progress',
        'created_by': userEmail,
        'updated_by': userEmail,
      });
      await _upsertWithRetry('family_survey_sessions', payload);
      return;
    }

    switch (page) {
      case 1:
        await _syncFamilyMembers(phoneNumber, data['family_members'] ?? data['familyMembers'] ?? data['members']);
        break;
      case 2:
      case 3:
      case 4:
      case 25:
        await _syncSocialConsciousness(phoneNumber, data['social_consciousness'] ?? data);
        break;
      case 5:
        await _syncLandHolding(phoneNumber, data['land_holding'] ?? data);
        break;
      case 6:
        await _syncIrrigationFacilities(phoneNumber, data['irrigation_facilities'] ?? data);
        break;
      case 7:
        await _syncCropProductivity(phoneNumber, data['crops'] ?? data['crop_productivity']);
        break;
      case 8:
        await _syncFertilizerUsage(phoneNumber, data['fertilizer_usage'] ?? data);
        break;
      case 9:
        await _syncAnimals(phoneNumber, data['animals']);
        break;
      case 10:
        await _syncAgriculturalEquipment(phoneNumber, data['agricultural_equipment'] ?? data);
        break;
      case 11:
        await _syncEntertainmentFacilities(phoneNumber, data['entertainment_facilities'] ?? data);
        break;
      case 12:
        await _syncTransportFacilities(phoneNumber, data['transport_facilities'] ?? data);
        break;
      case 13:
        await _syncDrinkingWaterSources(phoneNumber, data['drinking_water_sources'] ?? data);
        break;
      case 14:
        await _syncMedicalTreatment(phoneNumber, data['medical_treatment'] ?? data);
        break;
      case 15:
        await _syncDisputes(phoneNumber, data['disputes'] ?? data);
        break;
      case 16:
        await _syncHouseConditions(phoneNumber, data['house_conditions'] ?? data);
        await _syncHouseFacilities(phoneNumber, data['house_facilities'] ?? data);
        await _syncTulsiPlants(phoneNumber, data['house_facilities'] ?? data);
        await _syncNutritionalGarden(phoneNumber, data['house_facilities'] ?? data);
        break;
      case 17:
        await _syncDiseases(phoneNumber, data['diseases']);
        break;
      case 19:
        await _syncFolkloreMedicine(phoneNumber, data['folklore_medicine'] ?? data['folklore_medicines']);
        break;
      case 20:
        await _syncHealthProgrammes(phoneNumber, data['health_programmes'] ?? data);
        break;
      case 18:
        await _syncGovernmentSchemesParallel(phoneNumber, data, {});
        break;
      case 21:
        await _syncChildrenData(phoneNumber, data['children_data'] ?? data);
        await _syncMalnourishedChildrenData(phoneNumber, data['malnourished_children_data']);
        await _syncChildDiseases(phoneNumber, data['child_diseases']);
        break;
      case 22:
        await _syncMigration(phoneNumber, data['migration_data'] ?? data);
        break;
      case 23:
        await _syncTraining(phoneNumber, data['training_data']);
        await _syncSelfHelpGroups(phoneNumber, data['shg_members']);
        await _syncFpoMembership(phoneNumber, data['fpo_members']);
        break;
      case 24:
        await _syncVbGram(phoneNumber, data['vb_gram'] ?? data);
        await _syncVbGramMembers(phoneNumber, data['vb_gram_members']);
        break;
      case 25:
        await _syncPmKisanNidhi(phoneNumber, data['pm_kisan_nidhi'] ?? data);
        await _syncPmKisanMembers(phoneNumber, data['pm_kisan_members']);
        break;
      case 26:
        await _syncPmKisanSammanNidhi(phoneNumber, data['pm_kisan_samman_nidhi'] ?? data);
        await _syncPmKisanSammanMembers(phoneNumber, data['pm_kisan_samman_members']);
        break;
      case 27:
      case 28:
      case 29:
        await _syncMergedGovtSchemes(phoneNumber, data['merged_govt_schemes'] ?? data);
        break;
      case 30:
        await _syncBankAccounts(phoneNumber, data['bank_accounts']);
        break;
      default:
        break;
    }
  }

  Future<void> syncVillagePageToSupabase(String sessionId, int page, Map<String, dynamic> data) async {
    if (sessionId.isEmpty) return;

    switch (page) {
      case 0:
        await saveVillageData('village_survey_sessions', data);
        break;
      case 1:
        await saveVillageData('village_infrastructure', data);
        break;
      case 2:
        await saveVillageData('village_infrastructure_details', data);
        break;
      case 3:
        await saveVillageData('village_educational_facilities', data);
        break;
      case 4:
        await saveVillageData('village_drainage_waste', data);
        break;
      case 5:
        await saveVillageData('village_irrigation_facilities', data);
        break;
      case 6:
        await saveVillageData('village_seed_clubs', data);
        break;
      case 7:
        await saveVillageData('village_signboards', data);
        break;
      case 8:
        await saveVillageData('village_social_maps', data);
        break;
      case 9:
        await saveVillageData('village_survey_details', data);
        break;
      case 10:
        final points = data['map_points'];
        if (points is List) {
          for (final point in points) {
            if (point is Map<String, dynamic>) {
              await saveVillageData('village_map_points', point);
            } else if (point is Map) {
              await saveVillageData('village_map_points', point.map((k, v) => MapEntry(k.toString(), v)));
            }
          }
        } else {
          await saveVillageData('village_map_points', data);
        }
        break;
      case 11:
        await saveVillageData('village_forest_maps', data);
        break;
      case 12:
        await saveVillageData('village_biodiversity_register', data);
        break;
      case 13:
        await saveVillageData('village_cadastral_maps', data);
        break;
      case 14:
        await saveVillageData('village_transport_facilities', data);
        break;
      default:
        break;
    }
  }

// Helper methods for syncing family survey tables
  Future<void> _syncFamilyMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('family_members', rows);
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
    await _upsertWithRetry('land_holding', _normalizeMap({...filtered, 'phone_number': phoneNumber}));
  }

  Future<void> _syncIrrigationFacilities(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('irrigation_facilities', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncCropProductivity(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('crop_productivity', rows);
  }

  Future<void> _syncFertilizerUsage(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('fertilizer_usage', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncAnimals(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('animals', rows);
  }

  Future<void> _syncAgriculturalEquipment(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('agricultural_equipment', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncEntertainmentFacilities(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('entertainment_facilities', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncTransportFacilities(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('transport_facilities', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncDrinkingWaterSources(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry(
      'drinking_water_sources',
      _normalizeMap({
        ...data,
        'phone_number': phoneNumber,
        'hand_pumps_quality': data['hand_pumps_quality'],
        'well_quality': data['well_quality'],
        'tubewell_quality': data['tubewell_quality'],
        'nal_jaal_quality': data['nal_jaal_quality'],
        'other_sources_quality': data['other_sources_quality'],
      }),
    );
  }

  Future<void> _syncMedicalTreatment(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry(
      'medical_treatment',
      _normalizeMap({
        'allopathic': data['allopathic'] ?? '0',
        'ayurvedic': data['ayurvedic'] ?? '0',
        'homeopathy': data['homeopathy'] ?? '0',
        'traditional': data['traditional'] ?? '0',
        'other_treatment': data['other_treatment'] ?? '0',
        'preferred_treatment': data['preferred_treatment'],
        'phone_number': phoneNumber,
      }),
    );
  }

  Future<void> _syncDisputes(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('disputes', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncHouseConditions(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('house_conditions', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncHouseFacilities(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('house_facilities', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncDiseases(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('diseases', rows);
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
    syncTasks.add(syncWithTracking('pm_kisan_samman_nidhi', () => _syncPmKisanSammanNidhi(phoneNumber, surveyData['pm_kisan_samman_nidhi'])));
    syncTasks.add(syncWithTracking('pm_kisan_samman_members', () => _syncPmKisanSammanMembers(phoneNumber, surveyData['pm_kisan_samman_members'])));
    syncTasks.add(syncWithTracking('merged_govt_schemes', () => _syncMergedGovtSchemes(phoneNumber, surveyData['merged_govt_schemes'])));

    // Execute all in parallel
    await Future.wait(syncTasks, eagerError: false);
  }

  Future<void> _syncChildrenData(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('children_data', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncMalnourishedChildrenData(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('malnourished_children_data', rows);
  }

  Future<void> _syncChildDiseases(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('child_diseases', rows);
  }

  Future<void> _syncMalnutritionData(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('malnutrition_data', rows);
  }

  Future<void> _syncMigration(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('migration_data', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncTraining(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('training_data', rows);
  }

  Future<void> _syncSelfHelpGroups(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('shg_members', rows);
  }

  Future<void> _syncFpoMembership(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('fpo_members', rows);
  }

  Future<void> _syncBankAccounts(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('bank_accounts', rows);
  }

  Future<void> _syncSocialConsciousness(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('social_consciousness', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncTribalQuestions(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('tribal_questions', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncFolkloreMedicine(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('folklore_medicine', rows);
  }

  Future<void> _syncHealthProgrammes(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('health_programmes', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }


  // Government scheme helper methods
  Future<void> _syncAadhaarInfo(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('aadhaar_info', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncAadhaarSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('aadhaar_scheme_members', rows);
  }

  Future<void> _syncAyushmanCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('ayushman_card', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncAyushmanSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('ayushman_scheme_members', rows);
  }

  Future<void> _syncFamilyId(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('family_id', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncFamilyIdSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('family_id_scheme_members', rows);
  }

  Future<void> _syncRationCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('ration_card', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncRationSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('ration_scheme_members', rows);
  }

  Future<void> _syncSamagraId(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('samagra_id', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncSamagraSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('samagra_scheme_members', rows);
  }

  Future<void> _syncTribalCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('tribal_card', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncTribalSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('tribal_scheme_members', rows);
  }

  Future<void> _syncHandicappedAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('handicapped_allowance', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncHandicappedSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('handicapped_scheme_members', rows);
  }

  Future<void> _syncPensionAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('pension_allowance', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncPensionSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('pension_scheme_members', rows);
  }

  Future<void> _syncWidowAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('widow_allowance', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncWidowSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('widow_scheme_members', rows);
  }

  Future<void> _syncVbGram(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('vb_gram', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncVbGramMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) {
        final memberName = item['member_name'] ?? item['name'] ?? item['family_member_name'];
        return {
          'phone_number': phoneNumber,
          'sr_no': item['sr_no'],
          'member_name': memberName,
          'name_included': item['name_included'],
          'details_correct': item['details_correct'],
          'incorrect_details': item['incorrect_details'],
          'received': item['received'],
          'days': item['days'],
          'membership_details': item['membership_details'],
        };
      }).toList(),
    );
    await _upsertWithRetry('vb_gram_members', rows);
  }

  Future<void> _syncPmKisanNidhi(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('pm_kisan_nidhi', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncPmKisanMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) {
        final memberName = item['member_name'] ?? item['name'] ?? item['family_member_name'];
        return {
          'phone_number': phoneNumber,
          'sr_no': item['sr_no'],
          'member_name': memberName,
          'account_number': item['account_number'],
          'benefits_received': item['benefits_received'] ?? item['received'],
          'name_included': item['name_included'],
          'details_correct': item['details_correct'],
          'incorrect_details': item['incorrect_details'],
          'received': item['received'],
          'days': item['days'],
        };
      }).toList(),
    );
    await _upsertWithRetry('pm_kisan_members', rows);
  }

  Future<void> _syncPmKisanSammanNidhi(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('pm_kisan_samman_nidhi', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncPmKisanSammanMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) {
        final memberName = item['member_name'] ?? item['name'] ?? item['family_member_name'];
        return {
          'phone_number': phoneNumber,
          'sr_no': item['sr_no'],
          'member_name': memberName,
          'account_number': item['account_number'],
          'benefits_received': item['benefits_received'] ?? item['received'],
          'name_included': item['name_included'],
          'details_correct': item['details_correct'],
          'incorrect_details': item['incorrect_details'],
          'received': item['received'],
          'days': item['days'],
        };
      }).toList(),
    );
    await _upsertWithRetry('pm_kisan_samman_members', rows);
  }

  Future<void> _syncKisanCreditCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('kisan_credit_card', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncSwachhBharat(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('swachh_bharat', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncFasalBima(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('fasal_bima', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncMergedGovtSchemes(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final schemeData = data['scheme_data'] ?? (data is Map<String, dynamic> ? data : null);
    await _upsertWithRetry(
      'merged_govt_schemes',
      _normalizeMap({
        'phone_number': phoneNumber,
        'scheme_data': schemeData,
      }),
    );
  }

  // Extract and sync tulsi_plants from house_facilities
  Future<void> _syncTulsiPlants(String phoneNumber, Map<String, dynamic>? houseFacilitiesData) async {
    if (houseFacilitiesData == null || houseFacilitiesData.isEmpty) return;

    final tulsiData = {
      'phone_number': phoneNumber,
      'has_plants': houseFacilitiesData['tulsi_plants_available'] ?? 'no',
      'plant_count': houseFacilitiesData['tulsi_plants_count'] ?? 0,
    };

    await _upsertWithRetry('tulsi_plants', _normalizeMap(tulsiData));
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

    await _upsertWithRetry('nutritional_garden', _normalizeMap(gardenData));
  }

  // Village survey helper methods
  Future<void> _syncVillagePopulation(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_population', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageFarmFamilies(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_farm_families', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageDrainageWaste(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_drainage_waste', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageHousing(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_housing', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageAgriculturalImplements(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_agricultural_implements', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageCropProductivity(String sessionId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'session_id': sessionId}).toList(),
    );
    await _upsertWithRetry('village_crop_productivity', rows);
  }

  Future<void> _syncVillageAnimals(String sessionId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'session_id': sessionId}).toList(),
    );
    await _upsertWithRetry('village_animals', rows);
  }

  Future<void> _syncVillageIrrigationFacilities(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_irrigation_facilities', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageDrinkingWater(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_drinking_water', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageTransport(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_transport', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageEntertainment(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_entertainment', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageMedicalTreatment(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_medical_treatment', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageDisputes(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_disputes', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageEducationalFacilities(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_educational_facilities', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageSocialConsciousness(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_social_consciousness', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageChildrenData(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_children_data', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageMalnutritionData(String sessionId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'session_id': sessionId}).toList(),
    );
    await _upsertWithRetry('village_malnutrition_data', rows);
  }

  Future<void> _syncVillageBplFamilies(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_bpl_families', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageKitchenGardens(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_kitchen_gardens', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageSeedClubs(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_seed_clubs', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageBiodiversityRegister(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_biodiversity_register', _normalizeMap({...data, 'session_id': sessionId}));
  }

  Future<void> _syncVillageTraditionalOccupations(String sessionId, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'session_id': sessionId}).toList(),
    );
    await _upsertWithRetry('village_traditional_occupations', rows);
  }

  Future<void> _syncVillageUnemployment(String sessionId, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('village_unemployment', _normalizeMap({...data, 'session_id': sessionId}));
  }

  // Get survey statistics for dashboard
  Future<Map<String, dynamic>> getSurveyStatistics() async {
    try {
      final surveyCount = await _withRetry(
        () => client.from('family_survey_sessions').select('id'),
        operation: 'stats total surveys',
      ).then((data) => data.length);
      final todaySurveys = await _withRetry(
        () => client
            .from('family_survey_sessions')
            .select('id')
            .gte('created_at', DateTime.now().toIso8601String().split('T')[0]),
        operation: 'stats today surveys',
      ).then((data) => data.length);

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
      final payload = Map<String, dynamic>.from(data);
      if (tableName == 'village_survey_sessions') {
        payload.remove('page_completion_status');
        payload.remove('sync_pending');
        payload.remove('sync_status');
      }
      await _upsertWithRetry(tableName, _normalizeMap(payload));
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
      'village_traditional_occupations', 'village_drainage_waste', 'village_signboards',
      'village_infrastructure', 'village_infrastructure_details', 'village_survey_details',
      'village_map_points', 'village_forest_maps', 'village_cadastral_maps',
      'village_unemployment', 'village_social_maps', 'village_transport_facilities'
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
