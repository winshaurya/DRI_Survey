import React from 'react';

export default function Sidebar(){
  return (
    <aside style={{ width: 220, borderRight: '1px solid #e6e8eb', background: '#fff' }}>
      <div style={{ padding: 16 }}>
        <div style={{ fontWeight: 700, marginBottom: 12 }}>Dashboard</div>
        <nav>
          <ul style={{ listStyle: 'none', padding: 0 }}>
            <li style={{ marginBottom: 8 }}>Home</li>
            <li style={{ marginBottom: 8 }}>Family Surveys</li>
            <li style={{ marginBottom: 8 }}>Village Surveys</li>
            <li style={{ marginBottom: 8 }}>Exports</li>
          </ul>
        </nav>
      </div>
    </aside>
  );
}
