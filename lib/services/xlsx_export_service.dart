import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
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

      // Create Excel workbook matching questionnaire format
      final excel = Excel.createExcel();
      final sheet = excel['Family Survey'];

      // Set column widths for better readability
      sheet.setColumnWidth(0, 40); // Question column
      sheet.setColumnWidth(1, 30); // Response column

      int currentRow = 0;

      // Header
      sheet.appendRow([TextCellValue('FAMILY SURVEY QUESTIONNAIRE')]);
      currentRow++;
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // Location Information Section
      sheet.appendRow([TextCellValue('LOCATION INFORMATION'), TextCellValue('')]);
      currentRow++;
      sheet.appendRow([TextCellValue('1. Village Name'), TextCellValue(surveyData['village_name'] ?? '')]);
      currentRow++;
      sheet.appendRow([TextCellValue('2. Panchayat'), TextCellValue(surveyData['panchayat'] ?? '')]);
      currentRow++;
      sheet.appendRow([TextCellValue('3. Block'), TextCellValue(surveyData['block'] ?? '')]);
      currentRow++;
      sheet.appendRow([TextCellValue('4. District'), TextCellValue(surveyData['district'] ?? '')]);
      currentRow++;
      sheet.appendRow([TextCellValue('5. Postal Address'), TextCellValue(surveyData['postal_address'] ?? '')]);
      currentRow++;
      sheet.appendRow([TextCellValue('6. PIN Code'), TextCellValue(surveyData['pin_code'] ?? '')]);
      currentRow++;
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // Family Details Section
      sheet.appendRow([TextCellValue('FAMILY DETAILS'), TextCellValue('')]);
      currentRow++;

      if (familyMembers.isNotEmpty) {
        for (int i = 0; i < familyMembers.length; i++) {
          final member = familyMembers[i];
          sheet.appendRow([TextCellValue('Member ${i + 1}'), TextCellValue('')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Name'), TextCellValue(member['name'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Age'), TextCellValue(member['age'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Sex'), TextCellValue(member['sex'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Relationship with Head'), TextCellValue(member['relationship_with_head'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Educational Qualification'), TextCellValue(member['educational_qualification'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Occupation'), TextCellValue(member['occupation'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Days Employed'), TextCellValue(member['days_employed'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Income'), TextCellValue(member['income'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Awareness about Village'), TextCellValue(member['awareness_about_village'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Participate in Gram Sabha'), TextCellValue(member['participate_gram_sabha'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('')]);
          currentRow++;
        }
      }

      // Land Holding Section
      sheet.appendRow([TextCellValue('LAND HOLDING'), TextCellValue('')]);
      currentRow++;
      if (landHolding.isNotEmpty) {
        final land = landHolding.first;
        sheet.appendRow([TextCellValue('7. Irrigated Area (Acres)'), TextCellValue(land['irrigated_area'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('8. Cultivable Area (Acres)'), TextCellValue(land['cultivable_area'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('9. Orchard Plants'), TextCellValue(land['orchard_plants'] ?? '')]);
        currentRow++;
      }
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // Irrigation Facilities Section
      sheet.appendRow([TextCellValue('IRRIGATION FACILITIES'), TextCellValue('')]);
      currentRow++;
      if (irrigation.isNotEmpty) {
        final irr = irrigation.first;
        sheet.appendRow([TextCellValue('10. Canal'), TextCellValue(irr['canal'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('11. Tube Well'), TextCellValue(irr['tube_well'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('12. Ponds'), TextCellValue(irr['ponds'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('13. Other Facilities'), TextCellValue(irr['other_facilities'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('14. Primary Water Source'), TextCellValue(irr['primary_water_source'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('15. Distance from Water Source'), TextCellValue(irr['water_source_distance'] ?? '')]);
        currentRow++;
      }
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // Crop Productivity Section
      sheet.appendRow([TextCellValue('CROP PRODUCTIVITY'), TextCellValue('')]);
      currentRow++;
      if (crops.isNotEmpty) {
        for (int i = 0; i < crops.length; i++) {
          final crop = crops[i];
          sheet.appendRow([TextCellValue('Crop ${i + 1}'), TextCellValue('')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Crop Name'), TextCellValue(crop['crop_name'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Area (Acres)'), TextCellValue(crop['area_acres'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Productivity (Qtl/Acre)'), TextCellValue(crop['productivity_quintal_per_acre'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Total Production'), TextCellValue(crop['total_production'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Quantity Consumed'), TextCellValue(crop['quantity_consumed'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Quantity Sold'), TextCellValue(crop['quantity_sold'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('')]);
          currentRow++;
        }
      }

      // Fertilizer Usage Section
      sheet.appendRow([TextCellValue('FERTILIZER USAGE'), TextCellValue('')]);
      currentRow++;
      if (fertilizer.isNotEmpty) {
        final fert = fertilizer.first;
        sheet.appendRow([TextCellValue('16. Chemical Fertilizer'), TextCellValue(fert['chemical_fertilizer'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('17. Organic Fertilizer'), TextCellValue(fert['organic_fertilizer'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('18. Fertilizer Types'), TextCellValue(fert['fertilizer_types'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('19. Annual Expenditure (₹)'), TextCellValue(fert['fertilizer_expenditure'] ?? '')]);
        currentRow++;
      }
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // Animals Section
      sheet.appendRow([TextCellValue('ANIMALS/LIVESTOCK'), TextCellValue('')]);
      currentRow++;
      if (animals.isNotEmpty) {
        for (int i = 0; i < animals.length; i++) {
          final animal = animals[i];
          sheet.appendRow([TextCellValue('Animal ${i + 1}'), TextCellValue('')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Type'), TextCellValue(animal['animal_type'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Number of Animals'), TextCellValue(animal['number_of_animals'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Breed'), TextCellValue(animal['breed'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Production per Animal'), TextCellValue(animal['production_per_animal'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Quantity Sold'), TextCellValue(animal['quantity_sold'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('')]);
          currentRow++;
        }
      }

      // Agricultural Equipment Section
      sheet.appendRow([TextCellValue('AGRICULTURAL EQUIPMENT'), TextCellValue('')]);
      currentRow++;
      if (equipment.isNotEmpty) {
        final equip = equipment.first;
        sheet.appendRow([TextCellValue('20. Tractor'), TextCellValue(equip['tractor'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('21. Thresher'), TextCellValue(equip['thresher'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('22. Seed Drill'), TextCellValue(equip['seed_drill'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('23. Sprayer'), TextCellValue(equip['sprayer'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('24. Duster'), TextCellValue(equip['duster'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('25. Diesel Engine'), TextCellValue(equip['diesel_engine'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('26. Other Equipment'), TextCellValue(equip['other_equipment'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('27. Equipment Condition'), TextCellValue(equip['equipment_condition'] ?? '')]);
        currentRow++;
      }
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // Entertainment Facilities Section
      sheet.appendRow([TextCellValue('ENTERTAINMENT FACILITIES'), TextCellValue('')]);
      currentRow++;
      if (entertainment.isNotEmpty) {
        final ent = entertainment.first;
        sheet.appendRow([TextCellValue('28. Smart Mobile'), TextCellValue(ent['smart_mobile'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('29. Analog Mobile'), TextCellValue(ent['analog_mobile'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('30. Television'), TextCellValue(ent['television'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('31. Radio'), TextCellValue(ent['radio'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('32. Games'), TextCellValue(ent['games'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('33. Other Entertainment'), TextCellValue(ent['other_entertainment'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('34. Monthly Expenditure (₹)'), TextCellValue(ent['entertainment_expenditure'] ?? '')]);
        currentRow++;
      }
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // Transport Facilities Section
      sheet.appendRow([TextCellValue('TRANSPORT FACILITIES'), TextCellValue('')]);
      currentRow++;
      if (transport.isNotEmpty) {
        final trans = transport.first;
        sheet.appendRow([TextCellValue('35. Car/Jeep'), TextCellValue(trans['car_jeep'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('36. Motorcycle/Scooter'), TextCellValue(trans['motorcycle_scooter'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('37. E-Rickshaw'), TextCellValue(trans['e_rickshaw'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('38. Cycle'), TextCellValue(trans['cycle'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('39. Pickup Truck'), TextCellValue(trans['pickup_truck'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('40. Bullock Cart'), TextCellValue(trans['bullock_cart'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('41. Other Transport'), TextCellValue(trans['other_transport'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('42. Distance to Market'), TextCellValue(trans['market_distance'] ?? '')]);
        currentRow++;
      }
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // Drinking Water Sources Section
      sheet.appendRow([TextCellValue('DRINKING WATER SOURCES'), TextCellValue('')]);
      currentRow++;
      if (waterSources.isNotEmpty) {
        final water = waterSources.first;
        sheet.appendRow([TextCellValue('43. Hand Pumps'), TextCellValue(water['hand_pumps'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('44. Well'), TextCellValue(water['well'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('45. Tube Well'), TextCellValue(water['tubewell'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('46. Nal Jaal'), TextCellValue(water['nal_jaal'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('47. Primary Source'), TextCellValue(water['primary_drinking_water'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('48. Water Quality'), TextCellValue(water['water_quality'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('49. Monthly Expenditure (₹)'), TextCellValue(water['water_expenditure'] ?? '')]);
        currentRow++;
      }
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // Medical Treatment Section
      sheet.appendRow([TextCellValue('MEDICAL TREATMENT'), TextCellValue('')]);
      currentRow++;
      if (medical.isNotEmpty) {
        final med = medical.first;
        sheet.appendRow([TextCellValue('50. Allopathic'), TextCellValue(med['allopathic'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('51. Ayurvedic'), TextCellValue(med['ayurvedic'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('52. Homeopathy'), TextCellValue(med['homeopathy'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('53. Traditional'), TextCellValue(med['traditional'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('54. Jhad Phook'), TextCellValue(med['jhad_phook'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('55. Distance to Hospital'), TextCellValue(med['hospital_distance'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('56. Monthly Expenditure (₹)'), TextCellValue(med['medical_expenditure'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('57. Health Insurance'), TextCellValue(med['health_insurance'] ?? '')]);
        currentRow++;
      }
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // Diseases Section
      sheet.appendRow([TextCellValue('SERIOUS DISEASES'), TextCellValue('')]);
      currentRow++;
      if (diseases.isNotEmpty) {
        for (int i = 0; i < diseases.length; i++) {
          final disease = diseases[i];
          sheet.appendRow([TextCellValue('Disease ${i + 1}'), TextCellValue('')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Disease Name'), TextCellValue(disease['disease_name'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Suffering Since'), TextCellValue(disease['suffering_since'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('   Treatment From'), TextCellValue(disease['treatment_from'] ?? '')]);
          currentRow++;
          sheet.appendRow([TextCellValue('')]);
          currentRow++;
        }
      }

      // House Conditions Section
      sheet.appendRow([TextCellValue('HOUSE CONDITIONS'), TextCellValue('')]);
      currentRow++;
      if (houseConditions.isNotEmpty) {
        final house = houseConditions.first;
        sheet.appendRow([TextCellValue('58. Katcha'), TextCellValue(house['katcha'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('59. Pakka'), TextCellValue(house['pakka'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('60. Katcha-Pakka'), TextCellValue(house['katcha_pakka'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('61. Hut'), TextCellValue(house['hut'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
      }
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // House Facilities Section
      sheet.appendRow([TextCellValue('HOUSE FACILITIES'), TextCellValue('')]);
      currentRow++;
      if (houseFacilities.isNotEmpty) {
        final facilities = houseFacilities.first;
        sheet.appendRow([TextCellValue('62. Toilet'), TextCellValue(facilities['toilet'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('63. Drainage'), TextCellValue(facilities['drainage'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('64. Soak Pit'), TextCellValue(facilities['soak_pit'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('65. Cattle Shed'), TextCellValue(facilities['cattle_shed'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('66. Compost Pit'), TextCellValue(facilities['compost_pit'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('67. Nadep'), TextCellValue(facilities['nadep'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('68. LPG Gas'), TextCellValue(facilities['lpg_gas'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('69. Biogas'), TextCellValue(facilities['biogas'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('70. Solar Cooking'), TextCellValue(facilities['solar_cooking'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('71. Electric Connection'), TextCellValue(facilities['electric_connection'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('72. Nutritional Garden'), TextCellValue(facilities['nutritional_garden'] == 1 ? 'Yes' : 'No')]);
        currentRow++;
        sheet.appendRow([TextCellValue('73. Number of Rooms'), TextCellValue(facilities['number_of_rooms'] ?? '')]);
        currentRow++;
        sheet.appendRow([TextCellValue('74. House Ownership'), TextCellValue(facilities['house_ownership'] ?? '')]);
        currentRow++;
      }
      sheet.appendRow([TextCellValue('')]);
      currentRow++;

      // Social Consciousness Section
      sheet.appendRow([TextCellValue('SOCIAL CONSCIOUSNESS'), TextCellValue('')]);
      currentRow++;
      if (socialConsciousness.isNotEmpty) {
        // Add social consciousness questions here based on the data structure
        // This would need to be mapped properly based on the actual questionnaire
        for (final sc in socialConsciousness) {
          sheet.appendRow([TextCellValue('Question ${sc['question_number'] ?? ''}'), TextCellValue(sc['response'] ?? '')]);
          currentRow++;
        }
      }

      // Save file based on platform
      final bytes = excel.encode()!;

      if (kIsWeb) {
        // For web, download directly
        final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..download = fileName;
        anchor.click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile, save to Downloads/dri/ folder
        final downloadsDir = Directory('/storage/emulated/0/Download');
        final driDir = Directory('${downloadsDir.path}/dri');

        // Create dri directory if it doesn't exist
        if (!await driDir.exists()) {
          await driDir.create(recursive: true);
        }

        final file = File('${driDir.path}/$fileName');
        await file.writeAsBytes(bytes);

        print('XLSX file saved to: ${file.path}');
      }
    } catch (e) {
      print('Error exporting to XLSX: $e');
      rethrow;
    }
  }
}
