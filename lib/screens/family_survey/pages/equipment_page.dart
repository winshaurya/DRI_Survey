import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class EquipmentPage extends StatelessWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const EquipmentPage({
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
          l10n.agriculturalEquipment,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.selectAgriculturalEquipment,
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
          initialValue: pageData['other_equipment'],
          decoration: InputDecoration(
            labelText: l10n.otherEquipmentSpecify,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            pageData['other_equipment'] = value;
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
}
