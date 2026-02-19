import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/survey_provider.dart';
import '../../../services/database_service.dart';
import '../../../services/excel_service.dart';

class FamilySurveyPreviewPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final bool fromHistory;
  final bool showSubmitButton;
  final bool embedInSurveyFlow;
  final Map<String, dynamic>? surveyData; // Add optional survey data parameter

  const FamilySurveyPreviewPage({
    super.key,
    required this.phoneNumber,
    this.fromHistory = false,
    this.showSubmitButton = false,
    this.embedInSurveyFlow = false,
    this.surveyData, // Optional survey data
  });

  @override
  ConsumerState<FamilySurveyPreviewPage> createState() => _FamilySurveyPreviewPageState();
}

class _FamilySurveyPreviewPageState extends ConsumerState<FamilySurveyPreviewPage> {
  Map<String, dynamic> _surveyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllSurveyData();
  }

  Future<void> _loadAllSurveyData() async {
    setState(() => _isLoading = true);

    // If preview is embedded in the active survey flow, prefer the in-memory surveyData
    // passed by the caller so freshly-entered (unsaved) values are visible immediately.
    if (widget.embedInSurveyFlow && widget.surveyData != null && widget.surveyData!.isNotEmpty) {
      setState(() {
        _surveyData = _normalizeSurveyDataForPreview(widget.surveyData!);
        _isLoading = false;
      });
      return;
    }

    try {
      print('Loading survey data from database');

      // Otherwise, load from database as before
      final db = DatabaseService();
      final Map<String, dynamic> allData = {};

      // Load session data
      final session = await db.getSurveySession(widget.phoneNumber);
      if (session != null) {
        allData.addAll(session);
      }

      // Load family members
      final familyMembers = await db.getData('family_members', widget.phoneNumber);
      if (familyMembers.isNotEmpty) {
        allData['family_members'] = familyMembers;
      }

      // Load social consciousness
      final social = await db.getData('social_consciousness', widget.phoneNumber);
      if (social.isNotEmpty) {
        allData.addAll(social.first);
      }

      // Load tribal questions
      final tribal = await db.getData('tribal_questions', widget.phoneNumber);
      if (tribal.isNotEmpty) {
        allData['tribal_questions'] = tribal.first;
      }

      // Load land holding
      final land = await db.getData('land_holding', widget.phoneNumber);
      if (land.isNotEmpty) {
        allData.addAll(land.first);
      }

      // Load irrigation
      final irrigation = await db.getData('irrigation_facilities', widget.phoneNumber);
      if (irrigation.isNotEmpty) {
        allData['irrigation'] = irrigation.first;
      }

      // Load crops
      final crops = await db.getData('crop_productivity', widget.phoneNumber);
      if (crops.isNotEmpty) {
        allData['crops'] = crops;
      }

      // Load fertilizer usage
      final fertilizer = await db.getData('fertilizer_usage', widget.phoneNumber);
      if (fertilizer.isNotEmpty) {
        allData['fertilizer'] = fertilizer.first;
      }

      // Load animals
      final animals = await db.getData('animals', widget.phoneNumber);
      if (animals.isNotEmpty) {
        allData['animals'] = animals;
      }

      // Load equipment
      final equipment = await db.getData('agricultural_equipment', widget.phoneNumber);
      if (equipment.isNotEmpty) {
        allData['equipment'] = equipment;
      }

      // Load entertainment
      final entertainment = await db.getData('entertainment_facilities', widget.phoneNumber);
      if (entertainment.isNotEmpty) {
        allData['entertainment'] = entertainment.first;
      }

      // Load transport
      final transport = await db.getData('transport_facilities', widget.phoneNumber);
      if (transport.isNotEmpty) {
        allData['transport'] = transport.first;
      }

      // Load water sources
      final water = await db.getData('drinking_water_sources', widget.phoneNumber);
      if (water.isNotEmpty) {
        allData['water_sources'] = water.first;
      }

      // Load medical treatment
      final medical = await db.getData('medical_treatment', widget.phoneNumber);
      if (medical.isNotEmpty) {
        allData['medical'] = medical.first;
      }

      // Load disputes
      final disputes = await db.getData('disputes', widget.phoneNumber);
      if (disputes.isNotEmpty) {
        allData['disputes'] = disputes.first;
      }

      // Load house conditions
      final house = await db.getData('house_conditions', widget.phoneNumber);
      if (house.isNotEmpty) {
        allData['house'] = house.first;
      }

      // Load house facilities
      final facilities = await db.getData('house_facilities', widget.phoneNumber);
      if (facilities.isNotEmpty) {
        allData['facilities'] = facilities.first;
      }

      // Load diseases
      final diseases = await db.getData('diseases', widget.phoneNumber);
      if (diseases.isNotEmpty) {
        allData['diseases'] = diseases;
      }

      // Load merged government schemes (JSON)
      final schemes = await db.getData('merged_govt_schemes', widget.phoneNumber);
      if (schemes.isNotEmpty) {
        allData['merged_govt_schemes'] = schemes.first;
      }

      // Load government scheme info tables
      final aadhaarInfo = await db.getData('aadhaar_info', widget.phoneNumber);
      if (aadhaarInfo.isNotEmpty) allData['aadhaar_info'] = aadhaarInfo.first;

      final ayushmanCard = await db.getData('ayushman_card', widget.phoneNumber);
      if (ayushmanCard.isNotEmpty) allData['ayushman_card'] = ayushmanCard.first;

      final familyId = await db.getData('family_id', widget.phoneNumber);
      if (familyId.isNotEmpty) allData['family_id'] = familyId.first;

      final rationCard = await db.getData('ration_card', widget.phoneNumber);
      if (rationCard.isNotEmpty) allData['ration_card'] = rationCard.first;

      final samagraId = await db.getData('samagra_id', widget.phoneNumber);
      if (samagraId.isNotEmpty) allData['samagra_id'] = samagraId.first;

      final tribalCard = await db.getData('tribal_card', widget.phoneNumber);
      if (tribalCard.isNotEmpty) allData['tribal_card'] = tribalCard.first;

      final handicappedAllowance = await db.getData('handicapped_allowance', widget.phoneNumber);
      if (handicappedAllowance.isNotEmpty) allData['handicapped_allowance'] = handicappedAllowance.first;

      final pensionAllowance = await db.getData('pension_allowance', widget.phoneNumber);
      if (pensionAllowance.isNotEmpty) allData['pension_allowance'] = pensionAllowance.first;

      final widowAllowance = await db.getData('widow_allowance', widget.phoneNumber);
      if (widowAllowance.isNotEmpty) allData['widow_allowance'] = widowAllowance.first;

      final vbGram = await db.getData('vb_gram', widget.phoneNumber);
      if (vbGram.isNotEmpty) allData['vb_gram'] = vbGram.first;

      final pmKisan = await db.getData('pm_kisan_nidhi', widget.phoneNumber);
      if (pmKisan.isNotEmpty) allData['pm_kisan_nidhi'] = pmKisan.first;

      final pmSamman = await db.getData('pm_kisan_samman_nidhi', widget.phoneNumber);
      if (pmSamman.isNotEmpty) allData['pm_kisan_samman_nidhi'] = pmSamman.first;

      // Load children data
      final children = await db.getData('children_data', widget.phoneNumber);
      if (children.isNotEmpty) {
        allData['children'] = children;
      }

      // Load migration
      final migration = await db.getData('migration_data', widget.phoneNumber);
      if (migration.isNotEmpty) {
        allData['migration'] = migration.first;
      }

      // Load training
      final training = await db.getData('training_data', widget.phoneNumber);
      if (training.isNotEmpty) {
        allData['training'] = training;
      }

      // Load bank accounts
      final bankAccounts = await db.getData('bank_accounts', widget.phoneNumber);
      if (bankAccounts.isNotEmpty) {
        allData['bank_accounts'] = bankAccounts;
      }

      // Load health programmes
      final healthProgrammes = await db.getData('health_programmes', widget.phoneNumber);
      if (healthProgrammes.isNotEmpty) {
        allData['health_programmes'] = healthProgrammes.first;
      }

      // Load folklore medicine
      final folkloreMedicine = await db.getData('folklore_medicine', widget.phoneNumber);
      if (folkloreMedicine.isNotEmpty) {
        allData['folklore_medicine'] = folkloreMedicine;
      }

      final vbGramMembers = await db.getData('vb_gram_members', widget.phoneNumber);
      if (vbGramMembers.isNotEmpty) allData['vb_gram_members'] = vbGramMembers;

      final pmKisanMembers = await db.getData('pm_kisan_members', widget.phoneNumber);
      if (pmKisanMembers.isNotEmpty) allData['pm_kisan_members'] = pmKisanMembers;

      final pmSammanMembers = await db.getData('pm_kisan_samman_members', widget.phoneNumber);
      if (pmSammanMembers.isNotEmpty) allData['pm_kisan_samman_members'] = pmSammanMembers;

      // Load scheme members data
      final aadhaarMembers = await db.getData('aadhaar_scheme_members', widget.phoneNumber);
      if (aadhaarMembers.isNotEmpty) allData['aadhaar_members'] = aadhaarMembers;

      final tribalMembers = await db.getData('tribal_scheme_members', widget.phoneNumber);
      if (tribalMembers.isNotEmpty) allData['tribal_members'] = tribalMembers;

      final pensionMembers = await db.getData('pension_scheme_members', widget.phoneNumber);
      if (pensionMembers.isNotEmpty) allData['pension_members'] = pensionMembers;

      final widowMembers = await db.getData('widow_scheme_members', widget.phoneNumber);
      if (widowMembers.isNotEmpty) allData['widow_members'] = widowMembers;

      final ayushmanMembers = await db.getData('ayushman_scheme_members', widget.phoneNumber);
      if (ayushmanMembers.isNotEmpty) allData['ayushman_members'] = ayushmanMembers;

      final rationMembers = await db.getData('ration_scheme_members', widget.phoneNumber);
      if (rationMembers.isNotEmpty) allData['ration_members'] = rationMembers;

      final familyIdMembers = await db.getData('family_id_scheme_members', widget.phoneNumber);
      if (familyIdMembers.isNotEmpty) allData['family_id_members'] = familyIdMembers;

      final samagraMembers = await db.getData('samagra_scheme_members', widget.phoneNumber);
      if (samagraMembers.isNotEmpty) allData['samagra_members'] = samagraMembers;

      final handicappedMembers = await db.getData('handicapped_scheme_members', widget.phoneNumber);
      if (handicappedMembers.isNotEmpty) allData['handicapped_members'] = handicappedMembers;

      // Load SHG and FPO members
      final shgMembers = await db.getData('shg_members', widget.phoneNumber);
      if (shgMembers.isNotEmpty) allData['shg_members'] = shgMembers;

      final fpoMembers = await db.getData('fpo_members', widget.phoneNumber);
      if (fpoMembers.isNotEmpty) allData['fpo_members'] = fpoMembers;

      // Load malnourished children
      final malnourishedChildren = await db.getData('malnourished_children_data', widget.phoneNumber);
      if (malnourishedChildren.isNotEmpty) allData['malnourished_children'] = malnourishedChildren;

      final childDiseases = await db.getData('child_diseases', widget.phoneNumber);
      if (childDiseases.isNotEmpty) allData['child_diseases'] = childDiseases;

      setState(() {
        _surveyData = _normalizeSurveyDataForPreview(allData);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading survey data: $e');
      setState(() => _isLoading = false);
  }
}

  Map<String, dynamic> _normalizeSurveyDataForPreview(Map<String, dynamic> raw) {
    final data = Map<String, dynamic>.from(raw);

    Map<String, dynamic> mapify(dynamic value) {
      if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
      if (value is Map) {
        return value.map((key, val) => MapEntry(key.toString(), val));
      }
      return {};
    }

    List<dynamic> listify(dynamic value) {
      if (value is List) {
        return value.map((e) {
          if (e is Map<String, dynamic>) return Map<String, dynamic>.from(e);
          if (e is Map) return e.map((k, v) => MapEntry(k.toString(), v));
          return e;
        }).toList();
      }
      return [];
    }

    void ensureMap(String targetKey, List<String> sourceKeys, List<String> fields) {
      if (data[targetKey] is Map) return;
      for (final key in sourceKeys) {
        final val = data[key];
        if (val is Map) {
          data[targetKey] = mapify(val);
          return;
        }
      }
      final built = <String, dynamic>{};
      for (final field in fields) {
        if (data.containsKey(field)) {
          built[field] = data[field];
        }
      }
      if (built.isNotEmpty) {
        data[targetKey] = built;
      }
    }

    void ensureList(String targetKey, List<String> sourceKeys) {
      if (data[targetKey] is List) return;
      for (final key in sourceKeys) {
        final val = data[key];
        if (val is List) {
          data[targetKey] = listify(val);
          return;
        }
      }
    }

    ensureMap('irrigation', ['irrigation', 'irrigation_facilities'], [
      'primary_source',
      'canal',
      'tube_well',
      'river',
      'pond',
      'well',
      'hand_pump',
      'submersible',
      'rainwater_harvesting',
      'check_dam',
      'other_sources',
    ]);

    ensureList('crops', ['crops', 'crop_productivity']);

    ensureMap('fertilizer', ['fertilizer', 'fertilizer_usage'], [
      'urea_fertilizer',
      'organic_fertilizer',
      'fertilizer_types',
      'fertilizer_expenditure',
    ]);

    ensureList('animals', ['animals']);

    if (data['equipment'] is! List) {
      final equipmentList = listify(data['agricultural_equipment']);
      if (equipmentList.isNotEmpty) {
        data['equipment'] = equipmentList;
      } else {
        Map<String, dynamic> equipmentMap = {};
        if (data['agricultural_equipment'] is Map) {
          equipmentMap = mapify(data['agricultural_equipment']);
        } else if (data['equipment'] is Map) {
          equipmentMap = mapify(data['equipment']);
        } else {
          equipmentMap = mapify({
            'tractor': data['tractor'],
            'tractor_condition': data['tractor_condition'],
            'thresher': data['thresher'],
            'thresher_condition': data['thresher_condition'],
            'seed_drill': data['seed_drill'],
            'seed_drill_condition': data['seed_drill_condition'],
            'sprayer': data['sprayer'],
            'sprayer_condition': data['sprayer_condition'],
            'duster': data['duster'],
            'duster_condition': data['duster_condition'],
            'diesel_engine': data['diesel_engine'],
            'diesel_engine_condition': data['diesel_engine_condition'],
            'other_equipment': data['other_equipment'],
          });
        }
        if (equipmentMap.isNotEmpty) {
          data['equipment'] = [equipmentMap];
        }
      }
    }

    ensureMap('entertainment', ['entertainment', 'entertainment_facilities'], [
      'smart_mobile',
      'smart_mobile_count',
      'analog_mobile',
      'analog_mobile_count',
      'television',
      'radio',
      'games',
      'other_entertainment',
      'other_specify',
    ]);

    ensureMap('transport', ['transport', 'transport_facilities'], [
      'car_jeep',
      'motorcycle_scooter',
      'e_rickshaw',
      'cycle',
      'pickup_truck',
      'bullock_cart',
    ]);

    ensureMap('water_sources', ['water_sources', 'drinking_water_sources'], [
      'hand_pumps',
      'hand_pumps_distance',
      'hand_pumps_quality',
      'well',
      'well_distance',
      'well_quality',
      'tubewell',
      'tubewell_distance',
      'tubewell_quality',
      'nal_jaal',
      'nal_jaal_quality',
      'other_source',
      'other_distance',
      'other_sources_quality',
    ]);

    ensureMap('medical', ['medical', 'medical_treatment'], [
      'allopathic',
      'ayurvedic',
      'homeopathy',
      'traditional',
      'other_treatment',
      'preferred_treatment',
    ]);

    ensureMap('house', ['house', 'house_conditions'], [
      'house_type',
      'house_ownership',
      'num_of_rooms',
      'toilet_in_use',
      'toilet_details',
      'cooking_fuel',
      'light_source',
      'kitchen_type',
      'kitchen_type_other',
      'drainage_system',
      'electricity_connection',
    ]);

    ensureMap('facilities', ['facilities', 'house_facilities'], [
      'sewage',
      'compost_pit',
      'nadep',
      'lpg_gas',
      'biogas',
      'solar_cooking',
      'electric_connection',
      'nutritional_garden_available',
      'tulsi_plants_available',
    ]);

    if (data['folklore_medicine'] is! List) {
      final folklore = listify(data['folklore_medicines']);
      if (folklore.isNotEmpty) {
        data['folklore_medicine'] = folklore;
      }
    }

    if (data['health_programmes'] is! Map) {
      ensureMap('health_programmes', ['health_programmes'], [
        'vaccination_pregnancy',
        'child_vaccination',
        'vaccination_schedule',
        'health_checkup',
        'nutrition_programme',
        'health_programme_details',
      ]);
    }

    if (data['children'] is! List) {
      final childrenFields = <String, dynamic>{
        'births_last_3_years': data['births_last_3_years'],
        'infant_deaths_last_3_years': data['infant_deaths_last_3_years'],
        'malnourished_children': data['malnourished_children'],
      }..removeWhere((key, value) => value == null);
      if (childrenFields.isNotEmpty) {
        data['children'] = [childrenFields];
      }
    }

    if (data['malnourished_children'] is! List) {
      final malnourished = listify(data['malnourished_children_data']);
      if (malnourished.isNotEmpty) {
        data['malnourished_children'] = malnourished
            .map((child) {
              final c = mapify(child);
              return {
                'child_id': c['child_id'],
                'child_name': c['child_name'],
                'height': c['height'],
                'weight': c['weight'],
              };
            })
            .toList();

        if (data['child_diseases'] is! List) {
          final childDiseases = <Map<String, dynamic>>[];
          for (final child in malnourished) {
            final c = mapify(child);
            final childId = c['child_id'];
            final diseases = listify(c['diseases']);
            for (final d in diseases) {
              final disease = mapify(d);
              childDiseases.add({
                'child_id': childId,
                'disease_name': disease['name'] ?? disease['disease_name'],
              });
            }
          }
          if (childDiseases.isNotEmpty) {
            data['child_diseases'] = childDiseases;
          }
        }
      }
    }

    if (data['migration'] is! Map) {
      final migrationMap = <String, dynamic>{
        'family_members_migrated': data['family_members_migrated'],
        'reason': data['reason'],
        'duration': data['duration'],
        'destination': data['destination'],
        'no_migration': data['no_migration'],
        'migrated_members_json': data['migrated_members_json'],
      }..removeWhere((key, value) => value == null);

      if (data['migrated_members'] is List && !migrationMap.containsKey('migrated_members_json')) {
        migrationMap['migrated_members_json'] = jsonEncode(data['migrated_members']);
      }

      if (migrationMap.isNotEmpty) {
        data['migration'] = migrationMap;
      }
    }

    if (data['training'] is! List) {
      final trainingMembers = listify(data['training_members']);
      if (trainingMembers.isNotEmpty) {
        data['training'] = trainingMembers;
      }
    }

    if (data['diseases'] is! List) {
      final diseasesValue = data['diseases'];
      if (diseasesValue is Map && diseasesValue['members'] is List) {
        data['diseases'] = (diseasesValue['members'] as List)
            .map((member) => _mapDiseaseMember(mapify(member)))
            .toList();
      } else {
        final members = listify(data['members']);
        final looksLikeDisease = members.any((m) {
          final member = mapify(m);
          return member.containsKey('disease_name') ||
              member.containsKey('suffering_since') ||
              member.containsKey('treatment_taken') ||
              member.containsKey('treatment_from_when') ||
              member.containsKey('treatment_from_where') ||
              member.containsKey('treatment_taken_from');
        });
        if (looksLikeDisease) {
          data['diseases'] = members.map((m) => _mapDiseaseMember(mapify(m))).toList();
        }
      }
    }

    if (data['bank_accounts'] is! List) {
      final members = listify(data['members']);
      final hasBankAccounts = members.any((m) => mapify(m)['bank_accounts'] is List);
      if (hasBankAccounts) {
        final accounts = <Map<String, dynamic>>[];
        int srNo = 0;
        for (final m in members) {
          final member = mapify(m);
          final memberName = member['name'] ?? member['member_name'];
          final bankList = listify(member['bank_accounts']);
          for (final account in bankList) {
            final a = mapify(account);
            srNo++;
            accounts.add({
              'sr_no': a['sr_no'] ?? srNo,
              'member_name': memberName,
              'account_number': a['account_number'],
              'bank_name': a['bank_name'],
              'ifsc_code': a['ifsc_code'],
              'branch_name': a['branch_name'],
              'account_type': a['account_type'],
              'has_account': a['has_account'],
              'details_correct': a['details_correct'],
              'incorrect_details': a['incorrect_details'],
            });
          }
        }
        if (accounts.isNotEmpty) {
          data['bank_accounts'] = accounts;
        }
      }
    }

    void mapSchemeMembers(String targetKey, String sourceKey) {
      if (data[targetKey] is List) return;
      final members = listify(data[sourceKey]);
      if (members.isNotEmpty) {
        data[targetKey] = members;
      }
    }

    mapSchemeMembers('aadhaar_members', 'aadhaar_scheme_members');
    mapSchemeMembers('tribal_members', 'tribal_scheme_members');
    mapSchemeMembers('pension_members', 'pension_scheme_members');
    mapSchemeMembers('widow_members', 'widow_scheme_members');
    mapSchemeMembers('ayushman_members', 'ayushman_scheme_members');
    mapSchemeMembers('ration_members', 'ration_scheme_members');
    mapSchemeMembers('family_id_members', 'family_id_scheme_members');
    mapSchemeMembers('samagra_members', 'samagra_scheme_members');
    mapSchemeMembers('handicapped_members', 'handicapped_scheme_members');

    if (data['vb_gram_members'] is! List && data['vb_gram'] is Map) {
      final vbMap = mapify(data['vb_gram']);
      final vbMembers = listify(vbMap['members']);
      if (vbMembers.isNotEmpty) {
        data['vb_gram_members'] = vbMembers;
      }
    }

    if (data['pm_kisan_members'] is! List && data['pm_kisan_nidhi'] is Map) {
      final pmMap = mapify(data['pm_kisan_nidhi']);
      final pmMembers = listify(pmMap['members']);
      if (pmMembers.isNotEmpty) {
        data['pm_kisan_members'] = pmMembers;
      }
    }

    if (data['pm_kisan_samman_members'] is! List && data['pm_kisan_samman_nidhi'] is Map) {
      final pmMap = mapify(data['pm_kisan_samman_nidhi']);
      final pmMembers = listify(pmMap['members']);
      if (pmMembers.isNotEmpty) {
        data['pm_kisan_samman_members'] = pmMembers;
      }
    }

    return data;
  }

  Map<String, dynamic> _mapDiseaseMember(Map<String, dynamic> member) {
    return {
      'sr_no': member['sr_no'],
      'family_member_name': member['family_member_name'] ?? member['name'],
      'disease_name': member['disease_name'],
      'suffering_since': member['suffering_since'],
      'treatment_taken': member['treatment_taken'],
      'treatment_from_when': member['treatment_from_when'],
      'treatment_from_where': member['treatment_from_where'],
      'treatment_taken_from': member['treatment_taken_from'],
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      final loading = const Center(child: CircularProgressIndicator());
      return widget.embedInSurveyFlow
          ? loading
          : Scaffold(
              appBar: AppBar(title: const Text('Survey Preview')),
              body: loading,
            );
    }

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),

          // Action Buttons (Edit & Submit)
          if (widget.fromHistory || widget.showSubmitButton)
            _buildActionButtons(),

          const SizedBox(height: 24),

          // Data Sections
          _buildSection('Basic Information', _buildBasicInfo(), Icons.info),
          _buildSection('Family Members', _buildFamilyMembers(), Icons.family_restroom),
          _buildSection('Tribal Information', _buildTribalInfo(), Icons.category),
          _buildSection('Social Consciousness', _buildSocialConsciousness(), Icons.psychology),
          _buildSection('Land & Agriculture', _buildLandInfo(), Icons.landscape),
          _buildSection('Irrigation Facilities', _buildIrrigation(), Icons.water_drop),
          _buildSection('Crops Productivity', _buildCrops(), Icons.grass),
          _buildSection('Fertilizer Usage', _buildFertilizer(), Icons.science),
          _buildSection('Animals/Livestock', _buildAnimals(), Icons.pets),
          _buildSection('Agricultural Equipment', _buildEquipment(), Icons.build),
          _buildSection('Entertainment Facilities', _buildEntertainment(), Icons.tv),
          _buildSection('Transport Facilities', _buildTransport(), Icons.directions_car),
          _buildSection('Drinking Water Sources', _buildWaterSources(), Icons.water),
          _buildSection('Medical Treatment', _buildMedical(), Icons.local_hospital),
          _buildSection('Disputes Information', _buildDisputes(), Icons.gavel),
          _buildSection('House Conditions & Facilities', _buildHouseConditions(), Icons.home),
          _buildSection('Diseases & Health', _buildDiseases(), Icons.medical_services),
          _buildSection('Health Programmes', _buildHealthProgrammes(), Icons.medical_information),
          _buildSection('Folklore Medicine', _buildFolkloreMedicine(), Icons.local_florist),
          _buildSection('Government Schemes', _buildSchemes(), Icons.account_balance),
          _buildSection('Scheme Members Details', _buildSchemeMembers(), Icons.badge),
          _buildSection('Bank Accounts', _buildBankAccounts(), Icons.account_balance_wallet),
          _buildSection('SHG & FPO Membership', _buildSHGFPO(), Icons.groups),
          _buildSection('Children Data', _buildChildren(), Icons.child_care),
          _buildSection('Malnourished Children', _buildMalnourishedChildren(), Icons.child_care),
          _buildSection('Migration Data', _buildMigration(), Icons.flight_takeoff),
          _buildSection('Training Programmes', _buildTraining(), Icons.school),

          const SizedBox(height: 24),

          // Bottom Submit Button
          if (widget.showSubmitButton)
            _buildBottomSubmit(),
        ],
      ),
    );

    if (widget.embedInSurveyFlow) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Survey Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export to Excel',
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildHeader() {
    final villageName = _surveyData['village_name'] ?? 'N/A';
    final phoneNumber = widget.phoneNumber;
    final surveyDate = _surveyData['survey_date'] ?? _surveyData['created_at'];
    String formattedDate = 'N/A';
    
    if (surveyDate != null) {
      try {
        final date = DateTime.parse(surveyDate);
        formattedDate = DateFormat('MMMM d, yyyy').format(date);
      } catch (_) {}
    }

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              villageName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Phone: $phoneNumber', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Date: $formattedDate', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            if (widget.fromHistory)
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Survey'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _editSurvey,
                ),
              ),
            if (widget.fromHistory && widget.showSubmitButton)
              const SizedBox(width: 16),
            if (widget.showSubmitButton)
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Submit & Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _submitSurvey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Excel Export Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Export to Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _exportToExcel,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    final panchayat = _surveyData['panchayat'] ?? _surveyData['gram_panchayat'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Phone Number', widget.phoneNumber),
        _buildDataRow('Surveyor Name', _surveyData['surveyor_name']),
        _buildDataRow('Village Name', _surveyData['village_name']),
        _buildDataRow('Village Number', _surveyData['village_number']),
        _buildDataRow('Panchayat', panchayat),
        _buildDataRow('Block', _surveyData['block']),
        _buildDataRow('Tehsil', _surveyData['tehsil']),
        _buildDataRow('District', _surveyData['district']),
        _buildDataRow('State', _surveyData['state']),
        _buildDataRow('Postal Address', _surveyData['postal_address']),
        _buildDataRow('PIN Code', _surveyData['pin_code']),
        _buildDataRow('Survey Date', _surveyData['survey_date']),
        _buildDataRow('Head of Family', _surveyData['head_of_family']),
        _buildDataRow('Total Family Members', _surveyData['total_members']),
        _buildDataRow('Status', _surveyData['status']),
      ],
    );
  }

  Widget _buildTribalInfo() {
    final tribal = _surveyData['tribal_questions'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Deity Name', tribal['deity_name']),
        _buildDataRow('Festival Name', tribal['festival_name']),
        _buildDataRow('Dance Name', tribal['dance_name']),
        _buildDataRow('Language', tribal['language']),
      ],
    );
  }

  Widget _buildFamilyMembers() {
    final members = _surveyData['family_members'] as List<dynamic>? ?? [];
    
    if (members.isEmpty) {
      return const Text('No family members recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: members.asMap().entries.map((entry) {
        final index = entry.key;
        final member = entry.value as Map<String, dynamic>;
        return Card(
          color: Colors.blue[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${member['name'] ?? "Member ${index + 1}"}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                ),
                const Divider(height: 16),
                _buildDataRow('Sr. No', member['sr_no']),
                _buildDataRow('Name', member['name']),
                _buildDataRow('Father\'s Name', member['fathers_name']),
                _buildDataRow('Mother\'s Name', member['mothers_name']),
                _buildDataRow('Relationship with Head', member['relationship_with_head']),
                _buildDataRow('Age', member['age']),
                _buildDataRow('Sex', member['sex']),
                _buildDataRow('Physically Fit', member['physically_fit']),
                _buildDataRow('Cause (if not fit)', member['physically_fit_cause']),
                _buildDataRow('Educational Qualification', member['educational_qualification']),
                _buildDataRow('Inclination to Self Employment', member['inclination_self_employment']),
                _buildDataRow('Occupation', member['occupation']),
                _buildDataRow('Days Employed', member['days_employed']),
                _buildDataRow('Income (Rs.)', member['income']),
                _buildDataRow('Awareness about Village', member['awareness_about_village']),
                _buildDataRow('Participate in Gram Sabha', member['participate_gram_sabha']),
                _buildDataRow('Insured', member['insured']),
                _buildDataRow('Insurance Company', member['insurance_company']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSocialConsciousness() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lifestyle & Consumption', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple[800])),
        const SizedBox(height: 8),
        _buildDataRow('Clothes Frequency', _surveyData['clothes_frequency']),
        _buildDataRow('Clothes Other Specify', _surveyData['clothes_other_specify']),
        _buildDataRow('Food Waste Exists', _surveyData['food_waste_exists']),
        _buildDataRow('Food Waste Amount', _surveyData['food_waste_amount']),
        _buildDataRow('Waste Disposal', _surveyData['waste_disposal']),
        _buildDataRow('Waste Disposal Other', _surveyData['waste_disposal_other']),
        _buildDataRow('Separate Waste', _surveyData['separate_waste']),
        _buildDataRow('Compost Pit', _surveyData['compost_pit']),
        _buildDataRow('Recycle Used Items', _surveyData['recycle_used_items']),
        _buildDataRow('LED Lights', _surveyData['led_lights']),
        _buildDataRow('Turn Off Devices', _surveyData['turn_off_devices']),
        _buildDataRow('Fix Leaks', _surveyData['fix_leaks']),
        _buildDataRow('Avoid Plastics', _surveyData['avoid_plastics']),
        const Divider(height: 24),
        Text('Spiritual & Community', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple[800])),
        const SizedBox(height: 8),
        _buildDataRow('Family Prayers', _surveyData['family_prayers']),
        _buildDataRow('Family Meditation', _surveyData['family_meditation']),
        _buildDataRow('Meditation Members', _surveyData['meditation_members']),
        _buildDataRow('Family Yoga', _surveyData['family_yoga']),
        _buildDataRow('Yoga Members', _surveyData['yoga_members']),
        _buildDataRow('Community Activities', _surveyData['community_activities']),
        _buildDataRow('Spiritual Discourses', _surveyData['spiritual_discourses']),
        _buildDataRow('Discourses Members', _surveyData['discourses_members']),
        const Divider(height: 24),
        Text('Happiness & Addictions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple[800])),
        const SizedBox(height: 8),
        _buildDataRow('Personal Happiness', _surveyData['personal_happiness']),
        _buildDataRow('Family Happiness', _surveyData['family_happiness']),
        _buildDataRow('Happiness Family Who', _surveyData['happiness_family_who']),
        _buildDataRow('Financial Problems', _surveyData['financial_problems']),
        _buildDataRow('Family Disputes', _surveyData['family_disputes']),
        _buildDataRow('Illness Issues', _surveyData['illness_issues']),
        _buildDataRow('Unhappiness Reason', _surveyData['unhappiness_reason']),
        _buildDataRow('Addiction Smoke', _surveyData['addiction_smoke']),
        _buildDataRow('Addiction Drink', _surveyData['addiction_drink']),
        _buildDataRow('Addiction Gutka', _surveyData['addiction_gutka']),
        _buildDataRow('Addiction Gamble', _surveyData['addiction_gamble']),
        _buildDataRow('Addiction Tobacco', _surveyData['addiction_tobacco']),
        _buildDataRow('Addiction Details', _surveyData['addiction_details']),
      ],
    );
  }

  Widget _buildLandInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Irrigated Area (Hectares)', _surveyData['irrigated_area']),
        _buildDataRow('Cultivable Area (Hectares)', _surveyData['cultivable_area']),
        _buildDataRow('Unirrigated Area (Hectares)', _surveyData['unirrigated_area']),
        _buildDataRow('Barren Land (Hectares)', _surveyData['barren_land']),
        const Divider(height: 24),
        Text('Fruit Trees', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[800])),
        const SizedBox(height: 8),
        _buildDataRow('Mango Trees', _surveyData['mango_trees']),
        _buildDataRow('Guava Trees', _surveyData['guava_trees']),
        _buildDataRow('Lemon Trees', _surveyData['lemon_trees']),
        _buildDataRow('Banana Plants', _surveyData['banana_plants']),
        _buildDataRow('Papaya Trees', _surveyData['papaya_trees']),
        _buildDataRow('Pomegranate Trees', _surveyData['pomegranate_trees']),
        _buildDataRow('Other Fruit Trees Name', _surveyData['other_fruit_trees_name']),
        _buildDataRow('Other Fruit Trees Count', _surveyData['other_fruit_trees_count']),
      ],
    );
  }

  Widget _buildIrrigation() {
    final irrigationRaw = _surveyData['irrigation'];
    final irrigation = irrigationRaw is Map<String, dynamic>
        ? irrigationRaw
        : (irrigationRaw is List && irrigationRaw.isNotEmpty && irrigationRaw.first is Map<String, dynamic>
            ? irrigationRaw.first as Map<String, dynamic>
            : {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Canal', irrigation['canal']),
        _buildDataRow('Tube Well', irrigation['tube_well']),
        _buildDataRow('Pond', irrigation['pond']),
        _buildDataRow('Other Sources', irrigation['other_sources']),
      ],
    );
  }

  Widget _buildCrops() {
    final crops = _surveyData['crops'] as List<dynamic>? ?? [];
    
    if (crops.isEmpty) {
      return const Text('No crops recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: crops.asMap().entries.map((entry) {
        final index = entry.key;
        final crop = entry.value as Map<String, dynamic>;
        return Card(
          color: Colors.green[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop['crop_name'] ?? 'Crop ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                ),
                const Divider(height: 16),
                _buildDataRow('Sr. No', crop['sr_no']),
                _buildDataRow('Crop Name', crop['crop_name']),
                _buildDataRow('Area (Hectares)', crop['area_hectares']),
                _buildDataRow('Productivity (Q/Ha)', crop['productivity_quintal_per_hectare']),
                _buildDataRow('Total Production (Q)', crop['total_production_quintal']),
                _buildDataRow('Quantity Consumed (Q)', crop['quantity_consumed_quintal']),
                _buildDataRow('Quantity Sold (Q)', crop['quantity_sold_quintal']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFertilizer() {
    final fertilizerRaw = _surveyData['fertilizer'];
    final fertilizer = fertilizerRaw is Map<String, dynamic>
        ? fertilizerRaw
        : (fertilizerRaw is List && fertilizerRaw.isNotEmpty && fertilizerRaw.first is Map<String, dynamic>
            ? fertilizerRaw.first as Map<String, dynamic>
            : {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Urea Fertilizer', fertilizer['urea_fertilizer']),
        _buildDataRow('Organic Fertilizer', fertilizer['organic_fertilizer']),
        _buildDataRow('Fertilizer Types', fertilizer['fertilizer_types']),
      ],
    );
  }

  Widget _buildAnimals() {
    final animals = _surveyData['animals'] as List<dynamic>? ?? [];
    
    if (animals.isEmpty) {
      return const Text('No animals recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: animals.asMap().entries.map((entry) {
        final index = entry.key;
        final animal = entry.value as Map<String, dynamic>;
        return Card(
          color: Colors.brown[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal['animal_type'] ?? 'Animal ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown),
                ),
                const Divider(height: 16),
                _buildDataRow('Sr. No', animal['sr_no']),
                _buildDataRow('Animal Type', animal['animal_type']),
                _buildDataRow('Number of Animals', animal['number_of_animals']),
                _buildDataRow('Breed', animal['breed']),
                _buildDataRow('Production per Animal', animal['production_per_animal']),
                _buildDataRow('Quantity Sold', animal['quantity_sold']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEquipment() {
    final equipmentRaw = _surveyData['equipment'];
    final equipment = equipmentRaw is Map<String, dynamic>
        ? equipmentRaw
        : (equipmentRaw is List && equipmentRaw.isNotEmpty && equipmentRaw.first is Map<String, dynamic>
            ? equipmentRaw.first as Map<String, dynamic>
            : {});
    
    if (equipment.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataRow('Tractor', equipment['tractor']),
          _buildDataRow('Tractor Condition', equipment['tractor_condition']),
          _buildDataRow('Thresher', equipment['thresher']),
          _buildDataRow('Thresher Condition', equipment['thresher_condition']),
          _buildDataRow('Seed Drill', equipment['seed_drill']),
          _buildDataRow('Seed Drill Condition', equipment['seed_drill_condition']),
          _buildDataRow('Sprayer', equipment['sprayer']),
          _buildDataRow('Sprayer Condition', equipment['sprayer_condition']),
          _buildDataRow('Duster', equipment['duster']),
          _buildDataRow('Duster Condition', equipment['duster_condition']),
          _buildDataRow('Diesel Engine', equipment['diesel_engine']),
          _buildDataRow('Diesel Engine Condition', equipment['diesel_engine_condition']),
          _buildDataRow('Other Equipment', equipment['other_equipment']),
        ],
      );
    }
    
    return const Text('No equipment recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
  }

  Widget _buildEntertainment() {
    final entRaw = _surveyData['entertainment'];
    final ent = entRaw is Map<String, dynamic>
        ? entRaw
        : (entRaw is List && entRaw.isNotEmpty && entRaw.first is Map<String, dynamic>
            ? entRaw.first as Map<String, dynamic>
            : {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Smart Mobile', ent['smart_mobile']),
        _buildDataRow('Smart Mobile Count', ent['smart_mobile_count']),
        _buildDataRow('Analog Mobile', ent['analog_mobile']),
        _buildDataRow('Analog Mobile Count', ent['analog_mobile_count']),
        _buildDataRow('Television', ent['television']),
        _buildDataRow('Radio', ent['radio']),
        _buildDataRow('Games', ent['games']),
        _buildDataRow('Other Entertainment', ent['other_entertainment']),
        _buildDataRow('Other Specify', ent['other_specify']),
      ],
    );
  }

  Widget _buildTransport() {
    final transportRaw = _surveyData['transport'];
    final transport = transportRaw is Map<String, dynamic>
        ? transportRaw
        : (transportRaw is List && transportRaw.isNotEmpty && transportRaw.first is Map<String, dynamic>
            ? transportRaw.first as Map<String, dynamic>
            : {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Car/Jeep', transport['car_jeep']),
        _buildDataRow('Motorcycle/Scooter', transport['motorcycle_scooter']),
        _buildDataRow('E-Rickshaw', transport['e_rickshaw']),
        _buildDataRow('Cycle', transport['cycle']),
        _buildDataRow('Pickup Truck', transport['pickup_truck']),
        _buildDataRow('Bullock Cart', transport['bullock_cart']),
      ],
    );
  }

  Widget _buildWaterSources() {
    final water = _surveyData['water_sources'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Hand Pumps', water['hand_pumps']),
        _buildDataRow('Hand Pumps Distance (km)', water['hand_pumps_distance']),
        _buildDataRow('Hand Pumps Quality', water['hand_pumps_quality']),
        _buildDataRow('Well', water['well']),
        _buildDataRow('Well Distance (km)', water['well_distance']),
        _buildDataRow('Well Quality', water['well_quality']),
        _buildDataRow('Tubewell', water['tubewell']),
        _buildDataRow('Tubewell Distance (km)', water['tubewell_distance']),
        _buildDataRow('Tubewell Quality', water['tubewell_quality']),
        _buildDataRow('Nal Jaal', water['nal_jaal']),
        _buildDataRow('Nal Jaal Quality', water['nal_jaal_quality']),
        _buildDataRow('Other Source', water['other_source']),
        _buildDataRow('Other Distance (km)', water['other_distance']),
        _buildDataRow('Other Sources Quality', water['other_sources_quality']),
      ],
    );
  }

  Widget _buildMedical() {
    final medical = _surveyData['medical'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Allopathic', medical['allopathic']),
        _buildDataRow('Ayurvedic', medical['ayurvedic']),
        _buildDataRow('Homeopathy', medical['homeopathy']),
        _buildDataRow('Traditional', medical['traditional']),
        _buildDataRow('Other Treatment', medical['other_treatment']),
        _buildDataRow('Preferred Treatment', medical['preferred_treatment']),
      ],
    );
  }

  Widget _buildDisputes() {
    final disputes = _surveyData['disputes'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Family Disputes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red[800])),
        const SizedBox(height: 8),
        _buildDataRow('Family Disputes', disputes['family_disputes']),
        _buildDataRow('Family Registered', disputes['family_registered']),
        _buildDataRow('Family Period', disputes['family_period']),
        const Divider(height: 24),
        Text('Revenue Disputes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red[800])),
        const SizedBox(height: 8),
        _buildDataRow('Revenue Disputes', disputes['revenue_disputes']),
        _buildDataRow('Revenue Registered', disputes['revenue_registered']),
        _buildDataRow('Revenue Period', disputes['revenue_period']),
        const Divider(height: 24),
        Text('Criminal Disputes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red[800])),
        const SizedBox(height: 8),
        _buildDataRow('Criminal Disputes', disputes['criminal_disputes']),
        _buildDataRow('Criminal Registered', disputes['criminal_registered']),
        _buildDataRow('Criminal Period', disputes['criminal_period']),
        const Divider(height: 24),
        Text('Other Disputes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red[800])),
        const SizedBox(height: 8),
        _buildDataRow('Other Disputes', disputes['other_disputes']),
        _buildDataRow('Other Description', disputes['other_description']),
        _buildDataRow('Other Registered', disputes['other_registered']),
        _buildDataRow('Other Period', disputes['other_period']),
      ],
    );
  }

  Widget _buildHouseConditions() {
    final house = _surveyData['house'] as Map<String, dynamic>? ?? {};
    final facilities = _surveyData['facilities'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('House Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown[800])),
        const SizedBox(height: 8),
        _buildDataRow('Katcha', house['katcha']),
        _buildDataRow('Pakka', house['pakka']),
        _buildDataRow('Katcha-Pakka', house['katcha_pakka']),
        _buildDataRow('Hut', house['hut']),
        _buildDataRow('Toilet In Use', house['toilet_in_use']),
        _buildDataRow('Toilet Condition', house['toilet_condition']),
        const Divider(height: 24),
        Text('Facilities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown[800])),
        const SizedBox(height: 8),
        _buildDataRow('Toilet', facilities['toilet']),
        _buildDataRow('Toilet In Use', facilities['toilet_in_use']),
        _buildDataRow('Drainage', facilities['drainage']),
        _buildDataRow('Soak Pit', facilities['soak_pit']),
        _buildDataRow('Cattle Shed', facilities['cattle_shed']),
        _buildDataRow('Compost Pit', facilities['compost_pit']),
        _buildDataRow('Nadep', facilities['nadep']),
        _buildDataRow('LPG Gas', facilities['lpg_gas']),
        _buildDataRow('Biogas', facilities['biogas']),
        _buildDataRow('Solar Cooking', facilities['solar_cooking']),
        _buildDataRow('Electric Connection', facilities['electric_connection']),
        _buildDataRow('Nutritional Garden Available', facilities['nutritional_garden_available']),
        _buildDataRow('Tulsi Plants Available', facilities['tulsi_plants_available']),
      ],
    );
  }

  Widget _buildDiseases() {
    final diseases = _surveyData['diseases'] as List<dynamic>? ?? [];
    
    if (diseases.isEmpty) {
      return const Text('No diseases recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: diseases.asMap().entries.map((entry) {
        final index = entry.key;
        final disease = entry.value as Map<String, dynamic>;
        return Card(
          color: Colors.red[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disease['disease_name'] ?? 'Disease ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                ),
                const Divider(height: 16),
                _buildDataRow('Sr. No', disease['sr_no']),
                _buildDataRow('Family Member Name', disease['family_member_name']),
                _buildDataRow('Disease Name', disease['disease_name']),
                _buildDataRow('Suffering Since', disease['suffering_since']),
                _buildDataRow('Treatment Taken', disease['treatment_taken']),
                _buildDataRow('Treatment From When', disease['treatment_from_when']),
                _buildDataRow('Treatment From Where', disease['treatment_from_where']),
                _buildDataRow('Treatment Taken From', disease['treatment_taken_from']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthProgrammes() {
    final health = _surveyData['health_programmes'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Vaccination Pregnancy', health['vaccination_pregnancy']),
        _buildDataRow('Child Vaccination', health['child_vaccination']),
        _buildDataRow('Vaccination Schedule', health['vaccination_schedule']),
        _buildDataRow('Balance Doses Schedule', health['balance_doses_schedule']),
        _buildDataRow('Family Planning Awareness', health['family_planning_awareness']),
        _buildDataRow('Contraceptive Applied', health['contraceptive_applied']),
      ],
    );
  }

  Widget _buildFolkloreMedicine() {
    final folklore = _surveyData['folklore_medicine'] as List<dynamic>? ?? [];
    
    if (folklore.isEmpty) {
      return const Text('No folklore medicine recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: folklore.map((item) {
        final f = item as Map<String, dynamic>;
        return Card(
          color: Colors.teal[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataRow('Person Name', f['person_name']),
                _buildDataRow('Plant Local Name', f['plant_local_name']),
                _buildDataRow('Plant Botanical Name', f['plant_botanical_name']),
                _buildDataRow('Uses', f['uses']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _decodeSchemeData(dynamic row) {
    if (row is Map<String, dynamic>) {
      final raw = row['scheme_data'];
      if (raw is Map<String, dynamic>) return raw;
      if (raw is String && raw.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map) {
            return decoded.map((k, v) => MapEntry(k.toString(), v));
          }
        } catch (_) {
          return {};
        }
      }
    }
    return {};
  }

  String _yesNo(dynamic value) {
    if (value == null) return '-';
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is num) return value == 1 ? 'Yes' : 'No';
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'yes' || lower == 'true' || lower == '1') return 'Yes';
      if (lower == 'no' || lower == 'false' || lower == '0') return 'No';
      return value;
    }
    return value.toString();
  }

  Widget _buildSchemes() {
    final merged = _decodeSchemeData(_surveyData['merged_govt_schemes']);

    String mergedYesNo(String key) {
      final val = merged[key];
      if (val is Map) return _yesNo(val['is_beneficiary']);
      return _yesNo(val);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Aadhaar Card', _yesNo(_surveyData['aadhaar_info']?['has_aadhaar'])),
        _buildDataRow('Ration Card', _yesNo(_surveyData['ration_card']?['has_card'])),
        _buildDataRow('Tribal Card', _yesNo(_surveyData['tribal_card']?['has_card'])),
        _buildDataRow('Pension', _yesNo(_surveyData['pension_allowance']?['is_beneficiary'])),
        _buildDataRow('Widow Allowance', _yesNo(_surveyData['widow_allowance']?['is_beneficiary'])),
        _buildDataRow('Ayushman Card', _yesNo(_surveyData['ayushman_card']?['has_card'])),
        _buildDataRow('Family ID', _yesNo(_surveyData['family_id']?['has_id'])),
        _buildDataRow('Samagra ID', _yesNo(_surveyData['samagra_id']?['has_id'])),
        _buildDataRow('Handicapped Allowance', _yesNo(_surveyData['handicapped_allowance']?['is_beneficiary'])),
        _buildDataRow('PM Kisan Nidhi', _yesNo(_surveyData['pm_kisan_nidhi']?['is_beneficiary'])),
        _buildDataRow('PM Kisan Samman Nidhi', _yesNo(_surveyData['pm_kisan_samman_nidhi']?['is_beneficiary'])),
        _buildDataRow('VB Gram', _yesNo(_surveyData['vb_gram']?['is_member'])),
        _buildDataRow('Kisan Credit Card', mergedYesNo('kisan_credit_card')),
        _buildDataRow('Swachh Bharat', mergedYesNo('swachh_bharat')),
        _buildDataRow('Fasal Bima', mergedYesNo('fasal_bima')),
      ],
    );
  }

  Widget _buildSchemeMembers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSchemeMembersList('Aadhaar Members', _surveyData['aadhaar_members']),
        _buildSchemeMembersList('Tribal Card Members', _surveyData['tribal_members']),
        _buildSchemeMembersList('Pension Members', _surveyData['pension_members']),
        _buildSchemeMembersList('Widow Allowance Members', _surveyData['widow_members']),
        _buildSchemeMembersList('Ayushman Card Members', _surveyData['ayushman_members']),
        _buildSchemeMembersList('Ration Card Members', _surveyData['ration_members']),
        _buildSchemeMembersList('Family ID Members', _surveyData['family_id_members']),
        _buildSchemeMembersList('Samagra ID Members', _surveyData['samagra_members']),
        _buildSchemeMembersList('Handicapped Allowance Members', _surveyData['handicapped_members']),
        _buildSchemeMembersList('VB Gram Members', _surveyData['vb_gram_members']),
        _buildSchemeMembersList('PM Kisan Members', _surveyData['pm_kisan_members']),
        _buildSchemeMembersList('PM Kisan Samman Members', _surveyData['pm_kisan_samman_members']),
      ],
    );
  }

  Widget _buildSchemeMembersList(String title, dynamic membersData) {
    final members = membersData as List<dynamic>? ?? [];
    
    if (members.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
          const SizedBox(height: 4),
          const Text('No members recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          const Divider(height: 24),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
        const SizedBox(height: 8),
        ...members.map((member) {
          final m = member as Map<String, dynamic>;
          final memberName = m['family_member_name'] ?? m['member_name'] ?? m['name'];
          final haveCard = m['have_card'] ?? m['name_included'];
          final cardNumber = m['card_number'] ?? m['account_number'];
          final detailsCorrect = m['details_correct'];
          final whatIncorrect = m['what_incorrect'] ?? m['incorrect_details'];
          final benefitsReceived = m['benefits_received'] ?? m['received'];
          final days = m['days'] ?? m['days_worked'];
          return Card(
            color: Colors.indigo[50],
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDataRow('Sr. No', m['sr_no']),
                  _buildDataRow('Family Member Name', memberName),
                  _buildDataRow('Have Card / Included', haveCard),
                  _buildDataRow('Card / Account Number', cardNumber),
                  _buildDataRow('Details Correct', detailsCorrect),
                  _buildDataRow('What Incorrect', whatIncorrect),
                  _buildDataRow('Benefits Received', benefitsReceived),
                  if (days != null) _buildDataRow('Days', days),
                ],
              ),
            ),
          );
        }),
        const Divider(height: 24),
      ],
    );
  }


  Widget _buildBankAccounts() {
    final accounts = _surveyData['bank_accounts'] as List<dynamic>? ?? [];
    
    if (accounts.isEmpty) {
      return const Text('No bank accounts recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: accounts.asMap().entries.map((entry) {
        final index = entry.key;
        final account = entry.value as Map<String, dynamic>;
        return Card(
          color: Colors.lightGreen[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                ),
                const Divider(height: 16),
                _buildDataRow('Sr. No', account['sr_no']),
                _buildDataRow('Member Name', account['member_name']),
                _buildDataRow('Account Number', account['account_number']),
                _buildDataRow('Bank Name', account['bank_name']),
                _buildDataRow('IFSC Code', account['ifsc_code']),
                _buildDataRow('Branch Name', account['branch_name']),
                _buildDataRow('Account Type', account['account_type']),
                _buildDataRow('Has Account', account['has_account']),
                _buildDataRow('Details Correct', account['details_correct']),
                _buildDataRow('Incorrect Details', account['incorrect_details']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSHGFPO() {
    final shgMembers = _surveyData['shg_members'] as List<dynamic>? ?? [];
    final fpoMembers = _surveyData['fpo_members'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SHG Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple[800])),
        const SizedBox(height: 8),
        if (shgMembers.isEmpty)
          const Text('No SHG members recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
        else
          ...shgMembers.map((shg) {
            final s = shg as Map<String, dynamic>;
            return Card(
              color: Colors.purple[50],
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDataRow('Member Name', s['member_name']),
                    _buildDataRow('SHG Name', s['shg_name']),
                    _buildDataRow('Purpose', s['purpose']),
                    _buildDataRow('Agency', s['agency']),
                    _buildDataRow('Position', s['position']),
                    _buildDataRow('Monthly Saving (Rs.)', s['monthly_saving']),
                  ],
                ),
              ),
            );
          }),
        const Divider(height: 24),
        Text('FPO Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple[800])),
        const SizedBox(height: 8),
        if (fpoMembers.isEmpty)
          const Text('No FPO members recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
        else
          ...fpoMembers.map((fpo) {
            final f = fpo as Map<String, dynamic>;
            return Card(
              color: Colors.purple[50],
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDataRow('Member Name', f['member_name']),
                    _buildDataRow('FPO Name', f['fpo_name']),
                    _buildDataRow('Purpose', f['purpose']),
                    _buildDataRow('Agency', f['agency']),
                    _buildDataRow('Share Capital (Rs.)', f['share_capital']),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildChildren() {
    final children = _surveyData['children'] as List<dynamic>? ?? [];
    final childrenData = children.isNotEmpty && children.first is Map ? children.first as Map<String, dynamic> : {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Births Last 3 Years', childrenData['births_last_3_years']),
        _buildDataRow('Infant Deaths Last 3 Years', childrenData['infant_deaths_last_3_years']),
        _buildDataRow('Malnourished Children', childrenData['malnourished_children']),
      ],
    );
  }

  Widget _buildMalnourishedChildren() {
    final malnourished = _surveyData['malnourished_children'] as List<dynamic>? ?? [];
    final childDiseases = _surveyData['child_diseases'] as List<dynamic>? ?? [];
    
    if (malnourished.isEmpty) {
      return const Text('No malnourished children recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: malnourished.map((child) {
        final c = child as Map<String, dynamic>;
        final childId = c['child_id'];
        final diseases = childDiseases.where((d) => d['child_id'] == childId).toList();
        
        return Card(
          color: Colors.pink[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['child_name'] ?? 'Child',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.pink),
                ),
                const Divider(height: 16),
                _buildDataRow('Child ID', c['child_id']),
                _buildDataRow('Child Name', c['child_name']),
                _buildDataRow('Height (cm)', c['height']),
                _buildDataRow('Weight (kg)', c['weight']),
                if (diseases.isNotEmpty) ...[
                  const Divider(height: 16),
                  const Text('Diseases:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...diseases.map((d) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• ${d['disease_name']}'),
                  )),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMigration() {
    final migration = _surveyData['migration'] as Map<String, dynamic>? ?? {};
    final members = _decodeJsonList(migration['migrated_members_json']);

    if ((migration['no_migration'] == 1 || migration['no_migration'] == true) && members.isEmpty) {
      return const Text('No family migration reported', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Family Members Migrated', migration['family_members_migrated']),
        _buildDataRow('Reason', migration['reason']),
        _buildDataRow('Duration', migration['duration']),
        _buildDataRow('Destination', migration['destination']),
        if (members.isNotEmpty) ...[
          const Divider(height: 16),
          const Text('Migrated Members:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...members.map((m) {
            final member = m as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(left: 12, top: 6),
              child: Text('• ${member['member_name'] ?? ''}'),
            );
          }),
        ],
      ],
    );
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

  Widget _buildTraining() {
    final training = _surveyData['training'] as List<dynamic>? ?? [];
    
    if (training.isEmpty) {
      return const Text('No training data recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: training.map((t) {
        final train = t as Map<String, dynamic>;
        return Card(
          color: Colors.indigo[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataRow('Member Name', train['member_name']),
                _buildDataRow('Training Topic', train['training_topic']),
                _buildDataRow('Training Duration', train['training_duration']),
                _buildDataRow('Training Date', train['training_date']),
                _buildDataRow('Status', train['status']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSubmit() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle, size: 28),
        label: const Text('Submit Survey & Go Home', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _submitSurvey,
      ),
    );
  }

  Future<void> _exportToExcel() async {
    try {
      await ExcelService().exportCompleteSurveyToExcel(widget.phoneNumber);
      _showExportSuccess();
    } catch (e) {
      _showExportError(e);
    }
  }

  void _showExportSuccess() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Survey exported to Excel successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showExportError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Export failed: $error')),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

 void _editSurvey() {
    // Navigate to survey screen in edit mode
    Navigator.pushNamed(
      context,
      '/survey',
     arguments: {'continueSessionId': widget.phoneNumber},
    );
  }

  Future<void> _submitSurvey() async {
    try {
      // Mark survey as completed
      await DatabaseService().updateSurveyStatus(widget.phoneNumber, 'completed');
      
      // Sync to Supabase
      final SurveyNotifier notifier = ref.read(surveyProvider.notifier);
      await notifier.completeSurvey();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Survey submitted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

