# Local vs Supabase Table Coverage Report

Generated: 2026-02-06 22:07:50

## Table Counts
- Supabase schema tables: 87
- Local SQLite tables: 92
- Supabase sync references: 87
- Local collection references: 86

## In Supabase schema but missing in local SQLite
- pm_kisan_members
- self_help_groups
- vb_gram_members

## In local SQLite but missing in Supabase schema
- beneficiary_programs
- family_survey_sessions_new
- pending_uploads
- shg_members
- survey_sessions
- surveys
- sync_failures
- sync_metadata

## In Supabase schema but NOT referenced by Supabase sync service

## In Supabase schema but NOT referenced by local collection (sync_service)
- tribal_questions

