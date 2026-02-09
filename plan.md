# PLAN — Village Survey Consistency & Export Alignment
**Date:** February 8, 2026

## Objective
Deliver a consistent village survey flow where:
1) Preview shows only pages the user actually filled,
2) Excel export includes all local tables with correct mappings,
3) Local DB saves match current schema and syncs without duplicates,
4) Table names and one‑to‑many handling are consistent across app, local DB, export, and Supabase sync.

## Current Gaps (from gg.md)
- Legacy vs current transport table mismatch (`village_transport` vs `village_transport_facilities`).
- Provider saves to non‑existent table names (`village_detailed_map`, `village_forest_map`).
- Provider loads village data using `getData()` (phone-based) with `session_id`.
- Preview “filled section” logic treats zero/default values as filled.
- `village_map_points` not treated as one‑to‑many in export/sync.

## Plan of Action (No Code Yet)
### Phase 1 — Preview correctness (show only filled pages)
1) Use **data‑based detection only** (no `page_completion_status`).
2) Implement a strict “non‑default” check per section:
   - Ignore numeric `0`, empty strings, empty lists/maps, and placeholder values.
3) Add a mapping between preview sections and their underlying tables so the check is consistent.

### Phase 2 — Table name unification (local + sync + export)
1) Standardize on **`village_transport_facilities`** everywhere:
   - Remove legacy `village_transport` from required table lists, sync helpers, and Excel export sections.
   - Ensure Supabase sync uses the facilities table and its count fields.
2) Standardize on **`village_forest_maps`** and **`village_map_points`**:
   - Update provider save paths to correct table names.
   - Ensure full‑sync and export treat `village_map_points` as one‑to‑many.

### Phase 3 — Provider load/save consistency
1) Update `VillageSurveyNotifier._loadAllVillageData()` to use `getVillageData()` for session‑based queries.
2) Align `VillageSurveyNotifier._saveToDatabase()` table names to the actual schema (`village_forest_maps`, `village_map_points`).

### Phase 4 — Export completeness (Excel)
1) Update export table list and section order:
   - Remove legacy `village_transport` references.
   - Ensure `village_transport_facilities` appears and is mapped to count fields.
2) Add `village_map_points` to one‑to‑many list so all points export.
3) Verify all new village fields added in SCHEMA are exported (e.g., irrigation flags, disputes details, etc.).

### Phase 5 — Sync integrity
1) Update Supabase village sync to remove `village_transport` and use `village_transport_facilities`.
2) Ensure schema validation list matches SCHEMA (no extra missing tables).
3) Add `village_map_points` to one‑to‑many handling for full sync payloads.

## Files That Will Need Edits (When Approved)
- [lib/screens/village_survey/village_survey_preview_page.dart](lib/screens/village_survey/village_survey_preview_page.dart)
- [lib/providers/village_survey_provider.dart](lib/providers/village_survey_provider.dart)
- [lib/services/excel_service.dart](lib/services/excel_service.dart)
- [lib/services/sync_service.dart](lib/services/sync_service.dart)
- [lib/services/supabase_service.dart](lib/services/supabase_service.dart)
- [lib/database/database_helper.dart](lib/database/database_helper.dart) (optional cleanup of legacy table)

## Questions / Decisions Needed
1) Do you want to **delete** the legacy `village_transport` table or keep it for backward compatibility (read‑only fallback)? - yes delete 
2) Should `village_map_points` be included in Excel even if empty? (Default: include only if data exists.) - no

---
Once you approve or adjust this plan, I will implement the changes.