import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../form_template.dart'; // For styles/inputs if valid, or just material

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
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Title and Beneficiary Check
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  if (widget.showBeneficiaryCheck) ...[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRadioOption(
                            label: 'Yes',
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
                          _buildRadioOption(
                            label: 'No',
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
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Members Section
            if (_isBeneficiary || !widget.showBeneficiaryCheck) ...[
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _members.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildMemberCard(context, index);
                  },
                ),
              ),

              // Add Member Button
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _addMember,
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Family Member"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String label,
    required bool value,
    required bool groupValue,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<bool>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: groupValue == value ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, int index) {
    final member = _members[index];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Member Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Family Member ${index + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () => _showDeleteConfirmation(context, index),
                  tooltip: 'Remove member',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Family Member Name Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Family Member',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              initialValue: widget.familyMemberNames.contains(member['name']) ? member['name'] : null,
              items: widget.familyMemberNames.map((name) =>
                DropdownMenuItem(value: name, child: Text(name))
              ).toList(),
              onChanged: (val) {
                setState(() => member['name'] = val);
                _notifyChange();
              },
              style: theme.textTheme.bodyLarge,
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
                      decoration: InputDecoration(
                        labelText: 'Disease Name',
                        hintText: 'Select or type disease',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.medical_services),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: () {
                            // Can't easily force open from here without complex RawAutocomplete
                            // But usually focus does it if we hack it, but standard Autocomplete is fine
                          },
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                      onChanged: (val) {
                        member['disease_name'] = val;
                        _notifyChange();
                      },
                      style: theme.textTheme.bodyLarge,
                    );
                  },
                )
              else
                TextFormField(
                  initialValue: member['disease_name'] ?? '',
                  decoration: InputDecoration(
                    labelText: 'Disease Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.medical_services),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  onChanged: (val) {
                    member['disease_name'] = val;
                    _notifyChange();
                  },
                  style: theme.textTheme.bodyLarge,
                ),
              const SizedBox(height: 16),
            ],

            // Suffering Since (if enabled)
            if (widget.showSufferingSince) ...[
              TextFormField(
                initialValue: member['suffering_since'] ?? '',
                decoration: InputDecoration(
                  labelText: 'Suffering Since (Date)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                onChanged: (val) {
                  member['suffering_since'] = val;
                  _notifyChange();
                },
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],

            // Treatment Taken (if enabled)
            if (widget.showTreatmentTaken) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Treatment Taken?',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRadioOption(
                            label: 'Yes',
                            value: true,
                            groupValue: member['treatment_taken'] ?? false,
                            onChanged: (val) {
                              setState(() => member['treatment_taken'] = val);
                              _notifyChange();
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildRadioOption(
                            label: 'No',
                            value: false,
                            groupValue: member['treatment_taken'] ?? false,
                            onChanged: (val) {
                              setState(() => member['treatment_taken'] = val);
                              _notifyChange();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Treatment From When (if enabled)
            if (widget.showTreatmentFromWhen) ...[
              TextFormField(
                initialValue: member['treatment_from_when'] ?? '',
                decoration: InputDecoration(
                  labelText: 'Treatment From When (Date)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                onChanged: (val) {
                  member['treatment_from_when'] = val;
                  _notifyChange();
                },
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],

            // Treatment From Where (if enabled)
            if (widget.showTreatmentFromWhere) ...[
              TextFormField(
                initialValue: member['treatment_from_where'] ?? '',
                decoration: InputDecoration(
                  labelText: 'Treatment From Where',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                onChanged: (val) {
                  member['treatment_from_where'] = val;
                  _notifyChange();
                },
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],

            // Treatment Taken From (if enabled)
            if (widget.showTreatmentTakenFrom) ...[
              TextFormField(
                initialValue: member['treatment_taken_from'] ?? '',
                decoration: InputDecoration(
                  labelText: 'Treatment Taken From',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                onChanged: (val) {
                  member['treatment_taken_from'] = val;
                  _notifyChange();
                },
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],

            // Conditional Fields in a Grid Layout for better mobile UX
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                if (widget.showNameIncluded)
                  _buildQuestionCard(
                    context: context,
                    question: 'Name Included?',
                    value: member['name_included'],
                    onChanged: (val) {
                      setState(() => member['name_included'] = val);
                      _notifyChange();
                    },
                  ),

                if (widget.showReceived)
                  _buildQuestionCard(
                    context: context,
                    question: 'Received?',
                    value: member['received'],
                    onChanged: (val) {
                      setState(() => member['received'] = val);
                      _notifyChange();
                    },
                  ),

                if (widget.showDetailsCorrect)
                  _buildQuestionCard(
                    context: context,
                    question: 'Details Correct?',
                    value: member['details_correct'],
                    onChanged: (val) {
                      setState(() => member['details_correct'] = val);
                      _notifyChange();
                    },
                    showIncorrectField: true,
                    incorrectValue: member['incorrect_details'],
                    onIncorrectChanged: (val) {
                      member['incorrect_details'] = val;
                      _notifyChange();
                    },
                  ),
              ],
            ),

            // Days Input (if enabled)
            if (widget.showDays) ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: member['days']?.toString() ?? '',
                decoration: InputDecoration(
                  labelText: widget.daysLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  member['days'] = val;
                  _notifyChange();
                },
                style: theme.textTheme.bodyLarge,
              ),
            ],

            // Bank Accounts Section (if enabled)
            if (widget.showBankAccounts) ...[
              const SizedBox(height: 20),
              _buildBankAccountsSection(context, index),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required BuildContext context,
    required String question,
    required bool? value,
    required ValueChanged<bool?> onChanged,
    bool showIncorrectField = false,
    String? incorrectValue,
    ValueChanged<String>? onIncorrectChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: MediaQuery.of(context).size.width > 600
          ? (MediaQuery.of(context).size.width - 72) / 2
          : double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  label: 'Yes',
                  value: true,
                  groupValue: value ?? false,
                  onChanged: onChanged,
                ),
              ),
              Expanded(
                child: _buildRadioOption(
                  label: 'No',
                  value: false,
                  groupValue: value ?? false,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          if (showIncorrectField && value == false) ...[
            const SizedBox(height: 12),
            TextFormField(
              initialValue: incorrectValue,
              decoration: InputDecoration(
                labelText: 'What is incorrect?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              maxLines: 2,
              onChanged: onIncorrectChanged,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBankAccountsSection(BuildContext context, int memberIndex) {
    final member = _members[memberIndex];
    final bankAccounts = member['bank_accounts'] as List? ?? [];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_balance, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Bank Accounts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Bank Accounts List
        ...bankAccounts.asMap().entries.map((entry) {
          final accountIndex = entry.key;
          final account = entry.value;
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Account ${accountIndex + 1}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.delete, color: colorScheme.error, size: 20),
                        onPressed: () => _removeBankAccount(memberIndex, accountIndex),
                        tooltip: 'Remove account',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bank Account Form Fields
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildBankField(
                        label: 'Bank Name',
                        value: account['bank_name'],
                        onChanged: (val) {
                          account['bank_name'] = val;
                          _notifyChange();
                        },
                        icon: Icons.business,
                      ),
                      _buildBankField(
                        label: 'Account Number',
                        value: account['account_number'],
                        onChanged: (val) {
                          account['account_number'] = val;
                          _notifyChange();
                        },
                        icon: Icons.pin,
                        keyboardType: TextInputType.number,
                      ),
                      _buildBankField(
                        label: 'IFSC Code',
                        value: account['ifsc_code'],
                        onChanged: (val) {
                          account['ifsc_code'] = val;
                          _notifyChange();
                        },
                        icon: Icons.code,
                      ),
                      _buildBankField(
                        label: 'Branch Name',
                        value: account['branch_name'],
                        onChanged: (val) {
                          account['branch_name'] = val;
                          _notifyChange();
                        },
                        icon: Icons.location_on,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Account Type Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Account Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.account_box),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    initialValue: account['account_type'],
                    items: [
                      DropdownMenuItem(value: 'savings', child: Text('Savings Account')),
                      DropdownMenuItem(value: 'current', child: Text('Current Account')),
                      DropdownMenuItem(value: 'salary', child: Text('Salary Account')),
                      DropdownMenuItem(value: 'fixed_deposit', child: Text('Fixed Deposit')),
                      DropdownMenuItem(value: 'recurring_deposit', child: Text('Recurring Deposit')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      setState(() => account['account_type'] = val);
                      _notifyChange();
                    },
                  ),

                  const SizedBox(height: 12),

                  // Has Account and Details Correct
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildQuestionCard(
                        context: context,
                        question: 'Has Account?',
                        value: account['has_account'],
                        onChanged: (val) {
                          setState(() => account['has_account'] = val);
                          _notifyChange();
                        },
                      ),
                      _buildQuestionCard(
                        context: context,
                        question: 'Details Correct?',
                        value: account['details_correct'],
                        onChanged: (val) {
                          setState(() => account['details_correct'] = val);
                          _notifyChange();
                        },
                        showIncorrectField: true,
                        incorrectValue: account['incorrect_details'],
                        onIncorrectChanged: (val) {
                          account['incorrect_details'] = val;
                          _notifyChange();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        // Add Bank Account Button
        Center(
          child: OutlinedButton.icon(
            onPressed: () => _addBankAccount(memberIndex),
            icon: const Icon(Icons.add),
            label: const Text('Add Bank Account'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600
          ? (MediaQuery.of(context).size.width - 96) / 2
          : double.infinity,
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
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
