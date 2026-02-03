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

  Future<void> exportSurveyToExcel(Map<String, dynamic> surveyData) async {
    var excel = Excel.createExcel();

    // Remove the default sheet
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    _createSummarySheet(excel, surveyData);
    _createFamilySheet(excel, surveyData);
    _createAgricultureSheet(excel, surveyData);
    _createLivestockAssetsSheet(excel, surveyData);
    _createHealthSheet(excel, surveyData);
    _createSocialSchemesSheet(excel, surveyData);
    _createOtherSheet(excel, surveyData);

    var fileBytes = excel.save();
    if (fileBytes == null) return;
    Uint8List data = Uint8List.fromList(fileBytes);

    if (Platform.isAndroid || Platform.isIOS) {
       await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'family_survey_${surveyData['village_name'] ?? 'export'}_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        bytes: data,
      );
    } else {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'family_survey_${surveyData['village_name'] ?? 'export'}_${DateTime.now().millisecondsSinceEpoch}.xlsx',
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

  void _createSummarySheet(Excel excel, Map<String, dynamic> data) {
    Sheet sheet = excel['Summary'];
    _addHeader(sheet, ['Field', 'Value']);

    List<List<String>> rows = [
      ['Surveyor Name', data['surveyor_name']?.toString() ?? ''],
      ['Surveyor Email', data['surveyor_email']?.toString() ?? ''],
      ['Phone Number', data['phone_number']?.toString() ?? ''],
      ['Village Name', data['village_name']?.toString() ?? ''],
      ['Village Number', data['village_number']?.toString() ?? ''],
      ['Panchayat', data['panchayat']?.toString() ?? ''],
      ['Block', data['block']?.toString() ?? ''],
      ['Tehsil', data['tehsil']?.toString() ?? ''],
      ['District', data['district']?.toString() ?? ''],
      ['Postal Address', data['postal_address']?.toString() ?? ''],
      ['Pin Code', data['pin_code']?.toString() ?? ''],
      ['Survey Date', data['survey_date']?.toString() ?? ''],
    ];

    for (var row in rows) {
      sheet.appendRow(row.map((e) => TextCellValue(e)).toList());
    }
    
    // Auto-fit columns (approximation)
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 50);
  }

  void _createFamilySheet(Excel excel, Map<String, dynamic> data) {
    Sheet sheet = excel['Family Members'];
    List<String> headers = [
      'Name', 'Father\'s Name', 'Mother\'s Name', 'Relation', 'Age', 
      'Sex', 'Education', 'Occupation', 'Income', 'Marital Status', 
      'Physically Fit', 'Fit Cause'
    ];
    _addHeader(sheet, headers);

    if (data['family_members'] != null) {
      for (var member in data['family_members']) {
        List<CellValue> row = [
          TextCellValue(member['name']?.toString() ?? ''),
          TextCellValue(member['fathers_name']?.toString() ?? ''),
          TextCellValue(member['mothers_name']?.toString() ?? ''),
          TextCellValue(member['relationship']?.toString() ?? ''),
          IntCellValue(int.tryParse(member['age']?.toString() ?? '0') ?? 0),
          TextCellValue(member['sex']?.toString() ?? ''),
          TextCellValue(member['education']?.toString() ?? ''),
          TextCellValue(member['occupation']?.toString() ?? ''),
          DoubleCellValue(double.tryParse(member['income']?.toString() ?? '0.0') ?? 0.0),
          TextCellValue(member['marital_status']?.toString() ?? ''),
          TextCellValue(member['physically_fit']?.toString() ?? ''),
          TextCellValue(member['physically_fit_cause']?.toString() ?? ''),
        ];
        sheet.appendRow(row);
      }
    }
  }

  void _createAgricultureSheet(Excel excel, Map<String, dynamic> data) {
    Sheet sheet = excel['Agriculture'];
    
    // Land Holding Section
    sheet.appendRow([TextCellValue('LAND HOLDING DETAILS')]);
    _addHeader(sheet, ['Type', 'Area (Acres)']);
    sheet.appendRow([TextCellValue('Irrigated'), DoubleCellValue(double.tryParse(data['irrigated_land']?.toString() ?? '0') ?? 0)]);
    sheet.appendRow([TextCellValue('Unirrigated'), DoubleCellValue(double.tryParse(data['unirrigated_land']?.toString() ?? '0') ?? 0)]);
    sheet.appendRow([TextCellValue('Barren'), DoubleCellValue(double.tryParse(data['barren_land']?.toString() ?? '0') ?? 0)]);
    sheet.appendRow([]); // Empty row

    // Crops Section
    sheet.appendRow([TextCellValue('CROP PRODUCTIVITY')]);
    _addHeader(sheet, ['Crop Name', 'Area', 'Production (Quintal)', 'Sold (Quintal)', 'Rate']);
    if (data['crops'] != null) {
      for (var crop in data['crops']) {
        sheet.appendRow([
          TextCellValue(crop['crop_name']?.toString() ?? ''),
          DoubleCellValue(double.tryParse(crop['area']?.toString() ?? '0') ?? 0),
          DoubleCellValue(double.tryParse(crop['production']?.toString() ?? '0') ?? 0),
          DoubleCellValue(double.tryParse(crop['quantity_sold']?.toString() ?? '0') ?? 0),
          DoubleCellValue(double.tryParse(crop['rate']?.toString() ?? '0') ?? 0),
        ]);
      }
    }
  }

  void _createLivestockAssetsSheet(Excel excel, Map<String, dynamic> data) {
    Sheet sheet = excel['Livestock & Assets'];

    // Animals
    sheet.appendRow([TextCellValue('ANIMALS')]);
    _addHeader(sheet, ['Animal Type', 'Count', 'Breed', 'Milk Production']);
    if (data['animals'] != null) {
      for (var animal in data['animals']) {
        sheet.appendRow([
          TextCellValue(animal['animal_type']?.toString() ?? ''),
          IntCellValue(int.tryParse(animal['count']?.toString() ?? '0') ?? 0),
          TextCellValue(animal['breed']?.toString() ?? ''),
          DoubleCellValue(double.tryParse(animal['milk_production']?.toString() ?? '0') ?? 0),
        ]);
      }
    }
    sheet.appendRow([]);

    // Equipments
    sheet.appendRow([TextCellValue('EQUIPMENTS')]);
    // Assuming flat structure for equipment or map logic. Adjusting based on generalized data
    List<String> equipmentKeys = ['tractor', 'thresher', 'seed_drill', 'sprayer', 'duster', 'pump_set'];
    for (var key in equipmentKeys) {
       if (data.containsKey(key)) {
         sheet.appendRow([TextCellValue(key.toUpperCase()), TextCellValue(data[key]?.toString() ?? '')]);
       }
    }
  }

  void _createHealthSheet(Excel excel, Map<String, dynamic> data) {
    Sheet sheet = excel['Health'];
    
    // Diseases
    sheet.appendRow([TextCellValue('DISEASES')]);
    _addHeader(sheet, ['Family Member', 'Disease Name', 'Since When', 'Treatment Type']);
    if (data['diseases'] != null) {
      for (var disease in data['diseases']) {
        sheet.appendRow([
          TextCellValue(disease['member_name']?.toString() ?? ''),
          TextCellValue(disease['disease_name']?.toString() ?? ''),
          TextCellValue(disease['duration']?.toString() ?? ''),
          TextCellValue(disease['treatment_type']?.toString() ?? ''),
        ]);
      }
    }
    sheet.appendRow([]);
    
    // Malnourished Children
    sheet.appendRow([TextCellValue('MALNOURISHED CHILDREN')]);
    _addHeader(sheet, ['Child Name', 'Age', 'Weight', 'Height', 'Grade']);
    if (data['malnourished_children_data'] != null) {
       for (var child in data['malnourished_children_data']) {
         sheet.appendRow([
           TextCellValue(child['name']?.toString() ?? ''),
           IntCellValue(int.tryParse(child['age']?.toString() ?? '0') ?? 0),
           DoubleCellValue(double.tryParse(child['weight']?.toString() ?? '0') ?? 0),
           DoubleCellValue(double.tryParse(child['height']?.toString() ?? '0') ?? 0),
           TextCellValue(child['grade']?.toString() ?? ''),
         ]);
       }
    }
  }

  void _createSocialSchemesSheet(Excel excel, Map<String, dynamic> data) {
     Sheet sheet = excel['Social & Schemes'];
     
     // General Schemes Status (Booleans usually)
     List<String> schemes = ['vb_g_ram_g', 'pm_kisan', 'kisan_credit_card', 'swachh_bharat', 'fasal_bima', 'ayushman_bharat'];
     
     _addHeader(sheet, ['Scheme Name', 'Status/Beneficiary']);
     for (var scheme in schemes) {
       sheet.appendRow([
         TextCellValue(scheme.replaceAll('_', ' ').toUpperCase()), 
         TextCellValue(data[scheme]?.toString() ?? 'No')
       ]);
     }
  }

  void _createOtherSheet(Excel excel, Map<String, dynamic> data) {
    Sheet sheet = excel['Other Details'];
    
    // Disputes
    sheet.appendRow([TextCellValue('DISPUTES')]);
    sheet.appendRow([TextCellValue('Family Disputes'), TextCellValue(data['family_disputes']?.toString() ?? '')]);
    sheet.appendRow([TextCellValue('Revenue Disputes'), TextCellValue(data['revenue_disputes']?.toString() ?? '')]);
    
    // House
    sheet.appendRow([]);
    sheet.appendRow([TextCellValue('HOUSE CONDITION')]);
    sheet.appendRow([TextCellValue('House Type'), TextCellValue(data['house_type']?.toString() ?? '')]);
    sheet.appendRow([TextCellValue('Toilet'), TextCellValue(data['toilet']?.toString() ?? '')]);
  }

  void _addHeader(Sheet sheet, List<String> headers) {
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());
    
    // Style the header row (bold) - Excel package rudimentary styling
    // Currently package 'excel' doesn't support extensive styling easily in the free version in the same way, 
    // but the data structure is what matters most for the template.
  }
}
