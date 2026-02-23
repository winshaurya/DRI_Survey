-- Migration: 2026-02-21 - add training_needs table and RLS policy
BEGIN;

-- Create table with FK to family_survey_sessions.phone_number
CREATE TABLE IF NOT EXISTS training_needs (
    phone_number BIGINT NOT NULL REFERENCES family_survey_sessions(phone_number) ON DELETE CASCADE,
    sr_no INTEGER NOT NULL,
    wants_training TEXT, -- 'yes' / 'no' / NULL
    phone_contact TEXT,
    preferred_training_type TEXT,
    preferred_training_date TEXT,
    created_at TEXT DEFAULT NOW()::TEXT,
    PRIMARY KEY (phone_number, sr_no)
);

-- Enable RLS and add policy restricting access to the surveyor (email)
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