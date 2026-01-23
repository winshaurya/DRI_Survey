import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class GovernmentSchemesPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const GovernmentSchemesPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<GovernmentSchemesPage> createState() => _GovernmentSchemesPageState();
}

class _GovernmentSchemesPageState extends State<GovernmentSchemesPage> {
  late bool _pds;
  late bool _mnrega;
  late bool _ayushmanBharat;
  late bool _pmKisan;
  late bool _swachhBharat;
  late bool _otherSchemes;

  @override
  void initState() {
    super.initState();
    _pds = widget.pageData['pds'] ?? false;
    _mnrega = widget.pageData['mnrega'] ?? false;
    _ayushmanBharat = widget.pageData['ayushman_bharat'] ?? false;
    _pmKisan = widget.pageData['pm_kisan'] ?? false;
    _swachhBharat = widget.pageData['swachh_bharat'] ?? false;
    _otherSchemes = widget.pageData['other_schemes'] ?? false;
  }

  void _updateData() {
    final data = {
      'pds': _pds,
      'mnrega': _mnrega,
      'ayushman_bharat': _ayushmanBharat,
      'pm_kisan': _pmKisan,
      'swachh_bharat': _swachhBharat,
      'other_schemes': _otherSchemes,
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
              'Government Schemes & Benefits',
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
              'Select government schemes your family is enrolled in or benefits from',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // PDS (Public Distribution System)
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'PDS (Public Distribution System)',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Ration card for subsidized food grains'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restaurant, color: Colors.orange),
                ),
                value: _pds,
                onChanged: (value) {
                  setState(() => _pds = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // MGNREGA
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'MGNREGA',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Mahatma Gandhi National Rural Employment Guarantee Act'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.work, color: Colors.blue),
                ),
                value: _mnrega,
                onChanged: (value) {
                  setState(() => _mnrega = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Ayushman Bharat
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Ayushman Bharat / PMJAY',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Pradhan Mantri Jan Arogya Yojana health insurance'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.health_and_safety, color: Colors.red),
                ),
                value: _ayushmanBharat,
                onChanged: (value) {
                  setState(() => _ayushmanBharat = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // PM Kisan
          FadeInLeft(
            delay: const Duration(milliseconds: 500),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'PM Kisan Samman Nidhi',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Income support for farmers'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.agriculture, color: Colors.green),
                ),
                value: _pmKisan,
                onChanged: (value) {
                  setState(() => _pmKisan = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Swachh Bharat
          FadeInLeft(
            delay: const Duration(milliseconds: 600),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Swachh Bharat Mission',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Clean India initiative, toilets, sanitation'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cleaning_services, color: Colors.teal),
                ),
                value: _swachhBharat,
                onChanged: (value) {
                  setState(() => _swachhBharat = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Other Schemes
          FadeInLeft(
            delay: const Duration(milliseconds: 700),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Other Government Schemes',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Pension schemes, housing schemes, etc.'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.more_horiz, color: Colors.purple),
                ),
                value: _otherSchemes,
                onChanged: (value) {
                  setState(() => _otherSchemes = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Information Text
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance, color: Colors.indigo[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Government schemes provide essential support to rural families. Select all schemes your family is enrolled in or benefits from.',
                      style: TextStyle(
                        color: Colors.indigo[700],
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
            delay: const Duration(milliseconds: 900),
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'If your family is not enrolled in any government schemes, you can proceed without selecting any options.',
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
