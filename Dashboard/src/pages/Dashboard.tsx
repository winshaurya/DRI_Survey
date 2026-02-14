import React from 'react';
import LineChart from '../components/charts/LineChart';

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
        </aside>
      </main>
    </div>
  )
}
