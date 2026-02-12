-- Safe migration to fix family_survey_sessions primary key and add missing columns
-- This handles foreign key constraints properly

-- Step 1: Add missing columns that SQLite has
ALTER TABLE family_survey_sessions
ADD COLUMN IF NOT EXISTS page_completion_status TEXT DEFAULT '{}',
ADD COLUMN IF NOT EXISTS sync_pending INTEGER DEFAULT 0;

-- Step 1.5: Add missing updated_at column to village_map_points table
ALTER TABLE village_map_points
ADD COLUMN IF NOT EXISTS updated_at TEXT DEFAULT NOW()::TEXT;

-- Step 2: Drop all foreign key constraints that reference family_survey_sessions
-- This is necessary to change the primary key
ALTER TABLE aadhaar_info DROP CONSTRAINT IF EXISTS aadhaar_info_phone_number_fkey;
ALTER TABLE aadhaar_scheme_members DROP CONSTRAINT IF EXISTS aadhaar_scheme_members_phone_number_fkey;
ALTER TABLE agricultural_equipment DROP CONSTRAINT IF EXISTS agricultural_equipment_phone_number_fkey;
ALTER TABLE animals DROP CONSTRAINT IF EXISTS animals_phone_number_fkey;
ALTER TABLE ayushman_card DROP CONSTRAINT IF EXISTS ayushman_card_phone_number_fkey;
ALTER TABLE ayushman_scheme_members DROP CONSTRAINT IF EXISTS ayushman_scheme_members_phone_number_fkey;
ALTER TABLE bank_accounts DROP CONSTRAINT IF EXISTS bank_accounts_phone_number_fkey;
ALTER TABLE child_diseases DROP CONSTRAINT IF EXISTS child_diseases_phone_number_fkey;
ALTER TABLE children_data DROP CONSTRAINT IF EXISTS children_data_phone_number_fkey;
ALTER TABLE crop_productivity DROP CONSTRAINT IF EXISTS crop_productivity_phone_number_fkey;
ALTER TABLE diseases DROP CONSTRAINT IF EXISTS diseases_phone_number_fkey;
ALTER TABLE disputes DROP CONSTRAINT IF EXISTS disputes_phone_number_fkey;
ALTER TABLE drinking_water_sources DROP CONSTRAINT IF EXISTS drinking_water_sources_phone_number_fkey;
ALTER TABLE entertainment_facilities DROP CONSTRAINT IF EXISTS entertainment_facilities_phone_number_fkey;
ALTER TABLE family_id DROP CONSTRAINT IF EXISTS family_id_phone_number_fkey;
ALTER TABLE family_id_scheme_members DROP CONSTRAINT IF EXISTS family_id_scheme_members_phone_number_fkey;
ALTER TABLE family_members DROP CONSTRAINT IF EXISTS family_members_phone_number_fkey;
ALTER TABLE fertilizer_usage DROP CONSTRAINT IF EXISTS fertilizer_usage_phone_number_fkey;
ALTER TABLE folklore_medicine DROP CONSTRAINT IF EXISTS folklore_medicine_phone_number_fkey;
ALTER TABLE fpo_members DROP CONSTRAINT IF EXISTS fpo_members_phone_number_fkey;
ALTER TABLE handicapped_allowance DROP CONSTRAINT IF EXISTS handicapped_allowance_phone_number_fkey;
ALTER TABLE handicapped_scheme_members DROP CONSTRAINT IF EXISTS handicapped_scheme_members_phone_number_fkey;
ALTER TABLE health_programmes DROP CONSTRAINT IF EXISTS health_programmes_phone_number_fkey;
ALTER TABLE house_conditions DROP CONSTRAINT IF EXISTS house_conditions_phone_number_fkey;
ALTER TABLE house_facilities DROP CONSTRAINT IF EXISTS house_facilities_phone_number_fkey;
ALTER TABLE irrigation_facilities DROP CONSTRAINT IF EXISTS irrigation_facilities_phone_number_fkey;
ALTER TABLE land_holding DROP CONSTRAINT IF EXISTS land_holding_phone_number_fkey;
ALTER TABLE malnourished_children_data DROP CONSTRAINT IF EXISTS malnourished_children_data_phone_number_fkey;
ALTER TABLE malnutrition_data DROP CONSTRAINT IF EXISTS malnutrition_data_phone_number_fkey;
ALTER TABLE medical_treatment DROP CONSTRAINT IF EXISTS medical_treatment_phone_number_fkey;
ALTER TABLE merged_govt_schemes DROP CONSTRAINT IF EXISTS merged_govt_schemes_phone_number_fkey;
ALTER TABLE migration_data DROP CONSTRAINT IF EXISTS migration_data_phone_number_fkey;
ALTER TABLE nutritional_garden DROP CONSTRAINT IF EXISTS nutritional_garden_phone_number_fkey;
ALTER TABLE pension_allowance DROP CONSTRAINT IF EXISTS pension_allowance_phone_number_fkey;
ALTER TABLE pension_scheme_members DROP CONSTRAINT IF EXISTS pension_scheme_members_phone_number_fkey;
ALTER TABLE pm_kisan_members DROP CONSTRAINT IF EXISTS pm_kisan_members_phone_number_fkey;
ALTER TABLE pm_kisan_nidhi DROP CONSTRAINT IF EXISTS pm_kisan_nidhi_phone_number_fkey;
ALTER TABLE pm_kisan_samman_members DROP CONSTRAINT IF EXISTS pm_kisan_samman_members_phone_number_fkey;
ALTER TABLE pm_kisan_samman_nidhi DROP CONSTRAINT IF EXISTS pm_kisan_samman_nidhi_phone_number_fkey;
ALTER TABLE ration_card DROP CONSTRAINT IF EXISTS ration_card_phone_number_fkey;
ALTER TABLE ration_scheme_members DROP CONSTRAINT IF EXISTS ration_scheme_members_phone_number_fkey;
ALTER TABLE samagra_id DROP CONSTRAINT IF EXISTS samagra_id_phone_number_fkey;
ALTER TABLE samagra_scheme_members DROP CONSTRAINT IF EXISTS samagra_scheme_members_phone_number_fkey;
ALTER TABLE shg_members DROP CONSTRAINT IF EXISTS shg_members_phone_number_fkey;
ALTER TABLE social_consciousness DROP CONSTRAINT IF EXISTS social_consciousness_phone_number_fkey;
ALTER TABLE training_data DROP CONSTRAINT IF EXISTS training_data_phone_number_fkey;
ALTER TABLE transport_facilities DROP CONSTRAINT IF EXISTS transport_facilities_phone_number_fkey;
ALTER TABLE tribal_card DROP CONSTRAINT IF EXISTS tribal_card_phone_number_fkey;
ALTER TABLE tribal_questions DROP CONSTRAINT IF EXISTS tribal_questions_phone_number_fkey;
ALTER TABLE tribal_scheme_members DROP CONSTRAINT IF EXISTS tribal_scheme_members_phone_number_fkey;
ALTER TABLE tulsi_plants DROP CONSTRAINT IF EXISTS tulsi_plants_phone_number_fkey;
ALTER TABLE vb_gram DROP CONSTRAINT IF EXISTS vb_gram_phone_number_fkey;
ALTER TABLE vb_gram_members DROP CONSTRAINT IF EXISTS vb_gram_members_phone_number_fkey;
ALTER TABLE widow_allowance DROP CONSTRAINT IF EXISTS widow_allowance_phone_number_fkey;
ALTER TABLE widow_scheme_members DROP CONSTRAINT IF EXISTS widow_scheme_members_phone_number_fkey;

-- Step 3: Drop the existing primary key constraint
ALTER TABLE family_survey_sessions DROP CONSTRAINT IF EXISTS family_survey_sessions_pkey;

-- Step 4: Add new primary key constraint on phone_number
ALTER TABLE family_survey_sessions ADD CONSTRAINT family_survey_sessions_pkey PRIMARY KEY (phone_number);

-- Step 5: Drop the id column since we don't need it anymore
ALTER TABLE family_survey_sessions DROP COLUMN IF EXISTS id;

-- Step 6: Recreate all foreign key constraints
ALTER TABLE aadhaar_info ADD CONSTRAINT aadhaar_info_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE aadhaar_scheme_members ADD CONSTRAINT aadhaar_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE agricultural_equipment ADD CONSTRAINT agricultural_equipment_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE animals ADD CONSTRAINT animals_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE ayushman_card ADD CONSTRAINT ayushman_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE ayushman_scheme_members ADD CONSTRAINT ayushman_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE bank_accounts ADD CONSTRAINT bank_accounts_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE child_diseases ADD CONSTRAINT child_diseases_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE children_data ADD CONSTRAINT children_data_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE crop_productivity ADD CONSTRAINT crop_productivity_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE diseases ADD CONSTRAINT diseases_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE disputes ADD CONSTRAINT disputes_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE drinking_water_sources ADD CONSTRAINT drinking_water_sources_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE entertainment_facilities ADD CONSTRAINT entertainment_facilities_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE family_id ADD CONSTRAINT family_id_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE family_id_scheme_members ADD CONSTRAINT family_id_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE family_members ADD CONSTRAINT family_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE fertilizer_usage ADD CONSTRAINT fertilizer_usage_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE folklore_medicine ADD CONSTRAINT folklore_medicine_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE fpo_members ADD CONSTRAINT fpo_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE handicapped_allowance ADD CONSTRAINT handicapped_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE handicapped_scheme_members ADD CONSTRAINT handicapped_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE health_programmes ADD CONSTRAINT health_programmes_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE house_conditions ADD CONSTRAINT house_conditions_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE house_facilities ADD CONSTRAINT house_facilities_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE irrigation_facilities ADD CONSTRAINT irrigation_facilities_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE land_holding ADD CONSTRAINT land_holding_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE malnourished_children_data ADD CONSTRAINT malnourished_children_data_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE malnutrition_data ADD CONSTRAINT malnutrition_data_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE medical_treatment ADD CONSTRAINT medical_treatment_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE merged_govt_schemes ADD CONSTRAINT merged_govt_schemes_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE migration_data ADD CONSTRAINT migration_data_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE nutritional_garden ADD CONSTRAINT nutritional_garden_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE pension_allowance ADD CONSTRAINT pension_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE pension_scheme_members ADD CONSTRAINT pension_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE pm_kisan_members ADD CONSTRAINT pm_kisan_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE pm_kisan_nidhi ADD CONSTRAINT pm_kisan_nidhi_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE pm_kisan_samman_members ADD CONSTRAINT pm_kisan_samman_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE pm_kisan_samman_nidhi ADD CONSTRAINT pm_kisan_samman_nidhi_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE ration_card ADD CONSTRAINT ration_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE ration_scheme_members ADD CONSTRAINT ration_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE samagra_id ADD CONSTRAINT samagra_id_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE samagra_scheme_members ADD CONSTRAINT samagra_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE shg_members ADD CONSTRAINT shg_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE social_consciousness ADD CONSTRAINT social_consciousness_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE training_data ADD CONSTRAINT training_data_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE transport_facilities ADD CONSTRAINT transport_facilities_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE tribal_card ADD CONSTRAINT tribal_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE tribal_questions ADD CONSTRAINT tribal_questions_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE tribal_scheme_members ADD CONSTRAINT tribal_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE tulsi_plants ADD CONSTRAINT tulsi_plants_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE vb_gram ADD CONSTRAINT vb_gram_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE vb_gram_members ADD CONSTRAINT vb_gram_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE widow_allowance ADD CONSTRAINT widow_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;
ALTER TABLE widow_scheme_members ADD CONSTRAINT widow_scheme_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE;

-- Step 7: Verify the migration
SELECT
    'Migration completed successfully' as status,
    COUNT(*) as total_records,
    COUNT(CASE WHEN page_completion_status IS NOT NULL THEN 1 END) as records_with_page_status,
    COUNT(CASE WHEN sync_pending IS NOT NULL THEN 1 END) as records_with_sync_pending
FROM family_survey_sessions;