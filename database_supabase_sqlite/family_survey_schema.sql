-- Family Survey Schema for Supabase
-- This schema can be run multiple times safely (idempotent)
-- Compatible with both Supabase and SQLite

-- Enable necessary extensions (Supabase specific)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ===========================================
-- FAMILY SURVEY SESSIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS family_survey_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT UNIQUE NOT NULL,
    surveyor_email TEXT NOT NULL, -- For audit trails and RLS
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Basic Family Information
    village_name TEXT,
    village_number TEXT,
    panchayat TEXT,
    block TEXT,
    tehsil TEXT,
    district TEXT,
    postal_address TEXT,
    pin_code TEXT,

    -- SHINE Integration
    shine_code TEXT,

    -- GPS Coordinates (PostGIS for Supabase, regular for SQLite)
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    location_accuracy DECIMAL(5,2),
    location_timestamp TIMESTAMPTZ,

    -- Survey Metadata
    survey_date DATE DEFAULT CURRENT_DATE,
    surveyor_name TEXT,
    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'exported')),

    -- Additional metadata
    device_info JSONB,
    app_version TEXT,

    -- Audit fields
    created_by TEXT,
    updated_by TEXT,

    -- Sync fields
    is_deleted BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ,

    -- Versioning fields
    current_version INTEGER DEFAULT 1,
    last_edited_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- FAMILY FORM HISTORY TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS family_form_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    version INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Version metadata
    edited_by TEXT,
    edit_reason TEXT,
    is_auto_save BOOLEAN DEFAULT FALSE,

    -- Complete form data as JSON
    form_data JSONB NOT NULL,

    -- Change summary (optional)
    changes_summary TEXT,

    UNIQUE(phone_number, version)
);

-- ===========================================
-- FAMILY MEMBERS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS family_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Sync fields
    is_deleted BOOLEAN DEFAULT FALSE,

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
    income DECIMAL(10,2),
    awareness_about_village TEXT CHECK (awareness_about_village IN ('high', 'medium', 'low', 'none')),
    participate_gram_sabha TEXT CHECK (participate_gram_sabha IN ('regularly', 'sometimes', 'rarely', 'never')),
    -- Insurance details
    insured TEXT CHECK (insured IN ('yes', 'no')) DEFAULT 'no',
    insurance_company TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- LAND HOLDING TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS land_holding (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    irrigated_area DECIMAL(8,2),
    cultivable_area DECIMAL(8,2),
    unirrigated_area DECIMAL(8,2),
    barren_land DECIMAL(8,2),
    
    -- Specific orchard plants
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
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

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
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    urea_fertilizer TEXT,
    organic_fertilizer TEXT,
    fertilizer_types TEXT,
    fertilizer_expenditure DECIMAL(10,2),

    UNIQUE(phone_number)
);

-- ===========================================
-- CROP PRODUCTIVITY TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS crop_productivity (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    crop_name TEXT,
    area_acres DECIMAL(8,2),
    productivity_quintal_per_acre DECIMAL(8,2),
    total_production DECIMAL(10,2),
    quantity_consumed DECIMAL(10,2),
    quantity_sold DECIMAL(10,2),

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- ANIMALS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS animals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

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
CREATE TABLE IF NOT EXISTS agricultural_equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

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

-- Add condition columns for existing tables (migration)
ALTER TABLE agricultural_equipment ADD COLUMN IF NOT EXISTS tractor_condition TEXT CHECK (tractor_condition IN ('good', 'average', 'bad'));
ALTER TABLE agricultural_equipment ADD COLUMN IF NOT EXISTS thresher_condition TEXT CHECK (thresher_condition IN ('good', 'average', 'bad'));
ALTER TABLE agricultural_equipment ADD COLUMN IF NOT EXISTS seed_drill_condition TEXT CHECK (seed_drill_condition IN ('good', 'average', 'bad'));
ALTER TABLE agricultural_equipment ADD COLUMN IF NOT EXISTS sprayer_condition TEXT CHECK (sprayer_condition IN ('good', 'average', 'bad'));
ALTER TABLE agricultural_equipment ADD COLUMN IF NOT EXISTS duster_condition TEXT CHECK (duster_condition IN ('good', 'average', 'bad'));
ALTER TABLE agricultural_equipment ADD COLUMN IF NOT EXISTS diesel_engine_condition TEXT CHECK (diesel_engine_condition IN ('good', 'average', 'bad'));

-- ===========================================
-- ENTERTAINMENT FACILITIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS entertainment_facilities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

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
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

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
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    hand_pumps TEXT,
    hand_pumps_distance DECIMAL(5,1),
    hand_pumps_quality TEXT CHECK (hand_pumps_quality IN ('good', 'average', 'bad')),
    well TEXT,
    well_distance DECIMAL(5,1),
    well_quality TEXT CHECK (well_quality IN ('good', 'average', 'bad')),
    tubewell TEXT,
    tubewell_distance DECIMAL(5,1),
    tubewell_quality TEXT CHECK (tubewell_quality IN ('good', 'average', 'bad')),
    nal_jaal TEXT,
    nal_jaal_quality TEXT CHECK (nal_jaal_quality IN ('good', 'average', 'bad')),
    other_sources TEXT,
    other_distance DECIMAL(5,1),
    other_sources_quality TEXT CHECK (other_sources_quality IN ('good', 'average', 'bad')),

    UNIQUE(phone_number)
);

-- Add water quality columns to existing tables (migration)
ALTER TABLE drinking_water_sources DROP CONSTRAINT IF EXISTS drinking_water_sources_hand_pumps_quality_check;
ALTER TABLE drinking_water_sources ADD CONSTRAINT drinking_water_sources_hand_pumps_quality_check CHECK (hand_pumps_quality IN ('good', 'average', 'bad'));
ALTER TABLE drinking_water_sources DROP CONSTRAINT IF EXISTS drinking_water_sources_well_quality_check;
ALTER TABLE drinking_water_sources ADD CONSTRAINT drinking_water_sources_well_quality_check CHECK (well_quality IN ('good', 'average', 'bad'));
ALTER TABLE drinking_water_sources DROP CONSTRAINT IF EXISTS drinking_water_sources_tubewell_quality_check;
ALTER TABLE drinking_water_sources ADD CONSTRAINT drinking_water_sources_tubewell_quality_check CHECK (tubewell_quality IN ('good', 'average', 'bad'));
ALTER TABLE drinking_water_sources DROP CONSTRAINT IF EXISTS drinking_water_sources_nal_jaal_quality_check;
ALTER TABLE drinking_water_sources ADD CONSTRAINT drinking_water_sources_nal_jaal_quality_check CHECK (nal_jaal_quality IN ('good', 'average', 'bad'));
ALTER TABLE drinking_water_sources DROP CONSTRAINT IF EXISTS drinking_water_sources_other_sources_quality_check;
ALTER TABLE drinking_water_sources ADD CONSTRAINT drinking_water_sources_other_sources_quality_check CHECK (other_sources_quality IN ('good', 'average', 'bad'));

-- ===========================================
-- MEDICAL TREATMENT TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS medical_treatment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    allopathic TEXT,
    ayurvedic TEXT,
    homeopathy TEXT,
    traditional TEXT,
    other_treatment TEXT,
    preferred_treatment TEXT CHECK (preferred_treatment IN ('allopathic', 'ayurvedic', 'homeopathy', 'traditional', 'other_treatment')),

    UNIQUE(phone_number)
);

-- ===========================================
-- DISPUTES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS disputes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

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
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    katcha TEXT,
    pakka TEXT,
    katcha_pakka TEXT,
    hut TEXT,

    UNIQUE(phone_number)
);

-- ===========================================
-- HOUSE FACILITIES TABLE (MERGED with nutritional_garden)
-- ===========================================
CREATE TABLE IF NOT EXISTS house_facilities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    toilet TEXT,
    toilet_in_use TEXT,
    toilet_condition TEXT,
    drainage TEXT,
    soak_pit TEXT,
    cattle_shed TEXT,
    compost_pit TEXT,
    nadep TEXT,
    lpg_gas TEXT,
    biogas TEXT,
    solar_cooking TEXT,
    electric_connection TEXT,
    nutritional_garden_available TEXT, -- Merged from nutritional_garden table
    tulsi_plants_available TEXT, -- Merged from tulsi_plants table

    UNIQUE(phone_number)
);

-- ===========================================
-- DISEASES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS diseases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
    disease_name TEXT,
    suffering_since TEXT,
    treatment_from TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - AADHAAR
-- ===========================================
CREATE TABLE IF NOT EXISTS aadhaar_info (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    have_aadhaar TEXT,
    name_included TEXT,
    details_correct TEXT,

    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS aadhaar_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
    registered TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - AYUSHMAN CARD
-- ===========================================
CREATE TABLE IF NOT EXISTS ayushman_card (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    eligible TEXT,
    have_card TEXT,
    details_correct TEXT,

    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS ayushman_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
    registered TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - FAMILY ID
-- ===========================================
CREATE TABLE IF NOT EXISTS family_id (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    have_family_id TEXT,
    name_included TEXT,
    details_correct TEXT,

    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS family_id_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
    registered TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - RATION CARD
-- ===========================================
CREATE TABLE IF NOT EXISTS ration_card (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    have_ration_card TEXT,
    name_included TEXT,
    details_correct TEXT,

    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS ration_card_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
    registered TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - SAMAGRA ID
-- ===========================================
CREATE TABLE IF NOT EXISTS samagra_id (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    details_correct TEXT,

    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS samagra_children (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
    have_id TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - TRIBAL CARD
-- ===========================================
CREATE TABLE IF NOT EXISTS tribal_card (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    applicable TEXT,
    details_correct TEXT,

    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS tribal_card_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
    registered TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - HANDICAPPED ALLOWANCE
-- ===========================================
CREATE TABLE IF NOT EXISTS handicapped_allowance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    applicable TEXT,
    details_correct TEXT,

    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS handicapped_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
    registered TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - PENSION ALLOWANCE
-- ===========================================
CREATE TABLE IF NOT EXISTS pension_allowance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    applicable TEXT,
    details_correct TEXT,

    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS pension_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
    registered TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - WIDOW ALLOWANCE
-- ===========================================
CREATE TABLE IF NOT EXISTS widow_allowance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    applicable TEXT,
    details_correct TEXT,

    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS widow_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT CHECK (sex IN ('male', 'female', 'other')),
    registered TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- FOLKLORE MEDICINE KNOWLEDGE TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS folklore_medicine (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    person_name TEXT,
    plant_local_name TEXT,
    plant_botanical_name TEXT,
    uses TEXT
);

-- ===========================================
-- HEALTH PROGRAMMES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS health_programmes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    vaccination_pregnancy TEXT,
    child_vaccination TEXT,
    vaccination_schedule TEXT,
    family_planning_awareness TEXT,
    contraceptive_applied TEXT,

    UNIQUE(phone_number)
);

-- ===========================================
-- CHILDREN'S DATA TABLE
-- ===========================================
-- AGRICULTURE DATA TABLE (MERGED: land_holding, irrigation_facilities, fertilizer_usage)
-- ===========================================
CREATE TABLE IF NOT EXISTS agriculture_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Land holding data
    irrigated_area DECIMAL(8,2),
    cultivable_area DECIMAL(8,2),
    orchard_plants_type TEXT,

    -- Irrigation facilities data
    canal TEXT,
    tube_well TEXT,
    ponds TEXT,
    other_sources TEXT,

    -- Fertilizer usage data
    chemical_fertilizer TEXT,
    organic_fertilizer TEXT,

    UNIQUE(phone_number)
);

-- ===========================================
-- MIGRATION DATA TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS migration_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    migration_type TEXT,
    distance TEXT,
    job_description TEXT,
    member_count INTEGER DEFAULT 0
);

-- ===========================================
-- TRAINING DATA TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS training_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    training_type TEXT,
    training_institute TEXT,
    year_of_passing INTEGER,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- CHILDREN DATA TABLE (added for policy references)
-- ===========================================
CREATE TABLE IF NOT EXISTS children_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    school_name TEXT,
    class TEXT,
    health_notes TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- MALNUTRITION DATA TABLE (added for policy references)
-- ===========================================
CREATE TABLE IF NOT EXISTS malnutrition_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    age INTEGER,
    sex TEXT,
    height_feet DECIMAL(3,1),
    weight_kg DECIMAL(5,1),
    disease_cause TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- SELF HELP GROUPS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS self_help_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    shg_name TEXT,
    purpose TEXT,
    agency TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- FARMER PRODUCER ORGANIZATIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS fpo_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    fpo_name TEXT,
    purpose TEXT,
    agency TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - VB GRAM
-- ===========================================
CREATE TABLE IF NOT EXISTS vb_gram (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    beneficiary TEXT,
    name_included TEXT,
    details_correct TEXT,

    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS vb_gram_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    received TEXT,
    days_worked INTEGER DEFAULT 0,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - PM KISAN NIDHI
-- ===========================================
CREATE TABLE IF NOT EXISTS pm_kisan_nidhi (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    beneficiary TEXT,
    name_included TEXT,
    details_correct TEXT,

    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS pm_kisan_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    family_member_name TEXT,
    received TEXT,
    days_worked INTEGER DEFAULT 0,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- GOVERNMENT SCHEMES - MERGED SMALL SCHEMES
-- ===========================================
CREATE TABLE IF NOT EXISTS merged_govt_schemes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- PM Kisan Samman Nidhi
    pm_kisan_samman_beneficiary TEXT,
    pm_kisan_samman_received TEXT,
    pm_kisan_samman_details_correct TEXT,

    -- Kisan Credit Card
    kisan_credit_card_beneficiary TEXT,
    kisan_credit_card_received TEXT,
    kisan_credit_card_details_correct TEXT,

    -- Swachh Bharat Mission
    swachh_bharat_beneficiary TEXT,
    swachh_bharat_received TEXT,
    swachh_bharat_details_correct TEXT,

    -- Fasal Bima
    fasal_bima_beneficiary TEXT,
    fasal_bima_received TEXT,
    fasal_bima_details_correct TEXT,
    UNIQUE(phone_number)
);

-- ===========================================
-- BANK ACCOUNTS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS bank_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    member_name TEXT,
    account_number TEXT,
    bank_name TEXT,
    details_correct TEXT,
    incorrect_details TEXT,

    UNIQUE(phone_number, sr_no)
);

-- ===========================================
-- SOCIAL CONSCIOUSNESS SURVEY TABLE
-- ===========================================
-- Note: Replaced legacy schema with new fields (Feb 2026)
CREATE TABLE IF NOT EXISTS social_consciousness (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Sync fields
    is_deleted BOOLEAN DEFAULT FALSE,

    -- Environmental Consciousness
    clothes_frequency TEXT,
    waste_disposal TEXT,
    separate_waste TEXT,
    recycle_wet_waste TEXT,
    recycle_method TEXT,
    recycle_water TEXT,
    water_recycle_usage TEXT,
    rainwater_harvesting TEXT,

    -- Household & Energy
    have_toilet TEXT,
    toilet_in_use TEXT,
    soak_pit TEXT,
    led_lights TEXT,
    turn_off_devices TEXT,
    fix_leaks TEXT,
    avoid_plastics TEXT,

    -- Spirituality & Community
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

    -- Well-being & Happiness
    family_happiness TEXT,
    personal_happiness TEXT,
    unhappiness_reason TEXT,
    financial_problems TEXT,
    family_disputes TEXT,
    illness_issues TEXT,
    other_unhappiness_reason TEXT,
    family_addictions TEXT,
    addiction_details TEXT,

    -- New Fields (Survey Update 2026)
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

-- Migration for existing tables
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS clothes_other_specify TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS food_waste_exists TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS food_waste_amount TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS waste_disposal_other TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS compost_pit TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS recycle_used_items TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS happiness_family_who TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS addiction_smoke TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS addiction_drink TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS addiction_gutka TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS addiction_gamble TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS addiction_tobacco TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS savings_exists TEXT;
ALTER TABLE social_consciousness ADD COLUMN IF NOT EXISTS savings_percentage TEXT;


-- ===========================================
-- TRIBAL FAMILIES ADDITIONAL QUESTIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS tribal_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

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
CREATE INDEX IF NOT EXISTS idx_shg_session ON self_help_groups(phone_number);
CREATE INDEX IF NOT EXISTS idx_fpo_session ON fpo_members(phone_number);

-- ===========================================
-- RLS POLICIES (Supabase specific - SECURE)
-- ===========================================

-- Enable RLS on all tables
ALTER TABLE family_survey_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_form_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE agriculture_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE crop_productivity ENABLE ROW LEVEL SECURITY;
ALTER TABLE animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE agricultural_equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE entertainment_facilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE transport_facilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE drinking_water_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_treatment ENABLE ROW LEVEL SECURITY;
ALTER TABLE disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE house_conditions ENABLE ROW LEVEL SECURITY;
ALTER TABLE house_facilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE diseases ENABLE ROW LEVEL SECURITY;
ALTER TABLE aadhaar_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE aadhaar_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE ayushman_card ENABLE ROW LEVEL SECURITY;
ALTER TABLE ayushman_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_id ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_id_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE ration_card ENABLE ROW LEVEL SECURITY;
ALTER TABLE ration_card_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE samagra_id ENABLE ROW LEVEL SECURITY;
ALTER TABLE samagra_children ENABLE ROW LEVEL SECURITY;
ALTER TABLE tribal_card ENABLE ROW LEVEL SECURITY;
ALTER TABLE tribal_card_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE handicapped_allowance ENABLE ROW LEVEL SECURITY;
ALTER TABLE handicapped_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE pension_allowance ENABLE ROW LEVEL SECURITY;
ALTER TABLE pension_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE widow_allowance ENABLE ROW LEVEL SECURITY;
ALTER TABLE widow_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE folklore_medicine ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_programmes ENABLE ROW LEVEL SECURITY;
ALTER TABLE children_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE malnutrition_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE migration_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE self_help_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE fpo_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE vb_gram ENABLE ROW LEVEL SECURITY;
ALTER TABLE vb_gram_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE pm_kisan_nidhi ENABLE ROW LEVEL SECURITY;
ALTER TABLE pm_kisan_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE merged_govt_schemes ENABLE ROW LEVEL SECURITY;
ALTER TABLE bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_consciousness ENABLE ROW LEVEL SECURITY;
ALTER TABLE tribal_questions ENABLE ROW LEVEL SECURITY;

-- SECURE RLS Policies: Users can only access their own surveys based on surveyor_email
DROP POLICY IF EXISTS "Users can access their own family surveys" ON family_survey_sessions;
CREATE POLICY "Users can access their own family surveys" ON family_survey_sessions
    FOR ALL USING (auth.jwt() ->> 'email' = surveyor_email);

DROP POLICY IF EXISTS "Users can access family form history from their surveys" ON family_form_history;
CREATE POLICY "Users can access family form history from their surveys" ON family_form_history
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = family_form_history.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

-- Child tables inherit the same restriction through foreign key relationships
DROP POLICY IF EXISTS "Users can access family members from their surveys" ON family_members;
CREATE POLICY "Users can access family members from their surveys" ON family_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = family_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access agriculture data from their surveys" ON agriculture_data;
CREATE POLICY "Users can access agriculture data from their surveys" ON agriculture_data
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = agriculture_data.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access crop productivity from their surveys" ON crop_productivity;
CREATE POLICY "Users can access crop productivity from their surveys" ON crop_productivity
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = crop_productivity.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access animals from their surveys" ON animals;
CREATE POLICY "Users can access animals from their surveys" ON animals
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = animals.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access agricultural equipment from their surveys" ON agricultural_equipment;
CREATE POLICY "Users can access agricultural equipment from their surveys" ON agricultural_equipment
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = agricultural_equipment.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access entertainment facilities from their surveys" ON entertainment_facilities;
CREATE POLICY "Users can access entertainment facilities from their surveys" ON entertainment_facilities
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = entertainment_facilities.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access transport facilities from their surveys" ON transport_facilities;
CREATE POLICY "Users can access transport facilities from their surveys" ON transport_facilities
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = transport_facilities.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access drinking water sources from their surveys" ON drinking_water_sources;
CREATE POLICY "Users can access drinking water sources from their surveys" ON drinking_water_sources
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = drinking_water_sources.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access medical treatment from their surveys" ON medical_treatment;
CREATE POLICY "Users can access medical treatment from their surveys" ON medical_treatment
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = medical_treatment.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access disputes from their surveys" ON disputes;
CREATE POLICY "Users can access disputes from their surveys" ON disputes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = disputes.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access house conditions from their surveys" ON house_conditions;
CREATE POLICY "Users can access house conditions from their surveys" ON house_conditions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = house_conditions.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access house facilities from their surveys" ON house_facilities;
CREATE POLICY "Users can access house facilities from their surveys" ON house_facilities
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = house_facilities.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access diseases from their surveys" ON diseases;
CREATE POLICY "Users can access diseases from their surveys" ON diseases
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = diseases.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access aadhaar info from their surveys" ON aadhaar_info;
CREATE POLICY "Users can access aadhaar info from their surveys" ON aadhaar_info
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = aadhaar_info.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access aadhaar members from their surveys" ON aadhaar_members;
CREATE POLICY "Users can access aadhaar members from their surveys" ON aadhaar_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = aadhaar_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access ayushman card from their surveys" ON ayushman_card;
CREATE POLICY "Users can access ayushman card from their surveys" ON ayushman_card
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = ayushman_card.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access ayushman members from their surveys" ON ayushman_members;
CREATE POLICY "Users can access ayushman members from their surveys" ON ayushman_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = ayushman_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access family id from their surveys" ON family_id;
CREATE POLICY "Users can access family id from their surveys" ON family_id
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = family_id.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access family id members from their surveys" ON family_id_members;
CREATE POLICY "Users can access family id members from their surveys" ON family_id_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = family_id_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access ration card from their surveys" ON ration_card;
CREATE POLICY "Users can access ration card from their surveys" ON ration_card
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = ration_card.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access ration card members from their surveys" ON ration_card_members;
CREATE POLICY "Users can access ration card members from their surveys" ON ration_card_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = ration_card_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access samagra id from their surveys" ON samagra_id;
CREATE POLICY "Users can access samagra id from their surveys" ON samagra_id
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = samagra_id.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access samagra children from their surveys" ON samagra_children;
CREATE POLICY "Users can access samagra children from their surveys" ON samagra_children
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = samagra_children.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access tribal card from their surveys" ON tribal_card;
CREATE POLICY "Users can access tribal card from their surveys" ON tribal_card
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = tribal_card.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access tribal card members from their surveys" ON tribal_card_members;
CREATE POLICY "Users can access tribal card members from their surveys" ON tribal_card_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = tribal_card_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access handicapped allowance from their surveys" ON handicapped_allowance;
CREATE POLICY "Users can access handicapped allowance from their surveys" ON handicapped_allowance
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = handicapped_allowance.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access handicapped members from their surveys" ON handicapped_members;
CREATE POLICY "Users can access handicapped members from their surveys" ON handicapped_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = handicapped_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access pension allowance from their surveys" ON pension_allowance;
CREATE POLICY "Users can access pension allowance from their surveys" ON pension_allowance
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = pension_allowance.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access pension members from their surveys" ON pension_members;
CREATE POLICY "Users can access pension members from their surveys" ON pension_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = pension_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access widow allowance from their surveys" ON widow_allowance;
CREATE POLICY "Users can access widow allowance from their surveys" ON widow_allowance
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = widow_allowance.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access widow members from their surveys" ON widow_members;
CREATE POLICY "Users can access widow members from their surveys" ON widow_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = widow_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access folklore medicine from their surveys" ON folklore_medicine;
CREATE POLICY "Users can access folklore medicine from their surveys" ON folklore_medicine
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = folklore_medicine.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access health programmes from their surveys" ON health_programmes;
CREATE POLICY "Users can access health programmes from their surveys" ON health_programmes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = health_programmes.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access children data from their surveys" ON children_data;
CREATE POLICY "Users can access children data from their surveys" ON children_data
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = children_data.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access malnutrition data from their surveys" ON malnutrition_data;
CREATE POLICY "Users can access malnutrition data from their surveys" ON malnutrition_data
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = malnutrition_data.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access migration data from their surveys" ON migration_data;
CREATE POLICY "Users can access migration data from their surveys" ON migration_data
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = migration_data.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access training data from their surveys" ON training_data;
CREATE POLICY "Users can access training data from their surveys" ON training_data
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = training_data.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access self help groups from their surveys" ON self_help_groups;
CREATE POLICY "Users can access self help groups from their surveys" ON self_help_groups
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = self_help_groups.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access fpo members from their surveys" ON fpo_members;
CREATE POLICY "Users can access fpo members from their surveys" ON fpo_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = fpo_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access vb gram from their surveys" ON vb_gram;
CREATE POLICY "Users can access vb gram from their surveys" ON vb_gram
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = vb_gram.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access vb gram members from their surveys" ON vb_gram_members;
CREATE POLICY "Users can access vb gram members from their surveys" ON vb_gram_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = vb_gram_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access pm kisan nidhi from their surveys" ON pm_kisan_nidhi;
CREATE POLICY "Users can access pm kisan nidhi from their surveys" ON pm_kisan_nidhi
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = pm_kisan_nidhi.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access pm kisan members from their surveys" ON pm_kisan_members;
CREATE POLICY "Users can access pm kisan members from their surveys" ON pm_kisan_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = pm_kisan_members.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access merged govt schemes from their surveys" ON merged_govt_schemes;
CREATE POLICY "Users can access merged govt schemes from their surveys" ON merged_govt_schemes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = merged_govt_schemes.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access bank accounts from their surveys" ON bank_accounts;
CREATE POLICY "Users can access bank accounts from their surveys" ON bank_accounts
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = bank_accounts.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access social consciousness from their surveys" ON social_consciousness;
CREATE POLICY "Users can access social consciousness from their surveys" ON social_consciousness
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = social_consciousness.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

DROP POLICY IF EXISTS "Users can access tribal questions from their surveys" ON tribal_questions;
CREATE POLICY "Users can access tribal questions from their surveys" ON tribal_questions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = tribal_questions.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

-- ============ l===============================
-- UPDATED AT TRIGGER FUNCTION (Supabase specific)
-- ===========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to main sessions table
CREATE TRIGGER update_family_sessions_updated_at
    BEFORE UPDATE ON family_survey_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();