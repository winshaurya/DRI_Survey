import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class FertilizerPage extends StatelessWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const FertilizerPage({
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
          l10n.fertilizerUsage,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.selectFertilizerType,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        _buildCheckboxField(l10n.chemical, 'chemical_fertilizer'),
        _buildCheckboxField(l10n.organic, 'organic_fertilizer'),
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
