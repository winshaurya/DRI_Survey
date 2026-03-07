import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import 'hardcoded_remote_columns.dart';
import 'hardcoded_primary_keys.dart';

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

  Future<String> _resolveReferenceKeyColumn(Database db, String tableName) async {
    final pkCols = kHardcodedRemotePrimaryKeys[tableName] ?? const <String>[];
    if (pkCols.contains('phone_number')) return 'phone_number';
    if (pkCols.contains('session_id')) return 'session_id';

    final columns = await _getTableColumns(db, tableName);
    if (columns.contains('phone_number')) return 'phone_number';
    if (columns.contains('session_id')) return 'session_id';

    // Last-resort fallback for legacy/auxiliary tables.
    return 'phone_number';
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
    final keyColumn = await _resolveReferenceKeyColumn(db, tableName);
    final keyValue = keyColumn == 'phone_number'
        ? (int.tryParse(phoneNumber) ?? phoneNumber)
        : phoneNumber;
    await db.delete(
      tableName,
      where: '$keyColumn = ?',
      whereArgs: [keyValue],
    );
  }

  Future<List<Map<String, dynamic>>> getData(String tableName, String phoneNumber) async {
    final db = await database;
    final keyColumn = await _resolveReferenceKeyColumn(db, tableName);
    final keyValue = keyColumn == 'phone_number'
        ? (int.tryParse(phoneNumber) ?? phoneNumber)
        : phoneNumber;
    try {
      return await db.query(
        tableName,
        where: '$keyColumn = ?',
        whereArgs: [keyValue],
      );
    } catch (e) {
      // Table might not exist (migration pending) - log and return empty
      print('DB getData error for $tableName: $e');
      return <Map<String, dynamic>>[];
    }
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
      entry['completed'] = completed ? 1 : 0;
    }
    if (synced != null) {
      entry['synced'] = synced ? 1 : 0;
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
        final completed = value['completed'] == 1;
        final synced = value['synced'] == 1;
        if (completed && !synced) {
          return true;
        }
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

    final parsedPhone = int.tryParse(keyValue) ?? keyValue;
    final hasPhone = columns.contains('phone_number');
    final hasSession = columns.contains('session_id');
    final String? referenceColumn = hasPhone
        ? 'phone_number'
        : (hasSession ? 'session_id' : null);
    final dynamic referenceValue = hasPhone ? parsedPhone : keyValue;

    final normalizedData = <String, dynamic>{...data};
    if (hasPhone) {
      normalizedData['phone_number'] = parsedPhone;
    } else if (hasSession) {
      normalizedData['session_id'] = keyValue;
    }

    // Determine primary lookup columns using source-of-truth PK map,
    // but only keep PK columns that actually exist in local SQLite schema.
    final hardcodedPkCols = kHardcodedRemotePrimaryKeys[tableName] ?? const <String>[];
    final effectivePkCols = hardcodedPkCols
        .where((c) => columns.contains(c))
        .toList(growable: true);

    if (hardcodedPkCols.isNotEmpty && effectivePkCols.length != hardcodedPkCols.length) {
      final missingPk = hardcodedPkCols.where((c) => !columns.contains(c)).toList();
      debugPrint('insertOrUpdate($tableName): local schema missing PK columns $missingPk; using $effectivePkCols');
    }

    // If table PK includes sr_no and caller omitted it, allocate next sr_no for the same family/session.
    if (effectivePkCols.contains('sr_no')) {
      final srRaw = normalizedData['sr_no'];
      final srMissing = srRaw == null || (srRaw is String && srRaw.trim().isEmpty);
      if (srMissing) {
        int nextSr = 1;
        if (referenceColumn != null) {
          final maxRows = await db.rawQuery(
            'SELECT MAX(sr_no) AS max_sr FROM $tableName WHERE $referenceColumn = ?',
            [referenceValue],
          );
          final maxSr = (maxRows.isNotEmpty ? maxRows.first['max_sr'] : null) as num?;
          nextSr = (maxSr?.toInt() ?? 0) + 1;
        } else {
          final maxRows = await db.rawQuery('SELECT MAX(sr_no) AS max_sr FROM $tableName');
          final maxSr = (maxRows.isNotEmpty ? maxRows.first['max_sr'] : null) as num?;
          nextSr = (maxSr?.toInt() ?? 0) + 1;
        }
        normalizedData['sr_no'] = nextSr;
      } else if (srRaw is String) {
        normalizedData['sr_no'] = int.tryParse(srRaw) ?? srRaw;
      } else if (srRaw is num) {
        normalizedData['sr_no'] = srRaw.toInt();
      }
    }

    String existenceWhere;
    List<dynamic> existenceArgs = [];

    if (effectivePkCols.isNotEmpty) {
      final args = <dynamic>[];
      bool canUseAllPk = true;
      for (final c in effectivePkCols) {
        dynamic value;
        if (c == 'phone_number') {
          value = parsedPhone;
        } else if (c == 'session_id') {
          value = keyValue;
        } else {
          value = normalizedData[c];
        }

        if (value == null) {
          canUseAllPk = false;
          break;
        }
        args.add(value);
      }

      if (canUseAllPk) {
        existenceWhere = effectivePkCols.map((c) => '$c = ?').join(' AND ');
        existenceArgs = args;
      } else {
        if (referenceColumn == null) {
          throw Exception('Missing PK values for $tableName and no phone_number/session_id fallback available');
        }
        if (columns.contains('sr_no') && normalizedData['sr_no'] != null) {
          existenceWhere = '$referenceColumn = ? AND sr_no = ?';
          existenceArgs = [referenceValue, normalizedData['sr_no']];
        } else {
          existenceWhere = '$referenceColumn = ?';
          existenceArgs = [referenceValue];
        }
      }
    } else {
      if (referenceColumn == null) {
        throw Exception('No recognized key column for $tableName (expected phone_number or session_id)');
      }

      final bool hasSr = columns.contains('sr_no');
      final bool dataHasSr = normalizedData.containsKey('sr_no') && normalizedData['sr_no'] != null;

      existenceWhere = hasSr && dataHasSr ? '$referenceColumn = ? AND sr_no = ?' : '$referenceColumn = ?';
      existenceArgs = hasSr && dataHasSr ? [referenceValue, normalizedData['sr_no']] : [referenceValue];
    }

    // Check if record exists using computed where-clause
    final existing = await db.query(
      tableName,
      where: existenceWhere,
      whereArgs: existenceArgs,
      limit: 1,
    );

    final now = DateTime.now().toIso8601String();
    final dataWithTimestamp = <String, dynamic>{
      ...normalizedData,
    };
    // Ensure primary id columns are present in payload when local table contains them.
    if (effectivePkCols.isNotEmpty) {
      for (final c in effectivePkCols) {
        if (c == 'phone_number' || c == 'session_id') {
          final parsed = c == 'phone_number' ? (int.tryParse(keyValue) ?? keyValue) : keyValue;
          dataWithTimestamp[c] = parsed;
        } else if (!dataWithTimestamp.containsKey(c) && normalizedData[c] != null) {
          dataWithTimestamp[c] = normalizedData[c];
        }
      }
    } else {
      if (columns.contains('phone_number')) {
        dataWithTimestamp['phone_number'] = int.tryParse(keyValue) ?? keyValue;
      } else if (columns.contains('session_id')) {
        dataWithTimestamp['session_id'] = keyValue;
      }
    }
    if (columns.contains('updated_at')) {
      dataWithTimestamp['updated_at'] = now;
    }

    // Filter to known columns only
    // Filter to known local columns then order keys to follow remote schema order when available
    final rawFiltered = Map<String, dynamic>.fromEntries(
      dataWithTimestamp.entries.where((e) => columns.contains(e.key)),
    );

    final ordered = <String, dynamic>{};
    final remoteCols = kHardcodedRemoteTableColumns[tableName] ?? columns.toList();
    for (final col in remoteCols) {
      if (rawFiltered.containsKey(col)) ordered[col] = rawFiltered[col];
    }
    // Append any remaining local columns not present in remote list
    for (final e in rawFiltered.entries) {
      if (!ordered.containsKey(e.key)) ordered[e.key] = e.value;
    }
    final filteredData = ordered;

    // Normalize complex values (Maps/Lists) to JSON strings so sqflite can store them
    for (final key in filteredData.keys.toList()) {
      final value = filteredData[key];
      if (value is Map || value is List) {
        try {
          filteredData[key] = jsonEncode(value);
        } catch (_) {
          // If encoding fails, fall back to string conversion
          filteredData[key] = value.toString();
        }
      }
    }

    try {
      if (existing.isEmpty) {
        // Insert new (use replace on conflict to avoid UNIQUE constraint errors
        // if a race or type mismatch causes a duplicate key insert attempt).
        if (columns.contains('created_at')) {
          filteredData['created_at'] = now;
        }
        await db.insert(tableName, filteredData, conflictAlgorithm: ConflictAlgorithm.replace);
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
      // Surface DB errors for troubleshooting with schema + payload context
      try {
        final info = await db.rawQuery('PRAGMA table_info($tableName)');
        final cols = info.map((r) => r['name']?.toString()).whereType<String>().toList();
        print('DB error on insertOrUpdate -> table: $tableName, columns: $cols');
        print('Payload keys: ${filteredData.keys.toList()}');
        print('Payload snapshot: $filteredData');
      } catch (schemaErr) {
        print('Failed to fetch PRAGMA for $tableName: $schemaErr');
      }
      rethrow;
    }
  }

  Future<void> ensureSyncTable() async {
    final db = await database;
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sync_tracker (
          reference_key TEXT,
          table_name TEXT,
          status TEXT,
          last_attempt TEXT,
          error_message TEXT,
          PRIMARY KEY (reference_key, table_name)
        )
      ''');
      debugPrint('[DatabaseService] ✅ Sync tracker table ensured');
    } catch (e) {
      debugPrint('[DatabaseService] ⚠️  Failed to create sync_tracker table: $e');
    }
  }

  /// Seed sync_tracker rows for a given session with provided tables as 'pending'.
  Future<void> seedSyncTracker(String referenceId, List<String> tables) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();
    int newSeeds = 0;
    
    for (final t in tables) {
      batch.insert(
        'sync_tracker',
        {
          'reference_key': referenceId,
          'table_name': t,
          'status': 'pending',
          'last_attempt': now,
          'error_message': null,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      newSeeds++;
    }
    
    await batch.commit(noResult: true);
    debugPrint('[DatabaseService] 🌱 Seeded $newSeeds table trackers for $referenceId');
  }

  /// Updates the sync status for a specific table of a specific session/family
  Future<void> updateTableSyncStatus(String referenceId, String tableName, String status, {String? error}) async {
    final db = await database;
    final row = {
      'reference_key': referenceId,
      'table_name': tableName,
      'status': status,
      'last_attempt': DateTime.now().toIso8601String(),
      'error_message': error
    };
    await db.insert('sync_tracker', row, conflictAlgorithm: ConflictAlgorithm.replace);
    
    if (status == 'failed' && error != null) {
      debugPrint('[DatabaseService] ❌ Table sync failed: $tableName for $referenceId');
      debugPrint('[DatabaseService]    Error: ${error.length > 100 ? error.substring(0, 100) + "..." : error}');
    } else if (status == 'synced') {
      debugPrint('[DatabaseService] ✅ Table sync success: $tableName for $referenceId');
    } else if (status == 'pending') {
      debugPrint('[DatabaseService] 🔄 Table sync pending: $tableName for $referenceId');
    }
  }

  /// Gets the sync status for a specific table
  Future<String> getTableSyncStatus(String referenceId, String tableName) async {
    final db = await database;
    final res = await db.query('sync_tracker', 
      columns: ['status'], 
      where: 'reference_key = ? AND table_name = ?',
      whereArgs: [referenceId, tableName]
    );
    if (res.isNotEmpty) return res.first['status'] as String;
    return 'pending';
  }

  /// Returns counts of pending/synced/failed for a session across all tables.
  Future<Map<String, int>> getSyncSummary(String referenceKey) async {
    final db = await database;
    try {
      final rows = await db.rawQuery(
        'SELECT status, COUNT(*) as count FROM sync_tracker WHERE reference_key = ? GROUP BY status',
        [referenceKey],
      );
      final summary = {'pending': 0, 'synced': 0, 'failed': 0};
      for (final r in rows) {
        final s = r['status']?.toString() ?? 'pending';
        final c = (r['count'] as int?) ?? 0;
        summary[s] = c;
      }
      
      debugPrint('[DatabaseService] 📊 Sync summary for $referenceKey: ${summary["synced"]} synced, ${summary["pending"]} pending, ${summary["failed"]} failed');
      return summary;
    } catch (e) {
      debugPrint('[DatabaseService] ⚠️  Failed to get sync summary for $referenceKey: $e');
      return {'pending': 0, 'synced': 0, 'failed': 0};
    }
  }

  // --- NEW METHODS FOR HISTORY SCREEN ---
  
  Future<Map<String, int>> getSyncDetailStats(String referenceKey) async {
    final db = await database;
    try {
      final res = await db.rawQuery('SELECT status, COUNT(*) as count FROM sync_tracker WHERE reference_key = ? GROUP BY status', [referenceKey]);
      
      final stats = {'pending': 0, 'synced': 0, 'failed': 0};
      if (res.isNotEmpty) {
        for (var row in res) {
           final status = row['status'].toString();
           final count = row['count'] as int;
           stats[status] = count;
        }
      }
      return stats;
    } catch (_) {
      return {'pending': 0, 'synced': 0, 'failed': 0};
    }
  }

  Future<List<String>> getFailedTables(String referenceKey) async {
    final db = await database;
    final res = await db.query('sync_tracker', 
      columns: ['table_name'], 
      where: 'reference_key = ? AND status = ?',
      whereArgs: [referenceKey, 'failed']
    );
    return res.map((e) => e['table_name'] as String).toList();
  }
}

