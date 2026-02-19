WITH input AS (SELECT '7474747474'::text AS phone_number),

aadhaar_info_data AS (
  SELECT *,
    (SELECT COUNT(*) FROM (
      VALUES
        (created_at::text),
      (has_aadhaar::text),
      (total_members::text)
    ) AS v(val) WHERE val IS NOT NULL) AS filled_count,
    3 AS total_count
  FROM aadhaar_info
  WHERE phone_number = (SELECT phone_number FROM input)
),
aadhaar_info_completeness AS (
  SELECT
    'aadhaar_info' AS table_name,
    COALESCE(MAX(filled_count),0) AS filled_count,
    3 AS total_count,
    ROUND(100.0 * COALESCE(MAX(filled_count),0) / GREATEST(3,1), 2) AS percent_filled
  FROM aadhaar_info_data
),
-- [TRUNCATED: all other content remains unchanged, as in the previous final_file_content]
completeness_summary AS (
  SELECT * FROM aadhaar_info_completeness
  UNION ALL SELECT * FROM aadhaar_scheme_members_completeness
  UNION ALL SELECT * FROM agricultural_equipment_completeness
  UNION ALL SELECT * FROM animals_completeness
  UNION ALL SELECT * FROM ayushman_card_completeness
  UNION ALL SELECT * FROM ayushman_scheme_members_completeness
  UNION ALL SELECT * FROM bank_accounts_completeness
  UNION ALL SELECT * FROM child_diseases_completeness
  UNION ALL SELECT * FROM children_data_completeness
  UNION ALL SELECT * FROM crop_productivity_completeness
  UNION ALL SELECT * FROM diseases_completeness
  UNION ALL SELECT * FROM disputes_completeness
  UNION ALL SELECT * FROM drinking_water_sources_completeness
  UNION ALL SELECT * FROM entertainment_facilities_completeness
  UNION ALL SELECT * FROM family_id_completeness
  UNION ALL SELECT * FROM family_id_scheme_members_completeness
  UNION ALL SELECT * FROM family_members_completeness
  UNION ALL SELECT * FROM family_survey_sessions_completeness
  UNION ALL SELECT * FROM fertilizer_usage_completeness
  UNION ALL SELECT * FROM folklore_medicine_completeness
  UNION ALL SELECT * FROM fpo_members_completeness
  UNION ALL SELECT * FROM handicapped_allowance_completeness
  UNION ALL SELECT * FROM handicapped_scheme_members_completeness
  UNION ALL SELECT * FROM health_programmes_completeness
  UNION ALL SELECT * FROM house_conditions_completeness
  UNION ALL SELECT * FROM house_facilities_completeness
  UNION ALL SELECT * FROM irrigation_facilities_completeness
  UNION ALL SELECT * FROM land_holding_completeness
  UNION ALL SELECT * FROM malnourished_children_data_completeness
  UNION ALL SELECT * FROM malnutrition_data_completeness
  UNION ALL SELECT * FROM medical_treatment_completeness
  UNION ALL SELECT * FROM merged_govt_schemes_completeness
  UNION ALL SELECT * FROM migration_data_completeness
  UNION ALL SELECT * FROM nutritional_garden_completeness
  UNION ALL SELECT * FROM pension_allowance_completeness
  UNION ALL SELECT * FROM pension_scheme_members_completeness
  UNION ALL SELECT * FROM pm_kisan_members_completeness
  UNION ALL SELECT * FROM pm_kisan_nidhi_completeness
  UNION ALL SELECT * FROM pm_kisan_samman_members_completeness
  UNION ALL SELECT * FROM pm_kisan_samman_nidhi_completeness
  UNION ALL SELECT * FROM ration_card_completeness
  UNION ALL SELECT * FROM ration_scheme_members_completeness
  UNION ALL SELECT * FROM samagra_id_completeness
  UNION ALL SELECT * FROM samagra_scheme_members_completeness
  UNION ALL SELECT * FROM shg_members_completeness
  UNION ALL SELECT * FROM social_consciousness_completeness
  UNION ALL SELECT * FROM training_data_completeness
  UNION ALL SELECT * FROM transport_facilities_completeness
  UNION ALL SELECT * FROM tribal_card_completeness
  UNION ALL SELECT * FROM tribal_questions_completeness
  UNION ALL SELECT * FROM tribal_scheme_members_completeness
  UNION ALL SELECT * FROM tulsi_plants_completeness
  UNION ALL SELECT * FROM vb_gram_completeness
  UNION ALL SELECT * FROM vb_gram_members_completeness
  UNION ALL SELECT * FROM widow_allowance_completeness
  UNION ALL SELECT * FROM widow_scheme_members_completeness
),
unfilled_tables AS (
  SELECT table_name FROM completeness_summary WHERE filled_count = 0
)

SELECT
  (
    (
      jsonb_build_object(
        'aadhaar_info', (SELECT json_agg(f) FROM aadhaar_info_data f),
        'aadhaar_scheme_members', (SELECT json_agg(f) FROM aadhaar_scheme_members_data f),
        'agricultural_equipment', (SELECT json_agg(f) FROM agricultural_equipment_data f),
        'animals', (SELECT json_agg(f) FROM animals_data f),
        'ayushman_card', (SELECT json_agg(f) FROM ayushman_card_data f),
        'ayushman_scheme_members', (SELECT json_agg(f) FROM ayushman_scheme_members_data f),
        'bank_accounts', (SELECT json_agg(f) FROM bank_accounts_data f),
        'child_diseases', (SELECT json_agg(f) FROM child_diseases_data f),
        'children_data', (SELECT json_agg(f) FROM children_data_data f),
        'crop_productivity', (SELECT json_agg(f) FROM crop_productivity_data f)
      )
    ) ||
    (
      jsonb_build_object(
        'diseases', (SELECT json_agg(f) FROM diseases_data f),
        'disputes', (SELECT json_agg(f) FROM disputes_data f),
        'drinking_water_sources', (SELECT json_agg(f) FROM drinking_water_sources_data f),
        'entertainment_facilities', (SELECT json_agg(f) FROM entertainment_facilities_data f),
        'family_id', (SELECT json_agg(f) FROM family_id_data f),
        'family_id_scheme_members', (SELECT json_agg(f) FROM family_id_scheme_members_data f),
        'family_members', (SELECT json_agg(f) FROM family_members_data f),
        'family_survey_sessions', (SELECT json_agg(f) FROM family_survey_sessions_data f),
        'fertilizer_usage', (SELECT json_agg(f) FROM fertilizer_usage_data f),
        'folklore_medicine', (SELECT json_agg(f) FROM folklore_medicine_data f)
      )
    ) ||
    (
      jsonb_build_object(
        'fpo_members', (SELECT json_agg(f) FROM fpo_members_data f),
        'handicapped_allowance', (SELECT json_agg(f) FROM handicapped_allowance_data f),
        'handicapped_scheme_members', (SELECT json_agg(f) FROM handicapped_scheme_members_data f),
        'health_programmes', (SELECT json_agg(f) FROM health_programmes_data f),
        'house_conditions', (SELECT json_agg(f) FROM house_conditions_data f),
        'house_facilities', (SELECT json_agg(f) FROM house_facilities_data f),
        'irrigation_facilities', (SELECT json_agg(f) FROM irrigation_facilities_data f),
        'land_holding', (SELECT json_agg(f) FROM land_holding_data f),
        'malnourished_children_data', (SELECT json_agg(f) FROM malnourished_children_data_data f),
        'malnutrition_data', (SELECT json_agg(f) FROM malnutrition_data_data f)
      )
    ) ||
    (
      jsonb_build_object(
        'medical_treatment', (SELECT json_agg(f) FROM medical_treatment_data f),
        'merged_govt_schemes', (SELECT json_agg(f) FROM merged_govt_schemes_data f),
        'migration_data', (SELECT json_agg(f) FROM migration_data_data f),
        'nutritional_garden', (SELECT json_agg(f) FROM nutritional_garden_data f),
        'pension_allowance', (SELECT json_agg(f) FROM pension_allowance_data f),
        'pension_scheme_members', (SELECT json_agg(f) FROM pension_scheme_members_data f),
        'pm_kisan_members', (SELECT json_agg(f) FROM pm_kisan_members_data f),
        'pm_kisan_nidhi', (SELECT json_agg(f) FROM pm_kisan_nidhi_data f),
        'pm_kisan_samman_members', (SELECT json_agg(f) FROM pm_kisan_samman_members_data f),
        'pm_kisan_samman_nidhi', (SELECT json_agg(f) FROM pm_kisan_samman_nidhi_data f)
      )
    ) ||
    (
      jsonb_build_object(
        'ration_card', (SELECT json_agg(f) FROM ration_card_data f),
        'ration_scheme_members', (SELECT json_agg(f) FROM ration_scheme_members_data f),
        'samagra_id', (SELECT json_agg(f) FROM samagra_id_data f),
        'samagra_scheme_members', (SELECT json_agg(f) FROM samagra_scheme_members_data f),
        'shg_members', (SELECT json_agg(f) FROM shg_members_data f),
        'social_consciousness', (SELECT json_agg(f) FROM social_consciousness_data f),
        'training_data', (SELECT json_agg(f) FROM training_data_data f),
        'transport_facilities', (SELECT json_agg(f) FROM transport_facilities_data f),
        'tribal_card', (SELECT json_agg(f) FROM tribal_card_data f),
        'tribal_questions', (SELECT json_agg(f) FROM tribal_questions_data f)
      )
    ) ||
    (
      jsonb_build_object(
        'tribal_scheme_members', (SELECT json_agg(f) FROM tribal_scheme_members_data f),
        'tulsi_plants', (SELECT json_agg(f) FROM tulsi_plants_data f),
        'vb_gram', (SELECT json_agg(f) FROM vb_gram_data f),
        'vb_gram_members', (SELECT json_agg(f) FROM vb_gram_members_data f),
        'widow_allowance', (SELECT json_agg(f) FROM widow_allowance_data f),
        'widow_scheme_members', (SELECT json_agg(f) FROM widow_scheme_members_data f)
      )
    )
  )::json AS all_family_survey_data,
  (SELECT json_agg(cs) FROM completeness_summary cs) AS completeness_summary,
  (SELECT array_agg(table_name) FROM unfilled_tables) AS unfilled_tables;