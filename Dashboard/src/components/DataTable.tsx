/* eslint-disable react/jsx-key */
// DataTable: server-capable MUI DataGrid wrapper (TypeScript + React)

import * as React from "react";
import { DataGrid, GridToolbar } from "@mui/x-data-grid";
import type { GridColDef, GridRowsProp, GridSortModel } from "@mui/x-data-grid";
import { Box, Typography } from "@mui/material";

type Props = {
  data: any[];
  columns: string[];
  loading?: boolean;
  page?: number;
  pageSize?: number;
  rowCount?: number;
  sortModel?: GridSortModel;
  onPageChange?: (page: number) => void;
  onPageSizeChange?: (size: number) => void;
  onSortModelChange?: (model: GridSortModel) => void;
  onAction?: (action: "view" | "export", row: any) => void;
};

export default function DataTable({
  data,
  columns,
  loading = false,
  page = 0,
  pageSize = 10,
  rowCount = 0,
  sortModel = [],
  onPageChange,
  onPageSizeChange,
  onSortModelChange,
  onAction,
}: Props) {
  const gridColumns: GridColDef[] = columns.map((c) => ({
    field: c,
    headerName: String(c).replace(/_/g, " ").replace(/\b\w/g, (s) => s.toUpperCase()),
    flex: 1,
    minWidth: 120,
    sortable: true,
    valueGetter: (params: any) => {
      if (!params || !params.row) return "";
      try {
        return params.row[String(c)] ?? "";
      } catch {
        return "";
      }
    },
    valueFormatter: (params: any) => {
      const v = params?.value ?? (params?.row ? params.row[String(c)] : "");
      if (v === null || v === undefined) return "";
      if (typeof v === "object") return JSON.stringify(v);
      return String(v);
    },
  }));

  // add action column
  gridColumns.push({
    field: "__actions",
    headerName: "Actions",
    width: 130,
    sortable: false,
    filterable: false,
    renderCell: (params) => {
      return (
        <Box sx={{ display: "flex", gap: 1 }}>
          <button
            onClick={() => onAction && onAction("view", params.row)}
            style={{
              background: "transparent",
              border: "1px solid rgba(0,0,0,0.06)",
              padding: "6px 8px",
              borderRadius: 8,
              cursor: "pointer",
            }}
          >
            View
          </button>
          <button
            onClick={() => onAction && onAction("export", params.row)}
            style={{
              background: "#f7f9fb",
              border: "1px solid rgba(0,0,0,0.04)",
              padding: "6px 8px",
              borderRadius: 8,
              cursor: "pointer",
            }}
          >
            Export
          </button>
        </Box>
      );
    },
  });

  const rows: GridRowsProp = data.map((r, i) => ({ id: r.id ?? r.session_id ?? r.phone_number ?? i, ...r }));

  const NoRowsOverlay = () => (
    <Box sx={{ py: 6, textAlign: "center" }}>
      <Typography color="text.secondary">No sessions to display</Typography>
    </Box>
  );

  return (
    <div style={{ height: 520, width: "100%" }}>
      <DataGrid
        rows={rows}
        columns={gridColumns}
        getRowId={(row) => row.id}
        rowHeight={56}
        pagination
        paginationMode="server"
        sortingMode="server"
        rowCount={rowCount}
        pageSizeOptions={[10, 25, 50]}
        paginationModel={{ page, pageSize }}
        onPaginationModelChange={(model) => {
          if (model.page !== undefined && onPageChange) onPageChange(model.page);
          if (model.pageSize !== undefined && onPageSizeChange) onPageSizeChange(model.pageSize);
        }}
        sortModel={sortModel}
        onSortModelChange={(model) => onSortModelChange && onSortModelChange(model)}
        slots={{ toolbar: GridToolbar, noRowsOverlay: NoRowsOverlay }}
        disableRowSelectionOnClick
        onRowDoubleClick={(params) => onAction && onAction("view", params.row)}
        loading={loading}
        getRowSpacing={(params) => ({
          top: params.isFirstVisible ? 0 : 6,
          bottom: params.isLastVisible ? 0 : 6,
        })}
        sx={{
          backgroundColor: "transparent",
          borderRadius: 6,
          ".MuiDataGrid-columnHeaders": {
            backgroundColor: "#f7fafc",
            color: "var(--fg)",
            fontWeight: 700,
            zIndex: 1,
          },
          ".MuiDataGrid-cell": { borderBottom: "1px solid #eef2f7", color: "var(--fg)" },
          ".MuiDataGrid-row:hover": { background: "#f8fafc" },
          ".MuiDataGrid-virtualScroller": { background: "transparent" },
          ".MuiDataGrid-viewport": { position: "relative" },
        }}
      />
    </div>
  );
}
