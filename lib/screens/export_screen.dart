import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import '../services/data_export_service.dart';
import '../l10n/app_localizations.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _isExporting = false;

  Future<void> _exportData(String exportType) async {
    if (_isExporting) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() => _isExporting = true);

    try {
      final exportService = DataExportService();

      switch (exportType) {
        case 'all_surveys':
          await exportService.exportAllSurveysToExcel();
          break;
        case 'summary_report':
          await exportService.generateSurveySummaryReport();
          break;
        case 'json_backup':
          await exportService.exportDataAsJSON();
          break;
      }

      _showSuccessSnackBar('Data exported successfully!');
    } catch (e) {
      _showErrorSnackBar(l10n.exportFailed(e.toString()));
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exportData),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF1F8E9),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 625), // 500 * 1.25
                child: Text(
                  l10n.exportDataDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF424242),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Export Options
              FadeInUp(
                duration: const Duration(milliseconds: 875), // 700 * 1.25
                child: _buildExportOption(
                  icon: Icons.table_chart,
                  title: l10n.exportAllSurveys,
                  description: l10n.exportAllSurveysDesc,
                  onTap: () => _exportData('all_surveys'),
                ),
              ),

              const SizedBox(height: 16),

              FadeInUp(
                duration: const Duration(milliseconds: 875), // 700 * 1.25
                child: _buildExportOption(
                  icon: Icons.analytics,
                  title: l10n.exportSummaryReport,
                  description: l10n.exportSummaryDesc,
                  onTap: () => _exportData('summary_report'),
                ),
              ),

              const SizedBox(height: 16),

              FadeInUp(
                duration: const Duration(milliseconds: 1000), // 800 * 1.25
                child: _buildExportOption(
                  icon: Icons.backup,
                  title: l10n.exportJSONBackup,
                  description: l10n.exportBackupDesc,
                  onTap: () => _exportData('json_backup'),
                ),
              ),

              const SizedBox(height: 32),

              // Info Section
              FadeInUp(
                duration: const Duration(milliseconds: 1125), // 900 * 1.25
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.exportInfo,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.exportInfoDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _isExporting ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2E7D32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isExporting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
