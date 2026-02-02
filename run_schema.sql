-- SQLite-compatible version of the family survey schema
-- Run this script to set up the database schema

PRAGMA foreign_keys = ON;

-- ===========================================
-- FAMILY SURVEY SESSIONS TABLE
-- ===========================================
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
    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'exported')),
    device_info TEXT,
    app_version TEXT,
    created_by TEXT,
    updated_by TEXT,
    is_deleted INTEGER DEFAULT 0,
    last_synced_at TEXT,
    current_version INTEGER DEFAULT 1,
    last_edited_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- FAMILY FORM HISTORY TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS family_form_history (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    version INTEGER NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    edited_by TEXT,
    edit_reason TEXT,
    is_auto_save INTEGER DEFAULT 0,
    form_data TEXT NOT NULL,
    changes_summary TEXT,
    UNIQUE(phone_number, version)
);

-- ===========================================
-- FAMILY MEMBERS TABLE
-- ===========================================
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
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
    physically_fit TEXT CHECK (physically_fit IN ('fit', 'unfit')),
    physically_fit_cause TEXT,
    educational_qualification TEXT,
    inclination_self_employment TEXT CHECK (inclination_self_employment IN ('yes', 'no', 'maybe')),
    occupation TEXT,
    days_employed INTEGER,
    income REAL,
    awareness_about_village TEXT CHECK (awareness_about_village IN ('high', 'medium', 'low', 'none')),
    participate_gram_sabha TEXT CHECK (participate_gram_sabha IN ('regularly', 'sometimes', 'rarely', 'never')),
    insured TEXT CHECK (insured IN ('yes', 'no')) DEFAULT 'no',
    insurance_company TEXT,
    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- LAND HOLDING TABLE
-- ===========================================
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
    pomegranate_trees INTEGER DEFAULT 0,
    other_fruit_trees_name TEXT,
    other_fruit_trees_count INTEGER DEFAULT 0,
    UNIQUE(phone_number)
);

-- ===========================================
-- IRRIGATION FACILITIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS irrigation_facilities (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    primary_source TEXT,
    canal TEXT,
    tube_well TEXT,
    river TEXT,
    pond TEXT,
    well TEXT,
    hand_pump TEXT,
    submersible TEXT,
    rainwater_harvesting TEXT,
    check_dam TEXT,
    other_sources TEXT,
    UNIQUE(phone_number)
);

-- ===========================================
-- FERTILIZER USAGE TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS fertilizer_usage (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    urea_fertilizer TEXT,
    organic_fertilizer TEXT,
    fertilizer_types TEXT,
    fertilizer_expenditure REAL,
    UNIQUE(phone_number)
);

-- ===========================================
-- CROP PRODUCTIVITY TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS crop_productivity (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    sr_no INTEGER NOT NULL,
    crop_name TEXT,
    area_hectares REAL,
    productivity_quintal_per_hectare REAL,
    total_production_quintal REAL,
    quantity_consumed_quintal REAL,
    quantity_sold_quintal REAL,
    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- ANIMALS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS animals (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    sr_no INTEGER NOT NULL,
    animal_type TEXT,
    number_of_animals INTEGER,
    breed TEXT,
    production_per_animal REAL,
    quantity_sold REAL,
    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- AGRICULTURAL EQUIPMENT TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS agricultural_equipment (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    tractor TEXT,
    tractor_condition TEXT CHECK (tractor_condition IN ('good', 'average', 'bad')),
    thresher TEXT,
    thresher_condition TEXT CHECK (thresher_condition IN ('good', 'average', 'bad')),
    seed_drill TEXT,
    seed_drill_condition TEXT CHECK (seed_drill_condition IN ('good', 'average', 'bad')),
    sprayer TEXT,
    sprayer_condition TEXT CHECK (sprayer_condition IN ('good', 'average', 'bad')),
    duster TEXT,
    duster_condition TEXT CHECK (duster_condition IN ('good', 'average', 'bad')),
    diesel_engine TEXT,
    diesel_engine_condition TEXT CHECK (diesel_engine_condition IN ('good', 'average', 'bad')),
    other_equipment TEXT,
    UNIQUE(phone_number)
);

-- ===========================================
-- ENTERTAINMENT FACILITIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS entertainment_facilities (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    smart_mobile TEXT,
    smart_mobile_count INTEGER DEFAULT 0,
    analog_mobile TEXT,
    analog_mobile_count INTEGER DEFAULT 0,
    television TEXT,
    radio TEXT,
    games TEXT,
    other_entertainment TEXT,
    other_specify TEXT,
    UNIQUE(phone_number)
);

-- ===========================================
-- TRANSPORT FACILITIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS transport_facilities (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    car_jeep TEXT,
    motorcycle_scooter TEXT,
    e_rickshaw TEXT,
    cycle TEXT,
    pickup_truck TEXT,
    bullock_cart TEXT,
    UNIQUE(phone_number)
);

-- ===========================================
-- DRINKING WATER SOURCES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS drinking_water_sources (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    hand_pumps TEXT,
    hand_pumps_distance REAL,
    hand_pumps_quality TEXT CHECK (hand_pumps_quality IN ('good', 'average', 'bad')),
    well TEXT,
    well_distance REAL,
    well_quality TEXT CHECK (well_quality IN ('good', 'average', 'bad')),
    tubewell TEXT,
    tubewell_distance REAL,
    tubewell_quality TEXT CHECK (tubewell_quality IN ('good', 'average', 'bad')),
    nal_jaal TEXT,
    nal_jaal_quality TEXT CHECK (nal_jaal_quality IN ('good', 'average', 'bad')),
    other_source TEXT,
    other_distance REAL,
    hand_pumps_quality TEXT CHECK (hand_pumps_quality IN ('good', 'average', 'bad')),
    well_quality TEXT CHECK (well_quality IN ('good', 'average', 'bad')),
    tubewell_quality TEXT CHECK (tubewell_quality IN ('good', 'average', 'bad')),
    nal_jaal_quality TEXT CHECK (nal_jaal_quality IN ('good', 'average', 'bad')),
    other_sources_quality TEXT CHECK (other_sources_quality IN ('good', 'average', 'bad')),
    overall_water_quality TEXT CHECK (overall_water_quality IN ('good', 'average', 'bad')),
    UNIQUE(phone_number)
);

-- ===========================================
-- MEDICAL TREATMENT TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS medical_treatment (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    allopathic TEXT,
    ayurvedic TEXT,
    homeopathy TEXT,
    traditional TEXT,
    jhad_phook TEXT,
    other_treatment TEXT,
    preference_order TEXT,
    UNIQUE(phone_number)
);

-- ===========================================
-- DISPUTES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS disputes (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
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
    UNIQUE(phone_number)
);

-- ===========================================
-- HOUSE CONDITIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS house_conditions (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    katcha TEXT,
    pakka TEXT,
    katcha_pakka TEXT,
    hut TEXT,
    toilet_in_use TEXT,
    toilet_condition TEXT,
    UNIQUE(phone_number)
);

-- ===========================================
-- HOUSE FACILITIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS house_facilities (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
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
    nutritional_garden_available TEXT,
    tulsi_plants_available TEXT,
    UNIQUE(phone_number)
);

-- ===========================================
-- DISEASES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS diseases (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    disease_name TEXT,
    suffering_since TEXT,
    treatment_taken TEXT CHECK (treatment_taken IN ('yes', 'no')),
    treatment_from_when TEXT,
    treatment_from_where TEXT,
    treatment_taken_from TEXT,
    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES TABLES
-- ===========================================
CREATE TABLE IF NOT EXISTS aadhaar_scheme_members (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    UNIQUE(phone_number, sr_no)
);

CREATE TABLE IF NOT EXISTS tribal_scheme_members (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    UNIQUE(phone_number, sr_no)
);

CREATE TABLE IF NOT EXISTS pension_scheme_members (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    UNIQUE(phone_number, sr_no)
);

CREATE TABLE IF NOT EXISTS widow_scheme_members (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- TRAINING DATA TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS training_data (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    training_taken TEXT CHECK (training_taken IN ('yes', 'no')),
    want_training TEXT CHECK (want_training IN ('yes', 'no')),
    training_type TEXT,
    pass_out_year INTEGER,
    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- SELF HELP GROUPS MEMBERS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS shg_members (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    shg_name TEXT,
    purpose TEXT,
    agency TEXT,
    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- FPO MEMBERS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS fpo_members (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    fpo_name TEXT,
    purpose TEXT,
    agency TEXT,
    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- BENEFICIARY PROGRAMS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS beneficiary_programs (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    program_type TEXT NOT NULL,
    is_beneficiary INTEGER DEFAULT 0,
    member_name TEXT,
    name_included INTEGER,
    details_correct INTEGER,
    incorrect_details TEXT,
    days_worked INTEGER,
    received INTEGER,
    is_deleted INTEGER DEFAULT 0
);

-- ===========================================
-- BANK ACCOUNTS TABLE
-- ===========================================
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
);

-- ===========================================
-- SOCIAL CONSCIOUSNESS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS social_consciousness (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    is_deleted INTEGER DEFAULT 0,
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
    UNIQUE(phone_number)
);

-- ===========================================
-- CHILDREN DATA TABLES
-- ===========================================
CREATE TABLE IF NOT EXISTS children_data (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    births_last_3_years INTEGER DEFAULT 0,
    infant_deaths_last_3_years INTEGER DEFAULT 0,
    malnourished_children INTEGER DEFAULT 0,
    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS malnourished_children_data (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    child_id TEXT,
    child_name TEXT,
    height REAL,
    weight REAL,
    UNIQUE(phone_number, child_id)
);

CREATE TABLE IF NOT EXISTS child_diseases (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    child_id TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    disease_name TEXT NOT NULL,
    sr_no INTEGER NOT NULL,
    UNIQUE(phone_number, child_id, sr_no)
);

-- ===========================================
-- FOLKLORE MEDICINE TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS folklore_medicine (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    person_name TEXT,
    plant_local_name TEXT,
    plant_botanical_name TEXT,
    uses TEXT
);

-- ===========================================
-- HEALTH PROGRAMMES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS health_programmes (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    vaccination_pregnancy TEXT,
    child_vaccination TEXT,
    vaccination_schedule TEXT,
    family_planning_awareness TEXT,
    contraceptive_applied TEXT,
    UNIQUE(phone_number)
);

-- ===========================================
-- MIGRATION DATA TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS migration_data (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    migration_type TEXT,
    distance TEXT,
    job_description TEXT,
    member_count INTEGER DEFAULT 0
);

-- ===========================================
-- TRIBAL QUESTIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS tribal_questions (
    id TEXT PRIMARY KEY,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    individual_forest_claims TEXT,
    claim_map TEXT,
    palash_collectors TEXT,
    collection_areas_palash TEXT,
    honey_gatherers TEXT,
    collection_areas_honey TEXT,
    ntfp_collection TEXT,
    ntfp_stakeholders TEXT,
    skills_identification TEXT,
    UNIQUE(phone_number)
);

-- ===========================================
-- PENDING UPLOADS TABLE (Local SQLite only)
-- ===========================================
CREATE TABLE IF NOT EXISTS pending_uploads (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    local_file_path TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_type TEXT NOT NULL,
    village_smile_code TEXT NOT NULL,
    page_type TEXT NOT NULL,
    component TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'uploading', 'uploaded', 'failed')),
    upload_attempts INTEGER DEFAULT 0,
    last_attempt_at TEXT,
    error_message TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- INDEXES FOR PERFORMANCE
-- ===========================================
CREATE INDEX IF NOT EXISTS idx_family_sessions_status ON family_survey_sessions(status);
CREATE INDEX IF NOT EXISTS idx_family_sessions_date ON family_survey_sessions(survey_date);
CREATE INDEX IF NOT EXISTS idx_family_sessions_shine ON family_survey_sessions(shine_code);
CREATE INDEX IF NOT EXISTS idx_family_form_history_session ON family_form_history(phone_number);
CREATE INDEX IF NOT EXISTS idx_family_form_history_version ON family_form_history(phone_number, version);
CREATE INDEX IF NOT EXISTS idx_family_members_session ON family_members(phone_number);
CREATE INDEX IF NOT EXISTS idx_crop_productivity_session ON crop_productivity(phone_number);
CREATE INDEX IF NOT EXISTS idx_animals_session ON animals(phone_number);
CREATE INDEX IF NOT EXISTS idx_diseases_session ON diseases(phone_number);
CREATE INDEX IF NOT EXISTS idx_training_session ON training_data(phone_number);
CREATE INDEX IF NOT EXISTS idx_shg_session ON shg_members(phone_number);
CREATE INDEX IF NOT EXISTS idx_fpo_session ON fpo_members(phone_number);