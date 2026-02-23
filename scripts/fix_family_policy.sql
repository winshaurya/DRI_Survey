BEGIN;
ALTER TABLE public.family_survey_sessions DROP POLICY IF EXISTS "Users access own data";
CREATE POLICY "users_select_update_delete_own_rows"
  ON public.family_survey_sessions
  FOR ALL
  TO authenticated
  USING (surveyor_email = auth.jwt() ->> 'email')
  WITH CHECK (surveyor_email = auth.jwt() ->> 'email');
COMMIT;
