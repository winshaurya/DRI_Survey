import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/survey_provider.dart';

class ChildrenPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const ChildrenPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<ChildrenPage> createState() => _ChildrenPageState();
}

class _ChildrenPageState extends ConsumerState<ChildrenPage> {
  // Local state variables matching the _pageData keys
  String? _birthsLast3Years;
  String? _infantDeathsLast3Years;
  String? _malnourishedChildren;

  // Child malnutrition data - now supports multiple children with multiple diseases
  List<Map<String, dynamic>> _malnourishedChildrenData = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _birthsLast3Years = widget.pageData['births_last_3_years'];
    _infantDeathsLast3Years = widget.pageData['infant_deaths_last_3_years'];
    _malnourishedChildren = widget.pageData['malnourished_children'];

    // Initialize malnourished children data
    if (widget.pageData['malnourished_children_data'] != null) {
      _malnourishedChildrenData = _toListOfMap(widget.pageData['malnourished_children_data']);
    } else {
      _malnourishedChildrenData = [];
    }
  }

  void _updateData() {
    final data = {
      'births_last_3_years': _birthsLast3Years,
      'infant_deaths_last_3_years': _infantDeathsLast3Years,
      'malnourished_children': _malnourishedChildren,
      'malnourished_children_data': _malnourishedChildrenData,
    };
    widget.onDataChanged(data);
  }

  // Get family members under 19 years old
  List<Map<String, dynamic>> _getChildrenUnder19() {
    final surveyData = ref.read(surveyProvider).surveyData;
    final familyMembers = _toListOfMap(surveyData['family_members']);

    return familyMembers.where((member) {
      final age = int.tryParse(member['age']?.toString() ?? '');
      return age != null && age < 19;
    }).toList();
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
              l10n.childrenData,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Please provide information about children in the family',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),

          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: TextFormField(
              initialValue: _birthsLast3Years,
              decoration: InputDecoration(
                labelText: l10n.birthsLast3Years,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.child_care),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _birthsLast3Years = value;
                _updateData();
              },
            ),
          ),

          const SizedBox(height: 16),

          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: TextFormField(
              initialValue: _infantDeathsLast3Years,
              decoration: InputDecoration(
                labelText: l10n.infantDeathsLast3Years,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.warning_amber_rounded),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _infantDeathsLast3Years = value;
                _updateData();
              },
            ),
          ),

          const SizedBox(height: 16),

          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: TextFormField(
              initialValue: _malnourishedChildren,
              decoration: InputDecoration(
                labelText: l10n.malnourishedChildren,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.sick),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _malnourishedChildren = value;
                _updateData();
              },
            ),
          ),

          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Text(
              l10n.malnutritionData,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Malnourished children data - dynamic list
          ..._buildMalnourishedChildrenCards(l10n),

          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _addMalnourishedChild,
                icon: const Icon(Icons.add),
                label: const Text('Add Malnourished Child'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMalnourishedChildrenCards(AppLocalizations l10n) {
    return _malnourishedChildrenData.asMap().entries.map((entry) {
      final index = entry.key;
      final childData = entry.value;
      return _buildMalnourishedChildCard(index, childData, l10n);
    }).toList();
  }

  Widget _buildMalnourishedChildCard(int index, Map<String, dynamic> childData, AppLocalizations l10n) {
    final childrenUnder19 = _getChildrenUnder19();
    final selectedChildId = childData['child_id'];
    final diseases = _toListOfMap(childData['diseases']);

    return FadeInUp(
      delay: Duration(milliseconds: 600 + (index * 100)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Malnourished Child ${index + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeMalnourishedChild(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Remove this child',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Child selection dropdown
              DropdownButtonFormField<String>(
                initialValue: selectedChildId,
                decoration: InputDecoration(
                  labelText: 'Select Child',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.child_care),
                ),
                items: childrenUnder19.map((child) {
                  final name = child['name'] ?? 'Unknown';
                  final age = child['age'] ?? '';
                  final gender = child['gender'] ?? '';
                  final displayText = '$name (Age: $age, $gender)';
                  return DropdownMenuItem<String>(
                    value: child['id']?.toString() ?? name,
                    child: Text(displayText),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    childData['child_id'] = value;
                    _updateData();
                  });
                },
              ),

              const SizedBox(height: 16),

              // Height and Weight
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: childData['height']?.toString(),
                      decoration: InputDecoration(
                        labelText: '${l10n.height} (cm)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.height),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        childData['height'] = value;
                        _updateData();
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: TextFormField(
                      initialValue: childData['weight']?.toString(),
                      decoration: InputDecoration(
                        labelText: '${l10n.weight} (kg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        childData['weight'] = value;
                        _updateData();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Diseases section
              Text(
                'Diseases/Conditions',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // List of diseases
              ...diseases.asMap().entries.map((diseaseEntry) {
                final diseaseIndex = diseaseEntry.key;
                final disease = diseaseEntry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: disease['name']?.toString(),
                          decoration: InputDecoration(
                            labelText: 'Disease ${diseaseIndex + 1}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.medical_services),
                          ),
                          onChanged: (value) {
                            disease['name'] = value;
                            _updateData();
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeDisease(index, diseaseIndex),
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        tooltip: 'Remove this disease',
                      ),
                    ],
                  ),
                );
              }),

              // Add disease button
              TextButton.icon(
                onPressed: () => _addDisease(index),
                icon: const Icon(Icons.add),
                label: const Text('Add Disease'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addMalnourishedChild() {
    setState(() {
      _malnourishedChildrenData.add({
        'child_id': null,
        'height': null,
        'weight': null,
        'diseases': [],
      });
      _updateData();
    });
  }

  void _removeMalnourishedChild(int index) {
    setState(() {
      _malnourishedChildrenData.removeAt(index);
      _updateData();
    });
  }

  void _addDisease(int childIndex) {
    setState(() {
      if (_malnourishedChildrenData[childIndex]['diseases'] == null) {
        _malnourishedChildrenData[childIndex]['diseases'] = [];
      }
      final list = _malnourishedChildrenData[childIndex]['diseases'];
      if (list is List<Map<String, dynamic>>) {
        list.add({'name': ''});
      } else if (list is List) {
        list.add({'name': ''});
      } else {
        _malnourishedChildrenData[childIndex]['diseases'] = [{'name': ''}];
      }
      _updateData();
    });
  }

  // Safe conversion helper: accepts null, List<dynamic>, or List<Map<..., ...>>
  List<Map<String, dynamic>> _toListOfMap(dynamic value) {
    if (value == null) return [];
    if (value is List<Map<String, dynamic>>) return value;
    if (value is List) {
      try {
        return value.map((e) {
          if (e is Map<String, dynamic>) return e;
          if (e is Map) return Map<String, dynamic>.from(e);
          return <String, dynamic>{};
        }).toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  void _removeDisease(int childIndex, int diseaseIndex) {
    setState(() {
      (_malnourishedChildrenData[childIndex]['diseases'] as List).removeAt(diseaseIndex);
      _updateData();
    });
  }
}