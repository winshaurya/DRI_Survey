# VILLAGE SURVEY SAVE/SYNC AUDIT (GG)
**Date:** February 8, 2026

## Scope Reviewed
**Screens (all village UI):**
- [lib/screens/village_survey/village_form_screen.dart](lib/screens/village_survey/village_form_screen.dart)
- [lib/screens/village_survey/infrastructure_screen.dart](lib/screens/village_survey/infrastructure_screen.dart)
- [lib/screens/village_survey/infrastructure_availability_screen.dart](lib/screens/village_survey/infrastructure_availability_screen.dart)
- [lib/screens/village_survey/educational_facilities_screen.dart](lib/screens/village_survey/educational_facilities_screen.dart)
- [lib/screens/village_survey/drainage_waste_screen.dart](lib/screens/village_survey/drainage_waste_screen.dart)
- [lib/screens/village_survey/irrigation_facilities_screen.dart](lib/screens/village_survey/irrigation_facilities_screen.dart)
- [lib/screens/village_survey/seed_clubs_screen.dart](lib/screens/village_survey/seed_clubs_screen.dart)
- [lib/screens/village_survey/signboards_screen.dart](lib/screens/village_survey/signboards_screen.dart)
- [lib/screens/village_survey/social_map_screen.dart](lib/screens/village_survey/social_map_screen.dart)
- [lib/screens/village_survey/survey_details_screen.dart](lib/screens/village_survey/survey_details_screen.dart)
- [lib/screens/village_survey/detailed_map_screen.dart](lib/screens/village_survey/detailed_map_screen.dart)
- [lib/screens/village_survey/cadastral_map_screen.dart](lib/screens/village_survey/cadastral_map_screen.dart)
- [lib/screens/village_survey/forest_map_screen.dart](lib/screens/village_survey/forest_map_screen.dart)
- [lib/screens/village_survey/biodiversity_register_screen.dart](lib/screens/village_survey/biodiversity_register_screen.dart)
- [lib/screens/village_survey/transportation_screen.dart](lib/screens/village_survey/transportation_screen.dart)
- [lib/screens/village_survey/village_survey_preview_page.dart](lib/screens/village_survey/village_survey_preview_page.dart)

**Storage & Sync:**
- Local DB schema: [lib/database/database_helper.dart](lib/database/database_helper.dart)
- Local save helpers: [lib/services/database_service.dart](lib/services/database_service.dart)
- Sync engine: [lib/services/sync_service.dart](lib/services/sync_service.dart)
- Supabase sync: [lib/services/supabase_service.dart](lib/services/supabase_service.dart)
- History UI: [lib/screens/history/history_screen.dart](lib/screens/history/history_screen.dart)
- Provider path (alternate save/load flow): [lib/providers/village_survey_provider.dart](lib/providers/village_survey_provider.dart)

---
## Executive Findings (Critical)
### 1) **History shows “Completed & Synced” when NOT synced**
**Root cause:** `updateVillageSurveyStatus()` sets `last_synced_at` when status is set to `completed` (local-only). History treats `last_synced_at` as the sync signal.
- **Where status is set:** [lib/services/database_service.dart](lib/services/database_service.dart)
- **Where History decides “synced”:** [lib/screens/history/history_screen.dart](lib/screens/history/history_screen.dart)
- **Where completion happens:** [lib/screens/village_survey/village_survey_preview_page.dart](lib/screens/village_survey/village_survey_preview_page.dart) and [lib/providers/village_survey_provider.dart](lib/providers/village_survey_provider.dart)
**Impact:** Completed locally looks synced even if Supabase sync failed or never ran.

### 2) **Provider-based village flow writes to non-existent tables**
`VillageSurveyNotifier._saveToDatabase()` uses `village_detailed_map` and `village_forest_map` (not in local DB). Actual tables are `village_map_points` and `village_forest_maps`.
- **File:** [lib/providers/village_survey_provider.dart](lib/providers/village_survey_provider.dart)
**Impact:** If any screen uses `saveScreenData()`, detailed-map and forest-map data won’t persist.

### 3) **Provider loads village data using the wrong accessor**
`_loadAllVillageData()` calls `DatabaseService.getData()` (filters on `phone_number`) but passes `session_id`.
- **File:** [lib/providers/village_survey_provider.dart](lib/providers/village_survey_provider.dart)
**Impact:** Provider-based editing/loading shows empty data even if DB has records.

### 4) **Map points are one-to-many but full sync sends only the first row**
`_collectCompleteVillageSurveyData()` treats `village_map_points` as one-to-one, so only the first map point is included in the full survey sync.
- **File:** [lib/services/sync_service.dart](lib/services/sync_service.dart)
**Impact:** Detailed map points are silently dropped in full sync (page sync still pushes points, but full sync is incomplete).

### 5) **Uploads use `village_code` instead of `shine_code`**
Social map and biodiversity register uploads key files using `village_code` (not `shine_code`).
- **Files:** [lib/screens/village_survey/social_map_screen.dart](lib/screens/village_survey/social_map_screen.dart), [lib/screens/village_survey/biodiversity_register_screen.dart](lib/screens/village_survey/biodiversity_register_screen.dart)
**Impact:** If `village_code` ≠ `shine_code`, uploaded files attach to the wrong session or never resolve.

---
## Per‑Screen UI → Local DB Save Audit (What Exists in UI vs Saved Columns)
**Goal:** Every UI input should persist to SQLite.

### 0) Village Form
- **UI Inputs:** village_name, village_code, state, district, block, panchayat, tehsil, ldg_code, shine_code, latitude, longitude, location_accuracy, location_timestamp, praTeam
- **Saved to table:** `village_survey_sessions`
- **Saved columns:** `village_name`, `village_code`, `state`, `district`, `block`, `panchayat`, `tehsil`, `ldg_code`, `shine_code`, `latitude`, `longitude`, `location_accuracy`, `location_timestamp`, `status`, `created_at`, `updated_at`
- **Missing UI persistence:** `praTeam` is never saved (no column in table).
- **File:** [lib/screens/village_survey/village_form_screen.dart](lib/screens/village_survey/village_form_screen.dart)

### 1) Infrastructure
- **UI Inputs:** approach roads (availability, count, condition, remarks), internal lanes (availability, count, condition, remarks)
- **Saved to:** `village_infrastructure`
- **All UI fields saved:** ✅
- **File:** [lib/screens/village_survey/infrastructure_screen.dart](lib/screens/village_survey/infrastructure_screen.dart)

### 2) Infrastructure Availability
- **UI Inputs:** school availability + distances, other facilities, boys/girls counts, playground/panchayat/sharda/post office/health/bank/electricity, wells/ponds/handpumps/tubewells/tap water
- **Saved to:** `village_infrastructure_details`
- **Missing UI persistence:** `_hasPrimaryHealthCentre`, `_hasDrinkingWaterSource` are never saved (no columns).
- **File:** [lib/screens/village_survey/infrastructure_availability_screen.dart](lib/screens/village_survey/infrastructure_availability_screen.dart)

### 3) Educational Facilities
- **UI Inputs:** anganwadi centers, shiksha guarantee centers, other facility name/count
- **Saved to:** `village_educational_facilities`
- **All UI fields saved:** ✅
- **Note:** Table also has `primary_schools`, `middle_schools`, `secondary_schools`, `higher_secondary_schools`, `skill_development_centers` which are never filled by UI.
- **File:** [lib/screens/village_survey/educational_facilities_screen.dart](lib/screens/village_survey/educational_facilities_screen.dart)

### 4) Drainage & Waste
- **UI Inputs:** drainage types (earthen/masonry/covered/open/no drainage), drainage destination, drainage remarks, waste collected, waste segregated, waste remarks
- **Saved to:** `village_drainage_waste`
- **All UI fields saved:** ✅
- **File:** [lib/screens/village_survey/drainage_waste_screen.dart](lib/screens/village_survey/drainage_waste_screen.dart)

### 5) Irrigation Facilities
- **UI Inputs:** canal, tube well, ponds, river, well
- **Saved to:** `village_irrigation_facilities`
- **All UI fields saved:** ✅
- **Note:** Table has `other_sources` in Supabase, but not in local DB or UI.
- **File:** [lib/screens/village_survey/irrigation_facilities_screen.dart](lib/screens/village_survey/irrigation_facilities_screen.dart)

### 6) Seed Clubs
- **UI Inputs:** total clubs
- **Saved to:** `village_seed_clubs`
- **All UI fields saved:** ✅
- **File:** [lib/screens/village_survey/seed_clubs_screen.dart](lib/screens/village_survey/seed_clubs_screen.dart)

### 7) Signboards
- **UI Inputs:** signboards, info boards, wall writing
- **Saved to:** `village_signboards`
- **All UI fields saved:** ✅
- **File:** [lib/screens/village_survey/signboards_screen.dart](lib/screens/village_survey/signboards_screen.dart)

### 8) Social Map (remarks + file uploads)
- **UI Inputs:** remarks, file uploads (topography/enterprise/village/venn/transect)
- **Saved to:** `village_social_maps` (remarks only)
- **Upload metadata:** `pending_uploads` uses `village_smile_code` but the screen uses `village_code` as the key.
- **Missing UI persistence:** uploads may attach to wrong session if `village_code` ≠ `shine_code`.
- **File:** [lib/screens/village_survey/social_map_screen.dart](lib/screens/village_survey/social_map_screen.dart)

### 9) Survey Details
- **UI Inputs:** 12 category text fields
- **Saved to:** `village_survey_details`
- **All UI fields saved:** ✅
- **File:** [lib/screens/village_survey/survey_details_screen.dart](lib/screens/village_survey/survey_details_screen.dart)

### 10) Detailed Map Points
- **UI Inputs:** point list (lat, lng, category, remarks, point_id)
- **Saved to:** `village_map_points`
- **All UI fields saved:** ✅ (stored via direct DB insert)
- **Sync risk:** full survey sync only sends first point (see Executive Findings #4).
- **File:** [lib/screens/village_survey/detailed_map_screen.dart](lib/screens/village_survey/detailed_map_screen.dart)

### 11) Cadastral Map
- **UI Inputs:** has_cadastral_map, map_details, availability_status, optional image
- **Saved to:** `village_cadastral_maps`
- **Missing UI persistence:** image path is not stored (no column).
- **File:** [lib/screens/village_survey/cadastral_map_screen.dart](lib/screens/village_survey/cadastral_map_screen.dart)

### 12) Forest Map
- **UI Inputs:** forest_area, forest_types, forest_resources, conservation_status, remarks
- **Saved to:** `village_forest_maps`
- **All UI fields saved:** ✅
- **File:** [lib/screens/village_survey/forest_map_screen.dart](lib/screens/village_survey/forest_map_screen.dart)

### 13) Biodiversity Register
- **UI Inputs:** status, details, components, knowledge + optional image
- **Saved to:** `village_biodiversity_register` (text only)
- **Missing UI persistence:** image path not stored; upload keyed by `village_code` instead of `shine_code`.
- **File:** [lib/screens/village_survey/biodiversity_register_screen.dart](lib/screens/village_survey/biodiversity_register_screen.dart)

### 14) Transportation
- **UI Inputs:** vehicle counts
- **Saved to:** `village_transport_facilities`
- **All UI fields saved:** ✅
- **Note:** This screen is not part of the main flow; it is separate from the primary village survey route list.
- **File:** [lib/screens/village_survey/transportation_screen.dart](lib/screens/village_survey/transportation_screen.dart)

---
## Local DB Tables With **No** Current Village UI Screen
These tables exist in SQLite but are not written by the current village UI flow. They remain empty unless written elsewhere.
- `village_population`
- `village_farm_families`
- `village_housing`
- `village_agricultural_implements`
- `village_crop_productivity`
- `village_animals`
- `village_drinking_water`
- `village_transport` (legacy, separate from `village_transport_facilities`)
- `village_entertainment`
- `village_medical_treatment`
- `village_disputes`
- `village_social_consciousness`
- `village_children_data`
- `village_malnutrition_data`
- `village_bpl_families`
- `village_kitchen_gardens`
- `village_traditional_occupations`
- `village_unemployment`

If any of these are expected from UI, they are currently not collected.

---
## Sync Logic Consistency
### Page‑sync mapping (OK for UI pages)
`syncVillagePageToSupabase()` maps pages 0–14 to the correct tables used by the current screens.
- **File:** [lib/services/supabase_service.dart](lib/services/supabase_service.dart)

### Full‑survey sync issues
- `village_map_points` not treated as one‑to‑many in `_collectCompleteVillageSurveyData()` → only first point synced. **(Critical)**
- `_requiredVillageTables` includes both `village_transport` and `village_transport_facilities`. If Supabase doesn’t contain both, schema validation will block village sync entirely.
- **File:** [lib/services/sync_service.dart](lib/services/sync_service.dart)

---
## History Page “Synced” False Positive — Root Cause Summary
- **History logic:** `isSynced = last_synced_at != null`
- **Local status update:** `updateVillageSurveyStatus()` sets `last_synced_at` when status becomes `completed` (even before sync)
- **Effect:** history shows “Completed & Synced” immediately after submit, even if Supabase sync fails

---
## Fixes Implemented (This Pass)
- History now uses `sync_status` (with safe fallback) instead of `last_synced_at` to determine “Synced”.
- `last_synced_at` is no longer set on local completion; it is updated only on successful sync.
- Provider save/load now uses correct village table names and session‑based accessors.
- Full survey sync treats `village_map_points` as one‑to‑many.
- Schema validation no longer requires legacy `village_transport`.
- Excel export uses `village_transport_facilities` and includes `village_map_points` as one‑to‑many.
- UI‑only fields now persist locally: `pra_team`, `has_primary_health_centre`, `has_drinking_water_source`, and cadastral `image_path`.
- Supabase sync filters out local‑only fields to avoid schema errors.
- Social Map and Biodiversity Register uploads now use `shine_code` for session keying.