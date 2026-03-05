import React from "react";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { Box, Typography } from "@mui/material";

type Props = {
  data: any[];
  title?: string;
};

export default function RelatedDataGrid({ data, title }: Props) {
  if (!data || data.length === 0) {
    return <Typography sx={{ p: 2, fontStyle: 'italic', color: 'text.secondary' }}>No data available.</Typography>;
  }

  // Auto-generate columns from the first row keys
  const firstRow = data[0];
  const columns: GridColDef[] = Object.keys(firstRow).map((key) => ({
    field: key,
    headerName: key.replace(/_/g, " ").toUpperCase(),
    flex: 1,
    minWidth: 150,
    valueFormatter: (params) => {
        if (typeof params.value === 'object') return JSON.stringify(params.value);
        return params.value;
    }
  }));

  return (
    <Box sx={{ height: 400, width: "100%", mt: 1 }}>
      {title && <Typography variant="h6">{title}</Typography>}
      <DataGrid
        rows={data}
        columns={columns}
        getRowId={(row) => row.id || row.sr_no || row.created_at || Math.random()} 
        slots={{ toolbar: GridToolbar }}
        density="compact"
        initialState={{
            pagination: { paginationModel: { pageSize: 10 } },
        }}
      />
    </Box>
  );
}
