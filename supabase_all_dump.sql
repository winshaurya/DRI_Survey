-- auth.audit_log_entries
CREATE TABLE IF NOT EXISTS auth.audit_log_entries (
    instance_id uuid,
    id uuid,
    payload json,
    created_at timestamp with time zone,
    ip_address varchar(64)
\);

-- auth.flow_state
CREATE TABLE IF NOT EXISTS auth.flow_state (
    id uuid,
    user_id uuid,
    auth_code text,
    code_challenge_method USER-DEFINED,
    code_challenge text,
    provider_type text,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean
\);

-- auth.identities
CREATE TABLE IF NOT EXISTS auth.identities (
    provider_id text,
    user_id uuid,
    identity_data jsonb,
    provider text,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text,
    id uuid
\);

-- auth.instances
CREATE TABLE IF NOT EXISTS auth.instances (
    id uuid,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
\);

-- auth.mfa_amr_claims
CREATE TABLE IF NOT EXISTS auth.mfa_amr_claims (
    session_id uuid,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text,
    id uuid
\);

-- auth.mfa_challenges
CREATE TABLE IF NOT EXISTS auth.mfa_challenges (
    id uuid,
    factor_id uuid,
    created_at timestamp with time zone,
    verified_at timestamp with time zone,
    ip_address inet,
    otp_code text,
    web_authn_session_data jsonb
\);

-- auth.mfa_factors
CREATE TABLE IF NOT EXISTS auth.mfa_factors (
    id uuid,
    user_id uuid,
    friendly_name text,
    factor_type USER-DEFINED,
    status USER-DEFINED,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
\);

-- auth.oauth_authorizations
CREATE TABLE IF NOT EXISTS auth.oauth_authorizations (
    id uuid,
    authorization_id text,
    client_id uuid,
    user_id uuid,
    redirect_uri text,
    scope text,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method USER-DEFINED,
    response_type USER-DEFINED,
    status USER-DEFINED,
    authorization_code text,
    created_at timestamp with time zone,
    expires_at timestamp with time zone,
    approved_at timestamp with time zone,
    nonce text
\);

-- auth.oauth_client_states
CREATE TABLE IF NOT EXISTS auth.oauth_client_states (
    id uuid,
    provider_type text,
    code_verifier text,
    created_at timestamp with time zone
\);

-- auth.oauth_clients
CREATE TABLE IF NOT EXISTS auth.oauth_clients (
    id uuid,
    client_secret_hash text,
    registration_type USER-DEFINED,
    redirect_uris text,
    grant_types text,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    client_type USER-DEFINED,
    token_endpoint_auth_method text
\);

-- auth.oauth_consents
CREATE TABLE IF NOT EXISTS auth.oauth_consents (
    id uuid,
    user_id uuid,
    client_id uuid,
    scopes text,
    granted_at timestamp with time zone,
    revoked_at timestamp with time zone
\);

-- auth.one_time_tokens
CREATE TABLE IF NOT EXISTS auth.one_time_tokens (
    id uuid,
    user_id uuid,
    token_type USER-DEFINED,
    token_hash text,
    relates_to text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
\);

-- auth.refresh_tokens
CREATE TABLE IF NOT EXISTS auth.refresh_tokens (
    instance_id uuid,
    id bigint,
    token varchar(255),
    user_id varchar(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent varchar(255),
    session_id uuid
\);

-- auth.saml_providers
CREATE TABLE IF NOT EXISTS auth.saml_providers (
    id uuid,
    sso_provider_id uuid,
    entity_id text,
    metadata_xml text,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text
\);

-- auth.saml_relay_states
CREATE TABLE IF NOT EXISTS auth.saml_relay_states (
    id uuid,
    sso_provider_id uuid,
    request_id text,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid
\);

-- auth.schema_migrations
CREATE TABLE IF NOT EXISTS auth.schema_migrations (
    version varchar(255)
\);

-- auth.sessions
CREATE TABLE IF NOT EXISTS auth.sessions (
    id uuid,
    user_id uuid,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal USER-DEFINED,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text
\);

-- auth.sso_domains
CREATE TABLE IF NOT EXISTS auth.sso_domains (
    id uuid,
    sso_provider_id uuid,
    domain text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
\);

-- auth.sso_providers
CREATE TABLE IF NOT EXISTS auth.sso_providers (
    id uuid,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean
\);

-- auth.users
CREATE TABLE IF NOT EXISTS auth.users (
    instance_id uuid,
    id uuid,
    aud varchar(255),
    role varchar(255),
    email varchar(255),
    encrypted_password varchar(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token varchar(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token varchar(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new varchar(255),
    email_change varchar(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text,
    phone_confirmed_at timestamp with time zone,
    phone_change text,
    phone_change_token varchar(255),
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone,
    email_change_token_current varchar(255),
    email_change_confirm_status smallint,
    banned_until timestamp with time zone,
    reauthentication_token varchar(255),
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean,
    deleted_at timestamp with time zone,
    is_anonymous boolean
\);

-- extensions.pg_stat_statements
CREATE TABLE IF NOT EXISTS extensions.pg_stat_statements (
    userid oid,
    dbid oid,
    toplevel boolean,
    queryid bigint,
    query text,
    plans bigint,
    total_plan_time double precision,
    min_plan_time double precision,
    max_plan_time double precision,
    mean_plan_time double precision,
    stddev_plan_time double precision,
    calls bigint,
    total_exec_time double precision,
    min_exec_time double precision,
    max_exec_time double precision,
    mean_exec_time double precision,
    stddev_exec_time double precision,
    rows bigint,
    shared_blks_hit bigint,
    shared_blks_read bigint,
    shared_blks_dirtied bigint,
    shared_blks_written bigint,
    local_blks_hit bigint,
    local_blks_read bigint,
    local_blks_dirtied bigint,
    local_blks_written bigint,
    temp_blks_read bigint,
    temp_blks_written bigint,
    shared_blk_read_time double precision,
    shared_blk_write_time double precision,
    local_blk_read_time double precision,
    local_blk_write_time double precision,
    temp_blk_read_time double precision,
    temp_blk_write_time double precision,
    wal_records bigint,
    wal_fpi bigint,
    wal_bytes numeric,
    jit_functions bigint,
    jit_generation_time double precision,
    jit_inlining_count bigint,
    jit_inlining_time double precision,
    jit_optimization_count bigint,
    jit_optimization_time double precision,
    jit_emission_count bigint,
    jit_emission_time double precision,
    jit_deform_count bigint,
    jit_deform_time double precision,
    stats_since timestamp with time zone,
    minmax_stats_since timestamp with time zone
\);

-- extensions.pg_stat_statements_info
CREATE TABLE IF NOT EXISTS extensions.pg_stat_statements_info (
    dealloc bigint,
    stats_reset timestamp with time zone
\);

-- public.aadhaar_info
CREATE TABLE IF NOT EXISTS public.aadhaar_info (
    created_at text,
    has_aadhaar text,
    total_members integer,
    phone_number bigint
\);

-- public.aadhaar_scheme_members
CREATE TABLE IF NOT EXISTS public.aadhaar_scheme_members (
    sr_no integer,
    family_member_name text,
    have_card text,
    card_number text,
    details_correct text,
    what_incorrect text,
    benefits_received text,
    created_at text,
    phone_number bigint
\);

-- public.agricultural_equipment
CREATE TABLE IF NOT EXISTS public.agricultural_equipment (
    created_at text,
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
    phone_number bigint
\);

-- public.animals
CREATE TABLE IF NOT EXISTS public.animals (
    created_at text,
    sr_no integer,
    animal_type text,
    number_of_animals integer,
    breed text,
    production_per_animal numeric(8,
    quantity_sold numeric(10,
    phone_number bigint
\);

-- public.ayushman_card
CREATE TABLE IF NOT EXISTS public.ayushman_card (
    has_card text,
    total_members integer,
    created_at text,
    phone_number bigint
\);

-- public.ayushman_scheme_members
CREATE TABLE IF NOT EXISTS public.ayushman_scheme_members (
    sr_no integer,
    family_member_name text,
    have_card text,
    card_number text,
    details_correct text,
    what_incorrect text,
    benefits_received text,
    created_at text,
    phone_number bigint
\);

-- public.bank_accounts
CREATE TABLE IF NOT EXISTS public.bank_accounts (
    sr_no integer,
    member_name text,
    account_number text,
    bank_name text,
    ifsc_code text,
    branch_name text,
    account_type text,
    has_account integer,
    details_correct integer,
    incorrect_details text,
    created_at text,
    phone_number bigint
\);

-- public.child_diseases
CREATE TABLE IF NOT EXISTS public.child_diseases (
    child_id text,
    disease_name text,
    sr_no integer,
    created_at text,
    phone_number bigint
\);

-- public.children_data
CREATE TABLE IF NOT EXISTS public.children_data (
    births_last_3_years integer,
    infant_deaths_last_3_years integer,
    malnourished_children integer,
    created_at text,
    phone_number bigint
\);

-- public.crop_productivity
CREATE TABLE IF NOT EXISTS public.crop_productivity (
    created_at text,
    sr_no integer,
    crop_name text,
    area_hectares numeric(8,
    productivity_quintal_per_hectare numeric(8,
    total_production_quintal numeric(10,
    quantity_consumed_quintal numeric(10,
    quantity_sold_quintal numeric(10,
    phone_number bigint
\);

-- public.diseases
CREATE TABLE IF NOT EXISTS public.diseases (
    created_at text,
    sr_no integer,
    family_member_name text,
    disease_name text,
    suffering_since text,
    treatment_taken text,
    treatment_from_when text,
    treatment_from_where text,
    treatment_taken_from text,
    phone_number bigint
\);

-- public.disputes
CREATE TABLE IF NOT EXISTS public.disputes (
    created_at text,
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
    phone_number bigint
\);

-- public.drinking_water_sources
CREATE TABLE IF NOT EXISTS public.drinking_water_sources (
    created_at text,
    hand_pumps text,
    hand_pumps_distance numeric(5,
    hand_pumps_quality text,
    well text,
    well_distance numeric(5,
    well_quality text,
    tubewell text,
    tubewell_distance numeric(5,
    tubewell_quality text,
    nal_jaal text,
    nal_jaal_quality text,
    other_source text,
    other_distance numeric(5,
    other_sources_quality text,
    phone_number bigint
\);

-- public.entertainment_facilities
CREATE TABLE IF NOT EXISTS public.entertainment_facilities (
    created_at text,
    smart_mobile text,
    smart_mobile_count integer,
    analog_mobile text,
    analog_mobile_count integer,
    television text,
    radio text,
    games text,
    other_entertainment text,
    other_specify text,
    phone_number bigint
\);

-- public.family_id
CREATE TABLE IF NOT EXISTS public.family_id (
    has_id text,
    total_members integer,
    created_at text,
    phone_number bigint
\);

-- public.family_id_scheme_members
CREATE TABLE IF NOT EXISTS public.family_id_scheme_members (
    sr_no integer,
    family_member_name text,
    have_card text,
    card_number text,
    details_correct text,
    what_incorrect text,
    benefits_received text,
    created_at text,
    phone_number bigint
\);

-- public.family_members
CREATE TABLE IF NOT EXISTS public.family_members (
    created_at text,
    updated_at text,
    is_deleted integer,
    sr_no integer,
    name text,
    fathers_name text,
    mothers_name text,
    relationship_with_head text,
    age integer,
    sex text,
    physically_fit text,
    physically_fit_cause text,
    educational_qualification text,
    inclination_self_employment text,
    occupation text,
    days_employed integer,
    income numeric(10,
    awareness_about_village text,
    participate_gram_sabha text,
    insured text,
    insurance_company text,
    phone_number bigint
\);

-- public.family_survey_sessions
CREATE TABLE IF NOT EXISTS public.family_survey_sessions (
    surveyor_email text,
    created_at text,
    updated_at text,
    village_name text,
    village_number text,
    panchayat text,
    block text,
    tehsil text,
    district text,
    postal_address text,
    pin_code text,
    shine_code text,
    latitude numeric(10,
    longitude numeric(11,
    location_accuracy numeric(5,
    location_timestamp text,
    survey_date text,
    surveyor_name text,
    status text,
    device_info text,
    app_version text,
    created_by text,
    updated_by text,
    is_deleted integer,
    last_synced_at text,
    current_version integer,
    last_edited_at text,
    page_completion_status text,
    sync_pending integer,
    phone_number bigint
\);

-- public.fertilizer_usage
CREATE TABLE IF NOT EXISTS public.fertilizer_usage (
    created_at text,
    urea_fertilizer text,
    organic_fertilizer text,
    fertilizer_types text,
    fertilizer_expenditure numeric(10,
    phone_number bigint
\);

-- public.folklore_medicine
CREATE TABLE IF NOT EXISTS public.folklore_medicine (
    person_name text,
    plant_local_name text,
    plant_botanical_name text,
    uses text,
    created_at text,
    phone_number bigint
\);

-- public.fpo_members
CREATE TABLE IF NOT EXISTS public.fpo_members (
    member_name text,
    fpo_name text,
    purpose text,
    agency text,
    share_capital numeric(10,
    created_at text,
    phone_number bigint
\);

-- public.geography_columns
CREATE TABLE IF NOT EXISTS public.geography_columns (
    f_table_catalog name,
    f_table_schema name,
    f_table_name name,
    f_geography_column name,
    coord_dimension integer,
    srid integer,
    type text
\);

-- public.geometry_columns
CREATE TABLE IF NOT EXISTS public.geometry_columns (
    f_table_catalog varchar(256),
    f_table_schema name,
    f_table_name name,
    f_geometry_column name,
    coord_dimension integer,
    srid integer,
    type varchar(30)
\);

-- public.handicapped_allowance
CREATE TABLE IF NOT EXISTS public.handicapped_allowance (
    phone_number bigint,
    has_allowance text,
    total_members integer,
    created_at text
\);

-- public.handicapped_scheme_members
CREATE TABLE IF NOT EXISTS public.handicapped_scheme_members (
    sr_no integer,
    family_member_name text,
    have_card text,
    card_number text,
    details_correct text,
    what_incorrect text,
    benefits_received text,
    created_at text,
    phone_number bigint
\);

-- public.health_programmes
CREATE TABLE IF NOT EXISTS public.health_programmes (
    vaccination_pregnancy text,
    child_vaccination text,
    vaccination_schedule text,
    balance_doses_schedule text,
    family_planning_awareness text,
    contraceptive_applied text,
    created_at text,
    phone_number bigint
\);

-- public.house_conditions
CREATE TABLE IF NOT EXISTS public.house_conditions (
    created_at text,
    katcha text,
    pakka text,
    katcha_pakka text,
    hut text,
    toilet_in_use text,
    toilet_condition text,
    phone_number bigint
\);

-- public.house_facilities
CREATE TABLE IF NOT EXISTS public.house_facilities (
    created_at text,
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
    phone_number bigint
\);

-- public.irrigation_facilities
CREATE TABLE IF NOT EXISTS public.irrigation_facilities (
    created_at text,
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
    phone_number bigint
\);

-- public.land_holding
CREATE TABLE IF NOT EXISTS public.land_holding (
    created_at text,
    irrigated_area numeric(8,
    cultivable_area numeric(8,
    unirrigated_area numeric(8,
    barren_land numeric(8,
    mango_trees integer,
    guava_trees integer,
    lemon_trees integer,
    pomegranate_trees integer,
    other_fruit_trees_name text,
    other_fruit_trees_count integer,
    phone_number bigint
\);

-- public.malnourished_children_data
CREATE TABLE IF NOT EXISTS public.malnourished_children_data (
    child_id text,
    child_name text,
    height numeric(5,
    weight numeric(5,
    created_at text,
    phone_number bigint
\);

-- public.malnutrition_data
CREATE TABLE IF NOT EXISTS public.malnutrition_data (
    child_name text,
    age integer,
    weight numeric(5,
    height numeric(5,
    created_at text,
    phone_number bigint
\);

-- public.medical_treatment
CREATE TABLE IF NOT EXISTS public.medical_treatment (
    created_at text,
    allopathic text,
    ayurvedic text,
    homeopathy text,
    traditional text,
    other_treatment text,
    preferred_treatment text,
    phone_number bigint
\);

-- public.merged_govt_schemes
CREATE TABLE IF NOT EXISTS public.merged_govt_schemes (
    scheme_data text,
    created_at text,
    phone_number bigint
\);

-- public.migration_data
CREATE TABLE IF NOT EXISTS public.migration_data (
    family_members_migrated integer,
    reason text,
    duration text,
    destination text,
    created_at text,
    phone_number bigint
\);

-- public.nutritional_garden
CREATE TABLE IF NOT EXISTS public.nutritional_garden (
    has_garden text,
    garden_size numeric(5,
    vegetables_grown text,
    created_at text,
    phone_number bigint
\);

-- public.pension_allowance
CREATE TABLE IF NOT EXISTS public.pension_allowance (
    has_pension text,
    total_members integer,
    created_at text,
    phone_number bigint
\);

-- public.pension_scheme_members
CREATE TABLE IF NOT EXISTS public.pension_scheme_members (
    sr_no integer,
    family_member_name text,
    have_card text,
    card_number text,
    details_correct text,
    what_incorrect text,
    benefits_received text,
    created_at text,
    phone_number bigint
\);

-- public.pm_kisan_members
CREATE TABLE IF NOT EXISTS public.pm_kisan_members (
    sr_no integer,
    member_name text,
    account_number text,
    benefits_received text,
    created_at text,
    name_included integer,
    details_correct integer,
    incorrect_details text,
    received integer,
    days text,
    phone_number bigint
\);

-- public.pm_kisan_nidhi
CREATE TABLE IF NOT EXISTS public.pm_kisan_nidhi (
    is_beneficiary text,
    total_members integer,
    created_at text,
    phone_number bigint
\);

-- public.pm_kisan_samman_members
CREATE TABLE IF NOT EXISTS public.pm_kisan_samman_members (
    sr_no integer,
    member_name text,
    account_number text,
    benefits_received text,
    name_included integer,
    details_correct integer,
    incorrect_details text,
    received integer,
    days text,
    created_at text,
    phone_number bigint
\);

-- public.pm_kisan_samman_nidhi
CREATE TABLE IF NOT EXISTS public.pm_kisan_samman_nidhi (
    is_beneficiary text,
    total_members integer,
    created_at text,
    phone_number bigint
\);

-- public.ration_card
CREATE TABLE IF NOT EXISTS public.ration_card (
    phone_number bigint,
    has_card text,
    card_type text,
    total_members integer,
    created_at text
\);

-- public.ration_scheme_members
CREATE TABLE IF NOT EXISTS public.ration_scheme_members (
    sr_no integer,
    family_member_name text,
    have_card text,
    card_number text,
    details_correct text,
    what_incorrect text,
    benefits_received text,
    created_at text,
    phone_number bigint
\);

-- public.samagra_id
CREATE TABLE IF NOT EXISTS public.samagra_id (
    has_id text,
    family_id text,
    total_children integer,
    created_at text,
    phone_number bigint
\);

-- public.samagra_scheme_members
CREATE TABLE IF NOT EXISTS public.samagra_scheme_members (
    sr_no integer,
    family_member_name text,
    have_card text,
    card_number text,
    details_correct text,
    what_incorrect text,
    benefits_received text,
    created_at text,
    phone_number bigint
\);

-- public.shg_members
CREATE TABLE IF NOT EXISTS public.shg_members (
    member_name text,
    shg_name text,
    purpose text,
    agency text,
    position text,
    monthly_saving numeric(10,
    created_at text,
    phone_number bigint
\);

-- public.social_consciousness
CREATE TABLE IF NOT EXISTS public.social_consciousness (
    created_at text,
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
\);

-- public.spatial_ref_sys
CREATE TABLE IF NOT EXISTS public.spatial_ref_sys (
    srid integer,
    auth_name varchar(256),
    auth_srid integer,
    srtext varchar(2048),
    proj4text varchar(2048)
\);

-- public.training_data
CREATE TABLE IF NOT EXISTS public.training_data (
    member_name text,
    training_topic text,
    training_duration text,
    training_date text,
    status text,
    created_at text,
    phone_number bigint
\);

-- public.transport_facilities
CREATE TABLE IF NOT EXISTS public.transport_facilities (
    created_at text,
    car_jeep text,
    motorcycle_scooter text,
    e_rickshaw text,
    cycle text,
    pickup_truck text,
    bullock_cart text,
    phone_number bigint
\);

-- public.tribal_card
CREATE TABLE IF NOT EXISTS public.tribal_card (
    has_card text,
    total_members integer,
    created_at text,
    phone_number bigint
\);

-- public.tribal_questions
CREATE TABLE IF NOT EXISTS public.tribal_questions (
    deity_name text,
    festival_name text,
    dance_name text,
    language text,
    created_at text,
    phone_number bigint
\);

-- public.tribal_scheme_members
CREATE TABLE IF NOT EXISTS public.tribal_scheme_members (
    sr_no integer,
    family_member_name text,
    have_card text,
    card_number text,
    details_correct text,
    what_incorrect text,
    benefits_received text,
    created_at text,
    phone_number bigint
\);

-- public.tulsi_plants
CREATE TABLE IF NOT EXISTS public.tulsi_plants (
    has_plants text,
    plant_count integer,
    created_at text,
    phone_number bigint
\);

-- public.vb_gram
CREATE TABLE IF NOT EXISTS public.vb_gram (
    is_member text,
    total_members integer,
    created_at text,
    phone_number bigint
\);

-- public.vb_gram_members
CREATE TABLE IF NOT EXISTS public.vb_gram_members (
    sr_no integer,
    member_name text,
    membership_details text,
    created_at text,
    name_included integer,
    details_correct integer,
    incorrect_details text,
    received integer,
    days text,
    phone_number bigint
\);

-- public.village_agricultural_implements
CREATE TABLE IF NOT EXISTS public.village_agricultural_implements (
    session_id text,
    created_at text,
    tractor_available integer,
    thresher_available integer,
    seed_drill_available integer,
    sprayer_available integer,
    duster_available integer,
    diesel_engine_available integer,
    other_implements text
\);

-- public.village_animals
CREATE TABLE IF NOT EXISTS public.village_animals (
    session_id text,
    created_at text,
    sr_no integer,
    animal_type text,
    total_count integer,
    breed text
\);

-- public.village_biodiversity_register
CREATE TABLE IF NOT EXISTS public.village_biodiversity_register (
    session_id text,
    created_at text,
    register_maintained integer,
    status text,
    details text,
    components text,
    knowledge text
\);

-- public.village_bpl_families
CREATE TABLE IF NOT EXISTS public.village_bpl_families (
    session_id text,
    created_at text,
    total_bpl_families integer,
    bpl_families_with_job_cards integer,
    bpl_families_received_mgnrega integer
\);

-- public.village_cadastral_maps
CREATE TABLE IF NOT EXISTS public.village_cadastral_maps (
    session_id text,
    created_at text,
    has_cadastral_map integer,
    map_details text,
    availability_status text,
    image_path text
\);

-- public.village_children_data
CREATE TABLE IF NOT EXISTS public.village_children_data (
    session_id text,
    created_at text,
    total_children integer,
    malnourished_children integer,
    children_in_school integer,
    births_last_3_years integer,
    infant_deaths_last_3_years integer,
    malnourished_adults integer
\);

-- public.village_crop_productivity
CREATE TABLE IF NOT EXISTS public.village_crop_productivity (
    session_id text,
    created_at text,
    sr_no integer,
    crop_name text,
    area_hectares numeric(8,
    productivity_quintal_per_hectare numeric(8,
    total_production_quintal numeric(10,
    quantity_consumed_quintal numeric(10,
    quantity_sold_quintal numeric(10
\);

-- public.village_disputes
CREATE TABLE IF NOT EXISTS public.village_disputes (
    session_id text,
    created_at text,
    family_disputes integer,
    revenue_disputes integer,
    criminal_disputes integer,
    other_disputes text,
    family_registered integer,
    family_period text,
    revenue_registered integer,
    revenue_period text,
    criminal_registered integer,
    criminal_period text,
    other_description text,
    other_registered integer,
    other_period text
\);

-- public.village_drainage_waste
CREATE TABLE IF NOT EXISTS public.village_drainage_waste (
    session_id text,
    created_at text,
    drainage_system_available integer,
    waste_management_system integer,
    earthen_drain integer,
    masonry_drain integer,
    covered_drain integer,
    open_channel integer,
    no_drainage_system integer,
    drainage_destination text,
    drainage_remarks text,
    waste_collected_regularly integer,
    waste_segregated integer,
    waste_remarks text
\);

-- public.village_drinking_water
CREATE TABLE IF NOT EXISTS public.village_drinking_water (
    session_id text,
    created_at text,
    hand_pumps_available integer,
    hand_pumps_count integer,
    wells_available integer,
    wells_count integer,
    tube_wells_available integer,
    tube_wells_count integer,
    nal_jal_available integer,
    other_sources text
\);

-- public.village_educational_facilities
CREATE TABLE IF NOT EXISTS public.village_educational_facilities (
    session_id text,
    created_at text,
    primary_schools integer,
    middle_schools integer,
    high_schools integer,
    colleges integer,
    anganwadi_centers integer,
    secondary_schools integer,
    higher_secondary_schools integer,
    skill_development_centers integer,
    shiksha_guarantee_centers integer,
    other_facility_name text,
    other_facility_count integer
\);

-- public.village_entertainment
CREATE TABLE IF NOT EXISTS public.village_entertainment (
    session_id text,
    created_at text,
    smart_mobiles_available integer,
    smart_mobiles_count integer,
    analog_mobiles_available integer,
    analog_mobiles_count integer,
    televisions_available integer,
    televisions_count integer,
    radios_available integer,
    radios_count integer,
    games_available integer,
    other_entertainment text
\);

-- public.village_farm_families
CREATE TABLE IF NOT EXISTS public.village_farm_families (
    session_id text,
    created_at text,
    big_farmers integer,
    small_farmers integer,
    marginal_farmers integer,
    landless_farmers integer,
    total_farm_families integer
\);

-- public.village_forest_maps
CREATE TABLE IF NOT EXISTS public.village_forest_maps (
    session_id text,
    created_at text,
    forest_area text,
    forest_types text,
    forest_resources text,
    conservation_status text,
    remarks text
\);

-- public.village_housing
CREATE TABLE IF NOT EXISTS public.village_housing (
    session_id text,
    created_at text,
    katcha_houses integer,
    pakka_houses integer,
    katcha_pakka_houses integer,
    hut_houses integer,
    houses_with_toilet integer,
    functional_toilets integer,
    houses_with_drainage integer,
    houses_with_soak_pit integer,
    houses_with_cattle_shed integer,
    houses_with_compost_pit integer,
    houses_with_nadep integer,
    houses_with_lpg integer,
    houses_with_biogas integer,
    houses_with_solar integer,
    houses_with_electricity integer
\);

-- public.village_infrastructure
CREATE TABLE IF NOT EXISTS public.village_infrastructure (
    session_id text,
    created_at text,
    updated_at text,
    approach_roads_available integer,
    num_approach_roads integer,
    approach_condition text,
    approach_remarks text,
    internal_lanes_available integer,
    num_internal_lanes integer,
    internal_condition text,
    internal_remarks text
\);

-- public.village_infrastructure_details
CREATE TABLE IF NOT EXISTS public.village_infrastructure_details (
    session_id text,
    created_at text,
    has_primary_school integer,
    primary_school_distance text,
    has_junior_school integer,
    junior_school_distance text,
    has_high_school integer,
    high_school_distance text,
    has_intermediate_school integer,
    intermediate_school_distance text,
    other_education_facilities text,
    boys_students_count integer,
    girls_students_count integer,
    has_playground integer,
    playground_remarks text,
    has_panchayat_bhavan integer,
    panchayat_remarks text,
    has_sharda_kendra integer,
    sharda_kendra_distance text,
    has_post_office integer,
    post_office_distance text,
    has_health_facility integer,
    health_facility_distance text,
    has_bank integer,
    bank_distance text,
    has_electrical_connection integer,
    num_wells integer,
    num_ponds integer,
    num_hand_pumps integer,
    num_tube_wells integer,
    num_tap_water integer,
    has_primary_health_centre integer,
    has_drinking_water_source integer
\);

-- public.village_irrigation_facilities
CREATE TABLE IF NOT EXISTS public.village_irrigation_facilities (
    session_id text,
    created_at text,
    canal_available integer,
    tube_well_available integer,
    pond_available integer,
    other_sources text,
    has_canal integer,
    has_tube_well integer,
    has_ponds integer,
    has_river integer,
    has_well integer
\);

-- public.village_kitchen_gardens
CREATE TABLE IF NOT EXISTS public.village_kitchen_gardens (
    session_id text,
    created_at text,
    total_gardens integer,
    gardens_available integer
\);

-- public.village_malnutrition_data
CREATE TABLE IF NOT EXISTS public.village_malnutrition_data (
    session_id text,
    created_at text,
    sr_no integer,
    child_name text,
    age integer,
    weight numeric(5,
    height numeric(5,
    name text,
    sex text,
    height_feet numeric(5,
    weight_kg numeric(5,
    disease_cause text
\);

-- public.village_map_points
CREATE TABLE IF NOT EXISTS public.village_map_points (
    session_id text,
    created_at text,
    latitude numeric(10,
    longitude numeric(11,
    category text,
    remarks text,
    point_id integer
\);

-- public.village_medical_treatment
CREATE TABLE IF NOT EXISTS public.village_medical_treatment (
    session_id text,
    created_at text,
    allopathic_available integer,
    ayurvedic_available integer,
    homeopathy_available integer,
    traditional_available integer,
    other_treatment text,
    jhad_phook_available integer,
    preference_order text
\);

-- public.village_population
CREATE TABLE IF NOT EXISTS public.village_population (
    session_id text,
    created_at text,
    is_deleted integer,
    total_population integer,
    male_population integer,
    female_population integer,
    other_population integer,
    children_0_5 integer,
    children_6_14 integer,
    youth_15_24 integer,
    adults_25_59 integer,
    seniors_60_plus integer,
    illiterate_population integer,
    primary_educated integer,
    secondary_educated integer,
    higher_educated integer,
    sc_population integer,
    st_population integer,
    obc_population integer,
    general_population integer,
    working_population integer,
    unemployed_population integer
\);

-- public.village_seed_clubs
CREATE TABLE IF NOT EXISTS public.village_seed_clubs (
    session_id text,
    created_at text,
    total_clubs integer,
    clubs_available integer
\);

-- public.village_signboards
CREATE TABLE IF NOT EXISTS public.village_signboards (
    session_id text,
    created_at text,
    signboard_type text,
    location text,
    signboards text,
    info_boards text,
    wall_writing text
\);

-- public.village_social_consciousness
CREATE TABLE IF NOT EXISTS public.village_social_consciousness (
    session_id text,
    created_at text,
    waste_management_system integer,
    rainwater_harvesting integer,
    solar_energy_usage integer,
    community_participation text,
    clothing_purchase_frequency text,
    food_waste_level text,
    food_waste_amount text,
    waste_disposal_method text,
    waste_segregation integer,
    compost_pit_available integer,
    toilet_available integer,
    toilet_functional integer,
    toilet_soak_pit integer,
    led_lights_used integer,
    devices_turned_off integer,
    water_leaks_fixed integer,
    plastic_avoidance integer,
    family_puja integer,
    family_meditation integer,
    meditation_participants text,
    family_yoga integer,
    yoga_participants text,
    community_activities integer,
    activity_types text,
    shram_sadhana integer,
    shram_participants text,
    spiritual_discourses integer,
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
    saving_percentage text
\);

-- public.village_social_maps
CREATE TABLE IF NOT EXISTS public.village_social_maps (
    session_id text,
    created_at text,
    map_type text,
    map_data text,
    remarks text,
    topography_file_link text,
    enterprise_file_link text,
    village_file_link text,
    venn_file_link text,
    transect_file_link text,
    cadastral_file_link text
\);

-- public.village_survey_details
CREATE TABLE IF NOT EXISTS public.village_survey_details (
    session_id text,
    created_at text,
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
    special_features_details text
\);

-- public.village_survey_sessions
CREATE TABLE IF NOT EXISTS public.village_survey_sessions (
    session_id text,
    surveyor_email text,
    created_at text,
    updated_at text,
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
    latitude numeric(10,
    longitude numeric(11,
    location_accuracy numeric(5,
    location_timestamp text,
    status text,
    device_info text,
    app_version text,
    created_by text,
    updated_by text,
    is_deleted integer,
    last_synced_at text,
    current_version integer,
    last_edited_at text
\);

-- public.village_traditional_occupations
CREATE TABLE IF NOT EXISTS public.village_traditional_occupations (
    session_id text,
    created_at text,
    sr_no integer,
    occupation_name text,
    number_of_families integer,
    families_engaged integer,
    average_income numeric(10
\);

-- public.village_transport
CREATE TABLE IF NOT EXISTS public.village_transport (
    session_id text,
    created_at text,
    cars_available integer,
    motorcycles_available integer,
    e_rickshaws_available integer,
    cycles_available integer,
    pickup_trucks_available integer,
    bullock_carts_available integer
\);

-- public.village_transport_facilities
CREATE TABLE IF NOT EXISTS public.village_transport_facilities (
    session_id text,
    created_at text,
    road_connectivity integer,
    public_transport_available integer,
    tractor_count integer,
    car_jeep_count integer,
    motorcycle_scooter_count integer,
    cycle_count integer,
    e_rickshaw_count integer,
    pickup_truck_count integer
\);

-- public.village_unemployment
CREATE TABLE IF NOT EXISTS public.village_unemployment (
    session_id text,
    created_at text,
    total_unemployed integer,
    unemployed_youth integer,
    unemployed_adults integer
\);

-- public.widow_allowance
CREATE TABLE IF NOT EXISTS public.widow_allowance (
    has_allowance text,
    total_members integer,
    created_at text,
    phone_number bigint
\);

-- public.widow_scheme_members
CREATE TABLE IF NOT EXISTS public.widow_scheme_members (
    sr_no integer,
    family_member_name text,
    have_card text,
    card_number text,
    details_correct text,
    what_incorrect text,
    benefits_received text,
    created_at text,
    phone_number bigint
\);

-- realtime.messages
CREATE TABLE IF NOT EXISTS realtime.messages (
    topic text,
    extension text,
    payload jsonb,
    event text,
    private boolean,
    updated_at timestamp without time zone,
    inserted_at timestamp without time zone,
    id uuid
\);

-- realtime.schema_migrations
CREATE TABLE IF NOT EXISTS realtime.schema_migrations (
    version bigint,
    inserted_at timestamp without time zone
\);

-- realtime.subscription
CREATE TABLE IF NOT EXISTS realtime.subscription (
    id bigint,
    subscription_id uuid,
    entity regclass,
    filters ARRAY,
    claims jsonb,
    claims_role regrole,
    created_at timestamp without time zone,
    action_filter text
\);

-- storage.buckets
CREATE TABLE IF NOT EXISTS storage.buckets (
    id text,
    name text,
    owner uuid,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    public boolean,
    avif_autodetection boolean,
    file_size_limit bigint,
    allowed_mime_types ARRAY,
    owner_id text,
    type USER-DEFINED
\);

-- storage.buckets_analytics
CREATE TABLE IF NOT EXISTS storage.buckets_analytics (
    name text,
    type USER-DEFINED,
    format text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    id uuid,
    deleted_at timestamp with time zone
\);

-- storage.buckets_vectors
CREATE TABLE IF NOT EXISTS storage.buckets_vectors (
    id text,
    type USER-DEFINED,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
\);

-- storage.migrations
CREATE TABLE IF NOT EXISTS storage.migrations (
    id integer,
    name varchar(100),
    hash varchar(40),
    executed_at timestamp without time zone
\);

-- storage.objects
CREATE TABLE IF NOT EXISTS storage.objects (
    id uuid,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    last_accessed_at timestamp with time zone,
    metadata jsonb,
    path_tokens ARRAY,
    version text,
    owner_id text,
    user_metadata jsonb
\);

-- storage.s3_multipart_uploads
CREATE TABLE IF NOT EXISTS storage.s3_multipart_uploads (
    id text,
    in_progress_size bigint,
    upload_signature text,
    bucket_id text,
    key text,
    version text,
    owner_id text,
    created_at timestamp with time zone,
    user_metadata jsonb
\);

-- storage.s3_multipart_uploads_parts
CREATE TABLE IF NOT EXISTS storage.s3_multipart_uploads_parts (
    id uuid,
    upload_id text,
    size bigint,
    part_number integer,
    bucket_id text,
    key text,
    etag text,
    owner_id text,
    version text,
    created_at timestamp with time zone
\);

-- storage.vector_indexes
CREATE TABLE IF NOT EXISTS storage.vector_indexes (
    id text,
    name text,
    bucket_id text,
    data_type text,
    dimension integer,
    distance_metric text,
    metadata_configuration jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
\);

-- vault.decrypted_secrets
CREATE TABLE IF NOT EXISTS vault.decrypted_secrets (
    id uuid,
    name text,
    description text,
    secret text,
    decrypted_secret text,
    key_id uuid,
    nonce bytea,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
\);

-- vault.secrets
CREATE TABLE IF NOT EXISTS vault.secrets (
    id uuid,
    name text,
    description text,
    secret text,
    key_id uuid,
    nonce bytea,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
\);
