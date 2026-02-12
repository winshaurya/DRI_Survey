-- Summarize table existence and per-column filled counts for family survey phone 3233232332

-- 1) Table existence summary
WITH table_existence AS (
  SELECT 'family_survey_sessions' as table_name, CASE WHEN EXISTS(SELECT 1 FROM family_survey_sessions WHERE phone_number = '3233232332') THEN 1 ELSE 0 END as has_data
  UNION ALL SELECT 'family_members', CASE WHEN EXISTS(SELECT 1 FROM family_members WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'land_holding', CASE WHEN EXISTS(SELECT 1 FROM land_holding WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'irrigation_facilities', CASE WHEN EXISTS(SELECT 1 FROM irrigation_facilities WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'crop_productivity', CASE WHEN EXISTS(SELECT 1 FROM crop_productivity WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'fertilizer_usage', CASE WHEN EXISTS(SELECT 1 FROM fertilizer_usage WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'animals', CASE WHEN EXISTS(SELECT 1 FROM animals WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'agricultural_equipment', CASE WHEN EXISTS(SELECT 1 FROM agricultural_equipment WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'entertainment_facilities', CASE WHEN EXISTS(SELECT 1 FROM entertainment_facilities WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'transport_facilities', CASE WHEN EXISTS(SELECT 1 FROM transport_facilities WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'drinking_water_sources', CASE WHEN EXISTS(SELECT 1 FROM drinking_water_sources WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'medical_treatment', CASE WHEN EXISTS(SELECT 1 FROM medical_treatment WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'disputes', CASE WHEN EXISTS(SELECT 1 FROM disputes WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'house_conditions', CASE WHEN EXISTS(SELECT 1 FROM house_conditions WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'house_facilities', CASE WHEN EXISTS(SELECT 1 FROM house_facilities WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'social_consciousness', CASE WHEN EXISTS(SELECT 1 FROM social_consciousness WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'children_data', CASE WHEN EXISTS(SELECT 1 FROM children_data WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'migration_data', CASE WHEN EXISTS(SELECT 1 FROM migration_data WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'health_programmes', CASE WHEN EXISTS(SELECT 1 FROM health_programmes WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'aadhaar_info', CASE WHEN EXISTS(SELECT 1 FROM aadhaar_info WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'pm_kisan_nidhi', CASE WHEN EXISTS(SELECT 1 FROM pm_kisan_nidhi WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'village_bank_accounts', CASE WHEN EXISTS(SELECT 1 FROM bank_accounts WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'seed_clubs', CASE WHEN EXISTS(SELECT 1 FROM seed_clubs WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'nutritional_garden', CASE WHEN EXISTS(SELECT 1 FROM nutritional_garden WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'malnourished_children_data', CASE WHEN EXISTS(SELECT 1 FROM malnourished_children_data WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
  UNION ALL SELECT 'folklore_medicine', CASE WHEN EXISTS(SELECT 1 FROM folklore_medicine WHERE phone_number = '3233232332') THEN 1 ELSE 0 END
)

SELECT 'FAMILY TABLE EXISTENCE SUMMARY' as analysis_type, COUNT(*) as total_tables, SUM(has_data) as tables_with_data, COUNT(*) - SUM(has_data) as tables_empty, ROUND((SUM(has_data)::decimal / COUNT(*)::decimal) * 100,2) as completeness_percentage FROM table_existence;


-- 2) Per-table column completeness (checks whether any row for the phone has a non-null/non-empty value in each column)

-- FAMILY SURVEY SESSIONS
SELECT
  'family_survey_sessions' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN phone_number IS NOT NULL AND trim(phone_number) <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN surveyor_email IS NOT NULL AND trim(surveyor_email) <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN village_name IS NOT NULL AND trim(village_name) <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN village_number IS NOT NULL AND trim(village_number) <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN panchayat IS NOT NULL AND trim(panchayat) <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN block IS NOT NULL AND trim(block) <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN tehsil IS NOT NULL AND trim(tehsil) <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN district IS NOT NULL AND trim(district) <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN postal_address IS NOT NULL AND trim(postal_address) <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN pin_code IS NOT NULL AND trim(pin_code) <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN shine_code IS NOT NULL AND trim(shine_code) <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN status IS NOT NULL AND trim(status) <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  12 as total_columns
FROM family_survey_sessions
WHERE phone_number = '3233232332'

UNION ALL

-- FAMILY MEMBERS (checking core fields)
SELECT 'family_members' as table_name, COUNT(*) as total_rows,
(
  COALESCE(MAX(CASE WHEN sr_no IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN name IS NOT NULL AND trim(name) <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN fathers_name IS NOT NULL AND trim(fathers_name) <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN mothers_name IS NOT NULL AND trim(mothers_name) <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN relationship_with_head IS NOT NULL AND trim(relationship_with_head) <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN age IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN sex IS NOT NULL AND trim(sex) <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN physically_fit IS NOT NULL AND trim(physically_fit) <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN insured IS NOT NULL AND trim(insured) <> '' THEN 1 ELSE 0 END),0)
) as filled_columns, 9 as total_columns
FROM family_members
WHERE phone_number = '3233232332'

UNION ALL

-- ANIMALS
SELECT 'animals' as table_name, COUNT(*) as total_rows,
(
  COALESCE(MAX(CASE WHEN sr_no IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN animal_type IS NOT NULL AND trim(animal_type) <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN number_of_animals IS NOT NULL THEN 1 ELSE 0 END),0)
) as filled_columns, 3 as total_columns
FROM animals
WHERE phone_number = '3233232332'

UNION ALL

-- EDUCATION / NUTRITION related tables (examples)
SELECT 'children_data' as table_name, COUNT(*) as total_rows,
(
  COALESCE(MAX(CASE WHEN births_last_3_years IS NOT NULL THEN 1 ELSE 0 END),0)
) as filled_columns, 1 as total_columns
FROM children_data
WHERE phone_number = '3233232332'

UNION ALL

SELECT 'nutritional_garden' as table_name, COUNT(*) as total_rows,
(
  COALESCE(MAX(CASE WHEN has_garden IS NOT NULL THEN 1 ELSE 0 END),0)
) as filled_columns, 1 as total_columns
FROM nutritional_garden
WHERE phone_number = '3233232332'

UNION ALL

SELECT 'bank_accounts' as table_name, COUNT(*) as total_rows,
(
  COALESCE(MAX(CASE WHEN account_number IS NOT NULL AND trim(account_number) <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN bank_name IS NOT NULL AND trim(bank_name) <> '' THEN 1 ELSE 0 END),0)
) as filled_columns, 2 as total_columns
FROM bank_accounts
WHERE phone_number = '3233232332'

UNION ALL

SELECT 'aadhaar_info' as table_name, COUNT(*) as total_rows,
(
  COALESCE(MAX(CASE WHEN has_aadhaar IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN total_members IS NOT NULL THEN 1 ELSE 0 END),0)
) as filled_columns, 2 as total_columns
FROM aadhaar_info
WHERE phone_number = '3233232332'

UNION ALL

SELECT 'pm_kisan_nidhi' as table_name, COUNT(*) as total_rows,
(
  COALESCE(MAX(CASE WHEN is_beneficiary IS NOT NULL THEN 1 ELSE 0 END),0)
) as filled_columns, 1 as total_columns
FROM pm_kisan_nidhi
WHERE phone_number = '3233232332'

UNION ALL

SELECT 'folklore_medicine' as table_name, COUNT(*) as total_rows,
(
  COALESCE(MAX(CASE WHEN person_name IS NOT NULL AND trim(person_name) <> '' THEN 1 ELSE 0 END),0)
) as filled_columns, 1 as total_columns
FROM folklore_medicine
WHERE phone_number = '3233232332'

ORDER BY table_name;

-- Final totals

SELECT SUM(filled_columns) as total_filled_columns, SUM(total_columns) as total_columns, COUNT(*) as tables_checked, COUNT(*) FILTER (WHERE filled_columns>0) as tables_with_any_data
FROM (
  -- reuse the per-table query above
  SELECT * FROM (
    -- the per-table query is repeated here
    SELECT 'family_survey_sessions' as table_name,
      (
        COALESCE(MAX(CASE WHEN phone_number IS NOT NULL AND trim(phone_number) <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN surveyor_email IS NOT NULL AND trim(surveyor_email) <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN village_name IS NOT NULL AND trim(village_name) <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN village_number IS NOT NULL AND trim(village_number) <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN panchayat IS NOT NULL AND trim(panchayat) <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN block IS NOT NULL AND trim(block) <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN tehsil IS NOT NULL AND trim(tehsil) <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN district IS NOT NULL AND trim(district) <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN postal_address IS NOT NULL AND trim(postal_address) <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN pin_code IS NOT NULL AND trim(pin_code) <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN shine_code IS NOT NULL AND trim(shine_code) <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN status IS NOT NULL AND trim(status) <> '' THEN 1 ELSE 0 END),0)
      ) as filled_columns, 12 as total_columns
    FROM family_survey_sessions
    WHERE phone_number = '3233232332'

    UNION ALL

    SELECT 'family_members', (
      COALESCE(MAX(CASE WHEN sr_no IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN name IS NOT NULL AND trim(name) <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN fathers_name IS NOT NULL AND trim(fathers_name) <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN mothers_name IS NOT NULL AND trim(mothers_name) <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN relationship_with_head IS NOT NULL AND trim(relationship_with_head) <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN age IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN sex IS NOT NULL AND trim(sex) <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN physically_fit IS NOT NULL AND trim(physically_fit) <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN insured IS NOT NULL AND trim(insured) <> '' THEN 1 ELSE 0 END),0)
    ), 9 FROM family_members WHERE phone_number = '3233232332'

    UNION ALL

    SELECT 'animals', (
      COALESCE(MAX(CASE WHEN sr_no IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN animal_type IS NOT NULL AND trim(animal_type) <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN number_of_animals IS NOT NULL THEN 1 ELSE 0 END),0)
    ),3 FROM animals WHERE phone_number = '3233232332'

    UNION ALL

    SELECT 'children_data', (
      COALESCE(MAX(CASE WHEN births_last_3_years IS NOT NULL THEN 1 ELSE 0 END),0)
    ),1 FROM children_data WHERE phone_number = '3233232332'

    UNION ALL

    SELECT 'nutritional_garden', (
      COALESCE(MAX(CASE WHEN has_garden IS NOT NULL THEN 1 ELSE 0 END),0)
    ),1 FROM nutritional_garden WHERE phone_number = '3233232332'

    UNION ALL

    SELECT 'bank_accounts', (
      COALESCE(MAX(CASE WHEN account_number IS NOT NULL AND trim(account_number) <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN bank_name IS NOT NULL AND trim(bank_name) <> '' THEN 1 ELSE 0 END),0)
    ),2 FROM bank_accounts WHERE phone_number = '3233232332'

    UNION ALL

    SELECT 'aadhaar_info', (
      COALESCE(MAX(CASE WHEN has_aadhaar IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN total_members IS NOT NULL THEN 1 ELSE 0 END),0)
    ),2 FROM aadhaar_info WHERE phone_number = '3233232332'

    UNION ALL

    SELECT 'pm_kisan_nidhi', (
      COALESCE(MAX(CASE WHEN is_beneficiary IS NOT NULL THEN 1 ELSE 0 END),0)
    ),1 FROM pm_kisan_nidhi WHERE phone_number = '3233232332'

    UNION ALL

    SELECT 'folklore_medicine', (
      COALESCE(MAX(CASE WHEN person_name IS NOT NULL AND trim(person_name) <> '' THEN 1 ELSE 0 END),0)
    ),1 FROM folklore_medicine WHERE phone_number = '3233232332'

  ) t
) final;
