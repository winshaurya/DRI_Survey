import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';

class WaterSourcesPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const WaterSourcesPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<WaterSourcesPage> createState() => _WaterSourcesPageState();
}

class _WaterSourcesPageState extends State<WaterSourcesPage> {
  late bool _handPumps;
  late bool _well;
  late bool _tubewell;
  late bool _nalJaal;
  late bool _otherSources;

  late TextEditingController _handPumpsDistanceController;
  late TextEditingController _wellDistanceController;
  late TextEditingController _tubewellDistanceController;
  late TextEditingController _otherDistanceController;

  @override
  void initState() {
    super.initState();
    _handPumps = widget.pageData['hand_pumps'] ?? false;
    _well = widget.pageData['well'] ?? false;
    _tubewell = widget.pageData['tubewell'] ?? false;
    _nalJaal = widget.pageData['nal_jaal'] ?? false;
    _otherSources = widget.pageData['other_sources'] != null;

    _handPumpsDistanceController = TextEditingController(
      text: widget.pageData['hand_pumps_distance']?.toString() ?? '',
    );
    _wellDistanceController = TextEditingController(
      text: widget.pageData['well_distance']?.toString() ?? '',
    );
    _tubewellDistanceController = TextEditingController(
      text: widget.pageData['tubewell_distance']?.toString() ?? '',
    );
    _otherDistanceController = TextEditingController(
      text: widget.pageData['other_distance']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _handPumpsDistanceController.dispose();
    _wellDistanceController.dispose();
    _tubewellDistanceController.dispose();
    _otherDistanceController.dispose();
    super.dispose();
  }

  void _updateData() {
    final data = {
      'hand_pumps': _handPumps,
      'well': _well,
      'tubewell': _tubewell,
      'nal_jaal': _nalJaal,
      'hand_pumps_distance': double.tryParse(_handPumpsDistanceController.text),
      'well_distance': double.tryParse(_wellDistanceController.text),
      'tubewell_distance': double.tryParse(_tubewellDistanceController.text),
      if (_otherSources) 'other_sources': true,
      'other_distance': double.tryParse(_otherDistanceController.text),
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
              l10n.drinkingWaterSources,
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
              l10n.selectDrinkingWaterSources,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Hand Pumps
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      l10n.handPumps,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(l10n.manualWaterPumps),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.water, color: Colors.blue),
                    ),
                    value: _handPumps,
                    onChanged: (value) {
                      setState(() => _handPumps = value ?? false);
                      _updateData();
                    },
                    activeColor: Colors.green,
                  ),
                  if (_handPumps)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _handPumpsDistanceController,
                        decoration: InputDecoration(
                          labelText: l10n.distanceFromHomeMeters,
                          hintText: l10n.enterDistance,
                          suffixText: l10n.meters,
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

          // Well
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
                    title: Text(
                      l10n.well,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(l10n.openWellOrBoreWell),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.brown[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.water, color: Colors.brown),
                    ),
                    value: _well,
                    onChanged: (value) {
                      setState(() => _well = value ?? false);
                      _updateData();
                    },
                    activeColor: Colors.green,
                  ),
                  if (_well)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _wellDistanceController,
                        decoration: InputDecoration(
                          labelText: l10n.distanceFromHomeMeters,
                          hintText: l10n.enterDistance,
                          suffixText: l10n.meters,
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

          // Tube Well
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
                    title: Text(
                      l10n.tubeWellBoreWell,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(l10n.poweredWaterExtraction),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.settings, color: Colors.teal),
                    ),
                    value: _tubewell,
                    onChanged: (value) {
                      setState(() => _tubewell = value ?? false);
                      _updateData();
                    },
                    activeColor: Colors.green,
                  ),
                  if (_tubewell)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _tubewellDistanceController,
                        decoration: InputDecoration(
                          labelText: l10n.distanceFromHomeMeters,
                          hintText: l10n.enterDistance,
                          suffixText: l10n.meters,
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

          // Nal Jaal
          FadeInLeft(
            delay: const Duration(milliseconds: 500),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: Text(
                  l10n.nalJaalPipedWater,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l10n.governmentPipedWaterSupply),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.water_damage, color: Colors.green),
                ),
                value: _nalJaal,
                onChanged: (value) {
                  setState(() => _nalJaal = value ?? false);
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

          // Other Sources
          FadeInLeft(
            delay: const Duration(milliseconds: 600),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      l10n.otherSources,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(l10n.riverPondTankerEtc),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.more_horiz, color: Colors.purple),
                    ),
                    value: _otherSources,
                    onChanged: (value) {
                      setState(() => _otherSources = value ?? false);
                      _updateData();
                    },
                    activeColor: Colors.green,
                  ),
                  if (_otherSources)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _otherDistanceController,
                        decoration: InputDecoration(
                          labelText: 'Distance from home (in meters)',
                          hintText: 'Enter distance',
                          suffixText: 'meters',
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
          const SizedBox(height: 24),

          // Information Text
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.cyan[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyan[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.cyan[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.cleanWaterAccessInfo,
                      style: TextStyle(
                        color: Colors.cyan[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Validation Message
          if (!_handPumps && !_well && !_tubewell && !_nalJaal && !_otherSources)
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
                        l10n.selectDrinkingWaterSource,
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
