import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class FamilyDetailsPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;
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
  static const List<String> _memberFields = [
    'name',
    'fathers_name',
    'mothers_name',
    'relationship_with_head',
    'age',
    'sex',
    'physically_fit',
    'physically_fit_cause',
    'educational_qualification',
    'inclination_self_employment',
    'occupation',
    'days_employed',
    'income',
    'awareness_about_village',
    'participate_gram_sabha',
  ];

  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    _initializeFamilyMembersFromData();
  }

  void _initializeFamilyMembersFromData() {
    final memberCount = _determineMemberCount();
    final count = memberCount > 0 ? memberCount : 1;

    _familyMembers = List.generate(count, (index) {
      final id = index + 1;
      return {
        'id': id,
        'relation': id == 1 ? 'Head of Family' : 'Family Member $id',
        'isRequired': id == 1,
      };
    });

    widget.pageData['family_members_count'] = _familyMembers.length;
    widget.onDataChanged(widget.pageData);
  }

  int _determineMemberCount() {
    int maxIndex = widget.pageData['family_members_count'] is int
        ? widget.pageData['family_members_count'] as int
        : 0;

    final regex = RegExp(r'^member_(\d+)_');
    for (final key in widget.pageData.keys) {
      final match = regex.firstMatch(key);
      if (match != null) {
        final idx = int.tryParse(match.group(1) ?? '');
        if (idx != null && idx > maxIndex) {
          maxIndex = idx;
        }
      }
    }

    return maxIndex;
  }

  List<Map<String, dynamic>> _buildMemberDataSnapshot() {
    return _familyMembers
        .map((member) {
          final id = member['id'] as int;
          return {
            for (final field in _memberFields) field: widget.pageData['member_${id}_$field'],
          };
        })
        .toList();
  }

  void _rewriteMemberData(List<Map<String, dynamic>> snapshot) {
    final keysToRemove = widget.pageData.keys.where((k) => k.startsWith('member_')).toList();
    for (final key in keysToRemove) {
      widget.pageData.remove(key);
    }

    for (int i = 0; i < snapshot.length; i++) {
      final memberIndex = i + 1;
      final data = snapshot[i];
      for (final field in _memberFields) {
        final value = data[field];
        if (value != null && (value is String ? value.isNotEmpty : true)) {
          widget.pageData['member_${memberIndex}_${field}'] = value;
        }
      }
    }

    widget.pageData['family_members_count'] = _familyMembers.length;
    widget.onDataChanged(widget.pageData);
  }

  void _addFamilyMember() {
    setState(() {
      final newId = _familyMembers.length + 1;
      _familyMembers.add({
        'id': newId,
        'relation': 'Family Member $newId',
        'isRequired': false,
      });

      widget.pageData['family_members_count'] = _familyMembers.length;
      widget.onDataChanged(widget.pageData);
    });
  }

  void _removeFamilyMember(int index) {
    if (_familyMembers.length > 1) {
      final snapshot = _buildMemberDataSnapshot();
      if (index >= 0 && index < snapshot.length) {
        snapshot.removeAt(index);
      }

      setState(() {
        _familyMembers.removeAt(index);

        for (int i = 0; i < _familyMembers.length; i++) {
          final id = i + 1;
          _familyMembers[i]['id'] = id;
          _familyMembers[i]['relation'] = id == 1 ? 'Head of Family' : 'Family Member $id';
          _familyMembers[i]['isRequired'] = id == 1;
        }

        _rewriteMemberData(snapshot);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: widget.formKey ?? _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.familyDetails,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            l10n.provideDetailsForEachFamilyMember,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 17),

          // Family Members
          ..._familyMembers.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            return Column(
              children: [
                _buildFamilyMemberCard(
                  member['id'],
                  member['relation'],
                  l10n,
                  isRequired: member['isRequired'],
                  onRemove: _familyMembers.length > 1 ? () => _removeFamilyMember(index) : null,
                ),
                const SizedBox(height: 11),
              ],
            );
          }),

          const SizedBox(height: 11),

          // Add more family members
          ElevatedButton.icon(
            onPressed: _addFamilyMember,
            icon: const Icon(Icons.add),
            label: Text(l10n.addMember),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 11),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.family_restroom, color: Colors.green[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.totalFamilyMembers(_familyMembers.length.toString()),
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion, int memberNumber, String fieldKey) {
    return InkWell(
      onTap: () {
        setState(() {
          widget.pageData['member_${memberNumber}_${fieldKey}'] = suggestion;
          widget.onDataChanged(widget.pageData);
        });
      },
      child: Chip(
        label: Text(suggestion),
        backgroundColor: Colors.green[50],
        labelStyle: TextStyle(color: Colors.green[700]),
      ),
    );
  }

  Widget _buildFamilyMemberCard(int memberNumber, String relation, AppLocalizations l10n, {bool isRequired = false, VoidCallback? onRemove}) {
    return Card(
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
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    memberNumber.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$relation ${isRequired ? l10n.required : ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onRemove != null && memberNumber > 1) // Don't allow deletion of head of family
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: l10n.removeMember,
                  ),
              ],
            ),
            const SizedBox(height: 11),

            // Name
            TextFormField(
              initialValue: widget.pageData['member_${memberNumber}_name'],
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              onChanged: (value) {
                widget.pageData['member_${memberNumber}_name'] = value;
                widget.onDataChanged(widget.pageData);
              },
            ),

            const SizedBox(height: 11),

            // Father's Name and Mother's Name
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.pageData['member_${memberNumber}_fathers_name'],
                    decoration: InputDecoration(
                      labelText: "Father's Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    onChanged: (value) {
                      widget.pageData['member_${memberNumber}_fathers_name'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.pageData['member_${memberNumber}_mothers_name'],
                    decoration: InputDecoration(
                      labelText: "Mother's Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    onChanged: (value) {
                      widget.pageData['member_${memberNumber}_mothers_name'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 11),

            // Relationship with Head of Family (text input with suggestions)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: widget.pageData['member_${memberNumber}_relationship_with_head'],
                  decoration: InputDecoration(
                    labelText: 'Relationship with Head of Family',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.family_restroom),
                  ),
                  onChanged: (value) {
                    widget.pageData['member_${memberNumber}_relationship_with_head'] = value;
                    widget.onDataChanged(widget.pageData);
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildSuggestionChip('Self', memberNumber, 'relationship_with_head'),
                    _buildSuggestionChip('Spouse', memberNumber, 'relationship_with_head'),
                    _buildSuggestionChip('Son', memberNumber, 'relationship_with_head'),
                    _buildSuggestionChip('Daughter', memberNumber, 'relationship_with_head'),
                    _buildSuggestionChip('Father', memberNumber, 'relationship_with_head'),
                    _buildSuggestionChip('Mother', memberNumber, 'relationship_with_head'),
                    _buildSuggestionChip('Brother', memberNumber, 'relationship_with_head'),
                    _buildSuggestionChip('Sister', memberNumber, 'relationship_with_head'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 11),

            // Age and Sex
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.pageData['member_${memberNumber}_age'],
                    decoration: InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.pageData['member_${memberNumber}_age'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: widget.pageData['member_${memberNumber}_sex'],
                    decoration: InputDecoration(
                      labelText: 'Sex',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.wc),
                    ),
                    items: [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      widget.pageData['member_${memberNumber}_sex'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 11),

            // Physically Fit/Unfit (radio with cause)
            Text(
              'Physically Fit/Unfit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RadioListTile<String>(
                  title: const Text('Fit'),
                  value: 'fit',
                  groupValue: widget.pageData['member_${memberNumber}_physically_fit'],
                  onChanged: (value) {
                    setState(() {
                      widget.pageData['member_${memberNumber}_physically_fit'] = value;
                      widget.onDataChanged(widget.pageData);
                    });
                  },
                  activeColor: Colors.green,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                RadioListTile<String>(
                  title: const Text('Unfit'),
                  value: 'unfit',
                  groupValue: widget.pageData['member_${memberNumber}_physically_fit'],
                  onChanged: (value) {
                    setState(() {
                      widget.pageData['member_${memberNumber}_physically_fit'] = value;
                      widget.onDataChanged(widget.pageData);
                    });
                  },
                  activeColor: Colors.green,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),

            // Cause if unfit
            if (widget.pageData['member_${memberNumber}_physically_fit'] == 'unfit')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  initialValue: widget.pageData['member_${memberNumber}_physically_fit_cause'],
                  decoration: InputDecoration(
                    labelText: 'Cause of Unfitness',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.medical_services),
                  ),
                  onChanged: (value) {
                    widget.pageData['member_${memberNumber}_physically_fit_cause'] = value;
                    widget.onDataChanged(widget.pageData);
                  },
                ),
              ),

            const SizedBox(height: 11),

            // Educational Qualification (text input with suggestions)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: widget.pageData['member_${memberNumber}_educational_qualification'],
                  decoration: InputDecoration(
                    labelText: 'Educational Qualification',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.school),
                  ),
                  onChanged: (value) {
                    widget.pageData['member_${memberNumber}_educational_qualification'] = value;
                    widget.onDataChanged(widget.pageData);
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildSuggestionChip('Illiterate', memberNumber, 'educational_qualification'),
                    _buildSuggestionChip('Primary (1-5)', memberNumber, 'educational_qualification'),
                    _buildSuggestionChip('Middle (6-8)', memberNumber, 'educational_qualification'),
                    _buildSuggestionChip('Secondary (9-10)', memberNumber, 'educational_qualification'),
                    _buildSuggestionChip('Higher Secondary (11-12)', memberNumber, 'educational_qualification'),
                    _buildSuggestionChip('Graduate', memberNumber, 'educational_qualification'),
                    _buildSuggestionChip('Post Graduate', memberNumber, 'educational_qualification'),
                    _buildSuggestionChip('PhD', memberNumber, 'educational_qualification'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 11),

            // Inclination Toward Self Employment
            DropdownButtonFormField<String>(
              value: widget.pageData['member_${memberNumber}_inclination_self_employment'],
              decoration: InputDecoration(
                labelText: 'Inclination Toward Self Employment',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.business),
              ),
              items: [
                DropdownMenuItem(value: 'yes', child: Text('Yes')),
                DropdownMenuItem(value: 'no', child: Text('No')),
                DropdownMenuItem(value: 'maybe', child: Text('Maybe')),
              ],
              onChanged: (value) {
                widget.pageData['member_${memberNumber}_inclination_self_employment'] = value;
                widget.onDataChanged(widget.pageData);
              },
            ),

            const SizedBox(height: 11),

            // Occupation
            TextFormField(
              initialValue: widget.pageData['member_${memberNumber}_occupation'],
              decoration: InputDecoration(
                labelText: 'Occupation',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.work),
              ),
              onChanged: (value) {
                widget.pageData['member_${memberNumber}_occupation'] = value;
                widget.onDataChanged(widget.pageData);
              },
            ),

            const SizedBox(height: 11),

            // No. of Days Employed and Income
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.pageData['member_${memberNumber}_days_employed'],
                    decoration: InputDecoration(
                      labelText: 'No. of Days Employed',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_view_day),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.pageData['member_${memberNumber}_days_employed'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.pageData['member_${memberNumber}_income'],
                    decoration: InputDecoration(
                      labelText: 'Income (₹)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.currency_rupee),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.pageData['member_${memberNumber}_income'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 11),

            // Awareness About the Village
            DropdownButtonFormField<String>(
              value: widget.pageData['member_${memberNumber}_awareness_about_village'],
              decoration: InputDecoration(
                labelText: 'Awareness About the Village',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_city),
              ),
              items: [
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'none', child: Text('None')),
              ],
              onChanged: (value) {
                widget.pageData['member_${memberNumber}_awareness_about_village'] = value;
                widget.onDataChanged(widget.pageData);
              },
            ),

            const SizedBox(height: 11),

            // Participate in Gram Sabha Meetings
            DropdownButtonFormField<String>(
              value: widget.pageData['member_${memberNumber}_participate_gram_sabha'],
              decoration: InputDecoration(
                labelText: 'Participate in Gram Sabha Meetings',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.group),
              ),
              items: [
                DropdownMenuItem(value: 'regularly', child: Text('Regularly')),
                DropdownMenuItem(value: 'sometimes', child: Text('Sometimes')),
                DropdownMenuItem(value: 'rarely', child: Text('Rarely')),
                DropdownMenuItem(value: 'never', child: Text('Never')),
              ],
              onChanged: (value) {
                widget.pageData['member_${memberNumber}_participate_gram_sabha'] = value;
                widget.onDataChanged(widget.pageData);
              },
            ),
          ],
        ),
      ),
    );
  }
}
