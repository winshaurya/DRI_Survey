-- Migration: Fix land_holding and bank_accounts constraints
-- Date: 2026-02-19
-- Behaviour: convert types to BIGINT (safe USING), delete NULL/duplicate rows,
-- make columns NOT NULL and add PRIMARY KEY constraints if missing.

BEGIN;

-- LAND_HOLDING: ensure phone_number is BIGINT, not null and primary key
ALTER TABLE IF EXISTS land_holding ALTER COLUMN phone_number TYPE BIGINT USING phone_number::bigint;
-- remove rows with NULL phone_number (destructive)
DELETE FROM land_holding WHERE phone_number IS NULL;
-- remove duplicate phone_number rows, keep first physical row
DELETE FROM land_holding WHERE ctid NOT IN (
  SELECT min(ctid) FROM land_holding GROUP BY phone_number
);
ALTER TABLE IF EXISTS land_holding ALTER COLUMN phone_number SET NOT NULL;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'land_holding'::regclass AND contype = 'p'
  ) THEN
    EXECUTE 'ALTER TABLE land_holding ADD PRIMARY KEY (phone_number)';
  END IF;
END$$;

-- BANK_ACCOUNTS: ensure phone_number is BIGINT, sr_no NOT NULL, and composite PK
ALTER TABLE IF EXISTS bank_accounts ALTER COLUMN phone_number TYPE BIGINT USING phone_number::bigint;
-- remove rows with NULL phone_number or sr_no (destructive)
DELETE FROM bank_accounts WHERE phone_number IS NULL OR sr_no IS NULL;
-- remove duplicate (phone_number, sr_no) rows
DELETE FROM bank_accounts WHERE ctid NOT IN (
  SELECT min(ctid) FROM bank_accounts GROUP BY phone_number, sr_no
);
ALTER TABLE IF EXISTS bank_accounts ALTER COLUMN phone_number SET NOT NULL;
ALTER TABLE IF EXISTS bank_accounts ALTER COLUMN sr_no SET NOT NULL;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'bank_accounts'::regclass AND contype = 'p'
  ) THEN
    EXECUTE 'ALTER TABLE bank_accounts ADD PRIMARY KEY (phone_number, sr_no)';
  END IF;
END$$;

COMMIT;

-- End migration
