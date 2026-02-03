import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/survey_provider.dart';

class IrrigationPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const IrrigationPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<IrrigationPage> createState() => _IrrigationPageState();
}

class _IrrigationPageState extends ConsumerState<IrrigationPage> {
  late bool _canal;
  late bool _tubeWell;
  late bool _ponds;
  late bool _otherFacilities;

  String? _otherIrrigationSpecify;

  @override
  void initState() {
    super.initState();
    _canal = _parseBool(widget.pageData['canal']);
    _tubeWell = _parseBool(widget.pageData['tube_well']);
    _ponds = _parseBool(widget.pageData['ponds']);
    _otherFacilities = _parseBool(widget.pageData['other_facilities']);
    
    _otherIrrigationSpecify = widget.pageData['other_irrigation_specify'];
  }

  @override
  void didUpdateWidget(covariant IrrigationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
      setState(() {
        _canal = _parseBool(widget.pageData['canal']);
        _tubeWell = _parseBool(widget.pageData['tube_well']);
        _ponds = _parseBool(widget.pageData['ponds']);
        _otherFacilities = _parseBool(widget.pageData['other_facilities']);
        _otherIrrigationSpecify = widget.pageData['other_irrigation_specify'];
      });
    }
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'yes' || value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  void _updateData() {
    final data = {
      'canal': _canal ? 'Yes' : 'No',
      'tube_well': _tubeWell ? 'Yes' : 'No',
      'ponds': _ponds ? 'Yes' : 'No',
      'other_facilities': _otherFacilities ? 'Yes' : 'No',
      'other_irrigation_specify': _otherIrrigationSpecify,
    };
    widget.onDataChanged(data);
    ref.read(surveyProvider.notifier).savePageData(6, data);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              l10n.irrigationFacilities,
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
              l10n.selectIrrigationFacilities ?? 'Select available irrigation facilities',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Canal Irrigation
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: Text(
                  l10n.canal,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Government canal water supply'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.water, color: Colors.blue),
                ),
                value: _canal,
                onChanged: (value) {
                  setState(() => _canal = value ?? false);
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

          // Tube Well
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: Text(
                  l10n.tubeWell,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Borewell or tube well'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_downward, color: Colors.teal),
                ),
                value: _tubeWell,
                onChanged: (value) {
                  setState(() => _tubeWell = value ?? false);
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

          // Ponds
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: Text(
                  l10n.ponds,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Farm ponds or community ponds'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.cyan[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.waves, color: Colors.cyan),
                ),
                value: _ponds,
                onChanged: (value) {
                  setState(() => _ponds = value ?? false);
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

          // Other Facilities
          FadeInLeft(
            delay: const Duration(milliseconds: 500),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: Text(
                  l10n.otherFacilities,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Any other irrigation source'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.devices_other, color: Colors.purple),
                ),
                value: _otherFacilities,
                onChanged: (value) {
                  setState(() => _otherFacilities = value ?? false);
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
          
          if (_otherFacilities) ...[
            FadeInLeft(
              delay: const Duration(milliseconds: 550),
              child: TextFormField(
                initialValue: _otherIrrigationSpecify,
                decoration: InputDecoration(
                  labelText: 'Specify other irrigation facilities',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _otherIrrigationSpecify = value;
                  _updateData();
                },
              ),
            ),
            const SizedBox(height: 24),
          ],



          // Information Text
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.selectIrrigationMethodsInfo ?? 'Please select all applicable irrigation sources',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 14,
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
