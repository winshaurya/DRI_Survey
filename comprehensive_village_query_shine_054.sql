-- ===========================================
-- ULTIMATE COMPREHENSIVE VILLAGE SURVEY QUERY
-- For shine_code: SHINE_054
-- ===========================================
-- This query joins ALL village survey tables from the complete Supabase schema
-- Includes every single table and column for complete data extraction
-- Based on supbase_SCHEMA.sql - includes ALL village tables
-- Run this in Supabase SQL Editor

SELECT
  -- ===========================================
  -- MAIN SESSION DATA (village_survey_sessions)
  -- ===========================================
  vss.session_id,
  vss.surveyor_email,
  vss.village_name,
  vss.village_code,
  vss.state,
  vss.district,
  vss.block,
  vss.panchayat,
  vss.tehsil,
  vss.ldg_code,
  vss.gps_link,
  vss.shine_code,
  vss.latitude,
  vss.longitude,
  vss.location_accuracy,
  vss.location_timestamp,
  vss.status,
  vss.created_at,
  vss.updated_at,
  vss.device_info,
  vss.app_version,
  vss.created_by,
  vss.updated_by,
  vss.is_deleted,
  vss.last_synced_at,
  vss.current_version,
  vss.last_edited_at,

  -- ===========================================
  -- POPULATION DATA (village_population)
  -- ===========================================
  json_build_object(
    'total_population', vp.total_population,
    'male_population', vp.male_population,
    'female_population', vp.female_population,
    'other_population', vp.other_population,
    'children_0_5', vp.children_0_5,
    'children_6_14', vp.children_6_14,
    'youth_15_24', vp.youth_15_24,
    'adults_25_59', vp.adults_25_59,
    'seniors_60_plus', vp.seniors_60_plus,
    'illiterate_population', vp.illiterate_population,
    'primary_educated', vp.primary_educated,
    'secondary_educated', vp.secondary_educated,
    'higher_educated', vp.higher_educated,
    'sc_population', vp.sc_population,
    'st_population', vp.st_population,
    'obc_population', vp.obc_population,
    'general_population', vp.general_population,
    'working_population', vp.working_population,
    'unemployed_population', vp.unemployed_population
  ) as population_data,

  -- ===========================================
  -- FARM FAMILIES (village_farm_families)
  -- ===========================================
  json_build_object(
    'big_farmers', vff.big_farmers,
    'small_farmers', vff.small_farmers,
    'marginal_farmers', vff.marginal_farmers,
    'landless_farmers', vff.landless_farmers,
    'total_farm_families', vff.total_farm_families
  ) as farm_families_data,

  -- ===========================================
  -- HOUSING DATA (village_housing)
  -- ===========================================
  json_build_object(
    'katcha_houses', vh.katcha_houses,
    'pakka_houses', vh.pakka_houses,
    'katcha_pakka_houses', vh.katcha_pakka_houses,
    'hut_houses', vh.hut_houses,
    'houses_with_toilet', vh.houses_with_toilet,
    'functional_toilets', vh.functional_toilets,
    'houses_with_drainage', vh.houses_with_drainage,
    'houses_with_soak_pit', vh.houses_with_soak_pit,
    'houses_with_cattle_shed', vh.houses_with_cattle_shed,
    'houses_with_compost_pit', vh.houses_with_compost_pit,
    'houses_with_nadep', vh.houses_with_nadep,
    'houses_with_lpg', vh.houses_with_lpg,
    'houses_with_biogas', vh.houses_with_biogas,
    'houses_with_solar', vh.houses_with_solar,
    'houses_with_electricity', vh.houses_with_electricity
  ) as housing_data,

  -- ===========================================
  -- AGRICULTURAL IMPLEMENTS (village_agricultural_implements)
  -- ===========================================
  json_build_object(
    'tractor_available', vai.tractor_available,
    'thresher_available', vai.thresher_available,
    'seed_drill_available', vai.seed_drill_available,
    'sprayer_available', vai.sprayer_available,
    'duster_available', vai.duster_available,
    'diesel_engine_available', vai.diesel_engine_available,
    'other_implements', vai.other_implements
  ) as agricultural_implements_data,

  -- ===========================================
  -- CROP PRODUCTIVITY (village_crop_productivity)
  -- ===========================================
  (
    SELECT json_agg(
      json_build_object(
        'sr_no', vcp.sr_no,
        'crop_name', vcp.crop_name,
        'area_hectares', vcp.area_hectares,
        'productivity_quintal_per_hectare', vcp.productivity_quintal_per_hectare,
        'total_production_quintal', vcp.total_production_quintal,
        'quantity_consumed_quintal', vcp.quantity_consumed_quintal,
        'quantity_sold_quintal', vcp.quantity_sold_quintal
      ) ORDER BY vcp.sr_no
    )
    FROM village_crop_productivity vcp
    WHERE vcp.session_id = vss.session_id
  ) as crop_productivity_data,

  -- ===========================================
  -- ANIMALS (village_animals)
  -- ===========================================
  (
    SELECT json_agg(
      json_build_object(
        'sr_no', va.sr_no,
        'animal_type', va.animal_type,
        'total_count', va.total_count,
        'breed', va.breed
      ) ORDER BY va.sr_no
    )
    FROM village_animals va
    WHERE va.session_id = vss.session_id
  ) as animals_data,

  -- ===========================================
  -- IRRIGATION FACILITIES (village_irrigation_facilities)
  -- ===========================================
  json_build_object(
    'has_canal', vif.has_canal,
    'has_tube_well', vif.has_tube_well,
    'has_ponds', vif.has_ponds,
    'has_river', vif.has_river,
    'has_well', vif.has_well,
    'other_sources', vif.other_sources
  ) as irrigation_facilities_data,

  -- ===========================================
  -- DRINKING WATER (village_drinking_water)
  -- ===========================================
  json_build_object(
    'hand_pumps_available', vdw.hand_pumps_available,
    'hand_pumps_count', vdw.hand_pumps_count,
    'wells_available', vdw.wells_available,
    'wells_count', vdw.wells_count,
    'tube_wells_available', vdw.tube_wells_available,
    'tube_wells_count', vdw.tube_wells_count,
    'nal_jal_available', vdw.nal_jal_available,
    'other_sources', vdw.other_sources
  ) as drinking_water_data,

  -- ===========================================
  -- TRANSPORT (village_transport)
  -- ===========================================
  json_build_object(
    'cars_available', vt.cars_available,
    'motorcycles_available', vt.motorcycles_available,
    'e_rickshaws_available', vt.e_rickshaws_available,
    'cycles_available', vt.cycles_available,
    'pickup_trucks_available', vt.pickup_trucks_available,
    'bullock_carts_available', vt.bullock_carts_available
  ) as transport_data,

  -- ===========================================
  -- ENTERTAINMENT (village_entertainment)
  -- ===========================================
  json_build_object(
    'smart_mobiles_available', ve.smart_mobiles_available,
    'smart_mobiles_count', ve.smart_mobiles_count,
    'analog_mobiles_available', ve.analog_mobiles_available,
    'analog_mobiles_count', ve.analog_mobiles_count,
    'televisions_available', ve.televisions_available,
    'televisions_count', ve.televisions_count,
    'radios_available', ve.radios_available,
    'radios_count', ve.radios_count,
    'games_available', ve.games_available,
    'other_entertainment', ve.other_entertainment
  ) as entertainment_data,

  -- ===========================================
  -- MEDICAL TREATMENT (village_medical_treatment)
  -- ===========================================
  json_build_object(
    'allopathic_available', vmt.allopathic_available,
    'ayurvedic_available', vmt.ayurvedic_available,
    'homeopathy_available', vmt.homeopathy_available,
    'traditional_available', vmt.traditional_available,
    'other_treatment', vmt.other_treatment,
    'preference_order', vmt.preference_order
  ) as medical_treatment_data,

  -- ===========================================
  -- DISPUTES (village_disputes)
  -- ===========================================
  json_build_object(
    'family_disputes', vd.family_disputes,
    'family_registered', vd.family_registered,
    'family_period', vd.family_period,
    'revenue_disputes', vd.revenue_disputes,
    'revenue_registered', vd.revenue_registered,
    'revenue_period', vd.revenue_period,
    'criminal_disputes', vd.criminal_disputes,
    'criminal_registered', vd.criminal_registered,
    'criminal_period', vd.criminal_period,
    'other_disputes', vd.other_disputes,
    'other_description', vd.other_description,
    'other_registered', vd.other_registered,
    'other_period', vd.other_period
  ) as disputes_data,

  -- ===========================================
  -- EDUCATIONAL FACILITIES (village_educational_facilities)
  -- ===========================================
  json_build_object(
    'primary_schools', vef.primary_schools,
    'middle_schools', vef.middle_schools,
    'secondary_schools', vef.secondary_schools,
    'higher_secondary_schools', vef.higher_secondary_schools,
    'anganwadi_centers', vef.anganwadi_centers,
    'skill_development_centers', vef.skill_development_centers,
    'shiksha_guarantee_centers', vef.shiksha_guarantee_centers,
    'other_facility_name', vef.other_facility_name,
    'other_facility_count', vef.other_facility_count
  ) as educational_facilities_data,

  -- ===========================================
  -- SOCIAL CONSCIOUSNESS (village_social_consciousness)
  -- ===========================================
  json_build_object(
    'clothing_purchase_frequency', vsc.clothing_purchase_frequency,
    'food_waste_level', vsc.food_waste_level,
    'food_waste_amount', vsc.food_waste_amount,
    'waste_disposal_method', vsc.waste_disposal_method,
    'waste_segregation', vsc.waste_segregation,
    'compost_pit_available', vsc.compost_pit_available,
    'toilet_available', vsc.toilet_available,
    'toilet_functional', vsc.toilet_functional,
    'toilet_soak_pit', vsc.toilet_soak_pit,
    'led_lights_used', vsc.led_lights_used,
    'devices_turned_off', vsc.devices_turned_off,
    'water_leaks_fixed', vsc.water_leaks_fixed,
    'plastic_avoidance', vsc.plastic_avoidance,
    'family_puja', vsc.family_puja,
    'family_meditation', vsc.family_meditation,
    'meditation_participants', vsc.meditation_participants,
    'family_yoga', vsc.family_yoga,
    'yoga_participants', vsc.yoga_participants,
    'community_activities', vsc.community_activities,
    'activity_types', vsc.activity_types,
    'shram_sadhana', vsc.shram_sadhana,
    'shram_participants', vsc.shram_participants,
    'spiritual_discourses', vsc.spiritual_discourses,
    'discourse_participants', vsc.discourse_participants,
    'family_happiness', vsc.family_happiness,
    'happy_members', vsc.happy_members,
    'happiness_reasons', vsc.happiness_reasons,
    'smoking_prevalence', vsc.smoking_prevalence,
    'drinking_prevalence', vsc.drinking_prevalence,
    'gudka_prevalence', vsc.gudka_prevalence,
    'gambling_prevalence', vsc.gambling_prevalence,
    'tobacco_prevalence', vsc.tobacco_prevalence,
    'saving_habit', vsc.saving_habit,
    'saving_percentage', vsc.saving_percentage
  ) as social_consciousness_data,

  -- ===========================================
  -- CHILDREN DATA (village_children_data)
  -- ===========================================
  json_build_object(
    'births_last_3_years', vcd.births_last_3_years,
    'infant_deaths_last_3_years', vcd.infant_deaths_last_3_years,
    'malnourished_children', vcd.malnourished_children,
    'children_in_school', vcd.children_in_school
  ) as children_data,

  -- ===========================================
  -- MALNUTRITION DATA (village_malnutrition_data)
  -- ===========================================
  (
    SELECT json_agg(
      json_build_object(
        'sr_no', vmd.sr_no,
        'name', vmd.name,
        'sex', vmd.sex,
        'age', vmd.age,
        'weight', vmd.weight,
        'height', vmd.height
      ) ORDER BY vmd.sr_no
    )
    FROM village_malnutrition_data vmd
    WHERE vmd.session_id = vss.session_id
  ) as malnutrition_data,

  -- ===========================================
  -- BPL FAMILIES (village_bpl_families)
  -- ===========================================
  json_build_object(
    'total_bpl_families', vbpl.total_bpl_families,
    'bpl_families_with_job_cards', vbpl.bpl_families_with_job_cards,
    'bpl_families_received_mgnrega', vbpl.bpl_families_received_mgnrega
  ) as bpl_families_data,

  -- ===========================================
  -- KITCHEN GARDENS (village_kitchen_gardens)
  -- ===========================================
  json_build_object(
    'gardens_available', vkg.gardens_available,
    'total_gardens', vkg.total_gardens
  ) as kitchen_gardens_data,

  -- ===========================================
  -- SEED CLUBS (village_seed_clubs)
  -- ===========================================
  json_build_object(
    'clubs_available', vsc_clubs.clubs_available,
    'total_clubs', vsc_clubs.total_clubs
  ) as seed_clubs_data,

  -- ===========================================
  -- BIODIVERSITY REGISTER (village_biodiversity_register)
  -- ===========================================
  json_build_object(
    'register_maintained', vbr.register_maintained,
    'status', vbr.status,
    'details', vbr.details,
    'components', vbr.components,
    'knowledge', vbr.knowledge
  ) as biodiversity_register_data,

  -- ===========================================
  -- TRADITIONAL OCCUPATIONS (village_traditional_occupations)
  -- ===========================================
  (
    SELECT json_agg(
      json_build_object(
        'sr_no', vto.sr_no,
        'occupation_name', vto.occupation_name,
        'families_engaged', vto.families_engaged,
        'average_income', vto.average_income
      ) ORDER BY vto.sr_no
    )
    FROM village_traditional_occupations vto
    WHERE vto.session_id = vss.session_id
  ) as traditional_occupations_data,

  -- ===========================================
  -- DRAINAGE & WASTE (village_drainage_waste)
  -- ===========================================
  json_build_object(
    'earthen_drain', vdw_waste.earthen_drain,
    'masonry_drain', vdw_waste.masonry_drain,
    'covered_drain', vdw_waste.covered_drain,
    'open_channel', vdw_waste.open_channel,
    'no_drainage_system', vdw_waste.no_drainage_system,
    'drainage_destination', vdw_waste.drainage_destination,
    'drainage_remarks', vdw_waste.drainage_remarks,
    'waste_collected_regularly', vdw_waste.waste_collected_regularly,
    'waste_segregated', vdw_waste.waste_segregated,
    'waste_remarks', vdw_waste.waste_remarks
  ) as drainage_waste_data,

  -- ===========================================
  -- SIGNBOARDS (village_signboards)
  -- ===========================================
  json_build_object(
    'signboards', vs.signboards,
    'info_boards', vs.info_boards,
    'wall_writing', vs.wall_writing
  ) as signboards_data,

  -- ===========================================
  -- UNEMPLOYMENT (village_unemployment)
  -- ===========================================
  json_build_object(
    'unemployed_youth', vu.unemployed_youth,
    'unemployed_adults', vu.unemployed_adults,
    'total_unemployed', vu.total_unemployed
  ) as unemployment_data,

  -- ===========================================
  -- SOCIAL MAPS (village_social_maps)
  -- ===========================================
  json_build_object(
    'map_type', vsm.map_type,
    'map_data', vsm.map_data,
    'remarks', vsm.remarks,
    'topography_file_link', vsm.topography_file_link,
    'enterprise_file_link', vsm.enterprise_file_link,
    'village_file_link', vsm.village_file_link,
    'venn_file_link', vsm.venn_file_link,
    'transect_file_link', vsm.transect_file_link,
    'cadastral_file_link', vsm.cadastral_file_link
  ) as social_maps_data,

  -- ===========================================
  -- TRANSPORT FACILITIES (village_transport_facilities)
  -- ===========================================
  json_build_object(
    'tractor_count', vtf.tractor_count,
    'car_jeep_count', vtf.car_jeep_count,
    'motorcycle_scooter_count', vtf.motorcycle_scooter_count,
    'cycle_count', vtf.cycle_count,
    'e_rickshaw_count', vtf.e_rickshaw_count,
    'pickup_truck_count', vtf.pickup_truck_count
  ) as transport_facilities_data,

  -- ===========================================
  -- INFRASTRUCTURE (village_infrastructure)
  -- ===========================================
  json_build_object(
    'approach_roads_available', vi.approach_roads_available,
    'num_approach_roads', vi.num_approach_roads,
    'approach_condition', vi.approach_condition,
    'approach_remarks', vi.approach_remarks,
    'internal_lanes_available', vi.internal_lanes_available,
    'num_internal_lanes', vi.num_internal_lanes,
    'internal_condition', vi.internal_condition,
    'internal_remarks', vi.internal_remarks
  ) as infrastructure_data,

  -- ===========================================
  -- INFRASTRUCTURE DETAILS (village_infrastructure_details)
  -- ===========================================
  json_build_object(
    'has_primary_school', vid.has_primary_school,
    'primary_school_distance', vid.primary_school_distance,
    'has_junior_school', vid.has_junior_school,
    'junior_school_distance', vid.junior_school_distance,
    'has_high_school', vid.has_high_school,
    'high_school_distance', vid.high_school_distance,
    'has_intermediate_school', vid.has_intermediate_school,
    'intermediate_school_distance', vid.intermediate_school_distance,
    'other_education_facilities', vid.other_education_facilities,
    'boys_students_count', vid.boys_students_count,
    'girls_students_count', vid.girls_students_count,
    'has_playground', vid.has_playground,
    'playground_remarks', vid.playground_remarks,
    'has_panchayat_bhavan', vid.has_panchayat_bhavan,
    'panchayat_remarks', vid.panchayat_remarks,
    'has_sharda_kendra', vid.has_sharda_kendra,
    'sharda_kendra_distance', vid.sharda_kendra_distance,
    'has_post_office', vid.has_post_office,
    'post_office_distance', vid.post_office_distance,
    'has_health_facility', vid.has_health_facility,
    'health_facility_distance', vid.health_facility_distance,
    'has_primary_health_centre', vid.has_primary_health_centre,
    'has_bank', vid.has_bank,
    'bank_distance', vid.bank_distance,
    'has_electrical_connection', vid.has_electrical_connection,
    'has_drinking_water_source', vid.has_drinking_water_source,
    'num_wells', vid.num_wells,
    'num_ponds', vid.num_ponds,
    'num_hand_pumps', vid.num_hand_pumps,
    'num_tube_wells', vid.num_tube_wells,
    'num_tap_water', vid.num_tap_water
  ) as infrastructure_details_data,

  -- ===========================================
  -- SURVEY DETAILS (village_survey_details)
  -- ===========================================
  json_build_object(
    'forest_details', vsd.forest_details,
    'wasteland_details', vsd.wasteland_details,
    'garden_details', vsd.garden_details,
    'burial_ground_details', vsd.burial_ground_details,
    'crop_plants_details', vsd.crop_plants_details,
    'vegetables_details', vsd.vegetables_details,
    'fruit_trees_details', vsd.fruit_trees_details,
    'animals_details', vsd.animals_details,
    'birds_details', vsd.birds_details,
    'local_biodiversity_details', vsd.local_biodiversity_details,
    'traditional_knowledge_details', vsd.traditional_knowledge_details,
    'special_features_details', vsd.special_features_details
  ) as survey_details_data,

  -- ===========================================
  -- MAP POINTS (village_map_points)
  -- ===========================================
  (
    SELECT json_agg(
      json_build_object(
        'latitude', vmp.latitude,
        'longitude', vmp.longitude,
        'category', vmp.category,
        'remarks', vmp.remarks,
        'point_id', vmp.point_id
      ) ORDER BY vmp.point_id
    )
    FROM village_map_points vmp
    WHERE vmp.session_id = vss.session_id
  ) as map_points_data,

  -- ===========================================
  -- FOREST MAPS (village_forest_maps)
  -- ===========================================
  json_build_object(
    'forest_area', vfm.forest_area,
    'forest_types', vfm.forest_types,
    'forest_resources', vfm.forest_resources,
    'conservation_status', vfm.conservation_status,
    'remarks', vfm.remarks
  ) as forest_maps_data,

  -- ===========================================
  -- CADASTRAL MAPS (village_cadastral_maps)
  -- ===========================================
  json_build_object(
    'has_cadastral_map', vcm.has_cadastral_map,
    'map_details', vcm.map_details,
    'availability_status', vcm.availability_status,
    'image_path', vcm.image_path
  ) as cadastral_maps_data

FROM village_survey_sessions vss
LEFT JOIN village_population vp ON vp.session_id = vss.session_id
LEFT JOIN village_farm_families vff ON vff.session_id = vss.session_id
LEFT JOIN village_housing vh ON vh.session_id = vss.session_id
LEFT JOIN village_agricultural_implements vai ON vai.session_id = vss.session_id
LEFT JOIN village_irrigation_facilities vif ON vif.session_id = vss.session_id
LEFT JOIN village_drinking_water vdw ON vdw.session_id = vss.session_id
LEFT JOIN village_transport vt ON vt.session_id = vss.session_id
LEFT JOIN village_entertainment ve ON ve.session_id = vss.session_id
LEFT JOIN village_medical_treatment vmt ON vmt.session_id = vss.session_id
LEFT JOIN village_disputes vd ON vd.session_id = vss.session_id
LEFT JOIN village_educational_facilities vef ON vef.session_id = vss.session_id
LEFT JOIN village_social_consciousness vsc ON vsc.session_id = vss.session_id
LEFT JOIN village_children_data vcd ON vcd.session_id = vss.session_id
LEFT JOIN village_bpl_families vbpl ON vbpl.session_id = vss.session_id
LEFT JOIN village_kitchen_gardens vkg ON vkg.session_id = vss.session_id
LEFT JOIN village_seed_clubs vsc_clubs ON vsc_clubs.session_id = vss.session_id
LEFT JOIN village_biodiversity_register vbr ON vbr.session_id = vss.session_id
LEFT JOIN village_drainage_waste vdw_waste ON vdw_waste.session_id = vss.session_id
LEFT JOIN village_signboards vs ON vs.session_id = vss.session_id
LEFT JOIN village_unemployment vu ON vu.session_id = vss.session_id
LEFT JOIN village_social_maps vsm ON vsm.session_id = vss.session_id
LEFT JOIN village_transport_facilities vtf ON vtf.session_id = vss.session_id
LEFT JOIN village_infrastructure vi ON vi.session_id = vss.session_id
LEFT JOIN village_infrastructure_details vid ON vid.session_id = vss.session_id
LEFT JOIN village_survey_details vsd ON vsd.session_id = vss.session_id
LEFT JOIN village_forest_maps vfm ON vfm.session_id = vss.session_id
LEFT JOIN village_cadastral_maps vcm ON vcm.session_id = vss.session_id

WHERE vss.shine_code = 'SHINE_001';