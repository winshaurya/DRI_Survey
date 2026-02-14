# Serverless API templates

This folder contains templates for serverless functions (Vercel) that perform privileged operations using the Supabase `service_role` key. DO NOT commit secrets — set `SUPABASE_SERVICE_ROLE_KEY` and `SUPABASE_URL` in Vercel environment variables.

Endpoints:
- `api/exports/export-surveys.ts` — example endpoint to export surveys as CSV/Excel (uses service role key).
- `api/admin/aggregate.ts` — example endpoint to return aggregated metrics.

How to deploy:
1. Add the files to your repo.
2. Set `SUPABASE_SERVICE_ROLE_KEY` and `SUPABASE_URL` in Vercel project settings.
3. Deploy — Vercel will expose endpoints under `/.netlify/functions/*` or the Vercel functions URL.
