import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/survey_provider.dart';

class MigrationPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const MigrationPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends ConsumerState<MigrationPage> {
  List<Map<String, dynamic>> _migratedMembers = [];
  List<String> _familyMemberNames = [];
  bool _noMigration = false;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
    _initializeData();
  }

  void _loadFamilyMembers() {
    final surveyState = ref.read(surveyProvider);
    final familyMembers = surveyState.surveyData['family_members'] as List<dynamic>? ?? [];
    _familyMemberNames = familyMembers.map((member) => member['name'] as String? ?? '').where((name) => name.isNotEmpty).toList();
  }

  void _initializeData() {
    _noMigration = widget.pageData['no_migration'] ?? false;
    final existingData = widget.pageData['migrated_members'] as List<dynamic>?;
    if (existingData != null) {
      _migratedMembers = existingData.map((item) => Map<String, dynamic>.from(item)).toList();
    }
  }

  void _updateData() {
    final data = {
      'no_migration': _noMigration,
      'migrated_members': _migratedMembers,
    };
    widget.onDataChanged(data);
  }

  void _addMigratedMember() {
    setState(() {
      _migratedMembers.add({
        'member_name': '',
        'permanent_distance': '',
        'permanent_job': '',
        'seasonal_distance': '',
        'seasonal_job': '',
        'need_based_distance': '',
        'need_based_job': '',
      });
    });
    _updateData();
  }

  void _removeMember(int index) {
    setState(() {
      _migratedMembers.removeAt(index);
    });
    _updateData();
  }

  @override
  Widget build(BuildContext context) {
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
              'Details of family members who have migrated for employment',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // No Migration Checkbox
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'No Family Member has Migrated',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('All family members live and work in the village'),
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
                  setState(() {
                    _noMigration = value ?? false;
                    if (_noMigration) {
                      _migratedMembers.clear();
                    }
                  });
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

          if (!_noMigration) ...[
            ..._migratedMembers.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              return FadeInUp(
                delay: Duration(milliseconds: 100 * (index + 1)),
                child: _buildMemberCard(index, member),
              );
            }),

            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: ElevatedButton.icon(
                onPressed: _addMigratedMember,
                icon: const Icon(Icons.add),
                label: const Text('Add Family Member Migration Details'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberCard(int index, Map<String, dynamic> member) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Migrated Member ${index + 1}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeMember(index),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Family Member Name
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Name of Family Member Who Has Migrated',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              value: member['member_name']?.isNotEmpty == true ? member['member_name'] : null,
              items: _familyMemberNames.map((name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (value) {
                member['member_name'] = value ?? '';
                _updateData();
              },
            ),
            const SizedBox(height: 24),

            // Permanent Migration
            _buildMigrationRow(
              'Permanent',
              'permanent_distance',
              'permanent_job',
              member,
              Icons.domain,
              Colors.red,
            ),
            const Divider(height: 32),

            // Seasonal Migration
            _buildMigrationRow(
              'Seasonal',
              'seasonal_distance',
              'seasonal_job',
              member,
              Icons.wb_sunny,
              Colors.orange,
            ),
            const Divider(height: 32),

            // According to Need Migration
            _buildMigrationRow(
              'According to Need',
              'need_based_distance',
              'need_based_job',
              member,
              Icons.handshake,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMigrationRow(
    String title,
    String distanceKey,
    String jobKey,
    Map<String, dynamic> member,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Distance',
                  hintText: 'e.g. 50 km',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                initialValue: member[distanceKey] ?? '',
                onChanged: (value) {
                  member[distanceKey] = value;
                  _updateData();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  hintText: 'e.g. Labor, Driver',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                initialValue: member[jobKey] ?? '',
                onChanged: (value) {
                  member[jobKey] = value;
                  _updateData();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
