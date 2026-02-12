-- Count filled JSON keys per survey screen for SHINE_001
WITH s AS (
  SELECT * FROM village_survey_sessions WHERE shine_code = 'SHINE_001' LIMIT 1
)

-- Per-screen counts
SELECT screen, filled_keys, total_keys
FROM (
  SELECT 'session_metadata' AS screen,
    (CASE WHEN s.session_id IS NULL OR s.session_id = '' THEN 0 ELSE 1 END
     + CASE WHEN s.surveyor_email IS NULL OR trim(s.surveyor_email) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.village_name IS NULL OR trim(s.village_name) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.village_code IS NULL OR trim(s.village_code) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.state IS NULL OR trim(s.state) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.district IS NULL OR trim(s.district) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.block IS NULL OR trim(s.block) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.panchayat IS NULL OR trim(s.panchayat) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.tehsil IS NULL OR trim(s.tehsil) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.shine_code IS NULL OR trim(s.shine_code) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.status IS NULL OR trim(s.status) = '' THEN 0 ELSE 1 END
    ) AS filled_keys,
    11 AS total_keys
  FROM s
  UNION ALL
  SELECT 'population_data' AS screen,
    COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.population_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0) AS filled_keys,
    COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.population_data::jsonb)),0) AS total_keys
  FROM s
  UNION ALL
  SELECT 'farm_families_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.farm_families_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.farm_families_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'housing_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.housing_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.housing_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'agricultural_implements_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.agricultural_implements_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.agricultural_implements_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'crop_productivity_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.crop_productivity_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.crop_productivity_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'animals_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.animals_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.animals_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'irrigation_facilities_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.irrigation_facilities_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.irrigation_facilities_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'drinking_water_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.drinking_water_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.drinking_water_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'transport_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.transport_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.transport_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'entertainment_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.entertainment_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.entertainment_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'medical_treatment_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.medical_treatment_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.medical_treatment_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'disputes_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.disputes_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.disputes_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'educational_facilities_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.educational_facilities_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.educational_facilities_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'social_consciousness_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.social_consciousness_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.social_consciousness_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'children_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.children_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.children_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'malnutrition_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.malnutrition_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.malnutrition_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'bpl_families_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.bpl_families_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.bpl_families_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'kitchen_gardens_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.kitchen_gardens_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.kitchen_gardens_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'seed_clubs_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.seed_clubs_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.seed_clubs_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'biodiversity_register_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.biodiversity_register_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.biodiversity_register_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'traditional_occupations_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.traditional_occupations_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.traditional_occupations_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'drainage_waste_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.drainage_waste_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.drainage_waste_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'signboards_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.signboards_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.signboards_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'unemployment_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.unemployment_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.unemployment_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'social_maps_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.social_maps_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.social_maps_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'transport_facilities_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.transport_facilities_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.transport_facilities_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'infrastructure_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.infrastructure_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.infrastructure_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'infrastructure_details_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.infrastructure_details_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.infrastructure_details_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'survey_details_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.survey_details_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.survey_details_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'map_points_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.map_points_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.map_points_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'forest_maps_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.forest_maps_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.forest_maps_data::jsonb)),0) FROM s
  UNION ALL
  SELECT 'cadastral_maps_data', COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.cadastral_maps_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.cadastral_maps_data::jsonb)),0) FROM s
) x
ORDER BY screen;

-- Totals summary

WITH per AS (
  WITH s AS (SELECT * FROM village_survey_sessions WHERE shine_code = 'SHINE_001' LIMIT 1)
  SELECT  (CASE WHEN s.session_id IS NULL OR s.session_id = '' THEN 0 ELSE 1 END
     + CASE WHEN s.surveyor_email IS NULL OR trim(s.surveyor_email) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.village_name IS NULL OR trim(s.village_name) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.village_code IS NULL OR trim(s.village_code) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.state IS NULL OR trim(s.state) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.district IS NULL OR trim(s.district) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.block IS NULL OR trim(s.block) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.panchayat IS NULL OR trim(s.panchayat) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.tehsil IS NULL OR trim(s.tehsil) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.shine_code IS NULL OR trim(s.shine_code) = '' THEN 0 ELSE 1 END
     + CASE WHEN s.status IS NULL OR trim(s.status) = '' THEN 0 ELSE 1 END
    ) AS filled_keys, 11 as total_keys FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.population_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.population_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.farm_families_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.farm_families_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.housing_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.housing_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.agricultural_implements_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.agricultural_implements_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.crop_productivity_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.crop_productivity_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.animals_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.animals_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.irrigation_facilities_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.irrigation_facilities_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.drinking_water_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.drinking_water_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.transport_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.transport_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.entertainment_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.entertainment_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.medical_treatment_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.medical_treatment_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.disputes_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.disputes_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.educational_facilities_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.educational_facilities_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.social_consciousness_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.social_consciousness_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.children_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.children_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.malnutrition_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.malnutrition_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.bpl_families_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.bpl_families_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.kitchen_gardens_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.kitchen_gardens_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.seed_clubs_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.seed_clubs_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.biodiversity_register_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.biodiversity_register_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.traditional_occupations_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.traditional_occupations_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.drainage_waste_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.drainage_waste_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.signboards_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.signboards_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.unemployment_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.unemployment_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.social_maps_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.social_maps_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.transport_facilities_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.transport_facilities_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.infrastructure_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.infrastructure_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.infrastructure_details_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.infrastructure_details_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.survey_details_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.survey_details_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.map_points_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.map_points_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.forest_maps_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.forest_maps_data::jsonb)),0) FROM s
  UNION ALL
  SELECT COALESCE((SELECT COUNT(*) FROM jsonb_each_text(s.cadastral_maps_data::jsonb) t WHERE t.value IS NOT NULL AND trim(t.value) <> ''),0), COALESCE((SELECT COUNT(*) FROM jsonb_object_keys(s.cadastral_maps_data::jsonb)),0) FROM s
)
SELECT
  SUM(filled_keys) AS filled_keys_total,
  SUM(total_keys) AS total_keys_total,
  COUNT(*) AS total_screens,
  COUNT(*) FILTER (WHERE filled_keys > 0) AS screens_with_data
FROM per;
