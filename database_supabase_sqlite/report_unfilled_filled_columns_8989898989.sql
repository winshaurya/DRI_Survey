-- Report unfilled columns and filled values for phone number 8989898989
-- Shows names of unfilled columns and values for filled columns per table
-- Includes ALL 50+ family survey tables, even if no data exists for this phone

DROP TABLE IF EXISTS temp_column_report;

CREATE TEMP TABLE temp_column_report (
  table_name text,
  column_name text,
  is_filled boolean,
  value_text text
);

-- SQLite-compatible implementation (replacement for the original PostgreSQL PL/pgSQL block).
-- Behaviour: for each table that contains a `phone_number` column this script
-- inserts one row per column into `temp_column_report` for phone `8989898989`.
-- - If a row exists for that phone, each column's value (from the first matching row)
--   is recorded and `is_filled` set based on NULL/empty checks.
-- - If no row exists for the phone in a table, every column for that table is
--   inserted with `is_filled = false` and `value_text = NULL`.
--
-- Implementation notes:
-- - Uses JSON1 (`json_object` + `json_each`) to unpivot columns -> (key, value).
-- - This file is now SQLite-compatible (no PL/pgSQL `DO` block).
-- - If you need stricter Postgres behaviour, run the original Postgres script instead.

-- Example pattern used below for every table:
-- 1) create a JSON object from the first row for phone_number = '8989898989'
-- 2) json_each(row_json) -> (key, value) to insert per-column rows
-- 3) if no row exists for that phone, insert unfilled rows for all column names

-- NOTE: this script assumes the database has the tables/columns listed in
-- `all_table_columns.txt`. If some tables don't exist this script will fail only
-- for those tables — remove them from the script or create the tables first.

-- ===== family_survey_sessions =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'family_survey_sessions', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object(
    'phone_number', phone_number,
    'surveyor_email', surveyor_email,
    'created_at', created_at,
    'updated_at', updated_at,
    'village_name', village_name,
    'village_number', village_number,
    'panchayat', panchayat,
    'block', block,
    'tehsil', tehsil,
    'district', district,
    'postal_address', postal_address,
    'pin_code', pin_code,
    'shine_code', shine_code,
    'latitude', latitude,
    'longitude', longitude,
    'location_accuracy', location_accuracy,
    'location_timestamp', location_timestamp,
    'survey_date', survey_date,
    'surveyor_name', surveyor_name,
    'status', status,
    'device_info', device_info,
    'app_version', app_version,
    'created_by', created_by,
    'updated_by', updated_by,
    'is_deleted', is_deleted,
    'last_synced_at', last_synced_at,
    'current_version', current_version,
    'last_edited_at', last_edited_at,
    'page_completion_status', page_completion_status,
    'sync_pending', sync_pending
  ) AS row_json
  FROM family_survey_sessions
  WHERE phone_number = '8989898989'
  LIMIT 1
) AS r
CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'family_survey_sessions', key, 0, NULL
FROM (VALUES
  ('phone_number'),('surveyor_email'),('created_at'),('updated_at'),('village_name'),('village_number'),('panchayat'),('block'),('tehsil'),('district'),('postal_address'),('pin_code'),('shine_code'),('latitude'),('longitude'),('location_accuracy'),('location_timestamp'),('survey_date'),('surveyor_name'),('status'),('device_info'),('app_version'),('created_by'),('updated_by'),('is_deleted'),('last_synced_at'),('current_version'),('last_edited_at'),('page_completion_status'),('sync_pending')
) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM family_survey_sessions WHERE phone_number = '8989898989');

-- ===== family_members =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'family_members', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object(
    'id', id,
    'phone_number', phone_number,
    'created_at', created_at,
    'updated_at', updated_at,
    'is_deleted', is_deleted,
    'sr_no', sr_no,
    'name', name,
    'fathers_name', fathers_name,
    'mothers_name', mothers_name,
    'relationship_with_head', relationship_with_head,
    'age', age,
    'sex', sex,
    'physically_fit', physically_fit,
    'physically_fit_cause', physically_fit_cause,
    'educational_qualification', educational_qualification,
    'inclination_self_employment', inclination_self_employment,
    'occupation', occupation,
    'days_employed', days_employed,
    'income', income,
    'awareness_about_village', awareness_about_village,
    'participate_gram_sabha', participate_gram_sabha,
    'insured', insured,
    'insurance_company', insurance_company
  ) AS row_json
  FROM family_members
  WHERE phone_number = '8989898989'
  LIMIT 1
) AS r
CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'family_members', key, 0, NULL
FROM (VALUES
  ('id'),('phone_number'),('created_at'),('updated_at'),('is_deleted'),('sr_no'),('name'),('fathers_name'),('mothers_name'),('relationship_with_head'),('age'),('sex'),('physically_fit'),('physically_fit_cause'),('educational_qualification'),('inclination_self_employment'),('occupation'),('days_employed'),('income'),('awareness_about_village'),('participate_gram_sabha'),('insured'),('insurance_company')
) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM family_members WHERE phone_number = '8989898989');

-- ===== aadhaar_info =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'aadhaar_info', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'created_at', created_at, 'has_aadhaar', has_aadhaar, 'total_members', total_members) AS row_json
  FROM aadhaar_info WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'aadhaar_info', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('created_at'),('has_aadhaar'),('total_members')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM aadhaar_info WHERE phone_number = '8989898989');

-- ===== aadhaar_scheme_members =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'aadhaar_scheme_members', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'sr_no', sr_no, 'family_member_name', family_member_name, 'have_card', have_card, 'card_number', card_number, 'details_correct', details_correct, 'what_incorrect', what_incorrect, 'benefits_received', benefits_received, 'created_at', created_at) AS row_json
  FROM aadhaar_scheme_members WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'aadhaar_scheme_members', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('sr_no'),('family_member_name'),('have_card'),('card_number'),('details_correct'),('what_incorrect'),('benefits_received'),('created_at')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM aadhaar_scheme_members WHERE phone_number = '8989898989');

-- ===== agricultural_equipment =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'agricultural_equipment', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'created_at', created_at, 'tractor', tractor, 'tractor_condition', tractor_condition, 'thresher', thresher, 'thresher_condition', thresher_condition, 'seed_drill', seed_drill, 'seed_drill_condition', seed_drill_condition, 'sprayer', sprayer, 'sprayer_condition', sprayer_condition, 'duster', duster, 'duster_condition', duster_condition, 'diesel_engine', diesel_engine, 'diesel_engine_condition', diesel_engine_condition, 'other_equipment', other_equipment) AS row_json
  FROM agricultural_equipment WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'agricultural_equipment', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('created_at'),('tractor'),('tractor_condition'),('thresher'),('thresher_condition'),('seed_drill'),('seed_drill_condition'),('sprayer'),('sprayer_condition'),('duster'),('duster_condition'),('diesel_engine'),('diesel_engine_condition'),('other_equipment')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM agricultural_equipment WHERE phone_number = '8989898989');

-- ===== animals =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'animals', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'created_at', created_at, 'sr_no', sr_no, 'animal_type', animal_type, 'number_of_animals', number_of_animals, 'breed', breed, 'production_per_animal', production_per_animal, 'quantity_sold', quantity_sold) AS row_json
  FROM animals WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'animals', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('created_at'),('sr_no'),('animal_type'),('number_of_animals'),('breed'),('production_per_animal'),('quantity_sold')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM animals WHERE phone_number = '8989898989');

-- ===== bank_accounts =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'bank_accounts', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'sr_no', sr_no, 'member_name', member_name, 'account_number', account_number, 'bank_name', bank_name, 'ifsc_code', ifsc_code, 'branch_name', branch_name, 'account_type', account_type, 'has_account', has_account, 'details_correct', details_correct, 'incorrect_details', incorrect_details, 'created_at', created_at) AS row_json
  FROM bank_accounts WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'bank_accounts', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('sr_no'),('member_name'),('account_number'),('bank_name'),('ifsc_code'),('branch_name'),('account_type'),('has_account'),('details_correct'),('incorrect_details'),('created_at')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM bank_accounts WHERE phone_number = '8989898989');

-- ===== crop_productivity =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'crop_productivity', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'created_at', created_at, 'sr_no', sr_no, 'crop_name', crop_name, 'area_hectares', area_hectares, 'productivity_quintal_per_hectare', productivity_quintal_per_hectare, 'total_production_quintal', total_production_quintal, 'quantity_consumed_quintal', quantity_consumed_quintal, 'quantity_sold_quintal', quantity_sold_quintal) AS row_json
  FROM crop_productivity WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'crop_productivity', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('created_at'),('sr_no'),('crop_name'),('area_hectares'),('productivity_quintal_per_hectare'),('total_production_quintal'),('quantity_consumed_quintal'),('quantity_sold_quintal')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM crop_productivity WHERE phone_number = '8989898989');

-- ===== drinking_water_sources =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'drinking_water_sources', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'created_at', created_at, 'hand_pumps', hand_pumps, 'hand_pumps_distance', hand_pumps_distance, 'hand_pumps_quality', hand_pumps_quality, 'well', well, 'well_distance', well_distance, 'well_quality', well_quality, 'tubewell', tubewell, 'tubewell_distance', tubewell_distance, 'tubewell_quality', tubewell_quality, 'nal_jaal', nal_jaal, 'nal_jaal_quality', nal_jaal_quality, 'other_source', other_source, 'other_distance', other_distance, 'other_sources_quality', other_sources_quality) AS row_json
  FROM drinking_water_sources WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'drinking_water_sources', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('created_at'),('hand_pumps'),('hand_pumps_distance'),('hand_pumps_quality'),('well'),('well_distance'),('well_quality'),('tubewell'),('tubewell_distance'),('tubewell_quality'),('nal_jaal'),('nal_jaal_quality'),('other_source'),('other_distance'),('other_sources_quality')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM drinking_water_sources WHERE phone_number = '8989898989');

-- ===== house_conditions =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'house_conditions', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'created_at', created_at, 'katcha', katcha, 'pakka', pakka, 'katcha_pakka', katcha_pakka, 'hut', hut, 'toilet_in_use', toilet_in_use, 'toilet_condition', toilet_condition) AS row_json
  FROM house_conditions WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'house_conditions', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('created_at'),('katcha'),('pakka'),('katcha_pakka'),('hut'),('toilet_in_use'),('toilet_condition')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM house_conditions WHERE phone_number = '8989898989');

-- ===== house_facilities =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'house_facilities', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'created_at', created_at, 'toilet', toilet, 'toilet_in_use', toilet_in_use, 'drainage', drainage, 'soak_pit', soak_pit, 'cattle_shed', cattle_shed, 'compost_pit', compost_pit, 'nadep', nadep, 'lpg_gas', lpg_gas, 'biogas', biogas, 'solar_cooking', solar_cooking, 'electric_connection', electric_connection, 'nutritional_garden_available', nutritional_garden_available, 'tulsi_plants_available', tulsi_plants_available) AS row_json
  FROM house_facilities WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'house_facilities', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('created_at'),('toilet'),('toilet_in_use'),('drainage'),('soak_pit'),('cattle_shed'),('compost_pit'),('nadep'),('lpg_gas'),('biogas'),('solar_cooking'),('electric_connection'),('nutritional_garden_available'),('tulsi_plants_available')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM house_facilities WHERE phone_number = '8989898989');

-- ===== medical_treatment =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'medical_treatment', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'created_at', created_at, 'allopathic', allopathic, 'ayurvedic', ayurvedic, 'homeopathy', homeopathy, 'traditional', traditional, 'other_treatment', other_treatment, 'preferred_treatment', preferred_treatment) AS row_json
  FROM medical_treatment WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'medical_treatment', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('created_at'),('allopathic'),('ayurvedic'),('homeopathy'),('traditional'),('other_treatment'),('preferred_treatment')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM medical_treatment WHERE phone_number = '8989898989');

-- ===== diseases =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'diseases', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'created_at', created_at, 'sr_no', sr_no, 'family_member_name', family_member_name, 'disease_name', disease_name, 'suffering_since', suffering_since, 'treatment_taken', treatment_taken, 'treatment_from_when', treatment_from_when, 'treatment_from_where', treatment_from_where, 'treatment_taken_from', treatment_taken_from) AS row_json
  FROM diseases WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'diseases', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('created_at'),('sr_no'),('family_member_name'),('disease_name'),('suffering_since'),('treatment_taken'),('treatment_from_when'),('treatment_from_where'),('treatment_taken_from')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM diseases WHERE phone_number = '8989898989');

-- ===== fertilizer_usage =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'fertilizer_usage', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'created_at', created_at, 'urea_fertilizer', urea_fertilizer, 'organic_fertilizer', organic_fertilizer, 'fertilizer_types', fertilizer_types, 'fertilizer_expenditure', fertilizer_expenditure) AS row_json
  FROM fertilizer_usage WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'fertilizer_usage', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('created_at'),('urea_fertilizer'),('organic_fertilizer'),('fertilizer_types'),('fertilizer_expenditure')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM fertilizer_usage WHERE phone_number = '8989898989');

-- ===== folklore_medicine =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'folklore_medicine', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'person_name', person_name, 'plant_local_name', plant_local_name, 'plant_botanical_name', plant_botanical_name, 'uses', uses, 'created_at', created_at) AS row_json
  FROM folklore_medicine WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'folklore_medicine', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('person_name'),('plant_local_name'),('plant_botanical_name'),('uses'),('created_at')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM folklore_medicine WHERE phone_number = '8989898989');

-- ===== training_data =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'training_data', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'member_name', member_name, 'training_topic', training_topic, 'training_duration', training_duration, 'training_date', training_date, 'status', status, 'created_at', created_at) AS row_json
  FROM training_data WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'training_data', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('member_name'),('training_topic'),('training_duration'),('training_date'),('status'),('created_at')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM training_data WHERE phone_number = '8989898989');

-- ===== vb_gram =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'vb_gram', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'is_member', is_member, 'total_members', total_members, 'created_at', created_at) AS row_json
  FROM vb_gram WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'vb_gram', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('is_member'),('total_members'),('created_at')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM vb_gram WHERE phone_number = '8989898989');

-- ===== pm_kisan_nidhi =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'pm_kisan_nidhi', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'is_beneficiary', is_beneficiary, 'total_members', total_members, 'created_at', created_at) AS row_json
  FROM pm_kisan_nidhi WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'pm_kisan_nidhi', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('is_beneficiary'),('total_members'),('created_at')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM pm_kisan_nidhi WHERE phone_number = '8989898989');

-- ===== merged_govt_schemes =====
INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
SELECT 'merged_govt_schemes', j.key,
       CASE WHEN j.value IS NULL OR (typeof(j.value) = 'text' AND trim(j.value) = '') THEN 0 ELSE 1 END,
       j.value
FROM (
  SELECT json_object('id', id, 'phone_number', phone_number, 'scheme_data', scheme_data, 'created_at', created_at) AS row_json
  FROM merged_govt_schemes WHERE phone_number = '8989898989' LIMIT 1
) r CROSS JOIN json_each(r.row_json) AS j
UNION ALL
SELECT 'merged_govt_schemes', key, 0, NULL
FROM (VALUES ('id'),('phone_number'),('scheme_data'),('created_at')) AS keys(key)
WHERE NOT EXISTS (SELECT 1 FROM merged_govt_schemes WHERE phone_number = '8989898989');

-- ===== fallback: short summary for any remaining tables (optional) =====
-- If you add more tables to your schema, append the same pattern as above.
-- End of SQLite-compatible data population.


-- Report unfilled columns (names only)
SELECT 'UNFILLED COLUMNS' as report_type, table_name, column_name
FROM temp_column_report
WHERE is_filled = false
ORDER BY table_name, column_name;

-- Report filled columns with values
SELECT 'FILLED COLUMNS WITH VALUES' as report_type, table_name, column_name, value_text as value
FROM temp_column_report
WHERE is_filled = true
ORDER BY table_name, column_name;

-- Summary
SELECT
  table_name,
  COUNT(*) as total_columns,
  SUM(CASE WHEN is_filled THEN 1 ELSE 0 END) as filled_columns,
  SUM(CASE WHEN NOT is_filled THEN 1 ELSE 0 END) as unfilled_columns
FROM temp_column_report
GROUP BY table_name
ORDER BY table_name;