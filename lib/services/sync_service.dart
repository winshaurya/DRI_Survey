import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'supabase_service.dart';

class SyncProgress {
  final String stage;
  final String? message;
  final bool isError;
  final int syncedCount;
  final int totalTables;
  final int failedCount;

  const SyncProgress({
    required this.stage,
    this.message,
    this.isError = false,
    this.syncedCount = 0,
    this.totalTables = 0,
    this.failedCount = 0,
  });
}

// Task representing a single table sync operation
class SyncTask {
  final String referenceId; // phone_number or session_id
  final String table;
  final String type; // 'family' or 'village'
  int retryCount;

  SyncTask({
    required this.referenceId,
    required this.table,
    required this.type,
    this.retryCount = 0,
  });
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  static SyncService get instance => _instance;

  final DatabaseService _databaseService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  // Connection monitoring
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = false;
  
  // Queue management
  final List<SyncTask> _syncQueue = [];
  bool _isProcessingQueue = false;

  // Stream for UI updates
  final StreamController<SyncProgress> _progressController = StreamController<SyncProgress>.broadcast();
  Stream<SyncProgress> get progressStream => _progressController.stream;

  bool get isSyncing => _isProcessingQueue;

  // --- HARDCODED TABLE LISTS (Based on Schema) ---
  
  static const List<String> _familyTables = [
    'family_survey_sessions', // PARENT - MUST BE FIRST
    'aadhaar_info', 'aadhaar_scheme_members', 'agricultural_equipment', 'animals', 
    'ayushman_card', 'ayushman_scheme_members', 'bank_accounts', 'child_diseases', 
    'children_data', 'crop_productivity', 'diseases', 'disputes', 'drinking_water_sources', 
    'entertainment_facilities', 'family_id', 'family_id_scheme_members', 'family_members', 
    'fertilizer_usage', 'folklore_medicine', 'fpo_members', 'handicapped_allowance', 
    'handicapped_scheme_members', 'health_programmes', 'house_conditions', 'house_facilities', 
    'irrigation_facilities', 'land_holding', 'malnourished_children_data', 
    'medical_treatment', 'merged_govt_schemes', 'migration_data', 'nutritional_garden', 
    'pension_allowance', 'pension_scheme_members', 'pm_kisan_members', 'pm_kisan_nidhi', 
    'pm_kisan_samman_members', 'pm_kisan_samman_nidhi', 'ration_card', 'ration_scheme_members', 
    'samagra_id', 'samagra_scheme_members', 'shg_members', 'social_consciousness', 
    'training_data', 'training_needs', 'transport_facilities', 'tribal_card', 
    'tribal_questions', 'tribal_scheme_members', 'vb_gram', 'vb_gram_members', 
    'widow_allowance', 'widow_scheme_members'
  ];

  static const List<String> _villageTables = [
    'village_survey_sessions', // PARENT - MUST BE FIRST
    'village_agricultural_implements', 'village_animals', 'village_biodiversity_register', 
    'village_bpl_families', 'village_cadastral_maps', 'village_children_data', 
    'village_crop_productivity', 'village_disputes', 'village_drainage_waste', 
    'village_drinking_water', 'village_educational_facilities', 'village_entertainment', 
    'village_farm_families', 'village_forest_maps', 'village_housing', 'village_infrastructure', 
    'village_infrastructure_details', 'village_irrigation_facilities', 'village_kitchen_gardens', 
    'village_malnutrition_data', 'village_map_points', 'village_medical_treatment', 
    'village_population', 'village_seed_clubs', 'village_signboards', 'village_social_consciousness', 
    'village_social_maps', 'village_survey_details', 'village_traditional_occupations', 
    'village_transport_facilities', 'village_unemployment'
  ];

  int get _familyTableTotal => _familyTables.length;
  int get _villageTableTotal => _villageTables.length;

  // Identifies tables that use composite primary keys.
  // Supabase upsert requires knowing the conflict columns if they differ from the default PK.
  // Most 'members' tables use (phone_number, sr_no).
  static const Map<String, String> _compositeKeyTables = {
    'aadhaar_info': 'phone_number',
    'aadhaar_scheme_members': 'phone_number, sr_no',
    'animals': 'phone_number, sr_no',
    'ayushman_scheme_members': 'phone_number, sr_no',
    'bank_accounts': 'phone_number, sr_no',
    'child_diseases': 'phone_number, sr_no',
    'crop_productivity': 'phone_number, sr_no',
    'diseases': 'phone_number, sr_no',
    'family_id_scheme_members': 'phone_number, sr_no',
    'family_members': 'phone_number, sr_no',
    'handicapped_scheme_members': 'phone_number, sr_no',
    'pension_scheme_members': 'phone_number, sr_no',
    'pm_kisan_members': 'phone_number, sr_no',
    'pm_kisan_samman_members': 'phone_number, sr_no',
    
    // Additional tables identified from schema
    'ration_scheme_members': 'phone_number, sr_no',
    'samagra_scheme_members': 'phone_number, sr_no',
    'training_needs': 'phone_number, sr_no',
    'tribal_scheme_members': 'phone_number, sr_no',
    'vb_gram_members': 'phone_number, sr_no',
    'widow_scheme_members': 'phone_number, sr_no',
    'shg_members': 'phone_number, member_name',
    'village_map_points': 'session_id, point_id',
    'fpo_members': 'phone_number, sr_no',
    'malnourished_children_data': 'phone_number, sr_no',
    'migration_data': 'phone_number, sr_no',

    // Village Tables with SR_NO
    'village_animals': 'session_id, sr_no',
    'village_crop_productivity': 'session_id, sr_no',
    'village_malnutrition_data': 'session_id, sr_no',
    'village_traditional_occupations': 'session_id, sr_no'
  };

  SyncService._internal() {
    _initConnectionListener();
    _databaseService.ensureSyncTable(); // Ensure tracking table exists
  }

  void _initConnectionListener() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      bool wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      // Auto-trigger sync when network returns
      if (wasOffline && _isOnline) {
        debugPrint('[SyncService] Network restored. Auto-triggering sync.');
        syncAllPendingData();
      }
    });

    if (_isOnline) {
       // Optional: Auto-sync on startup
       // syncAllPendingData(); 
    }
  }

  Future<bool> get isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  bool get isAuthenticated => _supabaseService.currentUser != null;


  // --- MAIN SYNC FUNCTION ---
  
  // Method expected by SupabaseService for manual queuing of operations.
  // Adapts 'ensure_family_session' requests to standard table sync tasks.
  Future<void> queueSyncOperation(
    String operation, 
    Map<String, dynamic> params,
    {bool highPriority = false}
  ) async {
    debugPrint('[SyncService] queueSyncOperation called: $operation');
    
    if (operation == 'ensure_family_session') {
      final phone = params['phone_number']?.toString();
      if (phone != null) {
        // Just trigger sync for family sessions table for this phone
        _addToQueue(SyncTask(
          referenceId: phone, 
          table: 'family_survey_sessions', 
          type: 'family',
          retryCount: highPriority ? -1 : 0 // Lower retry count gives priority? No logic yet.
        ));
        
        // If high priority, maybe force process queue?
        if (highPriority && _isOnline) {
          _processQueue();
        }
      }
    } else {
        // Fallback: full sync
        syncAllPendingData(highPriority: highPriority);
    }
  }

  Future<void> syncAllPendingData({
    Function(int, int)? onProgress, 
    Function(String)? onError,
    bool highPriority = false,
  }) async {
    if (!_isOnline) {
      debugPrint('[SyncService] Offline. Skipping sync.');
      onError?.call('Offline. Sync skipped.');
      return;
    }
    
    if (_isProcessingQueue) {
      debugPrint('[SyncService] Already syncing. Skipping trigger.');
      return;
    }

    // Reset any leftover queue to avoid reprocessing stale tasks.
    _syncQueue.clear();

    _progressController.add(const SyncProgress(stage: 'start', message: 'Starting sync...'));

    try {
      // 1. Get all sessions
      final familySessions = await _databaseService.getAllSurveySessions();
      final villageSessions = await _databaseService.getAllVillageSurveySessions();

      debugPrint('[SyncService] Found ${familySessions.length} family sessions, ${villageSessions.length} village sessions local.');

      // Seed sync tracker entries so progress UI can count pending/failed/synced per session.
      for (final session in familySessions) {
        final phone = session['phone_number'].toString();
        await _databaseService.seedSyncTracker(phone, _familyTables);
      }
      for (final session in villageSessions) {
        final id = session['session_id'].toString();
        await _databaseService.seedSyncTracker(id, _villageTables);
      }

      // 2. Queue Family Data
      for (final session in familySessions) {
        final phone = session['phone_number'].toString();
        // Check local sync status map first to avoid unnecessary DB calls if possible? 
        // No, user wants robust check.
        await _queueSessionData('family', phone, _familyTables);
      }

      // 3. Queue Village Data
      for (final session in villageSessions) {
        final id = session['session_id'].toString();
        await _queueSessionData('village', id, _villageTables);
      }

      debugPrint('[SyncService] Queued ${_syncQueue.length} items. Starting process...');
      
      // 4. Process
      await _processQueue();
      
      onProgress?.call(100, 100);
      _progressController.add(const SyncProgress(stage: 'complete', message: 'Sync completed'));

    } catch (e) {
      debugPrint('[SyncService] FATAL ERROR in syncAllPendingData: $e');
      onError?.call(e.toString());
      _progressController.add(SyncProgress(stage: 'error', message: e.toString(), isError: true));
    }
  }

  // --- QUEUE LOGIC ---

  Future<void> _queueSessionData(String type, String id, List<String> tables) async {
    // Ensure tracker rows exist for this session before enqueuing.
    await _databaseService.seedSyncTracker(id, tables);

    // 1. Check Parent Status First
    final parentTable = tables.first; // Convention: First item is parent
    final parentStatus = await _databaseService.getTableSyncStatus(id, parentTable);
    
    if (parentStatus != 'synced') {
      // Parent not synced? Queue ONLY parent first. Children depend on it.
      _addToQueue(SyncTask(referenceId: id, table: parentTable, type: type));
      return; 
    }

    // 2. If parent synced, check all children
    for (final table in tables) {
      if (table == parentTable) continue; // Already checked

      final status = await _databaseService.getTableSyncStatus(id, table);
      if (status == 'synced') continue;

      // Double check: Does local data exist? (Don't sync empty tables if no data)
      if (await _hasLocalData(table, id, type)) {
        _addToQueue(SyncTask(referenceId: id, table: table, type: type));
      } else {
        // If there is no local data to send, mark as synced so progress math stays correct.
        await _databaseService.updateTableSyncStatus(id, table, 'synced');
      }
    }
  }

  void _addToQueue(SyncTask task) {
    // Avoid duplicates in current queue
    final exists = _syncQueue.any((t) => 
      t.referenceId == task.referenceId && t.table == task.table
    );
    if (!exists) {
      _syncQueue.add(task);
    }
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;
    _progressController.add(const SyncProgress(stage: 'start', message: 'Starting queue processing...'));

    int syncedCount = 0;
    int failedCount = 0;

    // Use loop with index 0 to process as queue
    while (_syncQueue.isNotEmpty && _isOnline) {
      if (!_isOnline) break;
      final task = _syncQueue.first;
      int currentTotal = syncedCount + failedCount + _syncQueue.length;
      
      try {
        _progressController.add(SyncProgress(
          stage: 'syncing', 
          message: 'Syncing ${task.table}...',
          syncedCount: syncedCount,
          totalTables: currentTotal,
          failedCount: failedCount
        ));
        debugPrint('[SyncService] Processing: ${task.type} ${task.referenceId} -> ${task.table}');
        await _databaseService.updateTableSyncStatus(task.referenceId, task.table, 'pending');
        
        // 1. Fetch Data
        final data = await _fetchDataForTable(task);
        if (data == null || (data is List && data.isEmpty)) {
           // No data actually found? Mark synced so we don't retry.
           await _databaseService.updateTableSyncStatus(task.referenceId, task.table, 'synced');
           syncedCount++; // Ideally count as success
           _syncQueue.removeAt(0);
           continue;
        }

        // 2. Upsert to Supabase
        await _performUpsert(task, data);

        // 3. Mark Success
        await _databaseService.updateTableSyncStatus(task.referenceId, task.table, 'synced');
        
        // Update parent timestamp for UI
        if ((task.table == 'family_survey_sessions' || task.table == 'village_survey_sessions')) {
           final db = await _databaseService.database;
           String keyCol = task.type == 'family' ? 'phone_number' : 'session_id';
           await db.update(
              task.table, 
              {'last_synced_at': DateTime.now().toIso8601String()},
              where: '$keyCol = ?',
              whereArgs: [task.referenceId]
           );
        }

        debugPrint('[SyncService] SUCCESS: ${task.table}');
        syncedCount++;
        _syncQueue.removeAt(0);
        
        // If Parent Succeded -> Trigger immediate check for children? 
        if (task.table == 'family_survey_sessions' || task.table == 'village_survey_sessions') {
           final tableList = task.type == 'family' ? _familyTables : _villageTables;
           await _queueSessionData(task.type, task.referenceId, tableList);
        }

      } catch (e) {
        debugPrint('[SyncService] FAILED: ${task.table} Error: $e');
        
        task.retryCount++;
        if (task.retryCount >= 3) {
           await _databaseService.updateTableSyncStatus(task.referenceId, task.table, 'failed', error: e.toString());
           failedCount++;
           _syncQueue.removeAt(0); // Move ahead
        } else {
            await _databaseService.updateTableSyncStatus(task.referenceId, task.table, 'pending', error: e.toString());
           _syncQueue.removeAt(0);
           _syncQueue.add(task); // Move to end (retry later)
        }
      }
    }

    _isProcessingQueue = false;
    _progressController.add(SyncProgress(
      stage: 'complete', 
      message: 'Queue processing complete',
      syncedCount: syncedCount,
      totalTables: syncedCount + failedCount,
      failedCount: failedCount
    ));
  }

  // --- DATA HELPERS ---

  Future<bool> _hasLocalData(String table, String id, String type) async {
    final db = await _databaseService.database;
    // Determine key column
    String keyCol = type == 'family' ? 'phone_number' : 'session_id';
    try {
      if (keyCol == 'phone_number') {
        final key = int.tryParse(id) ?? id; 
        final res = await db.query(table, where: 'phone_number = ?', whereArgs: [key], limit: 1);
        return res.isNotEmpty;
      } else {
        final res = await db.query(table, where: 'session_id = ?', whereArgs: [id], limit: 1);
        return res.isNotEmpty;
      }
    } catch (e) {
      debugPrint('[SyncService] _hasLocalData skipped table=$table (likely missing locally): $e');
      return false;
    }
  }

  Future<dynamic> _fetchDataForTable(SyncTask task) async {
    final db = await _databaseService.database;
    String keyCol = task.type == 'family' ? 'phone_number' : 'session_id';
    dynamic keyVal = task.referenceId;
    if (task.type == 'family') keyVal = int.tryParse(task.referenceId) ?? task.referenceId;
    try {
      final res = await db.query(task.table, where: '$keyCol = ?', whereArgs: [keyVal]);
      return res;
    } catch (e) {
      debugPrint('[SyncService] _fetchDataForTable skipped table=${task.table} (missing locally?): $e');
      return null;
    }
  }

  Future<void> _performUpsert(SyncTask task, dynamic data) async {
    // Reuse the normalized, column-filtered upsert with retries
    // from SupabaseService to avoid schema mismatch errors.
    await _supabaseService.upsertNormalized(task.table, data);
  }
  
  // -- COMPATIBILITY METHODS ---

  Future<void> syncAllPendingPages({
    Function(int, int)? onProgress,
    Function(String)? onError,
  }) async {
    syncAllPendingData(onProgress: onProgress, onError: onError);
  }

  // queueSyncOperation is implemented above.
  
  Future<void> syncVillageSurveyImmediately(String sessionId) async {
    await _queueSessionData('village', sessionId, _villageTables);
    await syncAllPendingData();
  }
  
  Future<void> syncFamilySurveyToSupabase(String phone) async => syncAllPendingData(); // Will queue this specific one eventually
  Future<void> syncVillageSurveyToSupabase(String id) async => syncAllPendingData();
  
  Future<void> syncFamilyPageData(String phone, int page, Map<String, dynamic> data) async {}
  Future<void> syncVillagePageData(String id, int page, Map<String, dynamic> data) async {}

  Future<Map<String, int>> getSessionSyncSummary(String referenceId) async {
    return _databaseService.getSyncSummary(referenceId);
  }

  /// Returns totals for UI progress bars (total, synced, failed, pending) per session.
  Future<Map<String, int>> getSessionProgress(String referenceId, String type) async {
    final totals = await _databaseService.getSyncSummary(referenceId);
    final synced = totals['synced'] ?? 0;
    final failed = totals['failed'] ?? 0;
    final totalTables = type == 'family' ? _familyTableTotal : _villageTableTotal;
    final pendingCalc = totalTables - synced - failed;
    final pending = pendingCalc < 0 ? 0 : pendingCalc;
    return {
      'total': totalTables,
      'synced': synced,
      'failed': failed,
      'pending': pending,
    };
  }


  void dispose() {
    _connectivitySubscription?.cancel();
    _progressController.close();
  }
}
