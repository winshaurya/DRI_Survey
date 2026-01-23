import 'package:flutter/material.dart';
import '../form_template.dart'; // Import the form template
import 'infrastructure_availability_screen.dart';
import 'housing_screen.dart'; // Import the previous screen

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
    // Navigate back to HousingScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HousingScreen()),
    );
  }

  Widget _buildInfrastructureContent() {
    return Column(
      children: [
        // Approach Roads Section
        QuestionCard(
          question: ' Approach Roads',
          description: 'Availability and condition of approach roads to village',
          child: Column(
            children: [
              // Availability Radio
              RadioOptionGroup(
                label: 'Are Approach Roads available?',
                options: ['Yes', 'No'],
                selectedValue: _hasApproachRoads ? 'Yes' : 'No',
                onChanged: (value) {
                  setState(() {
                    _hasApproachRoads = value == 'Yes';
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
                  label: 'Number of Approach Roads',
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
                  label: 'Condition of Approach Roads',
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
                  label: 'Remarks (if any)',
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
          question: ' Internal Lanes',
          description: 'Availability and condition of internal lanes in village',
          child: Column(
            children: [
              // Availability Radio
              RadioOptionGroup(
                label: 'Are Internal Lanes available?',
                options: ['Yes', 'No'],
                selectedValue: _hasInternalLanes ? 'Yes' : 'No',
                onChanged: (value) {
                  setState(() {
                    _hasInternalLanes = value == 'Yes';
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
                  label: 'Number of Internal Lanes',
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
                  label: 'Condition of Internal Lanes',
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
                  label: 'Remarks (if any)',
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
    return FormTemplateScreen(
      title: 'Infrastructure Information',
      stepNumber: 'Step 5',
      nextScreenRoute: '/infrastructure-availability',
      nextScreenName: 'Infrastructure Availability',
      icon: Icons.engineering,
      instructions: 'Availability of Approach Roads and Internal Lanes',
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