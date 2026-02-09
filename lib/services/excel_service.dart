import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../services/database_service.dart';

class ExcelService {
  static final ExcelService _instance = ExcelService._internal();

  factory ExcelService() {
    return _instance;
  }

  ExcelService._internal();

  final DatabaseService _databaseService = DatabaseService();

  static const int _maxEstimatedRows = 30000;
  bool _isExporting = false;

  // Cell Styles
  final CellStyle _headerStyle = CellStyle(
    bold: true,
    fontSize: 14,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    backgroundColorHex: ExcelColor.fromHexString('#D3D3D3'),
    fontFamily: getFontFamily(FontFamily.Arial),
  );

  final CellStyle _subHeaderStyle = CellStyle(
    bold: true,
    horizontalAlign: HorizontalAlign.Left,
    verticalAlign: VerticalAlign.Center,
    backgroundColorHex: ExcelColor.fromHexString('#EFEFEF'),
    fontFamily: getFontFamily(FontFamily.Arial),
  );

  final CellStyle _labelStyle = CellStyle(
    bold: true,
    horizontalAlign: HorizontalAlign.Left,
    verticalAlign: VerticalAlign.Center,
  );

  final CellStyle _valueStyle = CellStyle(
    horizontalAlign: HorizontalAlign.Left,
    verticalAlign: VerticalAlign.Center,
    textWrapping: TextWrapping.WrapText,
  );

  // Track current row index manually to stack tables
  int _rowIndex = 0;

  /// Export complete survey data from SQLite to Excel
  Future<void> exportCompleteSurveyToExcel(String phoneNumber) async {
    try {
      if (_isExporting) {
        throw Exception('Another export is already in progress. Please wait.');
      }
      _isExporting = true;

      // Fetch ALL data from SQLite
      final surveyData = await fetchCompleteSurveyData(phoneNumber);

      if (surveyData.isEmpty) {
        throw Exception('No survey data found for phone number: $phoneNumber');
      }

      final estimatedRows = _estimateRowCount(surveyData);
      if (estimatedRows > _maxEstimatedRows) {
        throw Exception('Survey is too large to export safely ($estimatedRows rows). Please export a smaller subset.');
      } else if (estimatedRows > (_maxEstimatedRows * 0.7)) {
        print('⚠ Warning: Large export ($estimatedRows rows). This may take time.');
      }

      var excel = Excel.createExcel();
      String sheetName = 'Complete Survey Report';
      if (excel.sheets.containsKey('Sheet1')) {
        excel.rename('Sheet1', sheetName);
      }

      Sheet sheet = excel[sheetName];
      _rowIndex = 0; // Reset row index

      // Create comprehensive report
      await createComprehensiveReport(sheet, surveyData);

      // Save file
      await _saveExcelFile(excel, _safeFileName('complete_survey_${phoneNumber}_${DateTime.now().millisecondsSinceEpoch}.xlsx'));

    } catch (e) {
      throw Exception('Failed to export complete survey: $e');
    } finally {
      _isExporting = false;
    }
  }


  /// Export all surveys to a single comprehensive Excel file
  Future<void> exportAllSurveysToExcel() async {
    try {
      if (_isExporting) {
        throw Exception('Another export is already in progress. Please wait.');
      }
      _isExporting = true;

      final db = DatabaseService();
      final sessions = await db.getAllSurveySessions();

      if (sessions.isEmpty) {
        throw Exception('No survey data found to export');
      }

      final excel = Excel.createExcel();
      final overviewSheet = excel['Survey Overview'];
      
      // Add headers
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

      for (final session in sessions) {
        final phoneNumber = session['phone_number'];
        final identifier = phoneNumber ?? session['id'] ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';
        String exportStatus = 'Success';
        
        try {
          final members = await db.getData('family_members', identifier);
          final totalIncome = members.fold<double>(0.0, (sum, member) =>
            sum + (double.tryParse(member['income']?.toString() ?? '0') ?? 0.0));

          if (phoneNumber == null) {
            exportStatus = 'Skipped - No phone number';
          }

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

        } catch (e) {
          exportStatus = 'Error: $e';
          print('✗ Error processing survey $identifier: $e');
          
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
      print('  📄 Total in overview: ${sessions.length} surveys\n');

      await _saveExcelFile(excel, _safeFileName('all_surveys_${DateTime.now().millisecondsSinceEpoch}.xlsx'));

    } catch (e) {
      throw Exception('Failed to export all surveys: $e');
    } finally {
      _isExporting = false;
    }
  }

  /// Export complete survey data with all details to Excel
  Future<void> exportCompleteSurveyData(String phoneNumber) async {
    await exportCompleteSurveyToExcel(phoneNumber);
  }

  /// Export complete village survey data to Excel (single sheet)
  Future<void> exportCompleteVillageSurveyToExcel(String sessionId) async {
    try {
      if (_isExporting) {
        throw Exception('Another export is already in progress. Please wait.');
      }
      _isExporting = true;

      final surveyData = await fetchCompleteVillageSurveyData(sessionId);
      if (surveyData.isEmpty) {
        throw Exception('No village survey data found for session: $sessionId');
      }

      var excel = Excel.createExcel();
      String sheetName = 'Village Survey Report';
      if (excel.sheets.containsKey('Sheet1')) {
        excel.rename('Sheet1', sheetName);
      }

      Sheet sheet = excel[sheetName];
      _rowIndex = 0;

      await createVillageSurveyReport(sheet, surveyData);

      await _saveExcelFile(
        excel,
        _safeFileName('village_survey_${sessionId}_${DateTime.now().millisecondsSinceEpoch}.xlsx'),
      );
    } catch (e) {
      throw Exception('Failed to export village survey: $e');
    } finally {
      _isExporting = false;
    }
  }

  String _safeSheetName(String name) {
    final sanitized = name.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
    return sanitized.length > 31 ? sanitized.substring(0, 31) : sanitized;
  }

  Future<Map<String, dynamic>> fetchCompleteSurveyData(String phoneNumber) async {
    final data = <String, dynamic>{};
    final missingTables = <String>[];
    final errorTables = <String, String>{};

    try {
      // 1. Get main survey session data
      final sessionData = await _databaseService.getSurveySession(phoneNumber);
      if (sessionData != null) {
        data.addAll(sessionData);
      } else {
        throw Exception('Survey session not found for phone: $phoneNumber');
      }

      // 2. Get all related data tables
      final dataMappings = {
        'family_members': 'family_members',
        'social_consciousness': 'social_consciousness',
        'tribal_questions': 'tribal_questions',
        'land_holding': 'land_holding',
        'irrigation_facilities': 'irrigation_facilities',
        'crop_productivity': 'crop_productivity',
        'fertilizer_usage': 'fertilizer_usage',
        'animals': 'animals',
        'agricultural_equipment': 'agricultural_equipment',
        'entertainment_facilities': 'entertainment_facilities',
        'transport_facilities': 'transport_facilities',
        'drinking_water_sources': 'drinking_water_sources',
        'medical_treatment': 'medical_treatment',
        'disputes': 'disputes',
        'house_conditions': 'house_conditions',
        'house_facilities': 'house_facilities',
        'diseases': 'diseases',
        'health_programmes': 'health_programmes',
        'folklore_medicine': 'folklore_medicine',
        'shg_members': 'shg_members',
        'fpo_members': 'fpo_members',
        'bank_accounts': 'bank_accounts',
        'children_data': 'children_data',
        'malnourished_children_data': 'malnourished_children_data',
        'child_diseases': 'child_diseases',
        'migration_data': 'migration_data',
        'training_data': 'training_data',
      };

      for (final entry in dataMappings.entries) {
        try {
          final tableData = await _databaseService.getData(entry.key, phoneNumber);
          if (tableData.isNotEmpty) {
            data[entry.value] = tableData;
          } else {
            missingTables.add(entry.key);
          }
        } catch (e) {
          errorTables[entry.key] = e.toString();
          print('⚠ Warning: Could not fetch data from ${entry.key}: $e');
        }
      }

      // 3. Get government schemes data
      await _fetchGovernmentSchemesData(phoneNumber, data);

      // Log summary
      if (missingTables.isNotEmpty) {
        print('ℹ Info: Empty tables for $phoneNumber: ${missingTables.join(", ")}');
      }
      if (errorTables.isNotEmpty) {
        print('⚠ Warning: Failed to fetch ${errorTables.length} tables for $phoneNumber');
        errorTables.forEach((table, error) {
          print('  ✗ $table: $error');
        });
      }

      // Store metadata about data completeness
      data['_export_metadata'] = {
        'export_timestamp': DateTime.now().toIso8601String(),
        'missing_tables_count': missingTables.length,
        'error_tables_count': errorTables.length,
        'total_tables_attempted': dataMappings.length,
        'data_completeness_percentage': 
            ((dataMappings.length - missingTables.length - errorTables.length) / dataMappings.length * 100).toStringAsFixed(1),
      };

    } catch (e) {
      print('✗ Error fetching complete survey data: $e');
      throw Exception('Failed to fetch survey data: $e');
    }

    return data;
  }

  /// Fetch complete village survey data from local database
  Future<Map<String, dynamic>> fetchCompleteVillageSurveyData(String sessionId) async {
    final db = await _databaseService.database;

    final sessions = await db.query(
      'village_survey_sessions',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    if (sessions.isEmpty) {
      throw Exception('Village survey session not found: $sessionId');
    }

    final surveyData = Map<String, dynamic>.from(sessions.first);

    final tables = [
      'village_population',
      'village_farm_families',
      'village_housing',
      'village_agricultural_implements',
      'village_crop_productivity',
      'village_animals',
      'village_irrigation_facilities',
      'village_drinking_water',
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
      'village_drainage_waste',
      'village_signboards',
      'village_infrastructure',
      'village_infrastructure_details',
      'village_survey_details',
      'village_map_points',
      'village_forest_maps',
      'village_cadastral_maps',
      'village_unemployment',
      'village_social_maps',
      'village_transport_facilities',
    ];

    for (final table in tables) {
      try {
        final data = await db.query(
          table,
          where: 'session_id = ?',
          whereArgs: [sessionId],
        );
        if (data.isNotEmpty) {
          if (_isOneToManyVillageTable(table)) {
            surveyData[table] = data;
          } else {
            surveyData[table] = data.first;
          }
        }
      } catch (_) {}
    }

    return surveyData;
  }

  bool _isOneToManyVillageTable(String tableName) {
    const oneToManyTables = {
      'village_crop_productivity',
      'village_animals',
      'village_malnutrition_data',
      'village_traditional_occupations',
    };
    return oneToManyTables.contains(tableName);
  }

  /// Fetch all government schemes data
  Future<void> _fetchGovernmentSchemesData(String phoneNumber, Map<String, dynamic> data) async {
    final schemeTables = [
      'aadhaar_info', 'aadhaar_scheme_members',
      'ayushman_card', 'ayushman_scheme_members',
      'family_id', 'family_id_scheme_members',
      'ration_card', 'ration_scheme_members',
      'samagra_id', 'samagra_scheme_members',
      'tribal_card', 'tribal_scheme_members',
      'handicapped_allowance', 'handicapped_scheme_members',
      'pension_allowance', 'pension_scheme_members',
      'widow_allowance', 'widow_scheme_members',
      'vb_gram', 'vb_gram_members',
      'pm_kisan_nidhi', 'pm_kisan_members',
      'pm_kisan_samman_nidhi', 'pm_kisan_samman_members',
      'merged_govt_schemes',
    ];

    for (final table in schemeTables) {
      final tableData = await _databaseService.getData(table, phoneNumber);
      if (tableData.isNotEmpty) {
        data[table] = tableData;
      }
    }
  }

  /// Create comprehensive Excel report
  Future<void> createComprehensiveReport(Sheet sheet, Map<String, dynamic> data) async {
    // Set column widths dynamically based on content (more columns supported)
    for (int i = 0; i < 15; i++) {
      double width = 20; // Default width
      if (i == 0) width = 30; // First column wider for labels
      sheet.setColumnWidth(i, width);
    }

    // 1. Report Header
    _addReportHeader(sheet, data);

    // 2. Family Members
    _addFamilyMembersSection(sheet, data);

    // 3. Agriculture & Land
    _addAgricultureSection(sheet, data);

    // 4. Livestock & Equipment
    _addLivestockSection(sheet, data);

    // 5. Health Information
    _addHealthSection(sheet, data);

    // 6. Government Schemes & Benefits
    _addGovernmentSchemesSection(sheet, data);

    // 7. Social Consciousness
    _addSocialConsciousnessSection(sheet, data);

    // 8. Training & Groups
    _addTrainingSection(sheet, data);

    // 9. Financial Information
    _addFinancialSection(sheet, data);

    // 10. Infrastructure & Facilities
    _addInfrastructureSection(sheet, data);

    // 11. Other Information
    _addOtherInformationSection(sheet, data);
  }

  /// Create a single-sheet village survey report with clear headings
  Future<void> createVillageSurveyReport(Sheet sheet, Map<String, dynamic> data) async {
    for (int i = 0; i < 18; i++) {
      double width = 22;
      if (i == 0) width = 32;
      sheet.setColumnWidth(i, width);
    }

    _writeSectionHeader(sheet, 'VILLAGE SURVEY REPORT');

    _writeKeyValuePair(sheet, 'Village Name:', data['village_name']);
    _writeKeyValuePair(sheet, 'Village Smile:', data['village_smile']);
    _writeKeyValuePair(sheet, 'Shine Code:', data['shine_code']);
    _writeKeyValuePair(sheet, 'Panchayat:', data['panchayat']);
    _writeKeyValuePair(sheet, 'Block:', data['block']);
    _writeKeyValuePair(sheet, 'District:', data['district']);
    _writeKeyValuePair(sheet, 'Survey Date:', data['survey_date']);
    _writeKeyValuePair(sheet, 'Surveyor Name:', data['surveyor_name']);
    _writeKeyValuePair(sheet, 'Latitude:', data['latitude']);
    _writeKeyValuePair(sheet, 'Longitude:', data['longitude']);
    _writeKeyValuePair(sheet, 'Location Accuracy:', data['location_accuracy']);
    _writeKeyValuePair(sheet, 'Location Timestamp:', data['location_timestamp']);
    _writeKeyValuePair(sheet, 'Status:', data['status']);
    _writeKeyValuePair(sheet, 'Device Info:', data['device_info']);
    _writeKeyValuePair(sheet, 'App Version:', data['app_version']);
    _rowIndex++;

    final sectionOrder = <String, String>{
      'village_population': 'Population',
      'village_farm_families': 'Farm Families',
      'village_housing': 'Housing',
      'village_agricultural_implements': 'Agricultural Implements',
      'village_crop_productivity': 'Crop Productivity',
      'village_animals': 'Animals',
      'village_irrigation_facilities': 'Irrigation Facilities',
      'village_drinking_water': 'Drinking Water',
      'village_transport': 'Transport',
      'village_transport_facilities': 'Transport Facilities',
      'village_entertainment': 'Entertainment',
      'village_medical_treatment': 'Medical Treatment',
      'village_disputes': 'Disputes',
      'village_educational_facilities': 'Educational Facilities',
      'village_social_consciousness': 'Social Consciousness',
      'village_children_data': 'Children Data',
      'village_malnutrition_data': 'Malnutrition Data',
      'village_bpl_families': 'BPL Families',
      'village_kitchen_gardens': 'Kitchen Gardens',
      'village_seed_clubs': 'Seed Clubs',
      'village_biodiversity_register': 'Biodiversity Register',
      'village_traditional_occupations': 'Traditional Occupations',
      'village_drainage_waste': 'Drainage & Waste',
      'village_signboards': 'Signboards',
      'village_infrastructure': 'Infrastructure',
      'village_infrastructure_details': 'Infrastructure Details',
      'village_survey_details': 'Survey Details',
      'village_map_points': 'Map Points',
      'village_forest_maps': 'Forest Maps',
      'village_cadastral_maps': 'Cadastral Maps',
      'village_unemployment': 'Unemployment',
      'village_social_maps': 'Social Maps',
    };

    for (final entry in sectionOrder.entries) {
      final sectionData = data[entry.key];
      if (sectionData == null) continue;

      _writeSectionHeader(sheet, entry.value.toUpperCase());

      if (sectionData is Map<String, dynamic>) {
        _writeMapSection(sheet, sectionData);
      } else if (sectionData is List) {
        _writeListSection(sheet, sectionData);
      }

      _rowIndex++;
    }
  }

  void _writeMapSection(Sheet sheet, Map<String, dynamic> data) {
    // Only skip technical fields, not user-input fields or map links
    const skip = {
      'id', 'session_id', 'created_at', 'updated_at', 'sync_status', 'sync_pending', 'last_synced_at',
      'device_info', 'app_version', 'location_accuracy', 'location_timestamp', 'shine_code', 'village_smile', 'latitude', 'longitude'
    };
    for (final entry in data.entries) {
      if (skip.contains(entry.key)) continue;
      _writeKeyValuePair(sheet, '${_prettyLabel(entry.key)}:', entry.value);
    }
  }

  void _writeListSection(Sheet sheet, List<dynamic> rows) {
    if (rows.isEmpty || rows.first is! Map) {
      _writeKeyValuePair(sheet, 'No data', '-');
      return;
    }

    final first = Map<String, dynamic>.from(rows.first as Map);
    final headers = first.keys.where((k) => !_shouldSkipVillageField(k)).toList();
    if (headers.isEmpty) {
      _writeKeyValuePair(sheet, 'No data', '-');
      return;
    }

    _writeTableHeader(sheet, headers.map(_prettyLabel).toList());

    for (final row in rows) {
      final mapRow = Map<String, dynamic>.from(row as Map);
      final cells = headers.map((key) => TextCellValue(mapRow[key]?.toString() ?? '')).toList();
      _writeTableRow(sheet, cells);
    }
  }

  String _prettyLabel(String key) {
    final words = key.replaceAll('_', ' ').split(' ');
    return words.map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  bool _shouldSkipVillageField(String key) {
    const skip = {
      'id',
      'session_id',
      'created_at',
      'updated_at',
      'sync_status',
      'sync_pending',
      'last_synced_at',
    };
    return skip.contains(key);
  }

  /// Legacy method for backward compatibility
  Future<void> exportSurveyToExcel(Map<String, dynamic> surveyData) async {
    // If phone number is available, use the new comprehensive method
    if (surveyData['phone_number'] != null) {
      await exportCompleteSurveyToExcel(surveyData['phone_number']);
      return;
    }

    // Otherwise use the old method
    var excel = Excel.createExcel();
    String sheetName = 'Survey Report';
    if (excel.sheets.containsKey('Sheet1')) {
      excel.rename('Sheet1', sheetName);
    }

    Sheet sheet = excel[sheetName];
    _rowIndex = 0;

    _addReportHeader(sheet, surveyData);
    _addFamilySection(sheet, surveyData);
    _addAgricultureSection(sheet, surveyData);
    _addLivestockSection(sheet, surveyData);
    _addHealthSection(sheet, surveyData);
    _addSchemesSection(sheet, surveyData);
    _addOtherSection(sheet, surveyData);

    await _saveExcelFile(
      excel,
      _safeFileName('survey_${surveyData['village_name'] ?? 'export'}_${surveyData['head_of_family'] ?? 'family'}.xlsx'),
    );
  }

  // --- Helper Methods ---

  void _addReportHeader(Sheet sheet, Map<String, dynamic> data) {
    // Main Title
    sheet.merge(CellIndex.indexByString("A${_rowIndex + 1}"), CellIndex.indexByString("D${_rowIndex + 1}"));
    var cell = sheet.cell(CellIndex.indexByString("A${_rowIndex + 1}"));
    cell.value = TextCellValue("FAMILY SURVEY REPORT");
    // Create specific style for main title
    cell.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#D3D3D3'), // Light Grey
      fontFamily: getFontFamily(FontFamily.Arial),
    );
    _rowIndex++;

    // Sub-title (Village Info)
    String villageInfo = "Village: ${data['village_name'] ?? ''} | Panchayat: ${data['panchayat'] ?? ''} | Block: ${data['block'] ?? ''}";
    sheet.merge(CellIndex.indexByString("A${_rowIndex + 1}"), CellIndex.indexByString("D${_rowIndex + 1}"));
    var subCell = sheet.cell(CellIndex.indexByString("A${_rowIndex + 1}"));
    subCell.value = TextCellValue(villageInfo);
    subCell.cellStyle = _subHeaderStyle;
    _rowIndex++;
    
    _rowIndex++; // Spacer

    // Basic Info Grid
    _writeKeyValuePair(sheet, "Surveyor Name:", data['surveyor_name']);
    _writeKeyValuePair(sheet, "Survey Date:", data['survey_date']);
    _writeKeyValuePair(sheet, "Head of Family:", data['head_of_family']);
    _writeKeyValuePair(sheet, "Family ID:", data['family_id_scheme_members'] != null && (data['family_id_scheme_members'] as List).isNotEmpty 
        ? data['family_id_scheme_members'][0]['card_number'] 
        : "N/A");
    
    _rowIndex++; // Spacer
  }

  void _addFamilySection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "FAMILY MEMBERS DETAILS");
    
    List<String> headers = ['Name', 'Relation', 'Age', 'Sex', 'Education', 'Occupation', 'Income'];
    _writeTableHeader(sheet, headers);

    if (data['family_members'] != null && data['family_members'] is List) {
      for (var member in data['family_members']) {
        List<CellValue> row = [
          TextCellValue(member['name']?.toString() ?? ''),
          TextCellValue((member['relationship_with_head'] ?? member['relationship'])?.toString() ?? ''),
          IntCellValue(int.tryParse(member['age']?.toString() ?? '0') ?? 0),
          TextCellValue(member['sex']?.toString() ?? ''),
          TextCellValue((member['educational_qualification'] ?? member['education'])?.toString() ?? ''),
          TextCellValue(member['occupation']?.toString() ?? ''),
          DoubleCellValue(double.tryParse(member['income']?.toString() ?? '0') ?? 0.0),
        ];
        _writeTableRow(sheet, row);
      }
    }
    _rowIndex++;
  }

  void _addAgricultureSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "AGRICULTURE LAND & CROPS");
    
    // Land
     _writeSubSectionHeader(sheet, "Land Holdings (Acres for Year)");
     final land = (data['land_holding'] is Map<String, dynamic>) ? data['land_holding'] as Map<String, dynamic> : data;
     _writeKeyValuePair(sheet, "Irrigated Land:", land['irrigated_area'] ?? land['irrigated_land']);
     _writeKeyValuePair(sheet, "Unirrigated Land:", land['unirrigated_area'] ?? land['unirrigated_land']);
     _writeKeyValuePair(sheet, "Barren Land:", land['barren_land']);
     _rowIndex++;

    // Crops
    _writeSubSectionHeader(sheet, "Crops Production");
    List<String> cropHeaders = ['Crop Name', 'Area (Acres)', 'Production (Q)', 'Sold (Q)', 'Rate (Rs)'];
    _writeTableHeader(sheet, cropHeaders);
    
    final crops = data['crop_productivity'] ?? data['crops'];
    if (crops != null && crops is List) {
      for (var crop in crops) {
        _writeTableRow(sheet, [
          TextCellValue(crop['crop_name']?.toString() ?? ''),
          DoubleCellValue(double.tryParse((crop['area_hectares'] ?? crop['area'])?.toString() ?? '0') ?? 0),
          DoubleCellValue(double.tryParse((crop['total_production_quintal'] ?? crop['production'])?.toString() ?? '0') ?? 0),
          DoubleCellValue(double.tryParse((crop['quantity_sold_quintal'] ?? crop['quantity_sold'])?.toString() ?? '0') ?? 0),
          DoubleCellValue(double.tryParse((crop['rate'] ?? crop['price_per_quintal'])?.toString() ?? '0') ?? 0),
        ]);
      }
    }
    _rowIndex++;

    // Fertilizer
    _writeSubSectionHeader(sheet, "Fertilizer Usage");
    if (data['fertilizer_usage'] != null && data['fertilizer_usage'] is Map) {
      final fert = data['fertilizer_usage'];
      _writeKeyValuePair(sheet, "Urea Fertilizer:", fert['urea_fertilizer']);
      _writeKeyValuePair(sheet, "Organic Fertilizer:", fert['organic_fertilizer']);
      _writeKeyValuePair(sheet, "Fertilizer Types:", fert['fertilizer_types']);
    }
    _rowIndex++;
  }

  void _addLivestockSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "LIVESTOCK & ASSETS");
    
    // Animals
    _writeSubSectionHeader(sheet, "Animals");
    List<String> animalHeaders = ['Type', 'Count', 'Breed', 'Milk (Ltrs)'];
    _writeTableHeader(sheet, animalHeaders);
     if (data['animals'] != null && data['animals'] is List) {
      for (var x in data['animals']) {
        _writeTableRow(sheet, [
          TextCellValue(x['animal_type']?.toString() ?? ''),
          IntCellValue(int.tryParse((x['number_of_animals'] ?? x['count'])?.toString() ?? '0') ?? 0),
          TextCellValue(x['breed']?.toString() ?? ''),
          DoubleCellValue(double.tryParse((x['production_per_animal'] ?? x['milk_production'])?.toString() ?? '0') ?? 0),
        ]);
      }
    }
    
    // Farm Equipment (Simple List)
    _rowIndex++;
    _writeSubSectionHeader(sheet, "Farm Equipment");
    List<String> equipments = [];
    final equipmentData = (data['agricultural_equipment'] is Map<String, dynamic>)
      ? data['agricultural_equipment'] as Map<String, dynamic>
      : data;
    if (equipmentData['tractor'] != null && equipmentData['tractor'].toString().isNotEmpty) equipments.add("Tractor: ${equipmentData['tractor']}");
    if (equipmentData['diesel_engine'] != null && equipmentData['diesel_engine'].toString().isNotEmpty) equipments.add("Diesel Engine: ${equipmentData['diesel_engine']}");
    if (equipmentData['thresher'] != null && equipmentData['thresher'].toString().isNotEmpty) equipments.add("Thresher: ${equipmentData['thresher']}");
    if (equipmentData['sprayer'] != null && equipmentData['sprayer'].toString().isNotEmpty) equipments.add("Sprayer: ${equipmentData['sprayer']}");
    if (equipmentData['seed_drill'] != null && equipmentData['seed_drill'].toString().isNotEmpty) equipments.add("Seed Drill: ${equipmentData['seed_drill']}");
    if (equipmentData['other_equipment'] != null && equipmentData['other_equipment'].toString().isNotEmpty) equipments.add("Other: ${equipmentData['other_equipment']}");
    
    sheet.cell(CellIndex.indexByString("A${_rowIndex + 1}")).value = TextCellValue(equipments.join(", "));
    _rowIndex++;
    _rowIndex++;
  }
  
  void _addHealthSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "HEALTH INFORMATION");

    // Diseases
    _writeSubSectionHeader(sheet, "Major Diseases");
    _writeTableHeader(sheet, ['Member', 'Disease', 'Duration', 'Treatment']);
    if (data['diseases'] != null && data['diseases'] is List) {
      for (var d in data['diseases']) {
        _writeTableRow(sheet, [
          TextCellValue(d['member_name']?.toString() ?? ''),
          TextCellValue(d['disease_name']?.toString() ?? ''),
          TextCellValue(d['duration']?.toString() ?? ''),
          TextCellValue(d['treatment_type']?.toString() ?? ''),
        ]);
      }
    }
    _rowIndex++;

    // Malnourished
    _writeSubSectionHeader(sheet, "Malnourished Children");
    _writeTableHeader(sheet, ['Child Name', 'Age', 'Weight', 'Height', 'Grade']);
     if (data['malnourished_children_data'] != null && data['malnourished_children_data'] is List) {
      for (var d in data['malnourished_children_data']) {
        _writeTableRow(sheet, [
          TextCellValue(d['name']?.toString() ?? ''),
          IntCellValue(int.tryParse(d['age']?.toString() ?? '0') ?? 0),
          DoubleCellValue(double.tryParse(d['weight']?.toString() ?? '0') ?? 0),
          DoubleCellValue(double.tryParse(d['height']?.toString() ?? '0') ?? 0),
          TextCellValue(d['grade']?.toString() ?? ''),
        ]);
      }
    }
    _rowIndex++;
  }

  void _addSchemesSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "GOVERNMENT SCHEMES ELIGIBILITY & BENEFITS");

    // 1. General Programs (Flat list)
    _writeSubSectionHeader(sheet, "General Programs (Yes/No)");
    List<List<String>> generalSchemes = [
      ['PM Kisan Nidhi', _getBeneficiaryStatus(data, 'pm_kisan_nidhi')],
      ['PM Kisan Samman Nidhi', _getBeneficiaryStatus(data, 'pm_kisan_samman_nidhi')],
      ['Kisan Credit Card', _getBeneficiaryStatus(data, 'kisan_credit_card')],
      ['Swachh Bharat Mission', _getBeneficiaryStatus(data, 'swachh_bharat')],
      ['Fasal Bima Yojana', _getBeneficiaryStatus(data, 'fasal_bima')],
      ['VB Gram G', _getBeneficiaryStatus(data, 'vb_gram')],
      ['Ujjwala Yojana', _getBeneficiaryStatus(data, 'ujjwala_yojana')],
      ['PM Awas Yojana', _getBeneficiaryStatus(data, 'pm_awas')],
      ['Ladli Behna', _getBeneficiaryStatus(data, 'ladli_behna')],
      ['Vridha Pension', _getBeneficiaryStatus(data, 'vridha_pension')],
      ['Widow Pension', _getBeneficiaryStatus(data, 'widow_pension')],
      ['Disability Pension', _getBeneficiaryStatus(data, 'disability_pension')],
    ];
    
    // Print in grid 2 columns
    for (var i = 0; i < generalSchemes.length; i++) {
        var row = generalSchemes[i];
        sheet.cell(CellIndex.indexByString("A${_rowIndex + 1}")).value = TextCellValue(row[0]);
        sheet.cell(CellIndex.indexByString("A${_rowIndex + 1}")).cellStyle = _labelStyle;
        sheet.cell(CellIndex.indexByString("B${_rowIndex + 1}")).value = TextCellValue(row[1]);
        sheet.cell(CellIndex.indexByString("B${_rowIndex + 1}")).cellStyle = _valueStyle;
        _rowIndex++;
    }
    _rowIndex++;

    // 2. Specialized Scheme Tables
    _writeSchemeTable(sheet, "Aadhaar Cards", data['aadhaar_scheme_members']);
    _writeSchemeTable(sheet, "Ayushman Bharat", data['ayushman_scheme_members']);
    _writeSchemeTable(sheet, "Ration Card", data['ration_scheme_members']);
    _writeSchemeTable(sheet, "Pension Schemes", data['pension_scheme_members']);
    _writeSchemeTable(sheet, "Laadli Laxmi", data['laadli_laxmi_scheme_members']);
    _writeSchemeTable(sheet, "Kanyadan / Nikah", data['kanyadan_scheme_members']);
    _writeSchemeTable(sheet, "Maternity Assistance (Prasuti)", data['maternity_scheme_members']);
    _writeSchemeTable(sheet, "Labor Card (Karmkar)", data['labor_scheme_members']);
  }
  
  String _getBeneficiaryStatus(Map<String, dynamic> data, String key) {
    // Check if key exists in general fields
    if (data.containsKey(key)) {
      var val = data[key];
      if (val is List && val.isNotEmpty) {
        val = val.first;
      }
      if (val is Map) return val['is_beneficiary'] == true ? "Yes" : "No";
      if (val is String) return val;
    }

    // Check merged schemes (scheme_data JSON)
    final merged = data['merged_govt_schemes'];
    if (merged is List && merged.isNotEmpty) {
      final row = merged.first;
      final raw = row['scheme_data'];
      if (raw is String && raw.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map && decoded.containsKey(key)) {
            final val = decoded[key];
            if (val is Map) return val['is_beneficiary'] == true ? "Yes" : "No";
            if (val is String) return val;
          }
        } catch (_) {}
      } else if (raw is Map && raw.containsKey(key)) {
        final val = raw[key];
        if (val is Map) return val['is_beneficiary'] == true ? "Yes" : "No";
        if (val is String) return val;
      }
    }
    return "-";
  }

  void _writeSchemeTable(Sheet sheet, String title, dynamic listData) {
    if (listData == null || listData is! List || listData.isEmpty) return;

    _writeSubSectionHeader(sheet, title);
    _writeTableHeader(sheet, ['Member Name', 'Has Card?', 'Benefit Received?', 'Issue Details']);

    for (var item in listData) {
      _writeTableRow(sheet, [
        TextCellValue(item['family_member_name']?.toString() ?? ''),
        TextCellValue(item['have_card']?.toString() ?? ''),
        TextCellValue(item['benefits_received']?.toString() ?? ''),
        TextCellValue("${item['details_correct'] == 'No' ? item['what_incorrect'] : ''} ${item['benefit_stop_reason'] ?? ''}"),
      ]);
    }
    _rowIndex++;
  }

  void _addOtherSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "OTHER DETAILS");
    _writeKeyValuePair(sheet, "Family Disputes:", data['family_disputes']);
    _writeKeyValuePair(sheet, "Revenue Disputes:", data['revenue_disputes']);
    _writeKeyValuePair(sheet, "House Type:", data['house_type']);
    _writeKeyValuePair(sheet, "Voter ID Status:", data['voter_id_status']);
  }

  // --- Low Level Write Helpers ---

  void _writeSectionHeader(Sheet sheet, String title) {
    sheet.merge(CellIndex.indexByString("A${_rowIndex + 1}"), CellIndex.indexByString("E${_rowIndex + 1}"));
    var cell = sheet.cell(CellIndex.indexByString("A${_rowIndex + 1}"));
    cell.value = TextCellValue(title);
    cell.cellStyle = _headerStyle;
    _rowIndex++;
  }
  
  void _writeSubSectionHeader(Sheet sheet, String title) {
    sheet.merge(CellIndex.indexByString("A${_rowIndex + 1}"), CellIndex.indexByString("C${_rowIndex + 1}"));
    var cell = sheet.cell(CellIndex.indexByString("A${_rowIndex + 1}"));
    cell.value = TextCellValue(title);
    cell.cellStyle = _subHeaderStyle;
    _rowIndex++;
  }

  void _writeKeyValuePair(Sheet sheet, String key, dynamic value) {
    var keyCell = sheet.cell(CellIndex.indexByString("A${_rowIndex + 1}"));
    keyCell.value = TextCellValue(key);
    keyCell.cellStyle = _labelStyle;

    var valCell = sheet.cell(CellIndex.indexByString("B${_rowIndex + 1}"));
    valCell.value = TextCellValue(value?.toString() ?? '-');
    valCell.cellStyle = _valueStyle;
    
    // Optional: Merge value cell across for better visibility
    sheet.merge(CellIndex.indexByString("B${_rowIndex + 1}"), CellIndex.indexByString("D${_rowIndex + 1}"));

    _rowIndex++;
  }

  void _writeTableHeader(Sheet sheet, List<String> headers) {
    for (int i = 0; i < headers.length; i++) {
       var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: _rowIndex));
       cell.value = TextCellValue(headers[i]);
       // Create a specific style for table headers instead of copyWith
       cell.cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Left,
          verticalAlign: VerticalAlign.Center,
          backgroundColorHex: ExcelColor.fromHexString('#F0F0F0'),
       );
    }
    _rowIndex++;
  }


  void _writeTableRow(Sheet sheet, List<CellValue> cells) {
      for (int i = 0; i < cells.length; i++) {
       var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: _rowIndex));
       cell.value = cells[i];
       cell.cellStyle = _valueStyle;
    }
    _rowIndex++;
  }

  List<dynamic> _decodeJsonList(dynamic raw) {
    if (raw == null) return [];
    try {
      if (raw is String && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded;
      }
    } catch (_) {}
    return [];
  }

  // --- New Comprehensive Section Methods ---

  void _addFamilyMembersSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "FAMILY MEMBERS DETAILS");

    List<String> headers = ['Name', 'Relation', 'Age', 'Sex', 'Education', 'Occupation', 'Income'];
    _writeTableHeader(sheet, headers);

    if (data['family_members'] != null && data['family_members'] is List) {
      for (var member in data['family_members']) {
        List<CellValue> row = [
          TextCellValue(member['name']?.toString() ?? ''),
          TextCellValue(member['relationship_with_head']?.toString() ?? ''),
          IntCellValue(int.tryParse(member['age']?.toString() ?? '0') ?? 0),
          TextCellValue(member['sex']?.toString() ?? ''),
          TextCellValue(member['educational_qualification']?.toString() ?? ''),
          TextCellValue(member['occupation']?.toString() ?? ''),
          DoubleCellValue(double.tryParse(member['income']?.toString() ?? '0') ?? 0.0),
        ];
        _writeTableRow(sheet, row);
      }
    }
    _rowIndex++;
  }

  void _addGovernmentSchemesSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "GOVERNMENT SCHEMES & BENEFITS");

    // Aadhaar
    _writeSchemeTable(sheet, "Aadhaar Cards", data['aadhaar_scheme_members']);

    // Ayushman Bharat
    _writeSchemeTable(sheet, "Ayushman Bharat", data['ayushman_scheme_members']);

    // Family ID - THIS WAS MISSING!
    _writeSchemeTable(sheet, "Family ID", data['family_id_scheme_members']);

    // Ration Card
    _writeSchemeTable(sheet, "Ration Card", data['ration_scheme_members']);

    // Samagra ID
    _writeSchemeTable(sheet, "Samagra ID", data['samagra_scheme_members']);

    // Tribal Card
    _writeSchemeTable(sheet, "Tribal Card", data['tribal_scheme_members']);

    // Pension Schemes
    _writeSchemeTable(sheet, "Pension Schemes", data['pension_scheme_members']);

    // Widow Allowance
    _writeSchemeTable(sheet, "Widow Allowance", data['widow_scheme_members']);

    // Handicapped Allowance
    _writeSchemeTable(sheet, "Handicapped Allowance", data['handicapped_scheme_members']);

    // VB Gram
    if (data['vb_gram'] != null && data['vb_gram'] is Map) {
      _writeSubSectionHeader(sheet, "VB Gram Membership");
      final vbGram = data['vb_gram'];
      _writeKeyValuePair(sheet, "Is Member:", vbGram['is_member'] ?? '-');
      _writeKeyValuePair(sheet, "Total Members:", vbGram['total_members'] ?? '-');
    }

    _writeSchemeTable(sheet, "VB Gram Members", data['vb_gram_members']);

    // PM Kisan Nidhi
    if (data['pm_kisan_nidhi'] != null && data['pm_kisan_nidhi'] is Map) {
      _writeSubSectionHeader(sheet, "PM Kisan Nidhi");
      final pmKisan = data['pm_kisan_nidhi'];
      _writeKeyValuePair(sheet, "Is Beneficiary:", pmKisan['is_beneficiary'] ?? '-');
      _writeKeyValuePair(sheet, "Total Members:", pmKisan['total_members'] ?? '-');
    }

    _writeSchemeTable(sheet, "PM Kisan Members", data['pm_kisan_members']);

    // PM Kisan Samman Nidhi
    if (data['pm_kisan_samman_nidhi'] != null && data['pm_kisan_samman_nidhi'] is Map) {
      _writeSubSectionHeader(sheet, "PM Kisan Samman Nidhi");
      final pmSamman = data['pm_kisan_samman_nidhi'];
      _writeKeyValuePair(sheet, "Is Beneficiary:", pmSamman['is_beneficiary'] ?? '-');
      _writeKeyValuePair(sheet, "Total Members:", pmSamman['total_members'] ?? '-');
    }

    _writeSchemeTable(sheet, "PM Kisan Samman Members", data['pm_kisan_samman_members']);
  }

  void _addSocialConsciousnessSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "SOCIAL CONSCIOUSNESS");

    if (data['social_consciousness'] != null && data['social_consciousness'] is Map) {
      final sc = data['social_consciousness'];
      _writeKeyValuePair(sheet, "Clothes Purchase Frequency:", sc['clothes_frequency']);
      _writeKeyValuePair(sheet, "Food Waste Level:", sc['food_waste_amount']);
      _writeKeyValuePair(sheet, "Waste Disposal Method:", sc['waste_disposal']);
      _writeKeyValuePair(sheet, "Separate Waste Collection:", sc['separate_waste']);
      _writeKeyValuePair(sheet, "LED Lights Usage:", sc['led_lights']);
      _writeKeyValuePair(sheet, "Family Prayers:", sc['family_prayers']);
      _writeKeyValuePair(sheet, "Family Meditation:", sc['family_meditation']);
      _writeKeyValuePair(sheet, "Family Yoga:", sc['family_yoga']);
      _writeKeyValuePair(sheet, "Addiction Issues:", _formatAddictions(sc));
    }
    _rowIndex++;
  }

  void _addTrainingSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "TRAINING & GROUP MEMBERSHIPS");

    // Training Data
    _writeSubSectionHeader(sheet, "Training Programs");
    List<String> trainingHeaders = ['Member Name', 'Training Topic', 'Duration', 'Date'];
    _writeTableHeader(sheet, trainingHeaders);

    if (data['training_data'] != null && data['training_data'] is List) {
      for (var training in data['training_data']) {
        _writeTableRow(sheet, [
          TextCellValue(training['member_name']?.toString() ?? ''),
          TextCellValue(training['training_topic']?.toString() ?? ''),
          TextCellValue(training['training_duration']?.toString() ?? ''),
          TextCellValue(training['training_date']?.toString() ?? ''),
        ]);
      }
    }
    _rowIndex++;

    // SHG Members
    _writeSubSectionHeader(sheet, "Self Help Group (SHG) Members");
    List<String> shgHeaders = ['Member Name', 'SHG Name', 'Purpose', 'Monthly Saving'];
    _writeTableHeader(sheet, shgHeaders);

    if (data['shg_members'] != null && data['shg_members'] is List) {
      for (var shg in data['shg_members']) {
        _writeTableRow(sheet, [
          TextCellValue(shg['member_name']?.toString() ?? ''),
          TextCellValue(shg['shg_name']?.toString() ?? ''),
          TextCellValue(shg['purpose']?.toString() ?? ''),
          DoubleCellValue(double.tryParse(shg['monthly_saving']?.toString() ?? '0') ?? 0.0),
        ]);
      }
    }
    _rowIndex++;

    // FPO Members
    _writeSubSectionHeader(sheet, "Farmer Producer Organization (FPO) Members");
    List<String> fpoHeaders = ['Member Name', 'FPO Name', 'Purpose', 'Share Capital'];
    _writeTableHeader(sheet, fpoHeaders);

    if (data['fpo_members'] != null && data['fpo_members'] is List) {
      for (var fpo in data['fpo_members']) {
        _writeTableRow(sheet, [
          TextCellValue(fpo['member_name']?.toString() ?? ''),
          TextCellValue(fpo['fpo_name']?.toString() ?? ''),
          TextCellValue(fpo['purpose']?.toString() ?? ''),
          DoubleCellValue(double.tryParse(fpo['share_capital']?.toString() ?? '0') ?? 0.0),
        ]);
      }
    }
    _rowIndex++;
  }

  void _addFinancialSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "FINANCIAL INFORMATION");

    // Bank Accounts
    _writeSubSectionHeader(sheet, "Bank Accounts");
    List<String> bankHeaders = ['Member Name', 'Account Number', 'Bank Name', 'IFSC Code'];
    _writeTableHeader(sheet, bankHeaders);

    if (data['bank_accounts'] != null && data['bank_accounts'] is List) {
      for (var account in data['bank_accounts']) {
        _writeTableRow(sheet, [
          TextCellValue(account['member_name']?.toString() ?? ''),
          TextCellValue(account['account_number']?.toString() ?? ''),
          TextCellValue(account['bank_name']?.toString() ?? ''),
          TextCellValue(account['ifsc_code']?.toString() ?? ''),
        ]);
      }
    }
    _rowIndex++;
  }

  void _addInfrastructureSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "INFRASTRUCTURE & FACILITIES");

    // House Conditions
    _writeSubSectionHeader(sheet, "House Conditions");
    if (data['house_conditions'] != null && data['house_conditions'] is Map) {
      final house = data['house_conditions'];
      _writeKeyValuePair(sheet, "House Type (Katcha/Pakka):", _formatHouseType(house));
      _writeKeyValuePair(sheet, "Toilet Available:", house['toilet_in_use']);
      _writeKeyValuePair(sheet, "Toilet Condition:", house['toilet_condition']);
    }

    // House Facilities
    _writeSubSectionHeader(sheet, "House Facilities");
    if (data['house_facilities'] != null && data['house_facilities'] is Map) {
      final facilities = data['house_facilities'];
      _writeKeyValuePair(sheet, "Electricity Connection:", facilities['electric_connection']);
      _writeKeyValuePair(sheet, "LPG Gas:", facilities['lpg_gas']);
      _writeKeyValuePair(sheet, "Biogas:", facilities['biogas']);
      _writeKeyValuePair(sheet, "Solar Cooking:", facilities['solar_cooking']);
      _writeKeyValuePair(sheet, "Nutritional Garden:", facilities['nutritional_garden_available']);
      _writeKeyValuePair(sheet, "Tulsi Plants:", facilities['tulsi_plants_available']);
    }

    // Drinking Water
    _writeSubSectionHeader(sheet, "Drinking Water Sources");
    if (data['drinking_water_sources'] != null && data['drinking_water_sources'] is Map) {
      final water = data['drinking_water_sources'];
      _writeKeyValuePair(sheet, "Primary Source:", water['hand_pumps']);
      _writeKeyValuePair(sheet, "Distance to Source:", water['hand_pumps_distance']);
      _writeKeyValuePair(sheet, "Water Quality:", water['hand_pumps_quality']);
    }

    // Entertainment & Transport
    _writeSubSectionHeader(sheet, "Entertainment & Transport");
    if (data['entertainment_facilities'] != null && data['entertainment_facilities'] is Map) {
      final entertainment = data['entertainment_facilities'];
      _writeKeyValuePair(sheet, "Smart Mobile Phones:", entertainment['smart_mobile']);
      _writeKeyValuePair(sheet, "Smart Mobile Count:", entertainment['smart_mobile_count']);
      _writeKeyValuePair(sheet, "Analog Mobile Phones:", entertainment['analog_mobile']);
      _writeKeyValuePair(sheet, "Analog Mobile Count:", entertainment['analog_mobile_count']);
      _writeKeyValuePair(sheet, "Television:", entertainment['television']);
      _writeKeyValuePair(sheet, "Radio:", entertainment['radio']);
      _writeKeyValuePair(sheet, "Games:", entertainment['games']);
      _writeKeyValuePair(sheet, "Other Entertainment:", entertainment['other_entertainment']);
    }

    if (data['transport_facilities'] != null && data['transport_facilities'] is Map) {
      final transport = data['transport_facilities'];
      _writeKeyValuePair(sheet, "Car/Jeep:", transport['car_jeep']);
      _writeKeyValuePair(sheet, "Motorcycle/Scooter:", transport['motorcycle_scooter']);
      _writeKeyValuePair(sheet, "E-rickshaw:", transport['e_rickshaw']);
      _writeKeyValuePair(sheet, "Cycle:", transport['cycle']);
      _writeKeyValuePair(sheet, "Pick-up/Truck:", transport['pickup_truck']);
      _writeKeyValuePair(sheet, "Bullock Cart:", transport['bullock_cart']);
    }

    _rowIndex++;
  }

  void _addOtherInformationSection(Sheet sheet, Map<String, dynamic> data) {
    _writeSectionHeader(sheet, "CHILDREN, MIGRATION & DISPUTES");

    // Children Data
    _writeSubSectionHeader(sheet, "Children Statistics");
    if (data['children_data'] != null && data['children_data'] is Map) {
      final children = data['children_data'];
      _writeKeyValuePair(sheet, "Births (Last 3 Years):", children['births_last_3_years']);
      _writeKeyValuePair(sheet, "Infant Deaths (Last 3 Years):", children['infant_deaths_last_3_years']);
      _writeKeyValuePair(sheet, "Malnourished Children:", children['malnourished_children']);
    }

    // Migration
    _writeSubSectionHeader(sheet, "Migration Data");
    if (data['migration_data'] != null && data['migration_data'] is Map) {
      final migration = data['migration_data'];
      _writeKeyValuePair(sheet, "Family Members Migrated:", migration['family_members_migrated']);
      _writeKeyValuePair(sheet, "Migration Reason:", migration['reason']);
      _writeKeyValuePair(sheet, "Migration Duration:", migration['duration']);
      _writeKeyValuePair(sheet, "Destination:", migration['destination']);

      final members = _decodeJsonList(migration['migrated_members_json']);
      if (members.isNotEmpty) {
        _writeTableHeader(sheet, ['Member Name', 'Permanent Distance', 'Permanent Job', 'Seasonal Distance', 'Seasonal Job', 'Need-based Distance', 'Need-based Job']);
        for (final m in members) {
          if (m is Map) {
            _writeTableRow(sheet, [
              TextCellValue(m['member_name']?.toString() ?? ''),
              TextCellValue(m['permanent_distance']?.toString() ?? ''),
              TextCellValue(m['permanent_job']?.toString() ?? ''),
              TextCellValue(m['seasonal_distance']?.toString() ?? ''),
              TextCellValue(m['seasonal_job']?.toString() ?? ''),
              TextCellValue(m['need_based_distance']?.toString() ?? ''),
              TextCellValue(m['need_based_job']?.toString() ?? ''),
            ]);
          }
        }
      }
    }

    // Disputes
    _writeSubSectionHeader(sheet, "Legal Disputes");
    if (data['disputes'] != null && data['disputes'] is Map) {
      final disputes = data['disputes'];
      _writeKeyValuePair(sheet, "Family Disputes:", disputes['family_disputes']);
      _writeKeyValuePair(sheet, "Revenue Disputes:", disputes['revenue_disputes']);
      _writeKeyValuePair(sheet, "Criminal Disputes:", disputes['criminal_disputes']);
      _writeKeyValuePair(sheet, "Family Registered:", disputes['family_registered']);
      _writeKeyValuePair(sheet, "Family Period:", disputes['family_period']);
      _writeKeyValuePair(sheet, "Revenue Registered:", disputes['revenue_registered']);
      _writeKeyValuePair(sheet, "Revenue Period:", disputes['revenue_period']);
      _writeKeyValuePair(sheet, "Criminal Registered:", disputes['criminal_registered']);
      _writeKeyValuePair(sheet, "Criminal Period:", disputes['criminal_period']);
      _writeKeyValuePair(sheet, "Other Disputes:", disputes['other_disputes']);
      _writeKeyValuePair(sheet, "Other Description:", disputes['other_description']);
      _writeKeyValuePair(sheet, "Other Registered:", disputes['other_registered']);
      _writeKeyValuePair(sheet, "Other Period:", disputes['other_period']);
    }

    // Folklore Medicine
    _writeSubSectionHeader(sheet, "Traditional Medicine Knowledge");
    List<String> folkloreHeaders = ['Person Name', 'Plant Name', 'Botanical Name', 'Uses'];
    _writeTableHeader(sheet, folkloreHeaders);

    if (data['folklore_medicine'] != null && data['folklore_medicine'] is List) {
      for (var medicine in data['folklore_medicine']) {
        _writeTableRow(sheet, [
          TextCellValue(medicine['person_name']?.toString() ?? ''),
          TextCellValue(medicine['plant_local_name']?.toString() ?? ''),
          TextCellValue(medicine['plant_botanical_name']?.toString() ?? ''),
          TextCellValue(medicine['uses']?.toString() ?? ''),
        ]);
      }
    }

    _rowIndex++;
  }

  // --- Helper Methods ---

  String _formatAddictions(Map<String, dynamic> sc) {
    List<String> addictions = [];
    if (sc['addiction_smoke'] == 'yes') addictions.add('Smoking');
    if (sc['addiction_drink'] == 'yes') addictions.add('Drinking');
    if (sc['addiction_gutka'] == 'yes') addictions.add('Gutka');
    if (sc['addiction_gamble'] == 'yes') addictions.add('Gambling');
    if (sc['addiction_tobacco'] == 'yes') addictions.add('Tobacco');
    return addictions.isEmpty ? 'None' : addictions.join(', ');
  }

  String _formatHouseType(Map<String, dynamic> house) {
    List<String> types = [];
    if (house['katcha'] == 'yes') types.add('Katcha');
    if (house['pakka'] == 'yes') types.add('Pakka');
    if (house['katcha_pakka'] == 'yes') types.add('Katcha-Pakka');
    if (house['hut'] == 'yes') types.add('Hut');
    return types.isEmpty ? 'Not specified' : types.join(', ');
  }

  int _estimateRowCount(Map<String, dynamic> data) {
    int count = 50; // base rows for headers/sections
    for (final entry in data.entries) {
      final value = entry.value;
      if (value is List) {
        count += value.length + 2;
      } else if (value is Map) {
        count += value.length > 10 ? 5 : 2;
      }
    }
    return count;
  }

  String _safeFileName(String fileName) {
    final sanitized = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return sanitized.replaceAll(RegExp(r'\s+'), '_');
  }

  Future<void> _saveExcelFile(Excel excel, String fileName) async {
    try {
      final safeName = _safeFileName(fileName);
      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Excel encoding failed (empty bytes)');
      }
      final data = Uint8List.fromList(fileBytes);

      if (Platform.isAndroid || Platform.isIOS) {
        await FilePicker.platform.saveFile(
          dialogTitle: 'Save Complete Survey Report',
          fileName: safeName,
          bytes: data,
        );
      } else {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Complete Survey Report',
          fileName: safeName,
        );

        if (outputFile != null) {
          if (!outputFile.endsWith('.xlsx')) {
            outputFile += '.xlsx';
          }
          File(outputFile)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        }
      }
    } catch (e) {
      throw Exception('Failed to save Excel file: $e');
    }
  }
}
