-- Migration: 2026-02-21 - fix training_needs schema to requested layout
BEGIN;

-- Drop and recreate table to ensure exact column types / PK
DROP TABLE IF EXISTS training_needs;

CREATE TABLE IF NOT EXISTS training_needs (
    phone_number BIGINT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER NOT NULL,
    wants_training INTEGER, /* 0/1 or NULL */
    preferred_training TEXT,
    created_at TEXT DEFAULT NOW()::TEXT,
    PRIMARY KEY (phone_number, sr_no)
);

-- Ensure RLS and policy (restrict to surveyor's email)
ALTER TABLE training_needs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Training needs - Users access own data" ON training_needs;
CREATE POLICY "Training needs - Users access own data" ON training_needs
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM family_survey_sessions
            WHERE phone_number = training_needs.phone_number
            AND surveyor_email = auth.jwt() ->> 'email'
        )
    );

COMMIT;