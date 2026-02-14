import 'package:flutter/material.dart';

class FamilyDetailsPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final void Function(Map<String, dynamic>) onDataChanged;
  final GlobalKey<FormState>? formKey;

  const FamilyDetailsPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
    this.formKey,
  });

  @override
  State<FamilyDetailsPage> createState() => _FamilyDetailsPageState();
}

class _FamilyDetailsPageState extends State<FamilyDetailsPage> {
  late List<Map<String, dynamic>> _members;

  @override
  void initState() {
    super.initState();
    _members = _initializeMembers();
  }

  @override
  void didUpdateWidget(covariant FamilyDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if parent data changed (navigation back/forth)
    _members = _initializeMembers();
  }

  List<Map<String, dynamic>> _initializeMembers() {
    final existing = widget.pageData['family_members'];
    if (existing != null && existing is List && existing.isNotEmpty) {
      // Deep-copy maps from any read-only query results (e.g., sqflite QueryRow)
      return existing.map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return Map<String, dynamic>.from(e);
        return Map<String, dynamic>.from(Map.of(e as Map));
      }).toList();
    }
    return [_createEmptyMember(1)];
  }

  Map<String, dynamic> _createEmptyMember(int srNo) {
    return {
      'sr_no': srNo,
      'name': '',
      'fathers_name': '',
      'mothers_name': '',
      'relationship_with_head': '',
      'age': '',
      'sex': null,
      'physically_fit': 'fit',
      'physically_fit_cause': '',
      'educational_qualification': '',
      'inclination_self_employment': '',
      'occupation': '',
      'days_employed': '',
      'income': '',
      'awareness_about_village': '',
      'participate_gram_sabha': '',
      // Insurance details
      'insured': 'no',
      'insurance_company': '',
    };
  }

  void _updateData() {
    // Ensure sr_no is correct for all items
    for (int i = 0; i < _members.length; i++) {
        _members[i]['sr_no'] = i + 1;
    }
    widget.onDataChanged({'family_members': _members});
  }

  void _addMember() {
    setState(() {
      _members.add(_createEmptyMember(_members.length + 1));
    });
    _updateData();
  }

  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
    });
    _updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Family Members' Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _members.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildMemberCard(index);
          },
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            onPressed: _addMember,
            icon: const Icon(Icons.add),
            label: const Text('Add Family Member'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMemberCard(int index) {
    final member = _members[index];
    final srNo = index + 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Member #$srNo',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                if (_members.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeMember(index),
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            // Name
            _buildTextField(
              label: 'Name',
              initialValue: member['name'],
              onChanged: (val) {
                member['name'] = val;
                _updateData();
              },
            ),

            // Father's Name
            _buildTextField(
              label: "Father's Name",
              initialValue: member['fathers_name'],
              onChanged: (val) {
                member['fathers_name'] = val;
                _updateData();
              },
            ),

            // Mother's Name
            _buildTextField(
              label: "Mother's Name",
              initialValue: member['mothers_name'],
              onChanged: (val) {
                member['mothers_name'] = val;
                _updateData();
              },
            ),

            // Relationship
            _buildDropdown(
              label: 'Relationship with Head',
              value: member['relationship_with_head']?.toString().isNotEmpty == true ? member['relationship_with_head'] : null,
              items: ['Self', 'Spouse', 'Son', 'Daughter', 'Father', 'Mother', 'Brother', 'Sister', 'Other'],
              onChanged: (val) {
                setState(() {
                  member['relationship_with_head'] = val;
                });
                _updateData();
              },
            ),

            // Age & Sex Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Age',
                    initialValue: member['age']?.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      member['age'] = val;
                      _updateData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    label: 'Sex',
                    value: member['sex'],
                    items: ['male', 'female', 'other'],
                    onChanged: (val) {
                      setState(() {
                        member['sex'] = val;
                      });
                      _updateData();
                    },
                  ),
                ),
              ],
            ),

            // Physically Fit
            _buildDropdown(
              label: 'Physically Fit/Unfit',
              value: member['physically_fit'],
              items: ['fit', 'unfit'],
              onChanged: (val) {
                setState(() {
                  member['physically_fit'] = val;
                  if (val == 'fit') {
                    member['physically_fit_cause'] = '';
                  }
                });
                _updateData();
              },
            ),

            // Cause (only if Unfit)
            if (member['physically_fit'] == 'unfit')
              _buildTextField(
                label: 'Cause of Unfitness',
                initialValue: member['physically_fit_cause'],
                onChanged: (val) {
                  member['physically_fit_cause'] = val;
                  _updateData();
                },
              ),

            // Educational Qualification
            _buildDropdown(
              label: 'Educational Qualification',
              value: member['educational_qualification']?.toString().isNotEmpty == true ? member['educational_qualification'] : null,
              items: [
                'Illiterate',
                'Primary (1-5)',
                'Middle (6-8)',
                'Secondary (9-10)',
                'Higher Secondary (11-12)',
                'Graduate',
                'Post Graduate',
                'PhD',
                'Other'
              ],
              onChanged: (val) {
                setState(() {
                  member['educational_qualification'] = val;
                });
                _updateData();
              },
            ),

            // Inclination Toward Self Employment
            _buildDropdown(
              label: 'Inclination Toward Self Employment',
              value: member['inclination_self_employment']?.toString().isNotEmpty == true ? member['inclination_self_employment'] : null,
              items: ['yes', 'no', 'maybe'],
              onChanged: (val) {
                setState(() {
                  member['inclination_self_employment'] = val;
                });
                _updateData();
              },
            ),

            // Occupation
            _buildTextField(
              label: 'Occupation',
              initialValue: member['occupation'],
              onChanged: (val) {
                member['occupation'] = val;
                _updateData();
              },
            ),

            // Days Employed & Income Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'No. of Days Employed',
                    initialValue: member['days_employed']?.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      member['days_employed'] = val;
                      _updateData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Income',
                    initialValue: member['income']?.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      member['income'] = val;
                      _updateData();
                    },
                  ),
                ),
              ],
            ),

            // Awareness About the Village
            _buildDropdown(
              label: 'Awareness About the Village',
              value: member['awareness_about_village']?.toString().isNotEmpty == true ? member['awareness_about_village'] : null,
              items: ['high', 'medium', 'low', 'none'],
              onChanged: (val) {
                setState(() {
                  member['awareness_about_village'] = val;
                });
                _updateData();
              },
            ),

            // Participate in Gram Sabha Meetings
            _buildDropdown(
              label: 'Participate in Gram Sabha Meetings',
              value: member['participate_gram_sabha']?.toString().isNotEmpty == true ? member['participate_gram_sabha'] : null,
              items: ['regularly', 'sometimes', 'rarely', 'never'],
              onChanged: (val) {
                setState(() {
                  member['participate_gram_sabha'] = val;
                });
                _updateData();
              },
            ),

            // Insured?
            _buildDropdown(
              label: 'Insured',
              value: member['insured']?.toString().isNotEmpty == true ? member['insured'] : 'no',
              items: ['yes', 'no'],
              onChanged: (val) {
                setState(() {
                  member['insured'] = val;
                  if (val != 'yes') member['insurance_company'] = '';
                });
                _updateData();
              },
            ),

            // Insurance Company (only if insured)
            if (member['insured'] == 'yes')
              _buildTextField(
                label: 'Insurance Company',
                initialValue: member['insurance_company'],
                onChanged: (val) {
                  member['insurance_company'] = val;
                  _updateData();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String? initialValue,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        // Simple validation can be added here
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}


