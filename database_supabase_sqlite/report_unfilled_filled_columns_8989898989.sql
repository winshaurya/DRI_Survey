-- Report unfilled columns and filled values for phone number 8989898989
-- Shows names of unfilled columns and values for filled columns per table
-- Includes ALL 50+ family survey tables, even if no data exists for this phone

DROP TABLE IF EXISTS temp_column_report;

CREATE TEMP TABLE temp_column_report (
  table_name text,
  column_name text,
  is_filled boolean,
  value_text text
);

DO $$
DECLARE
  tbl RECORD;
  col RECORD;
  val text;
  filled boolean;
  sql_query text;
BEGIN
  FOR tbl IN
    SELECT DISTINCT table_name FROM information_schema.columns
    WHERE column_name = 'phone_number' AND table_schema = 'public'
    ORDER BY table_name
  LOOP
    -- Process ALL tables with phone_number column
    FOR col IN SELECT column_name, data_type FROM information_schema.columns
               WHERE table_schema='public' AND table_name=tbl.table_name
               ORDER BY ordinal_position
    LOOP
      -- Try to get the value as text
      sql_query := format('SELECT %I::text FROM %I WHERE phone_number = %L LIMIT 1', col.column_name, tbl.table_name, '8989898989');
      BEGIN
        EXECUTE sql_query INTO val;
        -- Check if filled (not null and not empty for text)
        IF col.data_type ILIKE 'character%' OR col.data_type = 'text' THEN
          filled := (val IS NOT NULL AND trim(val) <> '');
        ELSE
          filled := (val IS NOT NULL);
        END IF;
        INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
        VALUES (tbl.table_name, col.column_name, filled, val);
      EXCEPTION WHEN OTHERS THEN
        -- If error (e.g., no row), mark as unfilled
        INSERT INTO temp_column_report(table_name, column_name, is_filled, value_text)
        VALUES (tbl.table_name, col.column_name, false, NULL);
      END;
    END LOOP;
  END LOOP;
END$$;

-- Report unfilled columns (names only)
SELECT 'UNFILLED COLUMNS' as report_type, table_name, column_name
FROM temp_column_report
WHERE is_filled = false
ORDER BY table_name, column_name;

-- Report filled columns with values
SELECT 'FILLED COLUMNS WITH VALUES' as report_type, table_name, column_name, value_text as value
FROM temp_column_report
WHERE is_filled = true
ORDER BY table_name, column_name;

-- Summary
SELECT
  table_name,
  COUNT(*) as total_columns,
  SUM(CASE WHEN is_filled THEN 1 ELSE 0 END) as filled_columns,
  SUM(CASE WHEN NOT is_filled THEN 1 ELSE 0 END) as unfilled_columns
FROM temp_column_report
GROUP BY table_name
ORDER BY table_name;