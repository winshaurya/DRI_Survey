import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'supabase_service.dart';

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
      'training_needs',
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

/// This method has been simplified to mirror the village survey protocol.
  ///
  /// Instead of syncing a single page, we collect the *entire* family survey
  /// from the local database and push it in one shot.  This keeps the remote
  /// logic identical to the village flow and avoids a huge switch statement.
  /// Sync a single page of the family survey to Supabase.
  ///
  /// This mirrors the village protocol: each page is uploaded separately
  /// (along with a lightweight session row).  In case of offline/auth
  /// failures the operation is queued as `sync_family_page`; the queue
  /// executor calls back into [_upsertFamilyPage] when connectivity returns.
  /// Upsert the given page data to the appropriate family table(s) on Supabase.
  /// This mirrors the logic used when saving locally in [SurveyNotifier]._savePageDataToDatabase.
  Future<void> _upsertFamilyPage(String phoneNumber, int page, Map<String, dynamic> data) async {
    // phoneNumber already normalized by caller
    final phoneKey = int.tryParse(phoneNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? phoneNumber;
    phoneNumber = phoneKey.toString();

    // remote‑newer check (based on session row) to avoid overwriting newer cloud record
    final localUpdatedAt = await _getLocalUpdatedAt('family_survey_sessions', 'phone_number', phoneNumber);
    final remoteNewer = await _isRemoteNewerFamily(phoneNumber, localUpdatedAt);
    if (remoteNewer) {
      await _markSurveyAsFailed(phoneNumber, ['REMOTE_NEWER']);
      throw Exception('Remote copy newer, skipping page sync');
    }

    // Only upsert session row on page 0; page0 already triggers ensureFamilySessionExists,
    // so further page syncs no longer attempt it (avoids RLS recursion errors).
    if (page == 0) {
      try {
        await _supabaseService.saveFamilyData('family_survey_sessions', {
          'phone_number': phoneNumber,
          'status': 'in_progress',
          'surveyor_email': _supabaseService.currentUser?.email ?? 'unknown',
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('warning: failed to upsert session row for $phoneNumber: $e');
      }
    }

    List<MapEntry<String, Map<String, dynamic>>> toUpload = [];

    switch (page) {
      case 0:
        // page0 data is already the session payload
        final payload = Map<String, dynamic>.from(data);
        payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('family_survey_sessions', payload));
        break;
      case 1:
        if (data['family_members'] is List) {
          for (var item in data['family_members']) {
            if (item is Map) {
              final map = Map<String, dynamic>.from(item);
              map['phone_number'] = phoneNumber;
              toUpload.add(MapEntry('family_members', map));
            }
          }
        }
        break;
      case 2:
      case 3:
      case 4:
        final payload = Map<String, dynamic>.from(data)..['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('social_consciousness', payload));
        break;
      case 5:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('land_holding', payload));
        break;
      case 6:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('irrigation_facilities', payload));
        break;
      case 7:
        if (data is Map && data['crop_productivity'] is List) {
          for (var crop in data['crop_productivity']) {
            if (crop is Map) {
              final m = Map<String, dynamic>.from(crop);
              m['phone_number'] = phoneNumber;
              toUpload.add(MapEntry('crop_productivity', m));
            }
          }
        }
        break;
      case 8:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('fertilizer_usage', payload));
        break;
      case 9:
        if (data is Map && data['animals'] is List) {
          for (var animal in data['animals']) {
            if (animal is Map) {
              final m = Map<String, dynamic>.from(animal);
              m['phone_number'] = phoneNumber;
              toUpload.add(MapEntry('animals', m));
            }
          }
        }
        break;
      case 10:
        if (data is Map && data['agricultural_equipment'] is List) {
          for (var item in data['agricultural_equipment']) {
            if (item is Map) {
              final m = Map<String, dynamic>.from(item);
              m['phone_number'] = phoneNumber;
              toUpload.add(MapEntry('agricultural_equipment', m));
            }
          }
        }
        break;
      case 11:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('entertainment_facilities', payload));
        break;
      case 12:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('transport_facilities', payload));
        break;
      case 13:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('drinking_water_sources', payload));
        break;
      case 14:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('medical_treatment', payload));
        break;
      case 15:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('disputes', payload));
        break;
      case 16:
        // may include both house_conditions and house_facilities maps
        if (data['house_conditions'] is Map) {
          final m = Map<String, dynamic>.from(data['house_conditions']);
          m['phone_number'] = phoneNumber;
          toUpload.add(MapEntry('house_conditions', m));
        }
        if (data['house_facilities'] is Map) {
          final m = Map<String, dynamic>.from(data['house_facilities']);
          m['phone_number'] = phoneNumber;
          toUpload.add(MapEntry('house_facilities', m));
        }
        break;
      case 17:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('diseases', payload));
        break;
      case 18:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('government_schemes', payload));
        break;
      case 19:
        // folklore_medicine may be stored as list under different keys
        Map<String, dynamic> payload = {};
        if (data['folklore_medicine'] != null) payload['folklore_medicine'] = data['folklore_medicine'];
        if (data['folklore_medicines'] != null) payload['folklore_medicine'] = data['folklore_medicines'];
        payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('folklore_medicine', payload));
        break;
      case 20:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('health_programmes', payload));
        break;
      case 21:
        if (data['children'] is List) {
          for (var item in data['children']) {
            if (item is Map) {
              final m = Map<String, dynamic>.from(item);
              m['phone_number'] = phoneNumber;
              toUpload.add(MapEntry('children_data', m));
            }
          }
        }
        break;
      case 22:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('migration_data', payload));
        break;
      case 23:
        // training programs already taken (training_data) and training requests (training_needs)
        if (data is Map && data['training_data'] is List) {
          for (var item in data['training_data']) {
            if (item is Map) {
              final m = Map<String, dynamic>.from(item);
              m['phone_number'] = phoneNumber;
              toUpload.add(MapEntry('training_data', m));
            }
          }
        } else {
          final payload = Map<String, dynamic>.from(data);
          payload['phone_number'] = phoneNumber;
          toUpload.add(MapEntry('training_data', payload));
        }

        if (data is Map && data['training_needs'] is List) {
          for (var item in data['training_needs']) {
            if (item is Map) {
              final m = Map<String, dynamic>.from(item);
              m['phone_number'] = phoneNumber;
              toUpload.add(MapEntry('training_needs', m));
            }
          }
        }
        break;
      case 24:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('vb_gram', payload));
        break;
      case 25:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('pm_kisan_nidhi', payload));
        break;
      case 26:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('pm_kisan_samman_nidhi', payload));
        break;
      case 27:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('kisan_credit_card', payload));
        break;
      case 28:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('swachh_bharat_mission', payload));
        break;
      case 29:
        final payload = Map<String, dynamic>.from(data); payload['phone_number'] = phoneNumber;
        toUpload.add(MapEntry('fasal_bima', payload));
        break;
      case 30:
        if (data['bank_accounts'] is List) {
          for (var item in data['bank_accounts']) {
            if (item is Map) {
              final m = Map<String, dynamic>.from(item);
              m['phone_number'] = phoneNumber;
              toUpload.add(MapEntry('bank_accounts', m));
            }
          }
        }
        break;
      default:
        // nothing to do
        break;
    }

    // perform upserts sequentially (mirroring generic sync concurrency pattern is unnecessary here)
    for (var entry in toUpload) {
      await _supabaseService.saveFamilyData(entry.key, entry.value);
    }
  }

  Future<void> syncFamilyPageData(String phoneNumber, int page, Map<String, dynamic> data) async {
    _ensureConnectivityMonitoringInitialized();
    if (phoneNumber.isEmpty || page < 0) return;

    // normalize phone number to numeric to satisfy supabase PKs
    final phoneKey = int.tryParse(phoneNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? phoneNumber;
    phoneNumber = phoneKey.toString();

    await _withSyncLock('family:$phoneNumber', () async {
      final connectivityResult = await Connectivity().checkConnectivity();
      final currentlyOnline = connectivityResult != ConnectivityResult.none;
      _isOnline = currentlyOnline;

      debugPrint('[SyncService] syncFamilyPageData online=$currentlyOnline user=${_supabaseService.currentUser?.email} page=$page');

      // When offline or unauthenticated, queue just the page operation
      if (!currentlyOnline || _supabaseService.currentUser == null) {
        debugPrint('[SyncService] queueing family page sync, online=$currentlyOnline, user=${_supabaseService.currentUser?.email}');
        await queueSyncOperation('sync_family_page', {
          'phone_number': phoneNumber,
          'page': page,
          'data': data,
        });
        return;
      }

      try {
        await _upsertFamilyPage(phoneNumber, page, data);
        await _databaseService.markFamilyPageSynced(phoneNumber, page);
      } catch (e) {
        _escalateError('Family page $page sync failed for $phoneNumber: $e', persistent: true);
        // fallback: attempt to queue full survey, but guard against schema errors
        try {
          final surveyData = await _collectCompleteSurveyData(phoneNumber);
          await queueSyncOperation('sync_family_survey', {
            'phone_number': phoneNumber,
            'data': surveyData,
          });
        } catch (e2) {
          _escalateError('Fallback collect failed for $phoneNumber: $e2', persistent: true);
        }
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

  List<String> getErrorsForSurvey(String phoneNumber) =>
      List<String>.from(_syncErrors[phoneNumber] ?? const []);

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
        final msg = 'No authenticated user; proceeding with anon key for village sync';
        debugPrint('[SyncService] $msg');
        // continue without returning
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

      // finished
      } catch (e) {
        _escalateError('Error during village sync: $e', persistent: true);
      }
    });
  }

  // -----------------------------------------------------------------------
  // Family survey generic sync follows the same pattern as village
  Future<void> syncFamilySurveyToSupabase(String phoneNumber) async {
    _ensureConnectivityMonitoringInitialized();
    try {
      final survey = await _databaseService.getSurveySession(phoneNumber);
      if (survey == null) {
        _escalateError('Survey not found for phoneNumber: $phoneNumber', persistent: true);
        return;
      }

      if (!_isOnline) {
        await queueSyncOperation('sync_family_survey', survey);
        return;
      }

      await _syncFamilySurveyToSupabase(survey);
    } catch (e) {
      _escalateError('Error syncing family survey: $e', persistent: true);
    }
  }

  Future<void> _syncFamilySurveyToSupabase(Map<String, dynamic> survey) async {
    _ensureConnectivityMonitoringInitialized();
    if (!_isOnline) return;
    final phone = survey['phone_number']?.toString();
    await _withSyncLock('family:$phone', () async {
      try {
        _emitProgress(SyncProgress(
          stage: 'family_sync',
          surveyId: phone,
          message: 'Preparing family survey for sync',
        ));

        if (_supabaseService.currentUser == null) {
          final msg = 'No authenticated user; proceeding with anon key';
          debugPrint('[SyncService] $msg');
          // we do not return; allow sync to continue using anon access
        }

        final schemaIssues = await _checkSchemaWithCache(_requiredFamilyTables, 'family');
        if (schemaIssues.isNotEmpty) {
          final msg = 'Supabase schema issues found. Skipping family sync.';
          _escalateError(msg + ': ' + schemaIssues.toString(), persistent: true);
          _emitProgress(SyncProgress(
            stage: 'family_sync',
            surveyId: phone,
            message: 'Schema validation failed for family tables',
            isError: true,
          ));
          return;
        }

        // ensure local record still exists
        final localSession = await _databaseService.getSurveySession(phone!);
        if (localSession == null) {
          _escalateError('⚠ Family survey $phone not found locally. Skipping cloud sync.', persistent: true);
          return;
        }

        _emitProgress(SyncProgress(
          stage: 'family_sync',
          surveyId: phone,
          message: 'Collecting family survey data',
        ));
        final surveyData = await _collectCompleteSurveyData(phone);

        if (surveyData.isEmpty || surveyData['phone_number'] == null) {
          _escalateError('✗ Family survey data incomplete for $phone. Not syncing.', persistent: true);
          return;
        }

        final localUpdatedAt = survey['updated_at']?.toString();
        final remoteNewer = await _isRemoteNewerFamily(phone, localUpdatedAt);
        if (remoteNewer) {
          await _markSurveyAsFailed(phone, ['REMOTE_NEWER']);
          return;
        }

        _emitProgress(SyncProgress(
          stage: 'family_sync',
          surveyId: phone,
          message: 'Syncing family survey tables',
        ));
        final success = await _supabaseService.syncFamilySurveyToSupabase(phone, surveyData);
        if (!success) {
          await _markSurveyAsFailed(phone, ['SYNC_FAILURE']);
          _escalateError('Family survey sync returned false for $phone', persistent: true);
          return;
        }

        await _markFamilySurveyAsSynced(phone);
      } catch (e) {
        _escalateError('Error during family sync: $e', persistent: true);
      }
    });
  }

  Future<void> _markVillageSurveyAsSynced(String sessionId) async {
    await _databaseService.updateVillageSurveySyncStatus(sessionId, 'synced');
  }

  Future<void> _markFamilySurveyAsSynced(String phoneNumber) async {
    await _databaseService.updateSurveyStatus(phoneNumber, 'synced');
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

    // Get all related data (failures for individual tables are caught)
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
      'training_needs': 'training_needs',
      'shg_members': 'shg_members',
      'fpo_members': 'fpo_members',
      'bank_accounts': 'bank_accounts',
      'tribal_questions': 'tribal_questions',
      // Note: tulsi_plants and nutritional_garden are stored in house_facilities table
    };

    for (final entry in dataMappings.entries) {
      try {
        final data = await _databaseService.getData(entry.key, phoneNumber);
        if (data.isNotEmpty) {
          surveyData[entry.value] = data;
        }
      } catch (e) {
        _escalateError('Failed to read ${entry.key} for $phoneNumber: $e');
      }
    }

    // Get government schemes data (tracked for errors)
    final governmentSchemes = await _collectGovernmentSchemesDataWithTracking(phoneNumber);
    surveyData.addAll(governmentSchemes);

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






  // Queue operations for when network returns. Pass `highPriority: true` to
  // insert the operation at the front of the queue so it runs before others.
  Future<void> queueSyncOperation(String operation, Map<String, dynamic> data, {bool highPriority = false}) async {
    final entry = {
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'retry_count': 0,
    };

    if (highPriority) {
      _syncQueue.insert(0, entry);
    } else {
      _syncQueue.add(entry);
    }

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
      case 'sync_family_survey':
        await _syncFamilySurveyToSupabase(data);
        break;
      case 'sync_family_page':
        final phone = data['phone_number']?.toString() ?? '';
        final page = data['page'] is int ? data['page'] as int : -1;
        final pageData = data['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(data['data'])
            : <String, dynamic>{};
        if (phone.isNotEmpty && page >= 0) {
          await _upsertFamilyPage(phone, page, pageData);
        }
        break;
      case 'ensure_family_session':
        final phone = data['phone_number']?.toString() ?? '';
        final extra = data['extra'] is Map<String, dynamic> ? Map<String, dynamic>.from(data['extra']) : null;
        if (phone.isNotEmpty) {
          // Only attempt when online and authenticated; ensureFamilySessionExists will
          // queue again if conditions aren't met.
          await _supabaseService.ensureFamilySessionExists(phone, extra: extra);
        }
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

  /// Synchronize all pending family surveys to Supabase.  The previous
  /// implementation synced individual pages; the new protocol uploads the
  /// entire survey in one shot. Progress callbacks count surveys rather than
  /// pages.
  Future<void> syncAllPendingPages({
    Function(int, int)? onProgress, // (syncedCount, totalCount)
    Function(String)? onError,
  }) async {
    _ensureConnectivityMonitoringInitialized();
    if (!_isOnline) {
      onError?.call('No internet connection. Sync will be queued for when connection is restored.');
      return;
    }

    if (_supabaseService.currentUser == null) {
      onError?.call('Authentication required. Please sign in before syncing.');
      throw Exception('Authentication required for syncing.');
    }

    try {
      final pendingSurveys = await _getPendingSurveys();
      final total = pendingSurveys.length;
      int syncedCount = 0;

      for (final survey in pendingSurveys) {
        final phone = survey['phone_number']?.toString();
        if (phone == null || phone.isEmpty) continue;
        try {
          await syncFamilySurveyToSupabase(phone);
          syncedCount++;
          onProgress?.call(syncedCount, total);
        } catch (e) {
          onError?.call('Failed to sync survey $phone: $e');
        }
      }
    } catch (e) {
      onError?.call('Sync failed: $e');
      rethrow;
    }
  }




  // Cleanup
  void dispose() {
    _connectivitySubscription?.cancel();
    try {
      if (!_progressController.isClosed) _progressController.close();
    } catch (_) {}
  }
}