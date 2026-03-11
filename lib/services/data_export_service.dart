import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

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

  /// Export the entire SQLite database (+ any pre-migration backups) as a ZIP.
  /// Opens the Android/iOS SAF "Save to…" folder dialog so the user picks where to save.
  Future<void> exportDatabaseAsZip() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final archive = Archive();

      // Add the live DB file.
      final liveDb = File(p.join(docsDir.path, 'family_survey.db'));
      if (await liveDb.exists()) {
        final bytes = await liveDb.readAsBytes();
        archive.addFile(ArchiveFile('family_survey.db', bytes.length, bytes));
      } else {
        throw Exception('Database file not found. No data has been saved yet.');
      }

      // Add any pre-migration backup files so old data is bundled too.
      final docsDirList = docsDir.listSync();
      for (final entity in docsDirList) {
        if (entity is File) {
          final name = p.basename(entity.path);
          if (name.startsWith('family_survey_backup_v') && name.endsWith('.db')) {
            final bytes = await entity.readAsBytes();
            archive.addFile(ArchiveFile(name, bytes.length, bytes));
          }
        }
      }

      // Encode to ZIP bytes.
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) throw Exception('Failed to encode ZIP.');

      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final fileName = 'survey_data_$dateStr.zip';

      // Open the system Save-As dialog.
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Survey Database',
        fileName: fileName,
        bytes: Uint8List.fromList(zipBytes),
      );

      if (result == null) {
        // User cancelled.
        throw Exception('Save cancelled by user.');
      }

      // On desktop/some Android versions FilePicker returns the path but doesn't
      // write bytes itself — write manually as a fallback.
      if (!result.endsWith('.zip') || !await File(result).exists()) {
        final outPath = result.endsWith('.zip') ? result : '$result.zip';
        await File(outPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(Uint8List.fromList(zipBytes));
      }
    } catch (e) {
      rethrow;
    }
  }
}
