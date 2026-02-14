import React, { useState } from 'react';
import {
  getSurveySessionCompleteness,
  filterAndSortStats,
  type ColumnStat,
} from '../../lib/surveyCompleteness';
import { fetchCompletenessAdmin } from '../../lib/adminApi';

export default function VillageDetail(){
  const [identifierKey, setIdentifierKey] = useState('shine_code');
  const [identifierValue, setIdentifierValue] = useState('');
  const [useServer, setUseServer] = useState(true);
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<null | { totalTables: number; totalColumns: number; columnsFilled: number; stats: ColumnStat[] }>(null);
  const [search, setSearch] = useState('');
  const [minPct, setMinPct] = useState(0);

  async function runCheck(){
    if (!identifierValue) return alert('Enter identifier value');
    setLoading(true);
    try {
      if (useServer) {
        const payload: any = { surveyType: 'village', identifierKey, identifierValue, tables: ['village_survey_sessions'], sampleLimit: 5, maxRows: 2000 };
        const res: any = await fetchCompletenessAdmin(payload);
        const stats = (res.tables ?? []).flatMap((t: any) => (t.stats ?? []).map((s: any) => ({ table: t.table, ...s })));
        setResult({ totalTables: res.totalTables, totalColumns: res.totalColumns, columnsFilled: res.columnsFilled, stats });
      } else {
        const res = await getSurveySessionCompleteness('village', identifierKey, identifierValue, ['village_survey_sessions']);
        setResult({ totalTables: res.totalTables, totalColumns: res.totalColumns, columnsFilled: res.columnsFilled, stats: res.stats });
      }
    } catch (err: any) {
      console.error(err);
      alert(err.message ?? String(err));
    } finally { setLoading(false); }
  }

  const displayed = result ? filterAndSortStats(result.stats, { searchTerm: search, minFilledPercent: minPct }) : [];

  return (
    <div>
      <h2>Village Survey Detail</h2>
      <p>Run a per-column completeness check for a village survey session (default id = <code>shine_code</code>). Uses the server-side admin API by default.</p>

      <div style={{ marginBottom: 12 }}>
        <select value={identifierKey} onChange={e => setIdentifierKey(e.target.value)}>
          <option value="session_id">session_id</option>
          <option value="shine_code">shine_code</option>
        </select>
        <input placeholder="identifier value" value={identifierValue} onChange={e => setIdentifierValue(e.target.value)} style={{ marginLeft: 8 }} />
        <label style={{ marginLeft: 8 }}><input type="checkbox" checked={useServer} onChange={e => setUseServer(e.target.checked)} /> Use admin (service role)</label>
        <button onClick={runCheck} disabled={loading} style={{ marginLeft: 8 }}>{loading ? 'Checking...' : 'Run completeness'}</button>
      </div>

      {result && (
        <div>
          <div style={{ marginBottom: 8 }}>
            <strong>Tables scanned:</strong> {result.totalTables} — <strong>Columns:</strong> {result.totalColumns} — <strong>Columns filled:</strong> {result.columnsFilled}
          </div>

          <div style={{ marginBottom: 8 }}>
            <label>Search column/value: <input value={search} onChange={e => setSearch(e.target.value)} /></label>
            <label style={{ marginLeft: 12 }}>Min % filled: <input type="number" value={minPct} onChange={e => setMinPct(Number(e.target.value || 0))} style={{ width: 70 }} />%</label>
          </div>

          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr>
                <th style={{ textAlign: 'left', borderBottom: '1px solid #ddd' }}>table</th>
                <th style={{ textAlign: 'left', borderBottom: '1px solid #ddd' }}>column</th>
                <th style={{ textAlign: 'left', borderBottom: '1px solid #ddd' }}>filled / total</th>
                <th style={{ textAlign: 'left', borderBottom: '1px solid #ddd' }}>filled %</th>
                <th style={{ textAlign: 'left', borderBottom: '1px solid #ddd' }}>examples</th>
              </tr>
            </thead>
            <tbody>
              {displayed.map(row => (
                <tr key={`${row.table}.${row.column}`}>
                  <td style={{ padding: '6px 4px' }}>{row.table}</td>
                  <td style={{ padding: '6px 4px' }}>{row.column}</td>
                  <td style={{ padding: '6px 4px' }}>{row.filledCount} / {row.totalRows}</td>
                  <td style={{ padding: '6px 4px' }}>{row.filledPercent}%</td>
                  <td style={{ padding: '6px 4px' }}>{row.examples.slice(0,3).map((e,i) => <span key={i} style={{ marginRight: 6 }}>{String(e)}</span>)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
