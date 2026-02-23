
import { useEffect, useState } from "react";
import {
  listUsers,
  createUser,
  deleteUser,
} from "../services/supabase";
import { Box, Button, TextField, Typography } from "@mui/material";

interface SupaUser {
  id: string;
  email: string | null;
  phone: string | null;
  user_metadata: any;
  app_metadata: any;
  confirmed_at: string | null;
  last_sign_in_at: string | null;
  created_at: string | null;
  role?: string; // added when enriching
}

export default function UsersPage() {
  const [users, setUsers] = useState<SupaUser[]>([]);
  // log for debugging
  useEffect(() => {
    console.log("UsersPage: users array", users);
  }, [users]);
  // debug flag (toggle raw JSON display)
  const [debug, setDebug] = useState(false);
  const [loading, setLoading] = useState(false);

  const [newEmail, setNewEmail] = useState("");
  const [newPassword, setNewPassword] = useState("");

  const fetch = async () => {
    setLoading(true);
    try {
      const data = await listUsers();
      // attach role field for easier display
      const enriched = data.map((u: any) => ({
        ...u,
        role: u.app_metadata?.role || "",
      }));
      setUsers(enriched as any);
    } catch (err: any) {
      console.error(err);
      alert(err.message || "failed to load users");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetch();
  }, []);


  const handleCreate = async () => {
    if (!newEmail || !newPassword) return;
    setLoading(true);
    try {
      await createUser({ email: newEmail, password: newPassword });
      setNewEmail("");
      setNewPassword("");
      fetch();
    } catch (err: any) {
      console.error(err);
      alert(err.message || "failed to create user");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        User management
      </Typography>
      <Button size="small" onClick={() => setDebug((d) => !d)} sx={{ mb: 2 }}>
        {debug ? "Hide raw data" : "Show raw data"}
      </Button>

      <Box sx={{ display: "flex", gap: 2, mb: 2, alignItems: "flex-end" }}>
        <TextField
          label="Email"
          value={newEmail}
          onChange={(e) => setNewEmail(e.target.value)}
          size="small"
        />
        <TextField
          label="Password"
          type="password"
          value={newPassword}
          onChange={(e) => setNewPassword(e.target.value)}
          size="small"
        />
        <Button variant="contained" onClick={handleCreate} disabled={loading || !newEmail || !newPassword}>
          Add user
        </Button>
      </Box>

      {debug && <pre style={{ whiteSpace: "pre-wrap", maxHeight: 240, overflow: "auto" }}>{JSON.stringify(users, null, 2)}</pre>}
      <div style={{ overflowX: "auto" }}>
        <table style={{ width: "100%", borderCollapse: "collapse" }}>
          <thead>
            <tr>
              {["id", "email", "role", "confirmed_at", "last_sign_in_at", "created_at"].map((col) => (
                <th
                  key={col}
                  style={{
                    textAlign: "left",
                    padding: "10px 12px",
                    borderBottom: "1px solid var(--muted-2)",
                    background: "var(--card)",
                    fontWeight: 700,
                  }}
                >
                  {String(col)
                    .replace(/_/g, " ")
                    .replace(/\b\w/g, (s) => s.toUpperCase())}
                </th>
              ))}
              <th style={{ padding: "10px 12px", borderBottom: "1px solid var(--muted-2)" }}>
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {users.length === 0 ? (
              <tr>
                <td colSpan={7} style={{ padding: 20, color: "var(--muted)" }}>
                  No users to display.
                </td>
              </tr>
            ) : (
              users.map((u, i) => (
                <tr key={u.id ?? i} style={{ borderBottom: "1px solid #f1f5f9" }}>
                  <td style={{ padding: "10px 12px" }}>{u.id}</td>
                  <td style={{ padding: "10px 12px" }}>{u.email}</td>
                  <td style={{ padding: "10px 12px" }}>{u.role}</td>
                  <td style={{ padding: "10px 12px" }}>{u.confirmed_at}</td>
                  <td style={{ padding: "10px 12px" }}>{u.last_sign_in_at}</td>
                  <td style={{ padding: "10px 12px" }}>{u.created_at}</td>
                  <td style={{ padding: "10px 12px" }}>
                    <Button
                      size="small"
                      onClick={() => alert(JSON.stringify(u, null, 2))}
                      sx={{ mr: 1 }}
                    >
                      View
                    </Button>
                    <Button
                      size="small"
                      onClick={async () => {
                        if (!window.confirm("Delete user '" + u.id + "' ?")) return;
                        setLoading(true);
                        try {
                          await deleteUser(u.id);
                          fetch();
                        } catch (e: any) {
                          console.error(e);
                          alert(e.message || "could not delete user");
                        } finally {
                          setLoading(false);
                        }
                      }}
                    >
                      Delete
                    </Button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </Box>
  );
}
