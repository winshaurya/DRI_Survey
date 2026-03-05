import { supabase } from "./supabase";
import { FAMILY_TABLES, VILLAGE_TABLES } from "../consts";

/**
 * Fetches all family survey sessions.
 */
export async function getFamilySessions() {
  const { data, error } = await supabase
    .from("family_survey_sessions")
    .select("*")
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data;
}

/**
 * Fetches all village survey sessions.
 */
export async function getVillageSessions() {
  const { data, error } = await supabase
    .from("village_survey_sessions")
    .select("*")
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data;
}

/**
 * Fetches a single family session and ALL its related data.
 */
export async function getFamilySessionDetails(phoneNumber: string) {
  // 1. Fetch main session
  const { data: session, error: sessionError } = await supabase
    .from("family_survey_sessions")
    .select("*")
    .eq("phone_number", phoneNumber)
    .single();

  if (sessionError) throw sessionError;

  // 2. Fetch all related tables in parallel
  const promises = FAMILY_TABLES.map(async (table) => {
    const { data, error } = await supabase
      .from(table)
      .select("*")
      .eq("phone_number", phoneNumber);
    
    if (error) {
        console.warn(`Failed to fetch ${table} for ${phoneNumber}`, error);
        return { table, data: [] };
    }
    return { table, data: data || [] };
  });

  const results = await Promise.all(promises);
  
  // 3. Combine into a single object
  const details: any = { ...session };
  results.forEach((res) => {
    details[res.table] = res.data;
  });

  return details;
}

/**
 * Fetches a single village session and ALL its related data.
 */
export async function getVillageSessionDetails(sessionId: string) {
  // 1. Fetch main session
  const { data: session, error: sessionError } = await supabase
    .from("village_survey_sessions")
    .select("*")
    .eq("session_id", sessionId)
    .single();

  if (sessionError) throw sessionError;

  // 2. Fetch all related tables in parallel
  const promises = VILLAGE_TABLES.map(async (table) => {
    const { data, error } = await supabase
      .from(table)
      .select("*")
      .eq("session_id", sessionId);

    if (error) {
        console.warn(`Failed to fetch ${table} for ${sessionId}`, error);
        return { table, data: [] };
    }
    
    return { table, data: data || [] };
  });

  const results = await Promise.all(promises);

  // 3. Combine
  const details: any = { ...session };
  results.forEach((res) => {
    details[res.table] = res.data;
  });

  return details;
}
