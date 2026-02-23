-- Supabase schema updates: non-recursive RLS policies for family_survey_sessions and fixed child-table policies
-- Apply with: psql "<CONN>" -f supabase_schema_updates.sql

BEGIN;

-- Parent table: family_survey_sessions -- ensure non-recursive policies
DROP POLICY IF EXISTS "users_select_update_delete_own_rows" ON public.family_survey_sessions;
DROP POLICY IF EXISTS "allow_authenticated_insert" ON public.family_survey_sessions;

CREATE POLICY users_select_update_delete_own_rows ON public.family_survey_sessions
  FOR ALL
  TO authenticated
  USING (surveyor_email = (auth.jwt() ->> 'email'::text))
  WITH CHECK (surveyor_email = (auth.jwt() ->> 'email'::text));

CREATE POLICY allow_authenticated_insert ON public.family_survey_sessions
  FOR INSERT
  TO authenticated
  WITH CHECK (surveyor_email = (auth.jwt() ->> 'email'::text));

-- Child-table policies: compare parent f.phone_number to child_table.phone_number
-- (These mirror the fixes applied interactively; listed here so the schema dump can be updated.)

-- vb_gram
ALTER TABLE public.vb_gram ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.vb_gram;
CREATE POLICY "Users access own data" ON public.vb_gram FOR ALL TO PUBLIC
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = vb_gram.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = vb_gram.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))));

-- pension_allowance
ALTER TABLE public.pension_allowance ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.pension_allowance;
CREATE POLICY "Users access own data" ON public.pension_allowance FOR ALL TO PUBLIC
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = pension_allowance.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = pension_allowance.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))));

-- widow_allowance
ALTER TABLE public.widow_allowance ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.widow_allowance;
CREATE POLICY "Users access own data" ON public.widow_allowance FOR ALL TO PUBLIC
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = widow_allowance.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = widow_allowance.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))));

-- handicapped_allowance
ALTER TABLE public.handicapped_allowance ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.handicapped_allowance;
CREATE POLICY "Users access own data" ON public.handicapped_allowance FOR ALL TO PUBLIC
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = handicapped_allowance.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = handicapped_allowance.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))));

-- bank_accounts
ALTER TABLE public.bank_accounts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.bank_accounts;
CREATE POLICY "Users access own data" ON public.bank_accounts FOR ALL TO PUBLIC
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = bank_accounts.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = bank_accounts.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))));

-- tribal_card
ALTER TABLE public.tribal_card ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.tribal_card;
CREATE POLICY "Users access own data" ON public.tribal_card FOR ALL TO PUBLIC
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = tribal_card.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = tribal_card.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))));

-- merged_govt_schemes
ALTER TABLE public.merged_govt_schemes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.merged_govt_schemes;
CREATE POLICY "Users access own data" ON public.merged_govt_schemes FOR ALL TO PUBLIC
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = merged_govt_schemes.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = merged_govt_schemes.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))));

-- pm_kisan_nidhi
ALTER TABLE public.pm_kisan_nidhi ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.pm_kisan_nidhi;
CREATE POLICY "Users access own data" ON public.pm_kisan_nidhi FOR ALL TO PUBLIC
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = pm_kisan_nidhi.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = pm_kisan_nidhi.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))));

-- ration_card
ALTER TABLE public.ration_card ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.ration_card;
CREATE POLICY "Users access own data" ON public.ration_card FOR ALL TO PUBLIC
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = ration_card.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = ration_card.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))));

-- pm_kisan_samman_nidhi
ALTER TABLE public.pm_kisan_samman_nidhi ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.pm_kisan_samman_nidhi;
CREATE POLICY "Users access own data" ON public.pm_kisan_samman_nidhi FOR ALL TO PUBLIC
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = pm_kisan_samman_nidhi.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE (f.phone_number = pm_kisan_samman_nidhi.phone_number) AND (f.surveyor_email = (auth.jwt() ->> 'email'::text))));

COMMIT;
