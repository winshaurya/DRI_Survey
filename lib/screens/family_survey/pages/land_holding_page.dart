import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/survey_provider.dart';

class LandHoldingPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const LandHoldingPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<LandHoldingPage> createState() => _LandHoldingPageState();
}

class _LandHoldingPageState extends ConsumerState<LandHoldingPage> {
  late TextEditingController _irrigatedAreaController;
  late TextEditingController _cultivableAreaController;
  late TextEditingController _otherOrchardController;

  late bool _mangoTrees;
  late bool _guavaTrees;
  late bool _lemonTrees;
  late bool _bananaPlants;
  late bool _papayaTrees;
  late bool _otherFruitTrees;

  @override
  void initState() {
    super.initState();
    _irrigatedAreaController = TextEditingController(text: widget.pageData['irrigated_area']?.toString());
    _cultivableAreaController = TextEditingController(text: widget.pageData['cultivable_area']?.toString());
    _otherOrchardController = TextEditingController(text: widget.pageData['other_orchard_plants']?.toString());
    
    _mangoTrees = _parseBool(widget.pageData['mango_trees']);
    _guavaTrees = _parseBool(widget.pageData['guava_trees']);
    _lemonTrees = _parseBool(widget.pageData['lemon_trees']);
    _bananaPlants = _parseBool(widget.pageData['banana_plants']);
    _papayaTrees = _parseBool(widget.pageData['papaya_trees']);
    _otherFruitTrees = _parseBool(widget.pageData['other_fruit_trees']);
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'yes' || value.toLowerCase() == 'true';
    return false;
  }

  @override
  void dispose() {
    _irrigatedAreaController.dispose();
    _cultivableAreaController.dispose();
    _otherOrchardController.dispose();
    super.dispose();
  }

  void _updateData() {
    final data = {
      'irrigated_area': double.tryParse(_irrigatedAreaController.text) ?? 0.0,
      'cultivable_area': double.tryParse(_cultivableAreaController.text) ?? 0.0,
      'other_orchard_plants': _otherOrchardController.text,
      'mango_trees': _mangoTrees ? 1 : 0,
      'guava_trees': _guavaTrees ? 1 : 0,
      'lemon_trees': _lemonTrees ? 1 : 0,
      'banana_plants': _bananaPlants ? 1 : 0,
      'papaya_trees': _papayaTrees ? 1 : 0,
      'other_fruit_trees': _otherFruitTrees,
      'other_fruit_trees_count': 0, // Default or add field if needed
    };
    widget.onDataChanged(data);
    ref.read(surveyProvider.notifier).savePageData(5, data);
  }

  Widget _buildCheckboxField(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      activeColor: Colors.green,
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
              l10n.landHolding,
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
              'Please provide information about your land holdings',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),

          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: TextFormField(
              controller: _irrigatedAreaController,
              decoration: InputDecoration(
                labelText: '${l10n.irrigatedArea} (Acres)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.water),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateData(),
            ),
          ),

          const SizedBox(height: 16),

          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: TextFormField(
              controller: _cultivableAreaController,
              decoration: InputDecoration(
                labelText: '${l10n.cultivableArea} (Acres)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.agriculture),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateData(),
            ),
          ),

          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Text(
              l10n.orchardPlants,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildCheckboxField('Mango Trees', _mangoTrees, (val) {
                    setState(() => _mangoTrees = val ?? false);
                    _updateData();
                  }),
                  _buildCheckboxField('Guava Trees', _guavaTrees, (val) {
                    setState(() => _guavaTrees = val ?? false);
                    _updateData();
                  }),
                  _buildCheckboxField('Lemon Trees', _lemonTrees, (val) {
                    setState(() => _lemonTrees = val ?? false);
                    _updateData();
                  }),
                  _buildCheckboxField('Banana Plants', _bananaPlants, (val) {
                    setState(() => _bananaPlants = val ?? false);
                    _updateData();
                  }),
                  _buildCheckboxField('Papaya Trees', _papayaTrees, (val) {
                    setState(() => _papayaTrees = val ?? false);
                    _updateData();
                  }),
                  _buildCheckboxField('Other Fruit Trees', _otherFruitTrees, (val) {
                    setState(() => _otherFruitTrees = val ?? false);
                    _updateData();
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_otherFruitTrees)
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: TextFormField(
                controller: _otherOrchardController,
                decoration: InputDecoration(
                  labelText: 'Other Orchard Plants (specify)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => _updateData(),
              ),
            ),
        ],
      ),
    );
  }
}
