
import React from 'react';
import { Home, Users, Map, Download } from 'lucide-react';
import { motion } from 'framer-motion';

export default function Sidebar() {
  return (
    <motion.aside
      initial={{ x: -40, opacity: 0 }}
      animate={{ x: 0, opacity: 1 }}
      transition={{ type: 'spring', stiffness: 80 }}
      style={{
        width: 230,
        borderRight: '1px solid #e6e8eb',
        background: 'linear-gradient(180deg, #f1f5f9 0%, #e0e7ef 100%)',
        minHeight: '100vh',
        boxShadow: '2px 0 16px 0 rgba(0,0,0,0.03)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'flex-start',
      }}
    >
      <div style={{ padding: 24 }}>
        <div style={{ fontWeight: 800, marginBottom: 18, fontSize: 18, letterSpacing: 1, color: '#6366f1', display: 'flex', alignItems: 'center', gap: 8 }}>
          <Home size={20} /> Dashboard
        </div>
        <nav>
          <ul style={{ listStyle: 'none', padding: 0, margin: 0, display: 'flex', flexDirection: 'column', gap: 10 }}>
            <li style={{ display: 'flex', alignItems: 'center', gap: 10, fontWeight: 500, color: '#0f172a', cursor: 'pointer', padding: '8px 0', borderRadius: 8, transition: 'background 0.2s' }}>
              <Home size={18} /> Home
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: 10, fontWeight: 500, color: '#0f172a', cursor: 'pointer', padding: '8px 0', borderRadius: 8, transition: 'background 0.2s' }}>
              <Users size={18} /> Family Surveys
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: 10, fontWeight: 500, color: '#0f172a', cursor: 'pointer', padding: '8px 0', borderRadius: 8, transition: 'background 0.2s' }}>
              <Map size={18} /> Village Surveys
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: 10, fontWeight: 500, color: '#0f172a', cursor: 'pointer', padding: '8px 0', borderRadius: 8, transition: 'background 0.2s' }}>
              <Download size={18} /> Exports
            </li>
          </ul>
        </nav>
      </div>
    </motion.aside>
  );
}
