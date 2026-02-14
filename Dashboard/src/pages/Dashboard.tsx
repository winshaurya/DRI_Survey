
import React from 'react';
import LineChart from '../components/charts/LineChart';
import Confetti from 'react-canvas-confetti';
import toast, { Toaster } from 'react-hot-toast';

export default function Dashboard(){
  return (
    <div>
      <section style={{ display: 'grid', gridTemplateColumns: '1fr 320px', gap: 16 }}>
        <div className="card">
          <h3>Survey submissions</h3>
          <LineChart />
        </div>
        <div className="card">
          <h3>Quick stats</h3>
          <ul>
            <li>Total family surveys: —</li>
            <li>Total village surveys: —</li>
            <li>Active surveyors: —</li>
          </ul>
        </div>
      </section>
    </div>
  );
}
import React, { useEffect, useState } from 'react'
import Header from '../components/Header'
import ChartCard from '../components/ChartCard'

export default function Dashboard() {
  const [counts, setCounts] = useState<number[]>([])
  const [loading, setLoading] = useState(false)
  const [tables, setTables] = useState<string[] | null>(null)

  useEffect(() => {
    async function loadCounts() {
      setLoading(true)
      try {
        const res = await fetch('/api/forms-count')
        const json = await res.json()
        setCounts([json.count ?? 0, Math.max(0, (json.count ?? 0) - 5), Math.max(0, Math.floor((json.count ?? 0) / 2))])
      } catch (err) {
        console.error(err)
        setCounts([0, 0, 0])
      } finally {
        setLoading(false)
      }
    }

    async function loadTables() {
      try {
        const res = await fetch('/api/schema')
        const json = await res.json()
        if (res.ok) setTables(json.tables ?? null)
        else setTables(null)
      } catch (err) {
        console.warn('Could not fetch schema', err)
        setTables(null)
      }
    }

    loadCounts()
    loadTables()
  }, [])

  return (
    <div className="dashboard-root">
      <Header />
      <main className="dashboard-grid">
        <section className="cards">
          <ChartCard title="Responses Overview" data={counts} loading={loading} />
        </section>
        <aside className="sidebar">
          <div className="panel">
            <h3>Schema</h3>
            {tables ? (
              <ul>
                {tables.map((t) => (
                  <li key={t}>{t}</li>
                ))}
              </ul>
            ) : (
              <p className="muted">Schema not available — set `SUPABASE_SERVICE_ROLE_KEY` in Vercel env.</p>
            )}
          </div>

          <div className="panel" style={{ marginTop: 12 }}>
            <h3>Admin completeness (service role)</h3>
            <AdminCompletenessPanel />
          </div>
        </aside>
      </main>
    </div>
  )
}

function AdminCompletenessPanel() {
  const [surveyType, setSurveyType] = React.useState<'family' | 'village'>('family');
  const [identifierKey, setIdentifierKey] = React.useState('phone_number');
  const [identifierValue, setIdentifierValue] = React.useState('');
  const [loading, setLoading] = React.useState(false);
  const [result, setResult] = React.useState<any>(null);
  const [showConfetti, setShowConfetti] = React.useState(false);

  async function runAdmin() {
    setLoading(true);
    setShowConfetti(false);
    try {
      const payload: any = { surveyType, identifierKey, identifierValue, sampleLimit: 5, maxRows: 2000 };
      const res = await fetch('/api/admin/completeness', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const json = await res.json();
      setResult(json);
      if (!json.error) {
        setShowConfetti(true);
        toast.success('Admin scan complete!');
        setTimeout(() => setShowConfetti(false), 2200);
      }
    } catch (err) {
      console.error(err);
      setResult({ error: 'request failed' });
      toast.error('Scan failed');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div style={{ position: 'relative' }}>
      <Toaster position="top-center" />
      {showConfetti && (
        <div style={{ position: 'absolute', left: 0, top: 0, width: '100%', height: 180, pointerEvents: 'none', zIndex: 20 }}>
          <Confetti width={400} height={180} recycle={false} numberOfPieces={120} />
        </div>
      )}
      <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
        <select value={surveyType} onChange={e => setSurveyType(e.target.value as any)}>
          <option value="family">family</option>
          <option value="village">village</option>
        </select>
        <input value={identifierKey} onChange={e => setIdentifierKey(e.target.value)} style={{ width: 140 }} />
        <input placeholder="identifier value" value={identifierValue} onChange={e => setIdentifierValue(e.target.value)} />
        <button onClick={runAdmin} disabled={loading}>{loading ? 'Scanning…' : 'Run admin scan'}</button>
      </div>

      {result && (
        <div style={{ marginTop: 8 }}>
          {result.error ? (
            <div className="muted">{String(result.error)}</div>
          ) : (
            <div>
              <div>
                <strong>Tables:</strong> {result.totalTables} — <strong>Columns:</strong> {result.totalColumns} — <strong>Filled:</strong> {result.columnsFilled}
              </div>
              <pre style={{ maxHeight: 220, overflow: 'auto' }}>{JSON.stringify(result.tables ?? result, null, 2)}</pre>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
