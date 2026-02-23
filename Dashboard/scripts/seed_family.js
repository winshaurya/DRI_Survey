/**
 * ESM seed script — inserts one family_survey_sessions row and related dummy rows.
 * Run: node scripts/seed_family.js
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

function minimalRowForTable(table, phone) {
  return { phone_number: phone, created_at: new Date().toISOString() };
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

  console.log("Seeding family tables to", SUPABASE_URL);

  const phone = Number("999" + Date.now().toString().slice(-7)); // unique-ish
  const session = {
    phone_number: phone,
    surveyor_email: "seed@local.test",
    village_name: "SeedVillage",
    district: "SeedDistrict",
    survey_date: new Date().toISOString().split("T")[0],
    status: "completed",
    created_at: new Date().toISOString(),
  };

  // Insert session first
  try {
    const res = await post("family_survey_sessions", session, SUPABASE_URL, SUPABASE_KEY);
    if (!res.ok) {
      console.error("Failed to insert family session:", res.status, res.body);
      return;
    }
    console.log("Inserted family session:", res.body);
  } catch (e) {
    console.error("Network failure inserting family session:", e);
    return;
  }

  const simpleTables = [
    "land_holding",
    "irrigation_facilities",
    "fertilizer_usage",
    "agricultural_equipment",
    "entertainment_facilities",
    "transport_facilities",
    "drinking_water_sources",
    "medical_treatment",
    "disputes",
    "house_conditions",
    "house_facilities",
    "social_consciousness",
    "aadhaar_info",
    "ayushman_card",
    "family_id",
    "ration_card",
    "samagra_id",
    "tribal_card",
    "handicapped_allowance",
    "pension_allowance",
    "widow_allowance",
    "vb_gram",
    "pm_kisan_nidhi",
    "merged_govt_schemes",
    "children_data",
    "migration_data",
    "training_data",
    "shg_members",
    "fpo_members",
    "folklore_medicine",
    "health_programmes",
    "tulsi_plants",
    "nutritional_garden",
  ];

  for (const t of simpleTables) {
    try {
      const payload = minimalRowForTable(t, phone);
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

  // Multi-row tables
  const multiTables = {
    family_members: [
      { phone_number: phone, sr_no: 1, name: "Member A", age: 35, sex: "male" },
      { phone_number: phone, sr_no: 2, name: "Member B", age: 30, sex: "female" },
    ],
    crop_productivity: [{ phone_number: phone, sr_no: 1, crop_name: "Wheat", area_hectares: 5 }],
    animals: [{ phone_number: phone, sr_no: 1, animal_type: "Cow", number_of_animals: 2 }],
    bank_accounts: [{ phone_number: phone, sr_no: 1, member_name: "Member A", account_number: "XXXX" }],
    malnourished_children_data: [{ phone_number: phone, child_id: "c1", child_name: "Child A", weight: 12.3 }],
    child_diseases: [{ phone_number: phone, child_id: "c1", sr_no: 1, disease_name: "Fever" }],
    aadhaar_scheme_members: [{ phone_number: phone, sr_no: 1, family_member_name: "Member A", have_card: "yes" }],
    ayushman_scheme_members: [{ phone_number: phone, sr_no: 1, family_member_name: "Member A", have_card: "yes" }],
    family_id_scheme_members: [{ phone_number: phone, sr_no: 1, family_member_name: "Member A", have_card: "yes" }],
    ration_scheme_members: [{ phone_number: phone, sr_no: 1, family_member_name: "Member A", have_card: "yes" }],
    samagra_scheme_members: [{ phone_number: phone, sr_no: 1, family_member_name: "Member A", have_card: "yes" }],
    tribal_scheme_members: [{ phone_number: phone, sr_no: 1, family_member_name: "Member A", have_card: "yes" }],
    handicapped_scheme_members: [{ phone_number: phone, sr_no: 1, family_member_name: "Member A", have_card: "no" }],
    pension_scheme_members: [{ phone_number: phone, sr_no: 1, family_member_name: "Member A", have_card: "no" }],
    widow_scheme_members: [{ phone_number: phone, sr_no: 1, family_member_name: "Member A", have_card: "no" }],
    vb_gram_members: [{ phone_number: phone, sr_no: 1, member_name: "Member A" }],
    pm_kisan_members: [{ phone_number: phone, sr_no: 1, member_name: "Member A" }],
    pm_kisan_samman_members: [{ phone_number: phone, sr_no: 1, member_name: "Member A" }],
    bank_accounts: [{ phone_number: phone, sr_no: 1, member_name: "Member A", account_number: "AC123" }],
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

  console.log("Family seeding complete. Reload app and Refresh.");
}

main().catch((e) => {
  console.error("Seed script failed", e);
  process.exit(1);
});