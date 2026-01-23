import 'dart:convert';
import 'package:csv/csv.dart';
// Temporarily disabled for minimal APK build
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

// Temporarily disabled for minimal APK build
// import '../database/database_helper.dart';

class DataExportService {
  DataExportService._internal();

  // Export all surveys to CSV
  static Future<void> exportAllSurveysToCSV() async {
    try {
      // Mock implementation - database disabled for minimal APK
      print('Database functionality disabled in minimal APK build');
      print('Export feature temporarily unavailable');

      // Create sample CSV data for demonstration
      List<List<String>> csvData = [];

      // Add header row
      csvData.add([
        'Survey ID',
        'Village Name',
        'Panchayat',
        'Block',
        'Tehsil',
        'District',
        'Postal Address',
        'Pin Code',
        'Survey Date',
        'Created At',
        'Synced'
      ]);

      // Add sample survey data
      csvData.add([
        '1',
        'Sample Village',
        'Sample Panchayat',
        'Sample Block',
        'Sample Tehsil',
        'Sample District',
        'Sample Address',
        '110001',
        DateTime.now().toString(),
        DateTime.now().toString(),
        'No'
      ]);

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // Save and share file
      await _saveAndShareFile(csv, 'sample_surveys.csv');

    } catch (e) {
      throw Exception('Failed to export surveys: $e');
    }
  }

  // Export complete survey data with all details
  static Future<void> exportCompleteSurveyData(int surveyId) async {
    print('Database functionality disabled in minimal APK build');
    print('Complete survey export temporarily unavailable');
    // Mock implementation - just export sample data
    await exportAllSurveysToCSV();
  }

  // Generate survey summary report
  static Future<void> generateSurveySummaryReport() async {
    print('Database functionality disabled in minimal APK build');
    print('Summary report generation temporarily unavailable');

    // Create sample summary CSV
    List<List<String>> csvData = [];
    csvData.add([
      'Village',
      'Total Families',
      'Total Population',
      'Avg Family Size',
      'Total Land (Acres)',
      'Irrigated Land (Acres)',
      'Total Livestock',
      'Government Beneficiaries'
    ]);

    csvData.add([
      'Sample Village',
      '10',
      '45',
      '4.5',
      '150.00',
      '75.00',
      '25',
      '8'
    ]);

    String csv = const ListToCsvConverter().convert(csvData);
    await _saveAndShareFile(csv, 'sample_summary_report.csv');
  }

  // Helper method to save file and share
  static Future<void> _saveAndShareFile(String csvContent, String fileName) async {
    if (kIsWeb) {
      // For web, download directly
      final blob = html.Blob([csvContent], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..download = fileName;
      anchor.click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile, just print the content (file system disabled for minimal APK)
      print('File export disabled in minimal APK build');
      print('CSV Content for $fileName:');
      print(csvContent);
      print('Copy the above content to save as $fileName');
    }
  }

  // Export data in JSON format for backup
  Future<void> exportDataAsJSON() async {
    try {
      print('Database functionality disabled in minimal APK build');
      print('JSON export temporarily unavailable');

      // Create sample JSON data
      Map<String, dynamic> sampleData = {
        'surveys': [
          {
            'id': 1,
            'village_name': 'Sample Village',
            'survey_date': DateTime.now().toIso8601String(),
            'status': 'completed'
          }
        ]
      };

      String jsonData = jsonEncode(sampleData);

      if (kIsWeb) {
        // For web, download directly
        final blob = html.Blob([jsonData], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..download = 'sample_backup.json';
        anchor.click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile, just print the content
        print('Sample JSON backup content:');
        print(jsonData);
        print('Copy the above content to save as sample_backup.json');
      }

    } catch (e) {
      throw Exception('Failed to export JSON data: $e');
    }
  }
}
