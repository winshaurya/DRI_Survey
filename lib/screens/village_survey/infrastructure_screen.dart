import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../form_template.dart'; // Import the form template
import 'infrastructure_availability_screen.dart';
import 'village_form_screen.dart'; // Import the previous screen

class InfrastructureScreen extends StatefulWidget {
  const InfrastructureScreen({super.key});

  @override
  _InfrastructureScreenState createState() => _InfrastructureScreenState();
}

class _InfrastructureScreenState extends State<InfrastructureScreen> {
  // Approach Roads fields
  bool _hasApproachRoads = false;
  String _numApproachRoads = '';
  String _approachCondition = '';
  String _approachRemarks = '';
  
  // Internal Lanes fields
  bool _hasInternalLanes = false;
  String _numInternalLanes = '';
  String _internalCondition = '';
  String _internalRemarks = '';
  
  // Controllers
  final TextEditingController approachRoadsController = TextEditingController();
  final TextEditingController internalLanesController = TextEditingController();
  final TextEditingController approachRemarksController = TextEditingController();
  final TextEditingController internalRemarksController = TextEditingController();
  
  // Condition options
  final List<String> _conditionOptions = ['Good', 'Bad'];
  String? _selectedApproachCondition;
  String? _selectedInternalCondition;

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InfrastructureAvailabilityScreen()),
    );
  }

  void _goToPreviousScreen() {
    // Navigate back to VillageFormScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => VillageFormScreen()),
    );
  }

  Widget _buildInfrastructureContent() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Approach Roads Section
        QuestionCard(
          question: l10n.approachRoads,
          description: l10n.availabilityConditionApproachRoads,
          child: Column(
            children: [
              // Availability Radio
              RadioOptionGroup(
                label: l10n.areApproachRoadsAvailable,
                options: [l10n.yes, l10n.no],
                selectedValue: _hasApproachRoads ? l10n.yes : l10n.no,
                onChanged: (value) {
                  setState(() {
                    _hasApproachRoads = value == l10n.yes;
                    if (!_hasApproachRoads) {
                      approachRoadsController.clear();
                      _selectedApproachCondition = null;
                      approachRemarksController.clear();
                      _numApproachRoads = '';
                      _approachCondition = '';
                      _approachRemarks = '';
                    }
                  });
                },
              ),

              SizedBox(height: 15),

              // Conditional fields (only show if approach roads are available)
              if (_hasApproachRoads) ...[
                // Number of Approach Roads
                NumberInput(
                  label: l10n.numberOfApproachRoads,
                  controller: approachRoadsController,
                  prefixIcon: Icons.numbers,
                  onChanged: (value) {
                    setState(() {
                      _numApproachRoads = value ?? '';
                    });
                  },
                ),

                SizedBox(height: 15),

                // Condition Dropdown
                DropdownInput(
                  label: l10n.conditionOfApproachRoads,
                  value: _selectedApproachCondition,
                  items: _conditionOptions,
                  prefixIcon: Icons.assessment,
                  onChanged: (value) {
                    setState(() {
                      _selectedApproachCondition = value;
                      _approachCondition = value ?? '';
                    });
                  },
                ),

                SizedBox(height: 15),

                // Remarks
                TextInput(
                  label: l10n.remarksIfAny,
                  controller: approachRemarksController,
                  prefixIcon: Icons.note,
                  isRequired: false,
                  onChanged: (value) {
                    _approachRemarks = value ?? '';
                  },
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 25),

        // Internal Lanes Section
        QuestionCard(
          question: l10n.internalLanes,
          description: l10n.availabilityConditionInternalLanes,
          child: Column(
            children: [
              // Availability Radio
              RadioOptionGroup(
                label: l10n.areInternalLanesAvailable,
                options: [l10n.yes, l10n.no],
                selectedValue: _hasInternalLanes ? l10n.yes : l10n.no,
                onChanged: (value) {
                  setState(() {
                    _hasInternalLanes = value == l10n.yes;
                    if (!_hasInternalLanes) {
                      internalLanesController.clear();
                      _selectedInternalCondition = null;
                      internalRemarksController.clear();
                      _numInternalLanes = '';
                      _internalCondition = '';
                      _internalRemarks = '';
                    }
                  });
                },
              ),

              SizedBox(height: 15),

              // Conditional fields (only show if internal lanes are available)
              if (_hasInternalLanes) ...[
                // Number of Internal Lanes
                NumberInput(
                  label: l10n.numberOfInternalLanes,
                  controller: internalLanesController,
                  prefixIcon: Icons.numbers,
                  onChanged: (value) {
                    setState(() {
                      _numInternalLanes = value ?? '';
                    });
                  },
                ),

                SizedBox(height: 15),

                // Condition Dropdown
                DropdownInput(
                  label: l10n.conditionOfInternalLanes,
                  value: _selectedInternalCondition,
                  items: _conditionOptions,
                  prefixIcon: Icons.assessment,
                  onChanged: (value) {
                    setState(() {
                      _selectedInternalCondition = value;
                      _internalCondition = value ?? '';
                    });
                  },
                ),

                SizedBox(height: 15),

                // Remarks
                TextInput(
                  label: l10n.remarksIfAny,
                  controller: internalRemarksController,
                  prefixIcon: Icons.note,
                  isRequired: false,
                  onChanged: (value) {
                    _internalRemarks = value ?? '';
                  },
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 20),


      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormTemplateScreen(
      title: l10n.infrastructureInformation,
      stepNumber: 'Step 2',
      nextScreenRoute: '/infrastructure-availability',
      nextScreenName: 'Availability of Infrastructure',
      icon: Icons.engineering,
      instructions: l10n.availabilityApproachRoadsInternalLanes,
      contentWidget: _buildInfrastructureContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen, onReset: () {  }, // Add back button callback
    );
  }

  @override
  void dispose() {
    approachRoadsController.dispose();
    internalLanesController.dispose();
    approachRemarksController.dispose();
    internalRemarksController.dispose();
    super.dispose();
  }
}
