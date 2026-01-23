import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';

class MigrationPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const MigrationPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends State<MigrationPage> {
  late bool _noMigration;
  late bool _seasonalMigration;
  late bool _permanentMigration;

  late TextEditingController _seasonalMigrantsController;
  late TextEditingController _permanentMigrantsController;
  late TextEditingController _migrationReasonController;

  @override
  void initState() {
    super.initState();
    _noMigration = widget.pageData['no_migration'] ?? false;
    _seasonalMigration = widget.pageData['seasonal_migration'] ?? false;
    _permanentMigration = widget.pageData['permanent_migration'] ?? false;

    _seasonalMigrantsController = TextEditingController(
      text: widget.pageData['seasonal_migrants']?.toString() ?? '',
    );
    _permanentMigrantsController = TextEditingController(
      text: widget.pageData['permanent_migrants']?.toString() ?? '',
    );
    _migrationReasonController = TextEditingController(
      text: widget.pageData['migration_reason'] ?? '',
    );
  }

  @override
  void dispose() {
    _seasonalMigrantsController.dispose();
    _permanentMigrantsController.dispose();
    _migrationReasonController.dispose();
    super.dispose();
  }

  void _updateData() {
    final data = {
      'no_migration': _noMigration,
      'seasonal_migration': _seasonalMigration,
      'permanent_migration': _permanentMigration,
      'seasonal_migrants': int.tryParse(_seasonalMigrantsController.text),
      'permanent_migrants': int.tryParse(_permanentMigrantsController.text),
      if (_migrationReasonController.text.isNotEmpty)
        'migration_reason': _migrationReasonController.text,
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
              'Family Migration Status',
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
              'Select migration patterns of your family members',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // No Migration
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'No Migration',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('All family members live in the village'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home, color: Colors.green),
                ),
                value: _noMigration,
                onChanged: (value) {
                  setState(() => _noMigration = value ?? false);
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

          // Seasonal Migration
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text(
                      'Seasonal Migration',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('Family members migrate seasonally for work'),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.repeat, color: Colors.blue),
                    ),
                    value: _seasonalMigration,
                    onChanged: (value) {
                      setState(() => _seasonalMigration = value ?? false);
                      _updateData();
                    },
                    activeColor: Colors.green,
                  ),
                  if (_seasonalMigration)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _seasonalMigrantsController,
                        decoration: InputDecoration(
                          labelText: 'Number of Seasonal Migrants',
                          hintText: 'Enter number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => _updateData(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Permanent Migration
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text(
                      'Permanent Migration',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('Family members have permanently moved away'),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.move_up, color: Colors.red),
                    ),
                    value: _permanentMigration,
                    onChanged: (value) {
                      setState(() => _permanentMigration = value ?? false);
                      _updateData();
                    },
                    activeColor: Colors.green,
                  ),
                  if (_permanentMigration)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _permanentMigrantsController,
                        decoration: InputDecoration(
                          labelText: 'Number of Permanent Migrants',
                          hintText: 'Enter number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => _updateData(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Migration Reason
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: TextFormField(
              controller: _migrationReasonController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Reason for Migration (if applicable)',
                hintText: 'Describe why family members migrated (e.g., employment, education, marriage)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                prefixIcon: const Icon(Icons.description, color: Colors.blue),
                helperText: 'Optional: Leave blank if no migration',
                helperStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              onChanged: (value) => _updateData(),
            ),
          ),
          const SizedBox(height: 24),

          // Information Text
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.travel_explore, color: Colors.purple[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Migration patterns indicate economic opportunities and challenges in rural areas. This data helps understand workforce mobility.',
                      style: TextStyle(
                        color: Colors.purple[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Common Reasons
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Common Migration Reasons:',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Employment opportunities\n• Agricultural work in other areas\n• Education\n• Marriage\n• Better living conditions',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Validation Message
          if (!_noMigration && !_seasonalMigration && !_permanentMigration)
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please select at least one migration option to continue.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
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
