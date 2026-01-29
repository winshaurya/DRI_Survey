-- Village Survey Schema for Supabase
-- This schema can be run multiple times safely (idempotent)
-- Compatible with both Supabase and SQLite

-- Enable necessary extensions (Supabase specific)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ===========================================
-- VILLAGE SURVEY SESSIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_survey_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT UNIQUE NOT NULL,
    surveyor_email TEXT NOT NULL, -- For audit trails and RLS
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Village Basic Information
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

    -- GPS Coordinates
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    location_accuracy DECIMAL(5,2),
    location_timestamp TIMESTAMPTZ,

    -- Survey Metadata
    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'exported')),
    device_info JSONB,
    app_version TEXT,

    -- Audit fields
    created_by TEXT,
    updated_by TEXT,

    -- Sync fields
    is_deleted BOOLEAN DEFAULT FALSE,
    last_synced_at TIMESTAMPTZ
);

-- ===========================================
-- VILLAGE POPULATION TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_population (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Sync fields
    is_deleted BOOLEAN DEFAULT FALSE,

    -- Population demographics
    total_population INTEGER DEFAULT 0,
    male_population INTEGER DEFAULT 0,
    female_population INTEGER DEFAULT 0,
    other_population INTEGER DEFAULT 0,

    -- Age groups
    children_0_5 INTEGER DEFAULT 0,
    children_6_14 INTEGER DEFAULT 0,
    youth_15_24 INTEGER DEFAULT 0,
    adults_25_59 INTEGER DEFAULT 0,
    seniors_60_plus INTEGER DEFAULT 0,

    -- Education levels
    illiterate_population INTEGER DEFAULT 0,
    primary_educated INTEGER DEFAULT 0,
    secondary_educated INTEGER DEFAULT 0,
    higher_educated INTEGER DEFAULT 0,

    -- Caste categories
    sc_population INTEGER DEFAULT 0,
    st_population INTEGER DEFAULT 0,
    obc_population INTEGER DEFAULT 0,
    general_population INTEGER DEFAULT 0,

    -- Working population
    working_population INTEGER DEFAULT 0,
    unemployed_population INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE FARM FAMILIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_farm_families (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Farm family categories by landholding
    big_farmers INTEGER DEFAULT 0, -- > 5 Hectare
    small_farmers INTEGER DEFAULT 0, -- 1-5 Hectare
    marginal_farmers INTEGER DEFAULT 0, -- Up to 1 Hectare
    landless_farmers INTEGER DEFAULT 0,

    -- Calculated totals
    total_farm_families INTEGER GENERATED ALWAYS AS (
        COALESCE(big_farmers, 0) +
        COALESCE(small_farmers, 0) +
        COALESCE(marginal_farmers, 0) +
        COALESCE(landless_farmers, 0)
    ) STORED,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE HOUSING TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_housing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Housing types
    katcha_houses INTEGER DEFAULT 0,
    pakka_houses INTEGER DEFAULT 0,
    katcha_pakka_houses INTEGER DEFAULT 0,
    hut_houses INTEGER DEFAULT 0,

    -- Housing facilities
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

-- ===========================================
-- VILLAGE AGRICULTURAL IMPLEMENT TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_agricultural_implements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Implements availability
    tractor_available BOOLEAN DEFAULT FALSE,
    thresher_available BOOLEAN DEFAULT FALSE,
    seed_drill_available BOOLEAN DEFAULT FALSE,
    sprayer_available BOOLEAN DEFAULT FALSE,
    duster_available BOOLEAN DEFAULT FALSE,
    diesel_engine_available BOOLEAN DEFAULT FALSE,
    other_implements TEXT,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE CROP PRODUCTIVITY TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_crop_productivity (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    crop_name TEXT,
    area_hectares DECIMAL(8,2),
    productivity_quintal_per_hectare DECIMAL(8,2),
    total_production_quintal DECIMAL(10,2),
    quantity_consumed_quintal DECIMAL(10,2),
    quantity_sold_quintal DECIMAL(10,2),

    UNIQUE(session_id, sr_no)
);

-- ===========================================
-- VILLAGE ANIMALS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_animals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    animal_type TEXT,
    total_count INTEGER,
    breed TEXT,

    UNIQUE(session_id, sr_no)
);

-- ===========================================
-- VILLAGE IRRIGATION FACILITIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_irrigation_facilities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    canal_available BOOLEAN DEFAULT FALSE,
    tube_well_available BOOLEAN DEFAULT FALSE,
    pond_available BOOLEAN DEFAULT FALSE,
    other_sources TEXT,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE DRINKING WATER SOURCES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_drinking_water (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    hand_pumps_available BOOLEAN DEFAULT FALSE,
    hand_pumps_count INTEGER DEFAULT 0,
    wells_available BOOLEAN DEFAULT FALSE,
    wells_count INTEGER DEFAULT 0,
    tube_wells_available BOOLEAN DEFAULT FALSE,
    tube_wells_count INTEGER DEFAULT 0,
    nal_jal_available BOOLEAN DEFAULT FALSE,
    other_sources TEXT,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE TRANSPORT FACILITIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_transport (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    cars_available BOOLEAN DEFAULT FALSE,
    motorcycles_available BOOLEAN DEFAULT FALSE,
    e_rickshaws_available BOOLEAN DEFAULT FALSE,
    cycles_available BOOLEAN DEFAULT FALSE,
    pickup_trucks_available BOOLEAN DEFAULT FALSE,
    bullock_carts_available BOOLEAN DEFAULT FALSE,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE ENTERTAINMENT FACILITIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_entertainment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    smart_mobiles_available BOOLEAN DEFAULT FALSE,
    smart_mobiles_count INTEGER DEFAULT 0,
    analog_mobiles_available BOOLEAN DEFAULT FALSE,
    analog_mobiles_count INTEGER DEFAULT 0,
    televisions_available BOOLEAN DEFAULT FALSE,
    televisions_count INTEGER DEFAULT 0,
    radios_available BOOLEAN DEFAULT FALSE,
    radios_count INTEGER DEFAULT 0,
    games_available BOOLEAN DEFAULT FALSE,
    other_entertainment TEXT,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE MEDICAL TREATMENT TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_medical_treatment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    allopathic_available BOOLEAN DEFAULT FALSE,
    ayurvedic_available BOOLEAN DEFAULT FALSE,
    homeopathic_available BOOLEAN DEFAULT FALSE,
    traditional_available BOOLEAN DEFAULT FALSE,
    jhad_phook_available BOOLEAN DEFAULT FALSE,
    other_treatment TEXT,
    preference_order TEXT, -- JSON array of preferences

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE DISPUTES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_disputes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    family_disputes BOOLEAN DEFAULT FALSE,
    family_registered BOOLEAN DEFAULT FALSE,
    family_period TEXT,

    revenue_disputes BOOLEAN DEFAULT FALSE,
    revenue_registered BOOLEAN DEFAULT FALSE,
    revenue_period TEXT,

    criminal_disputes BOOLEAN DEFAULT FALSE,
    criminal_registered BOOLEAN DEFAULT FALSE,
    criminal_period TEXT,

    other_disputes BOOLEAN DEFAULT FALSE,
    other_description TEXT,
    other_registered BOOLEAN DEFAULT FALSE,
    other_period TEXT,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE EDUCATIONAL FACILITIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_educational_facilities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Schools by level
    primary_schools INTEGER DEFAULT 0,
    middle_schools INTEGER DEFAULT 0,
    secondary_schools INTEGER DEFAULT 0,
    higher_secondary_schools INTEGER DEFAULT 0,

    -- Other facilities
    anganwadi_centers INTEGER DEFAULT 0,
    skill_development_centers INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE SOCIAL CONSCIOUSNESS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_social_consciousness (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Lifestyle habits
    clothing_purchase_frequency TEXT,
    food_waste_level TEXT,
    food_waste_amount TEXT,
    waste_disposal_method TEXT,
    waste_segregation BOOLEAN DEFAULT FALSE,
    compost_pit_available BOOLEAN DEFAULT FALSE,

    -- Utilities
    toilet_available BOOLEAN DEFAULT FALSE,
    toilet_functional BOOLEAN DEFAULT FALSE,
    toilet_soak_pit BOOLEAN DEFAULT FALSE,
    led_lights_used BOOLEAN DEFAULT FALSE,
    devices_turned_off BOOLEAN DEFAULT FALSE,
    water_leaks_fixed BOOLEAN DEFAULT FALSE,
    plastic_avoidance BOOLEAN DEFAULT FALSE,

    -- Spiritual activities
    family_puja BOOLEAN DEFAULT FALSE,
    family_meditation BOOLEAN DEFAULT FALSE,
    meditation_participants TEXT,
    family_yoga BOOLEAN DEFAULT FALSE,
    yoga_participants TEXT,

    -- Community activities
    community_activities BOOLEAN DEFAULT FALSE,
    activity_types TEXT,
    shram_sadhana BOOLEAN DEFAULT FALSE,
    shram_participants TEXT,
    spiritual_discourses BOOLEAN DEFAULT FALSE,
    discourse_participants TEXT,

    -- Happiness indicators
    family_happiness TEXT,
    happy_members TEXT,
    happiness_reasons TEXT,

    -- Negative habits
    smoking_prevalence TEXT,
    drinking_prevalence TEXT,
    gudka_prevalence TEXT,
    gambling_prevalence TEXT,
    tobacco_prevalence TEXT,

    -- Financial habits
    saving_habit TEXT,
    saving_percentage TEXT,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE CHILDREN DATA TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_children_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    births_last_3_years INTEGER DEFAULT 0,
    infant_deaths_last_3_years INTEGER DEFAULT 0,
    malnourished_children INTEGER DEFAULT 0,
    malnourished_adults INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE MALNUTRITION DATA TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_malnutrition_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    name TEXT,
    sex TEXT,
    age INTEGER,
    height_feet DECIMAL(3,1),
    weight_kg DECIMAL(5,1),
    disease_cause TEXT,

    UNIQUE(session_id, sr_no)
);

-- ===========================================
-- VILLAGE BPL FAMILIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_bpl_families (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    total_bpl_families INTEGER DEFAULT 0,
    bpl_families_with_job_cards INTEGER DEFAULT 0,
    bpl_families_received_mgnrega INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE KITCHEN GARDENS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_kitchen_gardens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    gardens_available BOOLEAN DEFAULT FALSE,
    total_gardens INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE SEED CLUBS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_seed_clubs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    clubs_available BOOLEAN DEFAULT FALSE,
    total_clubs INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE BIODIVERSITY REGISTER TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_biodiversity_register (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    register_available BOOLEAN DEFAULT FALSE,
    total_entries INTEGER DEFAULT 0,

    UNIQUE(session_id)
);

-- ===========================================
-- VILLAGE TRADITIONAL OCCUPATIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_traditional_occupations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    sr_no INTEGER NOT NULL,
    occupation_name TEXT,
    families_engaged INTEGER,
    average_income DECIMAL(10,2),

    UNIQUE(session_id, sr_no)
);

-- ===========================================
-- VILLAGE UNEMPLOYMENT TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS village_unemployment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    unemployed_youth INTEGER DEFAULT 0,
    unemployed_adults INTEGER DEFAULT 0,
    total_unemployed INTEGER GENERATED ALWAYS AS (
        COALESCE(unemployed_youth, 0) + COALESCE(unemployed_adults, 0)
    ) STORED,

    UNIQUE(session_id)
);

-- ===========================================
-- INDEXES FOR PERFORMANCE
-- ===========================================
CREATE INDEX IF NOT EXISTS idx_village_sessions_status ON village_survey_sessions(status);
CREATE INDEX IF NOT EXISTS idx_village_sessions_date ON village_survey_sessions(survey_date);
CREATE INDEX IF NOT EXISTS idx_village_sessions_shine ON village_survey_sessions(shine_code);
CREATE INDEX IF NOT EXISTS idx_village_population_session ON village_population(session_id);
CREATE INDEX IF NOT EXISTS idx_village_farm_families_session ON village_farm_families(session_id);
CREATE INDEX IF NOT EXISTS idx_village_housing_session ON village_housing(session_id);
CREATE INDEX IF NOT EXISTS idx_village_crop_productivity_session ON village_crop_productivity(session_id);
CREATE INDEX IF NOT EXISTS idx_village_animals_session ON village_animals(session_id);

-- ===========================================
-- RLS POLICIES (Supabase specific)
-- ===========================================
ALTER TABLE village_survey_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_population ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_farm_families ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_housing ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_agricultural_implements ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_crop_productivity ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_irrigation_facilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_drinking_water ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_transport ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_entertainment ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_medical_treatment ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_educational_facilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_social_consciousness ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_children_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_malnutrition_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_bpl_families ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_kitchen_gardens ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_seed_clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_biodiversity_register ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_traditional_occupations ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_unemployment ENABLE ROW LEVEL SECURITY;

-- SECURE RLS Policies: Users can only access their own village surveys based on surveyor_email
CREATE POLICY "Users can access their own village surveys" ON village_survey_sessions
    FOR ALL USING (auth.jwt() ->> 'email' = surveyor_email);

-- Child tables inherit the same restriction through foreign key relationships
CREATE POLICY "Users can access village population from their surveys" ON village_population
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_population.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village farm families from their surveys" ON village_farm_families
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_farm_families.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village housing from their surveys" ON village_housing
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_housing.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village agricultural implements from their surveys" ON village_agricultural_implements
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_agricultural_implements.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village crop productivity from their surveys" ON village_crop_productivity
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_crop_productivity.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village animals from their surveys" ON village_animals
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_animals.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village irrigation facilities from their surveys" ON village_irrigation_facilities
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_irrigation_facilities.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village drinking water from their surveys" ON village_drinking_water
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_drinking_water.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village transport from their surveys" ON village_transport
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_transport.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village entertainment from their surveys" ON village_entertainment
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_entertainment.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village medical treatment from their surveys" ON village_medical_treatment
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_medical_treatment.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village disputes from their surveys" ON village_disputes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_disputes.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village educational facilities from their surveys" ON village_educational_facilities
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_educational_facilities.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village social consciousness from their surveys" ON village_social_consciousness
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_social_consciousness.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village children data from their surveys" ON village_children_data
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_children_data.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village malnutrition data from their surveys" ON village_malnutrition_data
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_malnutrition_data.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village bpl families from their surveys" ON village_bpl_families
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_bpl_families.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village kitchen gardens from their surveys" ON village_kitchen_gardens
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_kitchen_gardens.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village seed clubs from their surveys" ON village_seed_clubs
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_seed_clubs.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village biodiversity register from their surveys" ON village_biodiversity_register
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_biodiversity_register.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village traditional occupations from their surveys" ON village_traditional_occupations
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_traditional_occupations.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

CREATE POLICY "Users can access village unemployment from their surveys" ON village_unemployment
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM village_survey_sessions
            WHERE session_id = village_unemployment.session_id
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

-- ===========================================
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
CREATE TRIGGER update_village_sessions_updated_at
    BEFORE UPDATE ON village_survey_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();