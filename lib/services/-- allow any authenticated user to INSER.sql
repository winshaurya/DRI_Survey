-- allow any authenticated user to INSERT their own session (temporarily)
ALTER POLICY "Family survey - Users access own sessions"
  ON public.family_survey_sessions
  USING ( auth.role() = 'authenticated' )           -- or simply `TRUE`
  WITH CHECK ( auth.role() = 'authenticated' );

-- or create a new permissive policy just for inserts:
CREATE POLICY allow_any_insert
  ON public.family_survey_sessions
  FOR INSERT
  TO authenticated
  WITH CHECK ( TRUE );