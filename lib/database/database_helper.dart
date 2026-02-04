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

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'family_survey.db');
    return await openDatabase(
      path,
      version: 35,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createVillageTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 20) {
       // Ensure all tables are created (idempotent due to IF NOT EXISTS)
       await _createVillageTables(db);
    }
    if (oldVersion < 21) {
      // Add missing columns to surveys table
      await db.execute('ALTER TABLE surveys ADD COLUMN village_number TEXT');
      await db.execute('ALTER TABLE surveys ADD COLUMN surveyor_name TEXT');
      await db.execute('ALTER TABLE surveys ADD COLUMN phone_number TEXT');
      await db.execute('ALTER TABLE surveys ADD COLUMN surveyor_email TEXT');
    }
    if (oldVersion < 22) {
      await db.execute('ALTER TABLE pending_uploads ADD COLUMN status TEXT DEFAULT "pending"');
    }
    if (oldVersion < 23) {
      // Add missing columns to self_help_groups and fpo_members tables
      // For SHG members
      try {
        await db.execute('ALTER TABLE self_help_groups ADD COLUMN purpose TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE self_help_groups ADD COLUMN agency TEXT');
      } catch (_) {}
      
      // For FPO members
      try {
        await db.execute('ALTER TABLE fpo_members ADD COLUMN purpose TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE fpo_members ADD COLUMN agency TEXT');
      } catch (_) {}
    }
    if (oldVersion < 24) {
      // Add status column to training_data to distinguish between taken and needed
      try {
        await db.execute('ALTER TABLE training_data ADD COLUMN status TEXT DEFAULT "taken"');
      } catch (_) {}
    }
    if (oldVersion < 26) {
      // Recreate social_consciousness table with new schema
      await db.execute('DROP TABLE IF EXISTS social_consciousness');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS social_consciousness (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          survey_id INTEGER,
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

      // Update irrigation_facilities to match page keys
      await db.execute('ALTER TABLE irrigation_facilities ADD COLUMN ponds TEXT');
      await db.execute('ALTER TABLE irrigation_facilities ADD COLUMN other_facilities TEXT');
      await db.execute('ALTER TABLE irrigation_facilities ADD COLUMN other_irrigation_specify TEXT');
    }
    if (oldVersion < 27) {
      // Recreate medical_treatment table with proper schema
      await db.execute('DROP TABLE IF EXISTS medical_treatment');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS medical_treatment (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          survey_id INTEGER,
          allopathic TEXT,
          ayurvedic TEXT,
          homeopathy TEXT,
          traditional TEXT,
          other_treatment TEXT,
          preferred_treatment TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }
    if (oldVersion < 28) {
      // Recreate all village survey tables to ensure schema consistency
      // 1. Village Irrigation
      await db.execute('DROP TABLE IF EXISTS village_irrigation_facilities');
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
    }
    if (oldVersion < 33) {
      // CRITICAL MIGRATION: Remove surveys table and standardize to phone_number FKs
      
      // 1. Drop the legacy surveys table (replaced by family_survey_sessions)
      await db.execute('DROP TABLE IF EXISTS surveys');
      
      // 2. For each child table, drop survey_id column and add phone_number FK
      // Note: This migration assumes fresh install or acceptable data loss
      // For production with existing data, you would need to:
      // a) Create new columns
      // b) Migrate data from survey_id -> phone_number lookup
      // c) Drop old columns
      
      // Since user confirmed "OK to lose data", we proceed with clean slate approach
      final childTables = [
        'family_members', 'land_holding', 'irrigation_facilities', 'crop_productivity',
        'fertilizer_usage', 'animals', 'agricultural_equipment', 'entertainment_facilities',
        'transport_facilities', 'drinking_water_sources', 'medical_treatment', 'disputes',
        'house_conditions', 'house_facilities', 'diseases', 'folklore_medicine',
        'health_programmes', 'beneficiary_programs', 'social_consciousness', 'training_data',
        'self_help_groups', 'fpo_members', 'children_data', 'malnourished_children_data',
        'child_diseases', 'migration_data', 'tribal_questions', 'bank_accounts',
        'tulsi_plants', 'nutritional_garden', 'malnutrition_data',
        // Government scheme tables
        'aadhaar_info', 'aadhaar_members', 'ayushman_card', 'ayushman_members',
        'family_id', 'family_id_members', 'ration_card', 'ration_card_members',
        'samagra_id', 'samagra_children', 'tribal_card', 'tribal_card_members',
        'handicapped_allowance', 'handicapped_members', 'pension_allowance', 'pension_members',
        'widow_allowance', 'widow_members', 'vb_gram', 'vb_gram_members',
        'pm_kisan_nidhi', 'pm_kisan_members', 'merged_govt_schemes',
        // Scheme member tables
        'aadhaar_scheme_members', 'tribal_scheme_members', 'pension_scheme_members',
        'widow_scheme_members', 'ayushman_scheme_members', 'ration_scheme_members',
        'family_id_scheme_members', 'samagra_scheme_members', 'handicapped_scheme_members',
      ];
      
      for (final table in childTables) {
        try {
          // Check if table exists
          final result = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
            [table]
          );
          
          if (result.isNotEmpty) {
            // Drop survey_id column if exists (SQLite doesn't support DROP COLUMN directly)
            // We'll recreate the table structure properly on next clean install
            // For now, add phone_number if missing
            try {
              await db.execute('ALTER TABLE $table ADD COLUMN phone_number TEXT');
            } catch (_) {
              // Column might already exist, ignore error
            }
          }
        } catch (e) {
          db.print('Migration warning for $table: $e');
        }
      }
      
      // 3. Create indexes for performance
      await db.execute('CREATE INDEX IF NOT EXISTS idx_family_members_phone ON family_members(phone_number)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_land_holding_phone ON land_holding(phone_number)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_bank_accounts_phone ON bank_accounts(phone_number)');
      
      debugPrint('✓ Migration to v33 complete: phone_number standardization applied');
    }
    
    if (oldVersion < 34) {
      debugPrint('Running migration to v34: Adding banana_plants and papaya_trees to land_holding...');
      
      // Add missing fruit tree columns to land_holding
      try {
        await db.execute('ALTER TABLE land_holding ADD COLUMN banana_plants INTEGER DEFAULT 0');
      } catch (_) {
        // Column might already exist, ignore
      }
      
      try {
        await db.execute('ALTER TABLE land_holding ADD COLUMN papaya_trees INTEGER DEFAULT 0');
      } catch (_) {
        // Column might already exist, ignore
      }
      
      debugPrint('✓ Migration to v34 complete: banana_plants and papaya_trees columns added');
    }

      // 2. Village Survey Details (Landscape & Biodiversity)
      await db.execute('DROP TABLE IF EXISTS village_survey_details');
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

      // 3. Cadastral Maps
      await db.execute('DROP TABLE IF EXISTS village_cadastral_maps');
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

      // 4. Map Points
      await db.execute('DROP TABLE IF EXISTS village_map_points');
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

      // 5. Forest Maps
      await db.execute('DROP TABLE IF EXISTS village_forest_maps');
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

      // 6. Infrastructure Details
      await db.execute('DROP TABLE IF EXISTS village_infrastructure_details');
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

      // 7. Infrastructure (Roads)
      await db.execute('DROP TABLE IF EXISTS village_infrastructure');
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

      // 8. Educational Facilities (Update)
      await db.execute('DROP TABLE IF EXISTS village_educational_facilities');
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

      // 9. Seed Clubs
      await db.execute('DROP TABLE IF EXISTS village_seed_clubs');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS village_seed_clubs (
          id TEXT PRIMARY KEY,
          session_id TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          clubs_available INTEGER DEFAULT 0,
          total_clubs INTEGER DEFAULT 0
        )
      ''');

      // 10. Signboards
      await db.execute('DROP TABLE IF EXISTS village_signboards');
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

      // 11. Social Maps
      await db.execute('DROP TABLE IF EXISTS village_social_maps');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS village_social_maps (
          id TEXT PRIMARY KEY,
          session_id TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          remarks TEXT
        )
      ''');

      // 12. Transport Facilities (Count)
      await db.execute('DROP TABLE IF EXISTS village_transport_facilities');
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
      
      // 13. Drainage (Ensure up to date)
      await db.execute('DROP TABLE IF EXISTS village_drainage_waste');
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
    }
    if (oldVersion < 29) {
      // Recreate pending_uploads with correct schema for file uploads
      await db.execute('DROP TABLE IF EXISTS pending_uploads');
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
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }
    if (oldVersion < 30) {
      // Add missing columns to pending_uploads for error tracking
      try {
        await db.execute('ALTER TABLE pending_uploads ADD COLUMN last_attempt_at TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE pending_uploads ADD COLUMN error_message TEXT');
      } catch (_) {}
    }
    if (oldVersion < 31) {
      // Add missing government scheme tables
      await db.execute('CREATE TABLE IF NOT EXISTS ayushman_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, survey_id INTEGER, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
      await db.execute('CREATE TABLE IF NOT EXISTS ration_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, survey_id INTEGER, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
      await db.execute('CREATE TABLE IF NOT EXISTS family_id_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, survey_id INTEGER, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
      await db.execute('CREATE TABLE IF NOT EXISTS samagra_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, survey_id INTEGER, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
      await db.execute('CREATE TABLE IF NOT EXISTS handicapped_scheme_members (id INTEGER PRIMARY KEY AUTOINCREMENT, survey_id INTEGER, sr_no INTEGER, family_member_name TEXT, have_card TEXT, card_number TEXT, details_correct TEXT, what_incorrect TEXT, benefits_received TEXT, created_at TEXT)');
    }
    if (oldVersion < 32) {
      // Fix Village Irrigation Facilities schema (ensure has_canal columns exist)
      await db.execute('DROP TABLE IF EXISTS village_irrigation_facilities');
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
        device_info TEXT,
        app_version TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_deleted INTEGER DEFAULT 0,
        last_synced_at TEXT,
        current_version INTEGER DEFAULT 1,
        last_edited_at TEXT
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
        id TEXT PRIMARY KEY,
        phone_number TEXT UNIQUE NOT NULL,
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
        latitude REAL,
        longitude REAL,
        location_accuracy REAL,
        location_timestamp TEXT,
        survey_date TEXT DEFAULT CURRENT_DATE,
        surveyor_name TEXT,
        status TEXT DEFAULT 'in_progress',
        device_info TEXT,
        app_version TEXT,
        created_by TEXT,
        updated_by TEXT,
        is_deleted INTEGER DEFAULT 0,
        last_synced_at TEXT,
        current_version INTEGER DEFAULT 1,
        last_edited_at TEXT DEFAULT CURRENT_TIMESTAMP
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
        income REAL,
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
        irrigated_area REAL,
        cultivable_area REAL,
        unirrigated_area REAL,
        barren_land REAL,
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

    // Village Survey Tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS village_survey_sessions (
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
    
    await _createRemainingTables(db);
    await _createVillageTables(db);
  }

  Future<void> _createRemainingTables(Database db) async {
    // Land Holding (if not already created)
    await db.execute('CREATE TABLE IF NOT EXISTS land_holding (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, irrigated_area REAL, cultivable_area REAL, unirrigated_area REAL, barren_land REAL, mango_trees INTEGER, guava_trees INTEGER, lemon_trees INTEGER, pomegranate_trees INTEGER, other_fruit_trees_name TEXT, other_fruit_trees_count INTEGER, created_at TEXT)');
    
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
    
    // Beneficiary Programs
    await db.execute('CREATE TABLE IF NOT EXISTS beneficiary_programs (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, program_type TEXT, beneficiary INTEGER, member_name TEXT, name_included INTEGER, details_correct INTEGER, incorrect_details TEXT, days_worked INTEGER, received INTEGER, created_at TEXT)');

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

    // SHG Members (self_help_groups)
    await db.execute('CREATE TABLE IF NOT EXISTS self_help_groups (id INTEGER PRIMARY KEY AUTOINCREMENT, phone_number TEXT, member_name TEXT, shg_name TEXT, purpose TEXT, agency TEXT, position TEXT, monthly_saving REAL, created_at TEXT)');

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
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    Database db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs}) async {
    Database db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<dynamic>? whereArgs}) async {
    Database db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    Database db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Survey specific operations
  Future<int> createSurvey(Map<String, dynamic> surveyData) async {
    Database db = await database;
    return await db.insert('surveys', surveyData);
  }

  Future<List<Map<String, dynamic>>> getAllSurveys() async {
    Database db = await database;
    return await db.query('surveys', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getSurvey(int surveyId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'surveys',
      where: 'id = ?',
      whereArgs: [surveyId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateSurveySyncStatus(int surveyId, bool synced) async {
    Database db = await database;
    await db.update(
      'surveys',
      {'synced': synced ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [surveyId],
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedSurveys() async {
    Database db = await database;
    return await db.query('surveys', where: 'synced = 0');
  }

  // Survey data saving method
  Future<void> saveSurveyData(Map<String, dynamic> data) async {
    // Skip database operations on web
    if (kIsWeb) {
      print('Web platform detected - skipping database save');
      return;
    }

    Database db = await database;

    await db.transaction((txn) async {
      // Insert or update main survey data
      int surveyId = await txn.insert('surveys', {
        'village_name': data['village_name'],
        'panchayat': data['panchayat'],
        'block': data['block'],
        'district': data['district'],
        'postal_address': data['postal_address'],
        'pin_code': data['pin_code'],
        'survey_date': data['survey_date'] ?? DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Save data to appropriate tables based on keys
      for (var entry in data.entries) {
        switch (entry.key) {
          case 'family_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                final memberData = Map<String, dynamic>.from(member);
                // memberData.remove('sr_no'); // Keep sr_no if essential, but existing schema had it.

                await txn.insert('family_members', { // FIXED: family_details -> family_members
                  ...memberData,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'land_holding':
            await txn.insert('land_holding', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'irrigation_facilities':
            await txn.insert('irrigation_facilities', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'crop_productivity':
            if (entry.value is List) {
              for (var crop in entry.value) {
                await txn.insert('crop_productivity', {
                  ...crop,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'fertilizer_usage':
            await txn.insert('fertilizer_usage', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'animals':
            if (entry.value is List) {
              for (var animal in entry.value) {
                final animalData = Map<String, dynamic>.from(animal);
                animalData.remove('sr_no');

                await txn.insert('animals', {
                  ...animalData,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'agricultural_equipment':
            await txn.insert('agricultural_equipment', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'entertainment_facilities':
            await txn.insert('entertainment_facilities', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'transport_facilities':
            await txn.insert('transport_facilities', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'drinking_water_sources':
            await txn.insert('drinking_water_sources', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'medical_treatment':
            await txn.insert('medical_treatment', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'disputes':
            await txn.insert('disputes', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'house_conditions':
            await txn.insert('house_conditions', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'house_facilities':
            await txn.insert('house_facilities', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'diseases':
            if (entry.value is List) {
              for (var disease in entry.value) {
                await txn.insert('diseases', {
                  ...disease,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'government_schemes':
            if (entry.value is List) {
              for (var scheme in entry.value) {
                await txn.insert('government_schemes', {
                  ...scheme,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'beneficiary_programs':
            if (entry.value is List) {
              for (var program in entry.value) {
                await txn.insert('beneficiary_programs', {
                  ...program,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'aadhaar_scheme_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('aadhaar_scheme_members', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'tribal_scheme_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('tribal_scheme_members', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'pension_scheme_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('pension_scheme_members', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'widow_scheme_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('widow_scheme_members', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'ayushman_scheme_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('ayushman_scheme_members', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'ration_scheme_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('ration_scheme_members', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'family_id_scheme_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('family_id_scheme_members', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'samagra_scheme_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('samagra_scheme_members', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'handicapped_scheme_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('handicapped_scheme_members', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'training_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('training_data', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'self_help_groups':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('self_help_groups', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'fpo_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                await txn.insert('fpo_members', {
                  ...member,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'vb_gram_g':
          case 'pm_kisan_nidhi':
          case 'pm_kisan_samman_nidhi':
          case 'kisan_credit_card':
          case 'swachh_bharat_mission':
          case 'fasal_bima':
            var data = entry.value as Map<String, dynamic>;
            bool isBeneficiary = data['is_beneficiary'] ?? false;
            if (isBeneficiary) {
              var members = data['members'] as List;
              for (var m in members) {
                await txn.insert('beneficiary_programs', {
                  'survey_id': surveyId,
                  'program_type': entry.key,
                  'beneficiary': 1,
                  'member_name': m['name'],
                  'name_included': (m['name_included'] == true) ? 1 : 0,
                  'details_correct': (m['details_correct'] == true) ? 1 : 0,
                  'incorrect_details': m['incorrect_details'],
                  'days_worked': int.tryParse(m['days']?.toString() ?? '0'),
                  'received': (m['received'] == true) ? 1 : 0,
                });
              }
            } else {
               await txn.insert('beneficiary_programs', {
                  'survey_id': surveyId,
                  'program_type': entry.key,
                  'beneficiary': 0,
               });
            }
            break;
          case 'social_consciousness':
            await txn.insert('social_consciousness', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'animals':
            await txn.insert('animals', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'equipment':
            await txn.insert('agricultural_equipment', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'entertainment':
            await txn.insert('entertainment_facilities', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'transport':
            await txn.insert('transport_facilities', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'water_sources':
            await txn.insert('drinking_water_sources', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'medical':
             // medical_treatment stores phone_number as ID, so create generic insert
             // Data structure from page might be single Map
            await txn.insert('medical_treatment', {
               ...entry.value,
               'phone_number': data['phone_number'] ?? 'unknown',
             });
            break;
          case 'disputes':
            await txn.insert('disputes', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'house_conditions':
            await txn.insert('house_conditions', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'diseases':
            if (entry.value is List) {
              for (var disease in entry.value) {
                await txn.insert('diseases', {
                  ...disease,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'folklore_medicines':
            if (entry.value is List) {
              for (var medicine in entry.value) {
                await txn.insert('folklore_medicine', {
                  ...medicine,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'health_programme':
            await txn.insert('health_programmes', {
              ...entry.value,
              'survey_id': surveyId,
            });
            break;
          case 'training_members':
            if (entry.value is List) {
              for (var training in entry.value) {
                await txn.insert('training_data', {
                  ...training,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'self_help_groups':
            if (entry.value is List) {
              for (var shg in entry.value) {
                await txn.insert('self_help_groups', {
                  ...shg,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'fpo_members':
            if (entry.value is List) {
              for (var fpo in entry.value) {
                await txn.insert('fpo_members', {
                  ...fpo,
                  'survey_id': surveyId,
                });
              }
            }
            break;
          case 'children': // Data from ChildrenPage
             // This needs mapping to children_data 
             // Form: births_last_3_years, etc are Top Level keys in pageData?
             // Let's check how they are passed.
             // If key is 'children', it might be boolean? No.
             break;
          case 'malnourished_children_data':
             if (entry.value is List) {
               for (var child in entry.value) {
                 await txn.insert('malnourished_children_data', {
                   ...child,
                   'survey_id': surveyId,
                 });
               }
             }
             break;
           // TODO: Add cases for beneficiary schemes (vb_g_ram_g, etc) 
           // and handle top-level children data separately (since it's not in a sub-map)
        }
      }

      // Handle top-level fields that belong to separate tables but aren't in their own map
      // Children Data
      if (data.containsKey('births_last_3_years')) {
        await txn.insert('children_data', {
          'births_last_3_years': data['births_last_3_years'],
          'infant_deaths_last_3_years': data['infant_deaths_last_3_years'],
          'malnourished_children': data['malnourished_children'],
          'survey_id': surveyId,
        });
      }

      // Migration
      if (data.containsKey('migration')) {
         // If migration is strictly boolean, we might need to check other keys
         await txn.insert('migration_data', {
           'family_members_migrated': data['migration'] == true ? 1 : 0, // Simplification
           'reason': data['migration_reason'], // Assumption
           'survey_id': surveyId,
         });
      }

      // Beneficiary Schemes
      final schemes = [
        {'key': 'vb_g_ram_g', 'type': 'VB-G-RAM-G'},
        {'key': 'pm_kisan', 'type': 'PM Kisan'},
        {'key': 'kisan_credit_card', 'type': 'Kisan Credit Card'},
        {'key': 'swachh_bharat', 'type': 'Swachh Bharat'},
        {'key': 'fasal_bima', 'type': 'Fasal Bima'},
      ];

      for (var scheme in schemes) {
        if (data.containsKey(scheme['key'])) {
          final schemeData = data[scheme['key']];
          if (schemeData is Map) {
             // Save main beneficiary status if needed? Table schema seems to support individual members?
             // Table: beneficiary_programs (program_type, beneficiary, member_name...)
             // schemeData usually has 'members' List inside
             if (schemeData['members'] is List) {
               for (var member in schemeData['members']) {
                 await txn.insert('beneficiary_programs', {
                   ...member,
                   'program_type': scheme['type'],
                   'survey_id': surveyId,
                 });
               }
             }
          }
        }
      }

    });
  }

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