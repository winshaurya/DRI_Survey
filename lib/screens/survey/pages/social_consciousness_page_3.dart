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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Consciousness Survey - 3c',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please answer questions about personal and family well-being',
          style: TextStyle(color: Colors.grey[600]),
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
          initialValue: pageData['happy_members'],
          decoration: InputDecoration(
            labelText: 'If yes, who?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            pageData['happy_members'] = value;
            onDataChanged(pageData);
          },
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
          initialValue: pageData['savings_percentage'],
          decoration: InputDecoration(
            labelText: 'If yes, what percentage of income?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            pageData['savings_percentage'] = value;
            onDataChanged(pageData);
          },
        ),
      ],
    );
  }

  Widget _buildCheckboxField(String label, String key) {
    return CheckboxListTile(
      title: Text(label),
      value: pageData[key] ?? false,
      onChanged: (value) {
        pageData[key] = value ?? false;
        onDataChanged(pageData);
      },
      controlAffinity: ListTileControlAffinity.leading,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
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
