-- Migration: Supabase schema alignment (all recent changes)
-- Generated on 2026-02-07

BEGIN;

-- Rename legacy table if it exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'self_help_groups'
  ) AND NOT EXISTS (
    SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'shg_members'
  ) THEN
    EXECUTE 'ALTER TABLE self_help_groups RENAME TO shg_members';
  END IF;
END $$;

-- Core scheme tables (new or ensured)
CREATE TABLE IF NOT EXISTS shg_members (
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

CREATE TABLE IF NOT EXISTS vb_gram_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    member_name TEXT,
    name_included INTEGER,
    details_correct INTEGER,
    incorrect_details TEXT,
    received INTEGER,
    days TEXT,
    membership_details TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE IF NOT EXISTS pm_kisan_nidhi (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    is_beneficiary TEXT,
    total_members INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS pm_kisan_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    member_name TEXT,
    account_number TEXT,
    benefits_received TEXT,
    name_included INTEGER,
    details_correct INTEGER,
    incorrect_details TEXT,
    received INTEGER,
    days TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE IF NOT EXISTS pm_kisan_samman_nidhi (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    is_beneficiary TEXT,
    total_members INTEGER,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS pm_kisan_samman_members (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER,
    member_name TEXT,
    account_number TEXT,
    benefits_received TEXT,
    name_included INTEGER,
    details_correct INTEGER,
    incorrect_details TEXT,
    received INTEGER,
    days TEXT,
    created_at TEXT DEFAULT NOW()::TEXT
);

CREATE TABLE IF NOT EXISTS tribal_questions (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    deity_name TEXT,
    festival_name TEXT,
    dance_name TEXT,
    language TEXT,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

CREATE TABLE IF NOT EXISTS merged_govt_schemes (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    phone_number TEXT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    scheme_data TEXT,
    created_at TEXT DEFAULT NOW()::TEXT,
    UNIQUE(phone_number)
);

-- Ensure expected columns exist (safe for existing tables)
ALTER TABLE vb_gram_members ADD COLUMN IF NOT EXISTS name_included INTEGER;
ALTER TABLE vb_gram_members ADD COLUMN IF NOT EXISTS details_correct INTEGER;
ALTER TABLE vb_gram_members ADD COLUMN IF NOT EXISTS incorrect_details TEXT;
ALTER TABLE vb_gram_members ADD COLUMN IF NOT EXISTS received INTEGER;
ALTER TABLE vb_gram_members ADD COLUMN IF NOT EXISTS days TEXT;
ALTER TABLE vb_gram_members ADD COLUMN IF NOT EXISTS membership_details TEXT;

ALTER TABLE pm_kisan_members ADD COLUMN IF NOT EXISTS account_number TEXT;
ALTER TABLE pm_kisan_members ADD COLUMN IF NOT EXISTS benefits_received TEXT;
ALTER TABLE pm_kisan_members ADD COLUMN IF NOT EXISTS name_included INTEGER;
ALTER TABLE pm_kisan_members ADD COLUMN IF NOT EXISTS details_correct INTEGER;
ALTER TABLE pm_kisan_members ADD COLUMN IF NOT EXISTS incorrect_details TEXT;
ALTER TABLE pm_kisan_members ADD COLUMN IF NOT EXISTS received INTEGER;
ALTER TABLE pm_kisan_members ADD COLUMN IF NOT EXISTS days TEXT;

-- RLS policies for new/renamed tables
ALTER TABLE shg_members ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "SHG members - Users access own data" ON shg_members;
CREATE POLICY "SHG members - Users access own data" ON shg_members
    FOR ALL USING (
        EXISTS (SELECT 1 FROM family_survey_sessions
                 WHERE phone_number = shg_members.phone_number
                 AND surveyor_email = auth.jwt() ->> 'email')
    );

ALTER TABLE vb_gram ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "VB Gram - Users access own data" ON vb_gram;
CREATE POLICY "VB Gram - Users access own data" ON vb_gram
    FOR ALL USING (
        EXISTS (SELECT 1 FROM family_survey_sessions
                 WHERE phone_number = vb_gram.phone_number
                 AND surveyor_email = auth.jwt() ->> 'email')
    );

ALTER TABLE vb_gram_members ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "VB Gram members - Users access own data" ON vb_gram_members;
CREATE POLICY "VB Gram members - Users access own data" ON vb_gram_members
    FOR ALL USING (
        EXISTS (SELECT 1 FROM family_survey_sessions
                 WHERE phone_number = vb_gram_members.phone_number
                 AND surveyor_email = auth.jwt() ->> 'email')
    );

ALTER TABLE pm_kisan_nidhi ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "PM Kisan - Users access own data" ON pm_kisan_nidhi;
CREATE POLICY "PM Kisan - Users access own data" ON pm_kisan_nidhi
    FOR ALL USING (
        EXISTS (SELECT 1 FROM family_survey_sessions
                 WHERE phone_number = pm_kisan_nidhi.phone_number
                 AND surveyor_email = auth.jwt() ->> 'email')
    );

ALTER TABLE pm_kisan_members ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "PM Kisan members - Users access own data" ON pm_kisan_members;
CREATE POLICY "PM Kisan members - Users access own data" ON pm_kisan_members
    FOR ALL USING (
        EXISTS (SELECT 1 FROM family_survey_sessions
                 WHERE phone_number = pm_kisan_members.phone_number
                 AND surveyor_email = auth.jwt() ->> 'email')
    );

ALTER TABLE pm_kisan_samman_nidhi ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "PM Kisan Samman - Users access own data" ON pm_kisan_samman_nidhi;
CREATE POLICY "PM Kisan Samman - Users access own data" ON pm_kisan_samman_nidhi
    FOR ALL USING (
        EXISTS (SELECT 1 FROM family_survey_sessions
                 WHERE phone_number = pm_kisan_samman_nidhi.phone_number
                 AND surveyor_email = auth.jwt() ->> 'email')
    );

ALTER TABLE pm_kisan_samman_members ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "PM Kisan Samman members - Users access own data" ON pm_kisan_samman_members;
CREATE POLICY "PM Kisan Samman members - Users access own data" ON pm_kisan_samman_members
    FOR ALL USING (
        EXISTS (SELECT 1 FROM family_survey_sessions
                 WHERE phone_number = pm_kisan_samman_members.phone_number
                 AND surveyor_email = auth.jwt() ->> 'email')
    );

COMMIT;
