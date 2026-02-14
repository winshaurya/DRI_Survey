import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../l10n/app_localizations.dart';
import '../../form_template.dart';
import '../../services/database_service.dart';
import '../../services/sync_service.dart';
import 'infrastructure_availability_screen.dart';

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

  @override
  void initState() {
    super.initState();
    // Load saved infrastructure data for edit flows
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final databaseService = Provider.of<DatabaseService>(context, listen: false);
        final sessionId = databaseService.currentSessionId;
        if (sessionId == null) return;

        final rows = await databaseService.getVillageData('village_infrastructure', sessionId);
        if (rows.isNotEmpty) {
          final row = rows.first;
          setState(() {
            _hasApproachRoads = (row['approach_roads_available'] ?? 0) == 1;
            _numApproachRoads = (row['num_approach_roads'] ?? '').toString();
            _approachCondition = row['approach_condition'] ?? '';
            approachRoadsController.text = _numApproachRoads;
            approachRemarksController.text = row['approach_remarks'] ?? '';

            _hasInternalLanes = (row['internal_lanes_available'] ?? 0) == 1;
            _numInternalLanes = (row['num_internal_lanes'] ?? '').toString();
            _internalCondition = row['internal_condition'] ?? '';
            internalLanesController.text = _numInternalLanes;
            internalRemarksController.text = row['internal_remarks'] ?? '';

            _selectedApproachCondition = _approachCondition.isNotEmpty ? _approachCondition : null;
            _selectedInternalCondition = _internalCondition.isNotEmpty ? _internalCondition : null;
          });
        }
      } catch (e) {
        debugPrint('Error loading infrastructure data: $e');
      }
    });
  }

  Future<void> _submitForm() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
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
      'approach_roads_available': _hasApproachRoads ? 1 : 0,
      'num_approach_roads': int.tryParse(_numApproachRoads),
      'approach_condition': _approachCondition,
      'approach_remarks': _approachRemarks,
      'internal_lanes_available': _hasInternalLanes ? 1 : 0,
      'num_internal_lanes': int.tryParse(_numInternalLanes),
      'internal_condition': _internalCondition,
      'internal_remarks': _internalRemarks,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await databaseService.insertOrUpdate('village_infrastructure', data, sessionId);

      await databaseService.markVillagePageCompleted(sessionId, 1);
      unawaited(SyncService.instance.syncVillagePageData(sessionId, 1, data));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InfrastructureAvailabilityScreen()),
        );
      }
    } catch (e) {
      print('Error saving infrastructure data: $e');
      if (mounted) {
        // Proceed even on error to not block user
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InfrastructureAvailabilityScreen()),
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
