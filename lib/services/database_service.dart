import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await DatabaseHelper().database;
    return _database!;
  }

  Future<Set<String>> _getTableColumns(Database db, String tableName) async {
    try {
      final info = await db.rawQuery('PRAGMA table_info($tableName)');
      return info
          .map((row) => row['name']?.toString())
          .whereType<String>()
          .toSet();
    } catch (e) {
      return <String>{};
    }
  }


  Future<void> saveVillageDrainageWaste(String sessionId, Map<String, dynamic> drainageData) async {
    final db = await database;
    await db.insert(
      'village_drainage_waste',
      {'session_id': sessionId, ...drainageData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSurveySession(String phoneNumber) async {
    final db = await database;
    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    await db.delete(
      'family_survey_sessions',
      where: 'phone_number = ?',
      whereArgs: [pk],
    );
  }

  Future<int> createNewSurveyRecord(Map<String, dynamic> surveyData) async {
    final db = await database;
    return await db.insert(
      'family_survey_sessions',
      surveyData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllVillageSurveySessions() async {
    final db = await database;
    return await db.query('village_survey_sessions', orderBy: 'created_at ASC');
  }

  Future<List<Map<String, dynamic>>> getAllSurveySessions() async {
    final db = await database;
    return await db.query('family_survey_sessions', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getSurveySession(String phoneNumber) async {
    final db = await database;
    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    final results = await db.query(
      'family_survey_sessions',
      where: 'phone_number = ?',
      whereArgs: [pk],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateSurveySession(String phoneNumber, Map<String, dynamic> data) async {
    final db = await database;
    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    await db.update(
      'family_survey_sessions',
      {
        ...data,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'phone_number = ?',
      whereArgs: [pk],
    );
  }

  Future<void> updatePageStatus(String phoneNumber, int page, bool completed) async {
    await _updatePageStatus(
      tableName: 'family_survey_sessions',
      keyColumn: 'phone_number',
      keyValue: phoneNumber,
      page: page,
      completed: completed,
    );
  }

  Future<void> updateSurveyStatus(String phoneNumber, String status) async {
    final db = await database;
    await db.update(
      'family_survey_sessions',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'phone_number = ?',
      whereArgs: [int.tryParse(phoneNumber) ?? phoneNumber],
    );
  }

  Future<void> updateSurveySyncStatus(String phoneNumber, String syncStatus) async {
    final db = await database;
    // Update family_survey_sessions with sync status
    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    await db.update(
      'family_survey_sessions',
      {
        'sync_status': syncStatus,
        'last_synced_at': syncStatus == 'synced' ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'phone_number = ?',
      whereArgs: [pk],
    );
  }

  Future<void> markFamilyPageCompleted(String phoneNumber, int page) async {
    await _updatePageStatus(
      tableName: 'family_survey_sessions',
      keyColumn: 'phone_number',
      keyValue: phoneNumber,
      page: page,
      completed: true,
      synced: null,
    );
  }

  Future<void> markFamilyPageSynced(String phoneNumber, int page) async {
    await _updatePageStatus(
      tableName: 'family_survey_sessions',
      keyColumn: 'phone_number',
      keyValue: phoneNumber,
      page: page,
      completed: true,
      synced: true,
    );
  }

  Future<void> markVillagePageCompleted(String sessionId, int page) async {
    await _updatePageStatus(
      tableName: 'village_survey_sessions',
      keyColumn: 'session_id',
      keyValue: sessionId,
      page: page,
      completed: true,
      synced: null,
    );
  }

  Future<void> markVillagePageSynced(String sessionId, int page) async {
    await _updatePageStatus(
      tableName: 'village_survey_sessions',
      keyColumn: 'session_id',
      keyValue: sessionId,
      page: page,
      completed: true,
      synced: true,
    );
  }

  Future<Map<String, dynamic>> getFamilyPageStatus(String phoneNumber) async {
    return _getPageStatus(
      tableName: 'family_survey_sessions',
      keyColumn: 'phone_number',
      keyValue: phoneNumber,
    );
  }

  Future<Map<String, dynamic>> getVillagePageStatus(String sessionId) async {
    return _getPageStatus(
      tableName: 'village_survey_sessions',
      keyColumn: 'session_id',
      keyValue: sessionId,
    );
  }

  Future<List<Map<String, dynamic>>> getIncompleteFamilySurveys() async {
    final db = await database;
    return await db.query(
      'family_survey_sessions',
      where: 'status = ? OR sync_pending = 1',
      whereArgs: ['in_progress'],
      orderBy: 'updated_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getIncompleteVillageSurveys() async {
    final db = await database;
    return await db.query(
      'village_survey_sessions',
      where: 'status = ? OR sync_pending = 1',
      whereArgs: ['in_progress'],
      orderBy: 'updated_at DESC',
    );
  }

  Future<void> updateVillageSurveySyncStatus(String sessionId, String syncStatus) async {
    final db = await database;
    // Update village_survey_sessions with sync status
    await db.update(
      'village_survey_sessions',
      {
        'sync_status': syncStatus,
        'last_synced_at': syncStatus == 'synced' ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> updateVillageSurveySession(String sessionId, Map<String, dynamic> data) async {
    final db = await database;
    await db.update(
      'village_survey_sessions',
      {
        ...data,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> saveData(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(tableName, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteByPhone(String tableName, String phoneNumber) async {
    final db = await database;
    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    await db.delete(
      tableName,
      where: 'phone_number = ?',
      whereArgs: [pk],
    );
  }

  Future<List<Map<String, dynamic>>> getData(String tableName, String phoneNumber) async {
    final db = await database;
    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    return await db.query(
      tableName,
      where: 'phone_number = ?',
      whereArgs: [pk],
    );
  }

  // Get all unsynced family surveys for sync operations
  Future<List<Map<String, dynamic>>> getUnsyncedFamilySurveys() async {
    final db = await database;
    return await db.query(
      'family_survey_sessions',
      where: 'last_synced_at IS NULL OR sync_status != "synced"',
    );
  }

  // Get unsynced village surveys
  Future<List<Map<String, dynamic>>> getUnsyncedVillageSurveys() async {
    final db = await database;
    return await db.query(
      'village_survey_sessions',
      where: 'last_synced_at IS NULL OR sync_status != "synced"',
    );
  }

  // Village survey specific methods
  String? _currentSessionId;

  String? get currentSessionId => _currentSessionId;
  set currentSessionId(String? id) => _currentSessionId = id;

  Future<void> createNewVillageSurveySession(Map<String, dynamic> sessionData) async {
    final db = await database;
    await db.insert(
      'village_survey_sessions',
      sessionData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (sessionData.containsKey('session_id')) {
      _currentSessionId = sessionData['session_id'];
    }
  }

  Future<Map<String, dynamic>?> getVillageSurveySession(String sessionId) async {
    final db = await database;
    final results = await db.query(
      'village_survey_sessions',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> _updatePageStatus({
    required String tableName,
    required String keyColumn,
    required String keyValue,
    required int page,
    bool? completed,
    bool? synced,
  }) async {
    final db = await database;
    final results = await db.query(
      tableName,
      columns: ['page_completion_status'],
      where: '$keyColumn = ?',
      whereArgs: [keyValue],
    );

    final existingRaw = results.isNotEmpty ? results.first['page_completion_status'] as String? : null;
    final statusMap = _decodePageStatus(existingRaw);

    final pageKey = page.toString();
    final entry = Map<String, dynamic>.from(statusMap[pageKey] ?? {});
    if (completed != null) {
      entry['completed'] = completed;
    }
    if (synced != null) {
      entry['synced'] = synced;
    }
    statusMap[pageKey] = entry;

    final syncPending = _hasPendingSync(statusMap) ? 1 : 0;

    await db.update(
      tableName,
      {
        'page_completion_status': jsonEncode(statusMap),
        'sync_pending': syncPending,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: '$keyColumn = ?',
      whereArgs: [keyValue],
    );
  }

  Future<Map<String, dynamic>> _getPageStatus({
    required String tableName,
    required String keyColumn,
    required String keyValue,
  }) async {
    final db = await database;
    final results = await db.query(
      tableName,
      columns: ['page_completion_status', 'sync_pending'],
      where: '$keyColumn = ?',
      whereArgs: [keyValue],
    );
    if (results.isEmpty) return {};
    final row = results.first;
    return {
      'page_completion_status': _decodePageStatus(row['page_completion_status'] as String?),
      'sync_pending': row['sync_pending'] ?? 0,
    };
  }

  Map<String, dynamic> _decodePageStatus(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      // ignore and fallback
    }
    return {};
  }

  bool _hasPendingSync(Map<String, dynamic> statusMap) {
    for (final entry in statusMap.entries) {
      final value = entry.value;
      if (value is Map) {
        final completed = value['completed'] == true;
        final synced = value['synced'] == true;
        if (completed && !synced) {
          return true;
        }
      } else if (value == true) {
        // Legacy format: completed but no sync flag means pending
        return true;
      }
    }
    return false;
  }



  Future<List<Map<String, dynamic>>> getVillageData(String tableName, String sessionId) async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  // Get village survey by shine_code (PRIMARY KEY)
  Future<Map<String, dynamic>?> getVillageSurveyByShineCode(String shineCode) async {
    final db = await database;
    final results = await db.query(
      'village_survey_sessions',
      where: 'shine_code = ?',
      whereArgs: [shineCode],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Get village screen data by shine_code or session_id
  Future<List<Map<String, dynamic>>> getVillageScreenData(String identifier, String tableName) async {
    final db = await database;
    
    // Try shine_code first, fallback to session_id
    var results = await db.query(
      tableName,
      where: 'shine_code = ?',
      whereArgs: [identifier],
    );
    
    if (results.isEmpty) {
      results = await db.query(
        tableName,
        where: 'session_id = ?',
        whereArgs: [identifier],
      );
    }
    
    return results;
  }

  // Create village survey session
  /// Creates a new village survey session, ensuring DB is ready and required fields are present.
  Future<void> createVillageSurveySession(Map<String, dynamic> sessionData) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final data = {
      ...sessionData,
      'created_at': sessionData['created_at'] ?? now,
      'updated_at': now,
    };
    if (data['session_id'] == null || (data['session_id'] as String).isEmpty) {
      throw Exception('session_id is required for village survey session');
    }
    try {
      await db.insert(
        'village_survey_sessions',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _currentSessionId = data['session_id'];
    } catch (e) {
      // Surface DB errors for troubleshooting
      rethrow;
    }
  }

  // Update village survey status
  Future<void> updateVillageSurveyStatus(String sessionId, String status) async {
    final db = await database;
    await db.update(
      'village_survey_sessions',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  // Insert or update village survey data
  /// Insert or update a record for a village survey table. Ensures DB is ready, required fields present, and errors are surfaced.
  Future<void> insertOrUpdate(String tableName, Map<String, dynamic> data, String keyValue) async {
    final db = await database;
    final columns = await _getTableColumns(db, tableName);
    if (keyValue.isEmpty) {
      throw Exception('key value is required for $tableName');
    }

    // Determine primary lookup column for this table (phone_number for family, session_id for village)
    String keyColumn;
    if (columns.contains('phone_number')) {
      keyColumn = 'phone_number';
    } else if (columns.contains('session_id')) {
      keyColumn = 'session_id';
    } else {
      throw Exception('No recognized key column for $tableName (expected phone_number or session_id)');
    }

    // Use composite key when table has sr_no and caller provided it
    final bool hasSr = columns.contains('sr_no');
    final bool dataHasSr = data is Map<String, dynamic> && data.containsKey('sr_no');

    final String existenceWhere = hasSr && dataHasSr ? '$keyColumn = ? AND sr_no = ?' : '$keyColumn = ?';
    final List<dynamic> existenceArgs = hasSr && dataHasSr ? [keyValue, data['sr_no']] : [keyValue];

    // Check if record exists using computed where-clause
    final existing = await db.query(
      tableName,
      where: existenceWhere,
      whereArgs: existenceArgs,
      limit: 1,
    );

    final now = DateTime.now().toIso8601String();
    final dataWithTimestamp = <String, dynamic>{
      ...data,
      keyColumn: keyValue,
    };
    if (columns.contains('updated_at')) {
      dataWithTimestamp['updated_at'] = now;
    }

    // Filter to known columns only
    final filteredData = Map<String, dynamic>.fromEntries(
      dataWithTimestamp.entries.where((e) => columns.contains(e.key)),
    );

    try {
      if (existing.isEmpty) {
        // Insert new
        if (columns.contains('created_at')) {
          filteredData['created_at'] = now;
        }
        await db.insert(tableName, filteredData);
      } else {
        // Update existing using same composite where if applicable
        await db.update(
          tableName,
          filteredData,
          where: existenceWhere,
          whereArgs: existenceArgs,
        );
      }
    } catch (e) {
      // Surface DB errors for troubleshooting
      rethrow;
    }
  }

  // ===========================================
  // PAGE-LEVEL SYNC STATUS MANAGEMENT
  // ===========================================

  Future<void> updatePageSyncStatus(String phoneNumber, int pageIndex, String status) async {
    final db = await database;
    final currentStatus = await _getPageSyncStatusMap(phoneNumber);
    currentStatus['page_$pageIndex'] = status;

    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    await db.update(
      'family_survey_sessions',
      {'page_sync_status': jsonEncode(currentStatus)},
      where: 'phone_number = ?',
      whereArgs: [pk],
    );
  }

  Future<String?> getPageSyncStatus(String phoneNumber, int pageIndex) async {
    final statusMap = await _getPageSyncStatusMap(phoneNumber);
    return statusMap['page_$pageIndex'];
  }

  Future<Map<String, String>> _getPageSyncStatusMap(String phoneNumber) async {
    final db = await database;
    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    final results = await db.query(
      'family_survey_sessions',
      columns: ['page_sync_status'],
      where: 'phone_number = ?',
      whereArgs: [pk],
    );

    if (results.isEmpty) return {};

    final rawStatus = results.first['page_sync_status'] as String?;
    if (rawStatus == null || rawStatus.isEmpty) return {};

    try {
      final decoded = jsonDecode(rawStatus) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  Future<List<int>> getPendingPages(String phoneNumber) async {
    final statusMap = await _getPageSyncStatusMap(phoneNumber);
    final pendingPages = <int>[];

    for (int i = 0; i < 32; i++) {
      final status = statusMap['page_$i'];
      if (status == null || status == 'pending' || status == 'failed') {
        pendingPages.add(i);
      }
    }

    return pendingPages;
  }

  Future<int> getSyncedPagesCount(String phoneNumber) async {
    final statusMap = await _getPageSyncStatusMap(phoneNumber);
    int count = 0;

    for (int i = 0; i < 32; i++) {
      if (statusMap['page_$i'] == 'synced') {
        count++;
      }
    }

    return count;
  }

  // ===========================================
  // DATA HASH MANAGEMENT FOR DELTA SYNC
  // ===========================================

  Future<void> updatePageDataHash(String phoneNumber, int pageIndex, String hash) async {
    final db = await database;
    final currentHashes = await _getPageDataHashesMap(phoneNumber);
    currentHashes['page_$pageIndex'] = hash;

    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    await db.update(
      'family_survey_sessions',
      {'page_data_hashes': jsonEncode(currentHashes)},
      where: 'phone_number = ?',
      whereArgs: [pk],
    );
  }

  Future<String?> getPageDataHash(String phoneNumber, int pageIndex) async {
    final hashesMap = await _getPageDataHashesMap(phoneNumber);
    return hashesMap['page_$pageIndex'];
  }

  Future<Map<String, String>> _getPageDataHashesMap(String phoneNumber) async {
    final db = await database;
    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    final results = await db.query(
      'family_survey_sessions',
      columns: ['page_data_hashes'],
      where: 'phone_number = ?',
      whereArgs: [pk],
    );

    if (results.isEmpty) return {};

    final rawHashes = results.first['page_data_hashes'] as String?;
    if (rawHashes == null || rawHashes.isEmpty) return {};

    try {
      final decoded = jsonDecode(rawHashes) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  // ===========================================
  // SYNC TIMESTAMP MANAGEMENT
  // ===========================================

  Future<void> updatePageLastSyncedAt(String phoneNumber, int pageIndex) async {
    final db = await database;
    final currentTimestamps = await _getPageLastSyncedAtMap(phoneNumber);
    currentTimestamps['page_$pageIndex'] = DateTime.now().toIso8601String();

    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    await db.update(
      'family_survey_sessions',
      {'page_last_synced_at': jsonEncode(currentTimestamps)},
      where: 'phone_number = ?',
      whereArgs: [pk],
    );
  }

  Future<String?> getPageLastSyncedAt(String phoneNumber, int pageIndex) async {
    final timestampsMap = await _getPageLastSyncedAtMap(phoneNumber);
    return timestampsMap['page_$pageIndex'];
  }

  Future<Map<String, String>> _getPageLastSyncedAtMap(String phoneNumber) async {
    final db = await database;
    final pk = int.tryParse(phoneNumber) ?? phoneNumber;
    final results = await db.query(
      'family_survey_sessions',
      columns: ['page_last_synced_at'],
      where: 'phone_number = ?',
      whereArgs: [pk],
    );

    if (results.isEmpty) return {};

    final rawTimestamps = results.first['page_last_synced_at'] as String?;
    if (rawTimestamps == null || rawTimestamps.isEmpty) return {};

    try {
      final decoded = jsonDecode(rawTimestamps) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  /// Get total count of all pages across all surveys
  Future<int> getTotalPagesCount() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT COUNT(*) as total
      FROM (
        SELECT json_extract(page_sync_status, '\$.page_count') as page_count
        FROM family_survey_sessions
        WHERE page_sync_status IS NOT NULL
      )
    ''');

    int total = 0;
    for (final result in results) {
      final pageCount = result['total'] as int? ?? 0;
      total += pageCount;
    }
    return total;
  }

  /// Get count of synced pages across all families
  Future<int> getTotalSyncedPagesCount() async {
    final db = await database;
    final results = await db.query('family_survey_sessions');

    int totalSynced = 0;
    for (final row in results) {
      final phoneNumber = row['phone_number'] as String;
      totalSynced += await getSyncedPagesCount(phoneNumber);
    }
    return totalSynced;
  }

  /// Get list of all pending pages that need syncing across all families
  Future<List<Map<String, dynamic>>> getAllPendingPages() async {
    final db = await database;
    final results = await db.query('family_survey_sessions');

    final pendingPages = <Map<String, dynamic>>[];

    for (final row in results) {
      final phoneNumber = row['phone_number'] as String;
      final pageSyncStatusRaw = row['page_sync_status'] as String?;

      if (pageSyncStatusRaw != null) {
        try {
          final pageSyncStatus = jsonDecode(pageSyncStatusRaw) as Map<String, dynamic>;
          final pageCount = pageSyncStatus['page_count'] as int? ?? 0;

          for (int page = 1; page <= pageCount; page++) {
            final pageKey = 'page_$page';
            final status = pageSyncStatus[pageKey] as String?;

            if (status != 'synced') {
              // Get page data using the sync service method
              // For now, return basic info and let sync service handle data collection
              pendingPages.add({
                'phone_number': phoneNumber,
                'page': page,
                'data': {}, // Will be populated by sync service
              });
            }
          }
        } catch (e) {
          // Skip malformed data
          continue;
        }
      }
    }

    return pendingPages;
  }
}
