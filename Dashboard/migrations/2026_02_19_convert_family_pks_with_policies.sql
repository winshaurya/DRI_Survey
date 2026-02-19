-- Migration: 2026-02-19
-- Purpose: Same as 2026_02_18 but safely drops/recreates RLS policies that depend on `phone_number`.
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
ALTER TABLE IF EXISTS land_holding       DROP CONSTRAINT IF EXISTS land_holding_phone_number_fkey;
ALTER TABLE IF EXISTS irrigation_facilities DROP CONSTRAINT IF EXISTS irrigation_facilities_phone_number_fkey;
ALTER TABLE IF EXISTS crop_productivity DROP CONSTRAINT IF EXISTS crop_productivity_phone_number_fkey;
ALTER TABLE IF EXISTS fertilizer_usage  DROP CONSTRAINT IF EXISTS fertilizer_usage_phone_number_fkey;
ALTER TABLE IF EXISTS animals          DROP CONSTRAINT IF EXISTS animals_phone_number_fkey;
ALTER TABLE IF EXISTS agricultural_equipment DROP CONSTRAINT IF EXISTS agricultural_equipment_phone_number_fkey;
ALTER TABLE IF EXISTS entertainment_facilities DROP CONSTRAINT IF EXISTS entertainment_facilities_phone_number_fkey;
ALTER TABLE IF EXISTS transport_facilities DROP CONSTRAINT IF EXISTS transport_facilities_phone_number_fkey;
ALTER TABLE IF EXISTS drinking_water_sources DROP CONSTRAINT IF EXISTS drinking_water_sources_phone_number_fkey;
ALTER TABLE IF EXISTS medical_treatment DROP CONSTRAINT IF EXISTS medical_treatment_phone_number_fkey;
ALTER TABLE IF EXISTS disputes          DROP CONSTRAINT IF EXISTS disputes_phone_number_fkey;
ALTER TABLE IF EXISTS house_conditions DROP CONSTRAINT IF EXISTS house_conditions_phone_number_fkey;
ALTER TABLE IF EXISTS house_facilities DROP CONSTRAINT IF EXISTS house_facilities_phone_number_fkey;
ALTER TABLE IF EXISTS diseases         DROP CONSTRAINT IF EXISTS diseases_phone_number_fkey;
ALTER TABLE IF EXISTS social_consciousness DROP CONSTRAINT IF EXISTS social_consciousness_phone_number_fkey;
ALTER TABLE IF EXISTS aadhaar_info     DROP CONSTRAINT IF EXISTS aadhaar_info_phone_number_fkey;
ALTER TABLE IF EXISTS aadhaar_scheme_members DROP CONSTRAINT IF EXISTS aadhaar_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS ayushman_card    DROP CONSTRAINT IF EXISTS ayushman_card_phone_number_fkey;
ALTER TABLE IF EXISTS ayushman_scheme_members DROP CONSTRAINT IF EXISTS ayushman_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS family_id        DROP CONSTRAINT IF EXISTS family_id_phone_number_fkey;
ALTER TABLE IF EXISTS family_id_scheme_members DROP CONSTRAINT IF EXISTS family_id_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS ration_card      DROP CONSTRAINT IF EXISTS ration_card_phone_number_fkey;
ALTER TABLE IF EXISTS ration_scheme_members DROP CONSTRAINT IF EXISTS ration_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS samagra_id       DROP CONSTRAINT IF EXISTS samagra_id_phone_number_fkey;
ALTER TABLE IF EXISTS samagra_scheme_members DROP CONSTRAINT IF EXISTS samagra_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS tribal_card      DROP CONSTRAINT IF EXISTS tribal_card_phone_number_fkey;
ALTER TABLE IF EXISTS tribal_scheme_members DROP CONSTRAINT IF EXISTS tribal_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS handicapped_allowance DROP CONSTRAINT IF EXISTS handicapped_allowance_phone_number_fkey;
ALTER TABLE IF EXISTS handicapped_scheme_members DROP CONSTRAINT IF EXISTS handicapped_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS pension_allowance DROP CONSTRAINT IF EXISTS pension_allowance_phone_number_fkey;
ALTER TABLE IF EXISTS pension_scheme_members DROP CONSTRAINT IF EXISTS pension_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS widow_allowance   DROP CONSTRAINT IF EXISTS widow_allowance_phone_number_fkey;
ALTER TABLE IF EXISTS widow_scheme_members DROP CONSTRAINT IF EXISTS widow_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS vb_gram          DROP CONSTRAINT IF EXISTS vb_gram_phone_number_fkey;
ALTER TABLE IF EXISTS vb_gram_members  DROP CONSTRAINT IF EXISTS vb_gram_members_phone_number_fkey;
ALTER TABLE IF EXISTS pm_kisan_nidhi   DROP CONSTRAINT IF EXISTS pm_kisan_nidhi_phone_number_fkey;
ALTER TABLE IF EXISTS pm_kisan_members DROP CONSTRAINT IF EXISTS pm_kisan_members_phone_number_fkey;
ALTER TABLE IF EXISTS pm_kisan_samman_nidhi DROP CONSTRAINT IF EXISTS pm_kisan_samman_nidhi_phone_number_fkey;
ALTER TABLE IF EXISTS pm_kisan_samman_members DROP CONSTRAINT IF EXISTS pm_kisan_samman_members_phone_number_fkey;
ALTER TABLE IF EXISTS tribal_questions DROP CONSTRAINT IF EXISTS tribal_questions_phone_number_fkey;
ALTER TABLE IF EXISTS merged_govt_schemes DROP CONSTRAINT IF EXISTS merged_govt_schemes_phone_number_fkey;
ALTER TABLE IF EXISTS children_data    DROP CONSTRAINT IF EXISTS children_data_phone_number_fkey;
ALTER TABLE IF EXISTS malnourished_children_data DROP CONSTRAINT IF EXISTS malnourished_children_data_phone_number_fkey;
ALTER TABLE IF EXISTS child_diseases   DROP CONSTRAINT IF EXISTS child_diseases_phone_number_fkey;
ALTER TABLE IF EXISTS migration_data   DROP CONSTRAINT IF EXISTS migration_data_phone_number_fkey;
ALTER TABLE IF EXISTS training_data    DROP CONSTRAINT IF EXISTS training_data_phone_number_fkey;
ALTER TABLE IF EXISTS shg_members      DROP CONSTRAINT IF EXISTS shg_members_phone_number_fkey;
ALTER TABLE IF EXISTS fpo_members      DROP CONSTRAINT IF EXISTS fpo_members_phone_number_fkey;
ALTER TABLE IF EXISTS bank_accounts    DROP CONSTRAINT IF EXISTS bank_accounts_phone_number_fkey;
ALTER TABLE IF EXISTS folklore_medicine DROP CONSTRAINT IF EXISTS folklore_medicine_phone_number_fkey;
ALTER TABLE IF EXISTS health_programmes DROP CONSTRAINT IF EXISTS health_programmes_phone_number_fkey;
ALTER TABLE IF EXISTS tulsi_plants     DROP CONSTRAINT IF EXISTS tulsi_plants_phone_number_fkey;
ALTER TABLE IF EXISTS nutritional_garden DROP CONSTRAINT IF EXISTS nutritional_garden_phone_number_fkey;
ALTER TABLE IF EXISTS malnutrition_data DROP CONSTRAINT IF EXISTS malnutrition_data_phone_number_fkey;

-- DROP RLS POLICIES THAT DEPEND ON `phone_number` -------------------------
-- Dynamically drop any policy whose USING or WITH CHECK references `phone_number`.
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE (COALESCE(qual,'') ILIKE '%phone_number%' OR COALESCE(with_check,'') ILIKE '%phone_number%')
  LOOP
    RAISE NOTICE 'Dropping policy % on %.%', r.policyname, r.schemaname, r.tablename;
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
  END LOOP;
END$$;

-- ALTER referencing columns to INTEGER using USING cast ----------------------
-- ALTER referencing columns to BIGINT using USING cast ----------------------
ALTER TABLE IF EXISTS family_members     ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS land_holding       ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS irrigation_facilities ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS crop_productivity ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS fertilizer_usage  ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS animals           ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS agricultural_equipment ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS entertainment_facilities ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS transport_facilities ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS drinking_water_sources ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS medical_treatment ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS disputes          ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS house_conditions ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS house_facilities ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS diseases         ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS social_consciousness ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS aadhaar_info     ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS aadhaar_scheme_members ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS ayushman_card    ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS ayushman_scheme_members ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS family_id        ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS family_id_scheme_members ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS ration_card      ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS ration_scheme_members ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS samagra_id       ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS samagra_scheme_members ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS tribal_card      ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS tribal_scheme_members ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS handicapped_allowance ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS handicapped_scheme_members ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS pension_allowance ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS pension_scheme_members ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS widow_allowance   ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS widow_scheme_members ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS vb_gram          ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS vb_gram_members  ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS pm_kisan_nidhi   ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS pm_kisan_members ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS pm_kisan_samman_nidhi ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS pm_kisan_samman_members ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS tribal_questions ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS merged_govt_schemes ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS children_data    ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS malnourished_children_data ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS child_diseases   ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS migration_data   ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS training_data    ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS shg_members      ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS fpo_members      ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS bank_accounts    ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS folklore_medicine ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS health_programmes ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS tulsi_plants     ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS nutritional_garden ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;
ALTER TABLE IF EXISTS malnutrition_data ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;

-- Convert the primary family table column to BIGINT
ALTER TABLE IF EXISTS family_survey_sessions ALTER COLUMN phone_number TYPE bigint USING phone_number::bigint;

-- RECREATE FK CONSTRAINTS FOR FAMILY-SURVEY TABLES -------------------------
-- RECREATE FK CONSTRAINTS FOR FAMILY-SURVEY TABLES -------------------------
ALTER TABLE IF EXISTS family_members     ADD CONSTRAINT family_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS land_holding       ADD CONSTRAINT land_holding_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS irrigation_facilities ADD CONSTRAINT irrigation_facilities_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS crop_productivity ADD CONSTRAINT crop_productivity_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS fertilizer_usage  ADD CONSTRAINT fertilizer_usage_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS animals          ADD CONSTRAINT animals_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS agricultural_equipment ADD CONSTRAINT agricultural_equipment_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS entertainment_facilities ADD CONSTRAINT entertainment_facilities_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS transport_facilities ADD CONSTRAINT transport_facilities_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS drinking_water_sources ADD CONSTRAINT drinking_water_sources_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS medical_treatment ADD CONSTRAINT medical_treatment_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS disputes          ADD CONSTRAINT disputes_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS house_conditions ADD CONSTRAINT house_conditions_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS house_facilities ADD CONSTRAINT house_facilities_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS diseases         ADD CONSTRAINT diseases_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS social_consciousness ADD CONSTRAINT social_consciousness_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS aadhaar_info     ADD CONSTRAINT aadhaar_info_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS aadhaar_scheme_members ADD CONSTRAINT aadhaar_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS ayushman_card    ADD CONSTRAINT ayushman_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS ayushman_scheme_members ADD CONSTRAINT ayushman_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS family_id        ADD CONSTRAINT family_id_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS family_id_scheme_members ADD CONSTRAINT family_id_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS ration_card      ADD CONSTRAINT ration_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS ration_scheme_members ADD CONSTRAINT ration_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS samagra_id       ADD CONSTRAINT samagra_id_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS samagra_scheme_members ADD CONSTRAINT samagra_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS tribal_card      ADD CONSTRAINT tribal_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS tribal_scheme_members ADD CONSTRAINT tribal_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS handicapped_allowance ADD CONSTRAINT handicapped_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS handicapped_scheme_members ADD CONSTRAINT handicapped_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS pension_allowance ADD CONSTRAINT pension_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS pension_scheme_members ADD CONSTRAINT pension_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS widow_allowance   ADD CONSTRAINT widow_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS widow_scheme_members ADD CONSTRAINT widow_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS vb_gram          ADD CONSTRAINT vb_gram_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS vb_gram_members  ADD CONSTRAINT vb_gram_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS pm_kisan_nidhi   ADD CONSTRAINT pm_kisan_nidhi_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS pm_kisan_members ADD CONSTRAINT pm_kisan_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS pm_kisan_samman_nidhi ADD CONSTRAINT pm_kisan_samman_nidhi_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS pm_kisan_samman_members ADD CONSTRAINT pm_kisan_samman_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS tribal_questions ADD CONSTRAINT tribal_questions_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS merged_govt_schemes ADD CONSTRAINT merged_govt_schemes_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS children_data    ADD CONSTRAINT children_data_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS malnourished_children_data ADD CONSTRAINT malnourished_children_data_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS child_diseases   ADD CONSTRAINT child_diseases_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS migration_data   ADD CONSTRAINT migration_data_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS training_data    ADD CONSTRAINT training_data_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS shg_members      ADD CONSTRAINT shg_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS fpo_members      ADD CONSTRAINT fpo_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS bank_accounts    ADD CONSTRAINT bank_accounts_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS folklore_medicine ADD CONSTRAINT folklore_medicine_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS health_programmes ADD CONSTRAINT health_programmes_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS tulsi_plants     ADD CONSTRAINT tulsi_plants_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS nutritional_garden ADD CONSTRAINT nutritional_garden_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE IF EXISTS malnutrition_data ADD CONSTRAINT malnutrition_data_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;

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

-- RECREATE RLS POLICIES ----------------------------------------------------
-- Recreate the policies we dropped above. Adjust expressions if your app's auth claims differ.
CREATE POLICY "Family survey - Users access own sessions" ON family_survey_sessions
  USING (((auth.jwt() ->> 'email'::text) = surveyor_email));

CREATE POLICY "Family members - Users access own data" ON family_members
  USING ((EXISTS ( SELECT 1 FROM family_survey_sessions WHERE ((family_survey_sessions.phone_number = family_members.phone_number) AND (family_survey_sessions.surveyor_email = (auth.jwt() ->> 'email'::text))))));

COMMIT;

-- POST-MIGRATION CHECKLIST (run on staging and verify):
-- 1) Confirm family_survey_sessions.phone_number is INTEGER and primary key.
-- 2) Confirm member lists use PRIMARY KEY (phone_number, sr_no).
-- 3) Run application sync + smoke tests (create/update/delete) against staging DB.
-- 4) Update RLS policies, views, triggers and stored functions that referenced legacy `id`.
-- 5) Once validated, schedule production rollout: backup, apply migration, verify.

-- RUNNING THIS MIGRATION (example using psql):
-- 1) Backup: pg_dump --format=directory --schema=public --file=backup_dir "$CONN"
-- 2) Run on staging: psql "$STAGING_CONN" -f 2026_02_19_convert_family_pks_with_policies.sql
-- 3) Verify app behavior on staging. If OK, run on production: psql "$PROD_CONN" -f 2026_02_19_convert_family_pks_with_policies.sql
