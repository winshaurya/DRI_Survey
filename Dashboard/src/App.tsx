import React, { useState } from "react";
import Header from "./components/ui/Header";
import Sidebar from "./components/ui/Sidebar";

export default function App() {
  const [dark, setDark] = useState(false);
  return (
    <div
      className="app-root"
      style={{
        display: "flex",
        minHeight: "100vh",
        background: dark
          ? "linear-gradient(120deg, #232526 0%, #414345 100%)"
          : "linear-gradient(120deg, #f8fafc 0%, #e0e7ef 100%)",
        transition: 'background 0.5s',
      }}
    >
      <Sidebar />
      <div style={{ flex: 1, minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
        {/* Pass theme toggle to Header */}
        <Header />
        <main
          style={{
            padding: 32,
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            backdropFilter: 'blur(12px)',
            borderRadius: 24,
            margin: 24,
            boxShadow: dark
              ? '0 8px 32px 0 #0005'
              : '0 8px 32px 0 #64748b22',
            background: dark
              ? 'rgba(36,37,38,0.7)'
              : 'rgba(255,255,255,0.7)',
            transition: 'background 0.5s, box-shadow 0.5s',
          }}
        >
          <h1 style={{ marginBottom: 12, fontSize: 32, fontWeight: 800, letterSpacing: 1, color: dark ? '#fbbf24' : '#6366f1' }}>Dashboard</h1>
          <p style={{ fontSize: 18, color: dark ? '#f3f4f6' : '#334155' }}>
            Welcome — scaffold ready. Create pages under <code>src/pages</code>.
          </p>
        </main>
      </div>
    </div>
  );
}
