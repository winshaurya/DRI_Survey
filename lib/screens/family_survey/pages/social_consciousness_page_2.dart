import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class SocialConsciousnessPage2 extends StatelessWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const SocialConsciousnessPage2({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Consciousness Survey - 3b',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please answer questions about environmental consciousness and family activities',
          style: TextStyle(color: Colors.grey[600]),
        ),
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
          initialValue: pageData['toilet_in_use'],
          decoration: InputDecoration(
            labelText: 'If yes, is it in use?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            pageData['toilet_in_use'] = value;
            onDataChanged(pageData);
          },
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
          initialValue: pageData['meditation_members'],
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            pageData['meditation_members'] = value;
            onDataChanged(pageData);
          },
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
          initialValue: pageData['yoga_members'],
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            pageData['yoga_members'] = value;
            onDataChanged(pageData);
          },
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
          initialValue: pageData['community_activities_type'],
          decoration: InputDecoration(
            labelText: 'If yes, which activities?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            pageData['community_activities_type'] = value;
            onDataChanged(pageData);
          },
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
          initialValue: pageData['shram_sadhana_members'],
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            pageData['shram_sadhana_members'] = value;
            onDataChanged(pageData);
          },
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
          initialValue: pageData['discourses_members'],
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            pageData['discourses_members'] = value;
            onDataChanged(pageData);
          },
        ),
      ],
    );
  }

  Widget _buildRadioField(String label, String groupKey, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: pageData[groupKey],
      onChanged: (newValue) {
        pageData[groupKey] = newValue;
        onDataChanged(pageData);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
