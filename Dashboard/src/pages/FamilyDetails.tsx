import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { Box, Typography, Button, Paper, Tabs, Tab, CircularProgress, Grid, Divider } from "@mui/material";
import { getFamilySessionDetails } from "../services/api";
import { FAMILY_TABLES } from "../consts";
import RelatedDataGrid from "../components/RelatedDataGrid";
import { exportToExcel } from "../utils/exporter";

export default function FamilyDetails() {
  const { id } = useParams(); // phone_number
  const navigate = useNavigate();
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [tabIndex, setTabIndex] = useState(0);

  useEffect(() => {
    if (id) loadDetails(id);
  }, [id]);

  async function loadDetails(phoneNumber: string) {
    try {
      const details = await getFamilySessionDetails(phoneNumber);
      setData(details);
    } catch (e) {
      console.error(e);
      alert("Failed to load details");
    } finally {
      setLoading(false);
    }
  }

  if (loading) return <Box sx={{ p: 4, display: 'flex', justifyContent: 'center' }}><CircularProgress /></Box>;
  if (!data) return <Box sx={{ p: 4 }}><Typography>No data found.</Typography></Box>;

  // Filter tables that have data
  const activeTables = FAMILY_TABLES.filter(t => Array.isArray(data[t]) && data[t].length > 0);

  return (
    <Box>
      <Box sx={{ mb: 3, display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <Button onClick={() => navigate(-1)}>Back</Button>
        <Typography variant="h5">Family Survey: {id}</Typography>
        <Button variant="contained" onClick={() => exportToExcel(data, "family")}>Export Excel</Button>
      </Box>

      {/* Main Session Info */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6" gutterBottom>Session Details</Typography>
        <Grid container spacing={2}>
            {Object.entries(data).filter(([k]) => !FAMILY_TABLES.includes(k)).map(([key, val]) => (
                <Grid item xs={12} sm={6} md={3} key={key}>
                    <Typography variant="caption" color="text.secondary" display="block">
                        {key.replace(/_/g, ' ').toUpperCase()}
                    </Typography>
                    <Typography>{String(val)}</Typography>
                </Grid>
            ))}
        </Grid>
      </Paper>

      {/* Related Tables Tabs */}
      <Box sx={{ borderBottom: 1, borderColor: "divider" }}>
        <Tabs 
            value={tabIndex} 
            onChange={(_, v) => setTabIndex(v)} 
            variant="scrollable"
            scrollButtons="auto"
            allowScrollButtonsMobile
        >
          {activeTables.map((t) => (
            <Tab key={t} label={t.replace(/_/g, " ")} />
          ))}
        </Tabs>
      </Box>

      {activeTables.map((t, index) => (
        <div role="tabpanel" hidden={tabIndex !== index} key={t}>
          {tabIndex === index && (
            <Box sx={{ py: 3 }}>
              <RelatedDataGrid data={data[t]} />
            </Box>
          )}
        </div>
      ))}
      
      {activeTables.length === 0 && (
          <Typography sx={{ p: 4, textAlign: 'center', color: 'text.secondary' }}>
              No related data found for this session.
          </Typography>
      )}
    </Box>
  );
}
