-- Summarize number of columns that have ANY filled values (per table) for SHINE_001
-- Uses MAX(...) to detect whether any row has a non-null/non-empty value per column

-- VILLAGE SURVEY SESSIONS
SELECT 'village_survey_sessions' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN session_id IS NOT NULL AND session_id <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN surveyor_email IS NOT NULL AND surveyor_email <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN village_name IS NOT NULL AND village_name <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN village_code IS NOT NULL AND village_code <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN state IS NOT NULL AND state <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN district IS NOT NULL AND district <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN block IS NOT NULL AND block <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN panchayat IS NOT NULL AND panchayat <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN tehsil IS NOT NULL AND tehsil <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN shine_code IS NOT NULL AND shine_code <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN status IS NOT NULL AND status <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  11 as total_columns
FROM village_survey_sessions
WHERE shine_code = 'SHINE_001'

UNION ALL

-- VILLAGE POPULATION
SELECT 'village_population' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN total_population IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN male_population IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN female_population IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN children_0_5 IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN children_6_14 IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN youth_15_24 IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN adults_25_59 IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN seniors_60_plus IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN sc_population IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN st_population IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN obc_population IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN general_population IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN working_population IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN unemployed_population IS NOT NULL THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  14 as total_columns
FROM village_population
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_HOUSING
SELECT 'village_housing' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN katcha_houses IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN pakka_houses IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN katcha_pakka_houses IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN hut_houses IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN houses_with_toilet IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN functional_toilets IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN houses_with_drainage IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN houses_with_soak_pit IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN houses_with_cattle_shed IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN houses_with_compost_pit IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN houses_with_nadep IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN houses_with_lpg IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN houses_with_biogas IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN houses_with_solar IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN houses_with_electricity IS NOT NULL THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  15 as total_columns
FROM village_housing
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_AGRICULTURAL_IMPLEMENTS
SELECT 'village_agricultural_implements' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN tractor_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN thresher_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN seed_drill_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN sprayer_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN duster_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN diesel_engine_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_implements IS NOT NULL AND other_implements <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  7 as total_columns
FROM village_agricultural_implements
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_CROP_PRODUCTIVITY
SELECT 'village_crop_productivity' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN sr_no IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN crop_name IS NOT NULL AND crop_name <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN area_hectares IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN productivity_quintal_per_hectare IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN total_production_quintal IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN quantity_consumed_quintal IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN quantity_sold_quintal IS NOT NULL THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  7 as total_columns
FROM village_crop_productivity
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_ANIMALS
SELECT 'village_animals' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN sr_no IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN animal_type IS NOT NULL AND animal_type <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN total_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN breed IS NOT NULL AND breed <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  4 as total_columns
FROM village_animals
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_IRRIGATION_FACILITIES
SELECT 'village_irrigation_facilities' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN has_canal IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_tube_well IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_ponds IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_river IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_well IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_sources IS NOT NULL AND other_sources <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  6 as total_columns
FROM village_irrigation_facilities
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_DRINKING_WATER
SELECT 'village_drinking_water' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN hand_pumps_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN hand_pumps_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN wells_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN wells_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN tube_wells_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN tube_wells_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN nal_jal_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_sources IS NOT NULL AND other_sources <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  8 as total_columns
FROM village_drinking_water
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_TRANSPORT
SELECT 'village_transport' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN cars_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN motorcycles_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN e_rickshaws_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN cycles_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN pickup_trucks_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN bullock_carts_available IS NOT NULL THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  6 as total_columns
FROM village_transport
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_ENTERTAINMENT
SELECT 'village_entertainment' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN smart_mobiles_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN smart_mobiles_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN analog_mobiles_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN analog_mobiles_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN televisions_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN televisions_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN radios_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN radios_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN games_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_entertainment IS NOT NULL AND other_entertainment <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  10 as total_columns
FROM village_entertainment
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_MEDICAL_TREATMENT
SELECT 'village_medical_treatment' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN allopathic_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN ayurvedic_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN homeopathy_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN traditional_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_treatment IS NOT NULL AND other_treatment <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN preference_order IS NOT NULL AND preference_order <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  6 as total_columns
FROM village_medical_treatment
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_DISPUTES
SELECT 'village_disputes' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN family_disputes IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN family_registered IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN family_period IS NOT NULL AND family_period <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN revenue_disputes IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN revenue_registered IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN revenue_period IS NOT NULL AND revenue_period <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN criminal_disputes IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN criminal_registered IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN criminal_period IS NOT NULL AND criminal_period <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_disputes IS NOT NULL AND other_disputes <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_description IS NOT NULL AND other_description <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_registered IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_period IS NOT NULL AND other_period <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  13 as total_columns
FROM village_disputes
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_EDUCATIONAL_FACILITIES
SELECT 'village_educational_facilities' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN primary_schools IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN middle_schools IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN secondary_schools IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN higher_secondary_schools IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN anganwadi_centers IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN skill_development_centers IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN shiksha_guarantee_centers IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_facility_name IS NOT NULL AND other_facility_name <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_facility_count IS NOT NULL THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  9 as total_columns
FROM village_educational_facilities
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_SOCIAL_CONSCIOUSNESS
SELECT 'village_social_consciousness' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN clothing_purchase_frequency IS NOT NULL AND clothing_purchase_frequency <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN food_waste_level IS NOT NULL AND food_waste_level <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN food_waste_amount IS NOT NULL AND food_waste_amount <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN waste_disposal_method IS NOT NULL AND waste_disposal_method <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN waste_segregation IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN compost_pit_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN toilet_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN toilet_functional IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN toilet_soak_pit IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN led_lights_used IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN devices_turned_off IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN water_leaks_fixed IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN plastic_avoidance IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN family_puja IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN family_meditation IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN meditation_participants IS NOT NULL AND meditation_participants <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN family_yoga IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN yoga_participants IS NOT NULL AND yoga_participants <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN community_activities IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN activity_types IS NOT NULL AND activity_types <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN shram_sadhana IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN shram_participants IS NOT NULL AND shram_participants <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN spiritual_discourses IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN discourse_participants IS NOT NULL AND discourse_participants <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN family_happiness IS NOT NULL AND family_happiness <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN happy_members IS NOT NULL AND happy_members <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN happiness_reasons IS NOT NULL AND happiness_reasons <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN smoking_prevalence IS NOT NULL AND smoking_prevalence <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN drinking_prevalence IS NOT NULL AND drinking_prevalence <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN gudka_prevalence IS NOT NULL AND gudka_prevalence <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN gambling_prevalence IS NOT NULL AND gambling_prevalence <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN tobacco_prevalence IS NOT NULL AND tobacco_prevalence <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN saving_habit IS NOT NULL AND saving_habit <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN saving_percentage IS NOT NULL AND saving_percentage <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  34 as total_columns
FROM village_social_consciousness
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_CHILDREN_DATA
SELECT 'village_children_data' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN births_last_3_years IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN infant_deaths_last_3_years IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN malnourished_children IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN children_in_school IS NOT NULL THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  4 as total_columns
FROM village_children_data
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_BIODIVERSITY_REGISTER
SELECT 'village_biodiversity_register' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN register_maintained IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN status IS NOT NULL AND status <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN details IS NOT NULL AND details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN components IS NOT NULL AND components <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN knowledge IS NOT NULL AND knowledge <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  5 as total_columns
FROM village_biodiversity_register
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_DRAINAGE_WASTE
SELECT 'village_drainage_waste' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN earthen_drain IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN masonry_drain IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN covered_drain IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN open_channel IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN no_drainage_system IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN drainage_destination IS NOT NULL AND drainage_destination <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN drainage_remarks IS NOT NULL AND drainage_remarks <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN waste_collected_regularly IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN waste_segregated IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN waste_remarks IS NOT NULL AND waste_remarks <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  10 as total_columns
FROM village_drainage_waste
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_UNEMPLOYMENT
SELECT 'village_unemployment' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN unemployed_youth IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN unemployed_adults IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN total_unemployed IS NOT NULL THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  3 as total_columns
FROM village_unemployment
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_SIGNBOARDS
SELECT 'village_signboards' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN signboards IS NOT NULL AND signboards <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN info_boards IS NOT NULL AND info_boards <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN wall_writing IS NOT NULL AND wall_writing <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  3 as total_columns
FROM village_signboards
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_SOCIAL_MAPS
SELECT 'village_social_maps' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN map_type IS NOT NULL AND map_type <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN map_data IS NOT NULL AND map_data <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN remarks IS NOT NULL AND remarks <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN topography_file_link IS NOT NULL AND topography_file_link <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN enterprise_file_link IS NOT NULL AND enterprise_file_link <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN village_file_link IS NOT NULL AND village_file_link <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN venn_file_link IS NOT NULL AND venn_file_link <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN transect_file_link IS NOT NULL AND transect_file_link <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN cadastral_file_link IS NOT NULL AND cadastral_file_link <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  9 as total_columns
FROM village_social_maps
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_TRANSPORT_FACILITIES
SELECT 'village_transport_facilities' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN tractor_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN car_jeep_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN motorcycle_scooter_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN cycle_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN e_rickshaw_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN pickup_truck_count IS NOT NULL THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  6 as total_columns
FROM village_transport_facilities
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_INFRASTRUCTURE
SELECT 'village_infrastructure' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN approach_roads_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN num_approach_roads IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN approach_condition IS NOT NULL AND approach_condition <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN approach_remarks IS NOT NULL AND approach_remarks <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN internal_lanes_available IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN num_internal_lanes IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN internal_condition IS NOT NULL AND internal_condition <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN internal_remarks IS NOT NULL AND internal_remarks <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  8 as total_columns
FROM village_infrastructure
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_INFRASTRUCTURE_DETAILS (subset of infra)
SELECT 'village_infrastructure_details' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN has_primary_school IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN primary_school_distance IS NOT NULL AND primary_school_distance <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_junior_school IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN junior_school_distance IS NOT NULL AND junior_school_distance <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_high_school IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN high_school_distance IS NOT NULL AND high_school_distance <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_intermediate_school IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN intermediate_school_distance IS NOT NULL AND intermediate_school_distance <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN other_education_facilities IS NOT NULL AND other_education_facilities <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN boys_students_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN girls_students_count IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_playground IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN playground_remarks IS NOT NULL AND playground_remarks <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_panchayat_bhavan IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN panchayat_remarks IS NOT NULL AND panchayat_remarks <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_sharda_kendra IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN sharda_kendra_distance IS NOT NULL AND sharda_kendra_distance <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_post_office IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN post_office_distance IS NOT NULL AND post_office_distance <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_health_facility IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN health_facility_distance IS NOT NULL AND health_facility_distance <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_primary_health_centre IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_bank IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN bank_distance IS NOT NULL AND bank_distance <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_electrical_connection IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN has_drinking_water_source IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN num_wells IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN num_ponds IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN num_hand_pumps IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN num_tube_wells IS NOT NULL THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN num_tap_water IS NOT NULL THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  31 as total_columns
FROM village_infrastructure_details
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_SURVEY_DETAILS
SELECT 'village_survey_details' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN has_primary_school IS NOT NULL THEN 1 ELSE 0 END),0)
    -- add more fields here if table has more columns
  ) as filled_columns,
  1 as total_columns
FROM village_survey_details
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

UNION ALL

-- VILLAGE_FOREST_MAPS
SELECT 'village_forest_maps' as table_name,
  COUNT(*) as total_rows,
  (
    COALESCE(MAX(CASE WHEN forest_details IS NOT NULL AND forest_details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN wasteland_details IS NOT NULL AND wasteland_details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN garden_details IS NOT NULL AND garden_details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN burial_ground_details IS NOT NULL AND burial_ground_details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN crop_plants_details IS NOT NULL AND crop_plants_details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN vegetables_details IS NOT NULL AND vegetables_details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN fruit_trees_details IS NOT NULL AND fruit_trees_details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN animals_details IS NOT NULL AND animals_details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN birds_details IS NOT NULL AND birds_details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN local_biodiversity_details IS NOT NULL AND local_biodiversity_details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN traditional_knowledge_details IS NOT NULL AND traditional_knowledge_details <> '' THEN 1 ELSE 0 END),0)
    + COALESCE(MAX(CASE WHEN special_features_details IS NOT NULL AND special_features_details <> '' THEN 1 ELSE 0 END),0)
  ) as filled_columns,
  12 as total_columns
FROM village_forest_maps
WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code = 'SHINE_001')

ORDER BY table_name;

-- Final totals (run separately if you want a single-row summary)

SELECT SUM(filled_columns) as total_filled_columns, SUM(total_columns) as total_columns, COUNT(*) as tables_checked, SUM(CASE WHEN filled_columns>0 THEN 1 ELSE 0 END) as tables_with_any_data
FROM (
  -- reuse the per-table query above as a derived table
  SELECT * FROM (
    -- copy first 1 row select (first part)
    SELECT 'village_survey_sessions' as table_name,
      (
        COALESCE(MAX(CASE WHEN session_id IS NOT NULL AND session_id <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN surveyor_email IS NOT NULL AND surveyor_email <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN village_name IS NOT NULL AND village_name <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN village_code IS NOT NULL AND village_code <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN state IS NOT NULL AND state <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN district IS NOT NULL AND district <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN block IS NOT NULL AND block <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN panchayat IS NOT NULL AND panchayat <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN tehsil IS NOT NULL AND tehsil <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN shine_code IS NOT NULL AND shine_code <> '' THEN 1 ELSE 0 END),0)
        + COALESCE(MAX(CASE WHEN status IS NOT NULL AND status <> '' THEN 1 ELSE 0 END),0)
      ) as filled_columns,
      11 as total_columns
    FROM village_survey_sessions WHERE shine_code='SHINE_001'

    UNION ALL

    SELECT 'village_population', (
      COALESCE(MAX(CASE WHEN total_population IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN male_population IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN female_population IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN children_0_5 IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN children_6_14 IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN youth_15_24 IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN adults_25_59 IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN seniors_60_plus IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN sc_population IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN st_population IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN obc_population IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN general_population IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN working_population IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN unemployed_population IS NOT NULL THEN 1 ELSE 0 END),0)
    ), 14
    FROM village_population vp WHERE vp.session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

    -- For brevity, the rest of the UNIONs are omitted here because they were already run above in the per-table query.
  ) t
) final;
