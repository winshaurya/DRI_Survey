import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class MedicalPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const MedicalPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<MedicalPage> createState() => _MedicalPageState();
}

class _MedicalPageState extends State<MedicalPage> {
  late bool _allopathic;
  late bool _ayurvedic;
  late bool _homeopathy;
  late bool _traditional;
  late bool _otherTreatment;
  late String _preferredTreatment;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _allopathic = widget.pageData['allopathic'] == 1 || widget.pageData['allopathic'] == true || widget.pageData['allopathic'] == '1';
    _ayurvedic = widget.pageData['ayurvedic'] == 1 || widget.pageData['ayurvedic'] == true || widget.pageData['ayurvedic'] == '1';
    _homeopathy = widget.pageData['homeopathy'] == 1 || widget.pageData['homeopathy'] == true || widget.pageData['homeopathy'] == '1';
    _traditional = widget.pageData['traditional'] == 1 || widget.pageData['traditional'] == true || widget.pageData['traditional'] == '1';
    _otherTreatment = widget.pageData['other_treatment'] == 1 || widget.pageData['other_treatment'] == true || widget.pageData['other_treatment'] == '1';
    _preferredTreatment = widget.pageData['preferred_treatment'] ?? '';
  }

  @override
  void didUpdateWidget(MedicalPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
      setState(() {
        _initializeData();
      });
    }
  }

  void _updateData() {
    final data = {
      'allopathic': _allopathic ? 1 : 0,
      'ayurvedic': _ayurvedic ? 1 : 0,
      'homeopathy': _homeopathy ? 1 : 0,
      'traditional': _traditional ? 1 : 0,
      'other_treatment': _otherTreatment ? 1 : 0,
      'preferred_treatment': _preferredTreatment,
    };
    widget.onDataChanged(data);
  }

  Widget _buildMedicalOptionRow(
      String key, String label, String subtitle, IconData icon, Color iconColor, int delay) {
    bool value = false;
    switch (key) {
      case 'allopathic':
        value = _allopathic;
        break;
      case 'ayurvedic':
        value = _ayurvedic;
        break;
      case 'homeopathy':
        value = _homeopathy;
        break;
      case 'traditional':
        value = _traditional;
        break;
      case 'other_treatment':
        value = _otherTreatment;
        break;
    }

    return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: CheckboxListTile(
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
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
          value: value,
          onChanged: (val) {
            setState(() {
              switch (key) {
                case 'allopathic':
                  _allopathic = val ?? false;
                  break;
                case 'ayurvedic':
                  _ayurvedic = val ?? false;
                  break;
                case 'homeopathy':
                  _homeopathy = val ?? false;
                  break;
                case 'traditional':
                  _traditional = val ?? false;
                  break;
                case 'other_treatment':
                  _otherTreatment = val ?? false;
                  break;
              }
            });
            _updateData();
          },
          activeColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> treatmentOptions = [
      {'value': 'allopathic', 'label': l10n.allopathic ?? 'Allopathic Medicine', 'subtitle': 'Modern medicine from qualified doctors', 'icon': Icons.local_hospital, 'color': Colors.blue},
      {'value': 'ayurvedic', 'label': l10n.ayurvedic ?? 'Ayurvedic Medicine', 'subtitle': 'Traditional Indian medicine system', 'icon': Icons.spa, 'color': Colors.green},
      {'value': 'homeopathy', 'label': l10n.homeopathy ?? 'Homeopathy', 'subtitle': 'Alternative medicine system', 'icon': Icons.healing, 'color': Colors.purple},
      {'value': 'traditional', 'label': l10n.traditional ?? 'Traditional Healing', 'subtitle': 'Local traditional healers and remedies', 'icon': Icons.eco, 'color': Colors.orange},
      {'value': 'other_treatment', 'label': l10n.other ?? 'Other Treatment', 'subtitle': 'Other medical treatment systems including traditional practices', 'icon': Icons.accessibility, 'color': Colors.red},
    ];

    // Validate preferred treatment value
    String? preferredValue;
    if (_preferredTreatment.isNotEmpty && treatmentOptions.any((element) => element['value'] == _preferredTreatment)) {
      preferredValue = _preferredTreatment;
    }

    // SIMPLIFIED UI: No internal scrolling, no animations, simple Column
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Important for being inside another ScrollView
      children: [
        Text(
          l10n.medicalTreatment ?? 'Medical Treatment Options',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select medical treatment systems used by your family',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),

        // Medical Treatment Checkboxes
        _buildMedicalOptionRow('allopathic', l10n.allopathic ?? 'Allopathic Medicine', 'Modern medicine from qualified doctors', Icons.local_hospital, Colors.blue, 0),
        _buildMedicalOptionRow('ayurvedic', l10n.ayurvedic ?? 'Ayurvedic Medicine', 'Traditional Indian medicine system', Icons.spa, Colors.green, 0),
        _buildMedicalOptionRow('homeopathy', l10n.homeopathy ?? 'Homeopathy', 'Alternative medicine system', Icons.healing, Colors.purple, 0),
        _buildMedicalOptionRow('traditional', l10n.traditional ?? 'Traditional Healing', 'Local traditional healers and remedies', Icons.eco, Colors.orange, 0),
        _buildMedicalOptionRow('other_treatment', l10n.other ?? 'Other Treatment', 'Other medical treatment systems', Icons.accessibility, Colors.red, 0),

        const SizedBox(height: 24),

        // Preferred Medical Treatment Dropdown
        Card(
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
                  'Preferred Medical Treatment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: preferredValue,
                  isExpanded: true, // Ensures it doesn't overflow horizontally
                  decoration: InputDecoration(
                    hintText: 'Select preferred medical treatment',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: treatmentOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option['value'],
                      child: Row(
                        children: [
                           Icon(
                              option['icon'] as IconData,
                              color: option['color'] as Color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded( // Use Expanded to handle long text safely
                              child: Text(
                                option['label'],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _preferredTreatment = value ?? '');
                    _updateData();
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
} // End of class