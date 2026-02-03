import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/survey_provider.dart';

class EquipmentPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const EquipmentPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends ConsumerState<EquipmentPage> {
  late Map<String, bool> _equipmentOwned;
  late Map<String, String> _equipmentCondition;

  late TextEditingController _otherEquipmentController;

  final List<String> _equipmentTypes = [
    'tractor',
    'thresher',
    'seed_drill',
    'sprayer',
    'duster',
    'diesel_engine'
  ];

  @override
  void initState() {
    super.initState();
    _equipmentOwned = {};
    _equipmentCondition = {};

    // Initialize equipment ownership and conditions
    for (final equipment in _equipmentTypes) {
      _equipmentOwned[equipment] = _parseBool(widget.pageData[equipment]);
      _equipmentCondition[equipment] = widget.pageData['${equipment}_condition'] ?? '';
    }

    _otherEquipmentController = TextEditingController(text: widget.pageData['other_equipment']);
  }

  @override
  void didUpdateWidget(covariant EquipmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
      setState(() {
        for (final equipment in _equipmentTypes) {
          _equipmentOwned[equipment] = _parseBool(widget.pageData[equipment]);
          _equipmentCondition[equipment] = widget.pageData['${equipment}_condition'] ?? '';
        }
        if (widget.pageData['other_equipment'] != _otherEquipmentController.text) {
             _otherEquipmentController.text = widget.pageData['other_equipment'] ?? '';
        }
      });
    }
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'yes' || value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  @override
  void dispose() {
    _otherEquipmentController.dispose();
    super.dispose();
  }

  void _updateData() {
    final data = <String, dynamic>{
      'other_equipment': _otherEquipmentController.text,
    };

    // Add equipment ownership and conditions
    for (final equipment in _equipmentTypes) {
      data[equipment] = _equipmentOwned[equipment]! ? 'Yes' : 'No';
      if (_equipmentOwned[equipment]!) {
        data['${equipment}_condition'] = _equipmentCondition[equipment]!;
      }
    }

    widget.onDataChanged(data);
  }

  Widget _buildEquipmentRow(String equipmentKey, String label, int delay) {
    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Equipment checkbox and label
              CheckboxListTile(
                title: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                value: _equipmentOwned[equipmentKey],
                onChanged: (value) {
                  setState(() {
                    _equipmentOwned[equipmentKey] = value ?? false;
                    if (!value!) {
                      _equipmentCondition[equipmentKey] = '';
                    }
                  });
                  _updateData();
                },
                activeColor: Colors.green,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),

              // Condition radio buttons (only show if equipment is owned)
              if (_equipmentOwned[equipmentKey]!)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Condition:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'good',
                                groupValue: _equipmentCondition[equipmentKey],
                                onChanged: (value) {
                                  setState(() {
                                    _equipmentCondition[equipmentKey] = value!;
                                  });
                                  _updateData();
                                },
                                activeColor: Colors.green,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              const Text('Good', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'average',
                                groupValue: _equipmentCondition[equipmentKey],
                                onChanged: (value) {
                                  setState(() {
                                    _equipmentCondition[equipmentKey] = value!;
                                  });
                                  _updateData();
                                },
                                activeColor: Colors.green,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              const Text('Average', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'bad',
                                groupValue: _equipmentCondition[equipmentKey],
                                onChanged: (value) {
                                  setState(() {
                                    _equipmentCondition[equipmentKey] = value!;
                                  });
                                  _updateData();
                                },
                                activeColor: Colors.green,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              const Text('Bad', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
              l10n.agriculturalEquipment,
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
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select equipment you own and rate their condition',
                      style: TextStyle(color: Colors.blue[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Equipment rows with checkboxes and condition radio buttons
          _buildEquipmentRow('tractor', l10n.tractor, 200),
          _buildEquipmentRow('thresher', l10n.thresher, 250),
          _buildEquipmentRow('seed_drill', l10n.seedDrill, 300),
          _buildEquipmentRow('sprayer', l10n.sprayer, 350),
          _buildEquipmentRow('duster', l10n.duster, 400),
          _buildEquipmentRow('diesel_engine', l10n.dieselEngine, 450),

          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: TextFormField(
              controller: _otherEquipmentController,
              decoration: InputDecoration(
                labelText: l10n.otherEquipmentSpecify ?? 'Other equipment (specify)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.build),
              ),
              onChanged: (_) => _updateData(),
            ),
          ),
        ],
      ),
    );
  }
}
