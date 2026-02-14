import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabaseClient';

export function useFetch(table: string, query: any = {}){
  const [data, setData] = useState<any[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<any>(null);

  useEffect(() => {
    let mounted = true;
    setLoading(true);
    supabase.from(table).select('*').limit(50)
      .then(res => { if (!mounted) return; setData(res.data ?? []); setError(res.error); setLoading(false); })
      .catch(err => { if (!mounted) return; setError(err); setLoading(false); });

    return () => { mounted = false; };
  }, [table]);

  return { data, loading, error };
}
