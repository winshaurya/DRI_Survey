import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialize with at least one crop
    if (_crops.isEmpty) {
      _crops.add({
        'id': 1,
        'name': 'Crop 1',
      });
    }
  }

  void _addCrop() {
    if (_crops.length < 11) {
      setState(() {
        final newId = _crops.length + 1;
        _crops.add({
          'id': newId,
          'name': 'Crop $newId',
        });
      });
    }
  }

  void _removeCrop(int index) {
    if (_crops.length > 1) {
      setState(() {
        _crops.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cropProductivityAndArea,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.provideCropProductionDetails,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Header row for table
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(l10n.crop, style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text(l10n.areaAcres, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              Expanded(flex: 1, child: Text(l10n.productivityQtlAcre, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              Expanded(flex: 1, child: Text(l10n.totalProd, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              Expanded(flex: 1, child: Text(l10n.consumed, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text(l10n.soldQtlRs, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Crop entries
        ..._crops.asMap().entries.map((entry) {
          final index = entry.key;
          final crop = entry.value;
          return Column(
            children: [
              _buildCropRow(crop['id'], l10n, _crops.length > 1 ? () => _removeCrop(index) : null),
              const SizedBox(height: 8),
            ],
          );
        }),

        const SizedBox(height: 16),

        if (_crops.length < 11)
          ElevatedButton.icon(
            onPressed: _addCrop,
            icon: const Icon(Icons.add),
            label: Text(l10n.addAnotherCrop),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.agriculture, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.totalCrops(_crops.length.toString()),
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCropRow(int cropNumber, AppLocalizations l10n, VoidCallback? onRemove) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  l10n.cropNumber(cropNumber.toString()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    tooltip: l10n.removeCrop,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: widget.pageData['crop_${cropNumber}_name'],
                    decoration: InputDecoration(
                      labelText: l10n.cropName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) {
                      widget.pageData['crop_${cropNumber}_name'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: widget.pageData['crop_${cropNumber}_area'],
                    decoration: InputDecoration(
                      labelText: l10n.area,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.pageData['crop_${cropNumber}_area'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: widget.pageData['crop_${cropNumber}_productivity'],
                    decoration: InputDecoration(
                      labelText: l10n.prod,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.pageData['crop_${cropNumber}_productivity'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: widget.pageData['crop_${cropNumber}_total_production'],
                    decoration: InputDecoration(
                      labelText: l10n.total,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.pageData['crop_${cropNumber}_total_production'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: widget.pageData['crop_${cropNumber}_consumed'],
                    decoration: InputDecoration(
                      labelText: l10n.consumed,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.pageData['crop_${cropNumber}_consumed'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: widget.pageData['crop_${cropNumber}_sold'],
                    decoration: InputDecoration(
                      labelText: l10n.soldQtlAndRs,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) {
                      widget.pageData['crop_${cropNumber}_sold'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
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
