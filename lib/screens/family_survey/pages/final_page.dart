// Rewriting the page based on the provided Excel file and the user's request to recreate the last 10 pages of the family survey.
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class FinalPage extends StatelessWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const FinalPage({
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
          'Survey Summary',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please review your survey responses before submitting',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Survey completed successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All responses have been recorded. Click submit to complete the survey.',
                style: TextStyle(color: Colors.green[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
