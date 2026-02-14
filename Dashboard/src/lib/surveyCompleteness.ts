import { supabase } from './supabaseClient';

export type ColumnStat = {
  table: string;
  column: string;
  totalRows: number;
  filledCount: number;
  emptyCount: number;
  filledPercent: number; // 0-100
  examples: any[]; // up to `sampleLimit` distinct non-null examples
};

type Options = {
  sampleLimit?: number;
  maxRows?: number; // protect large selects
  treatEmptyStringAsNull?: boolean;
};

/**
 * Fetch rows for `table` filtered by `filter` and compute per-column completeness.
 * Client-side only (good for small / per-session datasets). Returns columns sorted by completeness desc.
 */
export async function getCompletenessForTableClient(
  table: string,
  filter: Record<string, any>,
  opts: Options = {}
): Promise<ColumnStat[]> {
  const sampleLimit = opts.sampleLimit ?? 5;
  const maxRows = opts.maxRows ?? 2000;
  const treatEmptyStringAsNull = opts.treatEmptyStringAsNull ?? true;

  const { data: rows, error } = await supabase
    .from(table)
    .select('*')
    .match(filter)
    .limit(maxRows);

  if (error) throw error;
  if (!rows || rows.length === 0) return [];

  const totalRows = rows.length;
  const columnSet = new Set<string>();
  rows.forEach((r: any) => Object.keys(r).forEach((k) => columnSet.add(k)));
  const columns = Array.from(columnSet).sort();

  const stats: ColumnStat[] = columns.map((col) => {
    let filledCount = 0;
    const examples = new Set<any>();

    for (const r of rows as any[]) {
      const v = r[col];
      const isEmpty = v === null || v === undefined || (treatEmptyStringAsNull && typeof v === 'string' && v.trim() === '');
      if (!isEmpty) {
        filledCount += 1;
        if (examples.size < sampleLimit) examples.add(v);
      }
    }

    const filledPercent = totalRows ? Math.round((filledCount / totalRows) * 10000) / 100 : 0;

    return {
      table,
      column: col,
      totalRows,
      filledCount,
      emptyCount: totalRows - filledCount,
      filledPercent,
      examples: Array.from(examples),
    };
  });

  return stats.sort((a, b) => b.filledPercent - a.filledPercent || b.filledCount - a.filledCount);
}

/**
 * Run client-side completeness across multiple tables in parallel.
 */
export async function getCompletenessAcrossTablesClient(
  tables: string[],
  filterByTable: (table: string) => Record<string, any>,
  opts?: Options
): Promise<ColumnStat[]> {
  const promises = tables.map((t) => getCompletenessForTableClient(t, filterByTable(t), opts));
  const results = await Promise.all(promises);
  return results.flat();
}

/**
 * Simple search + sort helper for ColumnStat array.
 */
export function filterAndSortStats(
  stats: ColumnStat[],
  { searchTerm, minFilledPercent, sortBy }:
  { searchTerm?: string; minFilledPercent?: number; sortBy?: 'filledPercent' | 'filledCount' | 'column' } = {}
) {
  let out = stats.slice();
  if (typeof minFilledPercent === 'number') out = out.filter(s => s.filledPercent >= minFilledPercent);
  if (searchTerm && searchTerm.trim()) {
    const q = searchTerm.toLowerCase();
    out = out.filter(s => s.column.toLowerCase().includes(q) || s.examples.some(e => String(e).toLowerCase().includes(q)));
  }
  if (sortBy === 'column') out.sort((a,b) => a.column.localeCompare(b.column));
  else if (sortBy === 'filledCount') out.sort((a,b) => b.filledCount - a.filledCount);
  else out.sort((a,b) => b.filledPercent - a.filledPercent);
  return out;
}

/**
 * NOTE: for very large datasets or to inspect ALL tables/columns server-side, create a Postgres RPC
 * that inspects information_schema and returns counts (recommended). The RPC can be called from
 * client code with `supabase.rpc('my_rpc_name', { ... })`.
 */

/**
 * Convenience: check completeness for a single survey session.
 * - surveyType: 'family' | 'village'
 * - identifierKey: e.g. 'phone_number' or 'session_id' or 'shine_code'
 * - identifierValue: actual value to match
 * - tables: list of tables to scan (default: the session table for the surveyType)
 */
export async function getSurveySessionCompleteness(
  surveyType: 'family' | 'village',
  identifierKey: string,
  identifierValue: string | number,
  tables?: string[],
  opts?: Options
) {
  const defaultTable = surveyType === 'family' ? 'family_survey_sessions' : 'village_survey_sessions';
  const tablesToScan = tables && tables.length > 0 ? tables : [defaultTable];

  const stats = await getCompletenessAcrossTablesClient(
    tablesToScan,
    (_table) => ({ [identifierKey]: identifierValue }),
    opts
  );

  const totalTables = new Set(stats.map(s => s.table)).size;
  const totalColumns = stats.length;
  const columnsFilled = stats.filter(s => s.filledCount > 0).length;

  return {
    identifierKey,
    identifierValue,
    totalTables,
    totalColumns,
    columnsFilled,
    stats,
  };
}
