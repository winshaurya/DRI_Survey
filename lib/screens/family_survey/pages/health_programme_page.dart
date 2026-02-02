import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class HealthProgrammePage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const HealthProgrammePage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<HealthProgrammePage> createState() => _HealthProgrammePageState();
}

class _HealthProgrammePageState extends State<HealthProgrammePage> {
  String? _selectedFamilyMember;
  List<String> _familyMembers = [];

  // Pregnancy Vaccination
  String? _pregnancyVaccination;

  // Child Vaccination
  String? _childVaccination;
  String? _vaccinationSchedule;
  String? _balanceDosesSchedule;

  // Family Planning
  String? _familyPlanningAwareness;
  String? _contraceptiveApplied;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Load existing data from pageData
    final existingData = widget.pageData;

    setState(() {
      _pregnancyVaccination = existingData['vaccination_pregnancy'];
      _childVaccination = existingData['child_vaccination'];
      _vaccinationSchedule = existingData['vaccination_schedule'];
      _balanceDosesSchedule = existingData['balance_doses_schedule'];
      _familyPlanningAwareness = existingData['family_planning_awareness'];
      _contraceptiveApplied = existingData['contraceptive_applied'];
    });

    // Load family members
    _loadFamilyMembers();
  }

  void _loadFamilyMembers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final familyMembersData = widget.pageData['family_members'] as List<dynamic>? ?? [];

      if (familyMembersData.isNotEmpty && mounted) {
        final members = familyMembersData
            .map((member) => member['name'] as String)
            .where((name) => name.isNotEmpty)
            .toList();

        if (_familyMembers != members) {
          setState(() {
            _familyMembers = members;
          });
        }
      }
    });
  }

  void _updateData() {
    final data = {
      'vaccination_pregnancy': _pregnancyVaccination,
      'child_vaccination': _childVaccination,
      'vaccination_schedule': _vaccinationSchedule,
      'balance_doses_schedule': _balanceDosesSchedule,
      'family_planning_awareness': _familyPlanningAwareness,
      'contraceptive_applied': _contraceptiveApplied,
    };
    widget.onDataChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              'Health Programme Implemented',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Record information about health programmes and vaccinations in the family',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),

          // Family Member Selection
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Family Member',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the family member for whom you are recording health programme information',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedFamilyMember,
                      decoration: InputDecoration(
                        labelText: 'Family Member Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: _familyMembers.map((member) {
                        return DropdownMenuItem<String>(
                          value: member,
                          child: Text(member),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedFamilyMember = value);
                        _updateData();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Pregnancy Vaccination
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'a) Vaccination During Pregnancy',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Was vaccination done during pregnancy?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: ['Yes', 'No'].map((option) {
                        return RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: _pregnancyVaccination,
                          activeColor: Colors.pink,
                          onChanged: (value) {
                            setState(() => _pregnancyVaccination = value);
                            _updateData();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Child Vaccination
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'b) Child Vaccination',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Was child vaccination completed?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: ['Yes', 'No'].map((option) {
                        return RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: _childVaccination,
                          activeColor: Colors.blue,
                          onChanged: (value) {
                            setState(() {
                              _childVaccination = value;
                              // Reset dependent fields when changing main selection
                              if (value == 'No') {
                                _vaccinationSchedule = null;
                                _balanceDosesSchedule = null;
                              }
                            });
                            _updateData();
                          },
                        );
                      }).toList(),
                    ),

                    // Conditional fields for "Yes"
                    if (_childVaccination == 'Yes') ...[
                      const SizedBox(height: 16),
                      Text(
                        'Schedule of Vaccination',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: ['Completed', 'Not Completed'].map((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _vaccinationSchedule,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              setState(() {
                                _vaccinationSchedule = value;
                                // Reset balance doses if completed
                                if (value == 'Completed') {
                                  _balanceDosesSchedule = null;
                                }
                              });
                              _updateData();
                            },
                          );
                        }).toList(),
                      ),

                      // Balance doses schedule for "Not Completed"
                      if (_vaccinationSchedule == 'Not Completed') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _balanceDosesSchedule,
                          decoration: InputDecoration(
                            labelText: 'If not completed, balance doses schedule',
                            hintText: 'Describe remaining vaccination schedule',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.schedule),
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            setState(() => _balanceDosesSchedule = value);
                            _updateData();
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Family Planning Awareness
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'c) Awareness About Family Planning',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Is there awareness about family planning?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: ['Yes', 'No'].map((option) {
                        return RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: _familyPlanningAwareness,
                          activeColor: Colors.purple,
                          onChanged: (value) {
                            setState(() {
                              _familyPlanningAwareness = value;
                              // Reset dependent field when changing main selection
                              if (value == 'No') {
                                _contraceptiveApplied = null;
                              }
                            });
                            _updateData();
                          },
                        );
                      }).toList(),
                    ),

                    // Conditional field for "Yes"
                    if (_familyPlanningAwareness == 'Yes') ...[
                      const SizedBox(height: 16),
                      Text(
                        'If yes, Contraceptive Method Applied or Not',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: ['Applied', 'Not Applied'].map((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _contraceptiveApplied,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              setState(() => _contraceptiveApplied = value);
                              _updateData();
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}