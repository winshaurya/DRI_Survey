import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class FamilySchemeDataWidget extends StatefulWidget {
  final String title;
  final List<String> familyMemberNames;
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onDataChanged;

  // Configuration flags
  final bool showBeneficiaryCheck;
  final bool showNameIncluded;
  final bool showDetailsCorrect;
  final bool showReceived;
  final bool showDays;
  final bool showBankAccounts;
  final String daysLabel;

  // Styling
  final Color? color;
  final IconData? icon;

  // Diseases specific flags
  final bool showDiseaseName;
  final bool showSufferingSince;
  final bool showTreatmentTaken;
  final bool showTreatmentFromWhen;
  final bool showTreatmentFromWhere;
  final bool showTreatmentTakenFrom;

  // Optional list for disease autocomplete
  final List<String>? diseaseOptions;

  const FamilySchemeDataWidget({
    Key? key,
    required this.title,
    required this.familyMemberNames,
    required this.data,
    required this.onDataChanged,
    this.showBeneficiaryCheck = true,
    this.showNameIncluded = true,
    this.showDetailsCorrect = true,
    this.showReceived = false,
    this.showDays = false,
    this.showBankAccounts = false,
    this.daysLabel = 'No. of days',
    this.color,
    this.icon,
    this.showDiseaseName = false,
    this.showSufferingSince = false,
    this.showTreatmentTaken = false,
    this.showTreatmentFromWhen = false,
    this.showTreatmentFromWhere = false,
    this.showTreatmentTakenFrom = false,
    this.diseaseOptions,
  }) : super(key: key);

  @override
  _FamilySchemeDataWidgetState createState() => _FamilySchemeDataWidgetState();
}

class _FamilySchemeDataWidgetState extends State<FamilySchemeDataWidget> {
  late bool _isBeneficiary;
  late List<Map<String, dynamic>> _members;

  @override
  void initState() {
    super.initState();
    _isBeneficiary = widget.data['is_beneficiary'] ?? false;
    _members = List<Map<String, dynamic>>.from(widget.data['members'] ?? []);
  }

  @override
  void didUpdateWidget(covariant FamilySchemeDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _isBeneficiary = widget.data['is_beneficiary'] ?? false;
      _members = List<Map<String, dynamic>>.from(widget.data['members'] ?? []);
    }
  }

  void _notifyChange() {
    widget.onDataChanged({
      'is_beneficiary': _isBeneficiary,
      'members': _members,
    });
  }

  void _addMember() {
    setState(() {
      _members.add({
        'sr_no': _members.length + 1,
        'name': '',
        'name_included': null,
        'details_correct': null,
        'incorrect_details': '',
        'received': null,
        'days': '',
        'bank_accounts': widget.showBankAccounts ? [] : null,
      });
      // Auto-set beneficiary to true if we add a member
      if (!_isBeneficiary) {
        _isBeneficiary = true;
      }
    });
    _notifyChange();
  }

  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
      // Re-index
      for (int i = 0; i < _members.length; i++) {
        _members[i]['sr_no'] = i + 1;
      }
       if (_members.isEmpty) {
        // Optional: toggle off beneficiary if list empty? Maybe not.
      }
    });
    _notifyChange();
  }

  void _addBankAccount(int memberIndex) {
    setState(() {
      if (_members[memberIndex]['bank_accounts'] == null) {
        _members[memberIndex]['bank_accounts'] = [];
      }
      (_members[memberIndex]['bank_accounts'] as List).add({
        'bank_name': '',
        'account_number': '',
        'ifsc_code': '',
        'branch_name': '',
        'account_type': '',
        'has_account': null,
        'details_correct': null,
        'incorrect_details': '',
      });
    });
    _notifyChange();
  }

  void _removeBankAccount(int memberIndex, int accountIndex) {
    setState(() {
      (_members[memberIndex]['bank_accounts'] as List).removeAt(accountIndex);
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.color ?? theme.colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          FadeInDown(
            child: Text(
              widget.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Enter details for ${widget.title} Scheme',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Main Section
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: _buildSectionHeader(
              'Beneficiary Status',
              'Is any family member a beneficiary?',
              widget.icon ?? Icons.card_membership,
              primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          if (widget.showBeneficiaryCheck) ...[
             Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _isBeneficiary,
                  onChanged: (val) {
                    setState(() {
                      _isBeneficiary = val!;
                      if (_isBeneficiary && _members.isEmpty) {
                        _addMember();
                      }
                    });
                    _notifyChange();
                  },
                ),
                const Text('Yes'),
                const SizedBox(width: 24),
                Radio<bool>(
                  value: false,
                  groupValue: _isBeneficiary,
                  onChanged: (val) {
                    setState(() {
                      _isBeneficiary = val!;
                      if (!_isBeneficiary) _members.clear();
                    });
                    _notifyChange();
                  },
                ),
                const Text('No'),
              ],
            ),
            const SizedBox(height: 16),
          ],

          if (_isBeneficiary || !widget.showBeneficiaryCheck) ...[
            if (_members.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No beneficiaries added yet.',
                    style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ),
              ),

            ...List.generate(
              _members.length,
              (index) => _buildMemberCard(context, index, primaryColor),
            ),
            
             const SizedBox(height: 16),
             Center(
              child: OutlinedButton.icon(
                onPressed: _addMember,
                icon: const Icon(Icons.add),
                label: const Text('Add Family Member'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  side: BorderSide(color: primaryColor),
                ),
              ),
            ),
             const SizedBox(height: 50),
             const SizedBox(height: 40),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, int index, Color color) {
    final member = _members[index];
    
    return FadeInUp(
      key: ValueKey('member_$index'), 
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header with Delete
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Beneficiary #${index + 1}',
                     style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  InkWell(
                    onTap: () => _showDeleteConfirmation(context, index),
                    child: const Icon(Icons.delete, color: Colors.grey, size: 20),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Content from original widget, adapted
              // Family Member Name Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Family Member',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                value: widget.familyMemberNames.contains(member['name']) ? member['name'] : null,
                items: widget.familyMemberNames.map((name) =>
                  DropdownMenuItem(value: name, child: Text(name))
                ).toList(),
                onChanged: (val) {
                  setState(() => member['name'] = val);
                  _notifyChange();
                },
              ),

              const SizedBox(height: 16),

              // Disease Name (if enabled)
              if (widget.showDiseaseName) ...[
                if (widget.diseaseOptions != null && widget.diseaseOptions!.isNotEmpty)
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: member['disease_name'] ?? ''),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return widget.diseaseOptions!;
                      }
                      return widget.diseaseOptions!.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      member['disease_name'] = selection;
                      _notifyChange();
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Disease Name',
                          hintText: 'Select or type disease',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        onChanged: (val) {
                          member['disease_name'] = val;
                          _notifyChange();
                        },
                      );
                    },
                  )
                else
                  TextFormField(
                    initialValue: member['disease_name'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Disease Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    onChanged: (val) {
                      member['disease_name'] = val;
                      _notifyChange();
                    },
                  ),
                const SizedBox(height: 16),
              ],

              // Suffering Since (if enabled)
              if (widget.showSufferingSince) ...[
                TextFormField(
                  initialValue: member['suffering_since'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Suffering Since (Date)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.today),
                  ),
                  onChanged: (val) {
                    member['suffering_since'] = val;
                    _notifyChange();
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Treatment Taken (if enabled)
              if (widget.showTreatmentTaken) ...[
                _buildSimpleRadio(
                  'Treatment Taken?',
                  member['treatment_taken'] ?? false,
                  (val) {
                    setState(() => member['treatment_taken'] = val);
                    _notifyChange();
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Treatment From When (if enabled)
              if (widget.showTreatmentFromWhen) ...[
                TextFormField(
                  initialValue: member['treatment_from_when'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Treatment From When (Date)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event),
                  ),
                  onChanged: (val) {
                    member['treatment_from_when'] = val;
                    _notifyChange();
                  },
                  
                ),
                const SizedBox(height: 16),
              ],

              // Treatment From Where (if enabled)
              if (widget.showTreatmentFromWhere) ...[
                TextFormField(
                  initialValue: member['treatment_from_where'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Treatment From Where',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  onChanged: (val) {
                    member['treatment_from_where'] = val;
                    _notifyChange();
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Treatment Taken From (if enabled)
              if (widget.showTreatmentTakenFrom) ...[
                TextFormField(
                  initialValue: member['treatment_taken_from'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Treatment Taken From',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  onChanged: (val) {
                    member['treatment_taken_from'] = val;
                    _notifyChange();
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Standard Boolean Questions
              if (widget.showNameIncluded) ...[
                _buildSimpleRadio(
                  'Name Included?',
                  member['name_included'],
                  (val) {
                    setState(() => member['name_included'] = val);
                    _notifyChange();
                  },
                ),
                const SizedBox(height: 16),
              ],

              if (widget.showReceived) ...[
                _buildSimpleRadio(
                  'Received?',
                  member['received'],
                  (val) {
                    setState(() => member['received'] = val);
                    _notifyChange();
                  },
                ),
                const SizedBox(height: 16),
              ],

              if (widget.showDetailsCorrect) ...[
                 _buildDetailsCorrectSection(member),
                 const SizedBox(height: 16),
              ],

              // Days Input (if enabled)
              if (widget.showDays) ...[
                TextFormField(
                  initialValue: member['days']?.toString() ?? '',
                  decoration: InputDecoration(
                    labelText: widget.daysLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    member['days'] = val;
                    _notifyChange();
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Bank Accounts Section (if enabled)
              if (widget.showBankAccounts) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text('Bank Accounts', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                _buildBankAccountsList(index),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleRadio(String label, bool? groupValue, ValueChanged<bool?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<bool>(
              value: true,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            const Text('Yes'),
            const SizedBox(width: 24),
            Radio<bool>(
              value: false,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            const Text('No'),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsCorrectSection(Map<String, dynamic> member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Details Correct?', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<bool>(
              value: true,
              groupValue: member['details_correct'],
              onChanged: (val) {
                 setState(() => member['details_correct'] = val);
                 _notifyChange();
              },
            ),
            const Text('Yes'),
            const SizedBox(width: 24),
            Radio<bool>(
              value: false,
              groupValue: member['details_correct'],
              onChanged: (val) {
                 setState(() => member['details_correct'] = val);
                 _notifyChange();
              },
            ),
            const Text('No'),
          ],
        ),
        if (member['details_correct'] == false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              initialValue: member['incorrect_details'],
              decoration: const InputDecoration(
                labelText: 'What is incorrect?',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                member['incorrect_details'] = val;
                _notifyChange();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBankAccountsList(int memberIndex) {
    final member = _members[memberIndex];
    final bankAccounts = member['bank_accounts'] as List? ?? [];

    return Column(
      children: [
         ...bankAccounts.asMap().entries.map((entry) {
          final accountIndex = entry.key;
          final account = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
               color: Colors.grey[50], 
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Account ${accountIndex + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    InkWell(
                      onTap: () => _removeBankAccount(memberIndex, accountIndex),
                      child: const Icon(Icons.close, size: 18, color: Colors.red),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: account['bank_name'],
                  decoration: const InputDecoration(labelText: 'Bank Name', isDense: true, border: OutlineInputBorder()),
                  onChanged: (val) {
                    account['bank_name'] = val;
                    _notifyChange();
                  },
                ),
                const SizedBox(height: 8),
                 TextFormField(
                  initialValue: account['account_number'],
                  decoration: const InputDecoration(labelText: 'Account Number', isDense: true, border: OutlineInputBorder()),
                   keyboardType: TextInputType.number,
                  onChanged: (val) {
                    account['account_number'] = val;
                    _notifyChange();
                  },
                ),
                // Note: Simplified bank fields to save vertical space as requested "like training page" cards
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => _addBankAccount(memberIndex),
          icon: const Icon(Icons.add),
          label: const Text('Add Bank Account'),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: const Text('Are you sure you want to remove this family member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _removeMember(index);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
