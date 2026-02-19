import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'supabase_service.dart';
import 'file_upload_service.dart';

class SyncProgress {
  final String stage;
  final String? surveyId;
  final String? table;
  final int? current;
  final int? total;
  final String? message;
  final bool isError;

  const SyncProgress({
    required this.stage,
    this.surveyId,
    this.table,
    this.current,
    this.total,
    this.message,
    this.isError = false,
  });
}

typedef SyncErrorCallback = void Function(String message, {bool persistent});

class SyncService {
  static final SyncService _instance = SyncService._internal();
  static SyncService get instance => _instance;

  final DatabaseService _databaseService = DatabaseService();
  late final SupabaseService _supabaseService;
  late final FileUploadService _fileUploadService;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = false;
  bool _connectivityInitialized = false;

  // Progress and error reporting
  final StreamController<SyncProgress> _progressController = StreamController<SyncProgress>.broadcast();
  Stream<SyncProgress> get progressStream => _progressController.stream;
  SyncProgress? _lastProgress;

  // Sync queue for offline data
  final List<Map<String, dynamic>> _syncQueue = [];
  bool _isProcessingQueue = false;
  final Map<String, bool> _syncLocks = {};

  // Sync error tracking (persistent)
  final Map<String, List<String>> _syncErrors = {};
  final List<Map<String, dynamic>> _persistentSyncErrors = [];
  SyncErrorCallback? onSyncError;
  final Map<String, Map<String, bool>> _tableSyncStatus = {};

  final Map<String, DateTime> _lastSchemaCheckAt = {};
  final Map<String, Map<String, String>> _cachedSchemaIssues = {};

  static const List<String> _requiredFamilyTables = [
    'family_survey_sessions',
    'family_members',
    'land_holding',
    'irrigation_facilities',
    'crop_productivity',
    'fertilizer_usage',
    'animals',
    'agricultural_equipment',
    'entertainment_facilities',
    'transport_facilities',
    'drinking_water_sources',
    'medical_treatment',
    'disputes',
    'house_conditions',
    'house_facilities',
    'diseases',
    'social_consciousness',
    'children_data',
    'malnourished_children_data',
    'child_diseases',
    'folklore_medicine',
    'health_programmes',
    'migration_data',
    'training_data',
    'shg_members',
    'fpo_members',
    'bank_accounts',
    'tulsi_plants',
    'nutritional_garden',
    'malnutrition_data',
    'aadhaar_info',
    'aadhaar_scheme_members',
    'ayushman_card',
    'ayushman_scheme_members',
    'family_id',
    'family_id_scheme_members',
    'ration_card',
    'ration_scheme_members',
    'samagra_id',
    'samagra_scheme_members',
    'tribal_card',
    'tribal_scheme_members',
    'handicapped_allowance',
    'handicapped_scheme_members',
    'pension_allowance',
    'pension_scheme_members',
    'widow_allowance',
    'widow_scheme_members',
    'vb_gram',
    'vb_gram_members',
    'pm_kisan_nidhi',
    'pm_kisan_members',
    'pm_kisan_samman_nidhi',
    'pm_kisan_samman_members',
    'merged_govt_schemes',
    'tribal_questions',
  ];

  static const List<String> _requiredVillageTables = [
    'village_survey_sessions',
    'village_population',
    'village_farm_families',
    'village_housing',
    'village_agricultural_implements',
    'village_crop_productivity',
    'village_animals',
    'village_irrigation_facilities',
    'village_drinking_water',
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

  SyncService._internal() {
    // Lazy initialization to make service testable
    _supabaseService = SupabaseService.instance;
    _fileUploadService = FileUploadService.instance;
    // Initialize connectivity monitoring and load queue
    _ensureConnectivityMonitoringInitialized();
    loadSyncQueue();
  }

  void _ensureConnectivityMonitoringInitialized() {
    if (_connectivityInitialized) return;
    _connectivityInitialized = true;
    // Initialize connectivity monitoring asynchronously (do not await here)
    _initializeConnectivityMonitoring();
  }

  // Public method to check if online (ensures connectivity monitoring is initialized)
  Future<bool> get isOnlineAsync async {
    _ensureConnectivityMonitoringInitialized();
    return _isOnline;
  }

  Future<void> _initializeConnectivityMonitoring() async {
    // Check initial connectivity first
    final initialResult = await Connectivity().checkConnectivity();
    _isOnline = initialResult != ConnectivityResult.none;

    // Monitor connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;

        if (!wasOnline && _isOnline) {
          // Network came back online, process queued operations
          _processSyncQueue();
        }
      },
    );

    // Start syncing if initially online
    if (_isOnline) {
      // Sync operations are now handled by explicit page-by-page sync calls
    }
  }

  void _emitProgress(SyncProgress progress) {
    _lastProgress = progress;
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
    if (progress.isError && progress.message != null) {
      _escalateError(progress.message!);
    }
  }

  void _escalateError(String message, {bool persistent = false}) {
    // Escalate error to user via callback, persistent log, or UI
    if (onSyncError != null) {
      onSyncError!(message, persistent: persistent);
    }
    if (persistent) {
      _persistentSyncErrors.add({
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _savePersistentSyncErrors();
    }
  }

  Future<void> _savePersistentSyncErrors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('persistent_sync_errors', jsonEncode(_persistentSyncErrors));
    } catch (_) {}
  }

  Future<void> loadPersistentSyncErrors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errorsJson = prefs.getString('persistent_sync_errors');
      if (errorsJson != null && errorsJson.isNotEmpty) {
        final decoded = jsonDecode(errorsJson);
        if (decoded is List) {
          _persistentSyncErrors
            ..clear()
            ..addAll(decoded.whereType<Map>().map((item) => item.map((k, v) => MapEntry(k.toString(), v))));
        }
      }
    } catch (_) {}
  }

  Future<void> _withSyncLock(String key, Future<void> Function() action) async {
    if (_syncLocks[key] == true) return;
    _syncLocks[key] = true;
    try {
      await action();
    } finally {
      _syncLocks[key] = false;
    }
  }

  Future<void> syncFamilyPageData(String phoneNumber, int page, Map<String, dynamic> data) async {
    _ensureConnectivityMonitoringInitialized();
    if (phoneNumber.isEmpty || page < 0) return;

    await _withSyncLock('family:$phoneNumber', () async {
      // Re-check connectivity now to prefer immediate sync when possible
      final connectivityResult = await Connectivity().checkConnectivity();
      final currentlyOnline = connectivityResult != ConnectivityResult.none;
      _isOnline = currentlyOnline;

      // If offline or not authenticated, queue and return
      if (!currentlyOnline || _supabaseService.currentUser == null) {
        await queueSyncOperation('sync_family_page', {
          'phone_number': phoneNumber,
          'page': page,
          'data': data,
        });
        return;
      }

      // Prevent overwriting when remote has newer data
      final localUpdatedAt = await _getLocalUpdatedAt('family_survey_sessions', 'phone_number', phoneNumber);
      final remoteNewer = await _isRemoteNewerFamily(phoneNumber, localUpdatedAt);
      if (remoteNewer) {
        await _markSurveyAsFailed(phoneNumber, ['REMOTE_NEWER']);
        return;
      }

      // If this is page 0, perform immediate synchronous upsert so session is created/updated
      if (page == 0) {
        try {
          await _supabaseService.syncFamilyPageToSupabase(phoneNumber, 0, data);
          await _databaseService.markFamilyPageSynced(phoneNumber, 0);
        } catch (e) {
          final errMsg = 'Immediate session sync failed for $phoneNumber: $e';
          _escalateError(errMsg, persistent: true);
          await queueSyncOperation('sync_family_page', {
            'phone_number': phoneNumber,
            'page': page,
            'data': data,
          });
        }
        return;
      }

      // For other pages, schedule a background (non-blocking) sync similar to village flow
      try {
        _supabaseService.syncFamilyPageToSupabase(phoneNumber, page, data).then((_) async {
          try {
            await _databaseService.markFamilyPageSynced(phoneNumber, page);
          } catch (markErr) {
            _escalateError('Failed to mark page synced for $phoneNumber page $page: $markErr', persistent: true);
          }
        }).catchError((e) async {
          final errMsg = 'Background page sync failed for family $phoneNumber page $page: $e';
          _escalateError(errMsg, persistent: true);
          await queueSyncOperation('sync_family_page', {
            'phone_number': phoneNumber,
            'page': page,
            'data': data,
          });
        });
      } catch (e) {
        final errMsg = 'Page sync scheduling failed for family $phoneNumber page $page: $e';
        _escalateError(errMsg, persistent: true);
        await queueSyncOperation('sync_family_page', {
          'phone_number': phoneNumber,
          'page': page,
          'data': data,
        });
      }
    });
  }

  Future<void> syncVillagePageData(String sessionId, int page, Map<String, dynamic> data) async {
    if (sessionId.isEmpty || page < 0) return;
    await _withSyncLock('village:$sessionId', () async {
      if (!_isOnline || _supabaseService.currentUser == null) {
        await queueSyncOperation('sync_village_page', {
          'session_id': sessionId,
          'page': page,
          'data': data,
        });
        return;
      }

      final localUpdatedAt = await _getLocalUpdatedAt('village_survey_sessions', 'session_id', sessionId);
      final remoteNewer = await _isRemoteNewerVillage(sessionId, localUpdatedAt);
      if (remoteNewer) {
        await _databaseService.updateVillageSurveySyncStatus(sessionId, 'conflict');
        return;
      }

      try {
        await _supabaseService.syncVillagePageToSupabase(sessionId, page, data);
        await _databaseService.markVillagePageSynced(sessionId, page);
      } catch (e) {
        final errMsg = 'Page sync failed for village $sessionId page $page: $e';
        _escalateError(errMsg, persistent: true);
        await queueSyncOperation('sync_village_page', {
          'session_id': sessionId,
          'page': page,
          'data': data,
        });
      }
    });
  }

  /// Public method to sync a village survey by session ID
  Future<void> syncVillageSurveyToSupabase(String sessionId) async {
    _ensureConnectivityMonitoringInitialized();
    try {
      final survey = await _databaseService.getVillageSurveySession(sessionId);
      if (survey == null) {
        _escalateError('Survey not found for session ID: $sessionId', persistent: true);
        return;
      }

      if (!_isOnline) {
        await queueSyncOperation('sync_village_survey', survey);
        return;
      }

      await _syncVillageSurveyToSupabase(survey);
    } catch (e) {
      _escalateError('Error syncing village survey: $e', persistent: true);
    }
  }

  Future<Map<String, String>> _checkSchemaWithCache(List<String> tables, String cacheKey) async {
    final now = DateTime.now();
    final lastCheck = _lastSchemaCheckAt[cacheKey];
    if (lastCheck != null && now.difference(lastCheck).inMinutes < 10) {
      return _cachedSchemaIssues[cacheKey] ?? {};
    }

    _emitProgress(const SyncProgress(stage: 'schema_check', message: 'Validating Supabase schema...'));
    final issues = await _supabaseService.validateSchema(tables);
    _cachedSchemaIssues[cacheKey] = issues;
    _lastSchemaCheckAt[cacheKey] = now;
    if (issues.isNotEmpty) {
      final msg = 'Schema validation failed for ${issues.length} tables: ${issues.keys.join(", ")}';
      _emitProgress(SyncProgress(
        stage: 'schema_check',
        message: msg,
        isError: true,
      ));
      _escalateError(msg, persistent: true);
    }
    return issues;
  }

  Map<String, List<String>> get syncErrors => _syncErrors;
  Map<String, Map<String, bool>> get tableSyncStatus => _tableSyncStatus;
  SyncProgress? get lastProgress => _lastProgress;

  Map<String, dynamic>? _firstOrNull(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return null;
    return Map<String, dynamic>.from(list.first);
  }

  List<String> getErrorsForSurvey(String phoneNumber) =>
      List<String>.from(_syncErrors[phoneNumber] ?? const []);

  Future<Map<String, dynamic>> _collectFamilyPageDataFromDb(String phoneNumber, int page) async {
    switch (page) {
      case 27:
      case 28:
      case 29:
        return {
          'merged_govt_schemes': _firstOrNull(await _databaseService.getData('merged_govt_schemes', phoneNumber)),
        };
      case 23:
        return {
          'training_data': await _databaseService.getData('training_data', phoneNumber),
          'shg_members': await _databaseService.getData('shg_members', phoneNumber),
          'fpo_members': await _databaseService.getData('fpo_members', phoneNumber),
        };
      case 6:
        final irrigation = await _databaseService.getData('irrigation_facilities', phoneNumber);
        return irrigation.isNotEmpty ? Map<String, dynamic>.from(irrigation.first) : {};
      case 7:
        final crops = await _databaseService.getData('crop_productivity', phoneNumber);
        return {'crops': crops};
      case 8:
        final fertilizer = await _databaseService.getData('fertilizer_usage', phoneNumber);
        return fertilizer.isNotEmpty ? Map<String, dynamic>.from(fertilizer.first) : {};
      case 9:
        final animals = await _databaseService.getData('animals', phoneNumber);
        return {'animals': animals};
      case 10:
        final equipment = await _databaseService.getData('agricultural_equipment', phoneNumber);
        return equipment.isNotEmpty ? Map<String, dynamic>.from(equipment.first) : {};
      case 11:
        final entertainment = await _databaseService.getData('entertainment_facilities', phoneNumber);
        return entertainment.isNotEmpty ? Map<String, dynamic>.from(entertainment.first) : {};
      case 12:
        final transport = await _databaseService.getData('transport_facilities', phoneNumber);
        return transport.isNotEmpty ? Map<String, dynamic>.from(transport.first) : {};
      case 13:
        final water = await _databaseService.getData('drinking_water_sources', phoneNumber);
        return water.isNotEmpty ? Map<String, dynamic>.from(water.first) : {};
      case 14:
        final medical = await _databaseService.getData('medical_treatment', phoneNumber);
        return medical.isNotEmpty ? Map<String, dynamic>.from(medical.first) : {};
      case 15:
        final disputes = await _databaseService.getData('disputes', phoneNumber);
        return disputes.isNotEmpty ? Map<String, dynamic>.from(disputes.first) : {};
      case 16:
        final houseConditions = await _databaseService.getData('house_conditions', phoneNumber);
        final houseFacilities = await _databaseService.getData('house_facilities', phoneNumber);
        return {
          'house_conditions': houseConditions.isNotEmpty ? Map<String, dynamic>.from(houseConditions.first) : {},
          'house_facilities': houseFacilities.isNotEmpty ? Map<String, dynamic>.from(houseFacilities.first) : {},
        };
      case 17:
        final diseases = await _databaseService.getData('diseases', phoneNumber);
        return {'diseases': diseases};
      case 18:
        return {
          'aadhaar_info': _firstOrNull(await _databaseService.getData('aadhaar_info', phoneNumber)),
          'aadhaar_scheme_members': await _databaseService.getData('aadhaar_scheme_members', phoneNumber),
          'ayushman_card': _firstOrNull(await _databaseService.getData('ayushman_card', phoneNumber)),
          'ayushman_scheme_members': await _databaseService.getData('ayushman_scheme_members', phoneNumber),
          'family_id': _firstOrNull(await _databaseService.getData('family_id', phoneNumber)),
          'family_id_scheme_members': await _databaseService.getData('family_id_scheme_members', phoneNumber),
          'ration_card': _firstOrNull(await _databaseService.getData('ration_card', phoneNumber)),
          'ration_scheme_members': await _databaseService.getData('ration_scheme_members', phoneNumber),
          'samagra_id': _firstOrNull(await _databaseService.getData('samagra_id', phoneNumber)),
          'samagra_scheme_members': await _databaseService.getData('samagra_scheme_members', phoneNumber),
          'tribal_card': _firstOrNull(await _databaseService.getData('tribal_card', phoneNumber)),
          'tribal_scheme_members': await _databaseService.getData('tribal_scheme_members', phoneNumber),
          'handicapped_allowance': _firstOrNull(await _databaseService.getData('handicapped_allowance', phoneNumber)),
          'handicapped_scheme_members': await _databaseService.getData('handicapped_scheme_members', phoneNumber),
          'pension_allowance': _firstOrNull(await _databaseService.getData('pension_allowance', phoneNumber)),
          'pension_scheme_members': await _databaseService.getData('pension_scheme_members', phoneNumber),
          'widow_allowance': _firstOrNull(await _databaseService.getData('widow_allowance', phoneNumber)),
          'widow_scheme_members': await _databaseService.getData('widow_scheme_members', phoneNumber),
          'vb_gram': _firstOrNull(await _databaseService.getData('vb_gram', phoneNumber)),
          'vb_gram_members': await _databaseService.getData('vb_gram_members', phoneNumber),
          'pm_kisan_nidhi': _firstOrNull(await _databaseService.getData('pm_kisan_nidhi', phoneNumber)),
          'pm_kisan_members': await _databaseService.getData('pm_kisan_members', phoneNumber),
          'merged_govt_schemes': _firstOrNull(await _databaseService.getData('merged_govt_schemes', phoneNumber)),
        };
      case 19:
        final medicines = await _databaseService.getData('folklore_medicine', phoneNumber);
        return {'folklore_medicine': medicines};
      case 20:
        final programmes = await _databaseService.getData('health_programmes', phoneNumber);
        return programmes.isNotEmpty ? Map<String, dynamic>.from(programmes.first) : {};
      case 21:
        return {
          'children_data': _firstOrNull(await _databaseService.getData('children_data', phoneNumber)),
          'malnourished_children_data': await _databaseService.getData('malnourished_children_data', phoneNumber),
          'child_diseases': await _databaseService.getData('child_diseases', phoneNumber),
        };
      case 22:
        final migration = await _databaseService.getData('migration_data', phoneNumber);
        return migration.isNotEmpty ? Map<String, dynamic>.from(migration.first) : {};
      case 23:
        return {
          'training_data': await _databaseService.getData('training_data', phoneNumber),
          'shg_members': await _databaseService.getData('shg_members', phoneNumber),
          'fpo_members': await _databaseService.getData('fpo_members', phoneNumber),
        };
      case 24:
        return {
          'vb_gram': _firstOrNull(await _databaseService.getData('vb_gram', phoneNumber)),
          'vb_gram_members': await _databaseService.getData('vb_gram_members', phoneNumber),
        };
      case 25:
        return {
          'pm_kisan_nidhi': _firstOrNull(await _databaseService.getData('pm_kisan_nidhi', phoneNumber)),
          'pm_kisan_members': await _databaseService.getData('pm_kisan_members', phoneNumber),
        };
      case 26:
        return {
          'pm_kisan_samman_nidhi': _firstOrNull(await _databaseService.getData('pm_kisan_samman_nidhi', phoneNumber)),
          'pm_kisan_samman_members': await _databaseService.getData('pm_kisan_samman_members', phoneNumber),
        };
      case 27:
      case 28:
      case 29:
        return {
          'merged_govt_schemes': _firstOrNull(await _databaseService.getData('merged_govt_schemes', phoneNumber)),
        };
      case 30:
        return {'bank_accounts': await _databaseService.getData('bank_accounts', phoneNumber)};
      default:
        return {};
    }
  }

  Future<Map<String, dynamic>> _collectVillagePageDataFromDb(String sessionId, int page) async {
    switch (page) {
      case 0:
        return await _databaseService.getVillageSurveySession(sessionId) ?? {};
      case 1:
        return _firstOrNull(await _databaseService.getVillageData('village_infrastructure', sessionId)) ?? {};
      case 2:
        return _firstOrNull(await _databaseService.getVillageData('village_infrastructure_details', sessionId)) ?? {};
      case 3:
        return _firstOrNull(await _databaseService.getVillageData('village_educational_facilities', sessionId)) ?? {};
      case 4:
        return _firstOrNull(await _databaseService.getVillageData('village_drainage_waste', sessionId)) ?? {};
      case 5:
        return _firstOrNull(await _databaseService.getVillageData('village_irrigation_facilities', sessionId)) ?? {};
      case 6:
        return _firstOrNull(await _databaseService.getVillageData('village_seed_clubs', sessionId)) ?? {};
      case 7:
        return _firstOrNull(await _databaseService.getVillageData('village_signboards', sessionId)) ?? {};
      case 8:
        return _firstOrNull(await _databaseService.getVillageData('village_social_maps', sessionId)) ?? {};
      case 9:
        return _firstOrNull(await _databaseService.getVillageData('village_survey_details', sessionId)) ?? {};
      case 10:
        final points = await _databaseService.getVillageData('village_map_points', sessionId);
        return {'map_points': points};
      case 11:
        return _firstOrNull(await _databaseService.getVillageData('village_forest_maps', sessionId)) ?? {};
      case 12:
        return _firstOrNull(await _databaseService.getVillageData('village_biodiversity_register', sessionId)) ?? {};
      case 13:
        return _firstOrNull(await _databaseService.getVillageData('village_cadastral_maps', sessionId)) ?? {};
      case 14:
        return _firstOrNull(await _databaseService.getVillageData('village_transport_facilities', sessionId)) ?? {};
      default:
        return {};
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

        final status = survey['status']?.toString();
        final syncPending = survey['sync_pending'] == 1;
        final syncStatus = survey['sync_status']?.toString();

        // Only full-sync completed surveys. Pending pages are handled separately.
        if (syncPending) return false;
        if (syncStatus == 'synced') return false;
        return status == 'completed' || status == 'exported';
      }).toList();
    } catch (e) {
      _escalateError('Error getting pending surveys: $e', persistent: true);
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

        final status = survey['status']?.toString();
        final syncPending = survey['sync_pending'] == 1;
        final syncStatus = survey['sync_status']?.toString();

        // Only full-sync completed surveys. Pending pages are handled separately.
        if (syncPending) return false;
        if (syncStatus == 'synced') return false;
        return status == 'completed' || status == 'exported';
      }).toList();
    } catch (e) {
      _escalateError('Error getting pending village surveys: $e', persistent: true);
      return [];
    }
  }

  Future<bool> _checkSurveyExistsInSupabase(String phoneNumber) async {
    _ensureConnectivityMonitoringInitialized();
    if (!_isOnline) return false;

    try {
      final response = await _supabaseService.client
          .from('family_survey_sessions')
          .select('phone_number')
          .eq('phone_number', int.tryParse(phoneNumber) ?? phoneNumber)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      _escalateError('Error checking survey existence in Supabase: $e');
      return false;
    }
  }

  Future<bool> _checkVillageSurveyExistsInSupabase(String sessionId) async {
    _ensureConnectivityMonitoringInitialized();
    if (!_isOnline) return false;

    try {
      final response = await _supabaseService.client
          .from('village_survey_sessions')
          .select('session_id')
          .eq('session_id', sessionId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      _escalateError('Error checking village survey existence in Supabase: $e');
      return false;
    }
  }

  Future<void> _syncVillageSurveyToSupabase(Map<String, dynamic> survey) async {
    _ensureConnectivityMonitoringInitialized();
    if (!_isOnline) return;
    await _withSyncLock('village:${survey['session_id']}', () async {
      try {
      final sessionId = survey['session_id'];

      _emitProgress(SyncProgress(
        stage: 'village_sync',
        surveyId: sessionId?.toString(),
        message: 'Preparing village survey for sync',
      ));

      if (_supabaseService.currentUser == null) {
        final msg = 'Not authenticated. Skipping village sync.';
        _escalateError(msg, persistent: true);
        _emitProgress(SyncProgress(
          stage: 'village_sync',
          surveyId: sessionId?.toString(),
          message: msg,
          isError: true,
        ));
        return;
      }

      final schemaIssues = await _checkSchemaWithCache(_requiredVillageTables, 'village');
      if (schemaIssues.isNotEmpty) {
        final msg = 'Supabase schema issues found. Skipping village sync.';
        _escalateError(msg + ': ' + schemaIssues.toString(), persistent: true);
        _emitProgress(SyncProgress(
          stage: 'village_sync',
          surveyId: sessionId?.toString(),
          message: 'Schema validation failed for village tables',
          isError: true,
        ));
        return;
      }

      // CRITICAL FIX: Validate local save BEFORE syncing to cloud
      final localSessionData = await _databaseService.getVillageSurveySession(sessionId);
      if (localSessionData == null) {
        _escalateError('⚠ Village survey $sessionId not found locally. Skipping cloud sync.', persistent: true);
        return;
      }

      // Collect all survey data (all related tables for this session)
      _emitProgress(SyncProgress(
        stage: 'village_sync',
        surveyId: sessionId?.toString(),
        message: 'Collecting village survey data',
      ));
      final surveyData = await _collectCompleteVillageSurveyData(sessionId);

      // Verify critical data exists before syncing
      if (surveyData.isEmpty || surveyData['session_id'] == null) {
        _escalateError('✗ Village survey data incomplete for $sessionId. Not syncing.', persistent: true);
        return;
      }

      final localUpdatedAt = survey['updated_at']?.toString();
      final remoteNewer = await _isRemoteNewerVillage(sessionId, localUpdatedAt);
      if (remoteNewer) {
        await _databaseService.updateVillageSurveySyncStatus(sessionId, 'conflict');
        return;
      }

      // Sync to Supabase
      _emitProgress(SyncProgress(
        stage: 'village_sync',
        surveyId: sessionId?.toString(),
        message: 'Syncing village survey tables',
      ));
      await _supabaseService.syncVillageSurveyToSupabase(sessionId, surveyData);

      // Mark as synced locally
      await _markVillageSurveyAsSynced(sessionId);

      debugPrint('✓ Successfully synced village survey: $sessionId');
      _emitProgress(SyncProgress(
        stage: 'village_sync',
        surveyId: sessionId?.toString(),
        message: 'Village survey synced successfully',
      ));

      } catch (e) {
        _escalateError('✗ Failed to sync village survey ${survey['session_id']}: $e', persistent: true);
        _emitProgress(SyncProgress(
          stage: 'village_sync',
          surveyId: survey['session_id']?.toString(),
          message: 'Village sync failed: $e',
          isError: true,
        ));
        await queueSyncOperation('sync_village_survey', survey); 
      }
    });
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
        _escalateError('Error collecting data for table $table: $e');
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
      'tribal_questions': 'tribal_questions',
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

    final schemeInfoTables = <String>{
      'aadhaar_info',
      'ayushman_card',
      'family_id',
      'ration_card',
      'samagra_id',
      'tribal_card',
      'handicapped_allowance',
      'pension_allowance',
      'widow_allowance',
      'vb_gram',
      'pm_kisan_nidhi',
      'pm_kisan_samman_nidhi',
      'merged_govt_schemes',
    };

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
      'vb_gram_members',
      'pm_kisan_nidhi',
      'pm_kisan_members',
      'pm_kisan_samman_nidhi',
      'pm_kisan_samman_members',
      'merged_govt_schemes', // Merged table for small schemes
    ];

    for (final table in schemeTables) {
      final data = await _databaseService.getData(table, phoneNumber);
      if (data.isNotEmpty) {
        if (schemeInfoTables.contains(table)) {
          schemesData[table] = data.first;
        } else {
          schemesData[table] = data;
        }
      }
    }

    return schemesData;
  }

  /// Collect survey data with error tracking
  Future<Map<String, dynamic>> _collectCompleteSurveyDataWithTracking(String phoneNumber) async {
    final surveyData = <String, dynamic>{};
    _syncErrors.putIfAbsent(phoneNumber, () => <String>[]);
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
    final singleRowTables = <String>{
      'land_holding',
      'irrigation_facilities',
      'fertilizer_usage',
      'agricultural_equipment',
      'entertainment_facilities',
      'transport_facilities',
      'drinking_water_sources',
      'medical_treatment',
      'disputes',
      'house_conditions',
      'house_facilities',
      'social_consciousness',
      'children_data',
      'health_programmes',
      'migration_data',
      'tribal_questions',
      'tulsi_plants',
      'nutritional_garden',
    };

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
      'tribal_questions': 'tribal_questions',
      'tulsi_plants': 'tulsi_plants',
      'nutritional_garden': 'nutritional_garden',
    };

    for (final entry in dataMappings.entries) {
      try {
        final data = await _databaseService.getData(entry.key, phoneNumber);
        if (data.isNotEmpty) {
          if (singleRowTables.contains(entry.key)) {
            surveyData[entry.value] = data.first;
          } else {
            surveyData[entry.value] = data;
          }
        }
      } catch (e) {
        errors.add('Failed to fetch ${entry.key}: $e');
        _escalateError('⚠ Could not fetch ${entry.key} for $phoneNumber: $e');
      }
    }

    // Get government schemes data with tracking
    try {
      final governmentSchemes = await _collectGovernmentSchemesDataWithTracking(phoneNumber);
      surveyData.addAll(governmentSchemes);
    } catch (e) {
      errors.add('Failed to fetch government schemes: $e');
      _escalateError('⚠ Could not fetch government schemes for $phoneNumber: $e');
    }

    return surveyData;
  }

  /// Collect government schemes with error tracking
  Future<Map<String, dynamic>> _collectGovernmentSchemesDataWithTracking(String phoneNumber) async {
    final schemesData = <String, dynamic>{};
    _syncErrors.putIfAbsent(phoneNumber, () => <String>[]);
    final errors = _syncErrors[phoneNumber]!;

    final schemeInfoTables = <String>{
      'aadhaar_info',
      'ayushman_card',
      'family_id',
      'ration_card',
      'samagra_id',
      'tribal_card',
      'handicapped_allowance',
      'pension_allowance',
      'widow_allowance',
      'vb_gram',
      'pm_kisan_nidhi',
      'pm_kisan_samman_nidhi',
      'merged_govt_schemes',
    };

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
      'vb_gram_members',
      'pm_kisan_nidhi',
      'pm_kisan_members',
      'pm_kisan_samman_nidhi',
      'pm_kisan_samman_members',
      'merged_govt_schemes',
    ];

    for (final table in schemeTables) {
      try {
        final data = await _databaseService.getData(table, phoneNumber);
        if (data.isNotEmpty) {
          if (schemeInfoTables.contains(table)) {
            schemesData[table] = data.first;
          } else {
            schemesData[table] = data;
          }
        }
      } catch (e) {
        errors.add('Failed to fetch $table: $e');
        _escalateError('⚠ Could not fetch $table for $phoneNumber: $e');
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

  bool _isCriticalValidationError(String error) {
    return error.startsWith('Missing village_name') ||
        error.startsWith('Missing district') ||
        error.startsWith('Missing surveyor_email') ||
        error.startsWith('Missing family_members');
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
      _escalateError('Error marking survey as failed: $e');
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
      _escalateError('Error updating sync metadata: $e');
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
    _ensureConnectivityMonitoringInitialized();
    if (_isProcessingQueue || !_isOnline || _syncQueue.isEmpty) return;

    _isProcessingQueue = true;

    try {
      final queueCopy = List<Map<String, dynamic>>.from(_syncQueue);
      final successfulOperations = <int>[];
      final failedOperations = <int>[];

      for (int i = 0; i < queueCopy.length; i++) {
        final operation = queueCopy[i];
        try {
          await _executeQueuedOperation(operation);
          successfulOperations.add(i);
        } catch (e) {
          debugPrint('Failed to execute queued operation: $e');
          operation['retry_count'] = (operation['retry_count'] ?? 0) + 1;
          operation['last_error'] = e.toString();
          operation['last_attempt'] = DateTime.now().toIso8601String();

          // Remove from queue if max retries exceeded
          if (operation['retry_count'] >= 3) {
            failedOperations.add(i);
            _escalateError('Operation failed permanently after 3 retries: ${operation['operation']} - $e', persistent: true);
          }
        }
      }

      // Remove successful operations from queue (in reverse order to maintain indices)
      successfulOperations.sort((a, b) => b.compareTo(a));
      for (final index in successfulOperations) {
        _syncQueue.removeAt(index);
      }

      // Remove permanently failed operations
      failedOperations.sort((a, b) => b.compareTo(a));
      for (final index in failedOperations) {
        _syncQueue.removeAt(index);
      }

      // Save updated queue
      await _saveSyncQueue();

      // Report results
      if (successfulOperations.isNotEmpty) {
        debugPrint('✅ Successfully processed ${successfulOperations.length} queued operations');
      }
      if (failedOperations.isNotEmpty) {
        debugPrint('❌ Permanently failed ${failedOperations.length} queued operations');
      }

    } finally {
      _isProcessingQueue = false;
    }
  }

  Future<void> _executeQueuedOperation(Map<String, dynamic> operation) async {
    final opType = operation['operation'];
    final data = operation['data'];

    switch (opType) {
      case 'sync_village_survey':
        await _syncVillageSurveyToSupabase(data);
        break;
      case 'update_survey_data':
        await syncFamilyPageData(data['phone_number'], data['page'] ?? -1, data['data'] ?? {});
        break;
      case 'sync_family_page':
        await syncFamilyPageData(data['phone_number'], data['page'] ?? -1, data['data'] ?? {});
        break;
      case 'sync_village_page':
        await syncVillagePageData(data['session_id'], data['page'] ?? -1, data['data'] ?? {});
        break;
      default:
        throw UnsupportedError('Unknown operation: $opType');
    }
  }

  Future<void> _saveSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sync_queue', jsonEncode(_syncQueue));
      debugPrint('Sync queue saved with ${_syncQueue.length} operations');
    } catch (e) {
      _escalateError('Failed to save sync queue: $e', persistent: true);
    }
  }

  Future<void> loadSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString('sync_queue');
      if (queueJson != null && queueJson.isNotEmpty) {
        final decoded = jsonDecode(queueJson);
        if (decoded is List) {
          _syncQueue
            ..clear()
            ..addAll(decoded.whereType<Map>().map((item) =>
                item.map((k, v) => MapEntry(k.toString(), v))));
        }
      }
    } catch (e) {
      _escalateError('Failed to load sync queue: $e', persistent: true);
    }
  }

  Future<String?> _getLocalUpdatedAt(String table, String keyColumn, String keyValue) async {
    try {
      final db = await _databaseService.database;
      final results = await db.query(
        table,
        columns: ['updated_at'],
        where: '$keyColumn = ?',
        whereArgs: [keyValue],
      );
      if (results.isNotEmpty) {
        return results.first['updated_at']?.toString();
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  Future<bool> _isRemoteNewerFamily(String phoneNumber, String? localUpdatedAt) async {
    if (!_isOnline) return false;
    try {
      final remote = await _supabaseService.client
          .from('family_survey_sessions')
          .select('updated_at')
          .eq('phone_number', int.tryParse(phoneNumber) ?? phoneNumber)
          .limit(1);
      if (remote.isEmpty) return false;
      final remoteUpdatedAt = remote.first['updated_at']?.toString();
      if (remoteUpdatedAt == null || localUpdatedAt == null) return false;
      return DateTime.parse(remoteUpdatedAt).isAfter(DateTime.parse(localUpdatedAt));
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isRemoteNewerVillage(String sessionId, String? localUpdatedAt) async {
    if (!_isOnline) return false;
    try {
      final remote = await _supabaseService.client
          .from('village_survey_sessions')
          .select('updated_at')
          .eq('session_id', sessionId)
          .limit(1);
      if (remote.isEmpty) return false;
      final remoteUpdatedAt = remote.first['updated_at']?.toString();
      if (remoteUpdatedAt == null || localUpdatedAt == null) return false;
      return DateTime.parse(remoteUpdatedAt).isAfter(DateTime.parse(localUpdatedAt));
    } catch (_) {
      return false;
    }
  }

  // Public methods
  Future<void> syncVillageSurveyImmediately(String sessionId) async {
     _ensureConnectivityMonitoringInitialized();
     if (!_isOnline) {
      await queueSyncOperation('sync_village_survey', {'session_id': sessionId});
      return;
    }
    
    final survey = await _databaseService.getVillageSurveySession(sessionId);
    if (survey != null) {
      await _syncVillageSurveyToSupabase(survey);
    }
  }

  Future<bool> get isOnline async {
    // Ensure connectivity monitoring is initialized
    if (_connectivitySubscription == null) {
      await _initializeConnectivityMonitoring();
    }
    return _isOnline;
  }

  bool get isAuthenticated => _supabaseService.currentUser != null;

  Stream<bool> get connectivityStream => Connectivity().onConnectivityChanged
      .map((result) => result != ConnectivityResult.none);

  // Clear sync queue (useful for resetting stuck operations)
  Future<void> clearSyncQueue() async {
    _syncQueue.clear();
    await _saveSyncQueue();
    debugPrint('Sync queue cleared');
  }

  // Get current queue status
  List<Map<String, dynamic>> get syncQueue => List.unmodifiable(_syncQueue);

  /// Sync all pending pages for all families with progress tracking
  /// Returns progress updates showing "x/y pages synced"
  Future<void> syncAllPendingPages({
    Function(int, int)? onProgress, // (syncedCount, totalCount)
    Function(String)? onError,
  }) async {
    _ensureConnectivityMonitoringInitialized();
    if (!_isOnline) {
      onError?.call('No internet connection. Sync will be queued for when connection is restored.');
      return;
    }

    // Check authentication
    if (_supabaseService.currentUser == null) {
      onError?.call('Authentication required. Please sign in with Google to sync data.');
      throw Exception('Authentication required for syncing. Please sign in first.');
    }

    try {
      // Get all pending pages
      final pendingPages = await _databaseService.getAllPendingPages();
      
      // Collect actual page data for each pending page
      final pagesWithData = <Map<String, dynamic>>[];
      for (final pageInfo in pendingPages) {
        final phoneNumber = pageInfo['phone_number'] as String;
        final page = pageInfo['page'] as int;
        
        final pageData = await _collectFamilyPageDataFromDb(phoneNumber, page);
        if (pageData.isNotEmpty) {
          pagesWithData.add({
            'phone_number': phoneNumber,
            'page': page,
            'data': pageData,
          });
        }
      }
      if (pendingPages.isEmpty) {
        onProgress?.call(0, 0); // No pages to sync
        return;
      }

      final totalPages = pagesWithData.length;
      int syncedCount = 0;

      // Group pages by phone number for batch processing
      final pagesByPhone = <String, List<Map<String, dynamic>>>{};
      for (final page in pagesWithData) {
        final phoneNumber = page['phone_number'] as String;
        pagesByPhone.putIfAbsent(phoneNumber, () => []).add(page);
      }

      // Process each family's pages in batches
      for (final entry in pagesByPhone.entries) {
        final phoneNumber = entry.key;
        final familyPages = entry.value;

        try {
          await syncPageBatch(phoneNumber, familyPages, onPageSynced: (page, result) {
            final Map<String, dynamic> r = result is Map ? Map<String, dynamic>.from(result) : {};
            final ok = r['success'] == true;
            if (ok) {
              syncedCount++;
              onProgress?.call(syncedCount, totalPages);
            } else {
              onError?.call('Failed to sync page $page for $phoneNumber: ${r['error'] ?? 'unknown'}');
            }
          });
        } catch (e) {
          onError?.call('Failed to sync pages for $phoneNumber: $e');
        }
      }

    } catch (e) {
      onError?.call('Sync failed: $e');
      rethrow;
    }
  }

  /// Sync a batch of pages for a specific family
  Future<void> syncPageBatch(
    String phoneNumber,
    List<Map<String, dynamic>> pageDataList, {
    Function(int, dynamic)? onPageSynced,
  }) async {
    // Check if pages actually need syncing (delta sync)
    final pagesToSync = <Map<String, dynamic>>[];
    for (final pageData in pageDataList) {
      final page = pageData['page'] as int;
      final data = pageData['data'] as Map<String, dynamic>;

      if (await _pageNeedsSync(phoneNumber, page, data)) {
        pagesToSync.add(pageData);
      }
    }

    if (pagesToSync.isEmpty) {
      return; // All pages are up to date
    }

    // Perform batch sync
    final results = await _supabaseService.syncPageBatch(
      phoneNumber,
      pagesToSync,
      onPageSynced: onPageSynced,
    );

    // Update local sync status
    for (final entry in results.entries) {
      final page = entry.key as int;
      final Map<String, dynamic> resultMap = entry.value is Map ? Map<String, dynamic>.from(entry.value as Map) : {};
      final success = resultMap['success'] == true;

      if (success) {
        await _databaseService.updatePageSyncStatus(phoneNumber, page, 'synced');
        await _databaseService.updatePageLastSyncedAt(phoneNumber, page);
        final pageData = pageDataList.firstWhere((p) => (p['page'] is int ? p['page'] as int : int.tryParse(p['page'].toString()) ?? -1) == page)['data'];
        await _databaseService.updatePageDataHash(phoneNumber, page, _calculateDataHash(pageData));
      } else {
        await _databaseService.updatePageSyncStatus(phoneNumber, page, 'failed');
      }
    }
  }

  /// Check if a page needs syncing based on data hash comparison
  Future<bool> _pageNeedsSync(String phoneNumber, int page, Map<String, dynamic> data) async {
    final currentHash = await _databaseService.getPageDataHash(phoneNumber, page);
    final newHash = _calculateDataHash(data);

    return currentHash != newHash;
  }

  /// Get sync progress summary
  Future<Map<String, dynamic>> getSyncProgressSummary() async {
    final totalPages = await _databaseService.getTotalPagesCount();
    final syncedPages = await _databaseService.getTotalSyncedPagesCount();
    final pendingPages = await _databaseService.getAllPendingPages().then((pages) => pages.length);

    return {
      'total_pages': totalPages,
      'synced_pages': syncedPages,
      'pending_pages': pendingPages,
      'progress_percentage': totalPages > 0 ? (syncedPages / totalPages * 100).round() : 0,
    };
  }

  // Cleanup
  void dispose() {
    _connectivitySubscription?.cancel();
    try {
      if (!_progressController.isClosed) _progressController.close();
    } catch (_) {}
  }
}