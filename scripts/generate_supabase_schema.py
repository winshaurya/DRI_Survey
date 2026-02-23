import csv, collections, os, subprocess, sys, argparse


def fetch_from_csv(path):
    with open(path, newline='', encoding='utf-8') as f:
        reader = csv.reader(f)
        rows = list(reader)
    if not rows:
        raise RuntimeError("no data in CSV file")
    return rows


def fetch_from_postgres(conn_str):
    # Execute a query against Postgres using psql and return a list of rows
    query = """
SELECT table_schema, table_name, column_name,
       CASE
            WHEN data_type = 'character varying' THEN 'varchar('||character_maximum_length||')'
            WHEN data_type = 'character' THEN 'char('||character_maximum_length||')'
            WHEN data_type = 'numeric' AND numeric_precision IS NOT NULL THEN
                 'numeric('||numeric_precision||','||coalesce(numeric_scale,0)||')'
            ELSE data_type
       END
FROM information_schema.columns
WHERE table_schema NOT IN ('pg_catalog','information_schema')
ORDER BY table_schema, table_name, ordinal_position;
"""
    proc = subprocess.run([
        'psql', conn_str,
        '-t', '-A', '-F', ',',
        '-c', query
    ], capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"psql failed: {proc.stderr}")
    rows = []
    for line in proc.stdout.splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split(',')
        if len(parts) >= 4:
            rows.append(parts[:4])
    if not rows:
        raise RuntimeError("no rows returned from Postgres query")
    rows.insert(0, ['table_schema', 'table_name', 'column_name', 'data_type'])
    return rows


def build_schema(rows):
    cols = rows[0]
    tables = collections.OrderedDict()
    for row in rows[1:]:
        if len(row) < 4:
            continue
        sch, table, col, typ = row
        key = (sch, table)
        tables.setdefault(key, []).append((col, typ))

    out_lines = []
    for (sch, table), columns in tables.items():
        out_lines.append(f"-- {sch}.{table}")
        out_lines.append(f"CREATE TABLE IF NOT EXISTS {sch}.{table} (")
        defs = []
        for c, t in columns:
            defs.append(f"    {c} {t}")
        out_lines.append(",\n".join(defs))
        out_lines.append("\);\n")
    return out_lines


def write_schema(out_lines, outpath):
    with open(outpath, 'w', encoding='utf-8') as f:
        f.write("\n".join(out_lines))


def main():
    parser = argparse.ArgumentParser(
        description="Generate supabase schema from CSV or Postgres database."
    )
    parser.add_argument('--csv', help='path to csv export with columns')
    parser.add_argument('--conn', help='Postgres connection string for psql')
    parser.add_argument('--output', help='output file path',
                        default=r"..\supabase_all_dump.sql")
    args = parser.parse_args()

    if args.conn:
        rows = fetch_from_postgres(args.conn)
    elif args.csv:
        rows = fetch_from_csv(args.csv)
    else:
        parser.error('either --csv or --conn must be provided')

    out_lines = build_schema(rows)
    script_dir = os.path.dirname(__file__)
    outpath = os.path.abspath(os.path.join(script_dir, args.output))
    write_schema(out_lines, outpath)
    print(f"dumped {len(out_lines)} lines to {outpath}")

    # update existing supabase schema if located in repo
    existing_path = os.path.abspath(
        os.path.join(script_dir, '..', 'database_supabase_sqlite', 'supbase_SCHEMA.sql')
    )
    if os.path.exists(existing_path):
        try:
            with open(existing_path, 'w', encoding='utf-8') as f:
                f.write("\n".join(out_lines))
            print(f"overwrote existing schema at {existing_path}")
        except Exception as e:
            print(f"failed to overwrite existing schema: {e}")
        import re
        with open(existing_path, 'r', encoding='utf-8') as f:
            schema_txt = f.read()
        ex = re.findall(r'CREATE TABLE IF NOT EXISTS\s+([\w\.]+)', schema_txt)
        # build local table list for comparison
        tables = collections.OrderedDict()
        for row in rows[1:]:
            if len(row) < 4: continue
            sch, table, _, _ = row
            tables.setdefault((sch, table), True)
        missing = [t for t in tables.keys() if t not in ex]
        print(f"existing schema has {len(ex)} tables, {len(missing)} missing")
        if missing:
            print("missing tables:")
            for t in missing:
                print("  ", t)
    else:
        print(f"no existing supabase_SCHEMA.sql found at {existing_path}")


if __name__ == '__main__':
    main()
