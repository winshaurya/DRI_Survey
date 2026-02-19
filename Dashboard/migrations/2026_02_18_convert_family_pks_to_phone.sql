-- Migration: 2026-02-18
-- Purpose: Convert family-survey tables to use `phone_number` (INTEGER) as primary key
--          and make member lists use composite primary key (phone_number, sr_no).
-- Scope: FAMILY SURVEY only. DO NOT include village-survey tables in this migration.
-- IMPORTANT: BACKUP your Supabase Postgres DB before running. Run on staging first.

BEGIN;

-- SAFETY CHECKS -------------------------------------------------------------
DO $$
DECLARE
  bad_count integer;
  dup_count integer;
BEGIN
  -- Ensure primary sessions phone numbers are numeric and unique
  SELECT COUNT(*) INTO bad_count FROM family_survey_sessions WHERE phone_number IS NULL OR phone_number !~ '^[0-9]+$';
  IF bad_count > 0 THEN
    RAISE EXCEPTION 'Non-numeric or NULL phone_number values found in family_survey_sessions: %', bad_count;
  END IF;

  SELECT (COUNT(*) - COUNT(DISTINCT phone_number)) INTO dup_count FROM family_survey_sessions;
  IF dup_count > 0 THEN
    RAISE EXCEPTION 'Duplicate phone_number values found in family_survey_sessions: % rows', dup_count;
  END IF;

  -- Ensure family member composite keys are unique
  SELECT (COUNT(*) - COUNT(DISTINCT (phone_number || '|' || COALESCE(sr_no::text,'')))) INTO dup_count FROM family_members;
  IF dup_count > 0 THEN
    RAISE EXCEPTION 'Duplicate (phone_number,sr_no) found in family_members: % rows', dup_count;
  END IF;

  -- Add any additional family-survey table checks here as needed
END$$;

-- DROP FK CONSTRAINTS (IF PRESENT) -----------------------------------------
-- Drop constraints on family-survey referencing tables so we can alter types
ALTER TABLE IF EXISTS family_members     DROP CONSTRAINT IF EXISTS family_members_phone_number_fkey;
ALTER TABLE IF EXISTS bank_accounts     DROP CONSTRAINT IF EXISTS bank_accounts_phone_number_fkey;
ALTER TABLE IF EXISTS family_id         DROP CONSTRAINT IF EXISTS family_id_phone_number_fkey;
ALTER TABLE IF EXISTS aadhaar_info      DROP CONSTRAINT IF EXISTS aadhaar_info_phone_number_fkey;
ALTER TABLE IF EXISTS ayushman_card     DROP CONSTRAINT IF EXISTS ayushman_card_phone_number_fkey;
ALTER TABLE IF EXISTS samagra_id        DROP CONSTRAINT IF EXISTS samagra_id_phone_number_fkey;
ALTER TABLE IF EXISTS tribal_card       DROP CONSTRAINT IF EXISTS tribal_card_phone_number_fkey;
ALTER TABLE IF EXISTS merged_govt_schemes DROP CONSTRAINT IF EXISTS merged_govt_schemes_phone_number_fkey;
ALTER TABLE IF EXISTS pm_kisan_nidhi    DROP CONSTRAINT IF EXISTS pm_kisan_nidhi_phone_number_fkey;
ALTER TABLE IF EXISTS pm_kisan_samman_nidhi DROP CONSTRAINT IF EXISTS pm_kisan_samman_nidhi_phone_number_fkey;
ALTER TABLE IF EXISTS vb_gram           DROP CONSTRAINT IF EXISTS vb_gram_phone_number_fkey;
ALTER TABLE IF EXISTS pension_allowance DROP CONSTRAINT IF EXISTS pension_allowance_phone_number_fkey;
ALTER TABLE IF EXISTS widow_allowance   DROP CONSTRAINT IF EXISTS widow_allowance_phone_number_fkey;

-- ALTER referencing columns to INTEGER using USING cast ----------------------
ALTER TABLE IF EXISTS family_members     ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS bank_accounts      ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS family_id          ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS aadhaar_info       ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS ayushman_card      ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS samagra_id         ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS tribal_card        ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS merged_govt_schemes ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS pm_kisan_nidhi     ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS pm_kisan_samman_nidhi ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS vb_gram            ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS pension_allowance  ALTER COLUMN phone_number TYPE integer USING phone_number::integer;
ALTER TABLE IF EXISTS widow_allowance    ALTER COLUMN phone_number TYPE integer USING phone_number::integer;

-- Convert the primary family table column to INTEGER
ALTER TABLE IF EXISTS family_survey_sessions ALTER COLUMN phone_number TYPE integer USING phone_number::integer;

-- RECREATE FK CONSTRAINTS FOR FAMILY-SURVEY TABLES -------------------------
ALTER TABLE IF EXISTS family_members     ADD CONSTRAINT family_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS bank_accounts      ADD CONSTRAINT bank_accounts_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS family_id          ADD CONSTRAINT family_id_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS aadhaar_info       ADD CONSTRAINT aadhaar_info_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS ayushman_card      ADD CONSTRAINT ayushman_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS samagra_id         ADD CONSTRAINT samagra_id_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS tribal_card        ADD CONSTRAINT tribal_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS merged_govt_schemes ADD CONSTRAINT merged_govt_schemes_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS pm_kisan_nidhi     ADD CONSTRAINT pm_kisan_nidhi_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS pm_kisan_samman_nidhi ADD CONSTRAINT pm_kisan_samman_nidhi_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS vb_gram            ADD CONSTRAINT vb_gram_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS pension_allowance  ADD CONSTRAINT pension_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS widow_allowance    ADD CONSTRAINT widow_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;

-- DROP legacy id columns and add PRIMARY KEYs where applicable (family-only)
-- Composite PKs for member lists
ALTER TABLE IF EXISTS family_members DROP CONSTRAINT IF EXISTS family_members_pkey;
ALTER TABLE IF EXISTS family_members DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS family_members ADD PRIMARY KEY (phone_number, sr_no);

ALTER TABLE IF EXISTS family_id_scheme_members DROP CONSTRAINT IF EXISTS family_id_scheme_members_pkey;
ALTER TABLE IF EXISTS family_id_scheme_members DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS family_id_scheme_members ADD PRIMARY KEY (phone_number, sr_no);

ALTER TABLE IF EXISTS samagra_scheme_members DROP CONSTRAINT IF EXISTS samagra_scheme_members_pkey;
ALTER TABLE IF EXISTS samagra_scheme_members DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS samagra_scheme_members ADD PRIMARY KEY (phone_number, sr_no);

ALTER TABLE IF EXISTS tribal_scheme_members DROP CONSTRAINT IF EXISTS tribal_scheme_members_pkey;
ALTER TABLE IF EXISTS tribal_scheme_members DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS tribal_scheme_members ADD PRIMARY KEY (phone_number, sr_no);

ALTER TABLE IF EXISTS handicapped_scheme_members DROP CONSTRAINT IF EXISTS handicapped_scheme_members_pkey;
ALTER TABLE IF EXISTS handicapped_scheme_members DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS handicapped_scheme_members ADD PRIMARY KEY (phone_number, sr_no);

ALTER TABLE IF EXISTS vb_gram_members DROP CONSTRAINT IF EXISTS vb_gram_members_pkey;
ALTER TABLE IF EXISTS vb_gram_members DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS vb_gram_members ADD PRIMARY KEY (phone_number, sr_no);

ALTER TABLE IF EXISTS pm_kisan_members DROP CONSTRAINT IF EXISTS pm_kisan_members_pkey;
ALTER TABLE IF EXISTS pm_kisan_members DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS pm_kisan_members ADD PRIMARY KEY (phone_number, sr_no);

ALTER TABLE IF EXISTS pm_kisan_samman_members DROP CONSTRAINT IF EXISTS pm_kisan_samman_members_pkey;
ALTER TABLE IF EXISTS pm_kisan_samman_members DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS pm_kisan_samman_members ADD PRIMARY KEY (phone_number, sr_no);

-- Single-row family child tables: drop id and ensure unique/primary key by phone_number
ALTER TABLE IF EXISTS family_id DROP CONSTRAINT IF EXISTS family_id_pkey;
ALTER TABLE IF EXISTS family_id DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS family_id ADD PRIMARY KEY (phone_number);

ALTER TABLE IF EXISTS aadhaar_info DROP CONSTRAINT IF EXISTS aadhaar_info_pkey;
ALTER TABLE IF EXISTS aadhaar_info DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS aadhaar_info ADD PRIMARY KEY (phone_number);

ALTER TABLE IF EXISTS ayushman_card DROP CONSTRAINT IF EXISTS ayushman_card_pkey;
ALTER TABLE IF EXISTS ayushman_card DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS ayushman_card ADD PRIMARY KEY (phone_number);

ALTER TABLE IF EXISTS samagra_id DROP CONSTRAINT IF EXISTS samagra_id_pkey;
ALTER TABLE IF EXISTS samagra_id DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS samagra_id ADD PRIMARY KEY (phone_number);

ALTER TABLE IF EXISTS tribal_card DROP CONSTRAINT IF EXISTS tribal_card_pkey;
ALTER TABLE IF EXISTS tribal_card DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS tribal_card ADD PRIMARY KEY (phone_number);

ALTER TABLE IF EXISTS merged_govt_schemes DROP CONSTRAINT IF EXISTS merged_govt_schemes_pkey;
ALTER TABLE IF EXISTS merged_govt_schemes DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS merged_govt_schemes ADD PRIMARY KEY (phone_number);

ALTER TABLE IF EXISTS pm_kisan_nidhi DROP CONSTRAINT IF EXISTS pm_kisan_nidhi_pkey;
ALTER TABLE IF EXISTS pm_kisan_nidhi DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS pm_kisan_nidhi ADD PRIMARY KEY (phone_number);

ALTER TABLE IF EXISTS pm_kisan_samman_nidhi DROP CONSTRAINT IF EXISTS pm_kisan_samman_nidhi_pkey;
ALTER TABLE IF EXISTS pm_kisan_samman_nidhi DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS pm_kisan_samman_nidhi ADD PRIMARY KEY (phone_number);

ALTER TABLE IF EXISTS pension_allowance DROP CONSTRAINT IF EXISTS pension_allowance_pkey;
ALTER TABLE IF EXISTS pension_allowance DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS pension_allowance ADD PRIMARY KEY (phone_number);

ALTER TABLE IF EXISTS widow_allowance DROP CONSTRAINT IF EXISTS widow_allowance_pkey;
ALTER TABLE IF EXISTS widow_allowance DROP COLUMN IF EXISTS id;
ALTER TABLE IF EXISTS widow_allowance ADD PRIMARY KEY (phone_number);

COMMIT;

-- POST-MIGRATION CHECKLIST (run on staging and verify):
-- 1) Confirm family_survey_sessions.phone_number is INTEGER and primary key.
-- 2) Confirm member lists use PRIMARY KEY (phone_number, sr_no).
-- 3) Run application sync + smoke tests (create/update/delete) against staging DB.
-- 4) Update RLS policies, views, triggers and stored functions that referenced legacy `id`.
-- 5) Once validated, schedule production rollout: backup, apply migration, verify.

-- RUNNING THIS MIGRATION (example using psql):
-- 1) Backup: pg_dump --format=directory --schema=public --file=backup_dir "$CONN"
-- 2) Run on staging: psql "$STAGING_CONN" -f 2026_02_18_convert_family_pks_to_phone.sql
-- 3) Verify app behavior on staging. If OK, run on production: psql "$PROD_CONN" -f 2026_02_18_convert_family_pks_to_phone.sql
