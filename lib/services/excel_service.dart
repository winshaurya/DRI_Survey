import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class ExcelService {
  static final ExcelService _instance = ExcelService._internal();

  factory ExcelService() {
    return _instance;
  }

  ExcelService._internal();

  // Cell Styles
  final CellStyle _headerStyle = CellStyle(
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    backgroundColorHex: ExcelColor.fromHexString('#D3D3D3'), // Light Grey
    fontFamily: getFontFamily(FontFamily.Arial),
  );

  final CellStyle _subHeaderStyle = CellStyle(
    bold: true,
    horizontalAlign: HorizontalAlign.Left,
    verticalAlign: VerticalAlign.Center,
    backgroundColorHex: ExcelColor.fromHexString('#EFEFEF'), // Lighter Grey
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

  Future<void> exportSurveyToExcel(Map<String, dynamic> surveyData) async {
    var excel = Excel.createExcel();
    
    // Rename default sheet or use a new one
    String sheetName = 'Survey Report';
    if (excel.sheets.containsKey('Sheet1')) {
      excel.rename('Sheet1', sheetName);
    } 
    
    Sheet sheet = excel[sheetName];
    _rowIndex = 0; // Reset row index

    // --- 1. Report Header (Location Info) ---
    _addReportHeader(sheet, surveyData);
    
    // --- 2. Family Members ---
    _addFamilySection(sheet, surveyData);
    
    // --- 3. Agriculture ---
    _addAgricultureSection(sheet, surveyData);
    
    // 4. Livestock & Assets
    _addLivestockSection(sheet, surveyData);
    
    // 5. Health Details
    _addHealthSection(sheet, surveyData);
    
    // 6. Social Schemes
    _addSchemesSection(sheet, surveyData);

    // 7. Other Details
    _addOtherSection(sheet, surveyData);

    // Save
    var fileBytes = excel.save();
    if (fileBytes == null) return;
    Uint8List data = Uint8List.fromList(fileBytes);

    String fileName = 'survey_${surveyData['village_name'] ?? 'export'}_${surveyData['head_of_family'] ?? 'family'}.xlsx';
    
    if (Platform.isAndroid || Platform.isIOS) {
       await FilePicker.platform.saveFile(
        dialogTitle: 'Save Survey Report',
        fileName: fileName,
        bytes: data,
      );
    } else {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Survey Report',
        fileName: fileName,
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
          TextCellValue(member['relationship']?.toString() ?? ''),
          IntCellValue(int.tryParse(member['age']?.toString() ?? '0') ?? 0),
          TextCellValue(member['sex']?.toString() ?? ''),
          TextCellValue(member['education']?.toString() ?? ''),
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
     _writeKeyValuePair(sheet, "Irrigated Land:", data['irrigated_land']);
     _writeKeyValuePair(sheet, "Unirrigated Land:", data['unirrigated_land']);
     _writeKeyValuePair(sheet, "Barren Land:", data['barren_land']);
     _rowIndex++;

    // Crops
    _writeSubSectionHeader(sheet, "Crops Production");
    List<String> cropHeaders = ['Crop Name', 'Area (Acres)', 'Production (Q)', 'Sold (Q)', 'Rate (Rs)'];
    _writeTableHeader(sheet, cropHeaders);
    
    if (data['crops'] != null && data['crops'] is List) {
      for (var crop in data['crops']) {
        _writeTableRow(sheet, [
          TextCellValue(crop['crop_name']?.toString() ?? ''),
          DoubleCellValue(double.tryParse(crop['area']?.toString() ?? '0') ?? 0),
          DoubleCellValue(double.tryParse(crop['production']?.toString() ?? '0') ?? 0),
          DoubleCellValue(double.tryParse(crop['quantity_sold']?.toString() ?? '0') ?? 0),
          DoubleCellValue(double.tryParse(crop['rate']?.toString() ?? '0') ?? 0),
        ]);
      }
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
          IntCellValue(int.tryParse(x['count']?.toString() ?? '0') ?? 0),
          TextCellValue(x['breed']?.toString() ?? ''),
          DoubleCellValue(double.tryParse(x['milk_production']?.toString() ?? '0') ?? 0),
        ]);
      }
    }
    
    // Farm Equipment (Simple List)
    _rowIndex++;
    _writeSubSectionHeader(sheet, "Farm Equipment");
    List<String> equipments = [];
    if (data['tractor'] != null && data['tractor'].toString().isNotEmpty) equipments.add("Tractor: ${data['tractor']}");
    if (data['pump_set'] != null && data['pump_set'].toString().isNotEmpty) equipments.add("Pump Set: ${data['pump_set']}");
    if (data['thresher'] != null && data['thresher'].toString().isNotEmpty) equipments.add("Thresher: ${data['thresher']}");
    if (data['sprayer'] != null && data['sprayer'].toString().isNotEmpty) equipments.add("Sprayer: ${data['sprayer']}");
    
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
      ['PM Kisan Samman Nidhi', _getBeneficiaryStatus(data, 'pm_kisan_samman_nidhi')],
      ['Kisan Credit Card', _getBeneficiaryStatus(data, 'kisan_credit_card')],
      ['Swachh Bharat Mission', _getBeneficiaryStatus(data, 'swachh_bharat_mission')],
      ['Fasal Bima Yojana', _getBeneficiaryStatus(data, 'fasal_bima')],
      ['VB Gram G', _getBeneficiaryStatus(data, 'vb_gram_g')],
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
    // Check if key exists in general fields or in beneficiary_programs list
    if (data.containsKey(key)) {
       var val = data[key];
       if (val is Map) return val['is_beneficiary'] == true ? "Yes" : "No";
       if (val is String) return val;
    }
    // Also check the generic 'beneficiary_programs' list for program_type == key
    if (data['beneficiary_programs'] != null && data['beneficiary_programs'] is List) {
      for (var p in data['beneficiary_programs']) {
        if (p['program_type'] == key) {
           return (p['beneficiary'] == 1 || p['beneficiary'] == true) ? "Yes" : "No";
        }
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
}
