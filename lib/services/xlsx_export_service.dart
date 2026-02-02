import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dri_survey/services/database_service.dart';

class XlsxExportService {
  /// Export village survey identified by [sessionId] to an XLSX file
  /// saved at the app documents directory with name [fileName].
  Future<String> exportVillageSurveyToXlsx(String sessionId, String fileName) async {
    if (kIsWeb) {
      throw UnsupportedError('XLSX export not supported on web');
    }

    final db = DatabaseService();

    // Load session data
    final session = await db.getVillageSurveySession(sessionId) ?? {};

    // Tables to export for village survey
    final tableNames = <String>[
      'village_population',
      'village_farm_families',
      'village_drainage_waste',
      'village_housing',
      'village_agricultural_implements',
      'village_crop_productivity',
      'village_animals',
      'village_irrigation_facilities',
      'village_drinking_water',
      'village_transport',
      'village_entertainment',
      'village_medical_treatment',
      'village_disputes',
      'village_educational_facilities',
      'village_social_consciousness',
      'village_children_data',
      'village_malnutrition_data',
      'village_bpl_families',
      'village_kitchen_gardens',
      'village_seed_clubs',
      'village_biodiversity_register',
      'village_traditional_occupations',
      'village_unemployment',
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
      final rows = await db.getVillageData(table, sessionId);
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
      'children_data',
      'malnourished_children_data',
      'child_diseases',
      'folklore_medicine',
      'health_programmes',
      'aadhaar_scheme_members',
      'tribal_scheme_members',
      'pension_scheme_members',
      'widow_scheme_members',
      'training_data',
      'shg_members',
      'fpo_members',
      'bank_accounts',
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