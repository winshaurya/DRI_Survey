import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'supabase_service.dart';
import 'file_upload_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  static SyncService get instance => _instance;

  final DatabaseService _databaseService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService.instance;
  final FileUploadService _fileUploadService = FileUploadService.instance;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isOnline = false;

  // Sync queue for offline data
  final List<Map<String, dynamic>> _syncQueue = [];
  bool _isProcessingQueue = false;

  // Sync error tracking
  final Map<String, List<String>> _syncErrors = {};
  final Map<String, Map<String, bool>> _tableSyncStatus = {};

  SyncService._internal() {
    _initializeConnectivityMonitoring();
  }

  void _initializeConnectivityMonitoring() {
    // Monitor connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;

        if (!wasOnline && _isOnline) {
          // Network came back online, start syncing
          _startPeriodicSync();
          _processSyncQueue();
        } else if (wasOnline && !_isOnline) {
          // Network went offline, stop periodic sync
          _stopPeriodicSync();
        }
      },
    );

    // Check initial connectivity
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _startPeriodicSync();
      }
    });
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _performBackgroundSync();
    });
  }

  void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> _performBackgroundSync() async {
    if (!_isOnline || _isProcessingQueue) return;

    try {
      // Sync all pending surveys
      final pendingSurveys = await _getPendingSurveys();
      for (final survey in pendingSurveys) {
        await _syncSurveyToSupabase(survey);
      }

      // Sync all pending village surveys
      final pendingVillageSurveys = await _getPendingVillageSurveys();
      for (final survey in pendingVillageSurveys) {
        await _syncVillageSurveyToSupabase(survey);
      }

      // Process pending file uploads
      await _fileUploadService.processPendingUploads();

      // Process any queued sync operations
      await _processSyncQueue();

    } catch (e) {
      debugPrint('Background sync failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getPendingSurveys() async {
    try {
      final allSurveys = await _databaseService.getAllSurveySessions();
      
      return allSurveys.where((survey) {
        final phoneNumber = survey['phone_number']?.toString();
        // 1. Must have a valid primary key (phone_number)
        if (phoneNumber == null || phoneNumber.isEmpty) {
          return false;
        }

        // 2. Sync if status is NOT 'synced' (pending, failed, null)
        final status = survey['status'];
        return status != 'synced';
      }).toList();
    } catch (e) {
      debugPrint('Error getting pending surveys: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getPendingVillageSurveys() async {
    try {
      final allSurveys = await _databaseService.getAllVillageSurveySessions();
      
      return allSurveys.where((survey) {
        final sessionId = survey['session_id']?.toString();
        // 1. Must have a valid primary key (session_id)
        if (sessionId == null || sessionId.isEmpty) {
          return false;
        }

        // 2. Sync if status is NOT 'synced' (pending, failed, null)
        final status = survey['status'];
        return status != 'synced';
      }).toList();
    } catch (e) {
      debugPrint('Error getting pending village surveys: $e');
      return [];
    }
  }

  Future<bool> _checkSurveyExistsInSupabase(String phoneNumber) async {
    if (!_isOnline) return false;

    try {
      final response = await _supabaseService.client
          .from('family_survey_sessions')
          .select('phone_number')
          .eq('phone_number', phoneNumber)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkVillageSurveyExistsInSupabase(String sessionId) async {
    if (!_isOnline) return false;

    try {
      final response = await _supabaseService.client
          .from('village_survey_sessions')
          .select('session_id')
          .eq('session_id', sessionId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _syncSurveyToSupabase(Map<String, dynamic> survey) async {
    if (!_isOnline) return;

    final phoneNumber = survey['phone_number'];
    _syncErrors[phoneNumber] = [];
    _tableSyncStatus[phoneNumber] = {};

    try {
      // CRITICAL FIX: Validate local save BEFORE syncing to cloud
      final localSessionData = await _databaseService.getSurveySession(phoneNumber);
      if (localSessionData == null) {
        final error = 'Survey not found locally';
        _syncErrors[phoneNumber]!.add(error);
        debugPrint('⚠ WARNING: $phoneNumber - $error. Skipping cloud sync.');
        return;
      }

      // Collect all survey data (complete dataset for full sync)
      final surveyData = await _collectCompleteSurveyDataWithTracking(phoneNumber);

      // Verify critical data exists before syncing
      if (surveyData.isEmpty || surveyData['phone_number'] == null) {
        final error = 'Survey data incomplete';
        _syncErrors[phoneNumber]!.add(error);
        debugPrint('✗ ERROR: $phoneNumber - $error. Not syncing.');
        return;
      }

      // Validate data completeness before sync
      final validationErrors = _validateSurveyCompleteness(surveyData);
      if (validationErrors.isNotEmpty) {
        _syncErrors[phoneNumber]!.addAll(validationErrors);
        debugPrint('⚠ WARNING: $phoneNumber has ${validationErrors.length} validation issues:');
        for (final error in validationErrors) {
          debugPrint('  - $error');
        }
      }

      // Sync to Supabase with complete data and error tracking
      final syncResult = await _supabaseService.syncFamilySurveyToSupabaseWithTracking(
        phoneNumber, 
        surveyData,
        _tableSyncStatus[phoneNumber]!,
      );

      // Check if sync was truly complete
      final failedTables = _tableSyncStatus[phoneNumber]!.entries
          .where((e) => !e.value)
          .map((e) => e.key)
          .toList();

      if (failedTables.isEmpty && _syncErrors[phoneNumber]!.isEmpty) {
        // Mark as synced only if ALL tables succeeded
        await _markSurveyAsSynced(phoneNumber);
        await _updateSyncMetadata(phoneNumber, surveyData);
        debugPrint('✓ Successfully synced survey: $phoneNumber (${_tableSyncStatus[phoneNumber]!.length} tables)');
      } else {
        // Partial sync - mark as failed
        await _markSurveyAsFailed(phoneNumber, failedTables);
        debugPrint('⚠ PARTIAL SYNC: $phoneNumber - ${failedTables.length} tables failed:');
        for (final table in failedTables) {
          debugPrint('  ✗ $table');
        }
      }

    } catch (e, stackTrace) {
      final error = 'Sync exception: $e';
      _syncErrors[phoneNumber]!.add(error);
      debugPrint('✗ Failed to sync survey $phoneNumber: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Mark survey as failed and queue for retry
      await _markSurveyAsFailed(phoneNumber, ['SYNC_EXCEPTION']);
      await queueSyncOperation('sync_survey', survey);
    }
  }

  Future<void> _syncVillageSurveyToSupabase(Map<String, dynamic> survey) async {
    if (!_isOnline) return;

    try {
      final sessionId = survey['session_id'];

      // CRITICAL FIX: Validate local save BEFORE syncing to cloud
      final localSessionData = await _databaseService.getVillageSurveySession(sessionId);
      if (localSessionData == null) {
        debugPrint('⚠ WARNING: Village survey $sessionId not found locally. Skipping cloud sync.');
        return;
      }

      // Collect all survey data (all related tables for this session)
      final surveyData = await _collectCompleteVillageSurveyData(sessionId);

      // Verify critical data exists before syncing
      if (surveyData.isEmpty || surveyData['session_id'] == null) {
        debugPrint('✗ ERROR: Village survey data incomplete for $sessionId. Not syncing.');
        return;
      }

      // Sync to Supabase
      await _supabaseService.syncVillageSurveyToSupabase(sessionId, surveyData);

      // Mark as synced locally
      await _markVillageSurveyAsSynced(sessionId);

      debugPrint('✓ Successfully synced village survey: $sessionId');

    } catch (e) {
      debugPrint('✗ Failed to sync village survey ${survey['session_id']}: $e');
      await queueSyncOperation('sync_village_survey', survey); 
    }
  }

  Future<void> _markVillageSurveyAsSynced(String sessionId) async {
    await _databaseService.updateVillageSurveySyncStatus(sessionId, 'synced');
  }

  Future<Map<String, dynamic>> _collectCompleteVillageSurveyData(String sessionId) async {
    final db = await _databaseService.database;

    // Get main session data
    final sessions = await db.query(
      'village_survey_sessions',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    if (sessions.isEmpty) {
      throw Exception('Village survey session not found: $sessionId');
    }

    final surveyData = Map<String, dynamic>.from(sessions.first);

    // List of related tables
    final tables = [
      'village_population',
      'village_farm_families',
      'village_housing',
      'village_agricultural_implements',
      'village_crop_productivity',
      'village_animals',
      'village_irrigation_facilities',
      'village_drinking_water',
      'village_transport',
      'village_entertainment',
      'village_medical_treatment',
      'village_disputes',
      'village_educational_facilities',
      'village_social_consciousness',
      'village_children_data',
      'village_malnutrition_data',
      'village_bpl_families',
      'village_kitchen_gardens',
      'village_seed_clubs',
      'village_biodiversity_register',
      'village_traditional_occupations',
      'village_drainage_waste',
      'village_signboards',
      'village_infrastructure',
      'village_infrastructure_details',
      'village_survey_details',
      'village_map_points',
      'village_forest_maps',
      'village_cadastral_maps',
      'village_unemployment',
      'village_social_maps',
      'village_transport_facilities',
    ];

    for (final table in tables) {
      try {
        final data = await db.query(
          table,
          where: 'session_id = ?',
          whereArgs: [sessionId],
        );

        if (data.isNotEmpty) {
          if (_isOneToManyVillageTable(table)) {
            surveyData[table] = data;
          } else {
            surveyData[table] = data.first;
          }
        }
      } catch (e) {
        debugPrint('Error collecting data for table $table: $e');
      }
    }

    return surveyData;
  }

  bool _isOneToManyVillageTable(String tableName) {
    const oneToManyTables = {
      'village_crop_productivity',
      'village_animals',
      'village_malnutrition_data',
      'village_traditional_occupations',
    };
    return oneToManyTables.contains(tableName);
  }

  Future<Map<String, dynamic>> _collectCompleteSurveyData(String phoneNumber) async {
    final surveyData = <String, dynamic>{};

    // Get session data
    final sessionData = await _databaseService.getSurveySession(phoneNumber);
    if (sessionData != null) {
      surveyData.addAll(sessionData);
    }

    // Get all related data
    final dataMappings = {
      'family_members': 'family_members',
      'land_holding': 'land_holding',
      'irrigation_facilities': 'irrigation_facilities',
      'crop_productivity': 'crop_productivity',
      'fertilizer_usage': 'fertilizer_usage',
      'animals': 'animals',
      'agricultural_equipment': 'agricultural_equipment',
      'entertainment_facilities': 'entertainment_facilities',
      'transport_facilities': 'transport_facilities',
      'drinking_water_sources': 'drinking_water_sources',
      'medical_treatment': 'medical_treatment',
      'disputes': 'disputes',
      'house_conditions': 'house_conditions',
      'house_facilities': 'house_facilities',
      'diseases': 'diseases',
      'social_consciousness': 'social_consciousness',
      'children_data': 'children_data',
      'malnourished_children_data': 'malnourished_children_data',
      'child_diseases': 'child_diseases',
      'folklore_medicine': 'folklore_medicine',
      'health_programmes': 'health_programmes',
      'malnutrition_data': 'malnutrition_data',
      'migration_data': 'migration_data',
      'training_data': 'training_data',
      'shg_members': 'shg_members',
      'fpo_members': 'fpo_members',
      'bank_accounts': 'bank_accounts',
      // Note: tulsi_plants and nutritional_garden are stored in house_facilities table
    };

    for (final entry in dataMappings.entries) {
      final data = await _databaseService.getData(entry.key, phoneNumber);
      if (data.isNotEmpty) {
        surveyData[entry.value] = data;
      }
    }

    // Get government schemes data
    final governmentSchemes = await _collectGovernmentSchemesData(phoneNumber);
    surveyData.addAll(governmentSchemes);

    return surveyData;
  }

  Future<Map<String, dynamic>> _collectGovernmentSchemesData(String phoneNumber) async {
    final schemesData = <String, dynamic>{};

    final schemeTables = [
      'aadhaar_info', 'aadhaar_scheme_members',
      'ayushman_card', 'ayushman_scheme_members',
      'family_id', 'family_id_scheme_members',
      'ration_card', 'ration_scheme_members',
      'samagra_id', 'samagra_scheme_members',
      'tribal_card', 'tribal_scheme_members',
      'handicapped_allowance', 'handicapped_scheme_members',
      'pension_allowance', 'pension_scheme_members',
      'widow_allowance', 'widow_scheme_members',
      'vb_gram',
      'pm_kisan_nidhi',
      'merged_govt_schemes', // Merged table for small schemes
    ];

    for (final table in schemeTables) {
      final data = await _databaseService.getData(table, phoneNumber);
      if (data.isNotEmpty) {
        schemesData[table] = data;
      }
    }

    return schemesData;
  }

  /// Collect survey data with error tracking
  Future<Map<String, dynamic>> _collectCompleteSurveyDataWithTracking(String phoneNumber) async {
    final surveyData = <String, dynamic>{};
    final errors = _syncErrors[phoneNumber]!;

    // Get session data
    try {
      final sessionData = await _databaseService.getSurveySession(phoneNumber);
      if (sessionData != null) {
        surveyData.addAll(sessionData);
      } else {
        errors.add('Session data not found');
      }
    } catch (e) {
      errors.add('Failed to fetch session data: $e');
    }

    // Get all related data
    final dataMappings = {
      'family_members': 'family_members',
      'land_holding': 'land_holding',
      'irrigation_facilities': 'irrigation_facilities',
      'crop_productivity': 'crop_productivity',
      'fertilizer_usage': 'fertilizer_usage',
      'animals': 'animals',
      'agricultural_equipment': 'agricultural_equipment',
      'entertainment_facilities': 'entertainment_facilities',
      'transport_facilities': 'transport_facilities',
      'drinking_water_sources': 'drinking_water_sources',
      'medical_treatment': 'medical_treatment',
      'disputes': 'disputes',
      'house_conditions': 'house_conditions',
      'house_facilities': 'house_facilities',
      'diseases': 'diseases',
      'social_consciousness': 'social_consciousness',
      'children_data': 'children_data',
      'malnourished_children_data': 'malnourished_children_data',
      'child_diseases': 'child_diseases',
      'folklore_medicine': 'folklore_medicine',
      'health_programmes': 'health_programmes',
      'malnutrition_data': 'malnutrition_data',
      'migration_data': 'migration_data',
      'training_data': 'training_data',
      'shg_members': 'shg_members',
      'fpo_members': 'fpo_members',
      'bank_accounts': 'bank_accounts',
    };

    for (final entry in dataMappings.entries) {
      try {
        final data = await _databaseService.getData(entry.key, phoneNumber);
        if (data.isNotEmpty) {
          surveyData[entry.value] = data;
        }
      } catch (e) {
        errors.add('Failed to fetch ${entry.key}: $e');
        debugPrint('⚠ Warning: Could not fetch ${entry.key} for $phoneNumber: $e');
      }
    }

    // Get government schemes data with tracking
    try {
      final governmentSchemes = await _collectGovernmentSchemesDataWithTracking(phoneNumber);
      surveyData.addAll(governmentSchemes);
    } catch (e) {
      errors.add('Failed to fetch government schemes: $e');
    }

    return surveyData;
  }

  /// Collect government schemes with error tracking
  Future<Map<String, dynamic>> _collectGovernmentSchemesDataWithTracking(String phoneNumber) async {
    final schemesData = <String, dynamic>{};
    final errors = _syncErrors[phoneNumber]!;

    final schemeTables = [
      'aadhaar_info', 'aadhaar_scheme_members',
      'ayushman_card', 'ayushman_scheme_members',
      'family_id', 'family_id_scheme_members',
      'ration_card', 'ration_scheme_members',
      'samagra_id', 'samagra_scheme_members',
      'tribal_card', 'tribal_scheme_members',
      'handicapped_allowance', 'handicapped_scheme_members',
      'pension_allowance', 'pension_scheme_members',
      'widow_allowance', 'widow_scheme_members',
      'vb_gram',
      'pm_kisan_nidhi',
      'merged_govt_schemes',
    ];

    for (final table in schemeTables) {
      try {
        final data = await _databaseService.getData(table, phoneNumber);
        if (data.isNotEmpty) {
          schemesData[table] = data;
        }
      } catch (e) {
        errors.add('Failed to fetch $table: $e');
        debugPrint('⚠ Warning: Could not fetch $table for $phoneNumber: $e');
      }
    }

    return schemesData;
  }

  /// Validate survey data completeness before sync
  List<String> _validateSurveyCompleteness(Map<String, dynamic> surveyData) {
    final errors = <String>[];

    // Check critical fields in session data
    if (surveyData['village_name'] == null || surveyData['village_name'].toString().isEmpty) {
      errors.add('Missing village_name');
    }
    if (surveyData['district'] == null || surveyData['district'].toString().isEmpty) {
      errors.add('Missing district');
    }
    if (surveyData['surveyor_email'] == null || surveyData['surveyor_email'].toString().isEmpty) {
      errors.add('Missing surveyor_email');
    }

    // Check for family members (required for family survey)
    if (surveyData['family_members'] == null || 
        (surveyData['family_members'] as List).isEmpty) {
      errors.add('Missing family_members data');
    }

    // Warn about missing optional but important tables
    final importantTables = [
      'land_holding',
      'house_conditions',
      'social_consciousness',
    ];

    for (final table in importantTables) {
      if (surveyData[table] == null) {
        errors.add('Missing optional but important table: $table');
      }
    }

    return errors;
  }

  /// Mark survey as failed with failed tables list
  Future<void> _markSurveyAsFailed(String phoneNumber, List<String> failedTables) async {
    try {
      await _databaseService.updateSurveySyncStatus(phoneNumber, 'failed');
      
      // Store failed tables info for debugging
      final failureInfo = {
        'phone_number': phoneNumber,
        'failed_at': DateTime.now().toIso8601String(),
        'failed_tables': failedTables.join(', '),
        'error_count': _syncErrors[phoneNumber]?.length ?? 0,
      };
      
      await _databaseService.saveData('sync_failures', failureInfo);
      debugPrint('✗ Marked $phoneNumber as failed. Failed tables: ${failedTables.join(", ")}');
    } catch (e) {
      debugPrint('Error marking survey as failed: $e');
    }
  }

  Future<void> _markSurveyAsSynced(String phoneNumber) async {
    await _databaseService.updateSurveySyncStatus(phoneNumber, 'synced');
  }



  Future<void> _updateSyncMetadata(String phoneNumber, Map<String, dynamic> surveyData) async {
    try {
      // Store sync metadata locally
      final metadata = {
        'phone_number': phoneNumber,
        'last_sync_attempt': DateTime.now().toIso8601String(),
        'data_hash': _calculateDataHash(surveyData),
        'sync_version': 1,
      };

      await _databaseService.saveData('sync_metadata', metadata);
    } catch (e) {
      debugPrint('Error updating sync metadata: $e');
    }
  }

  String _calculateDataHash(Map<String, dynamic> data) {
    // Simple hash calculation for data integrity checking
    final jsonString = jsonEncode(data);
    var hash = 0;
    for (var i = 0; i < jsonString.length; i++) {
      final char = jsonString.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return hash.toString();
  }

  // Queue operations for when network returns
  Future<void> queueSyncOperation(String operation, Map<String, dynamic> data) async {
    _syncQueue.add({
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });

    // Save queue to persistent storage
    await _saveSyncQueue();

    // Process immediately if online
    if (_isOnline) {
      await _processSyncQueue();
    }
  }

  Future<void> _processSyncQueue() async {
    if (_isProcessingQueue || !_isOnline || _syncQueue.isEmpty) return;

    _isProcessingQueue = true;

    try {
      final queueCopy = List<Map<String, dynamic>>.from(_syncQueue);

      for (int i = 0; i < queueCopy.length; i++) {
        final operation = queueCopy[i];
        try {
          await _executeQueuedOperation(operation);
          _syncQueue.removeAt(i);
          i--; // Adjust index after removal
        } catch (e) {
          debugPrint('Failed to execute queued operation: $e');
          operation['retry_count'] = (operation['retry_count'] ?? 0) + 1;

          // Remove from queue if max retries exceeded
          if (operation['retry_count'] >= 3) {
            _syncQueue.removeAt(i);
            i--;
          }
        }
      }

      // Save updated queue
      await _saveSyncQueue();

    } finally {
      _isProcessingQueue = false;
    }
  }

  Future<void> _executeQueuedOperation(Map<String, dynamic> operation) async {
    final opType = operation['operation'];
    final data = operation['data'];

    switch (opType) {
      case 'sync_survey':
        await _syncSurveyToSupabase(data);
        break;
      case 'sync_village_survey':
        await _syncVillageSurveyToSupabase(data);
        break;
      case 'update_survey_data':
        await _supabaseService.syncFamilySurveyToSupabase(data['phone_number'], data);
        break;
      default:
        throw UnsupportedError('Unknown operation: $opType');
    }
  }

  Future<void> _saveSyncQueue() async {
    // Save to local storage (you might want to use shared_preferences or similar)
    debugPrint('Sync queue saved with ${_syncQueue.length} operations');
  }

  Future<void> loadSyncQueue() async {
    // Load from local storage
    // Implementation depends on your storage solution
  }

  // Public methods
  Future<void> syncSurveyImmediately(String phoneNumber) async {
    if (!_isOnline) {
      await queueSyncOperation('sync_survey', {'phone_number': phoneNumber});
      return;
    }

    final survey = await _databaseService.getSurveySession(phoneNumber);
    if (survey != null) {
      await _syncSurveyToSupabase(survey);
    }
  }

  Future<void> syncVillageSurveyImmediately(String sessionId) async {
     if (!_isOnline) {
      await queueSyncOperation('sync_village_survey', {'session_id': sessionId});
      return;
    }
    
    final survey = await _databaseService.getVillageSurveySession(sessionId);
    if (survey != null) {
      await _syncVillageSurveyToSupabase(survey);
    }
  }

  Future<void> forceSyncAllPendingData() async {
    if (!_isOnline) return;

    await _performBackgroundSync();
  }

  bool get isOnline => _isOnline;

  Stream<bool> get connectivityStream => Connectivity().onConnectivityChanged
      .map((result) => result != ConnectivityResult.none);

  // Cleanup
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}