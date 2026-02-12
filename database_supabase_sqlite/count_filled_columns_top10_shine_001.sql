-- Count filled columns for the 10 tables that had data in SHINE_001
-- Tables: village_survey_sessions, village_educational_facilities, village_seed_clubs, village_biodiversity_register, village_signboards, village_social_maps, village_infrastructure, village_infrastructure_details, village_survey_details, village_forest_maps

-- Per-table filled columns
SELECT 'village_survey_sessions' as table_name, COUNT(*) as rows,
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
) as filled_columns, 11 as total_columns
FROM village_survey_sessions WHERE shine_code='SHINE_001'

UNION ALL

SELECT 'village_educational_facilities' as table_name, COUNT(*) as rows,
(
  COALESCE(MAX(CASE WHEN primary_schools IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN middle_schools IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN high_schools IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN colleges IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN anganwadi_centers IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN secondary_schools IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN higher_secondary_schools IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN skill_development_centers IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN shiksha_guarantee_centers IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN other_facility_name IS NOT NULL AND other_facility_name <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN other_facility_count IS NOT NULL THEN 1 ELSE 0 END),0)
) as filled_columns, 11 as total_columns
FROM village_educational_facilities vef WHERE vef.session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

UNION ALL

SELECT 'village_seed_clubs' as table_name, COUNT(*) as rows,
(
  COALESCE(MAX(CASE WHEN total_clubs IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN clubs_available IS NOT NULL THEN 1 ELSE 0 END),0)
) as filled_columns, 2 as total_columns
FROM village_seed_clubs WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

UNION ALL

SELECT 'village_biodiversity_register' as table_name, COUNT(*) as rows,
(
  COALESCE(MAX(CASE WHEN register_maintained IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN status IS NOT NULL AND status <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN details IS NOT NULL AND details <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN components IS NOT NULL AND components <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN knowledge IS NOT NULL AND knowledge <> '' THEN 1 ELSE 0 END),0)
) as filled_columns, 5 as total_columns
FROM village_biodiversity_register WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

UNION ALL

SELECT 'village_signboards' as table_name, COUNT(*) as rows,
(
  COALESCE(MAX(CASE WHEN signboard_type IS NOT NULL AND signboard_type <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN location IS NOT NULL AND location <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN signboards IS NOT NULL AND signboards <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN info_boards IS NOT NULL AND info_boards <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN wall_writing IS NOT NULL AND wall_writing <> '' THEN 1 ELSE 0 END),0)
) as filled_columns, 5 as total_columns
FROM village_signboards WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

UNION ALL

SELECT 'village_social_maps' as table_name, COUNT(*) as rows,
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
) as filled_columns, 9 as total_columns
FROM village_social_maps WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

UNION ALL

SELECT 'village_infrastructure' as table_name, COUNT(*) as rows,
(
  COALESCE(MAX(CASE WHEN approach_roads_available IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN num_approach_roads IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN approach_condition IS NOT NULL AND approach_condition <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN approach_remarks IS NOT NULL AND approach_remarks <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN internal_lanes_available IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN num_internal_lanes IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN internal_condition IS NOT NULL AND internal_condition <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN internal_remarks IS NOT NULL AND internal_remarks <> '' THEN 1 ELSE 0 END),0)
) as filled_columns, 8 as total_columns
FROM village_infrastructure WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

UNION ALL

SELECT 'village_infrastructure_details' as table_name, COUNT(*) as rows,
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
  + COALESCE(MAX(CASE WHEN num_wells IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN num_ponds IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN num_hand_pumps IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN num_tube_wells IS NOT NULL THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN num_tap_water IS NOT NULL THEN 1 ELSE 0 END),0)
) as filled_columns, 30 as total_columns
FROM village_infrastructure_details WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

UNION ALL

SELECT 'village_survey_details' as table_name, COUNT(*) as rows,
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
) as filled_columns, 12 as total_columns
FROM village_survey_details WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

UNION ALL

SELECT 'village_forest_maps' as table_name, COUNT(*) as rows,
(
  COALESCE(MAX(CASE WHEN forest_area IS NOT NULL AND forest_area <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN forest_types IS NOT NULL AND forest_types <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN forest_resources IS NOT NULL AND forest_resources <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN conservation_status IS NOT NULL AND conservation_status <> '' THEN 1 ELSE 0 END),0)
  + COALESCE(MAX(CASE WHEN remarks IS NOT NULL AND remarks <> '' THEN 1 ELSE 0 END),0)
) as filled_columns, 5 as total_columns
FROM village_forest_maps WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

ORDER BY table_name;

-- Totals
SELECT
  SUM(filled_columns) as total_filled_columns,
  SUM(total_columns) as total_columns,
  COUNT(*) as tables_checked,
  SUM(CASE WHEN filled_columns>0 THEN 1 ELSE 0 END) as tables_with_any_data
FROM (
  -- repeat the above per-table query as derived table
  SELECT * FROM (
    -- first select
    SELECT 'village_survey_sessions' as table_name, (
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
    ) as filled_columns, 11 as total_columns
    FROM village_survey_sessions WHERE shine_code='SHINE_001'

    UNION ALL

    SELECT 'village_educational_facilities', (
      COALESCE(MAX(CASE WHEN primary_schools IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN middle_schools IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN high_schools IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN colleges IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN anganwadi_centers IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN secondary_schools IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN higher_secondary_schools IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN skill_development_centers IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN shiksha_guarantee_centers IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN other_facility_name IS NOT NULL AND other_facility_name <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN other_facility_count IS NOT NULL THEN 1 ELSE 0 END),0)
    ), 11 FROM village_educational_facilities WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

    UNION ALL

    SELECT 'village_seed_clubs', (
      COALESCE(MAX(CASE WHEN total_clubs IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN clubs_available IS NOT NULL THEN 1 ELSE 0 END),0)
    ), 2 FROM village_seed_clubs WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

    UNION ALL

    SELECT 'village_biodiversity_register', (
      COALESCE(MAX(CASE WHEN register_maintained IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN status IS NOT NULL AND status <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN details IS NOT NULL AND details <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN components IS NOT NULL AND components <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN knowledge IS NOT NULL AND knowledge <> '' THEN 1 ELSE 0 END),0)
    ),5 FROM village_biodiversity_register WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

    UNION ALL

    SELECT 'village_signboards', (
      COALESCE(MAX(CASE WHEN signboard_type IS NOT NULL AND signboard_type <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN location IS NOT NULL AND location <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN signboards IS NOT NULL AND signboards <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN info_boards IS NOT NULL AND info_boards <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN wall_writing IS NOT NULL AND wall_writing <> '' THEN 1 ELSE 0 END),0)
    ),5 FROM village_signboards WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

    UNION ALL

    SELECT 'village_social_maps', (
      COALESCE(MAX(CASE WHEN map_type IS NOT NULL AND map_type <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN map_data IS NOT NULL AND map_data <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN remarks IS NOT NULL AND remarks <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN topography_file_link IS NOT NULL AND topography_file_link <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN enterprise_file_link IS NOT NULL AND enterprise_file_link <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN village_file_link IS NOT NULL AND village_file_link <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN venn_file_link IS NOT NULL AND venn_file_link <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN transect_file_link IS NOT NULL AND transect_file_link <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN cadastral_file_link IS NOT NULL AND cadastral_file_link <> '' THEN 1 ELSE 0 END),0)
    ),9 FROM village_social_maps WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

    UNION ALL

    SELECT 'village_infrastructure', (
      COALESCE(MAX(CASE WHEN approach_roads_available IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN num_approach_roads IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN approach_condition IS NOT NULL AND approach_condition <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN approach_remarks IS NOT NULL AND approach_remarks <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN internal_lanes_available IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN num_internal_lanes IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN internal_condition IS NOT NULL AND internal_condition <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN internal_remarks IS NOT NULL AND internal_remarks <> '' THEN 1 ELSE 0 END),0)
    ),8 FROM village_infrastructure WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

    UNION ALL

    SELECT 'village_infrastructure_details', (
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
      + COALESCE(MAX(CASE WHEN num_wells IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN num_ponds IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN num_hand_pumps IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN num_tube_wells IS NOT NULL THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN num_tap_water IS NOT NULL THEN 1 ELSE 0 END),0)
    ),30 FROM village_infrastructure_details WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

    UNION ALL

    SELECT 'village_survey_details', (
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
    ),12 FROM village_survey_details WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

    UNION ALL

    SELECT 'village_forest_maps', (
      COALESCE(MAX(CASE WHEN forest_area IS NOT NULL AND forest_area <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN forest_types IS NOT NULL AND forest_types <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN forest_resources IS NOT NULL AND forest_resources <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN conservation_status IS NOT NULL AND conservation_status <> '' THEN 1 ELSE 0 END),0)
      + COALESCE(MAX(CASE WHEN remarks IS NOT NULL AND remarks <> '' THEN 1 ELSE 0 END),0)
    ),5 FROM village_forest_maps WHERE session_id IN (SELECT session_id FROM village_survey_sessions WHERE shine_code='SHINE_001')

  ) t
) final;
