// dashboard/src/components/TableData.tsx
import React, { useEffect, useState } from "react";
import { Table, Loader, Alert, TextInput, Group, Button } from "@mantine/core";
import { IconSearch, IconSortAscending, IconSortDescending, IconDownload } from "@tabler/icons-react";
import * as XLSX from "xlsx";

interface TableDataProps {
  tableName: string;
}

type SortDirection = "asc" | "desc";

export function TableData({ tableName }: TableDataProps) {
  const [data, setData] = useState<any[]>([]);
  const [filtered, setFiltered] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [sortCol, setSortCol] = useState<string | null>(null);
  const [sortDir, setSortDir] = useState<SortDirection>("asc");
  const [shoneCode, setShoneCode] = useState("");
  const [phoneNumber, setPhoneNumber] = useState("");

  useEffect(() => {
    setLoading(true);
    setError(null);

    const fetchData = async () => {
      try {
        // Use Supabase project URL and service role key from env (server-side key)
        const supabaseUrl = (import.meta.env.VITE_SUPABASE_URL || '') as string;
        const serviceRole = (import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY || '') as string;
        if (!supabaseUrl || !serviceRole) throw new Error('VITE_SUPABASE_URL and VITE_SUPABASE_SERVICE_ROLE_KEY are required in env');
        const restBase = `${supabaseUrl.replace(/\/$/, '')}/rest/v1`;
        const headers: Record<string, string> = {
          'Content-Type': 'application/json',
          'apikey': serviceRole,
          'Authorization': `Bearer ${serviceRole}`,
        };

        let rows: any[] = [];

        // If shine_code provided and table != village_survey_sessions, resolve session_ids first
        if (shoneCode && tableName !== 'village_survey_sessions') {
          const sUrl = `${restBase}/village_survey_sessions?select=session_id&shine_code=eq.${encodeURIComponent(shoneCode)}`;
          const sRes = await fetch(sUrl, { headers });
          if (!sRes.ok) {
            const txt = await sRes.text();
            throw new Error(`Failed to resolve sessions: ${txt}`);
          }
          const sessionJson = await sRes.json();
          const sessionIds = (sessionJson || []).map((r: any) => r.session_id);
          if (sessionIds.length === 0) {
            setData([]);
            setLoading(false);
            return;
          }
          // build in filter (quote ids)
          const inVals = sessionIds.map((id: string) => `"${id}"`).join(',');
          const qUrl = `${restBase}/${encodeURIComponent(tableName)}?select=*&limit=1000&session_id=in.(${encodeURIComponent(inVals)})`;
          const qRes = await fetch(qUrl, { headers });
          if (!qRes.ok) {
            const txt = await qRes.text();
            throw new Error(`Query failed: ${txt}`);
          }
          rows = await qRes.json();
        } else {
          const params: string[] = [];
          params.push('select=*');
          params.push('limit=1000');
          if (shoneCode && tableName === 'village_survey_sessions') params.push(`shine_code=eq.${encodeURIComponent(shoneCode)}`);
          if (phoneNumber) params.push(`phone_number=eq.${encodeURIComponent(phoneNumber)}`);
          const url = `${restBase}/${encodeURIComponent(tableName)}?${params.join('&')}`;
          const res = await fetch(url, { headers });
          if (!res.ok) {
            const txt = await res.text();
            throw new Error(`Query failed: ${txt}`);
          }
          rows = await res.json();
        }

        setData(rows || []);
      } catch (err: any) {
        setError(err.message || String(err));
      }
      setLoading(false);
    };

    fetchData();
    // eslint-disable-next-line
  }, [tableName, shoneCode, phoneNumber]);

  useEffect(() => {
    let filteredData = data;
    if (search) {
      filteredData = data.filter((row) =>
        Object.values(row).some((val) =>
          String(val).toLowerCase().includes(search.toLowerCase())
        )
      );
    }
    if (shoneCode) {
      filteredData = filteredData.filter((row) =>
        row.shone_code && String(row.shone_code).toLowerCase().includes(shoneCode.toLowerCase())
      );
    }
    if (phoneNumber) {
      filteredData = filteredData.filter((row) =>
        row.phone_number && String(row.phone_number).includes(phoneNumber)
      );
    }
    if (sortCol) {
      filteredData = [...filteredData].sort((a, b) => {
        if (a[sortCol] === b[sortCol]) return 0;
        if (sortDir === "asc") return a[sortCol] > b[sortCol] ? 1 : -1;
        return a[sortCol] < b[sortCol] ? 1 : -1;
      });
    }
    setFiltered(filteredData);
  }, [data, search, sortCol, sortDir]);

  if (loading) return <Loader />;
  if (error) return <Alert color="red">{error}</Alert>;
  if (!data.length) return <Alert>No data found for {tableName}</Alert>;

  const columns = Object.keys(data[0]);

  // Excel export function
  const handleExport = () => {
    const ws = XLSX.utils.json_to_sheet(filtered);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, tableName);
    XLSX.writeFile(wb, `${tableName}_export.xlsx`);
  };

  return (
    <>
      <Group mb="sm">
        <TextInput
          icon={<IconSearch size={16} />}
          placeholder="Search"
          value={search}
          onChange={(e) => setSearch(e.currentTarget.value)}
          style={{ flex: 1 }}
        />
        <TextInput
          placeholder="Filter by shone code"
          value={shoneCode}
          onChange={(e) => setShoneCode(e.currentTarget.value)}
          style={{ width: 180 }}
        />
        <TextInput
          placeholder="Filter by phone number"
          value={phoneNumber}
          onChange={(e) => setPhoneNumber(e.currentTarget.value)}
          style={{ width: 180 }}
        />
        <Button leftIcon={<IconDownload size={16} />} onClick={handleExport} color="green">
          Export Excel
        </Button>
      </Group>
      <Table striped highlightOnHover withBorder>
        <thead>
          <tr>
            {columns.map((col) => (
              <th key={col}>
                <Button
                  variant="subtle"
                  compact
                  onClick={() => {
                    if (sortCol === col) {
                      setSortDir(sortDir === "asc" ? "desc" : "asc");
                    } else {
                      setSortCol(col);
                      setSortDir("asc");
                    }
                  }}
                  rightIcon={
                    sortCol === col ? (
                      sortDir === "asc" ? (
                        <IconSortAscending size={14} />
                      ) : (
                        <IconSortDescending size={14} />
                      )
                    ) : null
                  }
                  style={{ textTransform: "capitalize" }}
                >
                  {col}
                </Button>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {filtered.map((row, idx) => (
            <tr key={row.id ?? row.phone_number ?? idx}>
              {columns.map((col, i) => (
                <td key={col}>{String(row[col])}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </Table>
    </>
  );
}
