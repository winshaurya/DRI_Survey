import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dri_survey/services/database_service.dart';

class XlsxExportService {
  /// Export survey identified by [sessionId] (phone number) to an XLSX file
  /// saved at the app documents directory with name [fileName].
  Future<String> exportSurveyToXlsx(String sessionId, String fileName) async {
    if (kIsWeb) {
      throw UnsupportedError('XLSX export not supported on web');
    }

    final db = DatabaseService();

    // Load session data
    final session = await db.getSurveySession(sessionId) ?? {};

    // Tables to export (add/remove as desired)
    final tableNames = <String>[
      'family_members',
      'land_holding',
      'irrigation_facilities',
      'crop_productivity',
      'fertilizer_usage',
      'animals',
      'agricultural_equipment',
      'entertainment_facilities',
      'transport_facilities',
      'drinking_water_sources',
      'medical_treatment',
      'disputes',
      'house_conditions',
      'house_facilities',
      'social_consciousness',
    ];

    final excel = Excel.createExcel();

    // Session sheet (key / value)
    final sessionSheet = excel['Session'];
    sessionSheet.appendRow([TextCellValue('Field'), TextCellValue('Value')]);
    session.forEach((k, v) {
      sessionSheet.appendRow([TextCellValue(k), TextCellValue(v?.toString() ?? '')]);
    });

    // Other tables: create sheet per table
    for (final table in tableNames) {
      final rows = await db.getData(table, sessionId);
      final sheetName = table.length <= 31 ? table : table.substring(0, 31);
      final sheet = excel[sheetName];

      if (rows.isEmpty) {
        sheet.appendRow([TextCellValue('No data')]);
        continue;
      }

      // Use keys of first row as header
      final headerKeys = rows.first.keys.toList();
      final header = headerKeys.map((k) => TextCellValue(k.toString())).toList();
      sheet.appendRow(header);

      for (final row in rows) {
        final values = headerKeys.map((key) => TextCellValue(row[key] != null ? row[key].toString() : '')).toList();
        sheet.appendRow(values);
      }
    }

    // Encode and write file to application documents directory
    final encoded = excel.encode();
    if (encoded == null) throw Exception('Failed to encode Excel file');

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(encoded, flush: true);

    return filePath;
  }
}