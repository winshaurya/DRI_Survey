// Supabase client setup. This application uses the **service role key** 
// for all queries.  WARNING: embedding the service role key in front-end
// code bypasses row‑level security and grants full database privileges.
// Use this only in a trusted environment (development/demo) and rotate the
// key frequently.

import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string;
const supabaseServiceRoleKey = import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY as string;

if (!supabaseUrl) console.warn("VITE_SUPABASE_URL missing");
if (!supabaseServiceRoleKey) console.warn("VITE_SUPABASE_SERVICE_ROLE_KEY missing");

export const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

// Helper: fetch all rows from a table
export async function fetchTableData(table: string) {
  const { data, error } = await supabase.from(table).select("*");
  if (error) throw error;
  return data;
} 
