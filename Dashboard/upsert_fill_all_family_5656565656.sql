-- Upsert (delete + insert) dummy data for EVERY table that references family_survey_sessions(phone_number)
-- Phone number used: 5656565656
-- This script deletes any existing family_survey_sessions row for that phone_number (cascades) and inserts
-- one fully-populated row per table (fills every column with valid dummy values).
-- Run with psql against your Supabase DB connection.

BEGIN;

-- delete existing (will cascade to child tables)
DELETE FROM family_survey_sessions WHERE phone_number = '5656565656';

-- insert main session (fill all survey fields)
INSERT INTO family_survey_sessions (
  phone_number, surveyor_email, created_at, updated_at, village_name, village_number, panchayat, block, tehsil, district, postal_address, pin_code, shine_code,
  latitude, longitude, location_accuracy, location_timestamp, survey_date, surveyor_name, status, device_info, app_version, created_by, updated_by, is_deleted, last_synced_at, current_version, last_edited_at
) VALUES (
  '5656565656', 'copilot+test@example.com', now()::text, now()::text, 'DummyVillage', '999', 'DummyPanchayat', 'DummyBlock', 'DummyTehsil', 'DummyDistrict', '123 Dummy St', '111111', 'SHN000',
  25.12345678, 82.12345678, 3.14, now()::text, current_date::text, 'Copilot Test', 'completed', 'android-emulator', '1.2.3', gen_random_uuid()::text, gen_random_uuid()::text, 0, now()::text, 1, now()::text
);

-- For every other table that contains phone_number, insert one row with sensible dummy values
DO $$
DECLARE
  v_phone TEXT := '5656565656';
  t RECORD;
  c RECORD;
  col_list TEXT;
  val_list TEXT;
  insert_sql TEXT;
BEGIN
  FOR t IN
    SELECT DISTINCT table_name
    FROM information_schema.columns
    WHERE column_name = 'phone_number' AND table_schema = 'public' AND table_name <> 'family_survey_sessions'
    ORDER BY table_name
  LOOP
    col_list := '';
    val_list := '';

    FOR c IN
      SELECT column_name, data_type, udt_name
      FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = t.table_name
      ORDER BY ordinal_position
    LOOP
      -- build column list and per-column dummy value
      IF col_list <> '' THEN
        col_list := col_list || ', ';
        val_list := val_list || ', ';
      END IF;

      col_list := col_list || format('%I', c.column_name);

      -- normalized type names
      IF c.column_name = 'phone_number' THEN
        val_list := val_list || quote_literal(v_phone);

      ELSIF lower(c.udt_name) = 'uuid' THEN
        -- prefer a UUID function for uuid columns
        val_list := val_list || 'gen_random_uuid()';

      ELSIF lower(c.data_type) IN ('character varying','text','character') THEN
        IF lower(c.column_name) = 'sex' THEN
          val_list := val_list || quote_literal('female');
        ELSIF lower(c.column_name) = 'status' THEN
          val_list := val_list || quote_literal('completed');
        ELSIF lower(c.column_name) LIKE '%email%' THEN
          val_list := val_list || quote_literal('copilot+dummy@example.com');
        ELSIF lower(c.column_name) LIKE '%date%' OR lower(c.column_name) LIKE '%timestamp%' OR lower(c.column_name) LIKE '%created%' OR lower(c.column_name) LIKE '%updated%' THEN
          -- keep textual timestamp/date fields human-readable
          val_list := val_list || quote_literal(now()::text);
        ELSE
          val_list := val_list || quote_literal('dummy_' || c.column_name);
        END IF;

      ELSIF lower(c.data_type) = 'boolean' OR lower(c.udt_name) = 'bool' THEN
        val_list := val_list || 'false';

      ELSIF lower(c.data_type) IN ('integer','smallint','bigint') THEN
        IF lower(c.column_name) = 'sr_no' THEN
          val_list := val_list || '1';
        ELSIF lower(c.column_name) LIKE '%count' OR lower(c.column_name) LIKE '%total%' THEN
          val_list := val_list || '1';
        ELSIF lower(c.column_name) = 'is_deleted' THEN
          val_list := val_list || '0';
        ELSE
          val_list := val_list || '1';
        END IF;

      ELSIF lower(c.data_type) IN ('numeric','decimal','real','double precision') THEN
        val_list := val_list || '1.0';

      ELSIF lower(c.data_type) IN ('json','jsonb') OR lower(c.udt_name) IN ('json','jsonb') THEN
        val_list := val_list || quote_literal('{}') || '::' || c.data_type;

      ELSE
        -- unknown / complex type: insert NULL so we don't cause type errors
        val_list := val_list || 'NULL';
      END IF;
    END LOOP;

    insert_sql := format('INSERT INTO %I (%s) VALUES (%s);', t.table_name, col_list, val_list);
    RAISE NOTICE 'Running: %', insert_sql;
    EXECUTE insert_sql;
  END LOOP;
END$$;

COMMIT;

-- Run the completeness check (core template) for the same phone number to validate
-- (use the small template; for full schema completeness use Dashboard/family_survey_completeness_all_tables.sql)

-- NOTE: run the expanded completeness after this script to verify 100% across all tables:
--   \i Dashboard/family_survey_completeness_all_tables.sql

-- Quick check: run the existing template for the most-used tables
\echo 'Run the comprehensive completeness query separately:'
\echo '\i Dashboard/family_survey_completeness_all_tables.sql'
