
import React from 'react';
import { Sun, Moon, UserCircle2, Sparkles } from 'lucide-react';
import { motion } from 'framer-motion';
import { useState } from 'react';

export default function Header() {
  const [dark, setDark] = useState(false);
  return (
    <motion.header
      initial={{ y: -40, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ type: 'spring', stiffness: 80 }}
      style={{
        padding: 18,
        borderBottom: '1px solid #e6e8eb',
        background: dark
          ? 'linear-gradient(90deg, #232526 0%, #414345 100%)'
          : 'linear-gradient(90deg, #f8fafc 0%, #e0e7ef 100%)',
        boxShadow: '0 2px 16px 0 rgba(0,0,0,0.04)',
        backdropFilter: 'blur(8px)',
        position: 'sticky',
        top: 0,
        zIndex: 10,
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <motion.div
          initial={{ scale: 0.8 }}
          animate={{ scale: 1 }}
          transition={{ type: 'spring', stiffness: 120 }}
          style={{ display: 'flex', alignItems: 'center', gap: 10 }}
        >
          <Sparkles color={dark ? '#fbbf24' : '#6366f1'} size={28} />
          <span style={{ fontWeight: 700, fontSize: 22, letterSpacing: 1, background: dark ? 'linear-gradient(90deg,#fbbf24,#f472b6)' : 'linear-gradient(90deg,#6366f1,#06b6d4)', WebkitBackgroundClip: 'text', color: 'transparent', WebkitTextFillColor: 'transparent' }}>
            Edu Survey
          </span>
        </motion.div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <motion.button
            whileTap={{ scale: 0.85, rotate: 10 }}
            aria-label="Toggle theme"
            onClick={() => setDark((d) => !d)}
            style={{
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              outline: 'none',
              padding: 4,
            }}
          >
            {dark ? <Sun color="#fde68a" size={22} /> : <Moon color="#64748b" size={22} />}
          </motion.button>
          <motion.button
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.95 }}
            style={{
              background: dark ? '#18181b' : '#fff',
              border: '1px solid #e5e7eb',
              borderRadius: 8,
              padding: '6px 14px',
              fontWeight: 500,
              color: dark ? '#f3f4f6' : '#18181b',
              boxShadow: dark ? '0 2px 8px 0 #0002' : '0 2px 8px 0 #0001',
              display: 'flex',
              alignItems: 'center',
              gap: 6,
              cursor: 'pointer',
              transition: 'background 0.2s',
            }}
          >
            <UserCircle2 size={20} style={{ marginRight: 2 }} />
            Account
          </motion.button>
        </div>
      </div>
    </motion.header>
  );
}
