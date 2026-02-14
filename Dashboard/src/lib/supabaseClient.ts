import { createClient } from "@supabase/supabase-js";

const url = String(import.meta.env.VITE_SUPABASE_URL ?? "");
const anonKey = String(import.meta.env.VITE_SUPABASE_ANON_KEY ?? "");

if (!url || !anonKey) {
  // Keep this non-fatal for scaffolding — user will set .env
  console.warn("VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY not set");
}

export const supabase = createClient(url, anonKey);
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string

if (!supabaseUrl || !anonKey) {
  console.warn('VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY not set. See .env.example')
}

export const supabase = createClient(supabaseUrl ?? '', anonKey ?? '')

// For admin operations (schema introspection, counts with service role) use serverless functions
// that use `process.env.SUPABASE_SERVICE_ROLE_KEY` on the server side (Vercel Environment Variables).

export async function getSampleRows(table: string, limit = 10) {
  try {
    const { data, error } = await supabase.from(table).select('*').limit(limit)
    if (error) throw error
    return data
  } catch (err) {
    console.error('getSampleRows error', err)
    return null
  }
}
