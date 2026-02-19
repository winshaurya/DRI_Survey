# Script: convert_phone_sql.ps1
# Replaces `phone_number TEXT` -> `phone_number INTEGER` and removes legacy id TEXT PK lines
# Usage: Open PowerShell in repo root and run: .\scripts\convert_phone_sql.ps1

$files = @(
    'Dashboard/supbase_SCHEMA.sql',
    'database_supabase_sqlite/supbase_SCHEMA.sql',
    'build/app/intermediates/flutter/release/flutter_assets/database_supabase_sqlite/supbase_SCHEMA.sql',
    'build/app/intermediates/flutter/debug/flutter_assets/database_supabase_sqlite/supbase_SCHEMA.sql',
    'build/app/intermediates/assets/debug/mergeDebugAssets/flutter_assets/database_supabase_sqlite/supbase_SCHEMA.sql'
)

foreach ($f in $files) {
    $path = Join-Path (Get-Location) $f
    if (Test-Path $path) {
        $text = Get-Content $path -Raw
        # remove id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT, lines (and id TEXT PRIMARY KEY, variants)
        $text = $text -replace "\n\s*id TEXT PRIMARY KEY DEFAULT gen_random_uuid\(\)::TEXT,",""
        $text = $text -replace "\n\s*id TEXT PRIMARY KEY,",""
        # replace phone_number TEXT -> phone_number INTEGER (only column definitions)
        $text = $text -replace "phone_number\s+TEXT","phone_number INTEGER"
        # ensure phone_number primary key lines remain valid
        $text = $text -replace "phone_number INTEGER PRIMARY KEY","phone_number INTEGER PRIMARY KEY"
        Set-Content -Path $path -Value $text -Encoding UTF8
        Write-Host "Updated: $f"
    } else {
        Write-Host "File not found: $f"
    }
}
