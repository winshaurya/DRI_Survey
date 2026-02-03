import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class DisputesPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const DisputesPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<DisputesPage> createState() => _DisputesPageState();
}

class _DisputesPageState extends State<DisputesPage> {
  // Family Disputes
  String _familyDisputes = '';
  String _familyRegistered = '';
  String _familyPeriod = '';

  // Revenue Disputes
  String _revenueDisputes = '';
  String _revenueRegistered = '';
  String _revenuePeriod = '';

  // Criminal Disputes
  String _criminalDisputes = '';
  String _criminalRegistered = '';
  String _criminalPeriod = '';

  // Other Disputes
  String _otherDisputes = '';
  String _otherDescription = '';
  String _otherRegistered = '';
  String _otherPeriod = '';

  final List<Map<String, dynamic>> _disputeTypes = [
    {'key': 'family', 'label': 'Family Disputes', 'icon': Icons.family_restroom, 'color': Colors.blue},
    {'key': 'revenue', 'label': 'Revenue Disputes', 'icon': Icons.account_balance, 'color': Colors.green},
    {'key': 'criminal', 'label': 'Foujdari (Criminal)', 'icon': Icons.gavel, 'color': Colors.red},
    {'key': 'other', 'label': 'Any Other - Describe', 'icon': Icons.more_horiz, 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    // Family Disputes
    _familyDisputes = widget.pageData['family_disputes'] ?? '';
    _familyRegistered = widget.pageData['family_registered'] ?? '';
    _familyPeriod = widget.pageData['family_period'] ?? '';

    // Revenue Disputes
    _revenueDisputes = widget.pageData['revenue_disputes'] ?? '';
    _revenueRegistered = widget.pageData['revenue_registered'] ?? '';
    _revenuePeriod = widget.pageData['revenue_period'] ?? '';

    // Criminal Disputes
    _criminalDisputes = widget.pageData['criminal_disputes'] ?? '';
    _criminalRegistered = widget.pageData['criminal_registered'] ?? '';
    _criminalPeriod = widget.pageData['criminal_period'] ?? '';

    // Other Disputes
    _otherDisputes = widget.pageData['other_disputes'] ?? '';
    _otherDescription = widget.pageData['other_description'] ?? '';
    _otherRegistered = widget.pageData['other_registered'] ?? '';
    _otherPeriod = widget.pageData['other_period'] ?? '';
  }

  @override
  void didUpdateWidget(DisputesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
      setState(() {
        _familyDisputes = widget.pageData['family_disputes'] ?? '';
        _familyRegistered = widget.pageData['family_registered'] ?? '';
        _familyPeriod = widget.pageData['family_period'] ?? '';

        _revenueDisputes = widget.pageData['revenue_disputes'] ?? '';
        _revenueRegistered = widget.pageData['revenue_registered'] ?? '';
        _revenuePeriod = widget.pageData['revenue_period'] ?? '';

        _criminalDisputes = widget.pageData['criminal_disputes'] ?? '';
        _criminalRegistered = widget.pageData['criminal_registered'] ?? '';
        _criminalPeriod = widget.pageData['criminal_period'] ?? '';

        _otherDisputes = widget.pageData['other_disputes'] ?? '';
        _otherDescription = widget.pageData['other_description'] ?? '';
        _otherRegistered = widget.pageData['other_registered'] ?? '';
        _otherPeriod = widget.pageData['other_period'] ?? '';
      });
    }
  }

  void _updateData() {
    final data = {
      // Family Disputes
      'family_disputes': _familyDisputes,
      'family_registered': _familyRegistered,
      'family_period': _familyPeriod,

      // Revenue Disputes
      'revenue_disputes': _revenueDisputes,
      'revenue_registered': _revenueRegistered,
      'revenue_period': _revenuePeriod,

      // Criminal Disputes
      'criminal_disputes': _criminalDisputes,
      'criminal_registered': _criminalRegistered,
      'criminal_period': _criminalPeriod,

      // Other Disputes
      'other_disputes': _otherDisputes,
      'other_description': _otherDescription,
      'other_registered': _otherRegistered,
      'other_period': _otherPeriod,
    };
    widget.onDataChanged(data);
  }

  Widget _buildMobileDisputeCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String label,
    required String subtitle,
    required String yesNoValue,
    required Function(String?) onYesNoChanged,
    required String registeredValue,
    required Function(String?) onRegisteredChanged,
    required String periodValue,
    required Function(String) onPeriodChanged,
    bool showDescriptionField = false,
    String? descriptionValue,
    Function(String)? onDescriptionChanged,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [backgroundColor, backgroundColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Icon and Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Yes/No Question
              Text(
                'Do you have this type of dispute?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Yes'),
                      value: 'yes',
                      groupValue: yesNoValue,
                      onChanged: onYesNoChanged,
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('No'),
                      value: 'no',
                      groupValue: yesNoValue,
                      onChanged: onYesNoChanged,
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),

              // Show additional fields only if "Yes" is selected
              if (yesNoValue == 'yes') ...[
                const SizedBox(height: 20),

                // Registration Status
                Text(
                  'Registration Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Registered'),
                        value: 'registered',
                        groupValue: registeredValue,
                        onChanged: onRegisteredChanged,
                        activeColor: Colors.blue,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Not Registered'),
                        value: 'not_registered',
                        groupValue: registeredValue,
                        onChanged: onRegisteredChanged,
                        activeColor: Colors.blue,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Period of Dispute
                Text(
                  'Period of Dispute',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: periodValue,
                  onChanged: onPeriodChanged,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'e.g., 2 years, 6 months, ongoing',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),

                // Description field for "Any Other" dispute type
                if (showDescriptionField) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Describe the Dispute',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: descriptionValue,
                    onChanged: onDescriptionChanged,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Please describe the nature of the dispute...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
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
              l10n.legalDisputesCourtCases,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              l10n.describeLegalDisputes,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mobile-Friendly Vertical Dispute Cards
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: [
                // Family Disputes Card
                _buildMobileDisputeCard(
                  icon: Icons.family_restroom,
                  iconColor: Colors.blue,
                  backgroundColor: Colors.blue[50]!,
                  label: 'Family Disputes',
                  subtitle: 'Disputes within family members',
                  yesNoValue: _familyDisputes,
                  onYesNoChanged: (value) {
                    setState(() => _familyDisputes = value ?? '');
                    _updateData();
                  },
                  registeredValue: _familyRegistered,
                  onRegisteredChanged: (value) {
                    setState(() => _familyRegistered = value ?? '');
                    _updateData();
                  },
                  periodValue: _familyPeriod,
                  onPeriodChanged: (value) {
                    setState(() => _familyPeriod = value);
                    _updateData();
                  },
                ),

                const SizedBox(height: 16),

                // Revenue Disputes Card
                _buildMobileDisputeCard(
                  icon: Icons.account_balance,
                  iconColor: Colors.green,
                  backgroundColor: Colors.green[50]!,
                  label: 'Revenue Disputes',
                  subtitle: 'Land and property related disputes',
                  yesNoValue: _revenueDisputes,
                  onYesNoChanged: (value) {
                    setState(() => _revenueDisputes = value ?? '');
                    _updateData();
                  },
                  registeredValue: _revenueRegistered,
                  onRegisteredChanged: (value) {
                    setState(() => _revenueRegistered = value ?? '');
                    _updateData();
                  },
                  periodValue: _revenuePeriod,
                  onPeriodChanged: (value) {
                    setState(() => _revenuePeriod = value);
                    _updateData();
                  },
                ),

                const SizedBox(height: 16),

                // Criminal Disputes Card
                _buildMobileDisputeCard(
                  icon: Icons.gavel,
                  iconColor: Colors.red,
                  backgroundColor: Colors.red[50]!,
                  label: 'Foujdari (Criminal)',
                  subtitle: 'Criminal cases and disputes',
                  yesNoValue: _criminalDisputes,
                  onYesNoChanged: (value) {
                    setState(() => _criminalDisputes = value ?? '');
                    _updateData();
                  },
                  registeredValue: _criminalRegistered,
                  onRegisteredChanged: (value) {
                    setState(() => _criminalRegistered = value ?? '');
                    _updateData();
                  },
                  periodValue: _criminalPeriod,
                  onPeriodChanged: (value) {
                    setState(() => _criminalPeriod = value);
                    _updateData();
                  },
                ),

                const SizedBox(height: 16),

                // Other Disputes Card
                _buildMobileDisputeCard(
                  icon: Icons.more_horiz,
                  iconColor: Colors.orange,
                  backgroundColor: Colors.orange[50]!,
                  label: 'Any Other Disputes',
                  subtitle: 'Other types of legal disputes',
                  yesNoValue: _otherDisputes,
                  onYesNoChanged: (value) {
                    setState(() => _otherDisputes = value ?? '');
                    _updateData();
                  },
                  registeredValue: _otherRegistered,
                  onRegisteredChanged: (value) {
                    setState(() => _otherRegistered = value ?? '');
                    _updateData();
                  },
                  periodValue: _otherPeriod,
                  onPeriodChanged: (value) {
                    setState(() => _otherPeriod = value);
                    _updateData();
                  },
                  showDescriptionField: true,
                  descriptionValue: _otherDescription,
                  onDescriptionChanged: (value) {
                    setState(() => _otherDescription = value);
                    _updateData();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Information Cards
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.legalInfoConfidential,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.commonDisputes,
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Optional Note
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.optionalDisputesSection,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}