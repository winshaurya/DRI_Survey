import React, { useEffect, useState } from "react";
import { Box, Typography, Button, LinearProgress, Stack } from "@mui/material";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { useNavigate } from "react-router-dom";
import { getFamilySessions, getFamilySessionDetails } from "../services/api";
import { exportToExcel } from "../utils/exporter";

export default function FamilyList() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    setLoading(true);
    try {
      const data = await getFamilySessions();
      setRows(data || []);
    } catch (error) {
      console.error("Failed to load family sessions", error);
    } finally {
      setLoading(false);
    }
  }

  const handleExport = async (phoneNumber: string) => {
    try {
      // Show some loading indicator?
      const fullData = await getFamilySessionDetails(phoneNumber);
      exportToExcel(fullData, "family");
    } catch (e) {
      console.error("Export failed", e);
      alert("Export failed. See console.");
    }
  };

  const columns: GridColDef[] = [
    { field: "phone_number", headerName: "Phone Number", flex: 1, minWidth: 150 },
    { field: "surveyor_name", headerName: "Surveyor", flex: 1, minWidth: 150 },
    { field: "village_name", headerName: "Village", flex: 1, minWidth: 150 },
    { field: "district", headerName: "District", flex: 1, minWidth: 120 },
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
            onClick={() => navigate(`/family/${params.row.phone_number}`)}
          >
            View
          </Button>
          <Button 
            size="small" 
            variant="outlined" 
            color="success"
            onClick={() => handleExport(params.row.phone_number)}
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
        Family Surveys
      </Typography>
      {loading && <LinearProgress />}
      <DataGrid
        rows={rows}
        columns={columns}
        getRowId={(row) => row.phone_number}
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
