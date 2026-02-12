-- Track all tables that have a phone_number column and check every column for non-null/non-empty values for phone 3233232332

DROP TABLE IF EXISTS temp_family_completeness_tables;
DROP TABLE IF EXISTS temp_family_completeness_columns;

CREATE TEMP TABLE temp_family_completeness_tables (
  table_name text,
  total_rows integer,
  filled_columns integer,
  total_columns integer
);

CREATE TEMP TABLE temp_family_completeness_columns (
  table_name text,
  column_name text,
  is_filled boolean
);

DO $$
DECLARE
  tbl RECORD;
  col RECORD;
  row_count int;
  col_filled boolean;
  filled_cnt int;
  flags text;
  flags_expr text;
  sql text;
  total_cols int;
BEGIN
  FOR tbl IN
    SELECT DISTINCT table_name FROM information_schema.columns
    WHERE column_name = 'phone_number' AND table_schema = 'public'
    ORDER BY table_name
  LOOP
    -- initialize
    row_count := 0;
    filled_cnt := 0;
    flags := '';
    total_cols := 0;

    -- get row count for this phone
    EXECUTE format('SELECT COUNT(*) FROM %I WHERE phone_number = %L', tbl.table_name, '3233232332') INTO row_count;

    -- iterate columns for this table
    FOR col IN SELECT column_name, data_type FROM information_schema.columns WHERE table_schema='public' AND table_name=tbl.table_name ORDER BY ordinal_position
    LOOP
      total_cols := total_cols + 1;
      -- check column-level filled boolean (non-null; for text also non-empty)
      IF col.data_type ILIKE 'character%' OR col.data_type = 'text' THEN
        EXECUTE format('SELECT EXISTS(SELECT 1 FROM %I WHERE phone_number = %L AND %I IS NOT NULL AND trim(%I) <> '''')', tbl.table_name, '3233232332', col.column_name, col.column_name) INTO col_filled;
      ELSE
        EXECUTE format('SELECT EXISTS(SELECT 1 FROM %I WHERE phone_number = %L AND %I IS NOT NULL)', tbl.table_name, '3233232332', col.column_name) INTO col_filled;
      END IF;

      INSERT INTO temp_family_completeness_columns(table_name, column_name, is_filled) VALUES (tbl.table_name, col.column_name, col_filled);

      -- build flags expression to compute sum of existence across columns
      IF col.data_type ILIKE 'character%' OR col.data_type = 'text' THEN
        flags := flags || format('COALESCE(MAX(CASE WHEN %I IS NOT NULL AND trim(%I) <> '''' THEN 1 ELSE 0 END),0) + ', col.column_name, col.column_name);
      ELSE
        flags := flags || format('COALESCE(MAX(CASE WHEN %I IS NOT NULL THEN 1 ELSE 0 END),0) + ', col.column_name);
      END IF;
    END LOOP;

    -- remove trailing ' + '
    IF flags <> '' THEN
      flags_expr := substring(flags from 1 for char_length(flags) - 3);
    ELSE
      flags_expr := '0';
    END IF;

    -- compute filled_cols using aggregate over rows for this phone (returns 0 when no rows)
    sql := format('SELECT %s as filled_columns FROM %I WHERE phone_number = %L', flags_expr, tbl.table_name, '3233232332');

    BEGIN
      EXECUTE sql INTO filled_cnt;
      IF filled_cnt IS NULL THEN filled_cnt := 0; END IF;
    EXCEPTION WHEN undefined_table THEN
      filled_cnt := 0;
    END;

    INSERT INTO temp_family_completeness_tables(table_name, total_rows, filled_columns, total_columns) VALUES (tbl.table_name, row_count, filled_cnt, total_cols);

  END LOOP;
END$$;

-- Final aggregated results
SELECT 'FAMILY TABLE EXISTENCE SUMMARY' as analysis_type, COUNT(*) as total_tables, SUM(CASE WHEN total_rows>0 THEN 1 ELSE 0 END) as tables_with_data, COUNT(*) - SUM(CASE WHEN total_rows>0 THEN 1 ELSE 0 END) as tables_empty, ROUND((SUM(CASE WHEN total_rows>0 THEN 1 ELSE 0 END)::decimal / COUNT(*)::decimal) * 100,2) as completeness_percentage FROM temp_family_completeness_tables;

-- Per-table summary
SELECT * FROM temp_family_completeness_tables ORDER BY table_name;

-- Per-column detail (only filled columns)
SELECT * FROM temp_family_completeness_columns WHERE is_filled = true ORDER BY table_name, column_name;

-- Per-column detail (only empty columns)
SELECT * FROM temp_family_completeness_columns WHERE is_filled = false ORDER BY table_name, column_name;

-- Totals
SELECT SUM(filled_columns) as total_filled_columns, SUM(total_columns) as total_columns, COUNT(*) as tables_checked, COUNT(*) FILTER (WHERE filled_columns>0) as tables_with_any_data FROM temp_family_completeness_tables;
