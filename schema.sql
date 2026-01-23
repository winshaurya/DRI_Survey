-- DRI Survey App Database Schema
-- Compatible with both SQLite and PostgreSQL

-- Enable foreign keys for SQLite
PRAGMA foreign_keys = ON;

-- Survey Sessions Table (tracks each survey instance)
CREATE TABLE survey_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
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
    status TEXT DEFAULT 'in_progress', -- in_progress, completed, exported
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Family Members Table
CREATE TABLE family_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT NOT NULL,
    fathers_name TEXT,
    mothers_name TEXT,
    relationship_with_head TEXT,
    age INTEGER,
    sex TEXT,
    physically_fit TEXT, -- fit/unfit with cause
    educational_qualification TEXT,
    inclination_self_employment TEXT,
    occupation TEXT,
    days_employed INTEGER,
    income REAL,
    awareness_about_village TEXT,
    participate_gram_sabha TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Land Holding Information
CREATE TABLE land_holding (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    irrigated_area REAL,
    cultivable_area REAL,
    orchard_plants_type TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Irrigation Facilities
CREATE TABLE irrigation_facilities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    canal TEXT, -- Yes/No
    tube_well TEXT, -- Yes/No
    ponds TEXT, -- Yes/No
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
    chemical_fertilizer TEXT, -- Yes/No
    organic_fertilizer TEXT, -- Yes/No
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
    tractor TEXT, -- Yes/No
    thresher TEXT, -- Yes/No
    seed_drill TEXT, -- Yes/No
    sprayer TEXT, -- Yes/No
    duster TEXT, -- Yes/No
    diesel_engine TEXT, -- Yes/No
    other_equipment TEXT,
    other_specify TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Entertainment Facilities
CREATE TABLE entertainment_facilities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    smart_mobile TEXT, -- Yes/No
    smart_mobile_count INTEGER,
    analog_mobile TEXT, -- Yes/No
    analog_mobile_count INTEGER,
    television TEXT, -- Yes/No
    radio TEXT, -- Yes/No
    games TEXT, -- Yes/No
    other_entertainment TEXT,
    other_specify TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Transport Facilities
CREATE TABLE transport_facilities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    car_jeep TEXT, -- Yes/No
    motorcycle_scooter TEXT, -- Yes/No
    e_rickshaw TEXT, -- Yes/No
    cycle TEXT, -- Yes/No
    pickup_truck TEXT, -- Yes/No
    bullock_cart TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Drinking Water Sources
CREATE TABLE drinking_water_sources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    hand_pumps TEXT, -- Yes/No
    hand_pumps_distance REAL,
    well TEXT, -- Yes/No
    well_distance REAL,
    tubewell TEXT, -- Yes/No
    tubewell_distance REAL,
    nal_jaal TEXT, -- Yes/No
    other_source TEXT,
    other_distance REAL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Medical Treatment Methods
CREATE TABLE medical_treatment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    allopathic TEXT, -- Yes/No
    ayurvedic TEXT, -- Yes/No
    homeopathy TEXT, -- Yes/No
    traditional TEXT, -- Yes/No
    jhad_phook TEXT, -- Yes/No
    other_treatment TEXT,
    preference_order TEXT, -- JSON array of preferences
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Disputes Information
CREATE TABLE disputes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    family_disputes TEXT, -- Yes/No
    family_registered TEXT, -- Yes/No
    family_period TEXT,
    revenue_disputes TEXT, -- Yes/No
    revenue_registered TEXT, -- Yes/No
    revenue_period TEXT,
    criminal_disputes TEXT, -- Yes/No
    criminal_registered TEXT, -- Yes/No
    criminal_period TEXT,
    other_disputes TEXT,
    other_description TEXT,
    other_registered TEXT, -- Yes/No
    other_period TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- House Conditions
CREATE TABLE house_conditions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    katcha TEXT, -- Yes/No
    pakka TEXT, -- Yes/No
    katcha_pakka TEXT, -- Yes/No
    hut TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- House Facilities
CREATE TABLE house_facilities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    toilet TEXT, -- Yes/No
    toilet_in_use TEXT, -- Yes/No
    drainage TEXT, -- Yes/No
    soak_pit TEXT, -- Yes/No
    cattle_shed TEXT, -- Yes/No
    compost_pit TEXT, -- Yes/No
    nadep TEXT, -- Yes/No
    lpg_gas TEXT, -- Yes/No
    biogas TEXT, -- Yes/No
    solar_cooking TEXT, -- Yes/No
    electric_connection TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Nutritional Kitchen Garden
CREATE TABLE nutritional_garden (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    available TEXT, -- Yes/No
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
    have_aadhaar TEXT, -- Yes/No
    name_included TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
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
    registered TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Ayushman Card
CREATE TABLE ayushman_card (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    eligible TEXT, -- Yes/No
    have_card TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
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
    registered TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Family ID
CREATE TABLE family_id (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    have_family_id TEXT, -- Yes/No
    name_included TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
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
    registered TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Ration Card
CREATE TABLE ration_card (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    have_ration_card TEXT, -- Yes/No
    name_included TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
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
    registered TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Samagra ID
CREATE TABLE samagra_id (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    details_correct TEXT, -- Yes/No
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
    have_id TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Tribal Card
CREATE TABLE tribal_card (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    applicable TEXT, -- NA/Yes/No
    details_correct TEXT, -- Yes/No
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
    registered TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Handicapped Allowance
CREATE TABLE handicapped_allowance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    applicable TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
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
    registered TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Pension Allowance
CREATE TABLE pension_allowance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    applicable TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
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
    registered TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - Widow Allowance
CREATE TABLE widow_allowance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    applicable TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
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
    registered TEXT, -- Yes/No
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
    vaccination_pregnancy TEXT, -- Yes/No
    child_vaccination TEXT, -- Yes/No
    vaccination_schedule TEXT,
    family_planning_awareness TEXT, -- Yes/No
    contraceptive_applied TEXT, -- Yes/No
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
    available TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Migration Data
CREATE TABLE migration_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    migration_type TEXT, -- permanent/seasonal/as_needed
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
    beneficiary TEXT, -- Yes/No
    name_included TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- VB Gram Members
CREATE TABLE vb_gram_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    received TEXT, -- Yes/No
    days_worked INTEGER,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - PM Kisan Nidhi
CREATE TABLE pm_kisan_nidhi (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    beneficiary TEXT, -- Yes/No
    name_included TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- PM Kisan Nidhi Members
CREATE TABLE pm_kisan_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    received TEXT, -- Yes/No
    days_worked INTEGER,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE,
    UNIQUE(session_id, sr_no)
);

-- Government Schemes - PM Kisan Samman Nidhi
CREATE TABLE pm_kisan_samman (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    beneficiary TEXT, -- Yes/No
    received TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Kisan Credit Card
CREATE TABLE kisan_credit_card (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    beneficiary TEXT, -- Yes/No
    received TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Swachh Bharat Mission
CREATE TABLE swachh_bharat (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    beneficiary TEXT, -- Yes/No
    received TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Government Schemes - Fasal Bima
CREATE TABLE fasal_bima (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT UNIQUE NOT NULL,
    beneficiary TEXT, -- Yes/No
    received TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES survey_sessions(session_id) ON DELETE CASCADE
);

-- Bank Accounts
CREATE TABLE bank_accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    name TEXT,
    have_account TEXT, -- Yes/No
    details_correct TEXT, -- Yes/No
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

-- Triggers to update timestamps (SQLite specific)
CREATE TRIGGER update_survey_sessions_timestamp
    AFTER UPDATE ON survey_sessions
    FOR EACH ROW
    WHEN NEW.updated_at = OLD.updated_at
    BEGIN
        UPDATE survey_sessions SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;
