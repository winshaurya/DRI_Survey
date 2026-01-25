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
      path = join(databasesPath, 'dri_survey.db');
    } else if (Platform.isIOS) {
      // For iOS, use application documents directory
      final directory = await getApplicationDocumentsDirectory();
      path = join(directory.path, 'dri_survey.db');
    } else {
      // For other platforms, use application documents directory
      final directory = await getApplicationDocumentsDirectory();
      path = join(directory.path, 'dri_survey.db');
    }

    return await openDatabase(
      path,
      version: 1,
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
    // Handle database upgrades here if needed
  }

  Future<String> _loadSchema() async {
    // For now, return the schema as a string
    // In production, you might want to load this from assets
    return '''
-- DRI Survey App Database Schema
-- Compatible with both SQLite and PostgreSQL

-- Enable foreign keys for SQLite
PRAGMA foreign_keys = ON;

-- Survey Sessions Table (tracks each survey instance)
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
    survey_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    surveyor_name TEXT,
    status TEXT DEFAULT 'in_progress',
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Family Members Table
CREATE TABLE family_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone_number TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT NOT NULL,
    fathers_name TEXT,
    mothers_name TEXT,
    relationship_with_head TEXT,
    age INTEGER,
    sex TEXT,
    physically_fit TEXT,
    educational_qualification TEXT,
    inclination_self_employment TEXT,
    occupation TEXT,
    days_employed INTEGER,
    income REAL,
    awareness_about_village TEXT,
    participate_gram_sabha TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
);

-- Land Holding Information
CREATE TABLE land_holding (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone_number TEXT NOT NULL,
    irrigated_area REAL,
    cultivable_area REAL,
    orchard_plants_type TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (phone_number) REFERENCES survey_sessions(phone_number) ON DELETE CASCADE
);

-- Irrigation Facilities
CREATE TABLE irrigation_facilities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    canal TEXT,
    tube_well TEXT,
    ponds TEXT,
    other_sources TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Crop Productivity
CREATE TABLE crop_productivity (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    crop_name TEXT,
    area_acres REAL,
    productivity_quintal_per_acre REAL,
    total_production REAL,
    quantity_consumed REAL,
    quantity_sold REAL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Fertilizer Usage
CREATE TABLE fertilizer_usage (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    chemical_fertilizer TEXT,
    organic_fertilizer TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Animals Information
CREATE TABLE animals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    animal_type TEXT,
    number_of_animals INTEGER,
    breed TEXT,
    production_per_animal REAL,
    quantity_sold REAL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Agricultural Equipment
CREATE TABLE agricultural_equipment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    tractor TEXT,
    thresher TEXT,
    seed_drill TEXT,
    sprayer TEXT,
    duster TEXT,
    diesel_engine TEXT,
    other_equipment TEXT,
    other_specify TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Entertainment Facilities
CREATE TABLE entertainment_facilities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    smart_mobile TEXT,
    smart_mobile_count INTEGER,
    analog_mobile TEXT,
    analog_mobile_count INTEGER,
    television TEXT,
    radio TEXT,
    games TEXT,
    other_entertainment TEXT,
    other_specify TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Transport Facilities
CREATE TABLE transport_facilities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    car_jeep TEXT,
    motorcycle_scooter TEXT,
    e_rickshaw TEXT,
    cycle TEXT,
    pickup_truck TEXT,
    bullock_cart TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Drinking Water Sources
CREATE TABLE drinking_water_sources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    hand_pumps TEXT,
    hand_pumps_distance REAL,
    well TEXT,
    well_distance REAL,
    tubewell TEXT,
    tubewell_distance REAL,
    nal_jaal TEXT,
    other_source TEXT,
    other_distance REAL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Medical Treatment Methods
CREATE TABLE medical_treatment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    allopathic TEXT,
    ayurvedic TEXT,
    homeopathy TEXT,
    traditional TEXT,
    jhad_phook TEXT,
    other_treatment TEXT,
    preference_order TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Disputes Information
CREATE TABLE disputes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    family_disputes TEXT,
    family_registered TEXT,
    family_period TEXT,
    revenue_disputes TEXT,
    revenue_registered TEXT,
    revenue_period TEXT,
    criminal_disputes TEXT,
    criminal_registered TEXT,
    criminal_period TEXT,
    other_disputes TEXT,
    other_description TEXT,
    other_registered TEXT,
    other_period TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- House Conditions
CREATE TABLE house_conditions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    katcha TEXT,
    pakka TEXT,
    katcha_pakka TEXT,
    hut TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- House Facilities
CREATE TABLE house_facilities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    toilet TEXT,
    toilet_in_use TEXT,
    drainage TEXT,
    soak_pit TEXT,
    cattle_shed TEXT,
    compost_pit TEXT,
    nadep TEXT,
    lpg_gas TEXT,
    biogas TEXT,
    solar_cooking TEXT,
    electric_connection TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Nutritional Kitchen Garden
CREATE TABLE nutritional_garden (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    available TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Diseases Information
CREATE TABLE diseases (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    disease_name TEXT,
    suffering_since TEXT,
    treatment_from TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Aadhaar
CREATE TABLE aadhaar_info (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    have_aadhaar TEXT,
    name_included TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Aadhaar Members
CREATE TABLE aadhaar_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    registered TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Ayushman Card
CREATE TABLE ayushman_card (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    eligible TEXT,
    have_card TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Ayushman Members
CREATE TABLE ayushman_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    registered TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Family ID
CREATE TABLE family_id (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    have_family_id TEXT,
    name_included TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Family ID Members
CREATE TABLE family_id_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    registered TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Ration Card
CREATE TABLE ration_card (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    have_ration_card TEXT,
    name_included TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Ration Card Members
CREATE TABLE ration_card_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    registered TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Samagra ID
CREATE TABLE samagra_id (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Samagra ID Children
CREATE TABLE samagra_children (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    have_id TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Tribal Card
CREATE TABLE tribal_card (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    applicable TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Tribal Card Members
CREATE TABLE tribal_card_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    registered TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Handicapped Allowance
CREATE TABLE handicapped_allowance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    applicable TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Handicapped Members
CREATE TABLE handicapped_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    registered TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Pension Allowance
CREATE TABLE pension_allowance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    applicable TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Pension Members
CREATE TABLE pension_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    registered TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Widow Allowance
CREATE TABLE widow_allowance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    applicable TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Widow Members
CREATE TABLE widow_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    registered TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Folklore Medicine Knowledge
CREATE TABLE folklore_medicine (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    person_name TEXT,
    plant_local_name TEXT,
    plant_botanical_name TEXT,
    uses TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Health Programmes
CREATE TABLE health_programmes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    vaccination_pregnancy TEXT,
    child_vaccination TEXT,
    vaccination_schedule TEXT,
    family_planning_awareness TEXT,
    contraceptive_applied TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Children's Data
CREATE TABLE children_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    births_last_3_years INTEGER,
    infant_deaths_last_3_years INTEGER,
    malnourished_children_adults INTEGER,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Malnutrition Data
CREATE TABLE malnutrition_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    sex TEXT,
    age INTEGER,
    height_feet REAL,
    weight_kg REAL,
    cause_disease TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Tulsi Plants
CREATE TABLE tulsi_plants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    available TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Migration Data
CREATE TABLE migration_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    migration_type TEXT,
    distance TEXT,
    job_description TEXT,
    member_count INTEGER,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Training Data
CREATE TABLE training_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    training_type TEXT,
    training_institute TEXT,
    year_of_passing INTEGER,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Self Help Groups
CREATE TABLE self_help_groups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    shg_name TEXT,
    purpose TEXT,
    agency TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Farmer Producer Organizations
CREATE TABLE fpo_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    fpo_name TEXT,
    purpose TEXT,
    agency TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - VB Gram
CREATE TABLE vb_gram (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    beneficiary TEXT,
    name_included TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- VB Gram Members
CREATE TABLE vb_gram_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    received TEXT,
    days_worked INTEGER,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - PM Kisan Nidhi
CREATE TABLE pm_kisan_nidhi (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    beneficiary TEXT,
    name_included TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- PM Kisan Nidhi Members
CREATE TABLE pm_kisan_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    received TEXT,
    days_worked INTEGER,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - PM Kisan Samman Nidhi
CREATE TABLE pm_kisan_samman (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    beneficiary TEXT,
    received TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Kisan Credit Card
CREATE TABLE kisan_credit_card (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    beneficiary TEXT,
    received TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Swachh Bharat Mission
CREATE TABLE swachh_bharat (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    beneficiary TEXT,
    received TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Fasal Bima
CREATE TABLE fasal_bima (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    beneficiary TEXT,
    received TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Bank Accounts
CREATE TABLE bank_accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    have_account TEXT,
    details_correct TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Social Consciousness Survey
CREATE TABLE social_consciousness (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    buy_clothes_frequency TEXT,
    food_waste TEXT,
    food_waste_amount TEXT,
    waste_disposal TEXT,
    waste_segregation TEXT,
    compost_pit TEXT,
    recycle_items TEXT,
    toilet_available TEXT,
    toilet_in_use TEXT,
    toilet_soak_pit TEXT,
    led_lights TEXT,
    turn_off_devices TEXT,
    fix_leaks TEXT,
    avoid_plastics TEXT,
    family_puja TEXT,
    family_meditate TEXT,
    meditate_who TEXT,
    family_yoga TEXT,
    yoga_who TEXT,
    community_activities TEXT,
    activities_type TEXT,
    shram_sadhana TEXT,
    shram_who TEXT,
    spiritual_discourses TEXT,
    discourses_who TEXT,
    family_happy TEXT,
    members_happy TEXT,
    happy_who TEXT,
    smoking TEXT,
    drinking TEXT,
    gudka TEXT,
    gambling TEXT,
    tobacco TEXT,
    saving_habit TEXT,
    saving_percentage TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Tribal Families Additional Questions
CREATE TABLE tribal_questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    individual_forest_claims TEXT,
    claim_map TEXT,
    palash_collectors TEXT,
    collection_areas_palash TEXT,
    honey_gatherers TEXT,
    collection_areas_honey TEXT,
    ntfp_collection TEXT,
    ntfp_stakeholders TEXT,
    skills_identification TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

  -- Village Survey - Sessions
  CREATE TABLE village_survey_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    village_name TEXT,
    village_code TEXT,
    state TEXT,
    district TEXT,
    block TEXT,
    panchayat TEXT,
    tehsil TEXT,
    ldg_code TEXT,
    gps_link TEXT,
    status TEXT DEFAULT 'in_progress',
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  -- Village Survey - Population
  CREATE TABLE village_population (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    total_families TEXT,
    total_members TEXT,
    men TEXT,
    women TEXT,
    male_children TEXT,
    female_children TEXT,
    caste TEXT,
    religion TEXT,
    other_religion TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE
  );

  -- Village Survey - Farm Families
  CREATE TABLE village_farm_families (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    big_farmers TEXT,
    small_farmers TEXT,
    marginal_farmers TEXT,
    landless_farmers TEXT,
    total_farm_families TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE
  );

-- Indexes for better performance
CREATE INDEX idx_survey_sessions_status ON survey_sessions(status);
CREATE INDEX idx_survey_sessions_date ON survey_sessions(survey_date);
CREATE INDEX idx_family_members_session ON family_members(session_id);
CREATE INDEX idx_crop_productivity_session ON crop_productivity(session_id);
CREATE INDEX idx_animals_session ON animals(session_id);
CREATE INDEX idx_diseases_session ON diseases(session_id);
CREATE INDEX idx_training_session ON training_data(session_id);
CREATE INDEX idx_shg_session ON self_help_groups(session_id);
CREATE INDEX idx_fpo_session ON fpo_members(session_id);
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
  }) async {
    if (kIsWeb) return '';

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
      'surveyor_name': surveyorName,
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
    if (kIsWeb) return null;

    final db = await database;
    final results = await db.query(
      'survey_sessions',
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateSurveyStatus(String phoneNumber, String status) async {
    if (kIsWeb) return;

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
    if (kIsWeb) return;

    final db = await database;
    data['created_at'] = DateTime.now().toIso8601String();

    await db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getData(String tableName, String phoneNumber) async {
    if (kIsWeb) return [];

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
    if (kIsWeb) return;

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
