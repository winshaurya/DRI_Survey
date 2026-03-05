-- Drop duplicate table
DROP TABLE IF EXISTS malnutrition_data;

-- Refactor fpo_members
ALTER TABLE fpo_members ADD COLUMN IF NOT EXISTS sr_no INTEGER;

WITH numbered_rows AS (
  SELECT phone_number, created_at, ROW_NUMBER() OVER (PARTITION BY phone_number ORDER BY created_at) as rn
  FROM fpo_members
)
UPDATE fpo_members
SET sr_no = numbered_rows.rn
FROM numbered_rows
WHERE fpo_members.phone_number = numbered_rows.phone_number AND fpo_members.created_at = numbered_rows.created_at;

-- Handle cases where sr_no might still be null (if any new rows inserted), though unlikely in single transaction block if run together
-- Set sr_no to 1 if it's null (fallback)
UPDATE fpo_members SET sr_no = 1 WHERE sr_no IS NULL;

ALTER TABLE fpo_members ALTER COLUMN sr_no SET NOT NULL;

ALTER TABLE fpo_members DROP CONSTRAINT IF EXISTS fpo_members_pkey;
ALTER TABLE fpo_members ADD CONSTRAINT fpo_members_pkey PRIMARY KEY (phone_number, sr_no);


-- Refactor malnourished_children_data
ALTER TABLE malnourished_children_data ADD COLUMN IF NOT EXISTS sr_no INTEGER;

WITH numbered_rows AS (
  SELECT phone_number, created_at, ROW_NUMBER() OVER (PARTITION BY phone_number ORDER BY created_at) as rn
  FROM malnourished_children_data
)
UPDATE malnourished_children_data
SET sr_no = numbered_rows.rn
FROM numbered_rows
WHERE malnourished_children_data.phone_number = numbered_rows.phone_number AND malnourished_children_data.created_at = numbered_rows.created_at;

UPDATE malnourished_children_data SET sr_no = 1 WHERE sr_no IS NULL;
ALTER TABLE malnourished_children_data ALTER COLUMN sr_no SET NOT NULL;

ALTER TABLE malnourished_children_data DROP CONSTRAINT IF EXISTS malnourished_children_data_pkey;
ALTER TABLE malnourished_children_data ADD CONSTRAINT malnourished_children_data_pkey PRIMARY KEY (phone_number, sr_no);


-- Refactor migration_data
ALTER TABLE migration_data ADD COLUMN IF NOT EXISTS sr_no INTEGER;

WITH numbered_rows AS (
  SELECT phone_number, created_at, ROW_NUMBER() OVER (PARTITION BY phone_number ORDER BY created_at) as rn
  FROM migration_data
)
UPDATE migration_data
SET sr_no = numbered_rows.rn
FROM numbered_rows
WHERE migration_data.phone_number = numbered_rows.phone_number AND migration_data.created_at = numbered_rows.created_at;

UPDATE migration_data SET sr_no = 1 WHERE sr_no IS NULL;
ALTER TABLE migration_data ALTER COLUMN sr_no SET NOT NULL;

ALTER TABLE migration_data DROP CONSTRAINT IF EXISTS migration_data_pkey;
ALTER TABLE migration_data ADD CONSTRAINT migration_data_pkey PRIMARY KEY (phone_number, sr_no);
