import React, { useEffect, useState } from "react";
import { Box, Typography, Button, LinearProgress, Stack } from "@mui/material";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { useNavigate } from "react-router-dom";
import { getVillageSessions, getVillageSessionDetails } from "../services/api";
import { exportToExcel } from "../utils/exporter";

export default function VillageList() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    setLoading(true);
    try {
      const data = await getVillageSessions();
      setRows(data || []);
    } catch (error) {
      console.error("Failed to load village sessions", error);
    } finally {
      setLoading(false);
    }
  }

  const handleExport = async (sessionId: string) => {
    try {
      const fullData = await getVillageSessionDetails(sessionId);
      exportToExcel(fullData, "village");
    } catch (e) {
      console.error("Export failed", e);
      alert("Export failed. See console.");
    }
  };

  const columns: GridColDef[] = [
    { field: "village_name", headerName: "Village Name", flex: 1, minWidth: 150 },
    { field: "village_code", headerName: "Village Code", width: 120 },
    { field: "panchayat", headerName: "Panchayat", flex: 1, minWidth: 150 },
    { field: "block", headerName: "Block", width: 120 },
    { field: "district", headerName: "District", width: 120 },
    { field: "surveyor_email", headerName: "Surveyor Email", flex: 1, minWidth: 180 },
    { field: "status", headerName: "Status", width: 120 },
    { field: "created_at", headerName: "Created At", width: 180,
      valueFormatter: (params) => new Date(params.value).toLocaleString()
    },
    {
      field: "actions",
      headerName: "Actions",
      width: 200,
      renderCell: (params) => (
        <Stack direction="row" spacing={1} sx={{ height: '100%', alignItems: 'center' }}>
          <Button 
            size="small" 
            variant="outlined" 
            onClick={() => navigate(`/village/${params.row.session_id}`)}
          >
            View
          </Button>
          <Button 
            size="small" 
            variant="outlined" 
            color="success"
            onClick={() => handleExport(params.row.session_id)}
          >
            Export
          </Button>
        </Stack>
      ),
    },
  ];

  return (
    <Box sx={{ height: 600, width: "100%" }}>
      <Typography variant="h5" gutterBottom>
        Village Surveys
      </Typography>
      {loading && <LinearProgress />}
      <DataGrid
        rows={rows}
        columns={columns}
        getRowId={(row) => row.session_id}
        slots={{ toolbar: GridToolbar }}
        slotProps={{ toolbar: { showQuickFilter: true } }}
        initialState={{
          pagination: { paginationModel: { pageSize: 25 } },
          sorting: { sortModel: [{ field: "created_at", sort: "desc" }] },
        }}
      />
    </Box>
  );
}
