import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

import '../services/database_service.dart';
import '../services/excel_service.dart';

class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  static DatabaseService get _db => DatabaseService();

  factory DataExportService() => _instance;

  DataExportService._internal();

  // Export all surveys to Excel - Now exports complete data for each survey
  Future<void> exportAllSurveysToExcel() async {
    try {
      // Get all survey sessions
      final sessions = await _db.getAllSurveySessions();

      if (sessions.isEmpty) {
        throw Exception('No survey data found to export');
      }

      // Create a master Excel file with multiple sheets
      final excel = Excel.createExcel();

      // Sheet 1: Survey Overview
      final overviewSheet = excel['Survey Overview'];
      overviewSheet.appendRow([
        TextCellValue('Phone Number'),
        TextCellValue('Village Name'),
        TextCellValue('Panchayat'),
        TextCellValue('Block'),
        TextCellValue('District'),
        TextCellValue('Surveyor Name'),
        TextCellValue('Survey Date'),
        TextCellValue('Status'),
        TextCellValue('Family Members'),
        TextCellValue('Total Income'),
        TextCellValue('Export Status'),
      ]);

      int successCount = 0;
      int skipCount = 0;
      int errorCount = 0;

      // Add overview data and create individual sheets
      for (final session in sessions) {
        final phoneNumber = session['phone_number'];
        
        // Better null handling - still export if phone is null (use ID as fallback)
        final identifier = phoneNumber ?? session['id'] ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';
        String exportStatus = 'Success';
        
        try {
          // Add to overview
          final members = await _db.getData('family_members', identifier);
          final totalIncome = members.fold<double>(0.0, (sum, member) =>
            sum + (double.tryParse(member['income']?.toString() ?? '0') ?? 0.0));

          overviewSheet.appendRow([
            TextCellValue(phoneNumber?.toString() ?? 'N/A'),
            TextCellValue(session['village_name'] ?? 'N/A'),
            TextCellValue(session['panchayat'] ?? ''),
            TextCellValue(session['block'] ?? ''),
            TextCellValue(session['district'] ?? ''),
            TextCellValue(session['surveyor_name'] ?? ''),
            TextCellValue(session['survey_date'] ?? ''),
            TextCellValue(session['status'] ?? ''),
            IntCellValue(members.length),
            DoubleCellValue(totalIncome),
            TextCellValue(exportStatus),
          ]);

          // Create individual comprehensive sheet for each survey
          if (phoneNumber != null) {
            try {
              await _createIndividualSurveySheet(excel, phoneNumber);
              successCount++;
            } catch (e) {
              exportStatus = 'Sheet Error: $e';
              errorCount++;
              print('⚠ Warning: Could not create detailed sheet for $phoneNumber: $e');
            }
          } else {
            exportStatus = 'Skipped - No phone number';
            skipCount++;
            print('⚠ Warning: Survey has no phone number, skipping detailed export');
          }

        } catch (e) {
          exportStatus = 'Error: $e';
          errorCount++;
          print('✗ Error processing survey $identifier: $e');
          
          // Still add to overview with error status
          overviewSheet.appendRow([
            TextCellValue(phoneNumber?.toString() ?? 'N/A'),
            TextCellValue('ERROR'),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue('error'),
            IntCellValue(0),
            DoubleCellValue(0),
            TextCellValue(exportStatus),
          ]);
        }
      }

      print('\n📊 Export Summary:');
      print('  ✓ Successfully exported: $successCount surveys');
      print('  ⚠ Skipped (no phone): $skipCount surveys');
      print('  ✗ Errors: $errorCount surveys');
      print('  📄 Total in overview: ${sessions.length} surveys\n');

      // Save and share file
      await _saveExcelFile(excel, 'all_complete_surveys_${DateTime.now().millisecondsSinceEpoch}.xlsx');

    } catch (e) {
      throw Exception('Failed to export surveys: $e');
    }
  }

  // Create individual comprehensive sheet for a survey
  Future<void> _createIndividualSurveySheet(Excel excel, String phoneNumber) async {
    try {
      final excelService = ExcelService();
      final surveyData = await excelService.fetchCompleteSurveyData(phoneNumber);

      if (surveyData.isEmpty) {
        print('⚠ WARNING: No data found for survey $phoneNumber. Skipping sheet creation.');
        return;
      }

      final sheetName = 'Survey_${phoneNumber.replaceAll('+', '').replaceAll('-', '')}';
      final sheet = excel[sheetName];

      // Create comprehensive report for this survey
      await excelService.createComprehensiveReport(sheet, surveyData);

    } catch (e) {
      print('✗ Error creating individual survey sheet for $phoneNumber: $e');
    }
  }

  // Export complete survey data with all details to Excel
  Future<void> exportCompleteSurveyData(String phoneNumber) async {
    try {
      // Use the comprehensive ExcelService method instead of duplicating logic
      final excelService = ExcelService();
      await excelService.exportCompleteSurveyToExcel(phoneNumber);
    } catch (e) {
      throw Exception('Failed to export complete survey: $e');
    }
  }

  // Generate survey summary report
  Future<void> generateSurveySummaryReport() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Summary Report'];

      // Get all survey sessions
      final sessions = await _db.getAllSurveySessions();

      // Add header
      sheet.appendRow([
        TextCellValue('Village Name'),
        TextCellValue('Total Families'),
        TextCellValue('Total Population'),
        TextCellValue('Avg Family Size'),
        TextCellValue('Survey Date'),
        TextCellValue('Status')
      ]);

      // Group by village and calculate summary
      final villageSummary = <String, Map<String, dynamic>>{};

      for (final session in sessions) {
        final villageName = session['village_name'] ?? 'Unknown';
        if (!villageSummary.containsKey(villageName)) {
          villageSummary[villageName] = {
            'families': 0,
            'population': 0,
            'surveys': 0,
            'latest_date': session['survey_date'] ?? '',
            'status': session['status'] ?? ''
          };
        }

        villageSummary[villageName]!['families'] += 1;
        villageSummary[villageName]!['surveys'] += 1;

        // Get family members count for this survey
        final members = await _db.getData('family_members', session['phone_number']);
        villageSummary[villageName]!['population'] += members.length;
      }

      // Add summary data
      villageSummary.forEach((village, data) {
        final avgSize = data['families'] > 0 ? (data['population'] / data['families']).toStringAsFixed(1) : '0';
        sheet.appendRow([
          TextCellValue(village),
          TextCellValue(data['families'].toString()),
          TextCellValue(data['population'].toString()),
          TextCellValue(avgSize),
          TextCellValue(data['latest_date']),
          TextCellValue(data['status'])
        ]);
      });

      // Save and share file
      await _saveExcelFile(excel, 'survey_summary_report.xlsx');

    } catch (e) {
      throw Exception('Failed to generate summary report: $e');
    }
  }

  // Export all surveys to CSV (legacy support)
  Future<void> exportAllSurveysToCSV() async {
    try {
      final sessions = await _db.getAllSurveySessions();

      if (sessions.isEmpty) {
        throw Exception('No survey data found to export');
      }

      // Create CSV data
      List<List<String>> csvData = [];
      csvData.add([
        'Phone Number',
        'Village Name',
        'Village Number',
        'Panchayat',
        'Block',
        'Tehsil',
        'District',
        'Postal Address',
        'Pin Code',
        'Surveyor Name',
        'Surveyor Email',
        'SHINE Code',
        'Latitude',
        'Longitude',
        'Location Accuracy',
        'Survey Date',
        'Status',
        'Created At',
        'Updated At'
      ]);

      for (final session in sessions) {
        csvData.add([
          session['phone_number'] ?? '',
          session['village_name'] ?? '',
          session['village_number'] ?? '',
          session['panchayat'] ?? '',
          session['block'] ?? '',
          session['tehsil'] ?? '',
          session['district'] ?? '',
          session['postal_address'] ?? '',
          session['pin_code'] ?? '',
          session['surveyor_name'] ?? '',
          session['surveyor_email'] ?? '',
          session['shine_code'] ?? '',
          session['latitude']?.toString() ?? '',
          session['longitude']?.toString() ?? '',
          session['location_accuracy']?.toString() ?? '',
          session['survey_date'] ?? '',
          session['status'] ?? '',
          session['created_at'] ?? '',
          session['updated_at'] ?? ''
        ]);
      }

      final csv = const ListToCsvConverter().convert(csvData);
      await _saveCSVFile(csv, 'all_surveys.csv');

    } catch (e) {
      throw Exception('Failed to export surveys to CSV: $e');
    }
  }

  // Helper method to save Excel file
  Future<void> _saveExcelFile(Excel excel, String fileName) async {
    final bytes = excel.encode();

    if (kIsWeb) {
      // For web, download directly
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..download = fileName;
      anchor.click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile, save to documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes!);

      // Note: File sharing would require additional permissions and packages
      print('Excel file saved to: ${file.path}');
    }
  }

  // Helper method to save CSV file
  Future<void> _saveCSVFile(String csvContent, String fileName) async {
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
      // For mobile, save to documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvContent);

      print('CSV file saved to: ${file.path}');
    }
  }

  // Export data in JSON format for backup
  Future<void> exportDataAsJSON() async {
    try {
      final sessions = await _db.getAllSurveySessions();
      final backupData = {
        'export_date': DateTime.now().toIso8601String(),
        'total_surveys': sessions.length,
        'surveys': sessions
      };

      final jsonData = jsonEncode(backupData);

      if (kIsWeb) {
        // For web, download directly
        final blob = html.Blob([jsonData], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..download = 'survey_backup_${DateTime.now().millisecondsSinceEpoch}.json';
        anchor.click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile, save to documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/survey_backup_${DateTime.now().millisecondsSinceEpoch}.json');
        await file.writeAsString(jsonData);

        print('JSON backup saved to: ${file.path}');
      }

    } catch (e) {
      throw Exception('Failed to export JSON data: $e');
    }
  }
}
