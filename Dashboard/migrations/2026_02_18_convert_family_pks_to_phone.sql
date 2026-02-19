-- Migration: 2026-02-18 (extended 2026-02-19)
-- Purpose: Convert family-survey tables to use `phone_number` (BIGINT) as primary key
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
-- (best-effort list based on asked tables; DB may report additional constraint names)
ALTER TABLE IF EXISTS family_members     DROP CONSTRAINT IF EXISTS family_members_phone_number_fkey;
ALTER TABLE IF EXISTS bank_accounts      DROP CONSTRAINT IF EXISTS bank_accounts_phone_number_fkey;
ALTER TABLE IF EXISTS family_id          DROP CONSTRAINT IF EXISTS family_id_phone_number_fkey;
ALTER TABLE IF EXISTS aadhaar_info       DROP CONSTRAINT IF EXISTS aadhaar_info_phone_number_fkey;
ALTER TABLE IF EXISTS ayushman_card      DROP CONSTRAINT IF EXISTS ayushman_card_phone_number_fkey;
ALTER TABLE IF EXISTS samagra_id         DROP CONSTRAINT IF EXISTS samagra_id_phone_number_fkey;
ALTER TABLE IF EXISTS tribal_card        DROP CONSTRAINT IF EXISTS tribal_card_phone_number_fkey;
ALTER TABLE IF EXISTS merged_govt_schemes DROP CONSTRAINT IF EXISTS merged_govt_schemes_phone_number_fkey;
ALTER TABLE IF EXISTS pm_kisan_nidhi     DROP CONSTRAINT IF EXISTS pm_kisan_nidhi_phone_number_fkey;
ALTER TABLE IF EXISTS pm_kisan_samman_nidhi DROP CONSTRAINT IF EXISTS pm_kisan_samman_nidhi_phone_number_fkey;
ALTER TABLE IF EXISTS vb_gram            DROP CONSTRAINT IF EXISTS vb_gram_phone_number_fkey;
ALTER TABLE IF EXISTS pension_allowance  DROP CONSTRAINT IF EXISTS pension_allowance_phone_number_fkey;
ALTER TABLE IF EXISTS widow_allowance    DROP CONSTRAINT IF EXISTS widow_allowance_phone_number_fkey;
ALTER TABLE IF EXISTS family_id_scheme_members DROP CONSTRAINT IF EXISTS family_id_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS aadhaar_scheme_members DROP CONSTRAINT IF EXISTS aadhaar_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS ayushman_scheme_members DROP CONSTRAINT IF EXISTS ayushman_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS ration_scheme_members DROP CONSTRAINT IF EXISTS ration_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS samagra_scheme_members DROP CONSTRAINT IF EXISTS samagra_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS tribal_scheme_members DROP CONSTRAINT IF EXISTS tribal_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS handicapped_scheme_members DROP CONSTRAINT IF EXISTS handicapped_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS pension_scheme_members DROP CONSTRAINT IF EXISTS pension_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS widow_scheme_members DROP CONSTRAINT IF EXISTS widow_scheme_members_phone_number_fkey;
ALTER TABLE IF EXISTS vb_gram_members DROP CONSTRAINT IF EXISTS vb_gram_members_phone_number_fkey;
ALTER TABLE IF EXISTS pm_kisan_members DROP CONSTRAINT IF EXISTS pm_kisan_members_phone_number_fkey;
ALTER TABLE IF EXISTS pm_kisan_samman_members DROP CONSTRAINT IF EXISTS pm_kisan_samman_members_phone_number_fkey;
ALTER TABLE IF EXISTS shg_members DROP CONSTRAINT IF EXISTS shg_members_phone_number_fkey;
ALTER TABLE IF EXISTS fpo_members DROP CONSTRAINT IF EXISTS fpo_members_phone_number_fkey;
ALTER TABLE IF EXISTS children_data DROP CONSTRAINT IF EXISTS children_data_phone_number_fkey;
ALTER TABLE IF EXISTS malnourished_children_data DROP CONSTRAINT IF EXISTS malnourished_children_data_phone_number_fkey;
ALTER TABLE IF EXISTS child_diseases DROP CONSTRAINT IF EXISTS child_diseases_phone_number_fkey;
ALTER TABLE IF EXISTS migration_data DROP CONSTRAINT IF EXISTS migration_data_phone_number_fkey;
ALTER TABLE IF EXISTS training_data DROP CONSTRAINT IF EXISTS training_data_phone_number_fkey;
ALTER TABLE IF EXISTS folklore_medicine DROP CONSTRAINT IF EXISTS folklore_medicine_phone_number_fkey;
ALTER TABLE IF EXISTS health_programmes DROP CONSTRAINT IF EXISTS health_programmes_phone_number_fkey;
ALTER TABLE IF EXISTS tulsi_plants DROP CONSTRAINT IF EXISTS tulsi_plants_phone_number_fkey;
ALTER TABLE IF EXISTS nutritional_garden DROP CONSTRAINT IF EXISTS nutritional_garden_phone_number_fkey;
ALTER TABLE IF EXISTS malnutrition_data DROP CONSTRAINT IF EXISTS malnutrition_data_phone_number_fkey;

-- Destructive conversion path (user approved test-data discard):
-- Truncate affected tables, drop and re-create `phone_number` as BIGINT, drop `id` columns,
-- then add primary keys. This discards existing data in affected tables.
DO $$
DECLARE
  t text;
  tables_to_process text[] := ARRAY[
    'family_survey_sessions','family_members','bank_accounts','family_id','aadhaar_info','ayushman_card','samagra_id','tribal_card','merged_govt_schemes',
    'pm_kisan_nidhi','pm_kisan_samman_nidhi','vb_gram','pension_allowance','widow_allowance','land_holding','irrigation_facilities',
    'crop_productivity','fertilizer_usage','animals','agricultural_equipment','entertainment_facilities','transport_facilities',
    'drinking_water_sources','medical_treatment','disputes','house_conditions','house_facilities','diseases','social_consciousness',
    'children_data','malnourished_children_data','child_diseases','migration_data','training_data','shg_members','fpo_members',
    'folklore_medicine','health_programmes','tulsi_plants','nutritional_garden','malnutrition_data','aadhaar_scheme_members','ayushman_scheme_members',
    'family_id_scheme_members','ration_scheme_members','samagra_scheme_members','tribal_scheme_members','handicapped_scheme_members',
    'pension_scheme_members','widow_scheme_members','vb_gram_members','pm_kisan_members','pm_kisan_samman_members','tribal_questions'
  ];
BEGIN
  -- Truncate tables first to ensure adding PKs will succeed on empty tables
  FOREACH t IN ARRAY tables_to_process LOOP
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name=t) THEN
      EXECUTE format('TRUNCATE TABLE %I CASCADE', t);
    END IF;
  END LOOP;

  -- Drop phone_number column if present and add a fresh BIGINT phone_number column; drop legacy id
  FOREACH t IN ARRAY tables_to_process LOOP
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name=t) THEN
      IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name=t AND column_name='phone_number') THEN
        EXECUTE format('ALTER TABLE %I DROP COLUMN phone_number CASCADE', t);
      END IF;
      EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS phone_number bigint', t);
      EXECUTE format('ALTER TABLE %I DROP COLUMN IF EXISTS id', t);
    END IF;
  END LOOP;
END$$;

-- Temporarily disable RLS on affected tables to avoid policy violations during type changes
DO $$
DECLARE
  tbl text;
  tables_to_disable text[] := ARRAY[
    'family_survey_sessions','family_members','bank_accounts','family_id','aadhaar_info','ayushman_card','samagra_id','tribal_card','merged_govt_schemes','pm_kisan_nidhi','pm_kisan_samman_nidhi','vb_gram','pension_allowance','widow_allowance'
  ];
BEGIN
  FOREACH tbl IN ARRAY tables_to_disable LOOP
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name=tbl) THEN
      EXECUTE format('ALTER TABLE %I DISABLE ROW LEVEL SECURITY', tbl);
    END IF;
  END LOOP;
END$$;

-- DROP legacy id columns and add PRIMARY KEYs where applicable (family-only)
-- For member-style tables (with sr_no) drop id and add composite PK if sr_no exists
DO $$
DECLARE
  member_tables text[] := ARRAY[
    'family_members','family_id_scheme_members','samagra_scheme_members','tribal_scheme_members','handicapped_scheme_members',
    'vb_gram_members','pm_kisan_members','pm_kisan_samman_members','shg_members','fpo_members'
  ];
  t text;
BEGIN
  FOREACH t IN ARRAY member_tables LOOP
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name=t) THEN
      EXECUTE format('ALTER TABLE %I DROP COLUMN IF EXISTS id', t);
      IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name=t AND column_name='sr_no') THEN
        BEGIN
          EXECUTE format('ALTER TABLE %I DROP CONSTRAINT IF EXISTS %I_pkey', t, t);
          EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY (phone_number, sr_no)', t);
        EXCEPTION WHEN others THEN
          RAISE NOTICE 'Could not add composite primary key to %', t;
        END;
      END IF;
    END IF;
  END LOOP;
END$$;

-- Single-row family child tables: drop id and ensure unique/primary key by phone_number
DO $$
DECLARE
  single_row_tables text[] := ARRAY[
    'bank_accounts','ration_card','family_id','aadhaar_info','ayushman_card','samagra_id','tribal_card','merged_govt_schemes',
    'pm_kisan_nidhi','pm_kisan_samman_nidhi','pension_allowance','widow_allowance','vb_gram','folklore_medicine','health_programmes','tulsi_plants','nutritional_garden'
  ];
  t text;
BEGIN
  FOREACH t IN ARRAY single_row_tables LOOP
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name=t) THEN
      EXECUTE format('ALTER TABLE %I DROP COLUMN IF EXISTS id', t);
      IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name=t AND column_name='phone_number') THEN
        BEGIN
          EXECUTE format('ALTER TABLE %I DROP CONSTRAINT IF EXISTS %I_pkey', t, t);
          EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY (phone_number)', t);
        EXCEPTION WHEN others THEN
          RAISE NOTICE 'Could not add primary key to %', t;
        END;
      END IF;
    END IF;
  END LOOP;
END$$;
-- Recreate FK constraints to reference family_survey_sessions(phone_number) (BIGINT)

-- Ensure `family_survey_sessions` has a primary key on phone_number so FKs can reference it
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='family_survey_sessions') THEN
    BEGIN
      EXECUTE 'ALTER TABLE family_survey_sessions DROP CONSTRAINT IF EXISTS family_survey_sessions_pkey';
      EXECUTE 'ALTER TABLE family_survey_sessions ADD PRIMARY KEY (phone_number)';
    EXCEPTION WHEN others THEN
      RAISE NOTICE 'Could not set primary key on family_survey_sessions';
    END;
  END IF;
END$$;

-- Recreate FK constraints to reference family_survey_sessions(phone_number) (BIGINT)
-- (Add more if DB indicates different constraint names)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'family_members_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE family_members ADD CONSTRAINT family_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'bank_accounts_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE bank_accounts ADD CONSTRAINT bank_accounts_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'family_id_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE family_id ADD CONSTRAINT family_id_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'aadhaar_info_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE aadhaar_info ADD CONSTRAINT aadhaar_info_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ayushman_card_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE ayushman_card ADD CONSTRAINT ayushman_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'samagra_id_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE samagra_id ADD CONSTRAINT samagra_id_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'tribal_card_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE tribal_card ADD CONSTRAINT tribal_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'merged_govt_schemes_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE merged_govt_schemes ADD CONSTRAINT merged_govt_schemes_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'pm_kisan_nidhi_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE pm_kisan_nidhi ADD CONSTRAINT pm_kisan_nidhi_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'pm_kisan_samman_nidhi_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE pm_kisan_samman_nidhi ADD CONSTRAINT pm_kisan_samman_nidhi_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'vb_gram_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE vb_gram ADD CONSTRAINT vb_gram_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'pension_allowance_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE pension_allowance ADD CONSTRAINT pension_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'widow_allowance_phone_number_fkey') THEN
    EXECUTE 'ALTER TABLE widow_allowance ADD CONSTRAINT widow_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
END$$;

-- Recreate any previously dropped policies saved in tmp_policies
DO $$
DECLARE
  rec record;
  roles text;
BEGIN
  IF to_regclass('tmp_policies') IS NOT NULL THEN
    FOR rec IN SELECT * FROM tmp_policies LOOP
      roles := '';
      IF rec.polroles IS NOT NULL THEN
        SELECT string_agg(quote_ident(r.rolname), ', ') INTO roles FROM pg_roles r WHERE r.oid = ANY(rec.polroles);
      END IF;
      EXECUTE format('CREATE POLICY %I ON %I.%I FOR %s %s %s %s',
        rec.polname,
        rec.schemaname,
        rec.tablename,
        rec.polcmd,
        CASE WHEN rec.using_expr IS NOT NULL THEN 'USING (' || rec.using_expr || ')' ELSE '' END,
        CASE WHEN rec.with_check IS NOT NULL THEN 'WITH CHECK (' || rec.with_check || ')' ELSE '' END,
        CASE WHEN roles <> '' THEN 'TO ' || roles ELSE '' END
      );
    END LOOP;
  END IF;
END$$;

-- Re-enable RLS on tables we disabled earlier
DO $$
DECLARE
  tbl text;
  tables_to_enable text[] := ARRAY[
    'family_survey_sessions','family_members','bank_accounts','family_id','aadhaar_info','ayushman_card','samagra_id','tribal_card','merged_govt_schemes','pm_kisan_nidhi','pm_kisan_samman_nidhi','vb_gram','pension_allowance','widow_allowance'
  ];
BEGIN
  FOREACH tbl IN ARRAY tables_to_enable LOOP
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name=tbl) THEN
      EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', tbl);
    END IF;
  END LOOP;
END$$;

COMMIT;

-- POST-MIGRATION CHECKLIST (run on staging and verify):
-- 1) Confirm family_survey_sessions.phone_number is BIGINT and primary key.
-- 2) Confirm member lists use PRIMARY KEY (phone_number, sr_no) where applicable.
-- 3) Run application sync + smoke tests (create/update/delete) against staging DB.
-- 4) Update RLS policies, views, triggers and stored functions that referenced legacy `id`.
-- 5) Once validated, schedule production rollout: backup, apply migration, verify.

-- RUNNING THIS MIGRATION (example using psql):
-- To run this migration against the provided Supabase DB:
