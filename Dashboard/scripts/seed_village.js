/**
 * Resilient ESM seed script — inserts village_survey_sessions first, then related rows.
 * Adds retries for network errors and uses minimal payloads to avoid schema mismatches.
 *
 * Run: node scripts/seed_village.js
 *
 * Reads VITE_SUPABASE_URL and VITE_SUPABASE_SERVICE_ROLE_KEY from .env at repo root.
 * WARNING: This will write to your Supabase project using the service-role key.
 */

import fs from "fs/promises";
import path from "path";

async function parseDotEnv(file) {
  const text = await fs.readFile(file, "utf8");
  const lines = text.split(/\r?\n/);
  const out = {};
  for (const l of lines) {
    const m = l.match(/^\s*([^#=]+?)\s*=\s*(.*)\s*$/);
    if (m) {
      let v = m[2].trim();
      if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
        v = v.slice(1, -1);
      }
      out[m[1].trim()] = v;
    }
  }
  return out;
}

async function post(table, payload, base, key, attempt = 1) {
  const url = `${base.replace(/\/$/, "")}/rest/v1/${table}`;
  try {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        apikey: key,
        Authorization: `Bearer ${key}`,
        "Content-Type": "application/json",
        Prefer: "return=representation",
      },
      body: JSON.stringify(payload),
    });
    const txt = await res.text();
    try {
      return { ok: res.ok, status: res.status, body: JSON.parse(txt) };
    } catch {
      return { ok: res.ok, status: res.status, body: txt };
    }
  } catch (e) {
    if (attempt < 4) {
      const wait = 2000 * attempt;
      console.warn(`Network error inserting ${table}, retry ${attempt} in ${wait}ms`, String(e));
      await new Promise((r) => setTimeout(r, wait));
      return post(table, payload, base, key, attempt + 1);
    }
    throw e;
  }
}

function minimalRowForTable(table, session_id) {
  // return minimal safe payloads to avoid unknown column errors
  return { session_id, created_at: new Date().toISOString() };
}

async function main() {
  const envPath = path.resolve(process.cwd(), ".env");
  try {
    await fs.access(envPath);
  } catch {
    console.error(".env not found at project root. Aborting.");
    process.exit(1);
  }

  const env = await parseDotEnv(envPath);
  const SUPABASE_URL = env["VITE_SUPABASE_URL"];
  const SUPABASE_KEY = env["VITE_SUPABASE_SERVICE_ROLE_KEY"];

  if (!SUPABASE_URL || !SUPABASE_KEY) {
    console.error("VITE_SUPABASE_URL or VITE_SUPABASE_SERVICE_ROLE_KEY missing in .env");
    process.exit(1);
  }

  console.log("Seeding village tables to", SUPABASE_URL);

  const session_id = `seed-${Date.now()}`;
  const session = {
    session_id,
    surveyor_email: "seed@local.test",
    village_name: "SeedVillage",
    state: "SeedState",
    district: "SeedDistrict",
    block: "SeedBlock",
    panchayat: "SeedPanchayat",
    status: "completed",
    created_at: new Date().toISOString(),
  };

  // Insert session first
  try {
    const res = await post("village_survey_sessions", session, SUPABASE_URL, SUPABASE_KEY);
    if (!res.ok) {
      console.error("Failed to insert session:", res.status, res.body);
      console.error("Aborting further inserts to avoid FK errors.");
      return;
    }
    console.log("Inserted session:", res.body);
  } catch (e) {
    console.error("Network failure inserting session:", e);
    return;
  }

  // Simple single-row tables: use minimal payload to avoid mismatched columns
  const simpleTables = [
    "village_population",
    "village_farm_families",
    "village_housing",
    "village_agricultural_implements",
    "village_irrigation_facilities",
    "village_drinking_water",
    "village_transport",
    "village_entertainment",
    "village_medical_treatment",
    "village_disputes",
    "village_educational_facilities",
    "village_social_consciousness",
    "village_children_data",
    "village_bpl_families",
    "village_kitchen_gardens",
    "village_seed_clubs",
    "village_biodiversity_register",
    "village_traditional_occupations",
    "village_drainage_waste",
    "village_signboards",
    "village_unemployment",
    "village_social_maps",
    "village_transport_facilities",
    "village_infrastructure",
    "village_infrastructure_details",
    "village_survey_details",
    "village_forest_maps",
    "village_cadastral_maps",
  ];

  for (const t of simpleTables) {
    try {
      const payload = minimalRowForTable(t, session_id);
      const r = await post(t, payload, SUPABASE_URL, SUPABASE_KEY);
      if (!r.ok) {
        console.error(`Insert into ${t} failed: status=${r.status}`, r.body);
      } else {
        console.log(`Inserted into ${t}:`, Array.isArray(r.body) ? r.body[0] : r.body);
      }
    } catch (e) {
      console.error(`Error inserting into ${t}:`, e);
    }
  }

  // Multi-row tables with required keys
  const multiTables = {
    village_crop_productivity: [
      { session_id, sr_no: 1, crop_name: "Wheat", area_hectares: 12.5 },
      { session_id, sr_no: 2, crop_name: "Rice", area_hectares: 8.0 },
    ],
    village_animals: [
      { session_id, sr_no: 1, animal_type: "Cow", total_count: 12 },
      { session_id, sr_no: 2, animal_type: "Goat", total_count: 25 },
    ],
    village_malnutrition_data: [{ session_id, sr_no: 1, name: "Child A", sex: "male", age: 3 }],
    village_map_points: [{ session_id, point_id: 1, latitude: 12.345678, longitude: 98.765432 }],
    village_traditional_occupations: [{ session_id, sr_no: 1, occupation_name: "Carpentry" }],
  };

  for (const [t, rows] of Object.entries(multiTables)) {
    for (const r of rows) {
      try {
        const res = await post(t, r, SUPABASE_URL, SUPABASE_KEY);
        if (!res.ok) {
          console.error(`Insert into ${t} failed: status=${res.status}`, res.body);
        } else {
          console.log(`Inserted into ${t}:`, Array.isArray(res.body) ? res.body[0] : res.body);
        }
      } catch (e) {
        console.error(`Error inserting into ${t}:`, e);
      }
    }
  }

  console.log("Seeding complete. Reload your app and click Refresh.");
}

main().catch((e) => {
  console.error("Seed script failed", e);
  process.exit(1);
});