export function toCsv(rows: any[], fields?: string[]){
  if (!rows || rows.length === 0) return '';
  const keys = fields ?? Object.keys(rows[0]);
  const header = keys.join(',');
  const lines = rows.map(r => keys.map(k => JSON.stringify(r[k] ?? '')).join(','));
  return [header, ...lines].join('\n');
}

export function downloadCsv(content: string, filename = 'export.csv'){
  const blob = new Blob([content], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = filename; a.click();
  URL.revokeObjectURL(url);
}
