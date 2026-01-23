import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';

class XlsxExportService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> exportSurveyToXlsx(String sessionId, String fileName) async {
    try {
      // Get survey data from database
      final surveyData = await _dbService.getSurveySession(sessionId);
      if (surveyData == null) {
        throw Exception('Survey session not found');
      }

      // Get all related data
      final familyMembers = await _dbService.getData('family_members', sessionId);
      final landHolding = await _dbService.getData('land_holding', sessionId);
      final irrigation = await _dbService.getData('irrigation_facilities', sessionId);
      final crops = await _dbService.getData('crop_productivity', sessionId);
      final fertilizer = await _dbService.getData('fertilizer_usage', sessionId);
      final animals = await _dbService.getData('animals', sessionId);
      final equipment = await _dbService.getData('agricultural_equipment', sessionId);
      final entertainment = await _dbService.getData('entertainment_facilities', sessionId);
      final transport = await _dbService.getData('transport_facilities', sessionId);
      final waterSources = await _dbService.getData('drinking_water_sources', sessionId);
      final medical = await _dbService.getData('medical_treatment', sessionId);
      final disputes = await _dbService.getData('disputes', sessionId);
      final houseConditions = await _dbService.getData('house_conditions', sessionId);
      final houseFacilities = await _dbService.getData('house_facilities', sessionId);
      final garden = await _dbService.getData('nutritional_garden', sessionId);
      final diseases = await _dbService.getData('diseases', sessionId);
      final socialConsciousness = await _dbService.getData('social_consciousness', sessionId);

      // Create Excel workbook
      final excel = Excel.createExcel();
      final sheet = excel['Family Survey'];

      // Add headers
      sheet.appendRow([
        TextCellValue('Section'),
        TextCellValue('Field'),
        TextCellValue('Value'),
      ]);

      // Add survey session data
      sheet.appendRow([
        TextCellValue('Survey Information'),
        TextCellValue('Session ID'),
        TextCellValue(sessionId)
      ]);
      surveyData.forEach((key, value) {
        if (key != 'session_id') {
          sheet.appendRow([
            TextCellValue('Survey Information'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        }
      });

      // Add family members
      if (familyMembers.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Family Members'),
          TextCellValue('Name'),
          TextCellValue('Age'),
          TextCellValue('Gender'),
          TextCellValue('Relation'),
          TextCellValue('Education'),
          TextCellValue('Occupation')
        ]);
        for (final member in familyMembers) {
          sheet.appendRow([
            TextCellValue('Family Members'),
            TextCellValue(member['name'] ?? ''),
            TextCellValue(member['age'] ?? ''),
            TextCellValue(member['gender'] ?? ''),
            TextCellValue(member['relation'] ?? ''),
            TextCellValue(member['education'] ?? ''),
            TextCellValue(member['occupation'] ?? ''),
          ]);
        }
      }

      // Add land holding
      if (landHolding.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Land Holding'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        landHolding.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('Land Holding'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add irrigation
      if (irrigation.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Irrigation Facilities'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        irrigation.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('Irrigation Facilities'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add crops
      if (crops.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Crop Productivity'),
          TextCellValue('Crop Name'),
          TextCellValue('Area'),
          TextCellValue('Production'),
          TextCellValue('Productivity')
        ]);
        for (final crop in crops) {
          sheet.appendRow([
            TextCellValue('Crop Productivity'),
            TextCellValue(crop['crop_name'] ?? ''),
            TextCellValue(crop['area'] ?? ''),
            TextCellValue(crop['production'] ?? ''),
            TextCellValue(crop['productivity'] ?? ''),
          ]);
        }
      }

      // Add fertilizer
      if (fertilizer.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Fertilizer Usage'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        fertilizer.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('Fertilizer Usage'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add animals
      if (animals.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Animals'),
          TextCellValue('Type'),
          TextCellValue('Count'),
          TextCellValue('Purpose')
        ]);
        for (final animal in animals) {
          sheet.appendRow([
            TextCellValue('Animals'),
            TextCellValue(animal['animal_type'] ?? ''),
            TextCellValue(animal['count'] ?? ''),
            TextCellValue(animal['purpose'] ?? ''),
          ]);
        }
      }

      // Add equipment
      if (equipment.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Agricultural Equipment'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        equipment.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('Agricultural Equipment'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add entertainment
      if (entertainment.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Entertainment Facilities'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        entertainment.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('Entertainment Facilities'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add transport
      if (transport.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Transport Facilities'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        transport.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('Transport Facilities'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add water sources
      if (waterSources.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Drinking Water Sources'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        waterSources.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('Drinking Water Sources'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add medical
      if (medical.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Medical Treatment'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        medical.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('Medical Treatment'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add disputes
      if (disputes.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Disputes'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        disputes.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('Disputes'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add house conditions
      if (houseConditions.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('House Conditions'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        houseConditions.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('House Conditions'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add house facilities
      if (houseFacilities.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('House Facilities'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        houseFacilities.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('House Facilities'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add garden
      if (garden.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Nutritional Garden'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        garden.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('Nutritional Garden'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Add diseases
      if (diseases.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Diseases'),
          TextCellValue('Disease'),
          TextCellValue('Affected Members'),
          TextCellValue('Treatment')
        ]);
        for (final disease in diseases) {
          sheet.appendRow([
            TextCellValue('Diseases'),
            TextCellValue(disease['disease_name'] ?? ''),
            TextCellValue(disease['affected_members'] ?? ''),
            TextCellValue(disease['treatment'] ?? ''),
          ]);
        }
      }

      // Add social consciousness
      if (socialConsciousness.isNotEmpty) {
        sheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        sheet.appendRow([
          TextCellValue('Social Consciousness'),
          TextCellValue('Field'),
          TextCellValue('Value')
        ]);
        socialConsciousness.first.forEach((key, value) {
          sheet.appendRow([
            TextCellValue('Social Consciousness'),
            TextCellValue(key),
            TextCellValue(value?.toString() ?? '')
          ]);
        });
      }

      // Save file
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);

      print('XLSX file saved to: ${file.path}');
    } catch (e) {
      print('Error exporting to XLSX: $e');
      rethrow;
    }
  }
}
