import { createClient } from '@supabase/supabase-js';
import type { VercelRequest, VercelResponse } from '@vercel/node';

export default async function handler(req: VercelRequest, res: VercelResponse){
  const SUPABASE_URL = process.env.SUPABASE_URL;
  const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY){
    res.status(500).json({ error: 'Missing supabase service role key on server' });
    return;
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  // Example aggregated query: count family surveys by day (assumes created_at column exists)
  const { data, error } = await supabase.rpc('count_family_surveys_by_day');
  if (error){
    // Fallback: simple count
    const fallback = await supabase.from('family_survey_sessions').select('id', { count: 'exact' });
    res.status(200).json({ total_family: fallback.count ?? 0 });
    return;
  }

  res.status(200).json({ data });
}
