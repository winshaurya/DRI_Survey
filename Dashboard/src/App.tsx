import { useEffect, useState } from "react";
import {
  Box,
  Tabs,
  Tab,
  Paper,
  Typography,
  Button,
  TextField,
  CircularProgress,
  Dialog,
  DialogTitle,
  DialogContent,
} from "@mui/material";
import { supabase } from "./services/supabase";
import RelatedTables from "./components/RelatedTables";
import logo from "../images/logo.png";
import UsersPage from "./pages/UsersPage";

/**
 * Clean, minimal dashboard:
 * - Only uses fetched data (no demo)
 * - Renders a simple HTML table to avoid DataGrid styling conflicts
 * - View button opens a JSON details dialog
 * - Removed repetitive/demo code
 */

// section of the app (survey tabs or user management)
export type Section = "village" | "family" | "users";

export default function App() {
  const [section, setSection] = useState<Section>("village");
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [search, setSearch] = useState("");
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [activeRow, setActiveRow] = useState<any | null>(null);

  useEffect(() => {
    if (section !== "users") {
      loadSessions();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [section]);

  async function loadSessions() {
    setLoading(true);
    try {
      const table = section === "village" ? "village_survey_sessions" : "family_survey_sessions";
      const { data, error } = await supabase.from(table).select("*").neq("is_deleted", 1).limit(500);
      if (error) {
        console.warn("Supabase query error:", error);
        setRows([]);
      } else {
        setRows(Array.isArray(data) ? data : []);
      }
    } catch (e) {
      console.error(e);
      setRows([]);
    } finally {
      setLoading(false);
    }
  }

  const filtered = rows.filter((r) =>
    !search ? true : Object.values(r).join(" ").toLowerCase().includes(search.toLowerCase())
  );

  const columns = filtered[0]
    ? Object.keys(filtered[0])
    : section === "village"
    ? ["session_id", "village_name", "state", "district", "status", "created_at"]
    : ["phone_number", "village_name", "district", "status", "survey_date", "created_at"];

  return (
    <Box sx={{ minHeight: "100vh", p: 4, background: "var(--bg-body)" }}>
      <Box sx={{ maxWidth: 1200, mx: "auto" }}>
        <Box sx={{ display: "flex", alignItems: "center", gap: 2, mb: 3 }}>
          <Box
            sx={{
              width: 44,
              height: 44,
              borderRadius: 2,
              background: "#fff",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              overflow: "hidden",
            }}
          >
            <img src={logo} alt="Logo" style={{ width: "100%", height: "100%", objectFit: "contain", background: "#fff" }} />
          </Box>

          <Box>
            <Typography variant="h5" sx={{ fontWeight: 700 }}>
              DRI PRA Dashbard
            </Typography>
            
          </Box>

          <Box sx={{ flex: 1 }} />

          {section !== "users" && (
            <Button onClick={() => loadSessions()} sx={{ mr: 1 }}>
              Refresh
            </Button>
          )}
        </Box>

        <Paper sx={{ p: 2 }}>
          <Box sx={{ display: "flex", gap: 2, alignItems: "center", mb: 2 }}>
            <Tabs value={section} onChange={(_, v) => setSection(v as Section)}>
              <Tab label="Village" value="village" />
              <Tab label="Family" value="family" />
              <Tab label="Users" value="users" />
            </Tabs>

            <Box sx={{ flex: 1 }} />

            {section !== "users" && (
              <TextField
                size="small"
                placeholder="Search"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                sx={{ width: 320 }}
              />
            )}
          </Box>

          {section === "users" ? (
            <UsersPage />
          ) : loading ? (
            <Box sx={{ py: 6, textAlign: "center" }}>
              <CircularProgress />
            </Box>
          ) : (
            <>
              <div style={{ overflowX: "auto" }}>
                <table style={{ width: "100%", borderCollapse: "collapse" }}>
                  <thead>
                    <tr>
                      {columns.map((c) => (
                        <th
                          key={c}
                          style={{
                            textAlign: "left",
                            padding: "10px 12px",
                            borderBottom: "1px solid var(--muted-2)",
                            background: "var(--card)",
                            fontWeight: 700,
                          }}
                        >
                          {String(c).replace(/_/g, " ").replace(/\b\w/g, (s) => s.toUpperCase())}
                        </th>
                      ))}
                      <th style={{ padding: "10px 12px", borderBottom: "1px solid var(--muted-2)" }}>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filtered.length === 0 ? (
                      <tr>
                        <td colSpan={columns.length + 1} style={{ padding: 20, color: "var(--muted)" }}>
                          No rows to display.
                        </td>
                      </tr>
                    ) : (
                      filtered.map((row, i) => (
                        <tr
                          key={row.id ?? row.session_id ?? row.phone_number ?? i}
                          style={{ borderBottom: "1px solid #f1f5f9", cursor: "pointer" }}
                          onClick={() => {
                            setActiveRow(row);
                            setDetailsOpen(true);
                          }}
                        >
                          {columns.map((c) => (
                            <td key={c} style={{ padding: "10px 12px", verticalAlign: "top", whiteSpace: "pre-wrap" }}>
                              {row[c] === null || row[c] === undefined ? "" : String(row[c])}
                            </td>
                          ))}
                          <td style={{ padding: "10px 12px" }}>
                            <Button
                              size="small"
                              onClick={(e) => {
                                e.stopPropagation();
                                setActiveRow(row);
                                setDetailsOpen(true);
                              }}
                              sx={{ mr: 1 }}
                            >
                              View
                            </Button>
                            <Button
                              size="small"
                              onClick={(e) => {
                                e.stopPropagation();
                                const blob = new Blob([JSON.stringify(row, null, 2)], { type: "application/json" });
                                const url = URL.createObjectURL(blob);
                                const a = document.createElement("a");
                                a.href = url;
                                a.download = `session_${section}_${section === "village" ? row?.session_id : row?.phone_number}.json`;
                                a.click();
                                URL.revokeObjectURL(url);
                              }}
                            >
                              Export
                            </Button>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </>
          )}
        </Paper>

        {section !== "users" && (
          <Dialog open={detailsOpen} onClose={() => setDetailsOpen(false)} fullWidth maxWidth="xl">
            <DialogTitle>
              Session — {section} — {(section === "village" ? activeRow?.session_id : activeRow?.phone_number) ?? ""}
            </DialogTitle>
            <DialogContent dividers>
              <Box sx={{ display: "flex", gap: 2, flexDirection: "column" }}>
                <Paper sx={{ p: 2, background: "var(--card)" }}>
                  <pre style={{ whiteSpace: "pre-wrap", wordBreak: "break-word", margin: 0 }}>
                    {activeRow ? JSON.stringify(activeRow, null, 2) : "No row selected"}
                  </pre>
                </Paper>

                {activeRow ? (
                  <RelatedTables
                    tab={section as "village" | "family"}
                    pk={(section === "village" ? activeRow?.session_id : activeRow?.phone_number) ?? ""}
                    keyField={section === "village" ? "session_id" : "phone_number"}
                    onClose={() => setDetailsOpen(false)}
                  />
                ) : null}
              </Box>
            </DialogContent>
          </Dialog>
        )}
      </Box>
    </Box>
  );
}
