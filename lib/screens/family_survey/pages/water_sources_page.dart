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

  late String _handPumpsQuality;
  late String _wellQuality;
  late String _tubewellQuality;
  late String _nalJaalQuality;
  late String _otherSourcesQuality;

  late TextEditingController _handPumpsDistanceController;
  late TextEditingController _wellDistanceController;
  late TextEditingController _tubewellDistanceController;
  late TextEditingController _otherDistanceController;

  @override
  void initState() {
    super.initState();

    // Initialize water sources availability
    _handPumps = widget.pageData['hand_pumps'] == 1 || widget.pageData['hand_pumps'] == true;
    _well = widget.pageData['well'] == 1 || widget.pageData['well'] == true;
    _tubewell = widget.pageData['tubewell'] == 1 || widget.pageData['tubewell'] == true;
    _nalJaal = widget.pageData['nal_jaal'] == 1 || widget.pageData['nal_jaal'] == true;
    _otherSources = widget.pageData['other_sources'] == 1 || widget.pageData['other_sources'] == true;

    // Initialize water quality
    _handPumpsQuality = widget.pageData['hand_pumps_quality'] ?? '';
    _wellQuality = widget.pageData['well_quality'] ?? '';
    _tubewellQuality = widget.pageData['tubewell_quality'] ?? '';
    _nalJaalQuality = widget.pageData['nal_jaal_quality'] ?? '';
    _otherSourcesQuality = widget.pageData['other_sources_quality'] ?? '';

    // Initialize distance controllers
    _handPumpsDistanceController = TextEditingController(text: widget.pageData['hand_pumps_distance']?.toString() ?? '');
    _wellDistanceController = TextEditingController(text: widget.pageData['well_distance']?.toString() ?? '');
    _tubewellDistanceController = TextEditingController(text: widget.pageData['tubewell_distance']?.toString() ?? '');
    _otherDistanceController = TextEditingController(text: widget.pageData['other_distance']?.toString() ?? '');
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
      'hand_pumps': _handPumps ? 1 : 0,
      'well': _well ? 1 : 0,
      'tubewell': _tubewell ? 1 : 0,
      'nal_jaal': _nalJaal ? 1 : 0,
      'other_sources': _otherSources ? 1 : 0,
      'hand_pumps_distance': double.tryParse(_handPumpsDistanceController.text),
      'well_distance': double.tryParse(_wellDistanceController.text),
      'tubewell_distance': double.tryParse(_tubewellDistanceController.text),
      'other_distance': double.tryParse(_otherDistanceController.text),
      'hand_pumps_quality': _handPumpsQuality,
      'well_quality': _wellQuality,
      'tubewell_quality': _tubewellQuality,
      'nal_jaal_quality': _nalJaalQuality,
      'other_sources_quality': _otherSourcesQuality,
    };
    widget.onDataChanged(data);
  }

  Widget _buildWaterSourceRow(String sourceKey, String label, String subtitle, IconData icon, Color iconColor, int delay) {
    bool isAvailable = false;
    String quality = '';
    TextEditingController? distanceController;

    switch (sourceKey) {
      case 'hand_pumps':
        isAvailable = _handPumps;
        quality = _handPumpsQuality;
        distanceController = _handPumpsDistanceController;
        break;
      case 'well':
        isAvailable = _well;
        quality = _wellQuality;
        distanceController = _wellDistanceController;
        break;
      case 'tubewell':
        isAvailable = _tubewell;
        quality = _tubewellQuality;
        distanceController = _tubewellDistanceController;
        break;
      case 'nal_jaal':
        isAvailable = _nalJaal;
        quality = _nalJaalQuality;
        break;
      case 'other_sources':
        isAvailable = _otherSources;
        quality = _otherSourcesQuality;
        distanceController = _otherDistanceController;
        break;
    }

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
              // Water source checkbox and label
              CheckboxListTile(
                title: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                subtitle: Text(subtitle),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                value: isAvailable,
                onChanged: (value) {
                  setState(() {
                    switch (sourceKey) {
                      case 'hand_pumps':
                        _handPumps = value ?? false;
                        if (!value!) _handPumpsQuality = '';
                        break;
                      case 'well':
                        _well = value ?? false;
                        if (!value!) _wellQuality = '';
                        break;
                      case 'tubewell':
                        _tubewell = value ?? false;
                        if (!value!) _tubewellQuality = '';
                        break;
                      case 'nal_jaal':
                        _nalJaal = value ?? false;
                        if (!value!) _nalJaalQuality = '';
                        break;
                      case 'other_sources':
                        _otherSources = value ?? false;
                        if (!value!) _otherSourcesQuality = '';
                        break;
                    }
                  });
                  _updateData();
                },
                activeColor: Colors.green,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),

              // Distance input (for sources that need it)
              if (isAvailable && distanceController != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: TextFormField(
                    controller: distanceController,
                    decoration: InputDecoration(
                      labelText: 'Distance from home (meters)',
                      hintText: 'Enter distance',
                      suffixText: 'meters',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _updateData(),
                  ),
                ),

              // Water quality radio buttons (only show if source is available)
              if (isAvailable)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Water Quality:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'clean',
                                groupValue: quality,
                                onChanged: (value) {
                                  setState(() {
                                    switch (sourceKey) {
                                      case 'hand_pumps':
                                        _handPumpsQuality = value!;
                                        break;
                                      case 'well':
                                        _wellQuality = value!;
                                        break;
                                      case 'tubewell':
                                        _tubewellQuality = value!;
                                        break;
                                      case 'nal_jaal':
                                        _nalJaalQuality = value!;
                                        break;
                                      case 'other_sources':
                                        _otherSourcesQuality = value!;
                                        break;
                                    }
                                  });
                                  _updateData();
                                },
                                activeColor: Colors.green,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              const Text('Clean', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'dirty',
                                groupValue: quality,
                                onChanged: (value) {
                                  setState(() {
                                    switch (sourceKey) {
                                      case 'hand_pumps':
                                        _handPumpsQuality = value!;
                                        break;
                                      case 'well':
                                        _wellQuality = value!;
                                        break;
                                      case 'tubewell':
                                        _tubewellQuality = value!;
                                        break;
                                      case 'nal_jaal':
                                        _nalJaalQuality = value!;
                                        break;
                                      case 'other_sources':
                                        _otherSourcesQuality = value!;
                                        break;
                                    }
                                  });
                                  _updateData();
                                },
                                activeColor: Colors.green,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              const Text('Dirty', style: TextStyle(fontSize: 14)),
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
              'Select drinking water sources and rate water quality',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Water source rows
          _buildWaterSourceRow('hand_pumps', l10n.handPumps ?? 'Hand Pumps', 'Manual water pumps', Icons.water, Colors.blue, 200),
          _buildWaterSourceRow('well', l10n.well ?? 'Well', 'Open well or bore well', Icons.water, Colors.brown, 250),
          _buildWaterSourceRow('tubewell', l10n.tubeWellBoreWell ?? 'Tube Well/Bore Well', 'Powered water extraction', Icons.settings, Colors.teal, 300),
          _buildWaterSourceRow('nal_jaal', l10n.nalJaalPipedWater ?? 'Nal Jaal/Piped Water', 'Government piped water supply', Icons.water_damage, Colors.green, 350),
          _buildWaterSourceRow('other_sources', l10n.otherSources ?? 'Other Sources', 'River, pond, tanker, etc.', Icons.more_horiz, Colors.purple, 400),

          const SizedBox(height: 24),

          // Information Text
          FadeInUp(
            delay: const Duration(milliseconds: 500),
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
                      'Clean water is essential for good health. Please rate the quality of water from your selected sources.',
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
              delay: const Duration(milliseconds: 600),
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
                        'Please select at least one drinking water source',
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