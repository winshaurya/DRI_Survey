-- Final remediation: add missing PKs, convert multi-row tables to composite PKs, clean up old id
-- Date: 2026-02-19
-- WARNING: destructive operations (delete NULL/duplicate rows)

BEGIN;

-- 1) Fix malnutrition_data: make phone_number NOT NULL and primary key
DO $$
BEGIN
  -- remove nulls and duplicates
  EXECUTE 'DELETE FROM malnutrition_data WHERE phone_number IS NULL';
  EXECUTE 'DELETE FROM malnutrition_data WHERE ctid NOT IN (SELECT min(ctid) FROM malnutrition_data GROUP BY phone_number)';
  -- set NOT NULL
  BEGIN
    EXECUTE 'ALTER TABLE malnutrition_data ALTER COLUMN phone_number SET NOT NULL';
  EXCEPTION WHEN others THEN RAISE NOTICE 'Could not set NOT NULL on malnutrition_data.phone_number: %', SQLERRM; END;
  -- add PK if missing
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='malnutrition_data'::regclass AND contype='p') THEN
    EXECUTE 'ALTER TABLE malnutrition_data ADD PRIMARY KEY (phone_number)';
  END IF;
END$$;

-- 2) Multi-row tables: add composite PK (phone_number, created_at)
DO $$
DECLARE
  t text;
  tables text[] := ARRAY['malnourished_children_data','fpo_members','training_data','migration_data','child_diseases'];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    BEGIN
      -- remove null phone or created_at
      EXECUTE format('DELETE FROM %I WHERE phone_number IS NULL OR created_at IS NULL', t);
      -- remove duplicates keeping first
      EXECUTE format('DELETE FROM %I WHERE ctid NOT IN (SELECT min(ctid) FROM %I GROUP BY phone_number, created_at)', t, t);
      -- set NOT NULL
      EXECUTE format('ALTER TABLE %I ALTER COLUMN phone_number SET NOT NULL', t);
      EXECUTE format('ALTER TABLE %I ALTER COLUMN created_at SET NOT NULL', t);
      -- add PK if missing
      IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = t::regclass AND contype = 'p') THEN
        EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY (phone_number, created_at)', t);
      END IF;
    EXCEPTION WHEN others THEN
      RAISE NOTICE 'Skipped % due to error: %', t, SQLERRM;
    END;
  END LOOP;
END$$;

-- 3) Repair shg_members: composite PK (phone_number, member_name)
DO $$
BEGIN
  -- remove rows with nulls
  EXECUTE 'DELETE FROM shg_members WHERE phone_number IS NULL OR member_name IS NULL';
  -- remove duplicates
  EXECUTE 'DELETE FROM shg_members WHERE ctid NOT IN (SELECT min(ctid) FROM shg_members GROUP BY phone_number, member_name)';
  -- set not null
  BEGIN EXECUTE 'ALTER TABLE shg_members ALTER COLUMN member_name SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'member_name not made NOT NULL: %', SQLERRM; END;
  BEGIN EXECUTE 'ALTER TABLE shg_members ALTER COLUMN phone_number SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'phone_number not made NOT NULL on shg_members: %', SQLERRM; END;
  -- replace PK
  BEGIN
    EXECUTE 'ALTER TABLE shg_members DROP CONSTRAINT IF EXISTS shg_members_pkey';
  EXCEPTION WHEN others THEN NULL; END;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='shg_members'::regclass AND contype='p') THEN
    EXECUTE 'ALTER TABLE shg_members ADD PRIMARY KEY (phone_number, member_name)';
  END IF;
END$$;

-- 4) Cleanup old column on handicapped_allowance
ALTER TABLE IF EXISTS handicapped_allowance DROP COLUMN IF EXISTS id CASCADE;

COMMIT;

-- End remediation
