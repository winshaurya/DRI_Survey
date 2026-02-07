import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Generic insert method for village survey screens
  Future<int> insert(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Generic update method for village survey screens
  Future<int> update(
    String tableName,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'family_survey.db');
    return await openDatabase(
      path,
      version: 40,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createVillageTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Ensure newer columns exist for upgrades.
    await _ensurePageTrackingColumns(db);
    await _ensureSchemeMemberTables(db);
    if (oldVersion < 38) {
      await _migrateFamilySurveySessionsPrimaryKey(db);
    }
  }

  Future<void> _ensureSchemeMemberTables(Database db) async {
    await db.execute('CREATE TABLE IF NOT EXISTS vb_gram_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, member_name TEXT, name_included INTEGER, details_correct INTEGER, incorrect_details TEXT, received INTEGER, days TEXT, membership_details TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS pm_kisan_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, member_name TEXT, account_number TEXT, benefits_received TEXT, name_included INTEGER, details_correct INTEGER, incorrect_details TEXT, received INTEGER, days TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS pm_kisan_samman_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, member_name TEXT, account_number TEXT, benefits_received TEXT, name_included INTEGER, details_correct INTEGER, incorrect_details TEXT, received INTEGER, days TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS pm_kisan_samman_nidhi (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, is_beneficiary TEXT, total_members INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
  }

  Future<void> _migrateFamilySurveySessionsPrimaryKey(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(family_survey_sessions)');
    final hasIdColumn = columns.any((row) => row['name'] == 'id');
    if (!hasIdColumn) {
      return;
    }

    await db.execute('''
      CREATE TABLE IF NOT EXISTS family_survey_sessions_new (
        phone_number TEXT PRIMARY KEY,
        surveyor_email TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        village_name TEXT,
        village_number TEXT,
        panchayat TEXT,
        block TEXT,
        tehsil TEXT,
        district TEXT,
        postal_address TEXT,
        pin_code TEXT,
        shine_code TEXT,
        latitude DECIMAL(10,8),
        longitude DECIMAL(11,8),
        location_accuracy DECIMAL(5,2),
        location_timestamp TEXT,
        survey_date TEXT DEFAULT CURRENT_DATE,
        surveyor_name TEXT,
        status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'exported')),
        sync_status TEXT DEFAULT 'pending',
        device_info TEXT,
        app_version TEXT,
        created_by TEXT,
        updated_by TEXT,
        is_deleted INTEGER DEFAULT 0,
        last_synced_at TEXT,
        current_version INTEGER DEFAULT 1,
        last_edited_at TEXT DEFAULT CURRENT_TIMESTAMP,
        page_completion_status TEXT DEFAULT '{}',
        sync_pending INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      INSERT OR REPLACE INTO family_survey_sessions_new (
        phone_number, surveyor_email, created_at, updated_at, village_name, village_number,
        panchayat, block, tehsil, district, postal_address, pin_code, shine_code,
        latitude, longitude, location_accuracy, location_timestamp, survey_date, surveyor_name,
        status, sync_status, device_info, app_version, created_by, updated_by, is_deleted,
        last_synced_at, current_version, last_edited_at, page_completion_status, sync_pending
      )
      SELECT
        phone_number,
        COALESCE(surveyor_email, 'unknown'),
        created_at, updated_at, village_name, village_number,
        panchayat, block, tehsil, district, postal_address, pin_code, shine_code,
        latitude, longitude, location_accuracy, location_timestamp, survey_date, surveyor_name,
        status, sync_status, device_info, app_version, created_by, updated_by, is_deleted,
        last_synced_at, current_version, last_edited_at, page_completion_status, sync_pending
      FROM family_survey_sessions
    ''');

    await db.execute('DROP TABLE family_survey_sessions');
    await db.execute('ALTER TABLE family_survey_sessions_new RENAME TO family_survey_sessions');
  }

  Future<void> _ensurePageTrackingColumns(Database db) async {
    await _addColumnIfMissing(db, 'family_survey_sessions', 'page_completion_status', "TEXT DEFAULT '{}'");
    await _addColumnIfMissing(db, 'family_survey_sessions', 'sync_pending', 'INTEGER DEFAULT 0');
    await _addColumnIfMissing(db, 'family_survey_sessions', 'sync_status', "TEXT DEFAULT 'pending'");

    await _addColumnIfMissing(db, 'village_survey_sessions', 'page_completion_status', "TEXT DEFAULT '{}'");
    await _addColumnIfMissing(db, 'village_survey_sessions', 'sync_pending', 'INTEGER DEFAULT 0');
    await _addColumnIfMissing(db, 'village_survey_sessions', 'sync_status', "TEXT DEFAULT 'pending'");
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String tableName,
    String columnName,
    String columnDef,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final exists = columns.any((row) => row['name'] == columnName);
    if (!exists) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnDef');
    }
  }

  Future<void> _createTables(Database db) async {
    // Enable foreign keys
    try {
      await db.execute('PRAGMA foreign_keys = ON');
    } catch (_) {
      // Ignore if not supported
    }

    // Pending uploads table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_uploads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_file_path TEXT,
        file_name TEXT,
        file_type TEXT,
        village_smile_code TEXT,
        page_type TEXT,
        component TEXT,
        status TEXT DEFAULT 'pending',
        upload_attempts INTEGER DEFAULT 0,
        last_attempt_at TEXT,
        error_message TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_survey_sessions (
        session_id TEXT PRIMARY KEY,
        surveyor_email TEXT,
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
        status TEXT,
        sync_status TEXT DEFAULT 'pending',
        device_info TEXT,
        app_version TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_deleted INTEGER DEFAULT 0,
        last_synced_at TEXT,
        current_version INTEGER DEFAULT 1,
        last_edited_at TEXT,
        page_completion_status TEXT DEFAULT '{}',
        sync_pending INTEGER DEFAULT 0
      )
    ''');
    
    // Create survey_sessions table (used by DatabaseService)
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

    // Create surveys table individually to avoid parsing issues
    // REMOVED IN V33: This table is replaced by family_survey_sessions
    // await db.execute('''
    //   CREATE TABLE IF NOT EXISTS surveys (...)
    // ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS family_survey_sessions (
        phone_number TEXT PRIMARY KEY,
        surveyor_email TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        village_name TEXT,
        village_number TEXT,
        panchayat TEXT,
        block TEXT,
        tehsil TEXT,
        district TEXT,
        postal_address TEXT,
        pin_code TEXT,
        shine_code TEXT,
        latitude DECIMAL(10,8),
        longitude DECIMAL(11,8),
        location_accuracy DECIMAL(5,2),
        location_timestamp TEXT,
        survey_date TEXT DEFAULT CURRENT_DATE,
        surveyor_name TEXT,
        status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'exported')),
        sync_status TEXT DEFAULT 'pending',
        device_info TEXT,
        app_version TEXT,
        created_by TEXT,
        updated_by TEXT,
        is_deleted INTEGER DEFAULT 0,
        last_synced_at TEXT,
        current_version INTEGER DEFAULT 1,
        last_edited_at TEXT DEFAULT CURRENT_TIMESTAMP,
        page_completion_status TEXT DEFAULT '{}',
        sync_pending INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_failures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT,
        failed_at TEXT,
        failed_tables TEXT,
        error_count INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_metadata (
        phone_number TEXT PRIMARY KEY,
        last_sync_attempt TEXT,
        data_hash TEXT,
        sync_version INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS family_members (
        id TEXT PRIMARY KEY,
        phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_deleted INTEGER DEFAULT 0,
        sr_no INTEGER NOT NULL,
        name TEXT NOT NULL,
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
        income DECIMAL(10,2),
        awareness_about_village TEXT,
        participate_gram_sabha TEXT,
        insured TEXT DEFAULT 'no',
        insurance_company TEXT,
        UNIQUE(phone_number, sr_no)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS land_holding (
        id TEXT PRIMARY KEY,
        phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        irrigated_area DECIMAL(8,2),
        cultivable_area DECIMAL(8,2),
        unirrigated_area DECIMAL(8,2),
        barren_land DECIMAL(8,2),
        mango_trees INTEGER DEFAULT 0,
        guava_trees INTEGER DEFAULT 0,
        lemon_trees INTEGER DEFAULT 0,
        banana_plants INTEGER DEFAULT 0,
        papaya_trees INTEGER DEFAULT 0,
        pomegranate_trees INTEGER DEFAULT 0,
        other_fruit_trees_name TEXT,
        other_fruit_trees_count INTEGER DEFAULT 0,
        UNIQUE(phone_number)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bank_accounts (
        id TEXT PRIMARY KEY,
        phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sr_no INTEGER,
        member_name TEXT,
        account_number TEXT,
        bank_name TEXT,
        ifsc_code TEXT,
        branch_name TEXT,
        account_type TEXT,
        has_account INTEGER DEFAULT 0,
        details_correct INTEGER DEFAULT 0,
        incorrect_details TEXT,
        UNIQUE(phone_number, sr_no)
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX IF NOT EXISTS idx_family_members_phone ON family_members(phone_number)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_bank_accounts_phone ON bank_accounts(phone_number)');

    await _createRemainingTables(db);
    await _createVillageTables(db);
  }

  Future<void> _createRemainingTables(Database db) async {
    // Irrigation Facilities
    await db.execute('CREATE TABLE IF NOT EXISTS irrigation_facilities (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, primary_source TEXT, canal TEXT, tube_well TEXT, river TEXT, pond TEXT, well TEXT, hand_pump TEXT, submersible TEXT, rainwater_harvesting TEXT, check_dam TEXT, other_sources TEXT, created_at TEXT)');

    // Fertilizer Usage
    await db.execute('CREATE TABLE IF NOT EXISTS fertilizer_usage (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, urea_fertilizer TEXT, organic_fertilizer TEXT, fertilizer_types TEXT, fertilizer_expenditure REAL, created_at TEXT)');

    // Crop Productivity
    await db.execute('CREATE TABLE IF NOT EXISTS crop_productivity (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, crop_name TEXT, area_hectares REAL, productivity_quintal_per_hectare REAL, total_production_quintal REAL, quantity_consumed_quintal REAL, quantity_sold_quintal REAL, created_at TEXT)');
    
    // Animals
    await db.execute('CREATE TABLE IF NOT EXISTS animals (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, animal_type TEXT, number_of_animals INTEGER, breed TEXT, production_per_animal REAL, quantity_sold REAL, created_at TEXT)');

    // Agricultural Equipment
    await db.execute('CREATE TABLE IF NOT EXISTS agricultural_equipment (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, tractor TEXT, tractor_condition TEXT, thresher TEXT, thresher_condition TEXT, seed_drill TEXT, seed_drill_condition TEXT, sprayer TEXT, sprayer_condition TEXT, duster TEXT, duster_condition TEXT, diesel_engine TEXT, diesel_engine_condition TEXT, other_equipment TEXT, created_at TEXT)');

    // Entertainment Facilities
    await db.execute('CREATE TABLE IF NOT EXISTS entertainment_facilities (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, smart_mobile TEXT, smart_mobile_count INTEGER, analog_mobile TEXT, analog_mobile_count INTEGER, television TEXT, radio TEXT, games TEXT, other_entertainment TEXT, other_specify TEXT, created_at TEXT)');

    // Transport Facilities
    await db.execute('CREATE TABLE IF NOT EXISTS transport_facilities (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, car_jeep TEXT, motorcycle_scooter TEXT, e_rickshaw TEXT, cycle TEXT, pickup_truck TEXT, bullock_cart TEXT, created_at TEXT)');

    // Drinking Water Sources
    await db.execute('CREATE TABLE IF NOT EXISTS drinking_water_sources (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, hand_pumps TEXT, hand_pumps_distance REAL, hand_pumps_quality TEXT, well TEXT, well_distance REAL, well_quality TEXT, tubewell TEXT, tubewell_distance REAL, tubewell_quality TEXT, nal_jaal TEXT, nal_jaal_quality TEXT, other_source TEXT, other_distance REAL, other_sources_quality TEXT, created_at TEXT)');

    // Medical Treatment
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medical_treatment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT,
        allopathic TEXT,
        ayurvedic TEXT,
        homeopathy TEXT,
        traditional TEXT,
        other_treatment TEXT,
        preferred_treatment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Disputes
    await db.execute('CREATE TABLE IF NOT EXISTS disputes (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, family_disputes TEXT, family_registered TEXT, family_period TEXT, revenue_disputes TEXT, revenue_registered TEXT, revenue_period TEXT, criminal_disputes TEXT, criminal_registered TEXT, criminal_period TEXT, other_disputes TEXT, other_description TEXT, other_registered TEXT, other_period TEXT, created_at TEXT)');

    // House Conditions
    await db.execute('CREATE TABLE IF NOT EXISTS house_conditions (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, katcha TEXT, pakka TEXT, katcha_pakka TEXT, hut TEXT, toilet_in_use TEXT, toilet_condition TEXT, created_at TEXT)');

    // House Facilities
    await db.execute('CREATE TABLE IF NOT EXISTS house_facilities (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, toilet TEXT, toilet_in_use TEXT, drainage TEXT, soak_pit TEXT, cattle_shed TEXT, compost_pit TEXT, nadep TEXT, lpg_gas TEXT, biogas TEXT, solar_cooking TEXT, electric_connection TEXT, nutritional_garden_available TEXT, tulsi_plants_available TEXT, created_at TEXT)');

    // Diseases
    await db.execute('CREATE TABLE IF NOT EXISTS diseases (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, family_member_name TEXT, disease_name TEXT, suffering_since TEXT, treatment_taken TEXT, treatment_from_when TEXT, treatment_from_where TEXT, treatment_taken_from TEXT, created_at TEXT)');

    // Folklore Medicine
    await db.execute('CREATE TABLE IF NOT EXISTS folklore_medicine (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, person_name TEXT, plant_local_name TEXT, plant_botanical_name TEXT, uses TEXT, created_at TEXT)');

    // Health Programmes
    await db.execute('CREATE TABLE IF NOT EXISTS health_programmes (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, vaccination_pregnancy TEXT, child_vaccination TEXT, vaccination_schedule TEXT, balance_doses_schedule TEXT, family_planning_awareness TEXT, contraceptive_applied TEXT, created_at TEXT)');
    
    // Scheme Members Tables (updated to use phone_number)
    await db.execute('CREATE TABLE IF NOT EXISTS aadhaar_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS tribal_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS pension_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS widow_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS ayushman_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS ration_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS family_id_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS samagra_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS handicapped_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS vb_gram_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, member_name TEXT, name_included INTEGER, details_correct INTEGER, incorrect_details TEXT, received INTEGER, days TEXT, membership_details TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS pm_kisan_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, member_name TEXT, account_number TEXT, benefits_received TEXT, name_included INTEGER, details_correct INTEGER, incorrect_details TEXT, received INTEGER, days TEXT, created_at TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS pm_kisan_samman_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, sr_no INTEGER, member_name TEXT, account_number TEXT, benefits_received TEXT, name_included INTEGER, details_correct INTEGER, incorrect_details TEXT, received INTEGER, days TEXT, created_at TEXT)');

    // Social Consciousness
    await db.execute('''
      CREATE TABLE IF NOT EXISTS social_consciousness (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT,
        clothes_frequency TEXT,
        clothes_other_specify TEXT,
        food_waste_exists TEXT,
        food_waste_amount TEXT,
        waste_disposal TEXT,
        waste_disposal_other TEXT,
        separate_waste TEXT,
        compost_pit TEXT,
        recycle_used_items TEXT,
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
        spiritual_discourses TEXT,
        discourses_members TEXT,
        personal_happiness TEXT,
        family_happiness TEXT,
        happiness_family_who TEXT,
        financial_problems TEXT,
        family_disputes TEXT,
        illness_issues TEXT,
        unhappiness_reason TEXT,
        addiction_smoke TEXT,
        addiction_drink TEXT,
        addiction_gutka TEXT,
        addiction_gamble TEXT,
        addiction_tobacco TEXT,
        addiction_details TEXT,
        created_at TEXT
      )
    ''');

    // Training Data
    await db.execute('CREATE TABLE IF NOT EXISTS training_data (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, member_name TEXT, training_topic TEXT, training_duration TEXT, training_date TEXT, status TEXT DEFAULT "taken", created_at TEXT)');

    // SHG Members
    await db.execute('CREATE TABLE IF NOT EXISTS shg_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, member_name TEXT, shg_name TEXT, purpose TEXT, agency TEXT, position TEXT, monthly_saving REAL, created_at TEXT)');

    // FPO Members
    await db.execute('CREATE TABLE IF NOT EXISTS fpo_members (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, member_name TEXT, fpo_name TEXT, purpose TEXT, agency TEXT, share_capital REAL, created_at TEXT)');

    // Children Data
    await db.execute('CREATE TABLE IF NOT EXISTS children_data (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, births_last_3_years INTEGER, infant_deaths_last_3_years INTEGER, malnourished_children INTEGER, created_at TEXT)');

    // Malnourished Children Data
    await db.execute('CREATE TABLE IF NOT EXISTS malnourished_children_data (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, child_id TEXT, child_name TEXT, height REAL, weight REAL, created_at TEXT)');

    // Child Diseases
    await db.execute('CREATE TABLE IF NOT EXISTS child_diseases (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, child_id TEXT, disease_name TEXT, sr_no INTEGER, created_at TEXT)');

    // Migration Data
    await db.execute('CREATE TABLE IF NOT EXISTS migration_data (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, family_members_migrated INTEGER, reason TEXT, duration TEXT, destination TEXT, created_at TEXT)');
    
    // Tribal Questions
    await db.execute('CREATE TABLE IF NOT EXISTS tribal_questions (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, deity_name TEXT, festival_name TEXT, dance_name TEXT, language TEXT, created_at TEXT)');

    // Tulsi Plants (separate from house_facilities in Supabase)
    await db.execute('CREATE TABLE IF NOT EXISTS tulsi_plants (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, has_plants TEXT, plant_count INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');

    // Nutritional Garden (separate from house_facilities in Supabase)
    await db.execute('CREATE TABLE IF NOT EXISTS nutritional_garden (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, has_garden TEXT, garden_size REAL, vegetables_grown TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');

    // Malnutrition Data (separate table in Supabase)
    await db.execute('CREATE TABLE IF NOT EXISTS malnutrition_data (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, child_name TEXT, age INTEGER, weight REAL, height REAL, created_at TEXT DEFAULT CURRENT_TIMESTAMP)');

    // Government Scheme Info Tables (main info tables)
    await db.execute('CREATE TABLE IF NOT EXISTS aadhaar_info (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, has_aadhaar TEXT, total_members INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
    await db.execute('CREATE TABLE IF NOT EXISTS ayushman_card (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, has_card TEXT, total_members INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
    await db.execute('CREATE TABLE IF NOT EXISTS family_id (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, has_id TEXT, family_id TEXT, total_children INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
    await db.execute('CREATE TABLE IF NOT EXISTS ration_card (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, has_card TEXT, card_type TEXT, total_members INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
    await db.execute('CREATE TABLE IF NOT EXISTS samagra_id (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, has_id TEXT, family_id TEXT, total_children INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
    await db.execute('CREATE TABLE IF NOT EXISTS tribal_card (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, has_card TEXT, total_members INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
    await db.execute('CREATE TABLE IF NOT EXISTS handicapped_allowance (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, has_allowance TEXT, total_members INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
    await db.execute('CREATE TABLE IF NOT EXISTS pension_allowance (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, has_pension TEXT, total_members INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
    await db.execute('CREATE TABLE IF NOT EXISTS widow_allowance (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, has_allowance TEXT, total_members INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
    await db.execute('CREATE TABLE IF NOT EXISTS vb_gram (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, is_member TEXT, total_members INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
    await db.execute('CREATE TABLE IF NOT EXISTS pm_kisan_nidhi (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, is_beneficiary TEXT, total_members INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
    await db.execute('CREATE TABLE IF NOT EXISTS pm_kisan_samman_nidhi (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, is_beneficiary TEXT, total_members INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');

    // Merged Government Schemes (for small schemes)
    await db.execute('CREATE TABLE IF NOT EXISTS merged_govt_schemes (id TEXT PRIMARY KEY, phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE, scheme_data TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(phone_number))');
  }

  /*
  // Legacy CRUD and survey-specific operations (surveys table is deprecated)
  // Commented out to avoid duplicate method signatures and legacy table usage.
  */

  // Bank Account & Family Member Helpers
  Future<List<String>> getFamilyMembers(int surveyId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'family_members',
      columns: ['name'],
      where: 'survey_id = ?',
      whereArgs: [surveyId],
      orderBy: 'sr_no ASC',
    );
    return results.map((e) => e['name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getBankAccounts(int surveyId) async {
    Database db = await database;
    return await db.query(
      'bank_accounts',
      where: 'survey_id = ?',
      whereArgs: [surveyId],
      orderBy: 'sr_no ASC',
    );
  }

  Future<int> insertBankAccount(Map<String, dynamic> account) async {
    Database db = await database;
    return await db.insert('bank_accounts', account);
  }

  Future<int> updateBankAccount(Map<String, dynamic> account) async {
    Database db = await database;
    return await db.update(
      'bank_accounts',
      account,
      where: 'id = ?',
      whereArgs: [account['id']],
    );
  }

  Future<int> deleteBankAccount(String id) async {
    Database db = await database;
    return await db.delete(
      'bank_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBankAccountsBySurveyId(int surveyId) async {
    Database db = await database;
    return await db.delete(
      'bank_accounts',
      where: 'survey_id = ?',
      whereArgs: [surveyId],
    );
  }

  Future<void> _createVillageTables(Database db) async {
    // Village Population
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_population (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_deleted INTEGER DEFAULT 0,
        total_population INTEGER DEFAULT 0,
        male_population INTEGER DEFAULT 0,
        female_population INTEGER DEFAULT 0,
        other_population INTEGER DEFAULT 0,
        children_0_5 INTEGER DEFAULT 0,
        children_6_14 INTEGER DEFAULT 0,
        youth_15_24 INTEGER DEFAULT 0,
        adults_25_59 INTEGER DEFAULT 0,
        seniors_60_plus INTEGER DEFAULT 0,
        illiterate_population INTEGER DEFAULT 0,
        primary_educated INTEGER DEFAULT 0,
        secondary_educated INTEGER DEFAULT 0,
        higher_educated INTEGER DEFAULT 0,
        sc_population INTEGER DEFAULT 0,
        st_population INTEGER DEFAULT 0,
        obc_population INTEGER DEFAULT 0,
        general_population INTEGER DEFAULT 0,
        working_population INTEGER DEFAULT 0,
        unemployed_population INTEGER DEFAULT 0
      )
    ''');

    // Village Farm Families
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_farm_families (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        big_farmers INTEGER DEFAULT 0,
        small_farmers INTEGER DEFAULT 0,
        marginal_farmers INTEGER DEFAULT 0,
        landless_farmers INTEGER DEFAULT 0,
        total_farm_families INTEGER DEFAULT 0
      )
    ''');

    // Village Housing
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_housing (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        katcha_houses INTEGER DEFAULT 0,
        pakka_houses INTEGER DEFAULT 0,
        katcha_pakka_houses INTEGER DEFAULT 0,
        hut_houses INTEGER DEFAULT 0,
        houses_with_toilet INTEGER DEFAULT 0,
        functional_toilets INTEGER DEFAULT 0,
        houses_with_drainage INTEGER DEFAULT 0,
        houses_with_soak_pit INTEGER DEFAULT 0,
        houses_with_cattle_shed INTEGER DEFAULT 0,
        houses_with_compost_pit INTEGER DEFAULT 0,
        houses_with_nadep INTEGER DEFAULT 0,
        houses_with_lpg INTEGER DEFAULT 0,
        houses_with_biogas INTEGER DEFAULT 0,
        houses_with_solar INTEGER DEFAULT 0,
        houses_with_electricity INTEGER DEFAULT 0
      )
    ''');

    // Village Agricultural Implements
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_agricultural_implements (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        tractor_available INTEGER DEFAULT 0,
        thresher_available INTEGER DEFAULT 0,
        seed_drill_available INTEGER DEFAULT 0,
        sprayer_available INTEGER DEFAULT 0,
        duster_available INTEGER DEFAULT 0,
        diesel_engine_available INTEGER DEFAULT 0,
        other_implements TEXT
      )
    ''');

    // Village Crop Productivity
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_crop_productivity (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sr_no INTEGER NOT NULL,
        crop_name TEXT,
        area_hectares REAL,
        productivity_quintal_per_hectare REAL,
        total_production_quintal REAL,
        quantity_consumed_quintal REAL,
        quantity_sold_quintal REAL
      )
    ''');

    // Village Animals
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_animals (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sr_no INTEGER NOT NULL,
        animal_type TEXT,
        total_count INTEGER,
        breed TEXT
      )
    ''');

    // Village Drinking Water
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_drinking_water (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        hand_pumps_available INTEGER DEFAULT 0,
        hand_pumps_count INTEGER DEFAULT 0,
        wells_available INTEGER DEFAULT 0,
        wells_count INTEGER DEFAULT 0,
        tube_wells_available INTEGER DEFAULT 0,
        tube_wells_count INTEGER DEFAULT 0,
        nal_jal_available INTEGER DEFAULT 0,
        other_sources TEXT
      )
    ''');

     // Village Transport
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_transport (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        cars_available INTEGER DEFAULT 0,
        motorcycles_available INTEGER DEFAULT 0,
        e_rickshaws_available INTEGER DEFAULT 0,
        cycles_available INTEGER DEFAULT 0,
        pickup_trucks_available INTEGER DEFAULT 0,
        bullock_carts_available INTEGER DEFAULT 0
      )
    ''');

    // Village Entertainment
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_entertainment (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        smart_mobiles_available INTEGER DEFAULT 0,
        smart_mobiles_count INTEGER DEFAULT 0,
        analog_mobiles_available INTEGER DEFAULT 0,
        analog_mobiles_count INTEGER DEFAULT 0,
        televisions_available INTEGER DEFAULT 0,
        televisions_count INTEGER DEFAULT 0,
        radios_available INTEGER DEFAULT 0,
        radios_count INTEGER DEFAULT 0,
        games_available INTEGER DEFAULT 0,
        other_entertainment TEXT
      )
    ''');

    // Village Medical Treatment
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_medical_treatment (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        allopathic_available INTEGER DEFAULT 0,
        ayurvedic_available INTEGER DEFAULT 0,
        homeopathic_available INTEGER DEFAULT 0,
        traditional_available INTEGER DEFAULT 0,
        jhad_phook_available INTEGER DEFAULT 0,
        other_treatment TEXT,
        preference_order TEXT
      )
    ''');

    // Village Disputes
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_disputes (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        family_disputes INTEGER DEFAULT 0,
        family_registered INTEGER DEFAULT 0,
        family_period TEXT,
        revenue_disputes INTEGER DEFAULT 0,
        revenue_registered INTEGER DEFAULT 0,
        revenue_period TEXT,
        criminal_disputes INTEGER DEFAULT 0,
        criminal_registered INTEGER DEFAULT 0,
        criminal_period TEXT,
        other_disputes INTEGER DEFAULT 0,
        other_description TEXT,
        other_registered INTEGER DEFAULT 0,
        other_period TEXT
      )
    ''');

    // Village Educational Facilities
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_educational_facilities (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        primary_schools INTEGER DEFAULT 0,
        middle_schools INTEGER DEFAULT 0,
        secondary_schools INTEGER DEFAULT 0,
        higher_secondary_schools INTEGER DEFAULT 0,
        anganwadi_centers INTEGER DEFAULT 0,
        skill_development_centers INTEGER DEFAULT 0,
        shiksha_guarantee_centers INTEGER DEFAULT 0,
        other_facility_name TEXT,
        other_facility_count INTEGER DEFAULT 0
      )
    ''');

    // Village Social Consciousness
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_social_consciousness (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        clothing_purchase_frequency TEXT,
        food_waste_level TEXT,
        food_waste_amount TEXT,
        waste_disposal_method TEXT,
        waste_segregation INTEGER DEFAULT 0,
        compost_pit_available INTEGER DEFAULT 0,
        toilet_available INTEGER DEFAULT 0,
        toilet_functional INTEGER DEFAULT 0,
        toilet_soak_pit INTEGER DEFAULT 0,
        led_lights_used INTEGER DEFAULT 0,
        devices_turned_off INTEGER DEFAULT 0,
        water_leaks_fixed INTEGER DEFAULT 0,
        plastic_avoidance INTEGER DEFAULT 0,
        family_puja INTEGER DEFAULT 0,
        family_meditation INTEGER DEFAULT 0,
        meditation_participants TEXT,
        family_yoga INTEGER DEFAULT 0,
        yoga_participants TEXT,
        community_activities INTEGER DEFAULT 0,
        activity_types TEXT,
        shram_sadhana INTEGER DEFAULT 0,
        shram_participants TEXT,
        spiritual_discourses INTEGER DEFAULT 0,
        discourse_participants TEXT,
        family_happiness TEXT,
        happy_members TEXT,
        happiness_reasons TEXT,
        smoking_prevalence TEXT,
        drinking_prevalence TEXT,
        gudka_prevalence TEXT,
        gambling_prevalence TEXT,
        tobacco_prevalence TEXT,
        saving_habit TEXT,
        saving_percentage TEXT
      )
    ''');
    
    // Village Children Data
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_children_data (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        births_last_3_years INTEGER DEFAULT 0,
        infant_deaths_last_3_years INTEGER DEFAULT 0,
        malnourished_children INTEGER DEFAULT 0,
        malnourished_adults INTEGER DEFAULT 0
      )
    ''');

    // Village Malnutrition Data
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_malnutrition_data (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sr_no INTEGER NOT NULL,
        name TEXT,
        sex TEXT,
        age INTEGER,
        height_feet REAL,
        weight_kg REAL,
        disease_cause TEXT
      )
    ''');
    
    // Village BPL Families
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_bpl_families (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        total_bpl_families INTEGER DEFAULT 0,
        bpl_families_with_job_cards INTEGER DEFAULT 0,
        bpl_families_received_mgnrega INTEGER DEFAULT 0
      )
    ''');

    // Village Kitchen Gardens
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_kitchen_gardens (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        gardens_available INTEGER DEFAULT 0,
        total_gardens INTEGER DEFAULT 0
      )
    ''');
    
    // Village Seed Clubs
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_seed_clubs (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        clubs_available INTEGER DEFAULT 0,
        total_clubs INTEGER DEFAULT 0
      )
    ''');
    
    // Village Biodiversity Register (Updated)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_biodiversity_register (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        status TEXT,
        details TEXT,
        components TEXT,
        knowledge TEXT
      )
    ''');
    
    // Village Traditional Occupations
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_traditional_occupations (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sr_no INTEGER NOT NULL,
        occupation_name TEXT,
        families_engaged INTEGER,
        average_income REAL
      )
    ''');

    // Village Drainage and Waste
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_drainage_waste (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        earthen_drain INTEGER DEFAULT 0,
        masonry_drain INTEGER DEFAULT 0,
        covered_drain INTEGER DEFAULT 0,
        open_channel INTEGER DEFAULT 0,
        no_drainage_system INTEGER DEFAULT 0,
        drainage_destination TEXT,
        drainage_remarks TEXT,
        waste_collected_regularly INTEGER DEFAULT 0,
        waste_segregated INTEGER DEFAULT 0,
        waste_remarks TEXT
      )
    ''');
    
    // Village Irrigation Facilities
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_irrigation_facilities (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        has_canal INTEGER DEFAULT 0,
        has_tube_well INTEGER DEFAULT 0,
        has_ponds INTEGER DEFAULT 0,
        has_river INTEGER DEFAULT 0,
        has_well INTEGER DEFAULT 0
      )
    ''');

    // Village Signboards
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_signboards (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        signboards TEXT,
        info_boards TEXT,
        wall_writing TEXT
      )
    ''');

    // Village Social Maps (Remarks)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_social_maps (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        remarks TEXT
      )
    ''');
    
    // Village Survey Details (Landscape & Biodiversity Categories)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_survey_details (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        forest_details TEXT,
        wasteland_details TEXT,
        garden_details TEXT,
        burial_ground_details TEXT,
        crop_plants_details TEXT,
        vegetables_details TEXT,
        fruit_trees_details TEXT,
        animals_details TEXT,
        birds_details TEXT,
        local_biodiversity_details TEXT,
        traditional_knowledge_details TEXT,
        special_features_details TEXT
      )
    ''');
    
    // Village Map Points
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_map_points (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        latitude REAL,
        longitude REAL,
        category TEXT,
        remarks TEXT,
        point_id INTEGER
      )
    ''');

    // Village Forest Map
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_forest_maps (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        forest_area TEXT,
        forest_types TEXT,
        forest_resources TEXT,
        conservation_status TEXT,
        remarks TEXT
      )
    ''');
    
    // Village Transport Facilities
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_transport_facilities (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        tractor_count INTEGER DEFAULT 0,
        car_jeep_count INTEGER DEFAULT 0,
        motorcycle_scooter_count INTEGER DEFAULT 0,
        cycle_count INTEGER DEFAULT 0,
        e_rickshaw_count INTEGER DEFAULT 0,
        pickup_truck_count INTEGER DEFAULT 0
      )
    ''');
    
    // Village Infrastructure (Approach Roads & Internal Lanes)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_infrastructure (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        approach_roads_available INTEGER DEFAULT 0,
        num_approach_roads INTEGER,
        approach_condition TEXT,
        approach_remarks TEXT,
        internal_lanes_available INTEGER DEFAULT 0,
        num_internal_lanes INTEGER,
        internal_condition TEXT,
        internal_remarks TEXT
      )
    ''');

    // Village Infrastructure Details (Schools etc)
    // Using a simple JSON dump for flexibility or specific columns
    // Given the complexity of InfrastructureAvailabilityScreen, specific columns are better.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_infrastructure_details (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        has_primary_school INTEGER DEFAULT 0,
        primary_school_distance TEXT,
        has_junior_school INTEGER DEFAULT 0,
        junior_school_distance TEXT,
        has_high_school INTEGER DEFAULT 0,
        high_school_distance TEXT,
        has_intermediate_school INTEGER DEFAULT 0,
        intermediate_school_distance TEXT,
        other_education_facilities TEXT,
        boys_students_count INTEGER,
        girls_students_count INTEGER,
        has_playground INTEGER DEFAULT 0,
        playground_remarks TEXT,
        has_panchayat_bhavan INTEGER DEFAULT 0,
        panchayat_remarks TEXT,
        has_sharda_kendra INTEGER DEFAULT 0,
        sharda_kendra_distance TEXT,
        has_post_office INTEGER DEFAULT 0,
        post_office_distance TEXT,
        has_health_facility INTEGER DEFAULT 0,
        health_facility_distance TEXT,
        has_bank INTEGER DEFAULT 0,
        bank_distance TEXT,
        has_electrical_connection INTEGER DEFAULT 0,
        num_wells INTEGER,
        num_ponds INTEGER,
        num_hand_pumps INTEGER,
        num_tube_wells INTEGER,
        num_tap_water INTEGER
      )
    ''');

    // Village Cadastral Maps
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_cadastral_maps (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        has_cadastral_map INTEGER DEFAULT 0,
        map_details TEXT,
        availability_status TEXT
      )
    ''');

    // Village Unemployment
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_unemployment (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        unemployed_youth INTEGER DEFAULT 0,
        unemployed_adults INTEGER DEFAULT 0,
        total_unemployed INTEGER DEFAULT 0
      )
    ''');
  }

  // Close database
  Future<void> close() async {
    Database? db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}