import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dri_survey/services/database_service.dart';

class XlsxExportService {

  String _prettyLabel(String key) {
    final words = key.replaceAll('_', ' ').split(' ');
    return words.map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  // Mapping of internal keys → UI question labels (common/important keys).
  // This list is sourced from lib/screens/family_survey/pages (UI labels).
  final Map<String, String> _labelMap = {
    // Session / location
    'phone_number': 'Phone Number',
    'village_name': 'Village Name',
    'panchayat': 'Panchayat',
    'block': 'Block',
    'tehsil': 'Tehsil',
    'district': 'District',
    'postal_address': 'Postal Address',
    'pin_code': 'Pin Code',
    'shine_code': 'Shine Code',
    'latitude': 'Latitude',
    'longitude': 'Longitude',
    'surveyor_name': 'Surveyor Name',

    // Family member fields
    'sr_no': 'Sr. No.',
    'name': 'Name',
    'fathers_name': "Father's Name",
    'mothers_name': "Mother's Name",
    'relationship_with_head': 'Relationship with Head',
    'age': 'Age',
    'sex': 'Sex',
    'physically_fit': 'Physically Fit/Unfit',
    'physically_fit_cause': 'Cause of Unfitness',
    'educational_qualification': 'Educational Qualification',
    'inclination_self_employment': 'Inclination Toward Self Employment',
    'occupation': 'Occupation',
    'days_employed': 'No. of Days Employed',
    'income': 'Income',
    'awareness_about_village': 'Awareness About the Village',
    'participate_gram_sabha': 'Participate in Gram Sabha Meetings',
    'insured': 'Insured',
    'insurance_company': 'Insurance Company',

    // Land & crops
    'irrigated_area': 'Irrigated Area',
    'cultivable_area': 'Cultivable Area',
    'crop_name': 'Crop Name',
    'crop_type': 'Crop Type',
    'area_hectares': 'Area (hectares)',
    'total_production_quintal': 'Total Production (quintal)',
    'quantity_sold_quintal': 'Quantity Sold (quintal)',
    'rate': 'Rate',

    // Animals
    'animal_type': 'Animal Type',
    'number_of_animals': 'Number of Animals',
    'breed': 'Breed',
    'production_per_animal': 'Production per Animal',

    // Schemes / bank
    'account_number': 'Account Number',
    'bank_name': 'Bank Name',
    'ifsc_code': 'IFSC Code',

    // Generic known fields
    'head_of_family': 'Head of Family',
    'family_id': 'Family ID',
  };

  String _labelForKey(String key) {
    if (key == null) return '';
    final k = key.toString();
    if (_labelMap.containsKey(k)) return _labelMap[k]!;
    return _prettyLabel(k);
  }

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
      'village_infrastructure',
      'village_infrastructure_details',
      'village_educational_facilities',
      'village_drainage_waste',
      'village_irrigation_facilities',
      'village_seed_clubs',
      'village_biodiversity_register',
      'village_social_maps',
      'village_traditional_occupations',
      'village_survey_details',
      'village_population',
      'village_farm_families',
      'village_housing',
      'village_agricultural_implements',
      'village_crop_productivity',
      'village_animals',
      'village_drinking_water',
      'village_transport_facilities',
      'village_entertainment',
      'village_medical_treatment',
      'village_disputes',
      'village_social_consciousness',
      'village_children_data',
      'village_malnutrition_data',
      'village_bpl_families',
      'village_kitchen_gardens',
      'village_unemployment',
      'village_signboards',
      'village_forest_maps',
      'village_cadastral_maps',
      'village_map_points',
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

      // Use keys of first row as header (mapped labels)
      final headerKeys = rows.first.keys.toList();
      final header = headerKeys.map((k) => TextCellValue(_labelForKey(k.toString()))).toList();
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

    // Tables to export in approximate page order (one-to-many grids will become tables)
    final tableNames = <String>[
      'family_members',
      'social_consciousness',
      'tribal_questions',
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
      'diseases',
      'health_programmes',
      'folklore_medicine',
      'aadhaar_scheme_members',
      'tribal_scheme_members',
      'pension_scheme_members',
      'widow_scheme_members',
      'ayushman_scheme_members',
      'ration_scheme_members',
      'family_id_scheme_members',
      'samagra_scheme_members',
      'handicapped_scheme_members',
      'vb_gram',
      'vb_gram_members',
      'pm_kisan_nidhi',
      'pm_kisan_members',
      'pm_kisan_samman_nidhi',
      'pm_kisan_samman_members',
      'merged_govt_schemes',
      'shg_members',
      'fpo_members',
      'children_data',
      'malnourished_children_data',
      'child_diseases',
      'migration_data',
      'training_data',
      'bank_accounts',
    ];

    final excel = Excel.createExcel();

    // Single consolidated sheet for family survey export
    final sheet = excel['FamilySurvey'];

    // 1) Session / top-level key-values (kept as Section = Session, Field, Value)
    sheet.appendRow([TextCellValue('Section'), TextCellValue('Field'), TextCellValue('Value')]);
    session.forEach((k, v) {
      sheet.appendRow([TextCellValue('Session'), TextCellValue(k.toString()), TextCellValue(v?.toString() ?? '')]);
    });

    // Blank row separator
    sheet.appendRow([TextCellValue('')]);

    // 2) Page-wise sections and one-to-many tables (grid)
    for (final table in tableNames) {
      final rows = await db.getData(table, sessionId);

      // Section header: Table name (keeps page order as defined above)
      sheet.appendRow([TextCellValue('Section'), TextCellValue(table)]);
      if (rows.isEmpty) {
        sheet.appendRow([TextCellValue('Info'), TextCellValue('No data')]);
        sheet.appendRow([TextCellValue('')]); // spacer
        continue;
      }

      // If rows are maps (repeating records) write a header row with keys then rows
      final headerKeys = rows.first.keys.toList();
      // Header row: put a marker in first column then human-friendly question labels
      sheet.appendRow([TextCellValue('Header'), ...headerKeys.map((k) => TextCellValue(_labelForKey(k.toString()))).toList()]);

      for (final row in rows) {
        sheet.appendRow([TextCellValue('Row'), ...headerKeys.map((key) => TextCellValue(row[key] != null ? row[key].toString() : '')).toList()]);
      }

      // Spacer between sections
      sheet.appendRow([TextCellValue('')]);
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