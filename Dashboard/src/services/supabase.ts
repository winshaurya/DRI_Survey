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

// User management helpers using the admin API (requires service role key)
export async function listUsers() {
  const { data, error } = await supabase.auth.admin.listUsers();
  if (error) throw error;
  // data.users is an array of User objects
  return data.users;
}

export async function createUser(opts: { email: string; password: string; phone?: string; user_metadata?: any; app_metadata?: any }) {
  const { data, error } = await supabase.auth.admin.createUser(opts);
  if (error) throw error;
  return data.user;
}

export async function deleteUser(id: string) {
  const { error } = await supabase.auth.admin.deleteUser(id);
  if (error) throw error;
}

export async function updateUser(id: string, opts: { email?: string; password?: string; phone?: string; user_metadata?: any; app_metadata?: any }) {
  const { data, error } = await supabase.auth.admin.updateUserById(id, opts);
  if (error) throw error;
  return data.user;
} 
