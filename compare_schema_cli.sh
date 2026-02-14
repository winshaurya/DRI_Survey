REM Extract columns from schema.sql
findstr /R /C:"CREATE TABLE IF NOT EXISTS" database_supabase_sqlite\supbase_SCHEMA.sql > schema_tables.txt
findstr /R /C:"^[ ]*[a-zA-Z0-9_]\+[ ]" database_supabase_sqlite\supbase_SCHEMA.sql | findstr /V /C:"CREATE TABLE" | findstr /V /C:"UNIQUE" | findstr /V /C:"PRIMARY" | findstr /V /C:"FOREIGN" | findstr /V /C:"CONSTRAINT" > schema_columns_raw.txt

REM Extract columns from db_columns.txt (already in table|column format)
sort db_columns.txt > db_columns_sorted.txt

REM Prepare schema columns in table|column format
REM This is a simplification; for full accuracy, a more advanced script would be needed.
REM For now, just output the raw lines for manual inspection.
type schema_columns_raw.txt

REM Show difference (manual step, as Windows shell lacks comm)
REM User should visually compare schema_columns_raw.txt and db_columns_sorted.txt