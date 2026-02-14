import React from "react";
import Header from "./components/ui/Header";
import Sidebar from "./components/ui/Sidebar";

export default function App() {
  return (
    <div className="app-root" style={{ display: "flex", minHeight: "100vh" }}>
      <Sidebar />
      <div style={{ flex: 1 }}>
        <Header />
        <main style={{ padding: 20 }}>
          <h1 style={{ marginBottom: 12 }}>Dashboard</h1>
          <p>Welcome — scaffold ready. Create pages under <code>src/pages</code>.</p>
        </main>
      </div>
    </div>
  );
}
