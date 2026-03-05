import * as XLSX from "xlsx";
import { FAMILY_TABLES, VILLAGE_TABLES } from "../consts";

/**
 * Flattens an object or array of objects into a format suitable for Excel.
 * For this application, we want to export:
 * - A main sheet with the session details.
 * - Separate sheets for each related table that has data.
 */
export function exportToExcel(data: any, type: "family" | "village") {
  const wb = XLSX.utils.book_new();

  // 1. Main Sheet (Session Details)
  // We remove the related table keys from the main object to avoid clutter
  const relatedTables = type === "family" ? FAMILY_TABLES : VILLAGE_TABLES;
  
  const mainData: any = { ...data };
  relatedTables.forEach(t => delete mainData[t]);

  const mainWs = XLSX.utils.json_to_sheet([mainData]);
  XLSX.utils.book_append_sheet(wb, mainWs, "Overview");

  // 2. Related Sheets
  relatedTables.forEach(table => {
    const rows = data[table];
    if (Array.isArray(rows) && rows.length > 0) {
      const ws = XLSX.utils.json_to_sheet(rows);
      // Sheet names max length is 31 chars
      const sheetName = table.substring(0, 31);
      XLSX.utils.book_append_sheet(wb, ws, sheetName);
    } else if (typeof rows === 'object' && rows !== null && Object.keys(rows).length > 0) {
        // Handle single object responses if any (though typically arrays in our API)
        const ws = XLSX.utils.json_to_sheet([rows]);
        const sheetName = table.substring(0, 31);
        XLSX.utils.book_append_sheet(wb, ws, sheetName);
    }
  });

  const fileName = `${type}_survey_${getMainId(data, type)}.xlsx`;
  XLSX.writeFile(wb, fileName);
}

function getMainId(data: any, type: "family" | "village") {
  if (type === "family") return data.phone_number || "export";
  return data.session_id || "export";
}
