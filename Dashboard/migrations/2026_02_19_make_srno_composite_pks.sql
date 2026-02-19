o- Make composite PKs (phone_number, sr_no) for all tables that have sr_no
-- Date: 2026-02-19
-- WARNING: This migration may delete NULL or duplicate rows to enforce uniqueness/NOT NULL.

BEGIN;

DO $$
DECLARE
  r RECORD;
  tbl text;
BEGIN
  FOR r IN SELECT DISTINCT table_name FROM information_schema.columns WHERE table_schema='public' AND column_name='sr_no' LOOP
    tbl := r.table_name;
    RAISE NOTICE 'Processing %', tbl;
    BEGIN
      -- remove rows with null phone_number or sr_no
      EXECUTE format('DELETE FROM %I WHERE phone_number IS NULL OR sr_no IS NULL', tbl);
      -- remove duplicates, keep first
      EXECUTE format('DELETE FROM %I WHERE ctid NOT IN (SELECT min(ctid) FROM %I GROUP BY phone_number, sr_no)', tbl, tbl);
      -- set NOT NULL on both columns
      EXECUTE format('ALTER TABLE %I ALTER COLUMN phone_number SET NOT NULL', tbl);
      EXECUTE format('ALTER TABLE %I ALTER COLUMN sr_no SET NOT NULL', tbl);
      -- drop existing primary key if any
      EXECUTE format(
        'ALTER TABLE %I DROP CONSTRAINT IF EXISTS %I_pkey', tbl, tbl
      );
      -- add composite primary key
      IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = tbl::regclass AND contype = 'p') THEN
        EXECUTE format('ALTER TABLE %I ADD PRIMARY KEY (phone_number, sr_no)', tbl);
      END IF;
    EXCEPTION WHEN others THEN
      RAISE NOTICE 'Skipped % due to error: %', tbl, SQLERRM;
    END;
  END LOOP;
END$$;

COMMIT;

-- End migration
