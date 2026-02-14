import React from 'react';

export default function Header(){
  return (
    <header style={{ padding: 12, borderBottom: '1px solid #e6e8eb', background: 'white' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ fontWeight: 600 }}>Supabase Admin</div>
        <div>
          <button style={{ marginRight: 8 }}>Account</button>
        </div>
      </div>
    </header>
  );
}
