-- Migration: Fix phone_number types, add PKs where appropriate, and enable RLS
-- Date: 2026-02-19
-- WARNING: This migration may delete NULL or duplicate rows to enforce uniqueness/NOT NULL.

BEGIN;

-- 1) Convert text phone_number columns to BIGINT where necessary
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT table_name FROM information_schema.columns WHERE column_name='phone_number' AND table_schema='public' AND data_type <> 'bigint' LOOP
    EXECUTE format('ALTER TABLE %I ALTER COLUMN phone_number TYPE BIGINT USING phone_number::bigint', r.table_name);
  END LOOP;
END$$;

-- 2) Ensure specific tables have NOT NULL and PRIMARY KEY constraints
-- List: fertilizer_usage, medical_treatment, shg_members: make phone_number NOT NULL and PRIMARY KEY (delete nulls/dupes)
DO $$
DECLARE t text;
BEGIN
  FOR t IN SELECT unnest(ARRAY['fertilizer_usage','medical_treatment','shg_members']) LOOP
    -- remove rows with NULL phone_number
    EXECUTE format('DELETE FROM %I WHERE phone_number IS NULL', t);
    -- remove duplicate phone_number rows (keep first)
    EXECUTE format('DELETE FROM %I WHERE ctid NOT IN (SELECT min(ctid) FROM %I GROUP BY phone_number)', t, t);
    -- set NOT NULL
    EXECUTE format('ALTER TABLE %I ALTER COLUMN phone_number SET NOT NULL', t);
    -- add PK if missing
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = t::regclass AND contype = 'p') THEN
      EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY (phone_number)', t);
    END IF;
  END LOOP;
END$$;

-- 3) Fix handicapped_allowance and ration_card phone_number types/constraints
-- Convert typed above; ensure they reference family_survey_sessions and set NOT NULL
DO $$
BEGIN
  -- handicapped_allowance: phone_number already NOT NULL text -> now bigint; ensure FK exists
  PERFORM 1;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='handicapped_allowance'::regclass AND contype='f') THEN
    BEGIN
      EXECUTE 'ALTER TABLE handicapped_allowance ADD CONSTRAINT handicapped_allowance_phone_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
    EXCEPTION WHEN duplicate_object THEN NULL; END;
  END IF;

  -- ration_card: convert done above; ensure FK
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='ration_card'::regclass AND contype='f') THEN
    BEGIN
      EXECUTE 'ALTER TABLE ration_card ADD CONSTRAINT ration_card_phone_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
    EXCEPTION WHEN duplicate_object THEN NULL; END;
  END IF;
END$$;

-- 4) Create/enable RLS policies for every table that has a phone_number column
DO $$
DECLARE
  r RECORD;
  policy_name text := 'Users access own data';
BEGIN
  FOR r IN SELECT DISTINCT table_name FROM information_schema.columns WHERE column_name='phone_number' AND table_schema='public' LOOP
    -- enable RLS
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', r.table_name);
    -- drop existing policy with same name (if any)
    EXECUTE format('DROP POLICY IF EXISTS "%s" ON %I', policy_name, r.table_name);
    -- create policy: allow access only when matching family_survey_sessions.surveyor_email
    EXECUTE format($fmt$
      CREATE POLICY "%s" ON %I
        FOR ALL USING (
          EXISTS (SELECT 1 FROM family_survey_sessions f WHERE f.phone_number = %I.phone_number AND f.surveyor_email = auth.jwt() ->> 'email')
        );
    $fmt$, policy_name, r.table_name, r.table_name);
  END LOOP;
END$$;

COMMIT;

-- End migration
