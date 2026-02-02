import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../l10n/app_localizations.dart';
import '../../form_template.dart';
import '../../services/database_service.dart';
import '../../database/database_helper.dart';
import '../../services/supabase_service.dart';
import 'educational_facilities_screen.dart';

class InfrastructureAvailabilityScreen extends StatefulWidget {
  const InfrastructureAvailabilityScreen({super.key});

  @override
  _InfrastructureAvailabilityScreenState createState() => _InfrastructureAvailabilityScreenState();
}

class _InfrastructureAvailabilityScreenState extends State<InfrastructureAvailabilityScreen> {
  // Controllers
  final TextEditingController primarySchoolDistanceController = TextEditingController();
  final TextEditingController juniorSchoolDistanceController = TextEditingController();
  final TextEditingController highSchoolDistanceController = TextEditingController();
  final TextEditingController intermediateSchoolDistanceController = TextEditingController();
  final TextEditingController otherEducationalFacilityController = TextEditingController();
  final TextEditingController boysStudentsController = TextEditingController();
  final TextEditingController girlsStudentsController = TextEditingController();
  final TextEditingController playgroundRemarksController = TextEditingController();
  final TextEditingController panchayatRemarksController = TextEditingController();
  final TextEditingController shardaKendraDistanceController = TextEditingController();
  final TextEditingController postOfficeDistanceController = TextEditingController();
  final TextEditingController healthFacilityDistanceController = TextEditingController();
  final TextEditingController bankDistanceController = TextEditingController();
  final TextEditingController numWellsController = TextEditingController();
  final TextEditingController numPondsController = TextEditingController();
  final TextEditingController numHandPumpsController = TextEditingController();
  final TextEditingController numTubeWellsController = TextEditingController();
  final TextEditingController numTapWaterController = TextEditingController();

  // Boolean states
  bool _hasPrimarySchool = false;
  bool _hasJuniorSchool = false;
  bool _hasHighSchool = false;
  bool _hasIntermediateSchool = false;
  bool _hasPlayground = false;
  bool _hasPanchayatBhavan = false;
  bool _hasShardaKendra = false;
  bool _hasPostOffice = false;
  bool _hasHealthFacility = false;
  bool _hasPrimaryHealthCentre = false;
  bool _hasBank = false;
  bool _hasElectricalConnection = false;
  bool _hasDrinkingWaterSource = false;

  Future<void> _submitForm() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    final sessionId = databaseService.currentSessionId;

    if (sessionId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No active session found')),
        );
      }
      return;
    }

    final data = {
      'id': const Uuid().v4(),
      'session_id': sessionId,
      'has_primary_school': _hasPrimarySchool ? 1 : 0,
      'primary_school_distance': primarySchoolDistanceController.text,
      'has_junior_school': _hasJuniorSchool ? 1 : 0,
      'junior_school_distance': juniorSchoolDistanceController.text,
      'has_high_school': _hasHighSchool ? 1 : 0,
      'high_school_distance': highSchoolDistanceController.text,
      'has_intermediate_school': _hasIntermediateSchool ? 1 : 0,
      'intermediate_school_distance': intermediateSchoolDistanceController.text,
      'other_education_facilities': otherEducationalFacilityController.text,
      'boys_students_count': int.tryParse(boysStudentsController.text),
      'girls_students_count': int.tryParse(girlsStudentsController.text),
      'has_playground': _hasPlayground ? 1 : 0,
      'playground_remarks': playgroundRemarksController.text,
      'has_panchayat_bhavan': _hasPanchayatBhavan ? 1 : 0,
      'panchayat_remarks': panchayatRemarksController.text,
      'has_sharda_kendra': _hasShardaKendra ? 1 : 0,
      'sharda_kendra_distance': shardaKendraDistanceController.text,
      'has_post_office': _hasPostOffice ? 1 : 0,
      'post_office_distance': postOfficeDistanceController.text,
      'has_health_facility': _hasHealthFacility ? 1 : 0,
      'health_facility_distance': healthFacilityDistanceController.text,
      'has_bank': _hasBank ? 1 : 0,
      'bank_distance': bankDistanceController.text,
      'has_electrical_connection': _hasElectricalConnection ? 1 : 0,
      'num_wells': int.tryParse(numWellsController.text),
      'num_ponds': int.tryParse(numPondsController.text),
      'num_hand_pumps': int.tryParse(numHandPumpsController.text),
      'num_tube_wells': int.tryParse(numTubeWellsController.text),
      'num_tap_water': int.tryParse(numTapWaterController.text),
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await DatabaseHelper().insert('village_infrastructure_details', data);
      
      try {
        await supabaseService.saveVillageData('village_infrastructure_details', data);
      } catch (e) {
        print('Supabase sync warning: $e');
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EducationalFacilitiesScreen()),
        );
      }
    } catch (e) {
      print('Error saving infrastructure details: $e');
      if (mounted) {
        // Proceed even if save fails, to avoid blocking
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EducationalFacilitiesScreen()),
        );
      }
    }
  }

  void _goToPreviousScreen() {
    Navigator.pop(context);
  }

  Widget _buildInfrastructureContent() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // School Availability Section
        QuestionCard(
          question: l10n.schoolAvailability,
          description: l10n.availabilityOfDifferentTypesOfSchools,
          child: Column(
            children: [
              // Primary School
              _buildSchoolRadioField(
                label: l10n.primarySchoolUpto5thStandard,
                hasSchool: _hasPrimarySchool,
                distanceController: primarySchoolDistanceController,
                onChanged: (value) {
                  setState(() {
                    _hasPrimarySchool = value == l10n.yes;
                    if (!_hasPrimarySchool) primarySchoolDistanceController.clear();
                  });
                },
              ),

              SizedBox(height: 20),

              // Junior School
              _buildSchoolRadioField(
                label: l10n.juniorSchool6thTo8thStandard,
                hasSchool: _hasJuniorSchool,
                distanceController: juniorSchoolDistanceController,
                onChanged: (value) {
                  setState(() {
                    _hasJuniorSchool = value == l10n.yes;
                    if (!_hasJuniorSchool) juniorSchoolDistanceController.clear();
                  });
                },
              ),

              SizedBox(height: 20),

              // High School
              _buildSchoolRadioField(
                label: l10n.highSchool9thTo10thStandard,
                hasSchool: _hasHighSchool,
                distanceController: highSchoolDistanceController,
                onChanged: (value) {
                  setState(() {
                    _hasHighSchool = value == l10n.yes;
                    if (!_hasHighSchool) highSchoolDistanceController.clear();
                  });
                },
              ),

              SizedBox(height: 20),

              // Intermediate School
              _buildSchoolRadioField(
                label: l10n.intermediateSchool102,
                hasSchool: _hasIntermediateSchool,
                distanceController: intermediateSchoolDistanceController,
                onChanged: (value) {
                  setState(() {
                    _hasIntermediateSchool = value == l10n.yes;
                    if (!_hasIntermediateSchool) intermediateSchoolDistanceController.clear();
                  });
                },
              ),

              SizedBox(height: 20),

              // Other Educational Facilities
              TextInput(
                label: l10n.otherLikeAnganwadiShikshaGuaranteeSchemeEtc,
                controller: otherEducationalFacilityController,
                prefixIcon: Icons.menu_book,
              ),
            ],
          ),
        ),

        SizedBox(height: 25),

        // Number of Students Section
        QuestionCard(
          question: l10n.numberOfStudents,
          description: l10n.totalNumberOfStudentsInVillage,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: NumberInput(
                      label: l10n.boys,
                      controller: boysStudentsController,
                      prefixIcon: Icons.boy,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: NumberInput(
                      label: l10n.girls,
                      controller: girlsStudentsController,
                      prefixIcon: Icons.girl,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 25),

        // Infrastructure Facilities Section
        QuestionCard(
          question: l10n.otherInfrastructureFacilities,
          description: l10n.availabilityOfVariousInfrastructureFacilities,
          child: Column(
            children: [
              // Playground
              _buildFacilityRadioField(
                label: l10n.playground,
                hasFacility: _hasPlayground,
                remarksController: playgroundRemarksController,
                onChanged: (value) {
                  setState(() {
                    _hasPlayground = value == l10n.yes;
                    if (!_hasPlayground) playgroundRemarksController.clear();
                  });
                },
              ),

              SizedBox(height: 15),

              // Panchayat Bhavan
              _buildFacilityRadioField(
                label: l10n.panchayatBhavan,
                hasFacility: _hasPanchayatBhavan,
                remarksController: panchayatRemarksController,
                onChanged: (value) {
                  setState(() {
                    _hasPanchayatBhavan = value == l10n.yes;
                    if (!_hasPanchayatBhavan) panchayatRemarksController.clear();
                  });
                },
              ),

              SizedBox(height: 15),

              // Sharda Kendra
              _buildFacilityRadioDistanceField(
                label: l10n.shardaKendraPlaceOfWorship,
                hasFacility: _hasShardaKendra,
                distanceController: shardaKendraDistanceController,
                onChanged: (value) {
                  setState(() {
                    _hasShardaKendra = value == l10n.yes;
                    if (!_hasShardaKendra) shardaKendraDistanceController.clear();
                  });
                },
              ),

              SizedBox(height: 15),

              // Post Office
              _buildFacilityRadioDistanceField(
                label: 'Post Office',
                hasFacility: _hasPostOffice,
                distanceController: postOfficeDistanceController,
                onChanged: (value) {
                  setState(() {
                    _hasPostOffice = value == l10n.yes;
                    if (!_hasPostOffice) postOfficeDistanceController.clear();
                  });
                },
              ),

              SizedBox(height: 15),

              // Health Facility
              _buildFacilityRadioDistanceField(
                label: l10n.healthFacilityGeneralPractitioners,
                hasFacility: _hasHealthFacility,
                distanceController: healthFacilityDistanceController,
                onChanged: (value) {
                  setState(() {
                    _hasHealthFacility = value == l10n.yes;
                    if (!_hasHealthFacility) healthFacilityDistanceController.clear();
                  });
                },
              ),

              SizedBox(height: 15),

              // Primary Health Centre
              _buildSimpleRadioField(
                label: l10n.primaryHealthCentre,
                hasFacility: _hasPrimaryHealthCentre,
                onChanged: (value) {
                  setState(() {
                    _hasPrimaryHealthCentre = value == l10n.yes;
                  });
                },
              ),

              SizedBox(height: 15),

              // Bank
              _buildFacilityRadioDistanceField(
                label: l10n.bank,
                hasFacility: _hasBank,
                distanceController: bankDistanceController,
                onChanged: (value) {
                  setState(() {
                    _hasBank = value == l10n.yes;
                    if (!_hasBank) bankDistanceController.clear();
                  });
                },
              ),

              SizedBox(height: 15),

              // Electrical Connection
              _buildSimpleRadioField(
                label: l10n.electricalConnection,
                hasFacility: _hasElectricalConnection,
                onChanged: (value) {
                  setState(() {
                    _hasElectricalConnection = value == l10n.yes;
                  });
                },
              ),

              SizedBox(height: 15),

              // Water Source Section
              _buildWaterSourceSection(),
            ],
          ),
        ),

        SizedBox(height: 20),
      ],
    );
  }

  // School Radio Field with Distance - MODIFIED
  Widget _buildSchoolRadioField({
    required String label,
    required bool hasSchool,
    required TextEditingController distanceController,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioOptionGroup(
          label: label, // Label moved inside RadioOptionGroup
          options: ['Yes', 'No'],
          selectedValue: hasSchool ? 'Yes' : 'No',
          onChanged: onChanged,
        ),
        if (hasSchool)
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: NumberInput(
              label: 'Distance From Village (km)',
              controller: distanceController,
              prefixIcon: Icons.location_on,
            ),
          ),
      ],
    );
  }

  // Facility Radio Field with Remarks - MODIFIED
  Widget _buildFacilityRadioField({
    required String label,
    required bool hasFacility,
    required TextEditingController remarksController,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioOptionGroup(
          label: label, // Label moved inside RadioOptionGroup
          options: ['Yes', 'No'],
          selectedValue: hasFacility ? 'Yes' : 'No',
          onChanged: onChanged,
        ),
        if (hasFacility)
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextInput(
              label: 'Remarks',
              controller: remarksController,
              prefixIcon: Icons.note,
            ),
          ),
      ],
    );
  }

  // Facility Radio Field with Distance - MODIFIED
  Widget _buildFacilityRadioDistanceField({
    required String label,
    required bool hasFacility,
    required TextEditingController distanceController,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioOptionGroup(
          label: label, // Label moved inside RadioOptionGroup
          options: ['Yes', 'No'],
          selectedValue: hasFacility ? 'Yes' : 'No',
          onChanged: onChanged,
        ),
        if (hasFacility)
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: NumberInput(
              label: 'Distance (km)',
              controller: distanceController,
              prefixIcon: Icons.location_on,
            ),
          ),
      ],
    );
  }

  // Simple Radio Field - MODIFIED
  Widget _buildSimpleRadioField({
    required String label,
    required bool hasFacility,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioOptionGroup(
          label: label, // Label moved inside RadioOptionGroup
          options: ['Yes', 'No'],
          selectedValue: hasFacility ? 'Yes' : 'No',
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Water Source Section - MODIFIED
  Widget _buildWaterSourceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimpleRadioField(
          label: 'Source of Drinking Water',
          hasFacility: _hasDrinkingWaterSource,
          onChanged: (value) {
            setState(() {
              _hasDrinkingWaterSource = value == 'Yes';
              if (!_hasDrinkingWaterSource) {
                numWellsController.clear();
                numPondsController.clear();
                numHandPumpsController.clear();
                numTubeWellsController.clear();
                numTapWaterController.clear();
              }
            });
          },
        ),
        
        if (_hasDrinkingWaterSource) ...[
          SizedBox(height: 15),
          Text(
            'Water Source Details:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 10),
          
          Row(
            children: [
              Expanded(
                child: NumberInput(
                  label: 'No. of Wells',
                  controller: numWellsController,
                  prefixIcon: Icons.water,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: NumberInput(
                  label: 'No. of Ponds',
                  controller: numPondsController,
                  prefixIcon: Icons.waves,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 15),
          
          Row(
            children: [
              Expanded(
                child: NumberInput(
                  label: 'No. of Hand Pumps',
                  controller: numHandPumpsController,
                  prefixIcon: Icons.build,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: NumberInput(
                  label: 'No. of Tube Wells',
                  controller: numTubeWellsController,
                  prefixIcon: Icons.opacity,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 15),
          
          NumberInput(
            label: 'No. of Tap Water connections (Nal Jaal)',
            controller: numTapWaterController,
            prefixIcon: Icons.water_damage,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormTemplateScreen(
      title: l10n.infrastructureAvailabilityInVillage,
      stepNumber: 'Step 3',
      nextScreenRoute: '/educational-facilities',
      nextScreenName: l10n.educationalFacilities,
      icon: Icons.school,
      instructions: l10n.availabilityOfInfrastructure,
      contentWidget: _buildInfrastructureContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen,
      onReset: () {  },
    );
  }

  @override
  void dispose() {
    primarySchoolDistanceController.dispose();
    juniorSchoolDistanceController.dispose();
    highSchoolDistanceController.dispose();
    intermediateSchoolDistanceController.dispose();
    otherEducationalFacilityController.dispose();
    boysStudentsController.dispose();
    girlsStudentsController.dispose();
    playgroundRemarksController.dispose();
    panchayatRemarksController.dispose();
    shardaKendraDistanceController.dispose();
    postOfficeDistanceController.dispose();
    healthFacilityDistanceController.dispose();
    bankDistanceController.dispose();
    numWellsController.dispose();
    numPondsController.dispose();
    numHandPumpsController.dispose();
    numTubeWellsController.dispose();
    numTapWaterController.dispose();
    super.dispose();
  }
}
