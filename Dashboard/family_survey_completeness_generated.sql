-- Family Survey Completeness Check (Auto-generated)
-- Phone number: 7474747474

WITH input AS (SELECT '7474747474'::text AS phone_number),

aadhaar_info_completeness AS (
  SELECT
    'aadhaar_info' AS table_name,
    COUNT(*) FILTER (WHERE id IS NOT NULL) +
    COUNT(*) FILTER (WHERE phone_number IS NOT NULL) +
    COUNT(*) FILTER (WHERE created_at IS NOT NULL) +
    COUNT(*) FILTER (WHERE has_aadhaar IS NOT NULL) +
    COUNT(*) FILTER (WHERE total_members IS NOT NULL) AS filled_count,
    5 AS total_count
  FROM aadhaar_info
  WHERE phone_number = (SELECT phone_number FROM input)
),
aadhaar_scheme_members_completeness AS (
  SELECT
    'aadhaar_scheme_members' AS table_name,
    COUNT(*) FILTER (WHERE id IS NOT NULL) +
    COUNT(*) FILTER (WHERE phone_number IS NOT NULL) +
    COUNT(*) FILTER (WHERE sr_no IS NOT NULL) +
    COUNT(*) FILTER (WHERE family_member_name IS NOT NULL) +

