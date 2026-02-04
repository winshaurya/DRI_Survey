-- Migration Script v1: Align Supabase Schema with App Code
-- Run this script in the Supabase SQL Editor to update your tables.

-- ===========================================
-- 1. VILLAGE SURVEY UPDATES
-- ===========================================

-- Update village_irrigation_facilities (Use INTEGER 0/1 to match App)
ALTER TABLE village_irrigation_facilities 
ADD COLUMN IF NOT EXISTS has_canal INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS has_tube_well INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS has_ponds INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS has_river INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS has_well INTEGER DEFAULT 0;

-- Create missing village_signboards table
CREATE TABLE IF NOT EXISTS village_signboards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    signboards TEXT,
    info_boards TEXT,
    wall_writing TEXT,
    UNIQUE(session_id)
);
ALTER TABLE village_signboards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access village signboards" ON village_signboards FOR ALL USING (auth.jwt() ->> 'email' = (SELECT surveyor_email FROM village_survey_sessions WHERE session_id = village_signboards.session_id));

-- Create missing village_social_maps table
CREATE TABLE IF NOT EXISTS village_social_maps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id TEXT NOT NULL REFERENCES village_survey_sessions(session_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    remarks TEXT,
    UNIQUE(session_id)
);
ALTER TABLE village_social_maps ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access village social maps" ON village_social_maps FOR ALL USING (auth.jwt() ->> 'email' = (SELECT surveyor_email FROM village_survey_sessions WHERE session_id = village_social_maps.session_id));


-- ===========================================
-- 2. FAMILY SURVEY UPDATES
-- ===========================================

-- Update tribal_questions
ALTER TABLE tribal_questions 
ADD COLUMN IF NOT EXISTS deity_name TEXT,
ADD COLUMN IF NOT EXISTS festival_name TEXT,
ADD COLUMN IF NOT EXISTS dance_name TEXT,
ADD COLUMN IF NOT EXISTS language TEXT;

-- Update training_data
ALTER TABLE training_data 
ADD COLUMN IF NOT EXISTS training_topic TEXT,
ADD COLUMN IF NOT EXISTS training_duration TEXT,
ADD COLUMN IF NOT EXISTS training_date TEXT,
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'taken';

-- Update migration_data
ALTER TABLE migration_data 
ADD COLUMN IF NOT EXISTS reason TEXT,
ADD COLUMN IF NOT EXISTS duration TEXT,
ADD COLUMN IF NOT EXISTS destination TEXT,
ADD COLUMN IF NOT EXISTS family_members_migrated INTEGER DEFAULT 0;

-- Update social_consciousness
ALTER TABLE social_consciousness 
ADD COLUMN IF NOT EXISTS saving_habit TEXT;

-- Create missing children_data table
CREATE TABLE IF NOT EXISTS children_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    births_last_3_years INTEGER DEFAULT 0,
    infant_deaths_last_3_years INTEGER DEFAULT 0,
    malnourished_children INTEGER DEFAULT 0,
    UNIQUE(phone_number)
);
ALTER TABLE children_data ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access children data" ON children_data FOR ALL USING (auth.jwt() ->> 'email' = (SELECT surveyor_email FROM family_survey_sessions WHERE phone_number = children_data.phone_number));

-- Create missing malnourished_children_data table
CREATE TABLE IF NOT EXISTS malnourished_children_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    child_id TEXT,
    child_name TEXT,
    height DECIMAL(5,2),
    weight DECIMAL(5,2)
);
ALTER TABLE malnourished_children_data ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access malnourished children" ON malnourished_children_data FOR ALL USING (auth.jwt() ->> 'email' = (SELECT surveyor_email FROM family_survey_sessions WHERE phone_number = malnourished_children_data.phone_number));

-- Create missing child_diseases table
CREATE TABLE IF NOT EXISTS child_diseases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    child_id TEXT,
    disease_name TEXT,
    sr_no INTEGER
);
ALTER TABLE child_diseases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access child diseases" ON child_diseases FOR ALL USING (auth.jwt() ->> 'email' = (SELECT surveyor_email FROM family_survey_sessions WHERE phone_number = child_diseases.phone_number));
