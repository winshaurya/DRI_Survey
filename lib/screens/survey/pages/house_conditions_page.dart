import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class HouseConditionsPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const HouseConditionsPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<HouseConditionsPage> createState() => _HouseConditionsPageState();
}

class _HouseConditionsPageState extends State<HouseConditionsPage> {
  late bool _katchaHouse;
  late bool _pakkaHouse;
  late bool _katchaPakkaHouse;
  late bool _hutHouse;

  @override
  void initState() {
    super.initState();
    _katchaHouse = widget.pageData['katcha_house'] ?? false;
    _pakkaHouse = widget.pageData['pakka_house'] ?? false;
    _katchaPakkaHouse = widget.pageData['katcha_pakka_house'] ?? false;
    _hutHouse = widget.pageData['hut_house'] ?? false;
  }

  void _updateData() {
    final data = {
      'katcha_house': _katchaHouse,
      'pakka_house': _pakkaHouse,
      'katcha_pakka_house': _katchaPakkaHouse,
      'hut_house': _hutHouse,
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
              'House Construction Type',
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
              'Select the type of house your family lives in',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Katcha House
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Katcha House',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Mud walls, thatched roof, temporary structure'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.brown[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.house_siding, color: Colors.brown),
                ),
                value: _katchaHouse,
                onChanged: (value) {
                  setState(() => _katchaHouse = value ?? false);
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

          // Pakka House
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Pakka House',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Concrete/brick walls, concrete roof, permanent structure'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home, color: Colors.blue),
                ),
                value: _pakkaHouse,
                onChanged: (value) {
                  setState(() => _pakkaHouse = value ?? false);
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

          // Katcha-Pakka House
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Semi-Pakka House',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Brick walls with thatched/tin roof, semi-permanent'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.house, color: Colors.orange),
                ),
                value: _katchaPakkaHouse,
                onChanged: (value) {
                  setState(() => _katchaPakkaHouse = value ?? false);
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

          // Hut House
          FadeInLeft(
            delay: const Duration(milliseconds: 500),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Hut / Temporary Shelter',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Makeshift hut, tent, or temporary accommodation'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cabin, color: Colors.grey),
                ),
                value: _hutHouse,
                onChanged: (value) {
                  setState(() => _hutHouse = value ?? false);
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
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.engineering, color: Colors.teal[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'House construction type indicates economic status and living standards. Select the type that best describes your current residence.',
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

          // Validation Message
          if (!_katchaHouse && !_pakkaHouse && !_katchaPakkaHouse && !_hutHouse)
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
                        'Please select at least one house type to continue.',
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
