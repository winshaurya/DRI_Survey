export type AdminCompletenessRequest = {
  tables?: string[];
  surveyType?: 'family' | 'village';
  identifierKey?: string;
  identifierValue?: string | number;
  sampleLimit?: number;
  maxRows?: number;
};

export async function fetchCompletenessAdmin(opts: AdminCompletenessRequest) {
  const res = await fetch('/api/admin/completeness', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(opts),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(text || 'admin completeness failed');
  }
  return res.json();
}
