import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/survey_provider.dart';

class FertilizerPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const FertilizerPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<FertilizerPage> createState() => _FertilizerPageState();
}

class _FertilizerPageState extends ConsumerState<FertilizerPage> {
  late bool _ureaFertilizer;
  late bool _organicFertilizer;
  late TextEditingController _fertilizerTypesController;

  @override
  void initState() {
    super.initState();
    _ureaFertilizer = _parseBool(widget.pageData['urea_fertilizer']);
    _organicFertilizer = _parseBool(widget.pageData['organic_fertilizer']);
    _fertilizerTypesController = TextEditingController(text: widget.pageData['fertilizer_types']);
  }

  @override
  void didUpdateWidget(covariant FertilizerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
      _fertilizerTypesController.text = widget.pageData['fertilizer_types']?.toString() ?? '';
      setState(() {
        _ureaFertilizer = _parseBool(widget.pageData['urea_fertilizer']);
        _organicFertilizer = _parseBool(widget.pageData['organic_fertilizer']);
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
    _fertilizerTypesController.dispose();
    super.dispose();
  }

  void _updateData() {
    final data = {
      'urea_fertilizer': _ureaFertilizer ? 'Yes' : 'No',
      'organic_fertilizer': _organicFertilizer ? 'Yes' : 'No',
      'fertilizer_types': _fertilizerTypesController.text,
    };
    widget.onDataChanged(data);
    ref.read(surveyProvider.notifier).savePageData(8, data);
  }

  Widget _buildCheckboxField(String label, bool value, Function(bool?) onChanged) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: CheckboxListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              l10n.fertilizerUsage,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInLeft(
            child: Text(
              l10n.selectFertilizerType ?? 'Please select the type of fertilizers used',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),

          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: _buildCheckboxField('Urea', _ureaFertilizer, (val) {
              setState(() => _ureaFertilizer = val ?? false);
              _updateData();
            }),
          ),

          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: _buildCheckboxField(l10n.organic, _organicFertilizer, (val) {
              setState(() => _organicFertilizer = val ?? false);
              _updateData();
            }),
          ),

          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: TextFormField(
              controller: _fertilizerTypesController,
              decoration: InputDecoration(
                labelText: 'Fertilizer brands (comma separated)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
                hintText: 'e.g., DAP, MOP, Potash, Neem Cake',
              ),
              maxLines: 2,
              onChanged: (_) => _updateData(),
            ),
          ),
        ],
      ),
    );
  }
}
