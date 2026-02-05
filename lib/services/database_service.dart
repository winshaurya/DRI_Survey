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
        'last_synced_at': status == 'completed' ? DateTime.now().toIso8601String() : null
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
        'status': syncStatus,
        'last_synced_at': syncStatus == 'synced' ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
    );
  }

  Future<void> updateVillageSurveySyncStatus(String sessionId, String syncStatus) async {
    final db = await database;
    // Update village_survey_sessions with sync status
    await db.update(
      'village_survey_sessions',
      {
        'status': syncStatus,
        'last_synced_at': syncStatus == 'synced' ? DateTime.now().toIso8601String() : null,
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
      where: 'last_synced_at IS NULL OR status != "synced"',
    );
  }

  // Get unsynced village surveys
  Future<List<Map<String, dynamic>>> getUnsyncedVillageSurveys() async {
    final db = await database;
    return await db.query(
      'village_survey_sessions',
      where: 'last_synced_at IS NULL OR status != "synced"',
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


  Future<List<Map<String, dynamic>>> getVillageData(String tableName, String sessionId) async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }
}
