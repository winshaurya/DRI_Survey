-- ========================================
-- MIGRATION: Make phone_number the primary key for family_survey_sessions
-- Date: February 9, 2026
-- Purpose: Align Supabase schema with SQLite schema for consistent sync
-- ========================================

-- Step 1: Drop existing primary key constraint and unique constraint on phone_number
ALTER TABLE family_survey_sessions DROP CONSTRAINT IF EXISTS family_survey_sessions_pkey;
ALTER TABLE family_survey_sessions DROP CONSTRAINT IF EXISTS family_survey_sessions_phone_number_key;

-- Step 2: Add phone_number as primary key
ALTER TABLE family_survey_sessions ADD CONSTRAINT family_survey_sessions_pkey PRIMARY KEY (phone_number);

-- Step 3: Drop the id column since we no longer need it
ALTER TABLE family_survey_sessions DROP COLUMN IF EXISTS id;

-- Step 4: Update indexes
DROP INDEX IF EXISTS idx_family_sessions_phone;
CREATE INDEX IF NOT EXISTS idx_family_sessions_phone ON family_survey_sessions(phone_number);

-- Step 5: Verify the migration
-- This should show phone_number as the primary key
-- SELECT conname, contype FROM pg_constraint WHERE conrelid = 'family_survey_sessions'::regclass;