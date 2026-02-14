import { createClient } from '@supabase/supabase-js';
import type { VercelRequest, VercelResponse } from '@vercel/node';

export default async function handler(req: VercelRequest, res: VercelResponse){
  // Simple serverless export example. This endpoint must be protected (check JWT/allowlist) before use.
  const SUPABASE_URL = process.env.SUPABASE_URL;
  const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY){
    res.status(500).json({ error: 'Missing supabase service role key on server' });
    return;
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  // Example: accept ?type=family or ?type=village
  const type = String(req.query.type ?? 'family');
  const table = type === 'village' ? 'village_survey_sessions' : 'family_survey_sessions';

  const { data, error } = await supabase.from(table).select('*').limit(10000);
  if (error){
    res.status(500).json({ error: error.message });
    return;
  }

  // Convert to CSV (very small helper)
  const keys = data && data.length > 0 ? Object.keys(data[0]) : [];
  const header = keys.join(',') + '\n';
  const rows = (data ?? []).map((r:any) => keys.map(k => JSON.stringify(r[k] ?? '')).join(',')).join('\n');
  const csv = header + rows;

  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', `attachment; filename="${table}.csv"`);
  res.status(200).send(csv);
}
