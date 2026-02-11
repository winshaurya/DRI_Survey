-- ===========================================
-- VILLAGE SURVEY COMPLETENESS ANALYSIS FOR SHINE_019
-- ===========================================
-- This query analyzes every village survey table to determine:
-- 1. How many tables have data vs are completely empty
-- 2. How many columns are filled vs null/empty in each table
-- 3. Overall completeness percentage

-- First, let's check which tables have ANY data for this shine_code
WITH village_table_existence AS (
    SELECT
        'village_survey_sessions' as table_name,
        CASE WHEN EXISTS (SELECT 1 FROM village_survey_sessions WHERE shine_code = 'SHINE_019') THEN 1 ELSE 0 END as has_data
    UNION ALL
    SELECT 'village_population', CASE WHEN EXISTS (SELECT 1 FROM village_population WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_farm_families', CASE WHEN EXISTS (SELECT 1 FROM village_farm_families WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_housing', CASE WHEN EXISTS (SELECT 1 FROM village_housing WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_agricultural_implements', CASE WHEN EXISTS (SELECT 1 FROM village_agricultural_implements WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_crop_productivity', CASE WHEN EXISTS (SELECT 1 FROM village_crop_productivity WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_animals', CASE WHEN EXISTS (SELECT 1 FROM village_animals WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_irrigation_facilities', CASE WHEN EXISTS (SELECT 1 FROM village_irrigation_facilities WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_drinking_water', CASE WHEN EXISTS (SELECT 1 FROM village_drinking_water WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_transport', CASE WHEN EXISTS (SELECT 1 FROM village_transport WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_entertainment', CASE WHEN EXISTS (SELECT 1 FROM village_entertainment WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_medical_treatment', CASE WHEN EXISTS (SELECT 1 FROM village_medical_treatment WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_disputes', CASE WHEN EXISTS (SELECT 1 FROM village_disputes WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_educational_facilities', CASE WHEN EXISTS (SELECT 1 FROM village_educational_facilities WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_social_consciousness', CASE WHEN EXISTS (SELECT 1 FROM village_social_consciousness WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_children_data', CASE WHEN EXISTS (SELECT 1 FROM village_children_data WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_malnutrition_data', CASE WHEN EXISTS (SELECT 1 FROM village_malnutrition_data WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_bpl_families', CASE WHEN EXISTS (SELECT 1 FROM village_bpl_families WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_kitchen_gardens', CASE WHEN EXISTS (SELECT 1 FROM village_kitchen_gardens WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_seed_clubs', CASE WHEN EXISTS (SELECT 1 FROM village_seed_clubs WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_biodiversity_register', CASE WHEN EXISTS (SELECT 1 FROM village_biodiversity_register WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_traditional_occupations', CASE WHEN EXISTS (SELECT 1 FROM village_traditional_occupations WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_drainage_waste', CASE WHEN EXISTS (SELECT 1 FROM village_drainage_waste WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_signboards', CASE WHEN EXISTS (SELECT 1 FROM village_signboards WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_unemployment', CASE WHEN EXISTS (SELECT 1 FROM village_unemployment WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_social_maps', CASE WHEN EXISTS (SELECT 1 FROM village_social_maps WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_transport_facilities', CASE WHEN EXISTS (SELECT 1 FROM village_transport_facilities WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_infrastructure', CASE WHEN EXISTS (SELECT 1 FROM village_infrastructure WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_infrastructure_details', CASE WHEN EXISTS (SELECT 1 FROM village_infrastructure_details WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_survey_details', CASE WHEN EXISTS (SELECT 1 FROM village_survey_details WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_map_points', CASE WHEN EXISTS (SELECT 1 FROM village_map_points WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_forest_maps', CASE WHEN EXISTS (SELECT 1 FROM village_forest_maps WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'village_cadastral_maps', CASE WHEN EXISTS (SELECT 1 FROM village_cadastral_maps WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019')) THEN 1 ELSE 0 END
)

SELECT
    'VILLAGE TABLE EXISTENCE SUMMARY' as analysis_type,
    COUNT(*) as total_tables,
    SUM(has_data) as tables_with_data,
    COUNT(*) - SUM(has_data) as tables_empty,
    ROUND((SUM(has_data)::decimal / COUNT(*)::decimal) * 100, 2) as completeness_percentage
FROM village_table_existence;

-- Now let's analyze column completeness for tables that have data
-- Get the session_id for SHINE_019
WITH session_data AS (
    SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019'
)

-- VILLAGE_SURVEY_SESSIONS analysis
SELECT
    'village_survey_sessions' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN session_id IS NOT NULL AND session_id != '' THEN 1 ELSE 0 END) as session_id_filled,
    SUM(CASE WHEN surveyor_email IS NOT NULL AND surveyor_email != '' THEN 1 ELSE 0 END) as surveyor_email_filled,
    SUM(CASE WHEN village_name IS NOT NULL AND village_name != '' THEN 1 ELSE 0 END) as village_name_filled,
    SUM(CASE WHEN village_code IS NOT NULL AND village_code != '' THEN 1 ELSE 0 END) as village_code_filled,
    SUM(CASE WHEN state IS NOT NULL AND state != '' THEN 1 ELSE 0 END) as state_filled,
    SUM(CASE WHEN district IS NOT NULL AND district != '' THEN 1 ELSE 0 END) as district_filled,
    SUM(CASE WHEN block IS NOT NULL AND block != '' THEN 1 ELSE 0 END) as block_filled,
    SUM(CASE WHEN panchayat IS NOT NULL AND panchayat != '' THEN 1 ELSE 0 END) as panchayat_filled,
    SUM(CASE WHEN tehsil IS NOT NULL AND tehsil != '' THEN 1 ELSE 0 END) as tehsil_filled,
    SUM(CASE WHEN shine_code IS NOT NULL AND shine_code != '' THEN 1 ELSE 0 END) as shine_code_filled,
    SUM(CASE WHEN status IS NOT NULL AND status != '' THEN 1 ELSE 0 END) as status_filled
FROM village_survey_sessions
WHERE shine_code = 'SHINE_019';

-- VILLAGE_POPULATION analysis
SELECT
    'village_population' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN total_population IS NOT NULL THEN 1 ELSE 0 END) as total_population_filled,
    SUM(CASE WHEN male_population IS NOT NULL THEN 1 ELSE 0 END) as male_population_filled,
    SUM(CASE WHEN female_population IS NOT NULL THEN 1 ELSE 0 END) as female_population_filled,
    SUM(CASE WHEN children_0_5 IS NOT NULL THEN 1 ELSE 0 END) as children_0_5_filled,
    SUM(CASE WHEN children_6_14 IS NOT NULL THEN 1 ELSE 0 END) as children_6_14_filled,
    SUM(CASE WHEN youth_15_24 IS NOT NULL THEN 1 ELSE 0 END) as youth_15_24_filled,
    SUM(CASE WHEN adults_25_59 IS NOT NULL THEN 1 ELSE 0 END) as adults_25_59_filled,
    SUM(CASE WHEN seniors_60_plus IS NOT NULL THEN 1 ELSE 0 END) as seniors_60_plus_filled,
    SUM(CASE WHEN sc_population IS NOT NULL THEN 1 ELSE 0 END) as sc_population_filled,
    SUM(CASE WHEN st_population IS NOT NULL THEN 1 ELSE 0 END) as st_population_filled,
    SUM(CASE WHEN obc_population IS NOT NULL THEN 1 ELSE 0 END) as obc_population_filled,
    SUM(CASE WHEN general_population IS NOT NULL THEN 1 ELSE 0 END) as general_population_filled,
    SUM(CASE WHEN working_population IS NOT NULL THEN 1 ELSE 0 END) as working_population_filled,
    SUM(CASE WHEN unemployed_population IS NOT NULL THEN 1 ELSE 0 END) as unemployed_population_filled
FROM village_population
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_HOUSING analysis
SELECT
    'village_housing' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN katcha_houses IS NOT NULL THEN 1 ELSE 0 END) as katcha_houses_filled,
    SUM(CASE WHEN pakka_houses IS NOT NULL THEN 1 ELSE 0 END) as pakka_houses_filled,
    SUM(CASE WHEN katcha_pakka_houses IS NOT NULL THEN 1 ELSE 0 END) as katcha_pakka_houses_filled,
    SUM(CASE WHEN hut_houses IS NOT NULL THEN 1 ELSE 0 END) as hut_houses_filled,
    SUM(CASE WHEN houses_with_toilet IS NOT NULL THEN 1 ELSE 0 END) as houses_with_toilet_filled,
    SUM(CASE WHEN functional_toilets IS NOT NULL THEN 1 ELSE 0 END) as functional_toilets_filled,
    SUM(CASE WHEN houses_with_drainage IS NOT NULL THEN 1 ELSE 0 END) as houses_with_drainage_filled,
    SUM(CASE WHEN houses_with_soak_pit IS NOT NULL THEN 1 ELSE 0 END) as houses_with_soak_pit_filled,
    SUM(CASE WHEN houses_with_cattle_shed IS NOT NULL THEN 1 ELSE 0 END) as houses_with_cattle_shed_filled,
    SUM(CASE WHEN houses_with_compost_pit IS NOT NULL THEN 1 ELSE 0 END) as houses_with_compost_pit_filled,
    SUM(CASE WHEN houses_with_nadep IS NOT NULL THEN 1 ELSE 0 END) as houses_with_nadep_filled,
    SUM(CASE WHEN houses_with_lpg IS NOT NULL THEN 1 ELSE 0 END) as houses_with_lpg_filled,
    SUM(CASE WHEN houses_with_biogas IS NOT NULL THEN 1 ELSE 0 END) as houses_with_biogas_filled,
    SUM(CASE WHEN houses_with_solar IS NOT NULL THEN 1 ELSE 0 END) as houses_with_solar_filled,
    SUM(CASE WHEN houses_with_electricity IS NOT NULL THEN 1 ELSE 0 END) as houses_with_electricity_filled
FROM village_housing
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_AGRICULTURAL_IMPLEMENTS analysis
SELECT
    'village_agricultural_implements' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN tractor_available IS NOT NULL THEN 1 ELSE 0 END) as tractor_available_filled,
    SUM(CASE WHEN thresher_available IS NOT NULL THEN 1 ELSE 0 END) as thresher_available_filled,
    SUM(CASE WHEN seed_drill_available IS NOT NULL THEN 1 ELSE 0 END) as seed_drill_available_filled,
    SUM(CASE WHEN sprayer_available IS NOT NULL THEN 1 ELSE 0 END) as sprayer_available_filled,
    SUM(CASE WHEN duster_available IS NOT NULL THEN 1 ELSE 0 END) as duster_available_filled,
    SUM(CASE WHEN diesel_engine_available IS NOT NULL THEN 1 ELSE 0 END) as diesel_engine_available_filled,
    SUM(CASE WHEN other_implements IS NOT NULL AND other_implements != '' THEN 1 ELSE 0 END) as other_implements_filled
FROM village_agricultural_implements
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_CROP_PRODUCTIVITY analysis
SELECT
    'village_crop_productivity' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN sr_no IS NOT NULL THEN 1 ELSE 0 END) as sr_no_filled,
    SUM(CASE WHEN crop_name IS NOT NULL AND crop_name != '' THEN 1 ELSE 0 END) as crop_name_filled,
    SUM(CASE WHEN area_hectares IS NOT NULL THEN 1 ELSE 0 END) as area_hectares_filled,
    SUM(CASE WHEN productivity_quintal_per_hectare IS NOT NULL THEN 1 ELSE 0 END) as productivity_filled,
    SUM(CASE WHEN total_production_quintal IS NOT NULL THEN 1 ELSE 0 END) as total_production_filled,
    SUM(CASE WHEN quantity_consumed_quintal IS NOT NULL THEN 1 ELSE 0 END) as quantity_consumed_filled,
    SUM(CASE WHEN quantity_sold_quintal IS NOT NULL THEN 1 ELSE 0 END) as quantity_sold_filled
FROM village_crop_productivity
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_ANIMALS analysis
SELECT
    'village_animals' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN sr_no IS NOT NULL THEN 1 ELSE 0 END) as sr_no_filled,
    SUM(CASE WHEN animal_type IS NOT NULL AND animal_type != '' THEN 1 ELSE 0 END) as animal_type_filled,
    SUM(CASE WHEN total_count IS NOT NULL THEN 1 ELSE 0 END) as total_count_filled,
    SUM(CASE WHEN breed IS NOT NULL AND breed != '' THEN 1 ELSE 0 END) as breed_filled
FROM village_animals
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_IRRIGATION_FACILITIES analysis
SELECT
    'village_irrigation_facilities' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN has_canal IS NOT NULL THEN 1 ELSE 0 END) as has_canal_filled,
    SUM(CASE WHEN has_tube_well IS NOT NULL THEN 1 ELSE 0 END) as has_tube_well_filled,
    SUM(CASE WHEN has_ponds IS NOT NULL THEN 1 ELSE 0 END) as has_ponds_filled,
    SUM(CASE WHEN has_river IS NOT NULL THEN 1 ELSE 0 END) as has_river_filled,
    SUM(CASE WHEN has_well IS NOT NULL THEN 1 ELSE 0 END) as has_well_filled,
    SUM(CASE WHEN other_sources IS NOT NULL AND other_sources != '' THEN 1 ELSE 0 END) as other_sources_filled
FROM village_irrigation_facilities
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_DRINKING_WATER analysis
SELECT
    'village_drinking_water' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN hand_pumps_available IS NOT NULL THEN 1 ELSE 0 END) as hand_pumps_available_filled,
    SUM(CASE WHEN hand_pumps_count IS NOT NULL THEN 1 ELSE 0 END) as hand_pumps_count_filled,
    SUM(CASE WHEN wells_available IS NOT NULL THEN 1 ELSE 0 END) as wells_available_filled,
    SUM(CASE WHEN wells_count IS NOT NULL THEN 1 ELSE 0 END) as wells_count_filled,
    SUM(CASE WHEN tube_wells_available IS NOT NULL THEN 1 ELSE 0 END) as tube_wells_available_filled,
    SUM(CASE WHEN tube_wells_count IS NOT NULL THEN 1 ELSE 0 END) as tube_wells_count_filled,
    SUM(CASE WHEN nal_jal_available IS NOT NULL THEN 1 ELSE 0 END) as nal_jal_available_filled,
    SUM(CASE WHEN other_sources IS NOT NULL AND other_sources != '' THEN 1 ELSE 0 END) as other_sources_filled
FROM village_drinking_water
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_TRANSPORT analysis
SELECT
    'village_transport' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN cars_available IS NOT NULL THEN 1 ELSE 0 END) as cars_available_filled,
    SUM(CASE WHEN motorcycles_available IS NOT NULL THEN 1 ELSE 0 END) as motorcycles_available_filled,
    SUM(CASE WHEN e_rickshaws_available IS NOT NULL THEN 1 ELSE 0 END) as e_rickshaws_available_filled,
    SUM(CASE WHEN cycles_available IS NOT NULL THEN 1 ELSE 0 END) as cycles_available_filled,
    SUM(CASE WHEN pickup_trucks_available IS NOT NULL THEN 1 ELSE 0 END) as pickup_trucks_available_filled,
    SUM(CASE WHEN bullock_carts_available IS NOT NULL THEN 1 ELSE 0 END) as bullock_carts_available_filled
FROM village_transport
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_ENTERTAINMENT analysis
SELECT
    'village_entertainment' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN smart_mobiles_available IS NOT NULL THEN 1 ELSE 0 END) as smart_mobiles_available_filled,
    SUM(CASE WHEN smart_mobiles_count IS NOT NULL THEN 1 ELSE 0 END) as smart_mobiles_count_filled,
    SUM(CASE WHEN analog_mobiles_available IS NOT NULL THEN 1 ELSE 0 END) as analog_mobiles_available_filled,
    SUM(CASE WHEN analog_mobiles_count IS NOT NULL THEN 1 ELSE 0 END) as analog_mobiles_count_filled,
    SUM(CASE WHEN televisions_available IS NOT NULL THEN 1 ELSE 0 END) as televisions_available_filled,
    SUM(CASE WHEN televisions_count IS NOT NULL THEN 1 ELSE 0 END) as televisions_count_filled,
    SUM(CASE WHEN radios_available IS NOT NULL THEN 1 ELSE 0 END) as radios_available_filled,
    SUM(CASE WHEN radios_count IS NOT NULL THEN 1 ELSE 0 END) as radios_count_filled,
    SUM(CASE WHEN games_available IS NOT NULL THEN 1 ELSE 0 END) as games_available_filled,
    SUM(CASE WHEN other_entertainment IS NOT NULL AND other_entertainment != '' THEN 1 ELSE 0 END) as other_entertainment_filled
FROM village_entertainment
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_MEDICAL_TREATMENT analysis
SELECT
    'village_medical_treatment' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN allopathic_available IS NOT NULL THEN 1 ELSE 0 END) as allopathic_available_filled,
    SUM(CASE WHEN ayurvedic_available IS NOT NULL THEN 1 ELSE 0 END) as ayurvedic_available_filled,
    SUM(CASE WHEN homeopathy_available IS NOT NULL THEN 1 ELSE 0 END) as homeopathy_available_filled,
    SUM(CASE WHEN traditional_available IS NOT NULL THEN 1 ELSE 0 END) as traditional_available_filled,
    SUM(CASE WHEN other_treatment IS NOT NULL AND other_treatment != '' THEN 1 ELSE 0 END) as other_treatment_filled,
    SUM(CASE WHEN preference_order IS NOT NULL AND preference_order != '' THEN 1 ELSE 0 END) as preference_order_filled
FROM village_medical_treatment
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_DISPUTES analysis
SELECT
    'village_disputes' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN family_disputes IS NOT NULL THEN 1 ELSE 0 END) as family_disputes_filled,
    SUM(CASE WHEN family_registered IS NOT NULL THEN 1 ELSE 0 END) as family_registered_filled,
    SUM(CASE WHEN family_period IS NOT NULL AND family_period != '' THEN 1 ELSE 0 END) as family_period_filled,
    SUM(CASE WHEN revenue_disputes IS NOT NULL THEN 1 ELSE 0 END) as revenue_disputes_filled,
    SUM(CASE WHEN revenue_registered IS NOT NULL THEN 1 ELSE 0 END) as revenue_registered_filled,
    SUM(CASE WHEN revenue_period IS NOT NULL AND revenue_period != '' THEN 1 ELSE 0 END) as revenue_period_filled,
    SUM(CASE WHEN criminal_disputes IS NOT NULL THEN 1 ELSE 0 END) as criminal_disputes_filled,
    SUM(CASE WHEN criminal_registered IS NOT NULL THEN 1 ELSE 0 END) as criminal_registered_filled,
    SUM(CASE WHEN criminal_period IS NOT NULL AND criminal_period != '' THEN 1 ELSE 0 END) as criminal_period_filled,
    SUM(CASE WHEN other_disputes IS NOT NULL AND other_disputes != '' THEN 1 ELSE 0 END) as other_disputes_filled,
    SUM(CASE WHEN other_description IS NOT NULL AND other_description != '' THEN 1 ELSE 0 END) as other_description_filled,
    SUM(CASE WHEN other_registered IS NOT NULL THEN 1 ELSE 0 END) as other_registered_filled,
    SUM(CASE WHEN other_period IS NOT NULL AND other_period != '' THEN 1 ELSE 0 END) as other_period_filled
FROM village_disputes
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_EDUCATIONAL_FACILITIES analysis
SELECT
    'village_educational_facilities' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN primary_schools IS NOT NULL THEN 1 ELSE 0 END) as primary_schools_filled,
    SUM(CASE WHEN middle_schools IS NOT NULL THEN 1 ELSE 0 END) as middle_schools_filled,
    SUM(CASE WHEN secondary_schools IS NOT NULL THEN 1 ELSE 0 END) as secondary_schools_filled,
    SUM(CASE WHEN higher_secondary_schools IS NOT NULL THEN 1 ELSE 0 END) as higher_secondary_schools_filled,
    SUM(CASE WHEN anganwadi_centers IS NOT NULL THEN 1 ELSE 0 END) as anganwadi_centers_filled,
    SUM(CASE WHEN skill_development_centers IS NOT NULL THEN 1 ELSE 0 END) as skill_development_centers_filled,
    SUM(CASE WHEN shiksha_guarantee_centers IS NOT NULL THEN 1 ELSE 0 END) as shiksha_guarantee_centers_filled,
    SUM(CASE WHEN other_facility_name IS NOT NULL AND other_facility_name != '' THEN 1 ELSE 0 END) as other_facility_name_filled,
    SUM(CASE WHEN other_facility_count IS NOT NULL THEN 1 ELSE 0 END) as other_facility_count_filled
FROM village_educational_facilities
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_SOCIAL_CONSCIOUSNESS analysis
SELECT
    'village_social_consciousness' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN clothing_purchase_frequency IS NOT NULL AND clothing_purchase_frequency != '' THEN 1 ELSE 0 END) as clothing_purchase_frequency_filled,
    SUM(CASE WHEN food_waste_level IS NOT NULL AND food_waste_level != '' THEN 1 ELSE 0 END) as food_waste_level_filled,
    SUM(CASE WHEN food_waste_amount IS NOT NULL AND food_waste_amount != '' THEN 1 ELSE 0 END) as food_waste_amount_filled,
    SUM(CASE WHEN waste_disposal_method IS NOT NULL AND waste_disposal_method != '' THEN 1 ELSE 0 END) as waste_disposal_method_filled,
    SUM(CASE WHEN waste_segregation IS NOT NULL THEN 1 ELSE 0 END) as waste_segregation_filled,
    SUM(CASE WHEN compost_pit_available IS NOT NULL THEN 1 ELSE 0 END) as compost_pit_available_filled,
    SUM(CASE WHEN toilet_available IS NOT NULL THEN 1 ELSE 0 END) as toilet_available_filled,
    SUM(CASE WHEN toilet_functional IS NOT NULL THEN 1 ELSE 0 END) as toilet_functional_filled,
    SUM(CASE WHEN toilet_soak_pit IS NOT NULL THEN 1 ELSE 0 END) as toilet_soak_pit_filled,
    SUM(CASE WHEN led_lights_used IS NOT NULL THEN 1 ELSE 0 END) as led_lights_used_filled,
    SUM(CASE WHEN devices_turned_off IS NOT NULL THEN 1 ELSE 0 END) as devices_turned_off_filled,
    SUM(CASE WHEN water_leaks_fixed IS NOT NULL THEN 1 ELSE 0 END) as water_leaks_fixed_filled,
    SUM(CASE WHEN plastic_avoidance IS NOT NULL THEN 1 ELSE 0 END) as plastic_avoidance_filled,
    SUM(CASE WHEN family_puja IS NOT NULL THEN 1 ELSE 0 END) as family_puja_filled,
    SUM(CASE WHEN family_meditation IS NOT NULL THEN 1 ELSE 0 END) as family_meditation_filled,
    SUM(CASE WHEN meditation_participants IS NOT NULL AND meditation_participants != '' THEN 1 ELSE 0 END) as meditation_participants_filled,
    SUM(CASE WHEN family_yoga IS NOT NULL THEN 1 ELSE 0 END) as family_yoga_filled,
    SUM(CASE WHEN yoga_participants IS NOT NULL AND yoga_participants != '' THEN 1 ELSE 0 END) as yoga_participants_filled,
    SUM(CASE WHEN community_activities IS NOT NULL THEN 1 ELSE 0 END) as community_activities_filled,
    SUM(CASE WHEN activity_types IS NOT NULL AND activity_types != '' THEN 1 ELSE 0 END) as activity_types_filled,
    SUM(CASE WHEN shram_sadhana IS NOT NULL THEN 1 ELSE 0 END) as shram_sadhana_filled,
    SUM(CASE WHEN shram_participants IS NOT NULL AND shram_participants != '' THEN 1 ELSE 0 END) as shram_participants_filled,
    SUM(CASE WHEN spiritual_discourses IS NOT NULL THEN 1 ELSE 0 END) as spiritual_discourses_filled,
    SUM(CASE WHEN discourse_participants IS NOT NULL AND discourse_participants != '' THEN 1 ELSE 0 END) as discourse_participants_filled,
    SUM(CASE WHEN family_happiness IS NOT NULL AND family_happiness != '' THEN 1 ELSE 0 END) as family_happiness_filled,
    SUM(CASE WHEN happy_members IS NOT NULL AND happy_members != '' THEN 1 ELSE 0 END) as happy_members_filled,
    SUM(CASE WHEN happiness_reasons IS NOT NULL AND happiness_reasons != '' THEN 1 ELSE 0 END) as happiness_reasons_filled,
    SUM(CASE WHEN smoking_prevalence IS NOT NULL AND smoking_prevalence != '' THEN 1 ELSE 0 END) as smoking_prevalence_filled,
    SUM(CASE WHEN drinking_prevalence IS NOT NULL AND drinking_prevalence != '' THEN 1 ELSE 0 END) as drinking_prevalence_filled,
    SUM(CASE WHEN gudka_prevalence IS NOT NULL AND gudka_prevalence != '' THEN 1 ELSE 0 END) as gudka_prevalence_filled,
    SUM(CASE WHEN gambling_prevalence IS NOT NULL AND gambling_prevalence != '' THEN 1 ELSE 0 END) as gambling_prevalence_filled,
    SUM(CASE WHEN tobacco_prevalence IS NOT NULL AND tobacco_prevalence != '' THEN 1 ELSE 0 END) as tobacco_prevalence_filled,
    SUM(CASE WHEN saving_habit IS NOT NULL AND saving_habit != '' THEN 1 ELSE 0 END) as saving_habit_filled,
    SUM(CASE WHEN saving_percentage IS NOT NULL AND saving_percentage != '' THEN 1 ELSE 0 END) as saving_percentage_filled
FROM village_social_consciousness
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_CHILDREN_DATA analysis
SELECT
    'village_children_data' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN births_last_3_years IS NOT NULL THEN 1 ELSE 0 END) as births_last_3_years_filled,
    SUM(CASE WHEN infant_deaths_last_3_years IS NOT NULL THEN 1 ELSE 0 END) as infant_deaths_last_3_years_filled,
    SUM(CASE WHEN malnourished_children IS NOT NULL THEN 1 ELSE 0 END) as malnourished_children_filled,
    SUM(CASE WHEN children_in_school IS NOT NULL THEN 1 ELSE 0 END) as children_in_school_filled
FROM village_children_data
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_BIODIVERSITY_REGISTER analysis
SELECT
    'village_biodiversity_register' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN register_maintained IS NOT NULL THEN 1 ELSE 0 END) as register_maintained_filled,
    SUM(CASE WHEN status IS NOT NULL AND status != '' THEN 1 ELSE 0 END) as status_filled,
    SUM(CASE WHEN details IS NOT NULL AND details != '' THEN 1 ELSE 0 END) as details_filled,
    SUM(CASE WHEN components IS NOT NULL AND components != '' THEN 1 ELSE 0 END) as components_filled,
    SUM(CASE WHEN knowledge IS NOT NULL AND knowledge != '' THEN 1 ELSE 0 END) as knowledge_filled
FROM village_biodiversity_register
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_DRAINAGE_WASTE analysis
SELECT
    'village_drainage_waste' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN earthen_drain IS NOT NULL THEN 1 ELSE 0 END) as earthen_drain_filled,
    SUM(CASE WHEN masonry_drain IS NOT NULL THEN 1 ELSE 0 END) as masonry_drain_filled,
    SUM(CASE WHEN covered_drain IS NOT NULL THEN 1 ELSE 0 END) as covered_drain_filled,
    SUM(CASE WHEN open_channel IS NOT NULL THEN 1 ELSE 0 END) as open_channel_filled,
    SUM(CASE WHEN no_drainage_system IS NOT NULL THEN 1 ELSE 0 END) as no_drainage_system_filled,
    SUM(CASE WHEN drainage_destination IS NOT NULL AND drainage_destination != '' THEN 1 ELSE 0 END) as drainage_destination_filled,
    SUM(CASE WHEN drainage_remarks IS NOT NULL AND drainage_remarks != '' THEN 1 ELSE 0 END) as drainage_remarks_filled,
    SUM(CASE WHEN waste_collected_regularly IS NOT NULL THEN 1 ELSE 0 END) as waste_collected_regularly_filled,
    SUM(CASE WHEN waste_segregated IS NOT NULL THEN 1 ELSE 0 END) as waste_segregated_filled,
    SUM(CASE WHEN waste_remarks IS NOT NULL AND waste_remarks != '' THEN 1 ELSE 0 END) as waste_remarks_filled
FROM village_drainage_waste
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');

-- VILLAGE_UNEMPLOYMENT analysis
SELECT
    'village_unemployment' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN unemployed_youth IS NOT NULL THEN 1 ELSE 0 END) as unemployed_youth_filled,
    SUM(CASE WHEN unemployed_adults IS NOT NULL THEN 1 ELSE 0 END) as unemployed_adults_filled,
    SUM(CASE WHEN total_unemployed IS NOT NULL THEN 1 ELSE 0 END) as total_unemployed_filled
FROM village_unemployment
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_019');
