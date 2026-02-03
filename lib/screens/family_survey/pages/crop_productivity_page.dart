import 'package:flutter/material.dart';

import '../../../components/autocomplete_dropdown.dart';
import '../../../l10n/app_localizations.dart';

class CropProductivityPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const CropProductivityPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<CropProductivityPage> createState() => _CropProductivityPageState();
}

class _CropProductivityPageState extends State<CropProductivityPage> {
  List<Map<String, dynamic>> _crops = [];
  List<TextEditingController> _cropNameControllers = [];

  // Crop options organized by season
  final Map<String, List<String>> cropOptions = {
    'Kharif': [
      'Sorghum',
      'Pearlmillet',
      'Rice',
      'Greengram',
      'Blackgram',
      'Pigeon pea',
      'Sesame',
      'Vegetables'
    ],
    'Rabi': [
      'Wheat',
      'Barley',
      'Chickpea',
      'Lentil',
      'Mustard',
      'Linseed',
      'Vegetables'
    ],
    'Summer': [
      'Greengram',
      'Blackgram',
      'Vegetables'
    ]
  };

  @override
  void initState() {
    super.initState();
    _initializeCrops();
  }

  void _initializeCrops() {
    final existingData = widget.pageData['crop_productivity'];
    
    if (existingData != null && existingData is List && existingData.isNotEmpty) {
      _crops = List<Map<String, dynamic>>.from(existingData);
      _cropNameControllers = _crops.map((c) => TextEditingController(text: c['name'])).toList();
    } else {
       _crops = [{
        'id': 1,
        'season': 'Kharif',
        'name': 'Rice',
        'area': '',
        'productivity': '',
        'total_production': '',
        'sold': ''
      }];
      _cropNameControllers = [TextEditingController(text: 'Rice')];
    }
  }

  @override
  void didUpdateWidget(covariant CropProductivityPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
        // Dispose old controllers first? No, list might be different. 
        // Simplest is to reload if structure changed. 
        // Be careful not to lose focus if unrelated data changed.
        // For now, assuming full page reload if data changed externally.
        for (var c in _cropNameControllers) c.dispose();
        _initializeCrops();
        setState(() {});
    }
  }

  @override
  void dispose() {
    for (var controller in _cropNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCrop() {
    if (_crops.length < 10) {
      setState(() {
        final newId = _crops.length + 1;
        _crops.add({
          'id': newId,
          'season': 'Kharif',
          'name': 'Rice',
          'area': '',
          'productivity': '',
          'total_production': '',
          'sold': ''
        });
        _cropNameControllers.add(TextEditingController(text: 'Rice'));
      });
      _updateData();
    }
  }

  void _removeCrop(int index) {
    if (_crops.length > 1) {
      setState(() {
        _crops.removeAt(index);
        _cropNameControllers[index].dispose();
        _cropNameControllers.removeAt(index);
      });
      _updateData();
    }
  }

  void _updateCropData(int index, String field, String value) {
    // index is the List index (0-based)
    setState(() {
       _crops[index][field] = value;
    });
    _updateData();
  }

  void _updateData() {
    widget.onDataChanged({'crop_productivity': _crops});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.grass, color: Colors.green[700], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.cropProductivity,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Please provide details about your crop production',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Crop entries - Mobile-friendly card layout
        ..._crops.asMap().entries.map((entry) {
          final index = entry.key;
          final crop = entry.value;
          return Column(
            children: [
              _buildCropCard(crop['id'], l10n, _crops.length > 1 ? () => _removeCrop(index) : null),
              const SizedBox(height: 16),
            ],
          );
        }),

        const SizedBox(height: 16),

        // Add crop button
        if (_crops.length < 10)
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addCrop,
              icon: const Icon(Icons.add),
              label: const Text('Add Another Crop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total crop types: ${_crops.length}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCropCard(int cropId, AppLocalizations l10n, VoidCallback? onRemove) {
     final index = _crops.indexWhere((c) => c['id'] == cropId);
     if (index == -1) return const SizedBox.shrink();
     final crop = _crops[index];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with crop number and delete button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Crop ${index + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                const Spacer(),
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    tooltip: 'Remove Crop',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Season Selection
            Text(
              'Season',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                value: crop['season'], // Use value instead of initialValue for controlled input
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: cropOptions.keys.map((season) {
                  return DropdownMenuItem<String>(
                    value: season,
                    child: Text(
                      season,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      crop['season'] = value;
                      // Reset crop name when season changes
                      final defaultCrop = cropOptions[value]!.first;
                      crop['name'] = defaultCrop;
                      _cropNameControllers[index].text = defaultCrop;
                    });
                     _updateData();
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // Crop Selection
            Text(
              'Crop Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            AutocompleteDropdown(
              label: 'Crop Type',
              hintText: 'Type or select crop name',
              options: cropOptions[crop['season'] ?? 'Kharif'] ?? cropOptions['Kharif']!,
              controller: _cropNameControllers[index],
              initialValue: crop['name'] ?? '',
              onChanged: (value) {
                 _updateCropData(index, 'name', value);
              },
            ),

            const SizedBox(height: 24),

            // Production Details - Two columns for mobile
            Text(
              'Production Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            // First row: Area and Productivity
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Area (Acres)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: crop['area']?.toString(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                           _updateCropData(index, 'area', value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Productivity (Qtl/Acre)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: crop['productivity']?.toString(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                           _updateCropData(index, 'productivity', value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Second row: Total Production and Quantity Sold
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Production (Qtl)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: crop['total_production']?.toString(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                           _updateCropData(index, 'total_production', value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity Sold (Qtl)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: crop['sold']?.toString(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                           _updateCropData(index, 'sold', value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
