import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class TrainingPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const TrainingPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  late bool _noTraining;
  late bool _agriculturalTraining;
  late bool _skillDevelopment;
  late bool _vocationalTraining;
  late bool _otherTraining;
  late String? _needTraining;

  @override
  void initState() {
    super.initState();
    _noTraining = widget.pageData['no_training'] ?? false;
    _agriculturalTraining = widget.pageData['agricultural_training'] ?? false;
    _skillDevelopment = widget.pageData['skill_development'] ?? false;
    _vocationalTraining = widget.pageData['vocational_training'] ?? false;
    _otherTraining = widget.pageData['other_training'] ?? false;
    _needTraining = widget.pageData['need_training'];
  }

  void _updateData() {
    final data = {
      'no_training': _noTraining,
      'agricultural_training': _agriculturalTraining,
      'skill_development': _skillDevelopment,
      'vocational_training': _vocationalTraining,
      'other_training': _otherTraining,
      'need_training': _needTraining,
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
              'Training & Skill Development',
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
              'Select training programs family members have participated in',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Do you need training question
          FadeInLeft(
            delay: const Duration(milliseconds: 150),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Do you need training?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'yes',
                          groupValue: _needTraining,
                          onChanged: (value) {
                            setState(() => _needTraining = value);
                            _updateData();
                          },
                          activeColor: Colors.green,
                        ),
                        const Text('Yes'),
                        const SizedBox(width: 20),
                        Radio<String>(
                          value: 'no',
                          groupValue: _needTraining,
                          onChanged: (value) {
                            setState(() => _needTraining = value);
                            _updateData();
                          },
                          activeColor: Colors.green,
                        ),
                        const Text('No'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // No Training
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'No Training Received',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('No family member has received any training'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.not_interested, color: Colors.grey),
                ),
                value: _noTraining,
                onChanged: (value) {
                  setState(() => _noTraining = value ?? false);
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

          // Agricultural Training
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Agricultural Training',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Farming techniques, crop management, livestock care'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.agriculture, color: Colors.green),
                ),
                value: _agriculturalTraining,
                onChanged: (value) {
                  setState(() => _agriculturalTraining = value ?? false);
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

          // Skill Development
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Skill Development Programs',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('General skill enhancement, entrepreneurship'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.build, color: Colors.blue),
                ),
                value: _skillDevelopment,
                onChanged: (value) {
                  setState(() => _skillDevelopment = value ?? false);
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

          // Vocational Training
          FadeInLeft(
            delay: const Duration(milliseconds: 500),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Vocational Training',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Specific trade skills, handicrafts, technical skills'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.engineering, color: Colors.orange),
                ),
                value: _vocationalTraining,
                onChanged: (value) {
                  setState(() => _vocationalTraining = value ?? false);
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

          // Other Training
          FadeInLeft(
            delay: const Duration(milliseconds: 600),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Other Training Programs',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Computer literacy, financial literacy, health education'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.more_horiz, color: Colors.purple),
                ),
                value: _otherTraining,
                onChanged: (value) {
                  setState(() => _otherTraining = value ?? false);
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
            delay: const Duration(milliseconds: 700),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.school, color: Colors.teal[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Training programs enhance employability and economic opportunities. This data helps evaluate the effectiveness of skill development initiatives.',
                      style: TextStyle(
                        color: Colors.teal[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Government Programs
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance, color: Colors.indigo[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Common Government Training Programs:',
                        style: TextStyle(
                          color: Colors.indigo[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• PMKVY (Pradhan Mantri Kaushal Vikas Yojana)\n• DDU-GKY (Deen Dayal Upadhyaya Grameen Kaushalya Yojana)\n• Agricultural extension programs\n• Women empowerment programs\n• Digital literacy programs',
                    style: TextStyle(
                      color: Colors.indigo[700],
                      fontSize: 13,
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
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select "No Training Received" if no family member has participated in any training program.',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Validation Message
          if (!_noTraining && !_agriculturalTraining && !_skillDevelopment && !_vocationalTraining && !_otherTraining)
            FadeInUp(
              delay: const Duration(milliseconds: 1000),
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
                        'Please select at least one training option to continue.',
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
