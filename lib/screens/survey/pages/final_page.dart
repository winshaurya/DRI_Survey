import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/survey_provider.dart';
import '../../../services/xlsx_export_service.dart';

class FinalPage extends StatefulWidget {
  final Map<String, dynamic> surveyData;
  final Function() onSubmit;

  const FinalPage({
    super.key,
    required this.surveyData,
    required this.onSubmit,
  });

  @override
  State<FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSubmitting = true);

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate submission
      widget.onSubmit();
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorSubmittingSurvey(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadXlsx() async {
    try {
      // Check storage permission
      final status = await Permission.storage.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        final result = await Permission.storage.request();
        if (result.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to download XLSX files. Please enable it in app settings.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      // Get session ID from provider
      final container = ProviderScope.containerOf(context);
      final surveyState = container.read(surveyProvider);
      final sessionId = surveyState.sessionId;

      if (sessionId == null || sessionId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No survey session found to export.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final fileName = 'family_survey_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      await XlsxExportService().exportSurveyToXlsx(sessionId, fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('XLSX file downloaded successfully: $fileName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading XLSX: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Success Icon
          FadeInDown(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green[300]!, width: 4),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 80,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Completion Title
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              l10n.surveyCompleted,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Completion Message
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Text(
              l10n.thankYouParticipating,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),

          // Survey Summary
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.summarize,
                    color: Colors.blue[700],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.surveySummary,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryItem(
                    l10n.familyInformation,
                    Icons.family_restroom,
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    l10n.economicDetails,
                    Icons.account_balance_wallet,
                    Colors.orange,
                  ),
                  _buildSummaryItem(
                    l10n.agriculturalData,
                    Icons.agriculture,
                    Colors.brown,
                  ),
                  _buildSummaryItem(
                    l10n.healthEducation,
                    Icons.health_and_safety,
                    Colors.red,
                  ),
                  _buildSummaryItem(
                    l10n.governmentSchemes,
                    Icons.account_balance,
                    Colors.purple,
                  ),
                  _buildSummaryItem(
                    l10n.migrationTraining,
                    Icons.travel_explore,
                    Colors.teal,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Important Notes
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Text(
                        l10n.importantNotes,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNoteItem(l10n.dataStoredSecurely),
                  _buildNoteItem(l10n.personalInfoConfidential),
                  _buildNoteItem(l10n.surveyResponsesHelp),
                  _buildNoteItem(l10n.contactLocalAuthorities),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Download XLSX Button
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton.icon(
                onPressed: _downloadXlsx,
                icon: const Icon(Icons.download, size: 24),
                label: Text(
                  'Download Survey XLSX',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue[600]!, width: 2),
                  foregroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Submit Button
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.green[200],
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.submittingSurvey,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            l10n.submitSurvey,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Footer Text
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: Text(
              l10n.thankYouContribution,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.green[500],
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              color: Colors.amber[700],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.amber[800],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
