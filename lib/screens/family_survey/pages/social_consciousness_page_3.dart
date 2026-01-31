import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class SocialConsciousnessPage3 extends StatelessWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const SocialConsciousnessPage3({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Social Consciousness Survey - Part 3',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Lifestyle, Happiness & Savings',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Question 18: Spiritual Discourses
        const Text(
          '18. Do Members of the Family listen to spiritual/motivational discourses (kathas)?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildRadioField('Yes', 'spiritual_discourses', 'yes'),
        _buildRadioField('No', 'spiritual_discourses', 'no'),
        if (pageData['spiritual_discourses'] == 'yes')
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: TextFormField(
              initialValue: pageData['discourses_members'],
              decoration: InputDecoration(
                labelText: 'If yes who?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                pageData['discourses_members'] = value;
                onDataChanged(pageData);
              },
            ),
          ),

        const SizedBox(height: 24),

        // Question 19: Personal Happiness
        const Text(
          '19. Are you happy?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildRadioField('Yes', 'personal_happiness', 'yes'),
        _buildRadioField('No', 'personal_happiness', 'no'),

        const SizedBox(height: 24),

        // Question 20: Family Happiness
        const Text(
          '20. Are members of your family happy?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildRadioField('Yes', 'family_happiness', 'yes'),
        _buildRadioField('No', 'family_happiness', 'no'),
        
        if (pageData['family_happiness'] == 'yes')
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: TextFormField(
              initialValue: pageData['happiness_family_who'],
              decoration: InputDecoration(
                labelText: 'If yes, who?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                pageData['happiness_family_who'] = value;
                onDataChanged(pageData);
              },
            ),
          ),

        if (pageData['family_happiness'] == 'no') ...[
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 12.0),
            child: Text('Reason for Unhappiness:', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          _buildCheckboxField('Financial Problems', 'financial_problems'),
          _buildCheckboxField('Family Disputes', 'family_disputes'),
          _buildCheckboxField('Illness/Health Issues', 'illness_issues'),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: TextFormField(
              initialValue: pageData['unhappiness_reason'],
              decoration: InputDecoration(
                labelText: 'Other Reason (Specify)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                pageData['unhappiness_reason'] = value;
                onDataChanged(pageData);
              },
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Question 21: Addictions
        const Text(
          '21. Does any member of the Family:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildCheckboxField('Smoke', 'addiction_smoke'),
        _buildCheckboxField('Drink', 'addiction_drink'),
        _buildCheckboxField('Eat Gudka', 'addiction_gutka'),
        _buildCheckboxField('Gamble', 'addiction_gamble'),
        _buildCheckboxField('Chew Tambacoo', 'addiction_tobacco'),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: TextFormField(
            initialValue: pageData['addiction_details'],
            decoration: InputDecoration(
              labelText: 'Other / Details',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) {
              pageData['addiction_details'] = value;
              onDataChanged(pageData);
            },
          ),
        ),

        const SizedBox(height: 24),

        // Question 22: Savings
        const Text(
          '22. Do you save your income?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildRadioField('Yes', 'savings_exists', 'yes'),
        _buildRadioField('No', 'savings_exists', 'no'),
        if (pageData['savings_exists'] == 'yes')
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: TextFormField(
              initialValue: pageData['savings_percentage'],
              decoration: InputDecoration(
                labelText: 'What percentage of income',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                pageData['savings_percentage'] = value;
                onDataChanged(pageData);
              },
            ),
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
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildCheckboxField(String label, String key) {
    return CheckboxListTile(
      title: Text(label),
      value: pageData[key] == 'yes',
      onChanged: (bool? value) {
        pageData[key] = value == true ? 'yes' : 'no';
        onDataChanged(pageData);
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.only(left: 16.0),
      visualDensity: VisualDensity.compact,
    );
  }
}
