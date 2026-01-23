import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class IrrigationPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const IrrigationPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<IrrigationPage> createState() => _IrrigationPageState();
}

class _IrrigationPageState extends State<IrrigationPage> {
  late bool _canal;
  late bool _tubeWell;
  late bool _ponds;
  late bool _otherFacilities;

  @override
  void initState() {
    super.initState();
    _canal = widget.pageData['canal'] ?? false;
    _tubeWell = widget.pageData['tube_well'] ?? false;
    _ponds = widget.pageData['ponds'] ?? false;
    _otherFacilities = widget.pageData['other_facilities'] ?? false;
  }

  void _updateData() {
    final data = {
      'canal': _canal,
      'tube_well': _tubeWell,
      'ponds': _ponds,
      'other_facilities': _otherFacilities,
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
              l10n.selectIrrigationFacilities,
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
                  l10n.canalIrrigation,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l10n.governmentCanalWaterSupply),
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
                  l10n.tubeWellBoreWell,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l10n.undergroundWaterExtraction),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.settings, color: Colors.orange),
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
                  l10n.pondsLakes,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l10n.naturalWaterStorageBodies),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.pool, color: Colors.teal),
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
                  l10n.otherIrrigationFacilities,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l10n.dripSprinklerEtc),
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

          // Information Text
          FadeInUp(
            delay: const Duration(milliseconds: 600),
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
                      l10n.selectIrrigationMethodsInfo,
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

          // Validation Message
          if (!_canal && !_tubeWell && !_ponds && !_otherFacilities)
            FadeInUp(
              delay: const Duration(milliseconds: 700),
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
                        l10n.pleaseSelectIrrigationFacility,
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
