import React, { useState } from 'react';
import { supabase } from '../lib/supabaseClient';

export default function Login(){
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  async function handleLogin(e: React.FormEvent){
    e.preventDefault();
    setLoading(true);
    const { error } = await supabase.auth.signInWithOtp({ email });
    if (error) setMessage(error.message); else setMessage('Check your email for the magic link.');
    setLoading(false);
  }

  return (
    <div style={{ maxWidth: 420, margin: '40px auto' }} className="card">
      <h2>Sign in</h2>
      <form onSubmit={handleLogin}>
        <input value={email} onChange={e => setEmail(e.target.value)} placeholder="email" style={{ width: '100%', padding: 8, marginBottom: 8 }} />
        <button disabled={loading} style={{ padding: '8px 12px' }}>{loading ? 'Sending...' : 'Send magic link'}</button>
      </form>
      {message && <p style={{ marginTop: 12 }}>{message}</p>}
    </div>
  );
}
