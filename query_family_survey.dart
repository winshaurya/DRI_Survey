/*
 * SQL Query to get complete family survey data for phone number 4444444444
 *
 * Run this query in your Supabase SQL Editor or database client
 */

const String familySurveyQuery = '''
-- Complete Family Survey Query for phone number 4444444444
-- Run this in Supabase SQL Editor

SELECT
  -- Main session data
  fss.phone_number,
  fss.surveyor_email,
  fss.village_name,
  fss.panchayat,
  fss.block,
  fss.district,
  fss.shine_code,
  fss.latitude,
  fss.longitude,
  fss.status,
  fss.created_at,

  -- Family members
  (
    SELECT json_agg(
      json_build_object(
        'sr_no', fm.sr_no,
        'name', fm.name,
        'relationship', fm.relationship_with_head,
        'age', fm.age,
        'sex', fm.sex,
        'occupation', fm.occupation,
        'income', fm.income
      )
    )
    FROM family_members fm
    WHERE fm.phone_number = fss.phone_number
    ORDER BY fm.sr_no
  ) as family_members,

  -- Land holding
  lh.irrigated_area,
  lh.cultivable_area,
  lh.mango_trees,
  lh.guava_trees,

  -- Irrigation facilities
  ir.canal,
  ir.tube_well,
  ir.well,

  -- Crop productivity
  (
    SELECT json_agg(
      json_build_object(
        'crop_name', cp.crop_name,
        'area_hectares', cp.area_hectares,
        'total_production', cp.total_production_quintal
      )
    )
    FROM crop_productivity cp
    WHERE cp.phone_number = fss.phone_number
  ) as crops,

  -- Animals
  (
    SELECT json_agg(
      json_build_object(
        'animal_type', a.animal_type,
        'count', a.number_of_animals,
        'breed', a.breed
      )
    )
    FROM animals a
    WHERE a.phone_number = fss.phone_number
  ) as animals,

  -- Agricultural equipment
  ae.tractor,
  ae.thresher,

  -- House conditions
  hc.pakka,
  hc.katcha,
  hc.toilet_in_use,

  -- Government schemes
  (
    SELECT json_build_object(
      'aadhaar', ai.has_aadhaar,
      'ayushman', ac.has_card,
      'ration_card', rc.has_card,
      'pm_kisan', pkn.is_beneficiary
    )
    FROM aadhaar_info ai
    LEFT JOIN ayushman_card ac ON ac.phone_number = ai.phone_number
    LEFT JOIN ration_card rc ON rc.phone_number = ai.phone_number
    LEFT JOIN pm_kisan_nidhi pkn ON pkn.phone_number = ai.phone_number
    WHERE ai.phone_number = fss.phone_number
  ) as government_schemes

FROM family_survey_sessions fss
LEFT JOIN land_holding lh ON lh.phone_number = fss.phone_number
LEFT JOIN irrigation_facilities ir ON ir.phone_number = fss.phone_number
LEFT JOIN agricultural_equipment ae ON ae.phone_number = fss.phone_number
LEFT JOIN house_conditions hc ON hc.phone_number = fss.phone_number

WHERE fss.phone_number = '4444444444';
''';

void main() {
  print('SQL Query to get complete family survey data for phone number 4444444444:');
  print('');
  print(familySurveyQuery);
  print('');
  print('Instructions:');
  print('1. Copy the SQL query above');
  print('2. Go to your Supabase Dashboard');
  print('3. Navigate to SQL Editor');
  print('4. Paste and run the query');
  print('5. The result will show all family survey data for phone 4444444444');
}
