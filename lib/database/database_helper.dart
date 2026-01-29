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

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'family_survey.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS family_details');
      await db.execute('''
        CREATE TABLE family_details (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          survey_id INTEGER,
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
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add sync support columns
      await db.execute('ALTER TABLE surveys ADD COLUMN remote_id TEXT');
      await db.execute('ALTER TABLE surveys ADD COLUMN is_deleted INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE family_details ADD COLUMN remote_id TEXT');
      await db.execute('ALTER TABLE family_details ADD COLUMN is_deleted INTEGER DEFAULT 0');
    }
    
    // Version 4: Add missing tables for data synchronization
    if (oldVersion < 4) {
       // Migration Data
       await db.execute('''
        CREATE TABLE IF NOT EXISTS migration_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          survey_id INTEGER,
          member_count INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
        )
      ''');

      // Training Data
      await db.execute('''
        CREATE TABLE IF NOT EXISTS training_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          survey_id INTEGER,
          sr_no INTEGER,
          name TEXT,
          gender TEXT,
          age INTEGER,
          training_type TEXT,
          duration TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
        )
      ''');

      // Self Help Groups
      await db.execute('''
        CREATE TABLE IF NOT EXISTS self_help_groups (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          survey_id INTEGER,
          sr_no INTEGER,
          group_name TEXT,
          member_name TEXT,
          role TEXT,
          monthly_saving REAL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
        )
      ''');
      
      // Social Consciousness
      await db.execute('''
        CREATE TABLE IF NOT EXISTS social_consciousness (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          survey_id INTEGER,
          clothing_frequency TEXT,
          food_waste TEXT,
          waste_disposal TEXT,
          toilet_usage TEXT,
          energy_saving TEXT,
          water_conservation TEXT,
          plastic_usage TEXT,
          addictions TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
        )
      ''');
      
      // Bank Accounts
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bank_accounts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          survey_id INTEGER,
          sr_no INTEGER,
          member_name TEXT,
          account_type TEXT,
          bank_name TEXT,
          has_kcc TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> _createTables(Database db) async {
    // Main Survey Table
    await db.execute('''
      CREATE TABLE surveys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT,
        survey_date TEXT NOT NULL DEFAULT CURRENT_DATE,
        village_name TEXT,
        panchayat TEXT,
        block TEXT,
        tehsil TEXT,
        district TEXT,
        postal_address TEXT,
        pin_code TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    // Family Details Table
    await db.execute('''
      CREATE TABLE family_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT,
        survey_id INTEGER,
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
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Land Holding Table
    await db.execute('''
      CREATE TABLE land_holding (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        irrigated_area REAL,
        cultivable_area REAL,
        orchard_plants TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Irrigation Facilities Table
    await db.execute('''
      CREATE TABLE irrigation_facilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        canal INTEGER DEFAULT 0,
        tube_well INTEGER DEFAULT 0,
        ponds INTEGER DEFAULT 0,
        other_facilities TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Crop Productivity Table
    await db.execute('''
      CREATE TABLE crop_productivity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        crop_name TEXT,
        area_acres REAL,
        productivity_quintal_per_acre REAL,
        total_production REAL,
        quantity_consumed REAL,
        quantity_sold_quintal REAL,
        quantity_sold_rupees REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Fertilizer Usage Table
    await db.execute('''
      CREATE TABLE fertilizer_usage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        chemical INTEGER DEFAULT 0,
        organic INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Animals Table
    await db.execute('''
      CREATE TABLE animals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        animal_type TEXT,
        number_of_animals INTEGER,
        breed TEXT,
        production_per_animal REAL,
        quantity_sold REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Agricultural Equipment Table
    await db.execute('''
      CREATE TABLE agricultural_equipment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        tractor INTEGER DEFAULT 0,
        thresher INTEGER DEFAULT 0,
        seed_drill INTEGER DEFAULT 0,
        sprayer INTEGER DEFAULT 0,
        duster INTEGER DEFAULT 0,
        diesel_engine INTEGER DEFAULT 0,
        other_equipment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Entertainment Facilities Table
    await db.execute('''
      CREATE TABLE entertainment_facilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        smart_mobile INTEGER DEFAULT 0,
        smart_mobile_count INTEGER,
        analog_mobile INTEGER DEFAULT 0,
        analog_mobile_count INTEGER,
        television INTEGER DEFAULT 0,
        radio INTEGER DEFAULT 0,
        games INTEGER DEFAULT 0,
        other_entertainment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Transport Facilities Table
    await db.execute('''
      CREATE TABLE transport_facilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        car_jeep INTEGER DEFAULT 0,
        motorcycle_scooter INTEGER DEFAULT 0,
        e_rickshaw INTEGER DEFAULT 0,
        cycle INTEGER DEFAULT 0,
        pickup_truck INTEGER DEFAULT 0,
        bullock_cart INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Drinking Water Sources Table
    await db.execute('''
      CREATE TABLE drinking_water_sources (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        hand_pumps INTEGER DEFAULT 0,
        hand_pumps_distance REAL,
        well INTEGER DEFAULT 0,
        well_distance REAL,
        tubewell INTEGER DEFAULT 0,
        tubewell_distance REAL,
        nal_jaal INTEGER DEFAULT 0,
        other_sources TEXT,
        other_distance REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Medical Treatment Methods Table
    await db.execute('''
      CREATE TABLE medical_treatment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        allopathic INTEGER DEFAULT 0,
        ayurvedic INTEGER DEFAULT 0,
        homeopathy INTEGER DEFAULT 0,
        traditional INTEGER DEFAULT 0,
        jhad_phook INTEGER DEFAULT 0,
        other_methods TEXT,
        preferences TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Disputes Table
    await db.execute('''
      CREATE TABLE disputes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        family_disputes INTEGER DEFAULT 0,
        family_registered INTEGER DEFAULT 0,
        revenue_disputes INTEGER DEFAULT 0,
        revenue_registered INTEGER DEFAULT 0,
        criminal_disputes INTEGER DEFAULT 0,
        criminal_registered INTEGER DEFAULT 0,
        other_disputes TEXT,
        dispute_period TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // House Conditions Table
    await db.execute('''
      CREATE TABLE house_conditions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        katcha INTEGER DEFAULT 0,
        pakka INTEGER DEFAULT 0,
        katcha_pakka INTEGER DEFAULT 0,
        hut INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // House Facilities Table
    await db.execute('''
      CREATE TABLE house_facilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
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
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Nutritional Kitchen Garden Table
    await db.execute('''
      CREATE TABLE nutritional_garden (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        available INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Serious Diseases Table
    await db.execute('''
      CREATE TABLE serious_diseases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        member_name TEXT,
        age INTEGER,
        sex TEXT,
        disease_name TEXT,
        suffering_since TEXT,
        treatment_from TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Government Schemes Table
    await db.execute('''
      CREATE TABLE government_schemes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        scheme_type TEXT,
        have_card INTEGER DEFAULT 0,
        name_included INTEGER DEFAULT 0,
        details_correct INTEGER DEFAULT 0,
        member_name TEXT,
        age INTEGER,
        sex TEXT,
        eligible INTEGER DEFAULT 0,
        registered INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Folklore Medicine Table
    await db.execute('''
      CREATE TABLE folklore_medicine (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        person_name TEXT,
        plant_local_name TEXT,
        plant_botanical_name TEXT,
        plant_uses TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Health Programs Table
    await db.execute('''
      CREATE TABLE health_programs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        pregnancy_vaccination INTEGER DEFAULT 0,
        child_vaccination INTEGER DEFAULT 0,
        vaccination_completed INTEGER DEFAULT 0,
        vaccination_schedule TEXT,
        family_planning_awareness INTEGER DEFAULT 0,
        contraceptive_applied INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Children's Data Table
    await db.execute('''
      CREATE TABLE children_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        births_last_3_years INTEGER DEFAULT 0,
        infant_deaths_last_3_years INTEGER DEFAULT 0,
        malnourished_children INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Malnutrition Data Table
    await db.execute('''
      CREATE TABLE malnutrition_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        member_name TEXT,
        sex TEXT,
        age INTEGER,
        height_feet REAL,
        weight_kg REAL,
        cause_disease TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Tulsi Plants Table
    await db.execute('''
      CREATE TABLE tulsi_plants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        available INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Migration Table
    await db.execute('''
      CREATE TABLE migration (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        migration_type TEXT,
        member_name TEXT,
        distance TEXT,
        job_description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Training Table
    await db.execute('''
      CREATE TABLE training (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        member_name TEXT,
        training_type TEXT,
        institute TEXT,
        year_of_passing INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Self Help Groups Table
    await db.execute('''
      CREATE TABLE self_help_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        member_name TEXT,
        shg_name TEXT,
        purpose TEXT,
        agency TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Farmer Producer Organizations Table
    await db.execute('''
      CREATE TABLE fpo_membership (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        member_name TEXT,
        fpo_name TEXT,
        purpose TEXT,
        agency TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Government Beneficiary Programs Table
    await db.execute('''
      CREATE TABLE beneficiary_programs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        program_type TEXT,
        beneficiary INTEGER DEFAULT 0,
        name_included INTEGER DEFAULT 0,
        details_correct INTEGER DEFAULT 0,
        received INTEGER DEFAULT 0,
        member_name TEXT,
        days_worked INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Bank Accounts Table
    await db.execute('''
      CREATE TABLE bank_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        member_name TEXT,
        has_account INTEGER DEFAULT 0,
        details_correct INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Social Consciousness Survey Table
    await db.execute('''
      CREATE TABLE social_consciousness (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        question_number INTEGER,
        response TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Tribal Additional Questions Table
    await db.execute('''
      CREATE TABLE tribal_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        individual_forest_claims TEXT,
        claim_map TEXT,
        palash_leaf_collector INTEGER DEFAULT 0,
        collection_areas TEXT,
        honey_gatherer INTEGER DEFAULT 0,
        honey_collection_areas TEXT,
        ntfp_identification TEXT,
        stakeholder_shgs TEXT,
        skills_identification TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (survey_id) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_surveys_synced ON surveys(synced)');
    await db.execute('CREATE INDEX idx_family_details_survey_id ON family_details(survey_id)');
    await db.execute('CREATE INDEX idx_land_holding_survey_id ON land_holding(survey_id)');
    await db.execute('CREATE INDEX idx_crop_productivity_survey_id ON crop_productivity(survey_id)');
    await db.execute('CREATE INDEX idx_animals_survey_id ON animals(survey_id)');
    await db.execute('CREATE INDEX idx_government_schemes_survey_id ON government_schemes(survey_id)');
    await db.execute('CREATE INDEX idx_beneficiary_programs_survey_id ON beneficiary_programs(survey_id)');
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
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Save data to appropriate tables based on keys
      for (var entry in data.entries) {
        switch (entry.key) {
          case 'family_members':
            if (entry.value is List) {
              for (var member in entry.value) {
                final memberData = Map<String, dynamic>.from(member);
                memberData.remove('sr_no');

                await txn.insert('family_details', {
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
          case 'serious_diseases':
            if (entry.value is List) {
              for (var disease in entry.value) {
                await txn.insert('serious_diseases', {
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
          // Add more cases as needed for other data types
        }
      }
    });
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
