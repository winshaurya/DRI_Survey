-- ===========================================
-- VILLAGE SURVEY COMPLETENESS ANALYSIS FOR SHINE_002
-- ===========================================
-- This is the same analysis as the SHINE_001 script but targeted at SHINE_002.
-- Usage examples:
-- - Supabase SQL editor: paste and run the file.
-- - psql / local Postgres: psql "postgresql://postgres:<PASSWORD>@db.<PROJECT>.supabase.co:5432/postgres" -f analyze_village_survey_completeness_shine_002.sql
-- - Export to CSV (psql):
--   \copy (SELECT * FROM village_table_existence_summary) TO 'village_table_existence_shine_002.csv' CSV HEADER;

-- NOTE: This file is generated from analyze_village_survey_completeness_shine_001.sql by replacing 'SHINE_001' -> 'SHINE_002'.

WITH village_table_existence AS (
    SELECT
        'village_survey_sessions' as table_name,
        CASE WHEN EXISTS (SELECT 1 FROM village_survey_sessions WHERE shine_code = 'SHINE_002') THEN 1 ELSE 0 END as has_data
    UNION ALL
    SELECT 'village_population', CASE WHEN EXISTS (SELECT 1 FROM village_population WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_farm_families', CASE WHEN EXISTS (SELECT 1 FROM village_farm_families WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_housing', CASE WHEN EXISTS (SELECT 1 FROM village_housing WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_agricultural_implements', CASE WHEN EXISTS (SELECT 1 FROM village_agricultural_implements WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_crop_productivity', CASE WHEN EXISTS (SELECT 1 FROM village_crop_productivity WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_animals', CASE WHEN EXISTS (SELECT 1 FROM village_animals WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_irrigation_facilities', CASE WHEN EXISTS (SELECT 1 FROM village_irrigation_facilities WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_drinking_water', CASE WHEN EXISTS (SELECT 1 FROM village_drinking_water WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_transport', CASE WHEN EXISTS (SELECT 1 FROM village_transport WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_entertainment', CASE WHEN EXISTS (SELECT 1 FROM village_entertainment WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_medical_treatment', CASE WHEN EXISTS (SELECT 1 FROM village_medical_treatment WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_disputes', CASE WHEN EXISTS (SELECT 1 FROM village_disputes WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_educational_facilities', CASE WHEN EXISTS (SELECT 1 FROM village_educational_facilities WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_social_consciousness', CASE WHEN EXISTS (SELECT 1 FROM village_social_consciousness WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_children_data', CASE WHEN EXISTS (SELECT 1 FROM village_children_data WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_malnutrition_data', CASE WHEN EXISTS (SELECT 1 FROM village_malnutrition_data WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_bpl_families', CASE WHEN EXISTS (SELECT 1 FROM village_bpl_families WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_kitchen_gardens', CASE WHEN EXISTS (SELECT 1 FROM village_kitchen_gardens WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_seed_clubs', CASE WHEN EXISTS (SELECT 1 FROM village_seed_clubs WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_biodiversity_register', CASE WHEN EXISTS (SELECT 1 FROM village_biodiversity_register WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_traditional_occupations', CASE WHEN EXISTS (SELECT 1 FROM village_traditional_occupations WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_drainage_waste', CASE WHEN EXISTS (SELECT 1 FROM village_drainage_waste WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_signboards', CASE WHEN EXISTS (SELECT 1 FROM village_signboards WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_unemployment', CASE WHEN EXISTS (SELECT 1 FROM village_unemployment WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_social_maps', CASE WHEN EXISTS (SELECT 1 FROM village_social_maps WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_transport_facilities', CASE WHEN EXISTS (SELECT 1 FROM village_transport_facilities WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_infrastructure', CASE WHEN EXISTS (SELECT 1 FROM village_infrastructure WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_infrastructure_details', CASE WHEN EXISTS (SELECT 1 FROM village_infrastructure_details WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_survey_details', CASE WHEN EXISTS (SELECT 1 FROM village_survey_details WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_map_points', CASE WHEN EXISTS (SELECT 1 FROM village_map_points WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_forest_maps', CASE WHEN EXISTS (SELECT 1 FROM village_forest_maps WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_cadastral_maps', CASE WHEN EXISTS (SELECT 1 FROM village_cadastral_maps WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_002')) THEN 1 ELSE 0 END
)

SELECT
    'VILLAGE TABLE EXISTENCE SUMMARY' as analysis_type,
    COUNT(*) as total_tables,
    SUM(has_data) as tables_with_data,
    COUNT(*) - SUM(has_data) as tables_empty,
    ROUND((SUM(has_data)::decimal / COUNT(*)::decimal) * 100, 2) as completeness_percentage
FROM village_table_existence;

-- (rest of script is identical to the SHINE_001 variant and uses 'SHINE_002' everywhere)
