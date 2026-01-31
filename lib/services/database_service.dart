import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:universal_html/html.dart' as html;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';

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
      version: 3,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    try {
      // Production-ready approach: Create tables directly in code
      // This ensures we have full control over schema and no external dependencies
      await _createSQLiteTables(db);
    } catch (e) {
      print('Error creating tables directly: $e');
      // Fallback: Try loading from schema files with better error handling
      try {
        await _createTablesFromSchema(db);
      } catch (fallbackError) {
        print('Fallback schema creation also failed: $fallbackError');
        // Last resort: Create minimal compatibility tables
        await _createMinimalTables(db);
      }
    }
  }

  Future<void> _createTablesFromSchema(Database db) async {
    final schema = await _loadSchema();
    final statements = schema.split(';').where((s) => s.trim().isNotEmpty);

    for (final statement in statements) {
      final trimmed = statement.trim();
      if (trimmed.isNotEmpty && !trimmed.startsWith('--')) {
        try {
          await db.execute(trimmed);
        } catch (e) {
          print('Failed to execute SQL statement: $trimmed');
          print('Error: $e');
          // Continue with other statements instead of failing completely
        }
      }
    }
  }

  Future<void> _createMinimalTables(Database db) async {
    print('Creating minimal compatibility tables...');

    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Minimal survey_sessions table for UI compatibility
    await db.execute('''
      CREATE TABLE IF NOT EXISTS survey_sessions (
        phone_number TEXT PRIMARY KEY,
        village_name TEXT,
        survey_date TEXT,
        status TEXT DEFAULT 'in_progress',
        surveyor_name TEXT,
        surveyor_email TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Minimal drinking_water_sources table with quality columns
    await db.execute('''
      CREATE TABLE IF NOT EXISTS drinking_water_sources (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        hand_pumps INTEGER DEFAULT 0,
        hand_pumps_distance REAL,
        hand_pumps_quality TEXT,
        well INTEGER DEFAULT 0,
        well_distance REAL,
        well_quality TEXT,
        tubewell INTEGER DEFAULT 0,
        tubewell_distance REAL,
        tubewell_quality TEXT,
        nal_jaal INTEGER DEFAULT 0,
        nal_jaal_quality TEXT,
        other_sources TEXT,
        other_distance REAL,
        other_sources_quality TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _createSQLiteTables(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Survey Sessions Table
    await db.execute('''
      CREATE TABLE survey_sessions (
        phone_number TEXT PRIMARY KEY,
        village_name TEXT,
        village_number TEXT,
        panchayat TEXT,
        block TEXT,
        tehsil TEXT,
        district TEXT,
        postal_address TEXT,
        pin_code TEXT,
        shine_code TEXT,
        latitude REAL,
        longitude REAL,
        location_accuracy REAL,
        location_timestamp TEXT,
        surveyor_name TEXT,
        surveyor_email TEXT,
        status TEXT DEFAULT 'in_progress',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_deleted INTEGER DEFAULT 0,
        last_synced_at TEXT
      )
    ''');

    // Family Members Table
    await db.execute('''
      CREATE TABLE family_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        sr_no INTEGER,
        name TEXT,
        fathers_name TEXT,
        mothers_name TEXT,
        relationship_with_head TEXT,
        age INTEGER,
        sex TEXT,
        physically_fit TEXT,
        physically_fit_cause TEXT,
        educational_qualification TEXT,
        inclination_self_employment TEXT,
        occupation TEXT,
        days_employed INTEGER,
        income REAL,
        awareness_about_village TEXT,
        participate_gram_sabha TEXT,
        insured TEXT DEFAULT 'no',
        insurance_company TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Land Holding Table
    await db.execute('''
      CREATE TABLE land_holding (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        irrigated_area REAL,
        cultivable_area REAL,
        orchard_plants TEXT,
        mango_trees INTEGER DEFAULT 0,
        guava_trees INTEGER DEFAULT 0,
        lemon_trees INTEGER DEFAULT 0,
        banana_plants INTEGER DEFAULT 0,
        papaya_trees INTEGER DEFAULT 0,
        other_fruit_trees INTEGER DEFAULT 0,
        other_orchard_plants TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Irrigation Facilities Table
    await db.execute('''
      CREATE TABLE irrigation_facilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        canal INTEGER DEFAULT 0,
        tube_well INTEGER DEFAULT 0,
        ponds INTEGER DEFAULT 0,
        other_facilities TEXT,
        other_irrigation_specify TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Crop Productivity Table
    await db.execute('''
      CREATE TABLE crop_productivity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        sr_no INTEGER,
        crop_name TEXT,
        area_acres REAL,
        productivity_quintal_per_acre REAL,
        total_production REAL,
        quantity_consumed REAL,
        quantity_sold_quintal REAL,
        quantity_sold_rupees REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Fertilizer Usage Table
    await db.execute('''
      CREATE TABLE fertilizer_usage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        chemical INTEGER DEFAULT 0,
        organic INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Animals Table
    await db.execute('''
      CREATE TABLE animals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        sr_no INTEGER,
        animal_type TEXT,
        number_of_animals INTEGER,
        breed TEXT,
        production_per_animal REAL,
        quantity_sold REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Agricultural Equipment Table
    await db.execute('''
      CREATE TABLE agricultural_equipment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        tractor INTEGER DEFAULT 0,
        tractor_condition TEXT,
        thresher INTEGER DEFAULT 0,
        thresher_condition TEXT,
        seed_drill INTEGER DEFAULT 0,
        seed_drill_condition TEXT,
        sprayer INTEGER DEFAULT 0,
        sprayer_condition TEXT,
        duster INTEGER DEFAULT 0,
        duster_condition TEXT,
        diesel_engine INTEGER DEFAULT 0,
        diesel_engine_condition TEXT,
        other_equipment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Entertainment Facilities Table
    await db.execute('''
      CREATE TABLE entertainment_facilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        smart_mobile INTEGER DEFAULT 0,
        smart_mobile_count INTEGER,
        analog_mobile INTEGER DEFAULT 0,
        analog_mobile_count INTEGER,
        television INTEGER DEFAULT 0,
        radio INTEGER DEFAULT 0,
        games INTEGER DEFAULT 0,
        other_entertainment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Transport Facilities Table
    await db.execute('''
      CREATE TABLE transport_facilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        car_jeep INTEGER DEFAULT 0,
        motorcycle_scooter INTEGER DEFAULT 0,
        e_rickshaw INTEGER DEFAULT 0,
        cycle INTEGER DEFAULT 0,
        pickup_truck INTEGER DEFAULT 0,
        bullock_cart INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Drinking Water Sources Table
    await db.execute('''
      CREATE TABLE drinking_water_sources (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        hand_pumps INTEGER DEFAULT 0,
        hand_pumps_distance REAL,
        hand_pumps_quality TEXT,
        well INTEGER DEFAULT 0,
        well_distance REAL,
        well_quality TEXT,
        tubewell INTEGER DEFAULT 0,
        tubewell_distance REAL,
        tubewell_quality TEXT,
        nal_jaal INTEGER DEFAULT 0,
        nal_jaal_quality TEXT,
        other_sources TEXT,
        other_distance REAL,
        other_sources_quality TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Medical Treatment Table
    await db.execute('''
      CREATE TABLE medical_treatment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        allopathic INTEGER DEFAULT 0,
        ayurvedic INTEGER DEFAULT 0,
        homeopathy INTEGER DEFAULT 0,
        traditional INTEGER DEFAULT 0,
        jhad_phook INTEGER DEFAULT 0,
        other_methods TEXT,
        preferences TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Disputes Table
    await db.execute('''
      CREATE TABLE disputes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        family_disputes INTEGER DEFAULT 0,
        family_registered INTEGER DEFAULT 0,
        revenue_disputes INTEGER DEFAULT 0,
        revenue_registered INTEGER DEFAULT 0,
        criminal_disputes INTEGER DEFAULT 0,
        criminal_registered INTEGER DEFAULT 0,
        other_disputes TEXT,
        dispute_period TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // House Conditions Table
    await db.execute('''
      CREATE TABLE house_conditions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        katcha INTEGER DEFAULT 0,
        pakka INTEGER DEFAULT 0,
        katcha_pakka INTEGER DEFAULT 0,
        hut INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // House Facilities Table
    await db.execute('''
      CREATE TABLE house_facilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        toilet INTEGER DEFAULT 0,
        toilet_in_use INTEGER DEFAULT 0,
        drainage INTEGER DEFAULT 0,
        soak_pit INTEGER DEFAULT 0,
        cattle_shed INTEGER DEFAULT 0,
        compost_pit INTEGER DEFAULT 0,
        nadep INTEGER DEFAULT 0,
        lpg_gas INTEGER DEFAULT 0,
        biogas INTEGER DEFAULT 0,
        solar_cooking INTEGER DEFAULT 0,
        electric_connection INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Diseases Table
    await db.execute('''
      CREATE TABLE diseases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        sr_no INTEGER,
        name TEXT,
        age INTEGER,
        sex TEXT,
        disease_name TEXT,
        suffering_since TEXT,
        treatment_from TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Social Consciousness Table
    await db.execute('''
      CREATE TABLE social_consciousness (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        clothes_frequency TEXT,
        waste_disposal TEXT,
        separate_waste TEXT,
        recycle_wet_waste TEXT,
        recycle_method TEXT,
        recycle_water TEXT,
        water_recycle_usage TEXT,
        rainwater_harvesting TEXT,
        have_toilet TEXT,
        toilet_in_use TEXT,
        soak_pit TEXT,
        led_lights TEXT,
        turn_off_devices TEXT,
        fix_leaks TEXT,
        avoid_plastics TEXT,
        family_prayers TEXT,
        family_meditation TEXT,
        meditation_members TEXT,
        family_yoga TEXT,
        yoga_members TEXT,
        community_activities TEXT,
        community_activities_type TEXT,
        shram_sadhana TEXT,
        shram_sadhana_members TEXT,
        spiritual_discourses TEXT,
        discourses_members TEXT,
        family_happiness TEXT,
        personal_happiness TEXT,
        unhappiness_reason TEXT,
        financial_problems TEXT,
        family_disputes TEXT,
        illness_issues TEXT,
        other_unhappiness_reason TEXT,
        family_addictions TEXT,
        addiction_details TEXT,
        clothes_other_specify TEXT,
        food_waste_exists TEXT,
        food_waste_amount TEXT,
        waste_disposal_other TEXT,
        compost_pit TEXT,
        recycle_used_items TEXT,
        happiness_family_who TEXT,
        addiction_smoke TEXT,
        addiction_drink TEXT,
        addiction_gutka TEXT,
        addiction_gamble TEXT,
        addiction_tobacco TEXT,
        savings_exists TEXT,
        savings_percentage TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
      )
    ''');

    // Form History Tables
    await db.execute('''
      CREATE TABLE family_form_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        version INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        edited_by TEXT,
        edit_reason TEXT,
        is_auto_save INTEGER DEFAULT 0,
        form_data TEXT NOT NULL,
        changes_summary TEXT,
        UNIQUE(session_id, version)
      )
    ''');

    await db.execute('''
      CREATE TABLE village_form_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        version INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        edited_by TEXT,
        edit_reason TEXT,
        is_auto_save INTEGER DEFAULT 0,
        form_data TEXT NOT NULL,
        changes_summary TEXT,
        UNIQUE(session_id, version)
      )
    ''');

    // Update sessions tables to include version tracking
    await db.execute('ALTER TABLE survey_sessions ADD COLUMN current_version INTEGER DEFAULT 1');
    await db.execute('ALTER TABLE survey_sessions ADD COLUMN last_edited_at TEXT');

    // Village Survey Tables
    await db.execute('''
      CREATE TABLE village_survey_sessions (
        session_id TEXT PRIMARY KEY,
        village_name TEXT,
        village_code TEXT,
        state TEXT,
        district TEXT,
        block TEXT,
        panchayat TEXT,
        tehsil TEXT,
        ldg_code TEXT,
        gps_link TEXT,
        shine_code TEXT,
        latitude REAL,
        longitude REAL,
        location_accuracy REAL,
        location_timestamp TEXT,
        status TEXT DEFAULT 'in_progress',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_deleted INTEGER DEFAULT 0,
        last_synced_at TEXT,
        current_version INTEGER DEFAULT 1,
        last_edited_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE village_population (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        total_population INTEGER,
        male_population INTEGER,
        female_population INTEGER,
        children_0_5 INTEGER,
        children_6_14 INTEGER,
        adults_15_59 INTEGER,
        seniors_60_plus INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (session_id) REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE village_farm_families (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        total_farm_families INTEGER,
        marginal_farmers INTEGER,
        small_farmers INTEGER,
        medium_farmers INTEGER,
        large_farmers INTEGER,
        landless_farmers INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (session_id) REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE
      )
    ''');
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

    // Version 3: Add water quality columns to drinking_water_sources table
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE drinking_water_sources ADD COLUMN hand_pumps_quality TEXT');
      } catch (e) {
        print('Error adding hand_pumps_quality column: $e');
      }
      try {
        await db.execute('ALTER TABLE drinking_water_sources ADD COLUMN well_quality TEXT');
      } catch (e) {
        print('Error adding well_quality column: $e');
      }
      try {
        await db.execute('ALTER TABLE drinking_water_sources ADD COLUMN tubewell_quality TEXT');
      } catch (e) {
        print('Error adding tubewell_quality column: $e');
      }
      try {
        await db.execute('ALTER TABLE drinking_water_sources ADD COLUMN nal_jaal_quality TEXT');
      } catch (e) {
        print('Error adding nal_jaal_quality column: $e');
      }
      try {
        await db.execute('ALTER TABLE drinking_water_sources ADD COLUMN other_sources_quality TEXT');
      } catch (e) {
        print('Error adding other_sources_quality column: $e');
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
      // Try loading from assets first
      return await rootBundle.loadString(path);
    } catch (e) {
      // Fallback to embedded schema if file loading fails
      print('Error loading schema from assets ($path): $e');
      return _getFallbackSchema();
    }
  }

  String _convertToSQLiteSchema(String supabaseSchema) {
    String result = supabaseSchema;

    // Remove all Supabase extensions
    result = result.replaceAll(RegExp(r'CREATE EXTENSION.*?;', multiLine: true), '');

    // Convert UUID types and functions
    result = result.replaceAll('UUID PRIMARY KEY DEFAULT uuid_generate_v4()', 'TEXT PRIMARY KEY');
    result = result.replaceAll('uuid_generate_v4()', "'generated_uuid_' || strftime('%Y%m%d%H%M%S', 'now') || '_' || abs(random())");

    // Convert PostgreSQL types to SQLite
    result = result.replaceAll('TIMESTAMPTZ', 'TEXT');
    result = result.replaceAll('JSONB', 'TEXT');
    result = result.replaceAll('DECIMAL', 'REAL');

    // Convert PostgreSQL functions
    result = result.replaceAll('NOW()', "strftime('%Y-%m-%d %H:%M:%S', 'now')");
    result = result.replaceAll('CURRENT_DATE', "date('now')");
    result = result.replaceAll('CURRENT_TIMESTAMP', "datetime('now')");

    // Remove all PostgreSQL-specific constructs
    result = result.replaceAll(RegExp(r'CREATE OR REPLACE FUNCTION.*?;', dotAll: true), '');
    result = result.replaceAll(RegExp(r'CREATE TRIGGER.*?;', dotAll: true), '');
    result = result.replaceAll(RegExp(r'ALTER TABLE.*?ENABLE ROW LEVEL SECURITY;', multiLine: true), '');
    result = result.replaceAll(RegExp(r'CREATE POLICY.*?;', dotAll: true), '');
    result = result.replaceAll(RegExp(r'CREATE INDEX.*?;', multiLine: true), '');

    // Remove Supabase auth references
    result = result.replaceAll(RegExp(r'auth\.role\(\).*?=', dotAll: true), '1=1 --');

    // Remove empty lines and clean up
    result = result.split('\n')
        .where((line) => line.trim().isNotEmpty && !line.trim().startsWith('--'))
        .join('\n');

    return result;
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
