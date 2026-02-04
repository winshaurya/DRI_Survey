-- ===========================================
-- SUPABASE SCHEMA REBUILD - EXACT SQLITE MIRROR
-- ===========================================
-- Execute this AFTER running 00_DROP_ALL_SUPABASE.sql
-- This schema mirrors SQLite exactly:
-- - phone_number (TEXT) for family surveys
-- - session_id (TEXT) for village surveys
-- - INTEGER (0/1) for booleans (no BOOLEAN type)
-- - TEXT for timestamps (ISO8601 format)
-- - All FKs reference TEXT primary keys

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================
-- FAMILY SURVEY SESSIONS TABLE
-- ===========================================
CREATE TABLE family_survey_sessions (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT UNIQUE NOT NULL,
    surveyor_email TEXT NOT NULL,
    created_at TEXT DEFAULT NOW()::TEXT,
    updated_at TEXT DEFAULT NOW()::TEXT,

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

    survey_date TEXT DEFAULT CURRENT_DATE::TEXT,
    surveyor_name TEXT,
    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'exported')),

    device_info TEXT,
    app_version TEXT,
    created_by TEXT,
    updated_by TEXT,

    is_deleted INTEGER DEFAULT 0,
    last_synced_at TEXT,
    current_version INTEGER DEFAULT 1,
    last_edited_at TEXT DEFAULT NOW()::TEXT
);

CREATE INDEX idx_family_sessions_phone ON family_survey_sessions(phone_number);
CREATE INDEX idx_family_sessions_status ON family_survey_sessions(status);

-- ===========================================
-- FAMILY MEMBERS TABLE
-- ===========================================
CREATE TABLE family_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,
    updated_at TEXT DEFAULT NOW()::TEXT,
    is_deleted INTEGER DEFAULT 0,

    sr_no INTEGER NOT NULL,
    name TEXT NOT NULL,
    fathers_name TEXT,
    mothers_name TEXT,
    relationship_with_head TEXT,
    age INTEGER,
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
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
);

CREATE INDEX idx_family_members_phone ON family_members(phone_number);

-- ===========================================
-- LAND HOLDING TABLE
-- ===========================================
CREATE TABLE land_holding (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    irrigated_area DECIMAL(8,2),
    cultivable_area DECIMAL(8,2),
    unirrigated_area DECIMAL(8,2),
    barren_land DECIMAL(8,2),
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
CREATE TABLE irrigation_facilities (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

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
-- CROP PRODUCTIVITY TABLE
-- ===========================================
CREATE TABLE crop_productivity (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    sr_no INTEGER NOT NULL,
    crop_name TEXT,
    area_hectares DECIMAL(8,2),
    productivity_quintal_per_hectare DECIMAL(8,2),
    total_production_quintal DECIMAL(10,2),
    quantity_consumed_quintal DECIMAL(10,2),
    quantity_sold_quintal DECIMAL(10,2),

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- FERTILIZER USAGE TABLE
-- ===========================================
CREATE TABLE fertilizer_usage (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    urea_fertilizer TEXT,
    organic_fertilizer TEXT,
    fertilizer_types TEXT,
    fertilizer_expenditure DECIMAL(10,2),

    UNIQUE(phone_number)
);

-- ===========================================
-- ANIMALS TABLE
-- ===========================================
CREATE TABLE animals (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    sr_no INTEGER NOT NULL,
    animal_type TEXT,
    number_of_animals INTEGER,
    breed TEXT,
    production_per_animal DECIMAL(8,2),
    quantity_sold DECIMAL(10,2),

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- AGRICULTURAL EQUIPMENT TABLE
-- ===========================================
CREATE TABLE agricultural_equipment (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    tractor TEXT,
    tractor_condition TEXT,
    thresher TEXT,
    thresher_condition TEXT,
    seed_drill TEXT,
    seed_drill_condition TEXT,
    sprayer TEXT,
    sprayer_condition TEXT,
    duster TEXT,
    duster_condition TEXT,
    diesel_engine TEXT,
    diesel_engine_condition TEXT,
    other_equipment TEXT,

    UNIQUE(phone_number)
);

-- ===========================================
-- ENTERTAINMENT FACILITIES TABLE
-- ===========================================
CREATE TABLE entertainment_facilities (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

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
CREATE TABLE transport_facilities (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

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
CREATE TABLE drinking_water_sources (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    hand_pumps TEXT,
    hand_pumps_distance DECIMAL(5,1),
    hand_pumps_quality TEXT,
    well TEXT,
    well_distance DECIMAL(5,1),
    well_quality TEXT,
    tubewell TEXT,
    tubewell_distance DECIMAL(5,1),
    tubewell_quality TEXT,
    nal_jaal TEXT,
    nal_jaal_quality TEXT,
    other_source TEXT,
    other_distance DECIMAL(5,1),
    other_sources_quality TEXT,

    UNIQUE(phone_number)
);

-- ===========================================
-- MEDICAL TREATMENT TABLE
-- ===========================================
CREATE TABLE medical_treatment (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    allopathic TEXT,
    ayurvedic TEXT,
    homeopathy TEXT,
    traditional TEXT,
    other_treatment TEXT,
    preferred_treatment TEXT,

    UNIQUE(phone_number)
);

-- ===========================================
-- DISPUTES TABLE
-- ===========================================
CREATE TABLE disputes (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

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
CREATE TABLE house_conditions (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

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
CREATE TABLE house_facilities (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

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
CREATE TABLE diseases (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    sr_no INTEGER,
    family_member_name TEXT,
    disease_name TEXT,
    suffering_since TEXT,
    treatment_taken TEXT,
    treatment_from_when TEXT,
    treatment_from_where TEXT,
    treatment_taken_from TEXT
);

-- ===========================================
-- SOCIAL CONSCIOUSNESS TABLE
-- ===========================================
CREATE TABLE social_consciousness (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

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

    UNIQUE(phone_number)
);

-- ===========================================
-- GOVERNMENT SCHEMES TABLES
-- ===========================================

CREATE TABLE aadhaar_info (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,
    has_aadhaar TEXT,
    total_members INTEGER,
    UNIQUE(phone_number)
);

CREATE TABLE aadhaar_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE ayushman_card (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    has_card TEXT,
    total_members INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE ayushman_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE family_id (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    has_id TEXT,
    total_members INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE family_id_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE ration_card (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    has_card TEXT,
    card_type TEXT,
    total_members INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE ration_card_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE samagra_id (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    has_id TEXT,
    family_id TEXT,
    total_children INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE samagra_children (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    child_name TEXT,
    samagra_id TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE tribal_card (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    has_card TEXT,
    total_members INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE tribal_card_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE handicapped_allowance (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    has_allowance TEXT,
    total_members INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE handicapped_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE pension_allowance (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    has_pension TEXT,
    total_members INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE pension_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE widow_allowance (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    has_allowance TEXT,
    total_members INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE widow_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    family_member_name TEXT,
    have_card TEXT,
    card_number TEXT,
    details_correct TEXT,
    what_incorrect TEXT,
    benefits_received TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE vb_gram (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    is_member TEXT,
    total_members INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE vb_gram_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    member_name TEXT,
    membership_details TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE pm_kisan_nidhi (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    is_beneficiary TEXT,
    total_members INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE pm_kisan_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    member_name TEXT,
    account_number TEXT,
    benefits_received TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE merged_govt_schemes (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    scheme_data TEXT,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

-- ===========================================
-- ADDITIONAL FAMILY TABLES
-- ===========================================

CREATE TABLE children_data (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    births_last_3_years INTEGER,
    infant_deaths_last_3_years INTEGER,
    malnourished_children INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE malnourished_children_data (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    child_id TEXT,
    child_name TEXT,
    height DECIMAL(5,2),
    weight DECIMAL(5,2),
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE child_diseases (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    child_id TEXT,
    disease_name TEXT,
    sr_no INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE migration_data (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    family_members_migrated INTEGER,
    reason TEXT,
    duration TEXT,
    destination TEXT,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE training_data (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    member_name TEXT,
    training_topic TEXT,
    training_duration TEXT,
    training_date TEXT,
    status TEXT DEFAULT 'taken',
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE self_help_groups (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    member_name TEXT,
    shg_name TEXT,
    purpose TEXT,
    agency TEXT,
    position TEXT,
    monthly_saving DECIMAL(10,2),
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE fpo_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    member_name TEXT,
    fpo_name TEXT,
    purpose TEXT,
    agency TEXT,
    share_capital DECIMAL(10,2),
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE bank_accounts (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
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
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE folklore_medicine (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    person_name TEXT,
    plant_local_name TEXT,
    plant_botanical_name TEXT,
    uses TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE health_programmes (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    vaccination_pregnancy TEXT,
    child_vaccination TEXT,
    vaccination_schedule TEXT,
    balance_doses_schedule TEXT,
    family_planning_awareness TEXT,
    contraceptive_applied TEXT,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE tribal_questions (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    deity_name TEXT,
    festival_name TEXT,
    dance_name TEXT,
    language TEXT,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE tulsi_plants (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    has_plants TEXT,
    plant_count INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE nutritional_garden (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    has_garden TEXT,
    garden_size DECIMAL(5,2),
    vegetables_grown TEXT,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE malnutrition_data (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    child_name TEXT,
    age INTEGER,
    weight DECIMAL(5,2),
    height DECIMAL(5,2),
    created_at TEXT DEFAULT NOW()::TEXT
);

-- ===========================================
-- VILLAGE SURVEY TABLES
-- ===========================================

CREATE TABLE village_survey_sessions (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT UNIQUE NOT NULL,
    surveyor_email TEXT NOT NULL,
    created_at TEXT DEFAULT NOW()::TEXT,
    updated_at TEXT DEFAULT NOW()::TEXT,

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

    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    location_accuracy DECIMAL(5,2),
    location_timestamp TEXT,

    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'exported')),
    device_info TEXT,
    app_version TEXT,

    created_by TEXT,
    updated_by TEXT,

    is_deleted INTEGER DEFAULT 0,
    last_synced_at TEXT,

    current_version INTEGER DEFAULT 1,
    last_edited_at TEXT DEFAULT NOW()::TEXT
);

CREATE INDEX idx_village_sessions_id ON village_survey_sessions(session_id);
CREATE INDEX idx_village_sessions_status ON village_survey_sessions(status);

CREATE TABLE village_population (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,
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
    unemployed_population INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_farm_families (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    big_farmers INTEGER DEFAULT 0,
    small_farmers INTEGER DEFAULT 0,
    marginal_farmers INTEGER DEFAULT 0,
    landless_farmers INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_housing (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

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
    houses_with_electricity INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_agricultural_implements (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    tractor_available INTEGER DEFAULT 0,
    thresher_available INTEGER DEFAULT 0,
    seed_drill_available INTEGER DEFAULT 0,
    sprayer_available INTEGER DEFAULT 0,
    duster_available INTEGER DEFAULT 0,
    diesel_engine_available INTEGER DEFAULT 0,
    other_implements TEXT,

    UNIQUE(session_id)
);

CREATE TABLE village_crop_productivity (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    sr_no INTEGER NOT NULL,
    crop_name TEXT,
    area_hectares DECIMAL(8,2),
    productivity_quintal_per_hectare DECIMAL(8,2),
    total_production_quintal DECIMAL(10,2),
    quantity_consumed_quintal DECIMAL(10,2),
    quantity_sold_quintal DECIMAL(10,2),

    UNIQUE(session_id, sr_no)
);

CREATE TABLE village_animals (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    sr_no INTEGER NOT NULL,
    animal_type TEXT,
    total_count INTEGER,
    breed TEXT,

    UNIQUE(session_id, sr_no)
);

CREATE TABLE village_irrigation_facilities (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    canal_available INTEGER DEFAULT 0,
    tube_well_available INTEGER DEFAULT 0,
    pond_available INTEGER DEFAULT 0,
    other_sources TEXT,

    UNIQUE(session_id)
);

CREATE TABLE village_drinking_water (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    hand_pumps_available INTEGER DEFAULT 0,
    hand_pumps_count INTEGER DEFAULT 0,
    wells_available INTEGER DEFAULT 0,
    wells_count INTEGER DEFAULT 0,
    tube_wells_available INTEGER DEFAULT 0,
    tube_wells_count INTEGER DEFAULT 0,
    nal_jal_available INTEGER DEFAULT 0,
    other_sources TEXT,

    UNIQUE(session_id)
);

CREATE TABLE village_transport (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    cars_available INTEGER DEFAULT 0,
    motorcycles_available INTEGER DEFAULT 0,
    e_rickshaws_available INTEGER DEFAULT 0,
    cycles_available INTEGER DEFAULT 0,
    pickup_trucks_available INTEGER DEFAULT 0,
    bullock_carts_available INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_entertainment (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    smart_mobiles_available INTEGER DEFAULT 0,
    smart_mobiles_count INTEGER DEFAULT 0,
    analog_mobiles_available INTEGER DEFAULT 0,
    analog_mobiles_count INTEGER DEFAULT 0,
    televisions_available INTEGER DEFAULT 0,
    televisions_count INTEGER DEFAULT 0,
    radios_available INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_medical_treatment (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    allopathic_available INTEGER DEFAULT 0,
    ayurvedic_available INTEGER DEFAULT 0,
    homeopathy_available INTEGER DEFAULT 0,
    traditional_available INTEGER DEFAULT 0,
    other_treatment TEXT,

    UNIQUE(session_id)
);

CREATE TABLE village_disputes (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    family_disputes INTEGER DEFAULT 0,
    revenue_disputes INTEGER DEFAULT 0,
    criminal_disputes INTEGER DEFAULT 0,
    other_disputes TEXT,

    UNIQUE(session_id)
);

CREATE TABLE village_educational_facilities (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    primary_schools INTEGER DEFAULT 0,
    middle_schools INTEGER DEFAULT 0,
    high_schools INTEGER DEFAULT 0,
    colleges INTEGER DEFAULT 0,
    anganwadi_centers INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_social_consciousness (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    waste_management_system INTEGER DEFAULT 0,
    rainwater_harvesting INTEGER DEFAULT 0,
    solar_energy_usage INTEGER DEFAULT 0,
    community_participation TEXT,

    UNIQUE(session_id)
);

CREATE TABLE village_children_data (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    total_children INTEGER DEFAULT 0,
    malnourished_children INTEGER DEFAULT 0,
    children_in_school INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_malnutrition_data (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    sr_no INTEGER,
    child_name TEXT,
    age INTEGER,
    weight DECIMAL(5,2),
    height DECIMAL(5,2)
);

CREATE TABLE village_bpl_families (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    total_bpl_families INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_kitchen_gardens (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    total_gardens INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_seed_clubs (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    total_clubs INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_biodiversity_register (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    register_maintained INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_traditional_occupations (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    sr_no INTEGER,
    occupation_name TEXT,
    number_of_families INTEGER
);

CREATE TABLE village_drainage_waste (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    drainage_system_available INTEGER DEFAULT 0,
    waste_management_system INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_signboards (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    signboard_type TEXT,
    location TEXT
);

CREATE TABLE village_unemployment (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    total_unemployed INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

CREATE TABLE village_social_maps (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    map_type TEXT,
    map_data TEXT
);

CREATE TABLE village_transport_facilities (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TEXT DEFAULT NOW()::TEXT,

    road_connectivity INTEGER DEFAULT 0,
    public_transport_available INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

-- ===========================================
-- INDEXES FOR PERFORMANCE
-- ===========================================

CREATE INDEX idx_family_members_phone ON family_members(phone_number);
CREATE INDEX idx_land_holding_phone ON land_holding(phone_number);
CREATE INDEX idx_irrigation_phone ON irrigation_facilities(phone_number);
CREATE INDEX idx_crop_phone ON crop_productivity(phone_number);
CREATE INDEX idx_animals_phone ON animals(phone_number);
CREATE INDEX idx_bank_accounts_phone ON bank_accounts(phone_number);

CREATE INDEX idx_village_population_session ON village_population(session_id);
CREATE INDEX idx_village_housing_session ON village_housing(session_id);
CREATE INDEX idx_village_crop_session ON village_crop_productivity(session_id);

-- ✓ Schema rebuild complete
-- All tables now use phone_number (family) or session_id (village) as foreign keys
-- All boolean fields stored as INTEGER (0/1)
-- All timestamps stored as TEXT (ISO8601)
-- Ready for app sync operations
