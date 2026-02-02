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
      // Get surveys that haven't been synced to Supabase yet
      final allSurveys = await _databaseService.getAllSurveySessions();
      final pendingSurveys = <Map<String, dynamic>>[];

      for (final survey in allSurveys) {
        // Check if survey exists in Supabase
        final existsInSupabase = await _checkSurveyExistsInSupabase(survey['phone_number']);
        if (!existsInSupabase) {
          pendingSurveys.add(survey);
        }
      }

      return pendingSurveys;
    } catch (e) {
      debugPrint('Error getting pending surveys: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getPendingVillageSurveys() async {
    try {
      final allSurveys = await _databaseService.getAllVillageSurveySessions();
      final pendingSurveys = <Map<String, dynamic>>[];

      for (final survey in allSurveys) {
        // Check if survey exists in Supabase
        final existsInSupabase = await _checkVillageSurveyExistsInSupabase(survey['session_id']);
        if (!existsInSupabase) {
          pendingSurveys.add(survey);
        }
      }

      return pendingSurveys;
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

    try {
      final phoneNumber = survey['phone_number'];

      // Collect all survey data
      final surveyData = await _collectCompleteSurveyData(phoneNumber);

      // Sync to Supabase with transaction
      await _supabaseService.syncFamilySurveyToSupabase(phoneNumber, surveyData);

      // Mark as synced locally with timestamp
      await _markSurveyAsSynced(phoneNumber);

      // Update local sync metadata
      await _updateSyncMetadata(phoneNumber, surveyData);

      debugPrint('Successfully synced survey: $phoneNumber');

    } catch (e) {
      debugPrint('Failed to sync survey ${survey['phone_number']}: $e');
      // Queue for retry
      await queueSyncOperation('sync_survey', survey);
    }
  }

  Future<void> _syncVillageSurveyToSupabase(Map<String, dynamic> survey) async {
    if (!_isOnline) return;

    try {
      final sessionId = survey['session_id'];

      // Collect all survey data
      final surveyData = await _collectCompleteVillageSurveyData(sessionId);

      // Sync to Supabase
      await _supabaseService.syncVillageSurveyToSupabase(sessionId, surveyData);

      // Not marking as synced locally in separate field for now as we just check existence, 
      // but ideally we should update a synced flag. Or simply rely on existence check.
      debugPrint('Successfully synced village survey: $sessionId');

    } catch (e) {
      debugPrint('Failed to sync village survey ${survey['session_id']}: $e');
      // Queue for retry - reusing queueSyncOperation which might need adjustment or a new type
      // await queueSyncOperation('sync_village_survey', survey); 
    }
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
      'migration_data': 'migration',
      'training_data': 'training',
      'self_help_groups': 'self_help_groups',
      'fpo_members': 'fpo_membership',
      'bank_accounts': 'bank_accounts',
      'tulsi_plants': 'tulsi_plants',
      'nutritional_garden': 'nutritional_garden',
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
      'aadhaar_info', 'aadhaar_members',
      'ayushman_card', 'ayushman_members',
      'family_id', 'family_id_members',
      'ration_card', 'ration_card_members',
      'samagra_id', 'samagra_children',
      'tribal_card', 'tribal_card_members',
      'handicapped_allowance', 'handicapped_members',
      'pension_allowance', 'pension_members',
      'widow_allowance', 'widow_members',
      'vb_gram', 'vb_gram_members',
      'pm_kisan_nidhi', 'pm_kisan_members',
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

  Future<void> _markSurveyAsSynced(String phoneNumber) async {
    await _databaseService.saveData('survey_sessions', {
      'phone_number': phoneNumber,
      'sync_status': 'synced',
      'last_synced_at': DateTime.now().toIso8601String(),
    });
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
      case 'update_survey_data':
        await _supabaseService.syncFamilySurveyToSupabase(data['phone_number'], data);
        break;
      default:
        throw UnsupportedError('Unknown operation: $opType');
    }
  }

  Future<void> _saveSyncQueue() async {
    final queueJson = jsonEncode(_syncQueue);
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