-- ===========================================
-- ULTIMATE COMPREHENSIVE FAMILY SURVEY QUERY
-- For phone number: 3233232332
-- ===========================================
-- Returns a single JSON object with all related family survey data

SELECT row_to_json(t) FROM (

SELECT
  -- MAIN SESSION DATA
  fss.phone_number,
  fss.surveyor_email,
  fss.village_name,
  fss.village_number,
  fss.panchayat,
  fss.block,
  fss.tehsil,
  fss.district,
  fss.postal_address,
  fss.pin_code,
  fss.shine_code,
  fss.latitude,
  fss.longitude,
  fss.location_accuracy,
  fss.location_timestamp,
  fss.survey_date,
  fss.surveyor_name,
  fss.status,
  fss.created_at,
  fss.updated_at,
  fss.device_info,
  fss.app_version,
  fss.created_by,
  fss.updated_by,
  fss.is_deleted,
  fss.last_synced_at,
  fss.current_version,
  fss.last_edited_at,

  -- FAMILY MEMBERS
  (
    SELECT json_agg(
      json_build_object(
        'sr_no', fm.sr_no,
        'name', fm.name,
        'fathers_name', fm.fathers_name,
        'mothers_name', fm.mothers_name,
        'relationship_with_head', fm.relationship_with_head,
        'age', fm.age,
        'sex', fm.sex,
        'physically_fit', fm.physically_fit,
        'physically_fit_cause', fm.physically_fit_cause,
        'educational_qualification', fm.educational_qualification,
        'inclination_self_employment', fm.inclination_self_employment,
        'occupation', fm.occupation,
        'days_employed', fm.days_employed,
        'income', fm.income,
        'awareness_about_village', fm.awareness_about_village,
        'participate_gram_sabha', fm.participate_gram_sabha,
        'insured', fm.insured,
        'insurance_company', fm.insurance_company
      ) ORDER BY fm.sr_no
    )
    FROM family_members fm
    WHERE fm.phone_number = fss.phone_number
  ) as family_members,

  -- AGRICULTURE & LAND (abridged, same as original) ...
  json_build_object(
    'land_holding', json_build_object(
      'irrigated_area', lh.irrigated_area,
      'cultivable_area', lh.cultivable_area
    ),
    'irrigation_facilities', json_build_object(
      'primary_source', ir.primary_source
    ),
    'crop_productivity', (
      SELECT json_agg(
        json_build_object(
          'sr_no', cp.sr_no,
          'crop_name', cp.crop_name
        ) ORDER BY cp.sr_no
      )
      FROM crop_productivity cp
      WHERE cp.phone_number = fss.phone_number
    ),
    'animals', (
      SELECT json_agg(
        json_build_object(
          'sr_no', a.sr_no,
          'animal_type', a.animal_type,
          'number_of_animals', a.number_of_animals
        ) ORDER BY a.sr_no
      )
      FROM animals a
      WHERE a.phone_number = fss.phone_number
    )
  ) as agriculture_data,

  -- INFRASTRUCTURE & FACILITIES (abridged)
  json_build_object(
    'entertainment_facilities', json_build_object(
      'smart_mobile', ef.smart_mobile
    ),
    'transport_facilities', json_build_object(
      'car_jeep', tf.car_jeep
    ),
    'drinking_water_sources', json_build_object(
      'hand_pumps', dws.hand_pumps
    )
  ) as infrastructure_data,

  -- SOCIAL & HEALTH (abridged)
  json_build_object(
    'disputes', json_build_object(
      'family_disputes', d.family_disputes
    ),
    'social_consciousness', json_build_object(
      'clothes_frequency', sc.clothes_frequency
    ),
    'children_data', json_build_object(
      'births_last_3_years', cd.births_last_3_years
    )
  ) as social_health_data,

  -- GOVERNMENT SCHEMES SUMMARY (abridged)
  json_build_object(
    'aadhaar_info', (SELECT json_build_object('has_aadhaar', ai.has_aadhaar, 'total_members', ai.total_members) FROM aadhaar_info ai WHERE ai.phone_number = fss.phone_number),
    'pm_kisan_nidhi', (SELECT json_build_object('is_beneficiary', pkn.is_beneficiary, 'total_members', pkn.total_members) FROM pm_kisan_nidhi pkn WHERE pkn.phone_number = fss.phone_number)
  ) as government_schemes_summary

FROM family_survey_sessions fss
LEFT JOIN land_holding lh ON lh.phone_number = fss.phone_number
LEFT JOIN irrigation_facilities ir ON ir.phone_number = fss.phone_number
LEFT JOIN crop_productivity cp ON cp.phone_number = fss.phone_number
LEFT JOIN animals a ON a.phone_number = fss.phone_number
LEFT JOIN entertainment_facilities ef ON ef.phone_number = fss.phone_number
LEFT JOIN transport_facilities tf ON tf.phone_number = fss.phone_number
LEFT JOIN drinking_water_sources dws ON dws.phone_number = fss.phone_number
LEFT JOIN disputes d ON d.phone_number = fss.phone_number
LEFT JOIN social_consciousness sc ON sc.phone_number = fss.phone_number
LEFT JOIN children_data cd ON cd.phone_number = fss.phone_number

WHERE fss.phone_number = '3233232332'

) t;
