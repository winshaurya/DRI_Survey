-- ===========================================
-- MIGRATION: Change family_survey_sessions primary key to phone_number
-- Date: February 9, 2026
-- Purpose: Align Supabase schema with SQLite schema for consistent primary keys
-- ===========================================

-- Step 1: Create new table with phone_number as primary key
CREATE TABLE IF NOT EXISTS family_survey_sessions_new (
    phone_number TEXT PRIMARY KEY,
    surveyor_email TEXT NOT NULL,
    created_at TEXT DEFAULT NOW()::TEXT,
    updated_at TEXT DEFAULT NOW()::TEXT,

    village_name TEXT,
    village_number TEXT,
    panchayat TEXT,
    block TEXT,
    tehsil TEXT,
    district TEXT,
    postal_address TEXT,
    pin_code TEXT,
    shine_code TEXT,

    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    location_accuracy DECIMAL(5,2),
    location_timestamp TEXT,

    survey_date TEXT DEFAULT CURRENT_DATE::TEXT,
    surveyor_name TEXT,
    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'exported')),

    device_info TEXT,
    app_version TEXT,
    created_by TEXT,
    updated_by TEXT,

    is_deleted INTEGER DEFAULT 0,
    last_synced_at TEXT,
    current_version INTEGER DEFAULT 1,
    last_edited_at TEXT DEFAULT NOW()::TEXT
);

-- Step 2: Copy data from old table to new table
INSERT INTO family_survey_sessions_new (
    phone_number, surveyor_email, created_at, updated_at,
    village_name, village_number, panchayat, block, tehsil, district,
    postal_address, pin_code, shine_code,
    latitude, longitude, location_accuracy, location_timestamp,
    survey_date, surveyor_name, status,
    device_info, app_version, created_by, updated_by,
    is_deleted, last_synced_at, current_version, last_edited_at
)
SELECT
    phone_number,
    COALESCE(surveyor_email, 'unknown'),
    created_at, updated_at,
    village_name, village_number, panchayat, block, tehsil, district,
    postal_address, pin_code, shine_code,
    latitude, longitude, location_accuracy, location_timestamp,
    survey_date, surveyor_name, status,
    device_info, app_version, created_by, updated_by,
    is_deleted, last_synced_at, current_version, last_edited_at
FROM family_survey_sessions
WHERE phone_number IS NOT NULL AND phone_number != '';

-- Step 3: Drop old table
DROP TABLE family_survey_sessions;

-- Step 4: Rename new table to original name
ALTER TABLE family_survey_sessions_new RENAME TO family_survey_sessions;

-- Step 5: Recreate indexes
CREATE INDEX IF NOT EXISTS idx_family_sessions_phone ON family_survey_sessions(phone_number);
CREATE INDEX IF NOT EXISTS idx_family_sessions_status ON family_survey_sessions(status);

-- Step 6: Verify the migration
SELECT COUNT(*) as migrated_records FROM family_survey_sessions;