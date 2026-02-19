-- Migration: convert handicapped_allowance to use phone_number as PRIMARY KEY
-- Date: 2026-02-19
-- WARNING: destructive: removes NULL/duplicate rows and drops `id` column


BEGIN;

-- Temporarily remove RLS policy so we can change column type
ALTER TABLE IF EXISTS handicapped_allowance DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON handicapped_allowance;

-- ensure phone_number is bigint
ALTER TABLE IF EXISTS handicapped_allowance ALTER COLUMN phone_number TYPE BIGINT USING phone_number::bigint;

-- remove rows without phone_number
DELETE FROM handicapped_allowance WHERE phone_number IS NULL;

-- remove duplicate phone_number rows (keep first)
DELETE FROM handicapped_allowance WHERE ctid NOT IN (SELECT min(ctid) FROM handicapped_allowance GROUP BY phone_number);

-- ensure not null
ALTER TABLE IF EXISTS handicapped_allowance ALTER COLUMN phone_number SET NOT NULL;

-- drop existing primary key constraint (if any)
DO $$
DECLARE
  pkname text;
BEGIN
  SELECT conname INTO pkname FROM pg_constraint WHERE conrelid='handicapped_allowance'::regclass AND contype='p' LIMIT 1;
  IF pkname IS NOT NULL THEN
    EXECUTE format('ALTER TABLE handicapped_allowance DROP CONSTRAINT %I', pkname);
  END IF;
END$$;

-- drop id column (cascade) if exists
ALTER TABLE IF EXISTS handicapped_allowance DROP COLUMN IF EXISTS id CASCADE;

-- add primary key on phone_number
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='handicapped_allowance'::regclass AND contype='p') THEN
    EXECUTE 'ALTER TABLE handicapped_allowance ADD PRIMARY KEY (phone_number)';
  END IF;
END$$;

-- ensure FK to family_survey_sessions exists
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='handicapped_allowance'::regclass AND contype='f') THEN
    EXECUTE 'ALTER TABLE handicapped_allowance ADD CONSTRAINT handicapped_allowance_phone_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE';
  END IF;
END$$;

-- Recreate RLS policy and re-enable
ALTER TABLE IF EXISTS handicapped_allowance ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users access own data" ON handicapped_allowance
  FOR ALL USING (
    EXISTS (SELECT 1 FROM family_survey_sessions f WHERE f.phone_number = handicapped_allowance.phone_number AND f.surveyor_email = auth.jwt() ->> 'email')
  );

COMMIT;
