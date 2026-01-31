import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

import '../services/database_service.dart';

class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  static DatabaseService get _db => DatabaseService();

  factory DataExportService() => _instance;

  DataExportService._internal();

  // Export all surveys to Excel
  Future<void> exportAllSurveysToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Surveys'];

      // Get all survey sessions
      final sessions = await _db.getAllSurveySessions();

      if (sessions.isEmpty) {
        throw Exception('No survey data found to export');
      }

      // Add header row
      sheet.appendRow([
        TextCellValue('Phone Number'),
        TextCellValue('Village Name'),
        TextCellValue('Village Number'),
        TextCellValue('Panchayat'),
        TextCellValue('Block'),
        TextCellValue('Tehsil'),
        TextCellValue('District'),
        TextCellValue('Postal Address'),
        TextCellValue('Pin Code'),
        TextCellValue('Surveyor Name'),
        TextCellValue('Surveyor Email'),
        TextCellValue('SHINE Code'),
        TextCellValue('Latitude'),
        TextCellValue('Longitude'),
        TextCellValue('Location Accuracy'),
        TextCellValue('Survey Date'),
        TextCellValue('Status'),
        TextCellValue('Created At'),
        TextCellValue('Updated At')
      ]);

      // Add survey data
      for (final session in sessions) {
        sheet.appendRow([
          TextCellValue(session['phone_number'] ?? ''),
          TextCellValue(session['village_name'] ?? ''),
          TextCellValue(session['village_number'] ?? ''),
          TextCellValue(session['panchayat'] ?? ''),
          TextCellValue(session['block'] ?? ''),
          TextCellValue(session['tehsil'] ?? ''),
          TextCellValue(session['district'] ?? ''),
          TextCellValue(session['postal_address'] ?? ''),
          TextCellValue(session['pin_code'] ?? ''),
          TextCellValue(session['surveyor_name'] ?? ''),
          TextCellValue(session['surveyor_email'] ?? ''),
          TextCellValue(session['shine_code'] ?? ''),
          TextCellValue(session['latitude']?.toString() ?? ''),
          TextCellValue(session['longitude']?.toString() ?? ''),
          TextCellValue(session['location_accuracy']?.toString() ?? ''),
          TextCellValue(session['survey_date'] ?? ''),
          TextCellValue(session['status'] ?? ''),
          TextCellValue(session['created_at'] ?? ''),
          TextCellValue(session['updated_at'] ?? '')
        ]);
      }

      // Save and share file
      await _saveExcelFile(excel, 'all_surveys.xlsx');

    } catch (e) {
      throw Exception('Failed to export surveys: $e');
    }
  }

  // Export complete survey data with all details to Excel
  Future<void> exportCompleteSurveyData(String phoneNumber) async {
    try {
      final excel = Excel.createExcel();

      // Get survey session
      final session = await _db.getSurveySession(phoneNumber);
      if (session == null) {
        throw Exception('Survey session not found');
      }

      // Sheet 1: Survey Session
      final sessionSheet = excel['Survey Session'];
      sessionSheet.appendRow([TextCellValue('Field'), TextCellValue('Value')]);
      session.forEach((key, value) {
        sessionSheet.appendRow([TextCellValue(key), TextCellValue(value?.toString() ?? '')]);
      });

      // Sheet 2: Family Members
      final membersSheet = excel['Family Members'];
      final members = await _db.getData('family_members', phoneNumber);
      if (members.isNotEmpty) {
        membersSheet.appendRow(members.first.keys.map((k) => TextCellValue(k)).toList());
        for (final member in members) {
          membersSheet.appendRow(member.values.map((v) => TextCellValue(v?.toString() ?? '')).toList());
        }
      }

      // Sheet 3: Agriculture Data
      final agricultureSheet = excel['Agriculture'];
      final agricultureData = await _db.getData('agriculture_data', phoneNumber);
      if (agricultureData.isNotEmpty) {
        agricultureSheet.appendRow(agricultureData.first.keys.map((k) => TextCellValue(k)).toList());
        for (final data in agricultureData) {
          agricultureSheet.appendRow(data.values.map((v) => TextCellValue(v?.toString() ?? '')).toList());
        }
      }

      // Sheet 4: Crop Productivity
      final cropsSheet = excel['Crop Productivity'];
      final crops = await _db.getData('crop_productivity', phoneNumber);
      if (crops.isNotEmpty) {
        cropsSheet.appendRow(crops.first.keys.map((k) => TextCellValue(k)).toList());
        for (final crop in crops) {
          cropsSheet.appendRow(crop.values.map((v) => TextCellValue(v?.toString() ?? '')).toList());
        }
      }

      // Sheet 5: Animals
      final animalsSheet = excel['Animals'];
      final animals = await _db.getData('animals', phoneNumber);
      if (animals.isNotEmpty) {
        animalsSheet.appendRow(animals.first.keys.map((k) => TextCellValue(k)).toList());
        for (final animal in animals) {
          animalsSheet.appendRow(animal.values.map((v) => TextCellValue(v?.toString() ?? '')).toList());
        }
      }

      // Sheet 6: Government Schemes
      final schemesSheet = excel['Government Schemes'];
      final schemes = await _db.getData('merged_govt_schemes', phoneNumber);
      if (schemes.isNotEmpty) {
        schemesSheet.appendRow(schemes.first.keys.map((k) => TextCellValue(k)).toList());
        for (final scheme in schemes) {
          schemesSheet.appendRow(scheme.values.map((v) => TextCellValue(v?.toString() ?? '')).toList());
        }
      }

      // Save and share file
      await _saveExcelFile(excel, 'complete_survey_${phoneNumber}.xlsx');

    } catch (e) {
      throw Exception('Failed to export complete survey data: $e');
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
