-- ===========================================
-- SUPABASE CLEANUP SCRIPT
-- ===========================================
-- This script drops ALL existing tables to prepare for schema rebuild
-- Execute this in Supabase SQL Editor BEFORE running the rebuild script
-- WARNING: This will delete all data - ensure you have backups if needed

-- Drop Family Survey Tables (CASCADE removes all dependent objects)
DROP TABLE IF EXISTS family_form_history CASCADE;
DROP TABLE IF EXISTS family_members CASCADE;
DROP TABLE IF EXISTS land_holding CASCADE;
DROP TABLE IF EXISTS irrigation_facilities CASCADE;
DROP TABLE IF EXISTS crop_productivity CASCADE;
DROP TABLE IF EXISTS fertilizer_usage CASCADE;
DROP TABLE IF EXISTS animals CASCADE;
DROP TABLE IF EXISTS agricultural_equipment CASCADE;
DROP TABLE IF EXISTS entertainment_facilities CASCADE;
DROP TABLE IF EXISTS transport_facilities CASCADE;
DROP TABLE IF EXISTS drinking_water_sources CASCADE;
DROP TABLE IF EXISTS medical_treatment CASCADE;
DROP TABLE IF EXISTS disputes CASCADE;
DROP TABLE IF EXISTS house_conditions CASCADE;
DROP TABLE IF EXISTS house_facilities CASCADE;
DROP TABLE IF EXISTS diseases CASCADE;
DROP TABLE IF EXISTS folklore_medicine CASCADE;
DROP TABLE IF EXISTS health_programmes CASCADE;
DROP TABLE IF EXISTS beneficiary_programs CASCADE;

-- Government Scheme Tables
DROP TABLE IF EXISTS aadhaar_info CASCADE;
DROP TABLE IF EXISTS aadhaar_members CASCADE;
DROP TABLE IF EXISTS ayushman_card CASCADE;
DROP TABLE IF EXISTS ayushman_members CASCADE;
DROP TABLE IF EXISTS family_id CASCADE;
DROP TABLE IF EXISTS family_id_members CASCADE;
DROP TABLE IF EXISTS ration_card CASCADE;
DROP TABLE IF EXISTS ration_card_members CASCADE;
DROP TABLE IF EXISTS samagra_id CASCADE;
DROP TABLE IF EXISTS samagra_children CASCADE;
DROP TABLE IF EXISTS tribal_card CASCADE;
DROP TABLE IF EXISTS tribal_card_members CASCADE;
DROP TABLE IF EXISTS handicapped_allowance CASCADE;
DROP TABLE IF EXISTS handicapped_members CASCADE;
DROP TABLE IF EXISTS pension_allowance CASCADE;
DROP TABLE IF EXISTS pension_members CASCADE;
DROP TABLE IF EXISTS widow_allowance CASCADE;
DROP TABLE IF EXISTS widow_members CASCADE;
DROP TABLE IF EXISTS vb_gram CASCADE;
DROP TABLE IF EXISTS vb_gram_members CASCADE;
DROP TABLE IF EXISTS pm_kisan_nidhi CASCADE;
DROP TABLE IF EXISTS pm_kisan_members CASCADE;
DROP TABLE IF EXISTS pm_kisan_samman CASCADE;
DROP TABLE IF EXISTS kisan_credit_card CASCADE;
DROP TABLE IF EXISTS swachh_bharat CASCADE;
DROP TABLE IF EXISTS fasal_bima CASCADE;
DROP TABLE IF EXISTS merged_govt_schemes CASCADE;

-- Additional Family Survey Tables
DROP TABLE IF EXISTS social_consciousness CASCADE;
DROP TABLE IF EXISTS training_data CASCADE;
DROP TABLE IF EXISTS self_help_groups CASCADE;
DROP TABLE IF EXISTS fpo_members CASCADE;
DROP TABLE IF EXISTS children_data CASCADE;
DROP TABLE IF EXISTS malnourished_children_data CASCADE;
DROP TABLE IF EXISTS child_diseases CASCADE;
DROP TABLE IF EXISTS migration_data CASCADE;
DROP TABLE IF EXISTS tribal_questions CASCADE;
DROP TABLE IF EXISTS bank_accounts CASCADE;
DROP TABLE IF EXISTS tulsi_plants CASCADE;
DROP TABLE IF EXISTS nutritional_garden CASCADE;
DROP TABLE IF EXISTS malnutrition_data CASCADE;

-- Main Family Survey Session Table (drop last due to FKs)
DROP TABLE IF EXISTS family_survey_sessions CASCADE;

-- Drop Village Survey Tables
DROP TABLE IF EXISTS village_form_history CASCADE;
DROP TABLE IF EXISTS village_population CASCADE;
DROP TABLE IF EXISTS village_farm_families CASCADE;
DROP TABLE IF EXISTS village_housing CASCADE;
DROP TABLE IF EXISTS village_agricultural_implements CASCADE;
DROP TABLE IF EXISTS village_crop_productivity CASCADE;
DROP TABLE IF EXISTS village_animals CASCADE;
DROP TABLE IF EXISTS village_irrigation_facilities CASCADE;
DROP TABLE IF EXISTS village_drinking_water CASCADE;
DROP TABLE IF EXISTS village_transport CASCADE;
DROP TABLE IF EXISTS village_entertainment CASCADE;
DROP TABLE IF EXISTS village_medical_treatment CASCADE;
DROP TABLE IF EXISTS village_disputes CASCADE;
DROP TABLE IF EXISTS village_educational_facilities CASCADE;
DROP TABLE IF EXISTS village_social_consciousness CASCADE;
DROP TABLE IF EXISTS village_children_data CASCADE;
DROP TABLE IF EXISTS village_malnutrition_data CASCADE;
DROP TABLE IF EXISTS village_bpl_families CASCADE;
DROP TABLE IF EXISTS village_kitchen_gardens CASCADE;
DROP TABLE IF EXISTS village_seed_clubs CASCADE;
DROP TABLE IF EXISTS village_biodiversity_register CASCADE;
DROP TABLE IF EXISTS village_traditional_occupations CASCADE;
DROP TABLE IF EXISTS village_drainage_waste CASCADE;
DROP TABLE IF EXISTS village_signboards CASCADE;
DROP TABLE IF EXISTS village_infrastructure CASCADE;
DROP TABLE IF EXISTS village_infrastructure_details CASCADE;
DROP TABLE IF EXISTS village_survey_details CASCADE;
DROP TABLE IF EXISTS village_map_points CASCADE;
DROP TABLE IF EXISTS village_forest_maps CASCADE;
DROP TABLE IF EXISTS village_cadastral_maps CASCADE;
DROP TABLE IF EXISTS village_unemployment CASCADE;
DROP TABLE IF EXISTS village_social_maps CASCADE;
DROP TABLE IF EXISTS village_transport_facilities CASCADE;

-- Main Village Survey Session Table (drop last due to FKs)
DROP TABLE IF EXISTS village_survey_sessions CASCADE;

-- Drop Legacy Tables (if any exist)
DROP TABLE IF EXISTS surveys CASCADE;
DROP TABLE IF EXISTS survey_sessions CASCADE;
DROP TABLE IF EXISTS pending_uploads CASCADE;
DROP TABLE IF EXISTS sync_metadata CASCADE;

-- Verification Query (should return 0 rows)
-- SELECT table_name FROM information_schema.tables 
-- WHERE table_schema = 'public' 
-- AND table_name LIKE '%survey%' OR table_name LIKE '%village%';

-- ✓ All tables dropped successfully
-- Ready for schema rebuild with 01_REBUILD_SUPABASE_SCHEMA.sql
