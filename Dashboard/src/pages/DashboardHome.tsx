import React from "react";
import { Box, Typography,  Paper, Grid } from "@mui/material";

export default function DashboardHome() {
  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Welcome to DRI PRA Dashboard
      </Typography>
      <Typography variant="body1" gutterBottom>
        Select a section from the sidebar to view survey data.
      </Typography>

      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid item xs={12} md={6}>
            <Paper sx={{ p: 3, height: '100%' }}>
                <Typography variant="h6">Family Surveys</Typography>
                <Typography variant="body2" color="text.secondary">
                    View detailed family data, including demographics, assets, schemes, and more.
                </Typography>
            </Paper>
        </Grid>
        <Grid item xs={12} md={6}>
            <Paper sx={{ p: 3, height: '100%' }}>
                <Typography variant="h6">Village Surveys</Typography>
                <Typography variant="body2" color="text.secondary">
                    View village infrastructure, resources, maps, and issues.
                </Typography>
            </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}
