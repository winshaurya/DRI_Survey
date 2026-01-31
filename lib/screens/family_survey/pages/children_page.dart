import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ChildrenPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const ChildrenPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<ChildrenPage> createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  // Local state variables matching the _pageData keys
  String? _birthsLast3Years;
  String? _infantDeathsLast3Years;
  String? _malnourishedChildren;
  
  // Child 1 details
  String? _child1Height;
  String? _child1Weight;
  String? _child1Cause;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _birthsLast3Years = widget.pageData['births_last_3_years'];
    _infantDeathsLast3Years = widget.pageData['infant_deaths_last_3_years'];
    _malnourishedChildren = widget.pageData['malnourished_children'];
    
    _child1Height = widget.pageData['child_1_height'];
    _child1Weight = widget.pageData['child_1_weight'];
    _child1Cause = widget.pageData['child_1_cause'];
  }

  void _updateData() {
    final data = {
      'births_last_3_years': _birthsLast3Years,
      'infant_deaths_last_3_years': _infantDeathsLast3Years,
      'malnourished_children': _malnourishedChildren,
      'child_1_height': _child1Height,
      'child_1_weight': _child1Weight,
      'child_1_cause': _child1Cause,
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
              l10n.childrenData,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Please provide information about children in the family',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),

          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: TextFormField(
              initialValue: _birthsLast3Years,
              decoration: InputDecoration(
                labelText: l10n.birthsLast3Years,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.child_care),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _birthsLast3Years = value;
                _updateData();
              },
            ),
          ),

          const SizedBox(height: 16),

          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: TextFormField(
              initialValue: _infantDeathsLast3Years,
              decoration: InputDecoration(
                labelText: l10n.infantDeathsLast3Years,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.warning_amber_rounded),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _infantDeathsLast3Years = value;
                _updateData();
              },
            ),
          ),

          const SizedBox(height: 16),

          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: TextFormField(
              initialValue: _malnourishedChildren,
              decoration: InputDecoration(
                labelText: l10n.malnourishedChildren,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.sick),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _malnourishedChildren = value;
                _updateData();
              },
            ),
          ),

          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Text(
              l10n.malnutritionData,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Child 1 malnutrition data
          _buildChildMalnutritionCard(1, l10n),

          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Multiple child entries coming soon')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Another Child'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildMalnutritionCard(int childNumber, AppLocalizations l10n) {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Child $childNumber',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _child1Height,
                      decoration: InputDecoration(
                        labelText: '${l10n.height} (feet)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.height),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                         _child1Height = value;
                         _updateData();
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: TextFormField(
                      initialValue: _child1Weight,
                      decoration: InputDecoration(
                        labelText: '${l10n.weight} (kg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                         _child1Weight = value;
                         _updateData();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                initialValue: _child1Cause,
                decoration: InputDecoration(
                  labelText: l10n.causeDisease,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.medical_services),
                ),
                onChanged: (value) {
                   _child1Cause = value;
                   _updateData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}