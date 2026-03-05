-- Fix Family Survey Tables (1:1) - Add missing Primary Keys
-- For tables that are 1:1, we use phone_number as the Primary Key.

-- 1. agricultural_equipment
ALTER TABLE agricultural_equipment ALTER COLUMN phone_number SET NOT NULL;
ALTER TABLE agricultural_equipment ADD CONSTRAINT agricultural_equipment_pkey PRIMARY KEY (phone_number);

-- 2. children_data
ALTER TABLE children_data ALTER COLUMN phone_number SET NOT NULL;
ALTER TABLE children_data ADD CONSTRAINT children_data_pkey PRIMARY KEY (phone_number);

-- 3. disputes
ALTER TABLE disputes ALTER COLUMN phone_number SET NOT NULL;
ALTER TABLE disputes ADD CONSTRAINT disputes_pkey PRIMARY KEY (phone_number);

-- 4. drinking_water_sources
ALTER TABLE drinking_water_sources ALTER COLUMN phone_number SET NOT NULL;
ALTER TABLE drinking_water_sources ADD CONSTRAINT drinking_water_sources_pkey PRIMARY KEY (phone_number);

-- 5. entertainment_facilities
ALTER TABLE entertainment_facilities ALTER COLUMN phone_number SET NOT NULL;
ALTER TABLE entertainment_facilities ADD CONSTRAINT entertainment_facilities_pkey PRIMARY KEY (phone_number);

-- 6. house_conditions
ALTER TABLE house_conditions ALTER COLUMN phone_number SET NOT NULL;
ALTER TABLE house_conditions ADD CONSTRAINT house_conditions_pkey PRIMARY KEY (phone_number);

-- 7. house_facilities
ALTER TABLE house_facilities ALTER COLUMN phone_number SET NOT NULL;
ALTER TABLE house_facilities ADD CONSTRAINT house_facilities_pkey PRIMARY KEY (phone_number);

-- 8. irrigation_facilities
ALTER TABLE irrigation_facilities ALTER COLUMN phone_number SET NOT NULL;
ALTER TABLE irrigation_facilities ADD CONSTRAINT irrigation_facilities_pkey PRIMARY KEY (phone_number);

-- 9. transport_facilities
ALTER TABLE transport_facilities ALTER COLUMN phone_number SET NOT NULL;
ALTER TABLE transport_facilities ADD CONSTRAINT transport_facilities_pkey PRIMARY KEY (phone_number);

-- 10. tribal_questions
ALTER TABLE tribal_questions ALTER COLUMN phone_number SET NOT NULL;
ALTER TABLE tribal_questions ADD CONSTRAINT tribal_questions_pkey PRIMARY KEY (phone_number);


-- Fix Village Survey Tables (1:Many) - Fix Incorrect Primary Keys
-- These tables currently have PK(session_id) but contain multiple rows per session identified by sr_no.
-- We must switch to PK(session_id, sr_no).

-- 1. village_animals
ALTER TABLE village_animals DROP CONSTRAINT IF EXISTS village_animals_pkey;
ALTER TABLE village_animals ADD CONSTRAINT village_animals_pkey PRIMARY KEY (session_id, sr_no);

-- 2. village_crop_productivity
ALTER TABLE village_crop_productivity DROP CONSTRAINT IF EXISTS village_crop_productivity_pkey;
ALTER TABLE village_crop_productivity ADD CONSTRAINT village_crop_productivity_pkey PRIMARY KEY (session_id, sr_no);

-- 3. village_malnutrition_data
-- Handle nullable sr_no
WITH numbered_rows AS (
  SELECT session_id, created_at, ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY created_at) as rn
  FROM village_malnutrition_data
)
UPDATE village_malnutrition_data
SET sr_no = numbered_rows.rn
FROM numbered_rows
WHERE village_malnutrition_data.session_id = numbered_rows.session_id 
  AND village_malnutrition_data.created_at = numbered_rows.created_at 
  AND village_malnutrition_data.sr_no IS NULL;

UPDATE village_malnutrition_data SET sr_no = 1 WHERE sr_no IS NULL;
ALTER TABLE village_malnutrition_data ALTER COLUMN sr_no SET NOT NULL;

ALTER TABLE village_malnutrition_data DROP CONSTRAINT IF EXISTS village_malnutrition_data_pkey;
ALTER TABLE village_malnutrition_data ADD CONSTRAINT village_malnutrition_data_pkey PRIMARY KEY (session_id, sr_no);

-- 4. village_traditional_occupations
-- Handle nullable sr_no
WITH numbered_rows AS (
  SELECT session_id, created_at, ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY created_at) as rn
  FROM village_traditional_occupations
)
UPDATE village_traditional_occupations
SET sr_no = numbered_rows.rn
FROM numbered_rows
WHERE village_traditional_occupations.session_id = numbered_rows.session_id 
  AND village_traditional_occupations.created_at = numbered_rows.created_at 
  AND village_traditional_occupations.sr_no IS NULL;

UPDATE village_traditional_occupations SET sr_no = 1 WHERE sr_no IS NULL;
ALTER TABLE village_traditional_occupations ALTER COLUMN sr_no SET NOT NULL;

ALTER TABLE village_traditional_occupations DROP CONSTRAINT IF EXISTS village_traditional_occupations_pkey;
ALTER TABLE village_traditional_occupations ADD CONSTRAINT village_traditional_occupations_pkey PRIMARY KEY (session_id, sr_no);
