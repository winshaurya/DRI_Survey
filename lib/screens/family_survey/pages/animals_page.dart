import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class AnimalsPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const AnimalsPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage> {
  List<Map<String, dynamic>> _animals = [];

  @override
  void initState() {
    super.initState();
    // Initialize with at least one animal
    if (_animals.isEmpty) {
      _animals.add({
        'id': 1,
        'name': 'Animal 1',
      });
    }
  }

  void _addAnimal() {
    if (_animals.length < 10) {
      setState(() {
        final newId = _animals.length + 1;
        _animals.add({
          'id': newId,
          'name': 'Animal $newId',
        });
      });
    }
  }

  void _removeAnimal(int index) {
    if (_animals.length > 1) {
      setState(() {
        _animals.removeAt(index);
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
          l10n.numberOfAnimals,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.provideLivestockDetails,
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
              Expanded(flex: 2, child: Text(l10n.animal, style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text(l10n.noOfAnimals, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              Expanded(flex: 1, child: Text(l10n.breed, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              Expanded(flex: 1, child: Text(l10n.productionPerAnimal, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              Expanded(flex: 1, child: Text(l10n.quantitySold, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Animal entries
        ..._animals.asMap().entries.map((entry) {
          final index = entry.key;
          final animal = entry.value;
          return Column(
            children: [
              _buildAnimalRow(animal['id'], l10n, _animals.length > 1 ? () => _removeAnimal(index) : null),
              const SizedBox(height: 8),
            ],
          );
        }),

        const SizedBox(height: 16),

        if (_animals.length < 10)
          ElevatedButton.icon(
            onPressed: _addAnimal,
            icon: const Icon(Icons.add),
            label: Text(l10n.addAnotherAnimal),
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
              Icon(Icons.pets, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.totalAnimalTypes(_animals.length.toString()),
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

  Widget _buildAnimalRow(int animalNumber, AppLocalizations l10n, VoidCallback? onRemove) {
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
                  l10n.animalNumber(animalNumber.toString()),
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
                    tooltip: l10n.removeAnimal,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: widget.pageData['animal_${animalNumber}_type'],
                    decoration: InputDecoration(
                      labelText: l10n.animalType,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) {
                      widget.pageData['animal_${animalNumber}_type'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: widget.pageData['animal_${animalNumber}_count'],
                    decoration: InputDecoration(
                      labelText: l10n.numberOfAnimals,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.pageData['animal_${animalNumber}_count'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: widget.pageData['animal_${animalNumber}_breed'],
                    decoration: InputDecoration(
                      labelText: l10n.breed,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) {
                      widget.pageData['animal_${animalNumber}_breed'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: widget.pageData['animal_${animalNumber}_production'],
                    decoration: InputDecoration(
                      labelText: l10n.productionPerAnimal,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) {
                      widget.pageData['animal_${animalNumber}_production'] = value;
                      widget.onDataChanged(widget.pageData);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: widget.pageData['animal_${animalNumber}_sold'],
                    decoration: InputDecoration(
                      labelText: l10n.quantitySold,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) {
                      widget.pageData['animal_${animalNumber}_sold'] = value;
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
