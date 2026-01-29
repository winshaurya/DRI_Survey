import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:universal_html/html.dart' as html;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  // Simple in-memory store for web to avoid sqflite usage.
  static final Map<String, List<Map<String, dynamic>>> _webStore = {};

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // For web, we'll use a different approach or skip database operations
      throw UnsupportedError('Database operations not supported on web platform');
    }

    // Use the proper database path for each platform
    String path;
    if (Platform.isAndroid) {
      // For Android, use the databases directory
      final databasesPath = await getDatabasesPath();
      path = join(databasesPath, 'family_survey.db');
    } else if (Platform.isIOS) {
      // For iOS, use application documents directory
      final directory = await getApplicationDocumentsDirectory();
      path = join(directory.path, 'family_survey.db');
    } else {
      // For other platforms, use application documents directory
      final directory = await getApplicationDocumentsDirectory();
      path = join(directory.path, 'family_survey.db');
    }

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Read and execute the schema.sql file
    final schemaContent = await _loadSchema();
    final statements = schemaContent.split(';').where((s) => s.trim().isNotEmpty);

    for (final statement in statements) {
      if (statement.trim().isNotEmpty) {
        await db.execute(statement.trim());
      }
    }
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add sync fields to family_survey_sessions
      try {
        await db.execute('ALTER TABLE family_survey_sessions ADD COLUMN is_deleted INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE family_survey_sessions ADD COLUMN last_synced_at TEXT');
      } catch (e) {
        // Ignore if columns already exist
        print('Error upgrading family_survey_sessions: $e');
      }

      // Add sync fields to family_members
      try {
        await db.execute('ALTER TABLE family_members ADD COLUMN is_deleted INTEGER DEFAULT 0');
      } catch (e) {
        print('Error upgrading family_members: $e');
      }

      // Add sync fields to village_survey_sessions
      try {
        await db.execute('ALTER TABLE village_survey_sessions ADD COLUMN is_deleted INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE village_survey_sessions ADD COLUMN last_synced_at TEXT');
      } catch (e) {
        print('Error upgrading village_survey_sessions: $e');
      }

      // Add sync fields to village_population
      try {
        await db.execute('ALTER TABLE village_population ADD COLUMN is_deleted INTEGER DEFAULT 0');
      } catch (e) {
        print('Error upgrading village_population: $e');
      }
    }
  }

  Future<String> _loadSchema() async {
    // Load the authoritative schemas from database_supabase_sqlite folder
    // This ensures SQLite follows the same schema as Supabase

    final familySchema = await _loadSchemaFile('database_supabase_sqlite/family_survey_schema.sql');
    final villageSchema = await _loadSchemaFile('database_supabase_sqlite/village_survey_schema.sql');

    // Convert Supabase-specific syntax to SQLite-compatible syntax
    final sqliteFamilySchema = _convertToSQLiteSchema(familySchema);
    final sqliteVillageSchema = _convertToSQLiteSchema(villageSchema);

    return '''
-- DRI Survey App Database Schema
-- Holy Grail Base Directory: database_supabase_sqlite/
-- SQLite-compatible version of Supabase schemas

-- Enable foreign keys for SQLite
PRAGMA foreign_keys = ON;

$sqliteFamilySchema

$sqliteVillageSchema
''';
  }

  Future<String> _loadSchemaFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        throw Exception('Schema file not found: $path');
      }
    } catch (e) {
      // Fallback to embedded schema if file loading fails
      return _getFallbackSchema();
    }
  }

  String _convertToSQLiteSchema(String supabaseSchema) {
    // Convert Supabase-specific syntax to SQLite
    return supabaseSchema
        // Remove Supabase extensions
        .replaceAll(RegExp(r'CREATE EXTENSION.*?;'), '')
        // Convert UUID to TEXT for SQLite
        .replaceAll('UUID PRIMARY KEY DEFAULT uuid_generate_v4()', 'TEXT PRIMARY KEY')
        .replaceAll('uuid_generate_v4()', "'generated_uuid_' || strftime('%Y%m%d%H%M%S', 'now') || '_' || random()")
        // Convert TIMESTAMPTZ to TEXT
        .replaceAll('TIMESTAMPTZ', 'TEXT')
        // Convert NOW() to SQLite syntax
        .replaceAll('NOW()', "strftime('%Y-%m-%d %H:%M:%S', 'now')")
        // Remove Supabase-specific functions and policies
        .replaceAll(RegExp(r'CREATE OR REPLACE FUNCTION.*?;', dotAll: true), '')
        .replaceAll(RegExp(r'CREATE TRIGGER.*?;', dotAll: true), '')
        .replaceAll(RegExp(r'ALTER TABLE.*?ENABLE ROW LEVEL SECURITY;', dotAll: true), '')
        .replaceAll(RegExp(r'CREATE POLICY.*?;', dotAll: true), '')
        // Remove JSONB (use TEXT instead)
        .replaceAll('JSONB', 'TEXT')
        // Remove Supabase auth references
        .replaceAll(RegExp(r'auth\.role\(\).*?=', dotAll: true), '1=1 --')
        // Keep only CREATE TABLE and CREATE INDEX statements
        .split('\n')
        .where((line) =>
            line.trim().startsWith('CREATE TABLE') ||
            line.trim().startsWith('CREATE INDEX') ||
            line.trim().startsWith('ALTER TABLE') ||
            line.trim().startsWith('UNIQUE') ||
            line.trim().startsWith('FOREIGN KEY') ||
            line.trim().startsWith('PRIMARY KEY') ||
            line.trim().startsWith(')') ||
            line.trim().startsWith('(') ||
            line.trim().isEmpty ||
            line.trim().startsWith('--'))
        .join('\n');
  }

  String _getFallbackSchema() {
    // Minimal fallback schema if files can't be loaded
    return '''
-- Fallback schema - please ensure database_supabase_sqlite/ files are available

CREATE TABLE family_survey_sessions (
    phone_number TEXT PRIMARY KEY,
    village_name TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE village_survey_sessions (
    session_id TEXT PRIMARY KEY,
    village_name TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
''';
  }

  // Survey Session Management
  Future<String> createNewSurveySession({
    required String villageName,
    String? villageNumber,
    String? panchayat,
    String? block,
    String? tehsil,
    String? district,
    String? postalAddress,
    String? pinCode,
    String? surveyorName,
    String? phoneNumber,
    String? surveyorEmail,
    String? shineCode,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    String? locationTimestamp,
  }) async {
    if (kIsWeb) {
      final session = {
        'phone_number': phoneNumber ?? '',
        'village_name': villageName,
        'village_number': villageNumber,
        'panchayat': panchayat,
        'block': block,
        'tehsil': tehsil,
        'district': district,
        'postal_address': postalAddress,
        'pin_code': pinCode,
        'surveyor_name': surveyorName,
        'surveyor_email': surveyorEmail,
        'shine_code': shineCode,
        'latitude': latitude,
        'longitude': longitude,
        'location_accuracy': locationAccuracy,
        'location_timestamp': locationTimestamp,
        'status': 'in_progress',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final table = _webStore.putIfAbsent('survey_sessions', () => []);
      table.removeWhere((row) => row['phone_number'] == phoneNumber);
      table.add(session);
      return phoneNumber ?? '';
    }

    final db = await database;

    // Phone number is required and serves as the primary key
    if (phoneNumber == null || phoneNumber.isEmpty) {
      throw ArgumentError('Phone number is required for survey session');
    }

    // Check if a survey already exists for this phone number
    final existingSession = await db.query(
      'survey_sessions',
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
      limit: 1,
    );

    if (existingSession.isNotEmpty) {
      // Return existing phone number
      return phoneNumber;
    }

    // Insert new survey session
    await db.insert('survey_sessions', {
      'phone_number': phoneNumber,
      'village_name': villageName,
      'village_number': villageNumber,
      'panchayat': panchayat,
      'block': block,
      'tehsil': tehsil,
      'district': district,
      'postal_address': postalAddress,
      'pin_code': pinCode,
      'shine_code': shineCode,
      'latitude': latitude,
      'longitude': longitude,
      'location_accuracy': locationAccuracy,
      'location_timestamp': locationTimestamp,
      'surveyor_name': surveyorName,
      'surveyor_email': surveyorEmail,
      'status': 'in_progress',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    return phoneNumber;
  }

  // Village Survey Session Management
  Future<String> createNewVillageSurveySession({
    required String villageName,
    String? villageCode,
    String? state,
    String? district,
    String? block,
    String? panchayat,
    String? tehsil,
    String? ldgCode,
    String? gpsLink,
    String? shineCode,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    String? locationTimestamp,
  }) async {
    if (kIsWeb) return '';

    final db = await database;

    // Create a new unique session id for village survey
    final sessionId = 'village_${DateTime.now().millisecondsSinceEpoch}';

    await db.insert(
      'village_survey_sessions',
      {
        'session_id': sessionId,
        'village_name': villageName,
        'village_code': villageCode,
        'state': state,
        'district': district,
        'block': block,
        'panchayat': panchayat,
        'tehsil': tehsil,
        'ldg_code': ldgCode,
        'gps_link': gpsLink,
        'shine_code': shineCode,
        'latitude': latitude,
        'longitude': longitude,
        'location_accuracy': locationAccuracy,
        'location_timestamp': locationTimestamp,
        'status': 'in_progress',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return sessionId;
  }

  Future<List<Map<String, dynamic>>> getAllVillageSurveySessions() async {
    if (kIsWeb) return [];

    final db = await database;
    return await db.query(
      'village_survey_sessions',
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getVillageSurveySession(String sessionId) async {
    if (kIsWeb) return null;

    final db = await database;
    final results = await db.query(
      'village_survey_sessions',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> saveVillagePopulation(String sessionId, Map<String, dynamic> data) async {
    if (kIsWeb) return;

    final db = await database;
    data['session_id'] = sessionId;
    data['created_at'] = DateTime.now().toIso8601String();

    await db.insert(
      'village_population',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveVillageFarmFamilies(String sessionId, Map<String, dynamic> data) async {
    if (kIsWeb) return;

    final db = await database;
    data['session_id'] = sessionId;
    data['created_at'] = DateTime.now().toIso8601String();

    await db.insert(
      'village_farm_families',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllSurveySessions() async {
    if (kIsWeb) return [];

    final db = await database;
    return await db.query(
      'survey_sessions',
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getSurveySession(String phoneNumber) async {
    if (kIsWeb) {
      final table = _webStore['survey_sessions'] ?? const [];
      try {
        return table.firstWhere((row) => row['phone_number'] == phoneNumber);
      } catch (_) {
        return null;
      }
    }

    final db = await database;
    final results = await db.query(
      'survey_sessions',
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateSurveyStatus(String phoneNumber, String status) async {
    if (kIsWeb) {
      final table = _webStore['survey_sessions'];
      if (table != null) {
        for (final row in table) {
          if (row['phone_number'] == phoneNumber) {
            row['status'] = status;
            row['updated_at'] = DateTime.now().toIso8601String();
          }
        }
      }
      return;
    }

    final db = await database;
    await db.update(
      'survey_sessions',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
    );
  }

  // Generic data saving methods
  Future<void> saveData(String tableName, Map<String, dynamic> data) async {
    if (kIsWeb) {
      final table = _webStore.putIfAbsent(tableName, () => []);
      table.add({
        ...data,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }

    final db = await database;
    data['created_at'] = DateTime.now().toIso8601String();

    await db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getData(String tableName, String phoneNumber) async {
    if (kIsWeb) {
      final table = _webStore[tableName] ?? const [];
      return table
          .where((row) => row['phone_number'] == phoneNumber)
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    }

    final db = await database;
    return await db.query(
      tableName,
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
    );
  }

  // Export functionality
  Future<String> exportSurveyToCSV(String sessionId) async {
    if (kIsWeb) return '';

    final db = await database;

    // Get all data for the survey
    final sessionData = await getSurveySession(sessionId);
    if (sessionData == null) return '';

    final csvData = <List<dynamic>>[];

    // Add headers and data for each table
    final tables = [
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
      'nutritional_garden',
      'diseases',
      'social_consciousness',
    ];

    for (final table in tables) {
      final data = await getData(table, sessionId);
      if (data.isNotEmpty) {
        // Add table header
        csvData.add(['=== $table ===']);
        csvData.add(data.first.keys.toList());
        for (final row in data) {
          csvData.add(row.values.toList());
        }
        csvData.add([]); // Empty row separator
      }
    }

    return const ListToCsvConverter().convert(csvData);
  }

  Future<void> exportSurveyToFile(String sessionId, String fileName) async {
    if (kIsWeb) {
      // For web, create a download link
      final csvContent = await exportSurveyToCSV(sessionId);
      final blob = html.Blob([csvContent]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      return;
    }

    final csvContent = await exportSurveyToCSV(sessionId);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvContent);
  }

  Future<void> deleteSurveySession(String sessionId) async {
    if (kIsWeb) {
      final table = _webStore['survey_sessions'];
      table?.removeWhere((row) => row['session_id'] == sessionId || row['phone_number'] == sessionId);
      return;
    }

    final db = await database;
    await db.delete(
      'survey_sessions',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
