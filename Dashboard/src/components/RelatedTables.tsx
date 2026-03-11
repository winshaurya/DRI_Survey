import { useEffect, useState } from "react";
import {
  Box,
  Typography,
  CircularProgress,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Button,
} from "@mui/material";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import { supabase } from "../services/supabase";
import * as XLSX from "xlsx";

type Props = {
  tab: "village" | "family";
  pk: string | number;
  keyField: string;
  onClose?: () => void;
};

export default function RelatedTables({ tab, pk, keyField, onClose }: Props) {
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState<Record<string, any[] | { error: string }>>({});

  // Regex to match page completion status keys (handles variants)
  const stripKeyRegex = /page[_ ]*completion[_ ]*status/i;

  const stripPageCompletionFromRow = (value: any): any => {
    if (value === null || value === undefined) return value;
    if (Array.isArray(value)) return value.map(stripPageCompletionFromRow);
    if (typeof value === "object") {
      const out: Record<string, any> = {};
      for (const k of Object.keys(value)) {
        if (!stripKeyRegex.test(k)) {
          out[k] = value[k];
        }
      }
      return out;
    }
    return value;
  };

  useEffect(() => {
    let mounted = true;
    async function fetchAll() {
      setLoading(true);
      const villageRelated = [
        "village_survey_sessions",
        "village_population",
        "village_farm_families",
        "village_housing",
        "village_agricultural_implements",
        "village_crop_productivity",
        "village_animals",
        "village_irrigation_facilities",
        "village_drinking_water",
        "village_transport",
        "village_entertainment",
        "village_medical_treatment",
        "village_disputes",
        "village_educational_facilities",
        "village_social_consciousness",
        "village_children_data",
        "village_malnutrition_data",
        "village_bpl_families",
        "village_kitchen_gardens",
        "village_seed_clubs",
        "village_biodiversity_register",
        "village_traditional_occupations",
        "village_drainage_waste",
        "village_signboards",
        "village_unemployment",
        "village_social_maps",
        "village_transport_facilities",
        "village_infrastructure",
        "village_infrastructure_details",
        "village_survey_details",
        "village_map_points",
        "village_forest_maps",
        "village_cadastral_maps",
      ];
      const familyRelated = [
        "family_survey_sessions",
        "family_members",
        "land_holding",
        "irrigation_facilities",
        "crop_productivity",
        "animals",
        "agricultural_equipment",
        "fertilizer_usage",
        "entertainment_facilities",
        "transport_facilities",
        "medical_treatment",
        "disputes",
        "house_conditions",
        "house_facilities",
        "diseases",
        "social_consciousness",
        // government schemes
        "aadhaar_info",
        "aadhaar_scheme_members",
        "ayushman_card",
        "ayushman_scheme_members",
        "family_id",
        "family_id_scheme_members",
        "ration_card",
        "ration_scheme_members",
        "samagra_id",
        "samagra_scheme_members",
        "tribal_card",
        "tribal_scheme_members",
        "handicapped_allowance",
        "handicapped_scheme_members",
        "pension_allowance",
        "pension_scheme_members",
        "widow_allowance",
        "widow_scheme_members",
        "vb_gram",
        "vb_gram_members",
        "pm_kisan_nidhi",
        "pm_kisan_members",
        "pm_kisan_samman_nidhi",
        "pm_kisan_samman_members",
        "tribal_questions",
        "merged_govt_schemes",
        // additional family tables
        "children_data",
        "malnourished_children_data",
        "child_diseases",
        "migration_data",
        "training_data",
        "shg_members",
        "fpo_members",
        "bank_accounts",
        "folklore_medicine",
        "health_programmes",
        "tulsi_plants",
        "nutritional_garden",
        "malnutrition_data",
      ];
      const list = tab === "village" ? villageRelated : familyRelated;

      const results: Record<string, any[] | { error: string }> = {};
      await Promise.all(
        list.map(async (tbl) => {
          try {
            // probe table; if table missing supabase REST returns 404 via error
            const { data: rows, error } = await supabase.from(tbl).select("*").eq(keyField, pk).limit(500);
            if (error) {
              results[tbl] = { error: String(error) };
            } else {
              results[tbl] = Array.isArray(rows) ? rows : [];
            }
          } catch (e: any) {
            results[tbl] = { error: String(e) };
          }
        })
      );

      if (mounted) {
        setData(results);
        setLoading(false);
      }
    }

    fetchAll();
    return () => {
      mounted = false;
    };
    }, [tab, pk, keyField]);

    const exportAllXLSX = async () => {
      try {
        console.log("RelatedTables: exportAllXLSX (single-sheet export)", { pk, keyField, tab });

        const villageRelated = [
          "village_population",
          "village_farm_families",
          "village_housing",
          "village_agricultural_implements",
          "village_crop_productivity",
          "village_animals",
          "village_irrigation_facilities",
          "village_drinking_water",
          "village_transport",
          "village_entertainment",
          "village_medical_treatment",
          "village_disputes",
          "village_educational_facilities",
          "village_social_consciousness",
          "village_children_data",
          "village_malnutrition_data",
          "village_bpl_families",
          "village_kitchen_gardens",
          "village_seed_clubs",
          "village_biodiversity_register",
          "village_traditional_occupations",
          "village_drainage_waste",
          "village_signboards",
          "village_unemployment",
          "village_social_maps",
          "village_transport_facilities",
          "village_infrastructure",
          "village_infrastructure_details",
          "village_survey_details",
          "village_map_points",
          "village_forest_maps",
          "village_cadastral_maps",
        ];
        const familyRelated = [
          "family_members",
          "land_holding",
          "irrigation_facilities",
          "crop_productivity",
          "animals",
          "agricultural_equipment",
          "fertilizer_usage",
          "entertainment_facilities",
          "transport_facilities",
          "medical_treatment",
          "disputes",
          "house_conditions",
          "house_facilities",
          "diseases",
          "social_consciousness",
          "aadhaar_info",
          "aadhaar_scheme_members",
          "ayushman_card",
          "ayushman_scheme_members",
          "family_id",
          "family_id_scheme_members",
          "ration_card",
          "ration_scheme_members",
          "samagra_id",
          "samagra_scheme_members",
          "tribal_card",
          "tribal_scheme_members",
          "handicapped_allowance",
          "handicapped_scheme_members",
          "pension_allowance",
          "pension_scheme_members",
          "widow_allowance",
          "widow_scheme_members",
          "vb_gram",
          "vb_gram_members",
          "pm_kisan_nidhi",
          "pm_kisan_members",
          "pm_kisan_samman_nidhi",
          "pm_kisan_samman_members",
          "tribal_questions",
          "merged_govt_schemes",
          "children_data",
          "malnourished_children_data",
          "child_diseases",
          "migration_data",
          "training_data",
          "shg_members",
          "fpo_members",
          "bank_accounts",
          "folklore_medicine",
          "health_programmes",
          "tulsi_plants",
          "nutritional_garden",
          "malnutrition_data",
        ];
        const list = tab === "village" ? villageRelated : familyRelated;

        void Promise.resolve().then(() => alert("Preparing single-sheet .xlsx — fetching latest data"));

        // Fetch all tables
        const fetches = await Promise.allSettled(
          list.map((tbl) => supabase.from(tbl).select("*").eq(keyField, pk).limit(1000))
        );

        const aoa: any[][] = [];
        const summary: string[] = [];

        for (let i = 0; i < list.length; i++) {
          const table = list[i];
          const res = fetches[i];

          // Add separator row with table name
          aoa.push([]);
          aoa.push([`TABLE: ${table}`]);

          if (res.status === "rejected") {
            aoa.push([`FETCH ERROR: ${String(res.reason)}`]);
            summary.push(`${table}: FETCH ERROR`);
            continue;
          }

          const payload = (res as PromiseFulfilledResult<any>).value;
          if (!payload) {
            aoa.push(["No rows"]);
            summary.push(`${table}: 0 rows`);
            continue;
          }

          if (payload.error) {
            aoa.push([`ERROR: ${String(payload.error)}`]);
            summary.push(`${table}: ERROR`);
            continue;
          }

          const rows = Array.isArray(payload.data) ? payload.data : [];
          if (!rows || rows.length === 0) {
            aoa.push(["No rows"]);
            summary.push(`${table}: 0 rows`);
            continue;
          }

          // Collect headers (union), excluding page completion keys
          const keySet = new Set<string>();
          for (const r of rows) Object.keys(r || {}).forEach((k) => {
            if (!stripKeyRegex.test(k)) keySet.add(k);
          });
          const headers = Array.from(keySet);
          aoa.push(headers);

          for (const r of rows) {
            aoa.push(
              headers.map((h) => {
                const v = r[h];
                if (v === null || v === undefined) return "";
                if (typeof v === "object") return JSON.stringify(stripPageCompletionFromRow(v));
                return v;
              })
            );
          }

          summary.push(`${table}: ${rows.length} rows, ${headers.length} cols`);
        }

        // Debug preview
        const wb = XLSX.utils.book_new();
        const ws = XLSX.utils.aoa_to_sheet(aoa);
        XLSX.utils.book_append_sheet(wb, ws, "RelatedTables");

        console.log("Workbook sheets:", wb.SheetNames);
        try {
          const preview = XLSX.utils.sheet_to_json(ws, { header: 1, range: 0, blankrows: false }).slice(0, 20);
          console.log("Single-sheet preview:", preview);
        } catch (e) {
          console.warn("Failed to preview single sheet", e);
        }

        void Promise.resolve().then(() => alert("Export summary:\n" + summary.join("\n")));

        const wbout = XLSX.write(wb, { bookType: "xlsx", type: "array" });
        const mime = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        const blob = new Blob([wbout], { type: mime });
        console.log("RelatedTables: generated blob", { size: blob.size, type: blob.type });

        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = `related_tables_${String(pk)}.xlsx`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
      } catch (e) {
        console.error("XLSX export failed", e);
        alert("Export failed. See console for details.");
      }
    };

    if (loading) {
    return (
      <Box sx={{ p: 4, textAlign: "center" }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box sx={{ p: 2 }}>
      <Box sx={{ display: "flex", justifyContent: "space-between", mb: 2 }}>
        <Typography variant="h6">Related tables for {String(pk)}</Typography>
        <Box>
          <Button id="exportXlsBtn" size="small" variant="outlined" onClick={exportAllXLSX} sx={{ mr: 1 }}>
            Export XLSX
          </Button>
          <Button size="small" onClick={onClose} sx={{ mr: 1 }}>
            Close
          </Button>
        </Box>
      </Box>

      {Object.keys(data).length === 0 && (
        <Typography color="text.secondary">No related tables detected.</Typography>
      )}

      {Object.entries(data).map(([table, rowsOrErr]) => {
        const isError = !Array.isArray(rowsOrErr);
        const rows = Array.isArray(rowsOrErr) ? rowsOrErr : [];
        const columns = rows[0] ? Object.keys(rows[0]) : [];
        const displayColumns = columns.filter((c) => !stripKeyRegex.test(c));

        return (
          <Accordion key={table} defaultExpanded={false} sx={{ mb: 1 }}>
            <AccordionSummary expandIcon={<ExpandMoreIcon />}>
              <Typography sx={{ fontWeight: 700 }}>{table}</Typography>
              <Typography sx={{ ml: 2, color: "text.secondary" }}>
                {isError ? " error" : ` ${rows.length} rows`}
              </Typography>
            </AccordionSummary>
            <AccordionDetails>
              {isError ? (
                <Typography color="error">{(rowsOrErr as any).error}</Typography>
              ) : rows.length === 0 ? (
                <Typography color="text.secondary">No rows</Typography>
              ) : (
                <div style={{ overflowX: "auto" }}>
                  <table style={{ width: "100%", borderCollapse: "collapse" }}>
                    <thead>
                      <tr>
                        {displayColumns.map((c) => (
                          <th
                            key={c}
                            style={{
                              textAlign: "left",
                              padding: "8px 10px",
                              borderBottom: "1px solid rgba(0,0,0,0.08)",
                              fontWeight: 700,
                            }}
                          >
                            {String(c)}
                          </th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {rows.map((r: any, idx: number) => (
                        <tr key={r.id ?? r.sr_no ?? idx}>
                          {displayColumns.map((c) => (
                            <td key={c} style={{ padding: "8px 10px", verticalAlign: "top" }}>
                              {r[c] === null || r[c] === undefined ? "" : String(r[c])}
                            </td>
                          ))}
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </AccordionDetails>
          </Accordion>
        );
      })}
    </Box>
  );
}