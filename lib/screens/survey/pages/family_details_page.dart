import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class FamilyDetailsPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const FamilyDetailsPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<FamilyDetailsPage> createState() => _FamilyDetailsPageState();
}

class _FamilyDetailsPageState extends State<FamilyDetailsPage> {
  List<Map<String, dynamic>> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    // Initialize with at least one family member (head of family)
    if (_familyMembers.isEmpty) {
      _familyMembers.add({
        'id': 1,
        'relation': 'Head of Family',
        'isRequired': true,
      });
    }
  }

  void _addFamilyMember() {
    setState(() {
      final newId = _familyMembers.length + 1;
      _familyMembers.add({
        'id': newId,
        'relation': 'Family Member $newId',
        'isRequired': false,
      });
    });
  }

  void _removeFamilyMember(int index) {
    if (_familyMembers.length > 1) {
      setState(() {
        _familyMembers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
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
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: l10n.removeMember,
                  ),
              ],
            ),
            const SizedBox(height: 11),

            TextFormField(
              initialValue: widget.pageData['member_${memberNumber}_name'],
              decoration: InputDecoration(
                labelText: '${l10n.memberName} *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                // Removed required validation to allow passing without filling
                return null;
              },
              onChanged: (value) {
                widget.pageData['member_${memberNumber}_name'] = value;
                widget.onDataChanged(widget.pageData);
              },
            ),

            const SizedBox(height: 11),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.pageData['member_${memberNumber}_age'],
                    decoration: InputDecoration(
                      labelText: '${l10n.age} *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      // Removed required validation to allow passing without filling
                      final age = int.tryParse(value ?? '');
                      if (age != null && (age < 0 || age > 120)) {
                        return l10n.pleaseEnterValidAge;
                      }
                      return null;
                    },
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
                      labelText: '${l10n.sex} *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.wc),
                    ),
                    items: [
                      DropdownMenuItem(value: 'male', child: Text(l10n.male)),
                      DropdownMenuItem(value: 'female', child: Text(l10n.female)),
                      DropdownMenuItem(value: 'other', child: Text(l10n.other)),
                    ],
                    validator: (value) {
                      // Removed required validation to allow passing without filling
                      return null;
                    },
                    onChanged: (value) {
                      widget.pageData['member_${memberNumber}_sex'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 11),

            TextFormField(
              initialValue: widget.pageData['member_${memberNumber}_relation'],
              decoration: InputDecoration(
                labelText: l10n.relation,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.family_restroom),
              ),
              onChanged: (value) {
                widget.pageData['member_${memberNumber}_relation'] = value;
                widget.onDataChanged(widget.pageData);
              },
            ),

            const SizedBox(height: 11),

            TextFormField(
              initialValue: widget.pageData['member_${memberNumber}_education'],
              decoration: InputDecoration(
                labelText: l10n.education,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.school),
              ),
              onChanged: (value) {
                widget.pageData['member_${memberNumber}_education'] = value;
                widget.onDataChanged(widget.pageData);
              },
            ),

            const SizedBox(height: 11),

            TextFormField(
              initialValue: widget.pageData['member_${memberNumber}_occupation'],
              decoration: InputDecoration(
                labelText: l10n.occupation,
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
          ],
        ),
      ),
    );
  }
}
