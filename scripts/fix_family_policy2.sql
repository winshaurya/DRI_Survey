BEGIN;
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='family_survey_sessions' AND policyname='Users access own data'
  ) THEN
    EXECUTE 'ALTER TABLE public.family_survey_sessions DROP POLICY "Users access own data"';
  END IF;
END$$;

CREATE POLICY "users_select_update_delete_own_rows"
  ON public.family_survey_sessions
  FOR ALL
  TO authenticated
  USING (surveyor_email = auth.jwt() ->> 'email')
  WITH CHECK (surveyor_email = auth.jwt() ->> 'email');
COMMIT;
