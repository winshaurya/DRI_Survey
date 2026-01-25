import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/database_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/font_size_provider.dart';
import '../../../providers/survey_provider.dart';
import '../pages/animals_page.dart';
import '../pages/crop_productivity_page.dart';
import '../pages/family_details_page.dart';
import '../pages/location_page.dart';

class SurveyPage extends StatefulWidget {
  final int pageIndex;
  final Function([Map<String, dynamic>?]) onNext;
  final VoidCallback? onPrevious;

  const SurveyPage({
    super.key,
    required this.pageIndex,
    required this.onNext,
    this.onPrevious,
  });

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _pageData = {};
  late double fontScale;

  @override
  void initState() {
    super.initState();
    // Initialize fontScale with default value
    fontScale = 0.7;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final l10n = AppLocalizations.of(context)!;
        fontScale = ref.watch(fontSizeProvider);

        return Scaffold(
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Page Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: FadeInUp(
                        child: _buildPageContent(widget.pageIndex, l10n, fontScale, ref),
                      ),
                    ),
                  ),

                  // Navigation Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (widget.onPrevious != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: widget.onPrevious,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                l10n.previous,
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                          ),

                        if (widget.onPrevious != null) const SizedBox(width: 16),

                        Expanded(
                          flex: widget.onPrevious != null ? 2 : 1,
                          child: ElevatedButton(
                            onPressed: () => _handleNext(ref),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.pageIndex == 22 ? l10n.submit : l10n.next,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageContent(int pageIndex, AppLocalizations l10n, double fontScale, WidgetRef ref) {
    switch (pageIndex) {
      case 0:
        return LocationPage(
          pageData: _pageData,
          onDataChanged: (data) {
            setState(() {
              _pageData.addAll(data);
            });
          },
        );
      case 1:
        return FamilyDetailsPage(
          pageData: _pageData,
          onDataChanged: (data) {
            setState(() {
              _pageData.addAll(data);
            });
          },
          formKey: _formKey,
        );
      case 2:
        return _buildSocialConsciousnessPage3a(l10n);
      case 3:
        return _buildSocialConsciousnessPage3b(l10n);
      case 4:
        return _buildSocialConsciousnessPage3c(l10n);
      case 5:
        return _buildLandHoldingPage(l10n);
      case 6:
        return _buildIrrigationPage(l10n);
      case 7:
        return CropProductivityPage(
          pageData: _pageData,
          onDataChanged: (data) {
            setState(() {
              _pageData.addAll(data);
            });
          },
        );
      case 8:
        return _buildFertilizerPage(l10n);
      case 9:
        return AnimalsPage(
          pageData: _pageData,
          onDataChanged: (data) {
            setState(() {
              _pageData.addAll(data);
            });
          },
        );
      case 10:
        return _buildEquipmentPage(l10n);
      case 11:
        return _buildEntertainmentPage(l10n);
      case 12:
        return _buildTransportPage(l10n);
      case 13:
        return _buildWaterSourcesPage(l10n);
      case 14:
        return _buildMedicalPage(l10n);
      case 15:
        return _buildDisputesPage(l10n);
      case 16:
        return _buildHouseConditionsPage(l10n);
      case 17:
        return _buildDiseasesPage(l10n);
      case 18:
        return _buildGovernmentSchemesPage(l10n);
      case 19:
        return _buildChildrenPage(l10n);
      case 20:
        return _buildMigrationPage(l10n);
      case 21:
        return _buildTrainingPage(l10n);
      case 22:
        return _buildFPOFamiliesPage(l10n);
      case 23:
        return _buildVBGramBeneficiariesPage(l10n);
      case 24:
        return _buildPMKisanBeneficiariesPage(l10n);
      case 25:
        return _buildPMKisanSammanBeneficiariesPage(l10n);
      case 26:
        return _buildKisanCreditCardBeneficiariesPage(l10n);
      case 27:
        return _buildSwachhBharatBeneficiariesPage(l10n);
      case 28:
        return _buildFasalBimaBeneficiariesPage(l10n);
      case 29:
        return _buildBankAccountHoldersPage(l10n);
      case 30:
        return _buildFinalPage(l10n, ref);
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget _buildLocationPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: Text(
            'Location Information',
            style: TextStyle(
              fontSize: 24 * fontScale,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 24),

        FadeInLeft(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 100),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: l10n.villageName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSaved: (value) => _pageData['village_name'] = value,
          ),
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.panchayat,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['panchayat'] = value,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: l10n.block,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _pageData['block'] = value,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: l10n.district,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _pageData['district'] = value,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.postalAddress,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
          onSaved: (value) => _pageData['postal_address'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.pinCode,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['pin_code'] = value,
        ),
      ],
    );
  }

  Widget _buildFamilyDetailsPage(AppLocalizations l10n) {
    final familyMembers = _pageData['family_members'] as List<Map<String, dynamic>>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.familyDetails,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide details for each family member',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Display existing family members
        ...familyMembers.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          return Column(
            children: [
              _buildFamilyMemberCard(index + 1, 'Family Member ${index + 1}', l10n, memberData: member),
              const SizedBox(height: 16),
            ],
          );
        }),

        // Add more family members button
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              final familyMembers = _pageData['family_members'] as List<Map<String, dynamic>>? ?? [];
              familyMembers.add({
                'sr_no': familyMembers.length + 1,
                'name': '',
                'fathers_name': '',
                'mothers_name': '',
                'relationship_with_head': '',
                'age': '',
                'sex': '',
                'physically_fit': '',
                'educational_qualification': '',
                'inclination_self_employment': '',
                'occupation': '',
                'days_employed': '',
                'income': '',
                'awareness_about_village': '',
                'participate_gram_sabha': '',
              });
              _pageData['family_members'] = familyMembers;
            });
          },
          icon: const Icon(Icons.add),
          label: Text(l10n.addMember),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        if (familyMembers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Click "Add Member" to add family members. At least one member is required.',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSocialConsciousnessPage3a(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Consciousness Survey - Part 1',
          style: TextStyle(
            fontSize: 24 * fontScale,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please answer questions about waste management and sanitation',
          style: TextStyle(
            fontSize: 14 * fontScale,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        // Question 1: How often do family members buy new clothes
        Text(
          '1. How often do family members buy new clothes?',
          style: TextStyle(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Weekly', 'clothes_frequency', 'weekly'),
        _buildRadioField('Monthly', 'clothes_frequency', 'monthly'),
        _buildRadioField('Yearly', 'clothes_frequency', 'yearly'),
        _buildRadioField('As per need', 'clothes_frequency', 'as_per_need'),
        _buildRadioField('Other (please specify)', 'clothes_frequency', 'other'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If other, please specify',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['clothes_frequency_other'] = value,
        ),

        const SizedBox(height: 24),

        // Question 2: Food Waste
        Text(
          '2. Is there food waste in the home?',
          style: TextStyle(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'food_waste', 'yes'),
        _buildRadioField('No', 'food_waste', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, how much?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['food_waste_amount'] = value,
        ),

        const SizedBox(height: 24),

        // Question 3: Waste Disposal
        Text(
          '3. How do you dispose of waste?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Throw anywhere', 'waste_disposal', 'throw_anywhere'),
        _buildRadioField('Put into village dustbins', 'waste_disposal', 'village_dustbins'),
        _buildRadioField('Collect and sell to kabadiwala', 'waste_disposal', 'kabadiwala'),
        _buildRadioField('Other (please specify)', 'waste_disposal', 'other'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If other, please specify',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['waste_disposal_other'] = value,
        ),

        const SizedBox(height: 24),

        // Question 4: Waste Segregation
        Text(
          '4. Do you segregate waste?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'waste_segregation', 'yes'),
        _buildRadioField('No', 'waste_segregation', 'no'),

        const SizedBox(height: 24),

        // Question 5: Compost Pit
        Text(
          '5. Do you have a compost pit?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'compost_pit', 'yes'),
        _buildRadioField('No', 'compost_pit', 'no'),

        const SizedBox(height: 24),

        // Question 6: Recycle Items
        Text(
          '6. Do you recycle used items?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'recycle_items', 'yes'),
        _buildRadioField('No', 'recycle_items', 'no'),

        const SizedBox(height: 24),

        // Question 7: Toilet
        Text(
          '7. Do you have a toilet?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'have_toilet', 'yes'),
        _buildRadioField('No', 'have_toilet', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, is it in use?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['toilet_in_use'] = value,
        ),

        const SizedBox(height: 24),

        // Question 8: Soak Pit
        Text(
          '8. If yes, does it have a soak pit?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'soak_pit', 'yes'),
        _buildRadioField('No', 'soak_pit', 'no'),
      ],
    );
  }

  Widget _buildSocialConsciousnessPage3b(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Consciousness Survey - Part 2',
          style: TextStyle(
            fontSize: 24 * fontScale,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please answer questions about energy, water conservation and spiritual practices',
          style: TextStyle(
            fontSize: 14 * fontScale,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        // Question 9: LED Lights
        Text(
          '9. Do you use LED lights?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'led_lights', 'yes'),
        _buildRadioField('No', 'led_lights', 'no'),

        const SizedBox(height: 24),

        // Question 10: Turn off devices
        Text(
          '10. Do you turn off electrical/electronic devices when not in use?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'turn_off_devices', 'yes'),
        _buildRadioField('No', 'turn_off_devices', 'no'),

        const SizedBox(height: 24),

        // Question 11: Fix leaking taps
        Text(
          '11. If you find water leaking from any tap/hand pump, do you try to fix it?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'fix_leaks', 'yes'),
        _buildRadioField('No', 'fix_leaks', 'no'),

        const SizedBox(height: 24),

        // Question 12: Avoid single-use plastics
        Text(
          '12. Do you avoid single-use plastics?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'avoid_plastics', 'yes'),
        _buildRadioField('No', 'avoid_plastics', 'no'),

        const SizedBox(height: 24),

        // Question 13: Family prayers
        Text(
          '13. Do all members of the family do Puja/Pray?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'family_prayers', 'yes'),
        _buildRadioField('No', 'family_prayers', 'no'),

        const SizedBox(height: 24),

        // Question 14: Meditation
        Text(
          '14. Do members of the family meditate?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'family_meditation', 'yes'),
        _buildRadioField('No', 'family_meditation', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['meditation_members'] = value,
        ),

        const SizedBox(height: 24),

        // Question 15: Yoga
        Text(
          '15. Do members of the family do Yoga?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'family_yoga', 'yes'),
        _buildRadioField('No', 'family_yoga', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['yoga_members'] = value,
        ),
      ],
    );
  }

  Widget _buildSocialConsciousnessPage3c(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Consciousness Survey - Part 3',
          style: TextStyle(
            fontSize: 24 * fontScale,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please answer questions about community participation and personal habits',
          style: TextStyle(
            fontSize: 14 * fontScale,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        // Question 16: Community activities
        Text(
          '16. Do members of your family participate in community activities?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'community_activities', 'yes'),
        _buildRadioField('No', 'community_activities', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, which activities?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['community_activities_type'] = value,
        ),

        const SizedBox(height: 24),

        // Question 17: Shram Sadhana
        Text(
          '17. Do members of your family participate in Shram Sadhana?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'shram_sadhana', 'yes'),
        _buildRadioField('No', 'shram_sadhana', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['shram_sadhana_members'] = value,
        ),

        const SizedBox(height: 24),

        // Question 18: Spiritual discourses
        Text(
          '18. Do members of the family listen to spiritual/motivational discourses (kathas)?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'spiritual_discourses', 'yes'),
        _buildRadioField('No', 'spiritual_discourses', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['discourses_members'] = value,
        ),

        const SizedBox(height: 24),

        // Question 19: Happiness
        Text(
          '19. Are you happy?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'personal_happiness', 'yes'),
        _buildRadioField('No', 'personal_happiness', 'no'),

        const SizedBox(height: 24),

        // Question 20: Family happiness
        Text(
          '20. Are members of your family happy?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'family_happiness', 'yes'),
        _buildRadioField('No', 'family_happiness', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['happy_members'] = value,
        ),

        const SizedBox(height: 24),

        // Question 21: Bad habits
        Text(
          '21. Does any member of the family:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildCheckboxField('Smoke', 'member_smokes'),
        _buildCheckboxField('Drink', 'member_drinks'),
        _buildCheckboxField('Eat Gudka', 'member_eats_gudka'),
        _buildCheckboxField('Gamble', 'member_gambles'),
        _buildCheckboxField('Chew Tobacco', 'member_chews_tobacco'),

        const SizedBox(height: 24),

        // Question 22: Savings
        Text(
          '22. Do you save?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'family_saves', 'yes'),
        _buildRadioField('No', 'family_saves', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, what percentage of income?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['savings_percentage'] = value,
        ),
      ],
    );
  }

  Widget _buildSocialConsciousnessPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Consciousness Survey',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please answer questions about your social consciousness and habits',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Question 1: How often do family members buy new clothes
        Text(
          '1. How often do family members buy new clothes?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Weekly', 'clothes_frequency', 'weekly'),
        _buildRadioField('Monthly', 'clothes_frequency', 'monthly'),
        _buildRadioField('Yearly', 'clothes_frequency', 'yearly'),
        _buildRadioField('As per need', 'clothes_frequency', 'as_per_need'),
        _buildRadioField('Other (please specify)', 'clothes_frequency', 'other'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If other, please specify',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['clothes_frequency_other'] = value,
        ),

        const SizedBox(height: 24),

        // Question 2: Food Waste
        Text(
          '2. Is there food waste in the home?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'food_waste', 'yes'),
        _buildRadioField('No', 'food_waste', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, how much?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['food_waste_amount'] = value,
        ),

        const SizedBox(height: 24),

        // Question 3: Waste Disposal
        Text(
          '3. How do you dispose of waste?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Throw anywhere', 'waste_disposal', 'throw_anywhere'),
        _buildRadioField('Put into village dustbins', 'waste_disposal', 'village_dustbins'),
        _buildRadioField('Collect and sell to kabadiwala', 'waste_disposal', 'kabadiwala'),
        _buildRadioField('Other (please specify)', 'waste_disposal', 'other'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If other, please specify',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['waste_disposal_other'] = value,
        ),

        const SizedBox(height: 24),

        // Question 4: Waste Segregation
        Text(
          '4. Do you segregate waste?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'waste_segregation', 'yes'),
        _buildRadioField('No', 'waste_segregation', 'no'),

        const SizedBox(height: 24),

        // Question 5: Compost Pit
        Text(
          '5. Do you have a compost pit?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'compost_pit', 'yes'),
        _buildRadioField('No', 'compost_pit', 'no'),

        const SizedBox(height: 24),

        // Question 6: Recycle Items
        Text(
          '6. Do you recycle used items?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'recycle_items', 'yes'),
        _buildRadioField('No', 'recycle_items', 'no'),

        const SizedBox(height: 24),

        // Question 7: Toilet
        Text(
          '7. Do you have a toilet?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'have_toilet', 'yes'),
        _buildRadioField('No', 'have_toilet', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, is it in use?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['toilet_in_use'] = value,
        ),

        const SizedBox(height: 24),

        // Question 8: Soak Pit
        Text(
          '8. If yes, does it have a soak pit?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'soak_pit', 'yes'),
        _buildRadioField('No', 'soak_pit', 'no'),

        const SizedBox(height: 24),

        // Question 9: LED Lights
        Text(
          '9. Do you use LED lights?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'led_lights', 'yes'),
        _buildRadioField('No', 'led_lights', 'no'),

        const SizedBox(height: 24),

        // Question 10: Turn off devices
        Text(
          '10. Do you turn off electrical/electronic devices when not in use?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'turn_off_devices', 'yes'),
        _buildRadioField('No', 'turn_off_devices', 'no'),

        const SizedBox(height: 24),

        // Question 11: Fix leaking taps
        Text(
          '11. If you find water leaking from any tap/hand pump, do you try to fix it?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'fix_leaks', 'yes'),
        _buildRadioField('No', 'fix_leaks', 'no'),

        const SizedBox(height: 24),

        // Question 12: Avoid single-use plastics
        Text(
          '12. Do you avoid single-use plastics?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'avoid_plastics', 'yes'),
        _buildRadioField('No', 'avoid_plastics', 'no'),

        const SizedBox(height: 24),

        // Question 13: Family prayers
        Text(
          '13. Do all members of the family do Puja/Pray?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'family_prayers', 'yes'),
        _buildRadioField('No', 'family_prayers', 'no'),

        const SizedBox(height: 24),

        // Question 14: Meditation
        Text(
          '14. Do members of the family meditate?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'family_meditation', 'yes'),
        _buildRadioField('No', 'family_meditation', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['meditation_members'] = value,
        ),

        const SizedBox(height: 24),

        // Question 15: Yoga
        Text(
          '15. Do members of the family do Yoga?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'family_yoga', 'yes'),
        _buildRadioField('No', 'family_yoga', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['yoga_members'] = value,
        ),

        const SizedBox(height: 24),

        // Question 16: Community activities
        Text(
          '16. Do members of your family participate in community activities?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'community_activities', 'yes'),
        _buildRadioField('No', 'community_activities', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, which activities?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['community_activities_type'] = value,
        ),

        const SizedBox(height: 24),

        // Question 17: Shram Sadhana
        Text(
          '17. Do members of your family participate in Shram Sadhana?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'shram_sadhana', 'yes'),
        _buildRadioField('No', 'shram_sadhana', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['shram_sadhana_members'] = value,
        ),

        const SizedBox(height: 24),

        // Question 18: Spiritual discourses
        Text(
          '18. Do members of the family listen to spiritual/motivational discourses (kathas)?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'spiritual_discourses', 'yes'),
        _buildRadioField('No', 'spiritual_discourses', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['discourses_members'] = value,
        ),

        const SizedBox(height: 24),

        // Question 19: Happiness
        Text(
          '19. Are you happy?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'personal_happiness', 'yes'),
        _buildRadioField('No', 'personal_happiness', 'no'),

        const SizedBox(height: 24),

        // Question 20: Family happiness
        Text(
          '20. Are members of your family happy?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'family_happiness', 'yes'),
        _buildRadioField('No', 'family_happiness', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['happy_members'] = value,
        ),

        const SizedBox(height: 24),

        // Question 21: Bad habits
        Text(
          '21. Does any member of the family:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildCheckboxField('Smoke', 'member_smokes'),
        _buildCheckboxField('Drink', 'member_drinks'),
        _buildCheckboxField('Eat Gudka', 'member_eats_gudka'),
        _buildCheckboxField('Gamble', 'member_gambles'),
        _buildCheckboxField('Chew Tobacco', 'member_chews_tobacco'),

        const SizedBox(height: 24),

        // Question 22: Savings
        Text(
          '22. Do you save?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'family_saves', 'yes'),
        _buildRadioField('No', 'family_saves', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'If yes, what percentage of income?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['savings_percentage'] = value,
        ),
      ],
    );
  }

  Widget _buildCheckboxField(String label, String key) {
    return CheckboxListTile(
      title: Text(label),
      value: _pageData[key] ?? false,
      onChanged: (value) {
        setState(() {
          _pageData[key] = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildRadioField(String label, String groupKey, String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _pageData[groupKey],
          onChanged: (newValue) {
            setState(() {
              _pageData[groupKey] = newValue;
            });
          },
        ),
        Text(label),
      ],
    );
  }

  Widget _buildCropCard(int cropNumber, AppLocalizations l10n, {Map<String, dynamic>? cropData}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crop ${cropNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: cropData?['crop_name'],
              decoration: InputDecoration(
                labelText: l10n.cropName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.grass),
              ),
              onChanged: (value) {
                if (cropData != null) {
                  cropData['crop_name'] = value;
                }
              },
              onSaved: (value) => _pageData['crop_${cropNumber}_name'] = value,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: cropData?['area_acres'],
                    decoration: InputDecoration(
                      labelText: '${l10n.areaAcres} (Acres)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.straighten),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (cropData != null) {
                        cropData['area_acres'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['crop_${cropNumber}_area'] = value,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: TextFormField(
                    initialValue: cropData?['productivity_quintal_per_acre'],
                    decoration: InputDecoration(
                      labelText: '${l10n.productivity} (Qtl/Acre)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.trending_up),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (cropData != null) {
                        cropData['productivity_quintal_per_acre'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['crop_${cropNumber}_productivity'] = value,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: cropData?['total_production'],
                    decoration: InputDecoration(
                      labelText: l10n.totalProduction,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.inventory),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (cropData != null) {
                        cropData['total_production'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['crop_${cropNumber}_total_production'] = value,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: TextFormField(
                    initialValue: cropData?['quantity_consumed'],
                    decoration: InputDecoration(
                      labelText: l10n.quantityConsumed,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.restaurant),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (cropData != null) {
                        cropData['quantity_consumed'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['crop_${cropNumber}_consumed'] = value,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: cropData?['quantity_sold'],
              decoration: InputDecoration(
                labelText: l10n.quantitySold,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.sell),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (cropData != null) {
                  cropData['quantity_sold'] = value;
                }
              },
              onSaved: (value) => _pageData['crop_${cropNumber}_sold'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalCard(int animalNumber, AppLocalizations l10n, {Map<String, dynamic>? animalData}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Animal ${animalNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: animalData?['animal_type'],
              decoration: InputDecoration(
                labelText: l10n.animalType,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.pets),
              ),
              onChanged: (value) {
                if (animalData != null) {
                  animalData['animal_type'] = value;
                }
              },
              onSaved: (value) => _pageData['animal_${animalNumber}_type'] = value,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: animalData?['number_of_animals'],
                    decoration: InputDecoration(
                      labelText: l10n.numberOfAnimals,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (animalData != null) {
                        animalData['number_of_animals'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['animal_${animalNumber}_count'] = value,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: TextFormField(
                    initialValue: animalData?['breed'],
                    decoration: InputDecoration(
                      labelText: l10n.breed,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    onChanged: (value) {
                      if (animalData != null) {
                        animalData['breed'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['animal_${animalNumber}_breed'] = value,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: animalData?['production_per_animal'],
              decoration: InputDecoration(
                labelText: l10n.productionPerAnimal,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.production_quantity_limits),
              ),
              onChanged: (value) {
                if (animalData != null) {
                  animalData['production_per_animal'] = value;
                }
              },
              onSaved: (value) => _pageData['animal_${animalNumber}_production'] = value,
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: animalData?['quantity_sold'],
              decoration: InputDecoration(
                labelText: 'Quantity Sold',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.sell),
              ),
              onChanged: (value) {
                if (animalData != null) {
                  animalData['quantity_sold'] = value;
                }
              },
              onSaved: (value) => _pageData['animal_${animalNumber}_sold'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseCard(int diseaseNumber, AppLocalizations l10n, double fontScale, {Map<String, dynamic>? diseaseData}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disease ${diseaseNumber}',
              style: TextStyle(
                fontSize: 18 * fontScale,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.diseaseName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.medical_services),
              ),
              items: [
                DropdownMenuItem(value: 'diabetes', child: Text('Diabetes')),
                DropdownMenuItem(value: 'hypertension', child: Text('Hypertension/Blood Pressure')),
                DropdownMenuItem(value: 'heart_disease', child: Text('Heart Disease')),
                DropdownMenuItem(value: 'asthma', child: Text('Asthma')),
                DropdownMenuItem(value: 'tuberculosis', child: Text('Tuberculosis')),
                DropdownMenuItem(value: 'cancer', child: Text('Cancer')),
                DropdownMenuItem(value: 'arthritis', child: Text('Arthritis')),
                DropdownMenuItem(value: 'kidney_disease', child: Text('Kidney Disease')),
                DropdownMenuItem(value: 'liver_disease', child: Text('Liver Disease')),
                DropdownMenuItem(value: 'thyroid', child: Text('Thyroid Problems')),
                DropdownMenuItem(value: 'mental_health', child: Text('Mental Health Issues')),
                DropdownMenuItem(value: 'epilepsy', child: Text('Epilepsy')),
                DropdownMenuItem(value: 'malaria', child: Text('Malaria')),
                DropdownMenuItem(value: 'dengue', child: Text('Dengue')),
                DropdownMenuItem(value: 'other', child: Text('Other (please specify)')),
              ],
              onChanged: (value) {
                if (diseaseData != null) {
                  diseaseData['disease_name'] = value;
                }
              },
              value: diseaseData?['disease_name'],
              onSaved: (value) => _pageData['disease_${diseaseNumber}_name'] = value,
            ),

            const SizedBox(height: 16),

            if (diseaseData?['disease_name'] == 'other')
              TextFormField(
                initialValue: diseaseData?['other_disease'],
                decoration: InputDecoration(
                  labelText: 'Specify other disease',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  if (diseaseData != null) {
                    diseaseData['other_disease'] = value;
                  }
                },
                onSaved: (value) => _pageData['disease_${diseaseNumber}_other'] = value,
              ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: diseaseData?['suffering_since'],
              decoration: InputDecoration(
                labelText: l10n.sufferingSince,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              onChanged: (value) {
                if (diseaseData != null) {
                  diseaseData['suffering_since'] = value;
                }
              },
              onSaved: (value) => _pageData['disease_${diseaseNumber}_since'] = value,
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: diseaseData?['treatment_from'],
              decoration: InputDecoration(
                labelText: l10n.treatmentFrom,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.local_hospital),
              ),
              onChanged: (value) {
                if (diseaseData != null) {
                  diseaseData['treatment_from'] = value;
                }
              },
              onSaved: (value) => _pageData['disease_${diseaseNumber}_treatment'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeCard(String schemeName, String key) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schemeName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Have Card',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'yes', child: Text('Yes')),
                      DropdownMenuItem(value: 'no', child: Text('No')),
                      DropdownMenuItem(value: 'applied', child: Text('Applied')),
                    ],
                    onChanged: (value) {
                      // Handle change
                    },
                    onSaved: (value) => _pageData['${key}_have_card'] = value,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSaved: (value) => _pageData['${key}_card_number'] = value,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextFormField(
              decoration: InputDecoration(
                labelText: 'Benefits Received',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
              onSaved: (value) => _pageData['${key}_benefits'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildMalnutritionCard(int childNumber, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Child ${childNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: '${l10n.height} (feet)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.height),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _pageData['child_${childNumber}_height'] = value,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: '${l10n.weight} (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.monitor_weight),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _pageData['child_${childNumber}_weight'] = value,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.causeDisease,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.medical_services),
              ),
              onSaved: (value) => _pageData['child_${childNumber}_cause'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberCard(int memberNumber, String relation, AppLocalizations l10n, {bool isRequired = false, Map<String, dynamic>? memberData}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    memberNumber.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$relation ${isRequired ? '(Required)' : ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: memberData?['name'],
              decoration: InputDecoration(
                labelText: '${l10n.memberName}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              onChanged: (value) {
                if (memberData != null) {
                  memberData['name'] = value;
                }
              },
              onSaved: (value) => _pageData['member_${memberNumber}_name'] = value,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: memberData?['age'],
                    decoration: InputDecoration(
                      labelText: '${l10n.age}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (memberData != null) {
                        memberData['age'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['member_${memberNumber}_age'] = value,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: memberData?['sex'],
                    decoration: InputDecoration(
                      labelText: '${l10n.sex}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.wc),
                    ),
                    items: [
                      DropdownMenuItem(value: 'male', child: Text(l10n.male)),
                      DropdownMenuItem(value: 'female', child: Text(l10n.female)),
                      DropdownMenuItem(value: 'other', child: Text(l10n.other)),
                    ],
                    onChanged: (value) {
                      if (memberData != null) {
                        memberData['sex'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['member_${memberNumber}_sex'] = value,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: memberData?['relationship_with_head'],
              decoration: InputDecoration(
                labelText: l10n.relation,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.family_restroom),
              ),
              onChanged: (value) {
                if (memberData != null) {
                  memberData['relationship_with_head'] = value;
                }
              },
              onSaved: (value) => _pageData['member_${memberNumber}_relation'] = value,
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: memberData?['educational_qualification'],
              decoration: InputDecoration(
                labelText: l10n.education,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.school),
              ),
              onChanged: (value) {
                if (memberData != null) {
                  memberData['educational_qualification'] = value;
                }
              },
              onSaved: (value) => _pageData['member_${memberNumber}_education'] = value,
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: memberData?['occupation'],
              decoration: InputDecoration(
                labelText: l10n.occupation,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.work),
              ),
              onChanged: (value) {
                if (memberData != null) {
                  memberData['occupation'] = value;
                }
              },
              onSaved: (value) => _pageData['member_${memberNumber}_occupation'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandHoldingPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.landHolding,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide information about your land holdings',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        TextFormField(
          decoration: InputDecoration(
            labelText: '${l10n.irrigatedArea} (Acres)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.water),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['irrigated_area'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: '${l10n.cultivableArea} (Acres)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.agriculture),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['cultivable_area'] = value,
        ),

        const SizedBox(height: 24),

        Text(
          l10n.orchardPlants,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        _buildCheckboxField('Mango Trees', 'mango_trees'),
        _buildCheckboxField('Guava Trees', 'guava_trees'),
        _buildCheckboxField('Lemon Trees', 'lemon_trees'),
        _buildCheckboxField('Banana Plants', 'banana_plants'),
        _buildCheckboxField('Papaya Trees', 'papaya_trees'),
        _buildCheckboxField('Other Fruit Trees', 'other_fruit_trees'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Other Orchard Plants (specify)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['other_orchard_plants'] = value,
        ),
      ],
    );
  }

  Widget _buildIrrigationPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.irrigationFacilities,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please select the irrigation facilities available to you',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildCheckboxField(l10n.canal, 'canal'),
        _buildCheckboxField(l10n.tubeWell, 'tube_well'),
        _buildCheckboxField(l10n.ponds, 'ponds'),
        _buildCheckboxField(l10n.otherFacilities, 'other_facilities'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Specify other irrigation facilities',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['other_irrigation_specify'] = value,
        ),

        const SizedBox(height: 24),

        Text(
          'Water Source Details',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Primary water source',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.water_drop),
          ),
          onSaved: (value) => _pageData['primary_water_source'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Distance from water source (${l10n.distance})',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.straighten),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['water_source_distance'] = value,
        ),
      ],
    );
  }
  Widget _buildCropProductivityPage(AppLocalizations l10n) {
    final crops = _pageData['crops'] as List<Map<String, dynamic>>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cropProductivity,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide details about your crop production',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Display existing crops
        ...crops.asMap().entries.map((entry) {
          final index = entry.key;
          final crop = entry.value;
          return Column(
            children: [
              _buildCropCard(index + 1, l10n, cropData: crop),
              const SizedBox(height: 16),
            ],
          );
        }),

        // Add more crops button
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              final crops = _pageData['crops'] as List<Map<String, dynamic>>? ?? [];
              crops.add({
                'sr_no': crops.length + 1,
                'crop_name': '',
                'area_acres': '',
                'productivity_quintal_per_acre': '',
                'total_production': '',
                'quantity_consumed': '',
                'quantity_sold': '',
              });
              _pageData['crops'] = crops;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Another Crop'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        if (crops.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Click "Add Another Crop" to add crop details.',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFertilizerPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.fertilizerUsage,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please select the type of fertilizers used',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildCheckboxField(l10n.chemical, 'chemical_fertilizer'),
        _buildCheckboxField(l10n.organic, 'organic_fertilizer'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Fertilizer brands/types used',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 2,
          onSaved: (value) => _pageData['fertilizer_types'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Annual fertilizer expenditure (₹)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.currency_rupee),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['fertilizer_expenditure'] = value,
        ),
      ],
    );
  }

  Widget _buildAnimalsPage(AppLocalizations l10n) {
    final animals = _pageData['animals'] as List<Map<String, dynamic>>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.animals,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide details about your livestock',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Display existing animals
        ...animals.asMap().entries.map((entry) {
          final index = entry.key;
          final animal = entry.value;
          return Column(
            children: [
              _buildAnimalCard(index + 1, l10n, animalData: animal),
              const SizedBox(height: 16),
            ],
          );
        }),

        // Add more animals button
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              final animals = _pageData['animals'] as List<Map<String, dynamic>>? ?? [];
              animals.add({
                'sr_no': animals.length + 1,
                'animal_type': '',
                'number_of_animals': '',
                'breed': '',
                'production_per_animal': '',
                'quantity_sold': '',
              });
              _pageData['animals'] = animals;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Another Animal'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        if (animals.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Click "Add Another Animal" to add livestock details.',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEquipmentPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.agriculturalEquipment,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please select the agricultural equipment you own',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildCheckboxField(l10n.tractor, 'tractor'),
        _buildCheckboxField(l10n.thresher, 'thresher'),
        _buildCheckboxField(l10n.seedDrill, 'seed_drill'),
        _buildCheckboxField(l10n.sprayer, 'sprayer'),
        _buildCheckboxField(l10n.duster, 'duster'),
        _buildCheckboxField(l10n.dieselEngine, 'diesel_engine'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Other equipment (specify)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['other_equipment'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Equipment condition (Good/Average/Poor)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['equipment_condition'] = value,
        ),
      ],
    );
  }

  Widget _buildEntertainmentPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.entertainmentFacilities,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please select the entertainment facilities available',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildCheckboxField(l10n.smartMobile, 'smart_mobile'),
        _buildCheckboxField(l10n.analogMobile, 'analog_mobile'),
        _buildCheckboxField(l10n.television, 'television'),
        _buildCheckboxField(l10n.radio, 'radio'),
        _buildCheckboxField(l10n.games, 'games'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Other entertainment facilities',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['other_entertainment'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Monthly expenditure on entertainment (₹)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.currency_rupee),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['entertainment_expenditure'] = value,
        ),
      ],
    );
  }

  Widget _buildTransportPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.transportFacilities,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please select the transport facilities available',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildCheckboxField(l10n.carJeep, 'car_jeep'),
        _buildCheckboxField(l10n.motorcycleScooter, 'motorcycle_scooter'),
        _buildCheckboxField(l10n.eRickshaw, 'e_rickshaw'),
        _buildCheckboxField(l10n.cycle, 'cycle'),
        _buildCheckboxField(l10n.pickupTruck, 'pickup_truck'),
        _buildCheckboxField(l10n.bullockCart, 'bullock_cart'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Other transport facilities',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['other_transport'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Distance to nearest market (${l10n.distance})',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.straighten),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['market_distance'] = value,
        ),
      ],
    );
  }

  Widget _buildWaterSourcesPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.drinkingWaterSources,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please select the drinking water sources available',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildCheckboxField(l10n.handPumps, 'hand_pumps'),
        _buildCheckboxField(l10n.well, 'well'),
        _buildCheckboxField(l10n.tubewell, 'tubewell'),
        _buildCheckboxField(l10n.nalJaal, 'nal_jaal'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Primary drinking water source',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.water_drop),
          ),
          onSaved: (value) => _pageData['primary_drinking_water'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Water quality (Good/Average/Poor)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['water_quality'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Monthly water expenditure (₹)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.currency_rupee),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['water_expenditure'] = value,
        ),
      ],
    );
  }

  Widget _buildMedicalPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicalTreatment,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please select the medical treatment options used',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildCheckboxField(l10n.allopathic, 'allopathic'),
        _buildCheckboxField(l10n.ayurvedic, 'ayurvedic'),
        _buildCheckboxField(l10n.homeopathy, 'homeopathy'),
        _buildCheckboxField(l10n.traditional, 'traditional'),
        _buildCheckboxField('Others', 'jhad_phook'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Distance to nearest hospital (${l10n.distance})',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.straighten),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['hospital_distance'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Monthly medical expenditure (₹)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.currency_rupee),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['medical_expenditure'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Health insurance coverage (Yes/No/Details)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['health_insurance'] = value,
        ),
      ],
    );
  }

  Widget _buildDisputesPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.disputes,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide information about any disputes',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildCheckboxField(l10n.familyDisputes, 'family_disputes'),
        _buildCheckboxField(l10n.revenueDisputes, 'revenue_disputes'),
        _buildCheckboxField(l10n.criminalDisputes, 'criminal_disputes'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.disputePeriod,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['dispute_period'] = value,
        ),

        const SizedBox(height: 16),

        Text(
          'Is the dispute resolved?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'dispute_resolved', 'yes'),
        _buildRadioField('No', 'dispute_resolved', 'no'),
      ],
    );
  }

  Widget _buildHouseConditionsPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.houseConditions,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide details about your house conditions',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        Text(
          'House Type:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        _buildCheckboxField(l10n.katcha, 'katcha_house'),
        _buildCheckboxField(l10n.pakka, 'pakka_house'),
        _buildCheckboxField(l10n.katchaPakka, 'katcha_pakka_house'),
        _buildCheckboxField(l10n.hut, 'hut_house'),

        const SizedBox(height: 24),

        Text(
          l10n.houseFacilities,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        _buildCheckboxField(l10n.toilet, 'toilet'),
        _buildCheckboxField(l10n.drainage, 'drainage'),
        _buildCheckboxField(l10n.soakPit, 'soak_pit'),
        _buildCheckboxField(l10n.cattleShed, 'cattle_shed'),
        _buildCheckboxField(l10n.compostPit, 'compost_pit'),
        _buildCheckboxField(l10n.nadep, 'nadep'),
        _buildCheckboxField(l10n.lpgGas, 'lpg_gas'),
        _buildCheckboxField(l10n.biogas, 'biogas'),
        _buildCheckboxField(l10n.solarCooking, 'solar_cooking'),
        _buildCheckboxField(l10n.electricConnection, 'electric_connection'),
        _buildCheckboxField(l10n.nutritionalGarden, 'nutritional_garden'),

        const SizedBox(height: 16),

        Text(
          'Do you have Tulsi plants?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Radio<String>(
              value: 'yes',
              groupValue: _pageData['tulsi_plants'],
              onChanged: (value) {
                setState(() {
                  _pageData['tulsi_plants'] = value;
                });
              },
              activeColor: Colors.green,
            ),
            const Text('Yes'),
            const SizedBox(width: 20),
            Radio<String>(
              value: 'no',
              groupValue: _pageData['tulsi_plants'],
              onChanged: (value) {
                setState(() {
                  _pageData['tulsi_plants'] = value;
                });
              },
              activeColor: Colors.green,
            ),
            const Text('No'),
          ],
        ),

        const SizedBox(height: 16),

        TextFormField(
          initialValue: _pageData['number_of_rooms'],
          decoration: InputDecoration(
            labelText: 'Number of rooms',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => _pageData['number_of_rooms'] = value,
          onSaved: (value) => _pageData['number_of_rooms'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          initialValue: _pageData['house_ownership'],
          decoration: InputDecoration(
            labelText: 'House ownership (Owned/Rented)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) => _pageData['house_ownership'] = value,
          onSaved: (value) => _pageData['house_ownership'] = value,
        ),
      ],
    );
  }

  Widget _buildDiseasesPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.seriousDiseases,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide information about serious diseases in the family',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Disease 1
        _buildDiseaseCard(1, l10n, fontScale),

        const SizedBox(height: 24),

        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Multiple disease entries coming soon')),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Another Disease'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),


      ],
    );
  }

  Widget _buildGovernmentSchemesPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.governmentSchemes,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide information about government scheme benefits',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildSchemeCard(l10n.aadhaar, 'aadhaar'),
        _buildSchemeCard(l10n.ayushman, 'ayushman'),
        _buildSchemeCard(l10n.familyId, 'family_id'),
        _buildSchemeCard(l10n.rationCard, 'ration_card'),
        _buildSchemeCard(l10n.samagraId, 'samagra_id'),
        _buildSchemeCard(l10n.tribalCard, 'tribal_card'),
        _buildSchemeCard(l10n.handicappedAllowance, 'handicapped_allowance'),
        _buildSchemeCard(l10n.pensionAllowance, 'pension_allowance'),
        _buildSchemeCard(l10n.widowAllowance, 'widow_allowance'),
      ],
    );
  }

  Widget _buildChildrenPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.childrenData,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide information about children in the family',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.birthsLast3Years,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['births_last_3_years'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.infantDeathsLast3Years,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['infant_deaths_last_3_years'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.malnourishedChildren,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['malnourished_children'] = value,
        ),

        const SizedBox(height: 24),

        Text(
          l10n.malnutritionData,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Child 1 malnutrition data
        _buildChildMalnutritionCard(1, l10n),

        const SizedBox(height: 24),

        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Multiple child entries coming soon')),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Another Child'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMigrationPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.migration,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide information about family migration',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        Text(
          l10n.migrationType,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        _buildCheckboxField(l10n.permanent, 'permanent_migration'),
        _buildCheckboxField(l10n.seasonal, 'seasonal_migration'),
        _buildCheckboxField(l10n.asNeeded, 'as_needed_migration'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.jobDescription,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['migration_job_description'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Migration destination',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['migration_destination'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Monthly remittance received (₹)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.currency_rupee),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['monthly_remittance'] = value,
        ),
      ],
    );
  }

  Widget _buildTrainingPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.training,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide information about training and self-help groups',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        Text(
          'Do you need training?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildRadioField('Yes', 'need_training', 'yes'),
        _buildRadioField('No', 'need_training', 'no'),

        const SizedBox(height: 24),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.trainingType,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['training_type'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.institute,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['training_institute'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.yearOfPassing,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _pageData['year_of_passing'] = value,
        ),

        const SizedBox(height: 24),

        Text(
          l10n.selfHelpGroups,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.shgName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['shg_name'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.purpose,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['shg_purpose'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.agency,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['shg_agency'] = value,
        ),

        const SizedBox(height: 24),

        Text(
          l10n.fpoMembership,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: l10n.fpoName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['fpo_name'] = value,
        ),
      ],
    );
  }

  Widget _buildFinalPage(AppLocalizations l10n, WidgetRef ref) {
    final surveyData = ref.watch(surveyProvider).surveyData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.preview,
                size: 32,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              Text(
                'Survey Preview',
                style: TextStyle(
                  fontSize: 24 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Review all your responses before submitting',
            style: TextStyle(
              fontSize: 14 * fontScale,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Survey Summary Sections
          _buildPreviewSection('Location Information', [
            _buildPreviewField('Village Name', surveyData['village_name']),
            _buildPreviewField('Panchayat', surveyData['panchayat']),
            _buildPreviewField('Block', surveyData['block']),
            _buildPreviewField('District', surveyData['district']),
            _buildPreviewField('Tehsil', surveyData['tehsil']),
            _buildPreviewField('Postal Address', surveyData['postal_address']),
            _buildPreviewField('PIN Code', surveyData['pin_code']),
            _buildPreviewField('Surveyor Name', surveyData['surveyor_name']),
          ]),

          _buildPreviewSection('Family Details', [
            _buildPreviewField('Head of Family Name', surveyData['member_1_name']),
            _buildPreviewField("Head of Family Father's Name", surveyData['member_1_fathers_name']),
            _buildPreviewField("Head of Family Mother's Name", surveyData['member_1_mothers_name']),
            _buildPreviewField('Head of Family Relationship', surveyData['member_1_relationship_with_head']),
            _buildPreviewField('Head of Family Age', surveyData['member_1_age']),
            _buildPreviewField('Head of Family Sex', surveyData['member_1_sex']),
            _buildPreviewField('Head of Family Physically Fit', surveyData['member_1_physically_fit']),
            _buildPreviewField('Head of Family Education', surveyData['member_1_educational_qualification']),
            _buildPreviewField('Head of Family Self Employment Inclination', surveyData['member_1_inclination_self_employment']),
            _buildPreviewField('Head of Family Occupation', surveyData['member_1_occupation']),
            _buildPreviewField('Head of Family Days Employed', surveyData['member_1_days_employed']),
            _buildPreviewField('Head of Family Income', surveyData['member_1_income']),
            _buildPreviewField('Head of Family Village Awareness', surveyData['member_1_awareness_about_village']),
            _buildPreviewField('Head of Family Gram Sabha Participation', surveyData['member_1_participate_gram_sabha']),
          ]),

          _buildPreviewSection('Land Holding', [
            _buildPreviewField('Irrigated Area (Acres)', surveyData['irrigated_area']),
            _buildPreviewField('Cultivable Area (Acres)', surveyData['cultivable_area']),
            _buildPreviewField('Mango Trees', surveyData['mango_trees'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Guava Trees', surveyData['guava_trees'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Lemon Trees', surveyData['lemon_trees'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Banana Plants', surveyData['banana_plants'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Papaya Trees', surveyData['papaya_trees'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Other Fruit Trees', surveyData['other_fruit_trees'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Other Orchard Plants', surveyData['other_orchard_plants']),
          ]),

          _buildPreviewSection('Irrigation Facilities', [
            _buildPreviewField('Canal', surveyData['canal'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Tube Well', surveyData['tube_well'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Ponds', surveyData['ponds'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Other Facilities', surveyData['other_facilities'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Other Irrigation Details', surveyData['other_irrigation_specify']),
            _buildPreviewField('Primary Water Source', surveyData['primary_water_source']),
            _buildPreviewField('Water Source Distance', surveyData['water_source_distance']),
          ]),

          _buildPreviewSection('Crop Productivity', [
            _buildPreviewField('Crop 1 Name', surveyData['crop_1_name']),
            _buildPreviewField('Crop 1 Area (Acres)', surveyData['crop_1_area']),
            _buildPreviewField('Crop 1 Productivity (Qtl/Acre)', surveyData['crop_1_productivity']),
            _buildPreviewField('Crop 1 Total Production', surveyData['crop_1_total_production']),
            _buildPreviewField('Crop 1 Consumed', surveyData['crop_1_consumed']),
            _buildPreviewField('Crop 1 Sold', surveyData['crop_1_sold']),
          ]),

          _buildPreviewSection('Fertilizer Usage', [
            _buildPreviewField('Chemical Fertilizer', surveyData['chemical_fertilizer'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Organic Fertilizer', surveyData['organic_fertilizer'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Fertilizer Types', surveyData['fertilizer_types']),
            _buildPreviewField('Fertilizer Expenditure (₹)', surveyData['fertilizer_expenditure']),
          ]),

          _buildPreviewSection('Animals/Livestock', [
            _buildPreviewField('Animal 1 Type', surveyData['animal_1_type']),
            _buildPreviewField('Animal 1 Count', surveyData['animal_1_count']),
            _buildPreviewField('Animal 1 Breed', surveyData['animal_1_breed']),
            _buildPreviewField('Animal 1 Production', surveyData['animal_1_production']),
          ]),

          _buildPreviewSection('Agricultural Equipment', [
            _buildPreviewField('Tractor', surveyData['tractor'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Thresher', surveyData['thresher'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Seed Drill', surveyData['seed_drill'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Sprayer', surveyData['sprayer'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Duster', surveyData['duster'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Diesel Engine', surveyData['diesel_engine'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Other Equipment', surveyData['other_equipment']),
            _buildPreviewField('Equipment Condition', surveyData['equipment_condition']),
          ]),

          _buildPreviewSection('Entertainment Facilities', [
            _buildPreviewField('Smart Mobile', surveyData['smart_mobile'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Analog Mobile', surveyData['analog_mobile'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Television', surveyData['television'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Radio', surveyData['radio'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Games', surveyData['games'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Other Entertainment', surveyData['other_entertainment']),
            _buildPreviewField('Entertainment Expenditure (₹)', surveyData['entertainment_expenditure']),
          ]),

          _buildPreviewSection('Transport Facilities', [
            _buildPreviewField('Car/Jeep', surveyData['car_jeep'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Motorcycle/Scooter', surveyData['motorcycle_scooter'] == true ? 'Yes' : 'No'),
            _buildPreviewField('E-Rickshaw', surveyData['e_rickshaw'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Cycle', surveyData['cycle'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Pickup Truck', surveyData['pickup_truck'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Bullock Cart', surveyData['bullock_cart'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Other Transport', surveyData['other_transport']),
            _buildPreviewField('Market Distance', surveyData['market_distance']),
          ]),

          _buildPreviewSection('Drinking Water Sources', [
            _buildPreviewField('Hand Pumps', surveyData['hand_pumps'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Well', surveyData['well'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Tube Well', surveyData['tubewell'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Nal Jaal', surveyData['nal_jaal'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Primary Drinking Water', surveyData['primary_drinking_water']),
            _buildPreviewField('Water Quality', surveyData['water_quality']),
            _buildPreviewField('Water Expenditure (₹)', surveyData['water_expenditure']),
          ]),

          _buildPreviewSection('Medical Treatment', [
            _buildPreviewField('Allopathic', surveyData['allopathic'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Ayurvedic', surveyData['ayurvedic'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Homeopathy', surveyData['homeopathy'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Traditional', surveyData['traditional'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Jhad Phook', surveyData['jhad_phook'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Hospital Distance', surveyData['hospital_distance']),
            _buildPreviewField('Medical Expenditure (₹)', surveyData['medical_expenditure']),
            _buildPreviewField('Health Insurance', surveyData['health_insurance']),
          ]),

          _buildPreviewSection('Disputes', [
            _buildPreviewField('Family Disputes', surveyData['family_disputes'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Revenue Disputes', surveyData['revenue_disputes'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Criminal Disputes', surveyData['criminal_disputes'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Dispute Period', surveyData['dispute_period']),
            _buildPreviewField('Dispute Resolution', surveyData['dispute_resolution']),
            _buildPreviewField('Dispute Status', surveyData['dispute_status']),
          ]),

          _buildPreviewSection('House Conditions', [
            _buildPreviewField('Katcha House', surveyData['katcha_house'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Pakka House', surveyData['pakka_house'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Katcha-Pakka House', surveyData['katcha_pakka_house'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Hut House', surveyData['hut_house'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Toilet', surveyData['toilet'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Drainage', surveyData['drainage'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Soak Pit', surveyData['soak_pit'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Cattle Shed', surveyData['cattle_shed'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Compost Pit', surveyData['compost_pit'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Nadep', surveyData['nadep'] == true ? 'Yes' : 'No'),
            _buildPreviewField('LPG Gas', surveyData['lpg_gas'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Biogas', surveyData['biogas'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Solar Cooking', surveyData['solar_cooking'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Electric Connection', surveyData['electric_connection'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Nutritional Garden', surveyData['nutritional_garden'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Number of Rooms', surveyData['number_of_rooms']),
            _buildPreviewField('House Ownership', surveyData['house_ownership']),
          ]),

          _buildPreviewSection('Diseases', [
            _buildPreviewField('Disease 1 Name', surveyData['disease_1_name']),
            _buildPreviewField('Disease 1 Since', surveyData['disease_1_since']),
            _buildPreviewField('Disease 1 Treatment', surveyData['disease_1_treatment']),
            _buildPreviewField('Tulsi Plants Count', surveyData['tulsi_plants_count']),
            _buildPreviewField('Tulsi Benefits', surveyData['tulsi_benefits']),
          ]),

          _buildPreviewSection('Government Schemes', [
            _buildPreviewField('Aadhaar Card', surveyData['aadhaar_have_card']),
            _buildPreviewField('Aadhaar Card Number', surveyData['aadhaar_card_number']),
            _buildPreviewField('Aadhaar Benefits', surveyData['aadhaar_benefits']),
            _buildPreviewField('Ayushman Card', surveyData['ayushman_have_card']),
            _buildPreviewField('Family ID Card', surveyData['family_id_have_card']),
            _buildPreviewField('Ration Card', surveyData['ration_card_have_card']),
            _buildPreviewField('Samagra ID Card', surveyData['samagra_id_have_card']),
            _buildPreviewField('Tribal Card', surveyData['tribal_card_have_card']),
            _buildPreviewField('Handicapped Allowance', surveyData['handicapped_allowance_have_card']),
            _buildPreviewField('Pension Allowance', surveyData['pension_allowance_have_card']),
            _buildPreviewField('Widow Allowance', surveyData['widow_allowance_have_card']),
          ]),

          _buildPreviewSection('Children Data', [
            _buildPreviewField('Births Last 3 Years', surveyData['births_last_3_years']),
            _buildPreviewField('Infant Deaths Last 3 Years', surveyData['infant_deaths_last_3_years']),
            _buildPreviewField('Malnourished Children', surveyData['malnourished_children']),
            _buildPreviewField('Child 1 Height', surveyData['child_1_height']),
            _buildPreviewField('Child 1 Weight', surveyData['child_1_weight']),
            _buildPreviewField('Child 1 Cause', surveyData['child_1_cause']),
          ]),

          _buildPreviewSection('Migration', [
            _buildPreviewField('Permanent Migration', surveyData['permanent_migration'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Seasonal Migration', surveyData['seasonal_migration'] == true ? 'Yes' : 'No'),
            _buildPreviewField('As Needed Migration', surveyData['as_needed_migration'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Migration Job Description', surveyData['migration_job_description']),
            _buildPreviewField('Migration Destination', surveyData['migration_destination']),
            _buildPreviewField('Monthly Remittance (₹)', surveyData['monthly_remittance']),
          ]),

          _buildPreviewSection('Training', [
            _buildPreviewField('Training Type', surveyData['training_type']),
            _buildPreviewField('Training Institute', surveyData['training_institute']),
            _buildPreviewField('Year of Passing', surveyData['year_of_passing']),
            _buildPreviewField('SHG Name', surveyData['shg_name']),
            _buildPreviewField('SHG Purpose', surveyData['shg_purpose']),
            _buildPreviewField('SHG Agency', surveyData['shg_agency']),
            _buildPreviewField('FPO Name', surveyData['fpo_name']),
          ]),

          _buildPreviewSection('Social Consciousness', [
            _buildPreviewField('Clothes Frequency', surveyData['clothes_frequency']),
            _buildPreviewField('Food Waste', surveyData['food_waste']),
            _buildPreviewField('Waste Disposal', surveyData['waste_disposal']),
            _buildPreviewField('Waste Segregation', surveyData['waste_segregation']),
            _buildPreviewField('Compost Pit', surveyData['compost_pit']),
            _buildPreviewField('Recycle Items', surveyData['recycle_items']),
            _buildPreviewField('Have Toilet', surveyData['have_toilet']),
            _buildPreviewField('LED Lights', surveyData['led_lights']),
            _buildPreviewField('Turn Off Devices', surveyData['turn_off_devices']),
            _buildPreviewField('Fix Leaks', surveyData['fix_leaks']),
            _buildPreviewField('Avoid Plastics', surveyData['avoid_plastics']),
            _buildPreviewField('Family Prayers', surveyData['family_prayers']),
            _buildPreviewField('Family Meditation', surveyData['family_meditation']),
            _buildPreviewField('Family Yoga', surveyData['family_yoga']),
            _buildPreviewField('Community Activities', surveyData['community_activities']),
            _buildPreviewField('Shram Sadhana', surveyData['shram_sadhana']),
            _buildPreviewField('Spiritual Discourses', surveyData['spiritual_discourses']),
            _buildPreviewField('Personal Happiness', surveyData['personal_happiness']),
            _buildPreviewField('Family Happiness', surveyData['family_happiness']),
            _buildPreviewField('Member Smokes', surveyData['member_smokes'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Member Drinks', surveyData['member_drinks'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Member Eats Gudka', surveyData['member_eats_gudka'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Member Gambles', surveyData['member_gambles'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Member Chews Tobacco', surveyData['member_chews_tobacco'] == true ? 'Yes' : 'No'),
            _buildPreviewField('Family Saves', surveyData['family_saves']),
            _buildPreviewField('Savings Percentage', surveyData['savings_percentage']),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(String title, List<Widget> fields) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18 * fontScale,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 12),
            ...fields,
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewField(String label, dynamic value) {
    final displayValue = value?.toString() ?? 'Not filled';
    final isFilled = value != null && value.toString().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14 * fontScale,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 14 * fontScale,
                color: isFilled ? Colors.black87 : Colors.red[400],
                fontWeight: isFilled ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFPOFamiliesPage(AppLocalizations l10n) {
    final fpoMembers = _pageData['fpo_members'] as List<Map<String, dynamic>>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No. of Family Members Who Are Members of a FPO',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide details about family members who are FPO members',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Display existing FPO members
        ...fpoMembers.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          return Column(
            children: [
              _buildFPOMemberCard(index + 1, memberData: member),
              const SizedBox(height: 16),
            ],
          );
        }),

        // Add more FPO members button
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              final fpoMembers = _pageData['fpo_members'] as List<Map<String, dynamic>>? ?? [];
              fpoMembers.add({
                'sr_no': fpoMembers.length + 1,
                'family_member_name': '',
                'fpo_name': '',
                'fpo_purpose': '',
                'fpo_agency': '',
              });
              _pageData['fpo_members'] = fpoMembers;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add FPO Member'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        if (fpoMembers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Click "Add FPO Member" to add family members who are FPO members.',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVBGramBeneficiariesPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VB G RAM G beneficiary',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide VB Gram beneficiary information',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildRadioField('Yes', 'vb_gram_beneficiary', 'yes'),
        _buildRadioField('No', 'vb_gram_beneficiary', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Name included?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['vb_gram_name_included'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Details Correct',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['vb_gram_details_correct'] = value,
        ),

        const SizedBox(height: 24),

        Text(
          'Family Members Details',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // VB Gram members table
        _buildVBGramMembersTable(),
      ],
    );
  }

  Widget _buildPMKisanBeneficiariesPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PM Kisan Nidhi Yojna beneficiary',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide PM Kisan beneficiary information',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildRadioField('Yes', 'pm_kisan_beneficiary', 'yes'),
        _buildRadioField('No', 'pm_kisan_beneficiary', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Name included?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['pm_kisan_name_included'] = value,
        ),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Details Correct',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['pm_kisan_details_correct'] = value,
        ),

        const SizedBox(height: 24),

        Text(
          'Family Members Details',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // PM Kisan members table
        _buildPMKisanMembersTable(),
      ],
    );
  }

  Widget _buildPMKisanSammanBeneficiariesPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PM Kisan Samman Nidhi beneficiary',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide PM Kisan Samman Nidhi beneficiary information',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildRadioField('Yes', 'pm_kisan_samman_beneficiary', 'yes'),
        _buildRadioField('No', 'pm_kisan_samman_beneficiary', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Details Correct',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['pm_kisan_samman_details_correct'] = value,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Received',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _pageData['pm_kisan_samman_received'] = value,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Yes/No',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _pageData['pm_kisan_samman_yes_no'] = value,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKisanCreditCardBeneficiariesPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kisan Credit Card beneficiary',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide Kisan Credit Card beneficiary information',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildRadioField('Yes', 'kisan_credit_card_beneficiary', 'yes'),
        _buildRadioField('No', 'kisan_credit_card_beneficiary', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Details Correct',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['kisan_credit_card_details_correct'] = value,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Received',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _pageData['kisan_credit_card_received'] = value,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Yes/No',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _pageData['kisan_credit_card_yes_no'] = value,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwachhBharatBeneficiariesPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Swachh Bharat Mission beneficiary',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide Swachh Bharat Mission beneficiary information',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildRadioField('Yes', 'swachh_bharat_beneficiary', 'yes'),
        _buildRadioField('No', 'swachh_bharat_beneficiary', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Details Correct',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['swachh_bharat_details_correct'] = value,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Received',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _pageData['swachh_bharat_received'] = value,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Yes/No',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _pageData['swachh_bharat_yes_no'] = value,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFasalBimaBeneficiariesPage(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fasal Bima beneficiary',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide Fasal Bima beneficiary information',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildRadioField('Yes', 'fasal_bima_beneficiary', 'yes'),
        _buildRadioField('No', 'fasal_bima_beneficiary', 'no'),

        const SizedBox(height: 16),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Details Correct',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['fasal_bima_details_correct'] = value,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Received',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _pageData['fasal_bima_received'] = value,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Yes/No',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _pageData['fasal_bima_yes_no'] = value,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBankAccountHoldersPage(AppLocalizations l10n) {
    final bankMembers = _pageData['bank_members'] as List<Map<String, dynamic>>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Family Members who have a Bank Account',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please provide details about family members with bank accounts',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        TextFormField(
          decoration: InputDecoration(
            labelText: 'Details Correct',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => _pageData['bank_account_details_correct'] = value,
        ),

        const SizedBox(height: 24),

        Text(
          'Family Members Details',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Bank members table
        _buildBankMembersTable(),
      ],
    );
  }

  Widget _buildFPOMemberCard(int memberNumber, {Map<String, dynamic>? memberData}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FPO Member ${memberNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: memberData?['family_member_name'],
              decoration: InputDecoration(
                labelText: 'Family Member\'s Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                if (memberData != null) {
                  memberData['family_member_name'] = value;
                }
              },
              onSaved: (value) => _pageData['fpo_member_${memberNumber}_name'] = value,
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: memberData?['fpo_name'],
              decoration: InputDecoration(
                labelText: 'Name of FPO',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                if (memberData != null) {
                  memberData['fpo_name'] = value;
                }
              },
              onSaved: (value) => _pageData['fpo_member_${memberNumber}_fpo_name'] = value,
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: memberData?['fpo_purpose'],
              decoration: InputDecoration(
                labelText: 'Purpose of FPO',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                if (memberData != null) {
                  memberData['fpo_purpose'] = value;
                }
              },
              onSaved: (value) => _pageData['fpo_member_${memberNumber}_purpose'] = value,
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: memberData?['fpo_agency'],
              decoration: InputDecoration(
                labelText: 'Under which Agency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                if (memberData != null) {
                  memberData['fpo_agency'] = value;
                }
              },
              onSaved: (value) => _pageData['fpo_member_${memberNumber}_agency'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVBGramMembersTable() {
    final vbGramMembers = _pageData['vb_gram_members'] as List<Map<String, dynamic>>? ?? [];

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(flex: 1, child: Text('Sr. No.', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Family Member\'s Name', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Yes', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('No. of days', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Yes', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Table Rows
        ...vbGramMembers.asMap().entries.map((entry) {
          final index = entry.key;
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('${index + 1}')),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: entry.value['name'],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => entry.value['name'] = value,
                    onSaved: (value) => _pageData['vb_gram_member_${index + 1}_name'] = value,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['yes_1'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['yes_1'] = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['no_1'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['no_1'] = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: entry.value['days'],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => entry.value['days'] = value,
                    onSaved: (value) => _pageData['vb_gram_member_${index + 1}_days'] = value,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['yes_2'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['yes_2'] = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['no_2'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['no_2'] = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }),

        // Add member button
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              final vbGramMembers = _pageData['vb_gram_members'] as List<Map<String, dynamic>>? ?? [];
              vbGramMembers.add({
                'name': '',
                'yes_1': false,
                'no_1': false,
                'days': '',
                'yes_2': false,
                'no_2': false,
              });
              _pageData['vb_gram_members'] = vbGramMembers;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Member'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPMKisanMembersTable() {
    final pmKisanMembers = _pageData['pm_kisan_members'] as List<Map<String, dynamic>>? ?? [];

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(flex: 1, child: Text('Sr. No.', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Family Member\'s Name', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Yes', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('No. of days', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Yes', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Table Rows
        ...pmKisanMembers.asMap().entries.map((entry) {
          final index = entry.key;
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('${index + 1}')),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: entry.value['name'],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => entry.value['name'] = value,
                    onSaved: (value) => _pageData['pm_kisan_member_${index + 1}_name'] = value,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['yes_1'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['yes_1'] = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['no_1'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['no_1'] = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: entry.value['days'],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => entry.value['days'] = value,
                    onSaved: (value) => _pageData['pm_kisan_member_${index + 1}_days'] = value,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['yes_2'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['yes_2'] = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['no_2'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['no_2'] = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }),

        // Add member button
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              final pmKisanMembers = _pageData['pm_kisan_members'] as List<Map<String, dynamic>>? ?? [];
              pmKisanMembers.add({
                'name': '',
                'yes_1': false,
                'no_1': false,
                'days': '',
                'yes_2': false,
                'no_2': false,
              });
              _pageData['pm_kisan_members'] = pmKisanMembers;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Member'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankMembersTable() {
    final bankMembers = _pageData['bank_members'] as List<Map<String, dynamic>>? ?? [];

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(flex: 1, child: Text('Sr. No.', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Yes', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Yes', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Table Rows
        ...bankMembers.asMap().entries.map((entry) {
          final index = entry.key;
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('${index + 1}')),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: entry.value['name'],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => entry.value['name'] = value,
                    onSaved: (value) => _pageData['bank_member_${index + 1}_name'] = value,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['yes_1'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['yes_1'] = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['no_1'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['no_1'] = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['yes_2'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['yes_2'] = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: entry.value['no_2'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        entry.value['no_2'] = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }),

        // Add member button
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              final bankMembers = _pageData['bank_members'] as List<Map<String, dynamic>>? ?? [];
              bankMembers.add({
                'name': '',
                'yes_1': false,
                'no_1': false,
                'yes_2': false,
                'no_2': false,
              });
              _pageData['bank_members'] = bankMembers;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Member'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankMemberCard(int memberNumber, {Map<String, dynamic>? memberData}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Account Holder ${memberNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: memberData?['name'],
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (memberData != null) {
                        memberData['name'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['bank_member_${memberNumber}_name'] = value,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: memberData?['has_bank_account'],
                    decoration: InputDecoration(
                      labelText: 'Yes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (memberData != null) {
                        memberData['has_bank_account'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['bank_member_${memberNumber}_has_account'] = value,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: memberData?['no_bank_account'],
                    decoration: InputDecoration(
                      labelText: 'No',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (memberData != null) {
                        memberData['no_bank_account'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['bank_member_${memberNumber}_no_account'] = value,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: memberData?['details_correct'],
                    decoration: InputDecoration(
                      labelText: 'Details Correct',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (memberData != null) {
                        memberData['details_correct'] = value;
                      }
                    },
                    onSaved: (value) => _pageData['bank_member_${memberNumber}_details_correct'] = value,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPage(String title, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.construction,
          size: 60,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'This section is under development',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleNext(WidgetRef ref) async {
    // Validation disabled: always proceed
    if (true) {
      _formKey.currentState?.save();

      try {
        // For the first page (location), initialize the survey
        if (widget.pageIndex == 0) {
          await ref.read(surveyProvider.notifier).initializeSurvey(
            villageName: _pageData['village_name'] ?? '',
            phoneNumber: _pageData['phone_number'],
            panchayat: _pageData['panchayat'],
            block: _pageData['block'],
            district: _pageData['district'],
            postalAddress: _pageData['postal_address'],
            pinCode: _pageData['pin_code'],
          );
        }

        // Save page data to database
        final db = DatabaseHelper();
        await db.saveSurveyData(_pageData);

        // Update provider
        ref.read(surveyProvider.notifier).updateSurveyDataMap(_pageData);

        // Navigate to next page with page data for validation
        widget.onNext(_pageData);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving data: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
