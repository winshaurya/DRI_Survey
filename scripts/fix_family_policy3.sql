BEGIN;

-- Drop known problematic policies (if present)
DROP POLICY IF EXISTS "Users access own data" ON public.family_survey_sessions;
DROP POLICY IF EXISTS allow_any_insert ON public.family_survey_sessions;

-- Remove any previously created test policies to avoid duplicates
DROP POLICY IF EXISTS "users_select_update_delete_own_rows" ON public.family_survey_sessions;
DROP POLICY IF EXISTS "allow_authenticated_insert" ON public.family_survey_sessions;

-- Create safe, non-recursive policy: allow authenticated users to access and modify their own rows
CREATE POLICY "users_select_update_delete_own_rows"
  ON public.family_survey_sessions
  FOR ALL
  TO authenticated
  USING (surveyor_email = auth.jwt() ->> 'email')
  WITH CHECK (surveyor_email = auth.jwt() ->> 'email');

-- Allow authenticated inserts only when surveyor_email matches the JWT email
CREATE POLICY "allow_authenticated_insert"
  ON public.family_survey_sessions
  FOR INSERT
  TO authenticated
  WITH CHECK (surveyor_email = auth.jwt() ->> 'email');

COMMIT;
