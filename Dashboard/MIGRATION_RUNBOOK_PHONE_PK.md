## Migration runbook — Convert PKs to phone_number (staging first) ✅

Purpose
- Convert family-related tables to use `phone_number` (or composite `(phone_number, sr_no)`) as primary keys and change `phone_number` column type to BIGINT on Supabase (Postgres).
- Non-destructive: preserve existing rows and provide rollback guidance.

Files in repo
- Migration SQL: `Dashboard/migrations/2026_02_18_convert_family_pks_to_phone.sql` (finalized)
- Local mirror / runtime migration: `lib/database/database_helper.dart` (DB version 43)

Preflight checks (required)
1. Take a full DB backup (recommended):
   - Managed snapshot (Supabase dashboard) OR
   - pg_dump: `pg_dump --format=directory --schema=public --file=backup_dir "$STAGING_PG_CONN"`
2. Numeric-only check (run on staging before migration):
   - SELECT COUNT(*) FROM family_survey_sessions WHERE phone_number IS NULL OR phone_number !~ '^[0-9]+$';
   - Repeat for every table listed in the migration SQL (family_members, crop_productivity, fertilizer_usage, etc.)
3. Uniqueness check (migration script also runs these):
   - Ensure no duplicate phone_number rows where phone_number will become PK.

How to run (staging)
1. Ensure you have a staging DB snapshot/backups.
2. Run the migration SQL against the staging database:
   - Using psql:
     psql "$STAGING_PG_CONN" -f Dashboard/migrations/2026_02_18_convert_family_pks_to_phone.sql
   - Or use Supabase SQL editor (paste the SQL) — **do not** run in production yet.
3. Watch for exceptions — the script aborts early on numeric/dup checks.

Smoke tests (staging)
1. Validate key counts (before/after):
   - SELECT COUNT(*) FROM family_survey_sessions;
   - SELECT COUNT(*) FROM family_members WHERE phone_number IS NOT NULL;
2. Verify FK integrity and that new PRIMARY KEYs exist.
3. Run client E2E flows against staging:
   - Create a new survey (phone as numeric), edit a member, delete a member.
   - Offline → sync flows.
   - Export/Excel generation.
4. Test RLS policies and any views/functions that reference `id`.

Post-migration (after staging validated)
1. Merge and release client changes that assume `phone_number` is numeric (we've updated local DB migration and key service call-sites).
2. Deploy RLS / view / function updates to production if any.
3. Schedule a short maintenance window for production migration.
4. Repeat the migration on production following the same backup + runbook steps.

Rollback (if needed)
- Preferred: restore from DB snapshot or `pg_restore` from the pre-migration pg_dump.
- If you used in-DB `backup_before_phone_migration` copies (optional) you can copy rows back from those tables.

Notes & caveats
- The migration script enforces numeric-only phone numbers but does NOT add a 10-digit CHECK constraint (per instructions).
- After migration the client must send numeric `phone_number` for Supabase queries (the app has defensive int.tryParse where needed and _normalizeMap converts numeric-strings to numbers).

Need me to:
- Run the staging migration for you (I cannot execute against your remote DB here) — I can prepare the exact psql or supabase CLI command and verify the SQL.
- Open a PR with model type changes & run unit/widget tests.

---
