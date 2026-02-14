-- Count total survey sessions for both village and family surveys
-- Quick overview of survey data completeness

-- Village Survey Sessions Count
SELECT
  'VILLAGE_SURVEY_SESSIONS' as survey_type,
  COUNT(*) as total_sessions,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_sessions,
  COUNT(CASE WHEN status = 'in_progress' THEN 1 END) as in_progress_sessions,
  ROUND(
    (COUNT(CASE WHEN status = 'completed' THEN 1 END)::decimal / COUNT(*)::decimal) * 100, 2
  ) as completion_percentage
FROM village_survey_sessions;

-- Family Survey Sessions Count
SELECT
  'FAMILY_SURVEY_SESSIONS' as survey_type,
  COUNT(*) as total_sessions,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_sessions,
  COUNT(CASE WHEN status = 'in_progress' THEN 1 END) as in_progress_sessions,
  ROUND(
    (COUNT(CASE WHEN status = 'completed' THEN 1 END)::decimal / COUNT(*)::decimal) * 100, 2
  ) as completion_percentage
FROM family_survey_sessions;

-- Combined Summary
SELECT
  'TOTAL_SURVEYS' as summary,
  (SELECT COUNT(*) FROM village_survey_sessions) as village_sessions,
  (SELECT COUNT(*) FROM family_survey_sessions) as family_sessions,
  ((SELECT COUNT(*) FROM village_survey_sessions) + (SELECT COUNT(*) FROM family_survey_sessions)) as total_sessions;