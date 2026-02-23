BEGIN;

-- Enable RLS and add non-recursive 'Users access own data' policy for family child tables
-- Each policy checks the parent session's `surveyor_email` against the current auth JWT email

ALTER TABLE public.bank_accounts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.bank_accounts;
CREATE POLICY "Users access own data" ON public.bank_accounts
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.tribal_card ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.tribal_card;
CREATE POLICY "Users access own data" ON public.tribal_card
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.merged_govt_schemes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.merged_govt_schemes;
CREATE POLICY "Users access own data" ON public.merged_govt_schemes
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.pm_kisan_nidhi ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.pm_kisan_nidhi;
CREATE POLICY "Users access own data" ON public.pm_kisan_nidhi
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.ration_card ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.ration_card;
CREATE POLICY "Users access own data" ON public.ration_card
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.pm_kisan_samman_nidhi ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.pm_kisan_samman_nidhi;
CREATE POLICY "Users access own data" ON public.pm_kisan_samman_nidhi
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.vb_gram ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.vb_gram;
CREATE POLICY "Users access own data" ON public.vb_gram
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.pension_allowance ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.pension_allowance;
CREATE POLICY "Users access own data" ON public.pension_allowance
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.widow_allowance ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.widow_allowance;
CREATE POLICY "Users access own data" ON public.widow_allowance
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.handicapped_allowance ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.handicapped_allowance;
CREATE POLICY "Users access own data" ON public.handicapped_allowance
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.training_needs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Training needs - Users access own data" ON public.training_needs;
CREATE POLICY "Training needs - Users access own data" ON public.training_needs
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = training_needs.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = training_needs.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.family_members;
CREATE POLICY "Users access own data" ON public.family_members
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = family_members.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = family_members.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.family_id ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.family_id;
CREATE POLICY "Users access own data" ON public.family_id
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = family_id.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = family_id.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.aadhaar_info ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.aadhaar_info;
CREATE POLICY "Users access own data" ON public.aadhaar_info
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = aadhaar_info.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = aadhaar_info.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.ayushman_card ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.ayushman_card;
CREATE POLICY "Users access own data" ON public.ayushman_card
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = ayushman_card.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = ayushman_card.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

ALTER TABLE public.samagra_id ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users access own data" ON public.samagra_id;
CREATE POLICY "Users access own data" ON public.samagra_id
  FOR ALL
  USING (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = samagra_id.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.family_survey_sessions f WHERE f.phone_number = samagra_id.phone_number AND f.surveyor_email = auth.jwt() ->> 'email'));

COMMIT;
