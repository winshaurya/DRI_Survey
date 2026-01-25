import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class SocialConsciousnessPage1 extends StatelessWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const SocialConsciousnessPage1({
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
          'Social Consciousness Survey - 3a',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please answer questions about your basic habits and waste management',
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
          initialValue: pageData['clothes_frequency_other'],
          decoration: InputDecoration(
            labelText: 'If other, please specify',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            pageData['clothes_frequency_other'] = value;
            onDataChanged(pageData);
          },
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
          initialValue: pageData['food_waste_amount'],
          decoration: InputDecoration(
            labelText: 'If yes, how much?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            pageData['food_waste_amount'] = value;
            onDataChanged(pageData);
          },
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
          initialValue: pageData['waste_disposal_other'],
          decoration: InputDecoration(
            labelText: 'If other, please specify',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            pageData['waste_disposal_other'] = value;
            onDataChanged(pageData);
          },
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
