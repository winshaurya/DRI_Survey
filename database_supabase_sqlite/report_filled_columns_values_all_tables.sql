-- This script lists, for each user table and column:
--   - Table name
--   - Column name
--   - Count of non-null (filled) values
--   - Count of total rows
--   - Example filled values (up to 5 distinct values)
DO $$
DECLARE
    r RECORD;
    c RECORD;
    dyn_sql TEXT;
BEGIN
    FOR r IN
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    LOOP
        FOR c IN
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = r.table_schema AND table_name = r.table_name
        LOOP
            dyn_sql := format(
                $fmt$
                SELECT
                    '%s' AS table_name,
                    '%s' AS column_name,
                    COUNT(*) AS total_rows,
                    COUNT(%I) AS filled_count,
                    ARRAY(
                        SELECT DISTINCT %I FROM %I.%I WHERE %I IS NOT NULL LIMIT 5
                    ) AS example_filled_values
                FROM %I.%I;
                $fmt$,
                r.table_name, c.column_name, c.column_name, c.column_name,
                r.table_schema, r.table_name, c.column_name,
                r.table_schema, r.table_name
            );
            RAISE NOTICE '%', dyn_sql;
            EXECUTE dyn_sql;
        END LOOP;
    END LOOP;
END $$;