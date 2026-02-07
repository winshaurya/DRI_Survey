import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

import '../services/database_service.dart';
import '../services/excel_service.dart';

/// Service for exporting survey data to Excel format
/// Saves directly to device storage
class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  static DatabaseService get _db => DatabaseService();

  factory DataExportService() => _instance;

  DataExportService._internal();

  /// Export all surveys to Excel file and save to storage
  Future<void> exportAllSurveysToExcel() async {
    try {
      await ExcelService().exportAllSurveysToExcel();
    } catch (e) {
      throw Exception('Failed to export surveys: $e');
    }
  }

  /// Export a single survey by phone number to Excel file and save to storage
  Future<void> exportCompleteSurveyData(String phoneNumber) async {
    try {
      await ExcelService().exportCompleteSurveyToExcel(phoneNumber);
    } catch (e) {
      throw Exception('Failed to export survey: $e');
    }
  }

  /// Export a single village survey by session ID to Excel file and save to storage
  Future<void> exportCompleteVillageSurveyData(String sessionId) async {
    try {
      await ExcelService().exportCompleteVillageSurveyToExcel(sessionId);
    } catch (e) {
      throw Exception('Failed to export village survey: $e');
    }
  }

  /// Generate summary report
  Future<void> generateSurveySummaryReport() async {
    try {
      final sessions = await _db.getAllSurveySessions();
      if (sessions.isEmpty) {
        throw Exception('No surveys found');
      }

      final excel = Excel.createExcel();
      final sheet = excel['Summary Report'];

      sheet.appendRow([TextCellValue('Survey Summary Report')]);
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('Total Surveys'),
        TextCellValue(sessions.length.toString()),
      ]);

      await _saveExcelFile(excel, 'survey_summary_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    } catch (e) {
      throw Exception('Failed to generate summary: $e');
    }
  }

  /// Export data as JSON backup (dummy implementation)
  Future<void> exportDataAsJSON() async {
    try {
      final sessions = await _db.getAllSurveySessions();
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'survey_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      // Simple JSON export
      await file.writeAsString('{"surveys": ${sessions.length}}');
      print('✓ JSON backup saved to: ${file.path}');
    } catch (e) {
      throw Exception('Failed to export JSON: $e');
    }
  }

  Future<void> _saveExcelFile(Excel excel, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      final bytes = excel.encode();
      
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        print('✓ Excel file saved to: ${file.path}');
      } else {
        throw Exception('Failed to encode Excel file');
      }
    } catch (e) {
      throw Exception('Failed to save Excel file: $e');
    }
  }
}
