-- Delete script for cleaning up users data
-- Targets: mr.shaurya25@gmail.com and liberlismtor@gmail.com
-- This script manually cascades deletions to all related tables because strict ON DELETE CASCADE might not be enabled on all relationships.

BEGIN;

-- 1. Identify Family Survey Sessions (Phone Numbers) to delete
CREATE TEMP TABLE temp_phones_to_delete AS
SELECT phone_number FROM public.family_survey_sessions
WHERE surveyor_email IN ('mr.shaurya25@gmail.com', 'liberlismtor@gmail.com');

-- 2. Identify Village Survey Sessions (Session IDs) to delete
CREATE TEMP TABLE temp_sessions_to_delete AS
SELECT session_id FROM public.village_survey_sessions
WHERE surveyor_email IN ('mr.shaurya25@gmail.com', 'liberlismtor@gmail.com');


-- 3. Delete from Family Survey Dependent Tables (using temp_phones_to_delete)
DELETE FROM public.aadhaar_info WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.aadhaar_scheme_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.agricultural_equipment WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.animals WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.ayushman_card WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.ayushman_scheme_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.bank_accounts WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.child_diseases WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
-- DELETE FROM public.children_data WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete); -- Check if this table uses phone_number
DELETE FROM public.family_id WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.family_id_scheme_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.family_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.fertilizer_usage WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.folklore_medicine WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.fpo_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.handicapped_allowance WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.handicapped_scheme_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.health_programmes WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.house_conditions WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.house_facilities WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.irrigation_facilities WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.land_holding WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.malnourished_children_data WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.medical_treatment WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.merged_govt_schemes WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.migration_data WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.nutritional_garden WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.pension_allowance WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.pension_scheme_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.pm_kisan_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.pm_kisan_nidhi WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.pm_kisan_samman_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.pm_kisan_samman_nidhi WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.ration_card WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.ration_scheme_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.samagra_id WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.samagra_scheme_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.shg_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.social_consciousness WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.training_data WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.training_needs WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.transport_facilities WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.tribal_card WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.tribal_questions WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.tribal_scheme_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.tulsi_plants WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.vb_gram WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.vb_gram_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.widow_allowance WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);
DELETE FROM public.widow_scheme_members WHERE phone_number IN (SELECT phone_number FROM temp_phones_to_delete);


-- 4. Delete from Village Survey Dependent Tables (using temp_sessions_to_delete)
DELETE FROM public.village_agricultural_implements WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_animals WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_biodiversity_register WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_bpl_families WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_cadastral_maps WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_children_data WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_crop_productivity WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_disputes WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_drainage_waste WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_drinking_water WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_educational_facilities WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_entertainment WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_farm_families WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_forest_maps WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_housing WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_infrastructure WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_infrastructure_details WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_irrigation_facilities WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_kitchen_gardens WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_malnutrition_data WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_map_points WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_medical_treatment WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_population WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_seed_clubs WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_signboards WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_social_consciousness WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_social_maps WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_survey_details WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_traditional_occupations WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_transport WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_transport_facilities WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);
DELETE FROM public.village_unemployment WHERE session_id IN (SELECT session_id FROM temp_sessions_to_delete);


-- 5. Delete the User Sessions from Main Tables
DELETE FROM public.family_survey_sessions WHERE surveyor_email IN ('mr.shaurya25@gmail.com', 'liberlismtor@gmail.com');
DELETE FROM public.village_survey_sessions WHERE surveyor_email IN ('mr.shaurya25@gmail.com', 'liberlismtor@gmail.com');

-- 6. Cleanup Temporary Tables
DROP TABLE temp_phones_to_delete;
DROP TABLE temp_sessions_to_delete;

COMMIT;
