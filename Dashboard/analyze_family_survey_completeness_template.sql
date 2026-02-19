-- ===========================================
-- FAMILY SURVEY COMPLETENESS ANALYSIS — REVISED
-- ===========================================
-- Template to analyze family survey completeness by `phone_number`.
--
-- Usage:
-- - Supabase SQL editor: Open the SQL editor, paste the file and run.
-- - psql / local Postgres: Save file and run:
--     psql -h HOST -U USER -d DB -f analyze_family_survey_completeness_template.sql
-- - To change the target phone number, edit the `params` CTE below.

-- -----------------------------
-- PARAMETERS (change here)
-- -----------------------------
CREATE TEMP TABLE IF NOT EXISTS params (phone_number text);
TRUNCATE params;
INSERT INTO params VALUES ('2555555555');

-- Check which family tables have ANY data for the selected phone_number
WITH family_table_existence AS (
SELECT 'family_survey_sessions' as table_name, CASE WHEN EXISTS (SELECT 1 FROM family_survey_sessions WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END as has_data UNION ALL
SELECT 'family_members', CASE WHEN EXISTS (SELECT 1 FROM family_members WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'land_holding', CASE WHEN EXISTS (SELECT 1 FROM land_holding WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'irrigation_facilities', CASE WHEN EXISTS (SELECT 1 FROM irrigation_facilities WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'crop_productivity', CASE WHEN EXISTS (SELECT 1 FROM crop_productivity WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'fertilizer_usage', CASE WHEN EXISTS (SELECT 1 FROM fertilizer_usage WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'animals', CASE WHEN EXISTS (SELECT 1 FROM animals WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'agricultural_equipment', CASE WHEN EXISTS (SELECT 1 FROM agricultural_equipment WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'entertainment_facilities', CASE WHEN EXISTS (SELECT 1 FROM entertainment_facilities WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'transport_facilities', CASE WHEN EXISTS (SELECT 1 FROM transport_facilities WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'drinking_water_sources', CASE WHEN EXISTS (SELECT 1 FROM drinking_water_sources WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'medical_treatment', CASE WHEN EXISTS (SELECT 1 FROM medical_treatment WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'disputes', CASE WHEN EXISTS (SELECT 1 FROM disputes WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'house_conditions', CASE WHEN EXISTS (SELECT 1 FROM house_conditions WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'house_facilities', CASE WHEN EXISTS (SELECT 1 FROM house_facilities WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'diseases', CASE WHEN EXISTS (SELECT 1 FROM diseases WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'social_consciousness', CASE WHEN EXISTS (SELECT 1 FROM social_consciousness WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'children_data', CASE WHEN EXISTS (SELECT 1 FROM children_data WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'folklore_medicine', CASE WHEN EXISTS (SELECT 1 FROM folklore_medicine WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'health_programmes', CASE WHEN EXISTS (SELECT 1 FROM health_programmes WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'migration_data', CASE WHEN EXISTS (SELECT 1 FROM migration_data WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'training_data', CASE WHEN EXISTS (SELECT 1 FROM training_data WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'vb_gram', CASE WHEN EXISTS (SELECT 1 FROM vb_gram WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'pm_kisan_nidhi', CASE WHEN EXISTS (SELECT 1 FROM pm_kisan_nidhi WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'pm_kisan_samman_nidhi', CASE WHEN EXISTS (SELECT 1 FROM pm_kisan_samman_nidhi WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'bank_accounts', CASE WHEN EXISTS (SELECT 1 FROM bank_accounts WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'family_id', CASE WHEN EXISTS (SELECT 1 FROM family_id WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'aadhaar_info', CASE WHEN EXISTS (SELECT 1 FROM aadhaar_info WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'ayushman_card', CASE WHEN EXISTS (SELECT 1 FROM ayushman_card WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'ration_card', CASE WHEN EXISTS (SELECT 1 FROM ration_card WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'samagra_id', CASE WHEN EXISTS (SELECT 1 FROM samagra_id WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END UNION ALL
SELECT 'tribal_card', CASE WHEN EXISTS (SELECT 1 FROM tribal_card WHERE phone_number = (SELECT phone_number::bigint FROM params)) THEN 1 ELSE 0 END
)

SELECT
    'FAMILY TABLE EXISTENCE SUMMARY' as analysis_type,
    COUNT(*) as total_tables,
    SUM(has_data) as tables_with_data,
    COUNT(*) - SUM(has_data) as tables_empty,
    ROUND((SUM(has_data)::decimal / COUNT(*)::decimal) * 100, 2) as completeness_percentage
FROM family_table_existence;

-- End of revised family completeness template