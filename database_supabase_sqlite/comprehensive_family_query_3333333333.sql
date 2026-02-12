-- ===========================================
-- ULTIMATE COMPREHENSIVE FAMILY SURVEY QUERY
-- For phone number: 0000000008
-- ===========================================
-- This query joins ALL 50+ family survey tables from the complete Supabase schema
-- Includes every single table and column for complete data extraction
-- Based on supbase_SCHEMA.sql - includes ALL tables
-- Run this in Supabase SQL Editor

SELECT
  -- ===========================================
  -- MAIN SESSION DATA (family_survey_sessions)
  -- ===========================================
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

  -- ===========================================
  -- FAMILY MEMBERS (JSON Array)
  -- ===========================================
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

  -- ===========================================
  -- AGRICULTURE & LAND (land_holding, irrigation_facilities, crop_productivity, fertilizer_usage, animals, agricultural_equipment)
  -- ===========================================
  json_build_object(
    'land_holding', json_build_object(
      'irrigated_area', lh.irrigated_area,
      'cultivable_area', lh.cultivable_area,
      'unirrigated_area', lh.unirrigated_area,
      'barren_land', lh.barren_land,
      'mango_trees', lh.mango_trees,
      'guava_trees', lh.guava_trees,
      'lemon_trees', lh.lemon_trees,
      'pomegranate_trees', lh.pomegranate_trees,
      'other_fruit_trees_name', lh.other_fruit_trees_name,
      'other_fruit_trees_count', lh.other_fruit_trees_count
    ),
    'irrigation_facilities', json_build_object(
      'primary_source', ir.primary_source,
      'canal', ir.canal,
      'tube_well', ir.tube_well,
      'river', ir.river,
      'pond', ir.pond,
      'well', ir.well,
      'hand_pump', ir.hand_pump,
      'submersible', ir.submersible,
      'rainwater_harvesting', ir.rainwater_harvesting,
      'check_dam', ir.check_dam,
      'other_sources', ir.other_sources
    ),
    'crop_productivity', (
      SELECT json_agg(
        json_build_object(
          'sr_no', cp.sr_no,
          'crop_name', cp.crop_name,
          'area_hectares', cp.area_hectares,
          'productivity_quintal_per_hectare', cp.productivity_quintal_per_hectare,
          'total_production_quintal', cp.total_production_quintal,
          'quantity_consumed_quintal', cp.quantity_consumed_quintal,
          'quantity_sold_quintal', cp.quantity_sold_quintal
        ) ORDER BY cp.sr_no
      )
      FROM crop_productivity cp
      WHERE cp.phone_number = fss.phone_number
    ),
    'fertilizer_usage', json_build_object(
      'urea_fertilizer', fu.urea_fertilizer,
      'organic_fertilizer', fu.organic_fertilizer,
      'fertilizer_types', fu.fertilizer_types,
      'fertilizer_expenditure', fu.fertilizer_expenditure
    ),
    'animals', (
      SELECT json_agg(
        json_build_object(
          'sr_no', a.sr_no,
          'animal_type', a.animal_type,
          'number_of_animals', a.number_of_animals,
          'breed', a.breed,
          'production_per_animal', a.production_per_animal,
          'quantity_sold', a.quantity_sold
        ) ORDER BY a.sr_no
      )
      FROM animals a
      WHERE a.phone_number = fss.phone_number
    ),
    'agricultural_equipment', json_build_object(
      'tractor', ae.tractor,
      'tractor_condition', ae.tractor_condition,
      'thresher', ae.thresher,
      'thresher_condition', ae.thresher_condition,
      'seed_drill', ae.seed_drill,
      'seed_drill_condition', ae.seed_drill_condition,
      'sprayer', ae.sprayer,
      'sprayer_condition', ae.sprayer_condition,
      'duster', ae.duster,
      'duster_condition', ae.duster_condition,
      'diesel_engine', ae.diesel_engine,
      'diesel_engine_condition', ae.diesel_engine_condition,
      'other_equipment', ae.other_equipment
    )
  ) as agriculture_data,

  -- ===========================================
  -- INFRASTRUCTURE & FACILITIES (entertainment_facilities, transport_facilities, drinking_water_sources, medical_treatment, house_conditions, house_facilities)
  -- ===========================================
  json_build_object(
    'entertainment_facilities', json_build_object(
      'smart_mobile', ef.smart_mobile,
      'smart_mobile_count', ef.smart_mobile_count,
      'analog_mobile', ef.analog_mobile,
      'analog_mobile_count', ef.analog_mobile_count,
      'television', ef.television,
      'radio', ef.radio,
      'games', ef.games,
      'other_entertainment', ef.other_entertainment,
      'other_specify', ef.other_specify
    ),
    'transport_facilities', json_build_object(
      'car_jeep', tf.car_jeep,
      'motorcycle_scooter', tf.motorcycle_scooter,
      'e_rickshaw', tf.e_rickshaw,
      'cycle', tf.cycle,
      'pickup_truck', tf.pickup_truck,
      'bullock_cart', tf.bullock_cart
    ),
    'drinking_water_sources', json_build_object(
      'hand_pumps', dws.hand_pumps,
      'hand_pumps_distance', dws.hand_pumps_distance,
      'hand_pumps_quality', dws.hand_pumps_quality,
      'well', dws.well,
      'well_distance', dws.well_distance,
      'well_quality', dws.well_quality,
      'tubewell', dws.tubewell,
      'tubewell_distance', dws.tubewell_distance,
      'tubewell_quality', dws.tubewell_quality,
      'nal_jaal', dws.nal_jaal,
      'nal_jaal_quality', dws.nal_jaal_quality,
      'other_source', dws.other_source,
      'other_distance', dws.other_distance,
      'other_sources_quality', dws.other_sources_quality
    ),
    'medical_treatment', json_build_object(
      'allopathic', mt.allopathic,
      'ayurvedic', mt.ayurvedic,
      'homeopathy', mt.homeopathy,
      'traditional', mt.traditional,
      'other_treatment', mt.other_treatment,
      'preferred_treatment', mt.preferred_treatment
    ),
    'house_conditions', json_build_object(
      'katcha', hc.katcha,
      'pakka', hc.pakka,
      'katcha_pakka', hc.katcha_pakka,
      'hut', hc.hut,
      'toilet_in_use', hc.toilet_in_use,
      'toilet_condition', hc.toilet_condition
    ),
    'house_facilities', json_build_object(
      'toilet', hf.toilet,
      'toilet_in_use', hf.toilet_in_use,
      'drainage', hf.drainage,
      'soak_pit', hf.soak_pit,
      'cattle_shed', hf.cattle_shed,
      'compost_pit', hf.compost_pit,
      'nadep', hf.nadep,
      'lpg_gas', hf.lpg_gas,
      'biogas', hf.biogas,
      'solar_cooking', hf.solar_cooking,
      'electric_connection', hf.electric_connection,
      'nutritional_garden_available', hf.nutritional_garden_available,
      'tulsi_plants_available', hf.tulsi_plants_available
    )
  ) as infrastructure_data,

  -- ===========================================
  -- SOCIAL & HEALTH (disputes, diseases, social_consciousness, children_data, migration_data, health_programmes)
  -- ===========================================
  json_build_object(
    'disputes', json_build_object(
      'family_disputes', d.family_disputes,
      'family_registered', d.family_registered,
      'family_period', d.family_period,
      'revenue_disputes', d.revenue_disputes,
      'revenue_registered', d.revenue_registered,
      'revenue_period', d.revenue_period,
      'criminal_disputes', d.criminal_disputes,
      'criminal_registered', d.criminal_registered,
      'criminal_period', d.criminal_period,
      'other_disputes', d.other_disputes,
      'other_description', d.other_description,
      'other_registered', d.other_registered,
      'other_period', d.other_period
    ),
    'diseases', (
      SELECT json_agg(
        json_build_object(
          'sr_no', dis.sr_no,
          'family_member_name', dis.family_member_name,
          'disease_name', dis.disease_name,
          'suffering_since', dis.suffering_since,
          'treatment_taken', dis.treatment_taken,
          'treatment_from_when', dis.treatment_from_when,
          'treatment_from_where', dis.treatment_from_where,
          'treatment_taken_from', dis.treatment_taken_from
        ) ORDER BY dis.sr_no
      )
      FROM diseases dis
      WHERE dis.phone_number = fss.phone_number
    ),
    'social_consciousness', json_build_object(
      'clothes_frequency', sc.clothes_frequency,
      'clothes_other_specify', sc.clothes_other_specify,
      'food_waste_exists', sc.food_waste_exists,
      'food_waste_amount', sc.food_waste_amount,
      'waste_disposal', sc.waste_disposal,
      'waste_disposal_other', sc.waste_disposal_other,
      'separate_waste', sc.separate_waste,
      'compost_pit', sc.compost_pit,
      'recycle_used_items', sc.recycle_used_items,
      'led_lights', sc.led_lights,
      'turn_off_devices', sc.turn_off_devices,
      'fix_leaks', sc.fix_leaks,
      'avoid_plastics', sc.avoid_plastics,
      'family_prayers', sc.family_prayers,
      'family_meditation', sc.family_meditation,
      'meditation_members', sc.meditation_members,
      'family_yoga', sc.family_yoga,
      'yoga_members', sc.yoga_members,
      'community_activities', sc.community_activities,
      'spiritual_discourses', sc.spiritual_discourses,
      'discourses_members', sc.discourses_members,
      'personal_happiness', sc.personal_happiness,
      'family_happiness', sc.family_happiness,
      'happiness_family_who', sc.happiness_family_who,
      'financial_problems', sc.financial_problems,
      'family_disputes', sc.family_disputes,
      'illness_issues', sc.illness_issues,
      'unhappiness_reason', sc.unhappiness_reason,
      'addiction_smoke', sc.addiction_smoke,
      'addiction_drink', sc.addiction_drink,
      'addiction_gutka', sc.addiction_gutka,
      'addiction_gamble', sc.addiction_gamble,
      'addiction_tobacco', sc.addiction_tobacco,
      'addiction_details', sc.addiction_details
    ),
    'children_data', json_build_object(
      'births_last_3_years', cd.births_last_3_years,
      'infant_deaths_last_3_years', cd.infant_deaths_last_3_years,
      'malnourished_children', cd.malnourished_children
    ),
    'migration_data', json_build_object(
      'family_members_migrated', md.family_members_migrated,
      'reason', md.reason,
      'duration', md.duration,
      'destination', md.destination
    ),
    'health_programmes', json_build_object(
      'vaccination_pregnancy', hp.vaccination_pregnancy,
      'child_vaccination', hp.child_vaccination,
      'family_planning_awareness', hp.family_planning_awareness,
      'contraceptive_applied', hp.contraceptive_applied
    )
  ) as social_health_data,

  -- ===========================================
  -- GOVERNMENT SCHEMES - SUMMARY (15 main scheme tables)
  -- ===========================================
  json_build_object(
    'aadhaar_info', (SELECT json_build_object('has_aadhaar', ai.has_aadhaar, 'total_members', ai.total_members) FROM aadhaar_info ai WHERE ai.phone_number = fss.phone_number),
    'ayushman_card', (SELECT json_build_object('has_card', ac.has_card, 'total_members', ac.total_members) FROM ayushman_card ac WHERE ac.phone_number = fss.phone_number),
    'ration_card', (SELECT json_build_object('has_card', rc.has_card, 'card_type', rc.card_type, 'total_members', rc.total_members) FROM ration_card rc WHERE rc.phone_number = fss.phone_number),
    'pm_kisan_nidhi', (SELECT json_build_object('is_beneficiary', pkn.is_beneficiary, 'total_members', pkn.total_members) FROM pm_kisan_nidhi pkn WHERE pkn.phone_number = fss.phone_number),
    'pm_kisan_samman_nidhi', (SELECT json_build_object('is_beneficiary', pksn.is_beneficiary, 'total_members', pksn.total_members) FROM pm_kisan_samman_nidhi pksn WHERE pksn.phone_number = fss.phone_number),
    'tribal_card', (SELECT json_build_object('has_card', tc.has_card, 'total_members', tc.total_members) FROM tribal_card tc WHERE tc.phone_number = fss.phone_number),
    'samagra_id', (SELECT json_build_object('has_id', si.has_id, 'total_children', si.total_children, 'family_id', si.family_id) FROM samagra_id si WHERE si.phone_number = fss.phone_number),
    'family_id', (SELECT json_build_object('has_id', fi.has_id, 'total_members', fi.total_members) FROM family_id fi WHERE fi.phone_number = fss.phone_number),
    'handicapped_allowance', (SELECT json_build_object('has_allowance', ha.has_allowance, 'total_members', ha.total_members) FROM handicapped_allowance ha WHERE ha.phone_number = fss.phone_number),
    'pension_allowance', (SELECT json_build_object('has_pension', pa.has_pension, 'total_members', pa.total_members) FROM pension_allowance pa WHERE pa.phone_number = fss.phone_number),
    'widow_allowance', (SELECT json_build_object('has_allowance', wa.has_allowance, 'total_members', wa.total_members) FROM widow_allowance wa WHERE wa.phone_number = fss.phone_number),
    'vb_gram', (SELECT json_build_object('is_member', vg.is_member, 'total_members', vg.total_members) FROM vb_gram vg WHERE vg.phone_number = fss.phone_number)
  ) as government_schemes_summary,

  -- ===========================================
  -- GOVERNMENT SCHEME MEMBERS - DETAILED (12 member tables)
  -- ===========================================
  json_build_object(
    'aadhaar_scheme_members', (SELECT json_agg(json_build_object('sr_no', asm.sr_no, 'family_member_name', asm.family_member_name, 'have_card', asm.have_card, 'card_number', asm.card_number, 'details_correct', asm.details_correct, 'what_incorrect', asm.what_incorrect, 'benefits_received', asm.benefits_received)) FROM aadhaar_scheme_members asm WHERE asm.phone_number = fss.phone_number),
    'ayushman_scheme_members', (SELECT json_agg(json_build_object('sr_no', ascm.sr_no, 'family_member_name', ascm.family_member_name, 'have_card', ascm.have_card, 'card_number', ascm.card_number, 'details_correct', ascm.details_correct, 'what_incorrect', ascm.what_incorrect, 'benefits_received', ascm.benefits_received)) FROM ayushman_scheme_members ascm WHERE ascm.phone_number = fss.phone_number),
    'ration_scheme_members', (SELECT json_agg(json_build_object('sr_no', rsm.sr_no, 'family_member_name', rsm.family_member_name, 'have_card', rsm.have_card, 'card_number', rsm.card_number, 'details_correct', rsm.details_correct, 'what_incorrect', rsm.what_incorrect, 'benefits_received', rsm.benefits_received)) FROM ration_scheme_members rsm WHERE rsm.phone_number = fss.phone_number),
    'pm_kisan_members', (SELECT json_agg(json_build_object('sr_no', pkm.sr_no, 'member_name', pkm.member_name, 'account_number', pkm.account_number, 'benefits_received', pkm.benefits_received, 'name_included', pkm.name_included, 'details_correct', pkm.details_correct, 'incorrect_details', pkm.incorrect_details, 'received', pkm.received, 'days', pkm.days)) FROM pm_kisan_members pkm WHERE pkm.phone_number = fss.phone_number),
    'pm_kisan_samman_members', (SELECT json_agg(json_build_object('sr_no', pksm.sr_no, 'member_name', pksm.member_name, 'account_number', pksm.account_number, 'benefits_received', pksm.benefits_received, 'name_included', pksm.name_included, 'details_correct', pksm.details_correct, 'incorrect_details', pksm.incorrect_details, 'received', pksm.received, 'days', pksm.days)) FROM pm_kisan_samman_members pksm WHERE pksm.phone_number = fss.phone_number),
    'tribal_scheme_members', (SELECT json_agg(json_build_object('sr_no', tsm.sr_no, 'family_member_name', tsm.family_member_name, 'have_card', tsm.have_card)) FROM tribal_scheme_members tsm WHERE tsm.phone_number = fss.phone_number),
    'samagra_scheme_members', (SELECT json_agg(json_build_object('sr_no', ssm.sr_no, 'family_member_name', ssm.family_member_name, 'have_card', ssm.have_card, 'card_number', ssm.card_number, 'details_correct', ssm.details_correct, 'what_incorrect', ssm.what_incorrect, 'benefits_received', ssm.benefits_received)) FROM samagra_scheme_members ssm WHERE ssm.phone_number = fss.phone_number),
    'handicapped_scheme_members', (SELECT json_agg(json_build_object('sr_no', hsm.sr_no, 'family_member_name', hsm.family_member_name, 'have_card', hsm.have_card, 'card_number', hsm.card_number, 'details_correct', hsm.details_correct, 'what_incorrect', hsm.what_incorrect, 'benefits_received', hsm.benefits_received)) FROM handicapped_scheme_members hsm WHERE hsm.phone_number = fss.phone_number),
    'pension_scheme_members', (SELECT json_agg(json_build_object('sr_no', psm.sr_no, 'family_member_name', psm.family_member_name, 'have_card', psm.have_card, 'card_number', psm.card_number, 'details_correct', psm.details_correct, 'what_incorrect', psm.what_incorrect, 'benefits_received', psm.benefits_received)) FROM pension_scheme_members psm WHERE psm.phone_number = fss.phone_number),
    'widow_scheme_members', (SELECT json_agg(json_build_object('sr_no', wsm.sr_no, 'family_member_name', wsm.family_member_name, 'have_card', wsm.have_card, 'card_number', wsm.card_number, 'details_correct', wsm.details_correct, 'what_incorrect', wsm.what_incorrect, 'benefits_received', wsm.benefits_received)) FROM widow_scheme_members wsm WHERE wsm.phone_number = fss.phone_number),
    'vb_gram_members', (SELECT json_agg(json_build_object('sr_no', vgm.sr_no, 'member_name', vgm.member_name, 'membership_details', vgm.membership_details, 'name_included', vgm.name_included, 'details_correct', vgm.details_correct, 'incorrect_details', vgm.incorrect_details, 'received', vgm.received, 'days', vgm.days)) FROM vb_gram_members vgm WHERE vgm.phone_number = fss.phone_number)
  ) as government_scheme_members,

  -- ===========================================
  -- FINANCIAL & ORGANIZATIONAL (bank_accounts, shg_members, fpo_members, training_data)
  -- ===========================================
  json_build_object(
    'bank_accounts', (SELECT json_agg(json_build_object('sr_no', ba.sr_no, 'member_name', ba.member_name, 'account_number', ba.account_number, 'bank_name', ba.bank_name, 'ifsc_code', ba.ifsc_code, 'account_type', ba.account_type, 'has_account', ba.has_account) ORDER BY ba.sr_no) FROM bank_accounts ba WHERE ba.phone_number = fss.phone_number),
    'shg_members', (SELECT json_agg(json_build_object('member_name', shg.member_name, 'shg_name', shg.shg_name, 'purpose', shg.purpose, 'position', shg.position, 'monthly_saving', shg.monthly_saving)) FROM shg_members shg WHERE shg.phone_number = fss.phone_number),
    'fpo_members', (SELECT json_agg(json_build_object('member_name', fpo.member_name, 'fpo_name', fpo.fpo_name, 'purpose', fpo.purpose, 'share_capital', fpo.share_capital)) FROM fpo_members fpo WHERE fpo.phone_number = fss.phone_number),
    'training_data', (SELECT json_agg(json_build_object('member_name', td.member_name, 'training_topic', td.training_topic, 'training_duration', td.training_duration, 'training_date', td.training_date, 'status', td.status)) FROM training_data td WHERE td.phone_number = fss.phone_number)
  ) as financial_organizational_data,

  -- ===========================================
  -- ADDITIONAL HEALTH & NUTRITION (child_diseases, malnourished_children_data, malnutrition_data, folklore_medicine, nutritional_garden, tulsi_plants, tribal_questions, merged_govt_schemes)
  -- ===========================================
  json_build_object(
    'child_diseases', (SELECT json_agg(json_build_object('sr_no', cd.sr_no, 'child_id', cd.child_id, 'disease_name', cd.disease_name)) FROM child_diseases cd WHERE cd.phone_number = fss.phone_number),
    'malnourished_children_data', (SELECT json_agg(json_build_object('child_id', mcd.child_id, 'child_name', mcd.child_name, 'height', mcd.height, 'weight', mcd.weight)) FROM malnourished_children_data mcd WHERE mcd.phone_number = fss.phone_number),
    'malnutrition_data', (SELECT json_build_object('child_name', md.child_name, 'age', md.age, 'weight', md.weight, 'height', md.height) FROM malnutrition_data md WHERE md.phone_number = fss.phone_number),
    'folklore_medicine', (SELECT json_agg(json_build_object('person_name', fm.person_name, 'plant_local_name', fm.plant_local_name, 'plant_botanical_name', fm.plant_botanical_name, 'uses', fm.uses)) FROM folklore_medicine fm WHERE fm.phone_number = fss.phone_number),
    'nutritional_garden', (SELECT json_build_object('has_garden', ng.has_garden, 'garden_size', ng.garden_size, 'vegetables_grown', ng.vegetables_grown) FROM nutritional_garden ng WHERE ng.phone_number = fss.phone_number),
    'tulsi_plants', (SELECT json_build_object('has_plants', tp.has_plants, 'plant_count', tp.plant_count) FROM tulsi_plants tp WHERE tp.phone_number = fss.phone_number),
    'tribal_questions', (SELECT json_agg(json_build_object('deity_name', tq.deity_name, 'festival_name', tq.festival_name, 'dance_name', tq.dance_name, 'language', tq.language)) FROM tribal_questions tq WHERE tq.phone_number = fss.phone_number),
    'merged_govt_schemes', (SELECT json_build_object('scheme_data', mgs.scheme_data) FROM merged_govt_schemes mgs WHERE mgs.phone_number = fss.phone_number)
  ) as additional_health_nutrition_data

FROM family_survey_sessions fss
LEFT JOIN land_holding lh ON lh.phone_number = fss.phone_number
LEFT JOIN irrigation_facilities ir ON ir.phone_number = fss.phone_number
LEFT JOIN fertilizer_usage fu ON fu.phone_number = fss.phone_number
LEFT JOIN agricultural_equipment ae ON ae.phone_number = fss.phone_number
LEFT JOIN entertainment_facilities ef ON ef.phone_number = fss.phone_number
LEFT JOIN transport_facilities tf ON tf.phone_number = fss.phone_number
LEFT JOIN drinking_water_sources dws ON dws.phone_number = fss.phone_number
LEFT JOIN medical_treatment mt ON mt.phone_number = fss.phone_number
LEFT JOIN disputes d ON d.phone_number = fss.phone_number
LEFT JOIN house_conditions hc ON hc.phone_number = fss.phone_number
LEFT JOIN house_facilities hf ON hf.phone_number = fss.phone_number
LEFT JOIN social_consciousness sc ON sc.phone_number = fss.phone_number
LEFT JOIN children_data cd ON cd.phone_number = fss.phone_number
LEFT JOIN migration_data md ON md.phone_number = fss.phone_number
LEFT JOIN health_programmes hp ON hp.phone_number = fss.phone_number

WHERE fss.phone_number = '0000000008';
