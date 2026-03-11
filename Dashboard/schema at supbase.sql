-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.aadhaar_info (
  created_at text DEFAULT (now())::text,
  has_aadhaar text,
  total_members integer,
  phone_number bigint NOT NULL,
  CONSTRAINT aadhaar_info_pkey PRIMARY KEY (phone_number),
  CONSTRAINT aadhaar_info_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.aadhaar_scheme_members (
  sr_no integer NOT NULL,
  family_member_name text,
  have_card text,
  card_number text,
  details_correct text,
  what_incorrect text,
  benefits_received text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT aadhaar_scheme_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.agricultural_equipment (
  created_at text DEFAULT (now())::text,
  tractor text,
  tractor_condition text,
  thresher text,
  thresher_condition text,
  seed_drill text,
  seed_drill_condition text,
  sprayer text,
  sprayer_condition text,
  duster text,
  duster_condition text,
  diesel_engine text,
  diesel_engine_condition text,
  other_equipment text,
  phone_number bigint NOT NULL,
  CONSTRAINT agricultural_equipment_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.animals (
  created_at text DEFAULT (now())::text,
  sr_no integer NOT NULL,
  animal_type text,
  number_of_animals integer,
  breed text,
  production_per_animal numeric,
  quantity_sold numeric,
  phone_number bigint NOT NULL,
  CONSTRAINT animals_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.ayushman_card (
  has_card text,
  total_members integer,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT ayushman_card_pkey PRIMARY KEY (phone_number),
  CONSTRAINT ayushman_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.ayushman_scheme_members (
  sr_no integer NOT NULL,
  family_member_name text,
  have_card text,
  card_number text,
  details_correct text,
  what_incorrect text,
  benefits_received text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT ayushman_scheme_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.bank_accounts (
  sr_no integer NOT NULL,
  member_name text,
  account_number text,
  bank_name text,
  ifsc_code text,
  branch_name text,
  account_type text,
  has_account integer DEFAULT 0,
  details_correct integer DEFAULT 0,
  incorrect_details text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT bank_accounts_pkey PRIMARY KEY (phone_number, sr_no),
  CONSTRAINT bank_accounts_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.child_diseases (
  child_id text,
  disease_name text,
  sr_no integer NOT NULL,
  created_at text NOT NULL DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT child_diseases_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.children_data (
  births_last_3_years integer,
  infant_deaths_last_3_years integer,
  malnourished_children integer,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT children_data_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.crop_productivity (
  created_at text DEFAULT (now())::text,
  sr_no integer NOT NULL,
  crop_name text,
  area_hectares numeric,
  productivity_quintal_per_hectare numeric,
  total_production_quintal numeric,
  quantity_consumed_quintal numeric,
  quantity_sold_quintal numeric,
  phone_number bigint NOT NULL,
  CONSTRAINT crop_productivity_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.diseases (
  created_at text DEFAULT (now())::text,
  sr_no integer NOT NULL,
  family_member_name text,
  disease_name text,
  suffering_since text,
  treatment_taken text,
  treatment_from_when text,
  treatment_from_where text,
  treatment_taken_from text,
  phone_number bigint NOT NULL,
  CONSTRAINT diseases_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.disputes (
  created_at text DEFAULT (now())::text,
  family_disputes text,
  family_registered text,
  family_period text,
  revenue_disputes text,
  revenue_registered text,
  revenue_period text,
  criminal_disputes text,
  criminal_registered text,
  criminal_period text,
  other_disputes text,
  other_description text,
  other_registered text,
  other_period text,
  phone_number bigint NOT NULL,
  CONSTRAINT disputes_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.drinking_water_sources (
  created_at text DEFAULT (now())::text,
  hand_pumps text,
  hand_pumps_distance numeric,
  hand_pumps_quality text,
  well text,
  well_distance numeric,
  well_quality text,
  tubewell text,
  tubewell_distance numeric,
  tubewell_quality text,
  nal_jaal text,
  nal_jaal_quality text,
  other_source text,
  other_distance numeric,
  other_sources_quality text,
  phone_number bigint NOT NULL,
  CONSTRAINT drinking_water_sources_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.entertainment_facilities (
  created_at text DEFAULT (now())::text,
  smart_mobile text,
  smart_mobile_count integer DEFAULT 0,
  analog_mobile text,
  analog_mobile_count integer DEFAULT 0,
  television text,
  radio text,
  games text,
  other_entertainment text,
  other_specify text,
  phone_number bigint NOT NULL,
  CONSTRAINT entertainment_facilities_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.family_id (
  has_id text,
  total_members integer,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT family_id_pkey PRIMARY KEY (phone_number),
  CONSTRAINT family_id_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.family_id_scheme_members (
  sr_no integer NOT NULL,
  family_member_name text,
  have_card text,
  card_number text,
  details_correct text,
  what_incorrect text,
  benefits_received text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT family_id_scheme_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.family_members (
  created_at text DEFAULT (now())::text,
  updated_at text DEFAULT (now())::text,
  is_deleted integer DEFAULT 0,
  sr_no integer NOT NULL,
  name text NOT NULL,
  fathers_name text,
  mothers_name text,
  relationship_with_head text,
  age integer,
  sex text CHECK (sex = ANY (ARRAY['male'::text, 'female'::text, 'other'::text])),
  physically_fit text,
  physically_fit_cause text,
  educational_qualification text,
  inclination_self_employment text,
  occupation text,
  days_employed integer,
  income numeric,
  awareness_about_village text,
  participate_gram_sabha text,
  insured text DEFAULT 'no'::text,
  insurance_company text,
  phone_number bigint NOT NULL,
  CONSTRAINT family_members_pkey PRIMARY KEY (phone_number, sr_no),
  CONSTRAINT family_members_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.family_survey_sessions (
  surveyor_email text,
  created_at text DEFAULT (now())::text,
  updated_at text DEFAULT (now())::text,
  village_name text,
  village_number text,
  panchayat text,
  block text,
  tehsil text,
  district text,
  postal_address text,
  pin_code text,
  shine_code text,
  latitude numeric,
  longitude numeric,
  location_timestamp text,
  survey_date text DEFAULT (CURRENT_DATE)::text,
  surveyor_name text,
  status text DEFAULT 'in_progress'::text CHECK (status = ANY (ARRAY['in_progress'::text, 'completed'::text, 'exported'::text])),
  device_info text,
  app_version text,
  created_by text,
  updated_by text,
  is_deleted integer DEFAULT 0,
  last_synced_at text,
  current_version integer DEFAULT 1,
  last_edited_at text DEFAULT (now())::text,
  page_completion_status text DEFAULT '{}'::text,
  sync_pending integer DEFAULT 0,
  phone_number bigint NOT NULL,
  state text,
  CONSTRAINT family_survey_sessions_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.fertilizer_usage (
  created_at text DEFAULT (now())::text,
  urea_fertilizer text,
  organic_fertilizer text,
  fertilizer_types text,
  fertilizer_expenditure numeric,
  phone_number bigint NOT NULL,
  CONSTRAINT fertilizer_usage_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.folklore_medicine (
  person_name text,
  plant_local_name text,
  plant_botanical_name text,
  uses text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT folklore_medicine_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.fpo_members (
  member_name text,
  fpo_name text,
  purpose text,
  agency text,
  share_capital numeric,
  created_at text NOT NULL DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  sr_no integer NOT NULL,
  CONSTRAINT fpo_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.handicapped_allowance (
  phone_number bigint NOT NULL UNIQUE,
  has_allowance text,
  total_members integer,
  created_at text DEFAULT (now())::text,
  CONSTRAINT handicapped_allowance_pkey PRIMARY KEY (phone_number),
  CONSTRAINT handicapped_allowance_phone_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.handicapped_scheme_members (
  sr_no integer NOT NULL,
  family_member_name text,
  have_card text,
  card_number text,
  details_correct text,
  what_incorrect text,
  benefits_received text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT handicapped_scheme_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.health_programmes (
  vaccination_pregnancy text,
  child_vaccination text,
  vaccination_schedule text,
  balance_doses_schedule text,
  family_planning_awareness text,
  contraceptive_applied text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT health_programmes_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.house_conditions (
  created_at text DEFAULT (now())::text,
  katcha text,
  pakka text,
  katcha_pakka text,
  hut text,
  toilet_in_use text,
  toilet_condition text,
  phone_number bigint NOT NULL,
  CONSTRAINT house_conditions_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.house_facilities (
  created_at text DEFAULT (now())::text,
  toilet text,
  toilet_in_use text,
  drainage text,
  soak_pit text,
  cattle_shed text,
  compost_pit text,
  nadep text,
  lpg_gas text,
  biogas text,
  solar_cooking text,
  electric_connection text,
  nutritional_garden_available text,
  tulsi_plants_available text,
  phone_number bigint NOT NULL,
  CONSTRAINT house_facilities_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.irrigation_facilities (
  created_at text DEFAULT (now())::text,
  primary_source text,
  canal text,
  tube_well text,
  river text,
  pond text,
  well text,
  hand_pump text,
  submersible text,
  rainwater_harvesting text,
  check_dam text,
  other_sources text,
  phone_number bigint NOT NULL,
  CONSTRAINT irrigation_facilities_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.land_holding (
  created_at text DEFAULT (now())::text,
  irrigated_area numeric,
  cultivable_area numeric,
  unirrigated_area numeric,
  barren_land numeric,
  mango_trees integer DEFAULT 0,
  guava_trees integer DEFAULT 0,
  lemon_trees integer DEFAULT 0,
  pomegranate_trees integer DEFAULT 0,
  other_fruit_trees_name text,
  other_fruit_trees_count integer DEFAULT 0,
  phone_number bigint NOT NULL,
  CONSTRAINT land_holding_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.malnourished_children_data (
  child_id text,
  child_name text,
  height numeric,
  weight numeric,
  created_at text NOT NULL DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  sr_no integer NOT NULL,
  CONSTRAINT malnourished_children_data_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.medical_treatment (
  created_at text DEFAULT (now())::text,
  allopathic text,
  ayurvedic text,
  homeopathy text,
  traditional text,
  other_treatment text,
  preferred_treatment text,
  phone_number bigint NOT NULL,
  CONSTRAINT medical_treatment_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.merged_govt_schemes (
  scheme_data text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT merged_govt_schemes_pkey PRIMARY KEY (phone_number),
  CONSTRAINT merged_govt_schemes_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.migration_data (
  family_members_migrated integer,
  reason text,
  duration text,
  destination text,
  created_at text NOT NULL DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  sr_no integer NOT NULL,
  CONSTRAINT migration_data_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.nutritional_garden (
  has_garden text,
  garden_size numeric,
  vegetables_grown text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT nutritional_garden_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.pension_allowance (
  has_pension text,
  total_members integer,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT pension_allowance_pkey PRIMARY KEY (phone_number),
  CONSTRAINT pension_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.pension_scheme_members (
  sr_no integer NOT NULL,
  family_member_name text,
  have_card text,
  card_number text,
  details_correct text,
  what_incorrect text,
  benefits_received text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT pension_scheme_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.pm_kisan_members (
  sr_no integer NOT NULL,
  member_name text,
  account_number text,
  benefits_received text,
  created_at text DEFAULT (now())::text,
  name_included integer,
  details_correct integer,
  incorrect_details text,
  received integer,
  days text,
  phone_number bigint NOT NULL,
  CONSTRAINT pm_kisan_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.pm_kisan_nidhi (
  is_beneficiary text,
  total_members integer,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT pm_kisan_nidhi_pkey PRIMARY KEY (phone_number),
  CONSTRAINT pm_kisan_nidhi_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.pm_kisan_samman_members (
  sr_no integer NOT NULL,
  member_name text,
  account_number text,
  benefits_received text,
  name_included integer,
  details_correct integer,
  incorrect_details text,
  received integer,
  days text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT pm_kisan_samman_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.pm_kisan_samman_nidhi (
  is_beneficiary text,
  total_members integer,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT pm_kisan_samman_nidhi_pkey PRIMARY KEY (phone_number),
  CONSTRAINT pm_kisan_samman_nidhi_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.kisan_credit_card (
  has_card text,
  card_number text,
  credit_limit numeric,
  outstanding_amount numeric,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT kisan_credit_card_pkey PRIMARY KEY (phone_number),
  CONSTRAINT kisan_credit_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.kisan_credit_card_members (
  sr_no integer NOT NULL,
  member_name text,
  name_included integer,
  details_correct integer,
  incorrect_details text,
  received integer,
  days text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT kisan_credit_card_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.swachh_bharat_mission (
  has_toilet text,
  toilet_type text,
  construction_year integer,
  subsidy_received text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT swachh_bharat_mission_pkey PRIMARY KEY (phone_number),
  CONSTRAINT swachh_bharat_mission_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.swachh_bharat_mission_members (
  sr_no integer NOT NULL,
  member_name text,
  name_included integer,
  details_correct integer,
  incorrect_details text,
  received integer,
  days text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT swachh_bharat_mission_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.fasal_bima (
  has_insurance text,
  insurance_type text,
  crop_insured text,
  premium_amount numeric,
  claim_received text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT fasal_bima_pkey PRIMARY KEY (phone_number),
  CONSTRAINT fasal_bima_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.fasal_bima_members (
  sr_no integer NOT NULL,
  member_name text,
  name_included integer,
  details_correct integer,
  incorrect_details text,
  received integer,
  days text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT fasal_bima_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.ration_card (
  phone_number bigint NOT NULL UNIQUE,
  has_card text,
  card_type text,
  total_members integer,
  created_at text DEFAULT (now())::text,
  CONSTRAINT ration_card_pkey PRIMARY KEY (phone_number),
  CONSTRAINT ration_card_phone_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.ration_scheme_members (
  sr_no integer NOT NULL,
  family_member_name text,
  have_card text,
  card_number text,
  details_correct text,
  what_incorrect text,
  benefits_received text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT ration_scheme_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.samagra_id (
  has_id text,
  family_id text,
  total_children integer,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT samagra_id_pkey PRIMARY KEY (phone_number),
  CONSTRAINT samagra_id_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.samagra_scheme_members (
  sr_no integer NOT NULL,
  family_member_name text,
  have_card text,
  card_number text,
  details_correct text,
  what_incorrect text,
  benefits_received text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT samagra_scheme_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.shg_members (
  sr_no integer NOT NULL,
  member_name text,
  shg_name text,
  purpose text,
  agency text,
  position text,
  monthly_saving numeric,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT shg_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.social_consciousness (
  created_at text DEFAULT (now())::text,
  clothes_frequency text,
  clothes_other_specify text,
  food_waste_exists text,
  food_waste_amount text,
  waste_disposal text,
  waste_disposal_other text,
  separate_waste text,
  compost_pit text,
  recycle_used_items text,
  led_lights text,
  turn_off_devices text,
  fix_leaks text,
  avoid_plastics text,
  family_prayers text,
  family_meditation text,
  meditation_members text,
  family_yoga text,
  yoga_members text,
  community_activities text,
  spiritual_discourses text,
  discourses_members text,
  personal_happiness text,
  family_happiness text,
  happiness_family_who text,
  financial_problems text,
  family_disputes text,
  illness_issues text,
  unhappiness_reason text,
  addiction_smoke text,
  addiction_drink text,
  addiction_gutka text,
  addiction_gamble text,
  addiction_tobacco text,
  addiction_details text,
  phone_number bigint
);
CREATE TABLE public.spatial_ref_sys (
  srid integer NOT NULL CHECK (srid > 0 AND srid <= 998999),
  auth_name character varying,
  auth_srid integer,
  srtext character varying,
  proj4text character varying,
  CONSTRAINT spatial_ref_sys_pkey PRIMARY KEY (srid)
);
CREATE TABLE public.training_data (
  member_name text,
  training_topic text,
  training_duration text,
  training_date text,
  status text DEFAULT 'taken'::text,
  created_at text NOT NULL DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT training_data_pkey PRIMARY KEY (phone_number, created_at)
);
CREATE TABLE public.training_needs (
  phone_number bigint NOT NULL,
  sr_no integer NOT NULL,
  wants_training integer,
  preferred_training text,
  created_at text DEFAULT (now())::text,
  CONSTRAINT training_needs_pkey PRIMARY KEY (phone_number, sr_no),
  CONSTRAINT training_needs_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.transport_facilities (
  created_at text DEFAULT (now())::text,
  car_jeep text,
  motorcycle_scooter text,
  e_rickshaw text,
  cycle text,
  pickup_truck text,
  bullock_cart text,
  phone_number bigint NOT NULL,
  CONSTRAINT transport_facilities_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.tribal_card (
  has_card text,
  total_members integer,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT tribal_card_pkey PRIMARY KEY (phone_number),
  CONSTRAINT tribal_card_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.tribal_questions (
  deity_name text,
  festival_name text,
  dance_name text,
  language text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT tribal_questions_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.tribal_scheme_members (
  sr_no integer NOT NULL,
  family_member_name text,
  have_card text,
  card_number text,
  details_correct text,
  what_incorrect text,
  benefits_received text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT tribal_scheme_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.tulsi_plants (
  has_plants text,
  plant_count integer,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT tulsi_plants_pkey PRIMARY KEY (phone_number)
);
CREATE TABLE public.vb_gram (
  is_member text,
  total_members integer,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT vb_gram_pkey PRIMARY KEY (phone_number),
  CONSTRAINT vb_gram_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.vb_gram_members (
  sr_no integer NOT NULL,
  member_name text,
  membership_details text,
  created_at text DEFAULT (now())::text,
  name_included integer,
  details_correct integer,
  incorrect_details text,
  received integer,
  days text,
  phone_number bigint NOT NULL,
  CONSTRAINT vb_gram_members_pkey PRIMARY KEY (phone_number, sr_no)
);
CREATE TABLE public.village_agricultural_implements (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  tractor_available integer DEFAULT 0,
  thresher_available integer DEFAULT 0,
  seed_drill_available integer DEFAULT 0,
  sprayer_available integer DEFAULT 0,
  duster_available integer DEFAULT 0,
  diesel_engine_available integer DEFAULT 0,
  other_implements text,
  CONSTRAINT village_agricultural_implements_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_agricultural_implements_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_animals (
  session_id text NOT NULL,
  created_at text DEFAULT (now())::text,
  sr_no integer NOT NULL,
  animal_type text,
  total_count integer,
  breed text,
  CONSTRAINT village_animals_pkey PRIMARY KEY (session_id, sr_no),
  CONSTRAINT village_animals_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_biodiversity_register (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  register_maintained integer DEFAULT 0,
  status text,
  details text,
  components text,
  knowledge text,
  CONSTRAINT village_biodiversity_register_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_biodiversity_register_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_bpl_families (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  total_bpl_families integer DEFAULT 0,
  bpl_families_with_job_cards integer DEFAULT 0,
  bpl_families_received_mgnrega integer DEFAULT 0,
  CONSTRAINT village_bpl_families_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_bpl_families_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_cadastral_maps (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  has_cadastral_map integer DEFAULT 0,
  map_details text,
  availability_status text,
  image_path text,
  CONSTRAINT village_cadastral_maps_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_cadastral_maps_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_children_data (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  total_children integer DEFAULT 0,
  malnourished_children integer DEFAULT 0,
  children_in_school integer DEFAULT 0,
  births_last_3_years integer DEFAULT 0,
  infant_deaths_last_3_years integer DEFAULT 0,
  malnourished_adults integer DEFAULT 0,
  CONSTRAINT village_children_data_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_children_data_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_crop_productivity (
  session_id text NOT NULL,
  created_at text DEFAULT (now())::text,
  sr_no integer NOT NULL,
  crop_name text,
  area_hectares numeric,
  productivity_quintal_per_hectare numeric,
  total_production_quintal numeric,
  quantity_consumed_quintal numeric,
  quantity_sold_quintal numeric,
  CONSTRAINT village_crop_productivity_pkey PRIMARY KEY (session_id, sr_no),
  CONSTRAINT village_crop_productivity_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_disputes (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  family_disputes integer DEFAULT 0,
  revenue_disputes integer DEFAULT 0,
  criminal_disputes integer DEFAULT 0,
  other_disputes text,
  family_registered integer DEFAULT 0,
  family_period text,
  revenue_registered integer DEFAULT 0,
  revenue_period text,
  criminal_registered integer DEFAULT 0,
  criminal_period text,
  other_description text,
  other_registered integer DEFAULT 0,
  other_period text,
  CONSTRAINT village_disputes_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_disputes_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_drainage_waste (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  drainage_system_available integer DEFAULT 0,
  waste_management_system integer DEFAULT 0,
  earthen_drain integer DEFAULT 0,
  masonry_drain integer DEFAULT 0,
  covered_drain integer DEFAULT 0,
  open_channel integer DEFAULT 0,
  no_drainage_system integer DEFAULT 0,
  drainage_destination text,
  drainage_remarks text,
  waste_collected_regularly integer DEFAULT 0,
  waste_segregated integer DEFAULT 0,
  waste_remarks text,
  CONSTRAINT village_drainage_waste_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_drainage_waste_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_drinking_water (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  hand_pumps_available integer DEFAULT 0,
  hand_pumps_count integer DEFAULT 0,
  wells_available integer DEFAULT 0,
  wells_count integer DEFAULT 0,
  tube_wells_available integer DEFAULT 0,
  tube_wells_count integer DEFAULT 0,
  nal_jal_available integer DEFAULT 0,
  other_sources text,
  CONSTRAINT village_drinking_water_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_drinking_water_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_educational_facilities (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  primary_schools integer DEFAULT 0,
  middle_schools integer DEFAULT 0,
  high_schools integer DEFAULT 0,
  colleges integer DEFAULT 0,
  anganwadi_centers integer DEFAULT 0,
  secondary_schools integer DEFAULT 0,
  higher_secondary_schools integer DEFAULT 0,
  skill_development_centers integer DEFAULT 0,
  shiksha_guarantee_centers integer DEFAULT 0,
  other_facility_name text,
  other_facility_count integer DEFAULT 0,
  CONSTRAINT village_educational_facilities_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_educational_facilities_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_entertainment (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  smart_mobiles_available integer DEFAULT 0,
  smart_mobiles_count integer DEFAULT 0,
  analog_mobiles_available integer DEFAULT 0,
  analog_mobiles_count integer DEFAULT 0,
  televisions_available integer DEFAULT 0,
  televisions_count integer DEFAULT 0,
  radios_available integer DEFAULT 0,
  radios_count integer DEFAULT 0,
  games_available integer DEFAULT 0,
  other_entertainment text,
  CONSTRAINT village_entertainment_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_entertainment_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_farm_families (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  big_farmers integer DEFAULT 0,
  small_farmers integer DEFAULT 0,
  marginal_farmers integer DEFAULT 0,
  landless_farmers integer DEFAULT 0,
  total_farm_families integer DEFAULT 0,
  CONSTRAINT village_farm_families_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_farm_families_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_forest_maps (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  forest_area text,
  forest_types text,
  forest_resources text,
  conservation_status text,
  remarks text,
  CONSTRAINT village_forest_maps_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_forest_maps_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_housing (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  katcha_houses integer DEFAULT 0,
  pakka_houses integer DEFAULT 0,
  katcha_pakka_houses integer DEFAULT 0,
  hut_houses integer DEFAULT 0,
  houses_with_toilet integer DEFAULT 0,
  functional_toilets integer DEFAULT 0,
  houses_with_drainage integer DEFAULT 0,
  houses_with_soak_pit integer DEFAULT 0,
  houses_with_cattle_shed integer DEFAULT 0,
  houses_with_compost_pit integer DEFAULT 0,
  houses_with_nadep integer DEFAULT 0,
  houses_with_lpg integer DEFAULT 0,
  houses_with_biogas integer DEFAULT 0,
  houses_with_solar integer DEFAULT 0,
  houses_with_electricity integer DEFAULT 0,
  CONSTRAINT village_housing_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_housing_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_infrastructure (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  updated_at text DEFAULT (now())::text,
  approach_roads_available integer DEFAULT 0,
  num_approach_roads integer,
  approach_condition text,
  approach_remarks text,
  internal_lanes_available integer DEFAULT 0,
  num_internal_lanes integer,
  internal_condition text,
  internal_remarks text,
  CONSTRAINT village_infrastructure_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_infrastructure_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_infrastructure_details (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  has_primary_school integer DEFAULT 0,
  primary_school_distance text,
  has_junior_school integer DEFAULT 0,
  junior_school_distance text,
  has_high_school integer DEFAULT 0,
  high_school_distance text,
  has_intermediate_school integer DEFAULT 0,
  intermediate_school_distance text,
  other_education_facilities text,
  boys_students_count integer,
  girls_students_count integer,
  has_playground integer DEFAULT 0,
  playground_remarks text,
  has_panchayat_bhavan integer DEFAULT 0,
  panchayat_remarks text,
  has_sharda_kendra integer DEFAULT 0,
  sharda_kendra_distance text,
  has_post_office integer DEFAULT 0,
  post_office_distance text,
  has_health_facility integer DEFAULT 0,
  health_facility_distance text,
  has_bank integer DEFAULT 0,
  bank_distance text,
  has_electrical_connection integer DEFAULT 0,
  num_wells integer,
  num_ponds integer,
  num_hand_pumps integer,
  num_tube_wells integer,
  num_tap_water integer,
  has_primary_health_centre integer DEFAULT 0,
  has_drinking_water_source integer DEFAULT 0,
  CONSTRAINT village_infrastructure_details_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_infrastructure_details_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_irrigation_facilities (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  canal_available integer DEFAULT 0,
  tube_well_available integer DEFAULT 0,
  pond_available integer DEFAULT 0,
  other_sources text,
  has_canal integer DEFAULT 0,
  has_tube_well integer DEFAULT 0,
  has_ponds integer DEFAULT 0,
  has_river integer DEFAULT 0,
  has_well integer DEFAULT 0,
  CONSTRAINT village_irrigation_facilities_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_irrigation_facilities_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_kitchen_gardens (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  total_gardens integer DEFAULT 0,
  gardens_available integer DEFAULT 0,
  CONSTRAINT village_kitchen_gardens_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_kitchen_gardens_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_malnutrition_data (
  session_id text NOT NULL,
  created_at text DEFAULT (now())::text,
  sr_no integer NOT NULL,
  child_name text,
  age integer,
  weight numeric,
  height numeric,
  name text,
  sex text,
  height_feet numeric,
  weight_kg numeric,
  disease_cause text,
  CONSTRAINT village_malnutrition_data_pkey PRIMARY KEY (session_id, sr_no),
  CONSTRAINT village_malnutrition_data_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_map_points (
  session_id text NOT NULL,
  created_at text DEFAULT (now())::text,
  latitude numeric,
  longitude numeric,
  category text,
  remarks text,
  point_id integer NOT NULL,
  CONSTRAINT village_map_points_pkey PRIMARY KEY (session_id, point_id),
  CONSTRAINT village_map_points_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_medical_treatment (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  allopathic_available integer DEFAULT 0,
  ayurvedic_available integer DEFAULT 0,
  homeopathy_available integer DEFAULT 0,
  traditional_available integer DEFAULT 0,
  other_treatment text,
  jhad_phook_available integer DEFAULT 0,
  preference_order text,
  CONSTRAINT village_medical_treatment_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_medical_treatment_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_population (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  is_deleted integer DEFAULT 0,
  total_population integer DEFAULT 0,
  male_population integer DEFAULT 0,
  female_population integer DEFAULT 0,
  other_population integer DEFAULT 0,
  children_0_5 integer DEFAULT 0,
  children_6_14 integer DEFAULT 0,
  youth_15_24 integer DEFAULT 0,
  adults_25_59 integer DEFAULT 0,
  seniors_60_plus integer DEFAULT 0,
  illiterate_population integer DEFAULT 0,
  primary_educated integer DEFAULT 0,
  secondary_educated integer DEFAULT 0,
  higher_educated integer DEFAULT 0,
  sc_population integer DEFAULT 0,
  st_population integer DEFAULT 0,
  obc_population integer DEFAULT 0,
  general_population integer DEFAULT 0,
  working_population integer DEFAULT 0,
  unemployed_population integer DEFAULT 0,
  CONSTRAINT village_population_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_population_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_seed_clubs (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  total_clubs integer DEFAULT 0,
  clubs_available integer DEFAULT 0,
  CONSTRAINT village_seed_clubs_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_seed_clubs_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_signboards (
  session_id text NOT NULL,
  created_at text DEFAULT (now())::text,
  signboard_type text,
  location text,
  signboards text,
  info_boards text,
  wall_writing text,
  CONSTRAINT village_signboards_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_signboards_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_social_consciousness (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  waste_management_system integer DEFAULT 0,
  rainwater_harvesting integer DEFAULT 0,
  solar_energy_usage integer DEFAULT 0,
  community_participation text,
  clothing_purchase_frequency text,
  food_waste_level text,
  food_waste_amount text,
  waste_disposal_method text,
  waste_segregation integer DEFAULT 0,
  compost_pit_available integer DEFAULT 0,
  toilet_available integer DEFAULT 0,
  toilet_functional integer DEFAULT 0,
  toilet_soak_pit integer DEFAULT 0,
  led_lights_used integer DEFAULT 0,
  devices_turned_off integer DEFAULT 0,
  water_leaks_fixed integer DEFAULT 0,
  plastic_avoidance integer DEFAULT 0,
  family_puja integer DEFAULT 0,
  family_meditation integer DEFAULT 0,
  meditation_participants text,
  family_yoga integer DEFAULT 0,
  yoga_participants text,
  community_activities integer DEFAULT 0,
  activity_types text,
  shram_sadhana integer DEFAULT 0,
  shram_participants text,
  spiritual_discourses integer DEFAULT 0,
  discourse_participants text,
  family_happiness text,
  happy_members text,
  happiness_reasons text,
  smoking_prevalence text,
  drinking_prevalence text,
  gudka_prevalence text,
  gambling_prevalence text,
  tobacco_prevalence text,
  saving_habit text,
  saving_percentage text,
  CONSTRAINT village_social_consciousness_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_social_consciousness_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_social_maps (
  session_id text NOT NULL,
  created_at text DEFAULT (now())::text,
  map_type text,
  map_data text,
  remarks text,
  topography_file_link text,
  enterprise_file_link text,
  village_file_link text,
  venn_file_link text,
  transect_file_link text,
  cadastral_file_link text,
  CONSTRAINT village_social_maps_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_social_maps_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_survey_details (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  forest_details text,
  wasteland_details text,
  garden_details text,
  burial_ground_details text,
  crop_plants_details text,
  vegetables_details text,
  fruit_trees_details text,
  animals_details text,
  birds_details text,
  local_biodiversity_details text,
  traditional_knowledge_details text,
  special_features_details text,
  CONSTRAINT village_survey_details_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_survey_details_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_survey_sessions (
  session_id text NOT NULL UNIQUE,
  surveyor_email text NOT NULL,
  created_at text DEFAULT (now())::text,
  updated_at text DEFAULT (now())::text,
  village_name text,
  village_code text,
  state text,
  district text,
  block text,
  panchayat text,
  tehsil text,
  ldg_code text,
  gps_link text,
  shine_code text,
  latitude numeric,
  longitude numeric,
  location_timestamp text,
  status text DEFAULT 'in_progress'::text CHECK (status = ANY (ARRAY['in_progress'::text, 'completed'::text, 'exported'::text])),
  device_info text,
  app_version text,
  created_by text,
  updated_by text,
  is_deleted integer DEFAULT 0,
  last_synced_at text,
  current_version integer DEFAULT 1,
  last_edited_at text DEFAULT (now())::text,
  CONSTRAINT village_survey_sessions_pkey PRIMARY KEY (session_id)
);
CREATE TABLE public.village_traditional_occupations (
  session_id text NOT NULL,
  created_at text DEFAULT (now())::text,
  sr_no integer NOT NULL,
  occupation_name text,
  number_of_families integer,
  families_engaged integer,
  average_income numeric,
  CONSTRAINT village_traditional_occupations_pkey PRIMARY KEY (session_id, sr_no),
  CONSTRAINT village_traditional_occupations_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_transport (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  cars_available integer DEFAULT 0,
  motorcycles_available integer DEFAULT 0,
  e_rickshaws_available integer DEFAULT 0,
  cycles_available integer DEFAULT 0,
  pickup_trucks_available integer DEFAULT 0,
  bullock_carts_available integer DEFAULT 0,
  CONSTRAINT village_transport_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_transport_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_transport_facilities (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  road_connectivity integer DEFAULT 0,
  public_transport_available integer DEFAULT 0,
  tractor_count integer DEFAULT 0,
  car_jeep_count integer DEFAULT 0,
  motorcycle_scooter_count integer DEFAULT 0,
  cycle_count integer DEFAULT 0,
  e_rickshaw_count integer DEFAULT 0,
  pickup_truck_count integer DEFAULT 0,
  CONSTRAINT village_transport_facilities_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_transport_facilities_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.village_unemployment (
  session_id text NOT NULL UNIQUE,
  created_at text DEFAULT (now())::text,
  total_unemployed integer DEFAULT 0,
  unemployed_youth integer DEFAULT 0,
  unemployed_adults integer DEFAULT 0,
  CONSTRAINT village_unemployment_pkey PRIMARY KEY (session_id),
  CONSTRAINT village_unemployment_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.village_survey_sessions(session_id)
);
CREATE TABLE public.widow_allowance (
  has_allowance text,
  total_members integer,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT widow_allowance_pkey PRIMARY KEY (phone_number),
  CONSTRAINT widow_allowance_phone_number_fkey FOREIGN KEY (phone_number) REFERENCES public.family_survey_sessions(phone_number)
);
CREATE TABLE public.widow_scheme_members (
  sr_no integer NOT NULL,
  family_member_name text,
  have_card text,
  card_number text,
  details_correct text,
  what_incorrect text,
  benefits_received text,
  created_at text DEFAULT (now())::text,
  phone_number bigint NOT NULL,
  CONSTRAINT widow_scheme_members_pkey PRIMARY KEY (phone_number, sr_no)
);