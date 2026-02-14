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

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
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
    await db.delete(
      'family_survey_sessions',
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
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
    final results = await db.query(
      'family_survey_sessions',
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
    );
    return results.isNotEmpty ? results.first : null;
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
      whereArgs: [phoneNumber],
    );
  }

  Future<void> updateSurveySyncStatus(String phoneNumber, String syncStatus) async {
    final db = await database;
    // Update family_survey_sessions with sync status
    await db.update(
      'family_survey_sessions',
      {
        'sync_status': syncStatus,
        'last_synced_at': syncStatus == 'synced' ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
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
    await db.delete(
      tableName,
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
    );
  }

  Future<List<Map<String, dynamic>>> getData(String tableName, String phoneNumber) async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
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
  Future<void> insertOrUpdate(String tableName, Map<String, dynamic> data, String sessionId) async {
    final db = await database;
    final columns = await _getTableColumns(db, tableName);
    if (sessionId.isEmpty) {
      throw Exception('session_id is required for $tableName');
    }
    // Check if record exists
    final existing = await db.query(
      tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    final now = DateTime.now().toIso8601String();
    final dataWithTimestamp = <String, dynamic>{
      ...data,
      'session_id': sessionId,
    };
    if (columns.contains('updated_at')) {
      dataWithTimestamp['updated_at'] = now;
    }
    // Filter to known columns only
    final filteredData = Map<String, dynamic>.fromEntries(
      dataWithTimestamp.entries.where((e) => columns.contains(e.key))
    );
    try {
      if (existing.isEmpty) {
        // Insert new
        if (columns.contains('created_at')) {
          filteredData['created_at'] = now;
        }
        await db.insert(tableName, filteredData);
      } else {
        // Update existing
        await db.update(
          tableName,
          filteredData,
          where: 'session_id = ?',
          whereArgs: [sessionId],
        );
      }
    } catch (e) {
      // Surface DB errors for troubleshooting
      rethrow;
    }
  }

  Future<Set<String>> _getTableColumns(Database db, String tableName) async {
    final info = await db.rawQuery('PRAGMA table_info($tableName)');
    return info
        .map((row) => row['name']?.toString())
        .whereType<String>()
        .toSet();
  }
}
