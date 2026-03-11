import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

import '../database/database_helper.dart';
import '../services/database_service.dart';
import '../services/excel_service.dart';
import '../services/xlsx_export_service.dart';

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
      // Use XLSX exporter (single consolidated sheet, keys-first template)
      final fileName = 'family_survey_${phoneNumber}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      await XlsxExportService().exportSurveyToXlsx(phoneNumber, fileName);
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

  /// Build a ZIP containing:
  ///   • all_data.json  — every table as structured JSON
  ///   • <table>.csv    — one CSV file per table
  Future<Uint8List> buildJsonBytes() async {
    final db = await DatabaseHelper().database;

    // Discover all user tables.
    final tableResult = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' "
      "AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%' "
      "ORDER BY name",
    );

    final Map<String, dynamic> jsonExport = {
      'exported_at': DateTime.now().toIso8601String(),
      'tables': <String, dynamic>{},
    };

    final archive = Archive();

    for (final row in tableResult) {
      final tableName = row['name'] as String;
      try {
        final rows = await db.query(tableName);
        (jsonExport['tables'] as Map<String, dynamic>)[tableName] = rows;

        // Build CSV for this table.
        if (rows.isNotEmpty) {
          final buf = StringBuffer();
          final headers = rows.first.keys.toList();
          buf.writeln(_csvRow(headers));
          for (final r in rows) {
            buf.writeln(_csvRow(headers.map((h) => r[h]).toList()));
          }
          final csvBytes = utf8.encode(buf.toString());
          archive.addFile(
            ArchiveFile('csv/$tableName.csv', csvBytes.length, csvBytes),
          );
        }
      } catch (_) {
        // Skip any table that fails to read.
      }
    }

    // Add the combined JSON.
    final jsonBytes =
        utf8.encode(const JsonEncoder.withIndent('  ').convert(jsonExport));
    archive.addFile(
      ArchiveFile('all_data.json', jsonBytes.length, jsonBytes),
    );

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) throw Exception('Failed to encode ZIP.');
    return Uint8List.fromList(zipBytes);
  }

  /// Escape a single CSV field value.
  String _csvField(dynamic value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  /// Build one CSV row from a list of values.
  String _csvRow(List<dynamic> values) =>
      values.map(_csvField).join(',');

  /// Open the system Save-As dialog and write the ZIP file.
  /// Call this AFTER dismissing any progress spinner.
  Future<void> saveJsonFile(Uint8List zipData) async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final fileName = 'survey_data_$dateStr.zip';

    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Survey Data',
      fileName: fileName,
      bytes: zipData,
    );

    if (result == null) return; // user cancelled

    // Desktop: FilePicker returns a path but does not write — write manually.
    // Android SAF returns a content:// URI and writes itself.
    if (!result.startsWith('content://')) {
      final outPath = result.endsWith('.zip') ? result : '$result.zip';
      File(outPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(zipData);
    }
  }
}
