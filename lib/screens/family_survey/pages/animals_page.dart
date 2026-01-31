import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/autocomplete_dropdown.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/survey_provider.dart';

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
  late List<Map<String, dynamic>> _animals;
  final Map<int, TextEditingController> _breedControllers = {};

  // Animal breed options
  final Map<String, List<String>> _animalBreeds = {
    'Cattle': ['Desi', 'Kenkatha', 'Sahiwal', 'Gir', 'Hariana'],
    'Buffalo': ['Desi', 'Murrah', 'Bhadawari'],
    'Goat': ['Bundelkhandi', 'Jamunapari', 'Barbari', 'Beetal'],
    'Sheep': ['Jalauni', 'Marwari'],
    'Pig': ['Desi', 'Large White Yorkshires'],
  };

  @override
  void initState() {
    super.initState();
    // Initialize animals list from pageData, checking type safety
    if (widget.pageData['animals'] is List) {
      _animals = List<Map<String, dynamic>>.from(
        (widget.pageData['animals'] as List).map((e) => Map<String, dynamic>.from(e))
      );
    } else {
      _animals = [];
    }
  }

  @override
  void dispose() {
    // Dispose all breed controllers
    for (final controller in _breedControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateData() {
    final data = {'animals': _animals};
    widget.onDataChanged(data);
  }

  void _addAnimal() {
    setState(() {
      _animals.add({
        'sr_no': _animals.length + 1,
        'animal_type': '',
        'number_of_animals': '',
        'breed': '',
        'production_per_animal': '',
        'quantity_sold': '',
      });
    });
    _updateData();
  }

  void _removeAnimal(int index) {
    setState(() {
      _animals.removeAt(index);
      // Re-index remaining animals
      for (int i = 0; i < _animals.length; i++) {
        _animals[i]['sr_no'] = i + 1;
      }
    });
    _updateData();
  }

  @override
  Widget build(BuildContext context) {
    // Access context and survey provider to get data if not provided via props (fallback)
    // In this architecture, we rely on initState from widget.pageData,
    // but we could also watch provider if needed.

    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              l10n.animals,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Please provide details about your livestock',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),

          if (_animals.isEmpty)
             FadeInLeft(
               delay: const Duration(milliseconds: 100),
               child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Click "Add Another Animal" to add livestock details.',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
                           ),
             ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _animals.length,
            itemBuilder: (context, index) {
              return FadeInLeft(
                delay: Duration(milliseconds: 150 + (index * 50)),
                child: _buildAnimalCard(index, l10n),
              );
            },
          ),

          const SizedBox(height: 24),

          Center(
            child: FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: ElevatedButton.icon(
                onPressed: _addAnimal,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Animal'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreedAutocomplete(int index, Map<String, dynamic> animal, AppLocalizations l10n) {
    // Initialize controller if not exists
    if (!_breedControllers.containsKey(index)) {
      _breedControllers[index] = TextEditingController(text: animal['breed'] ?? '');
    }

    // Get breed options based on animal type
    final animalType = animal['animal_type']?.toString() ?? '';
    final breedOptions = _animalBreeds[animalType] ?? [];

    return AutocompleteDropdown(
      label: l10n.breed,
      hintText: 'Select or type breed',
      options: breedOptions,
      controller: _breedControllers[index]!,
      initialValue: animal['breed'],
      onChanged: (value) {
        animal['breed'] = value;
        _updateData();
      },
    );
  }

  Widget _buildAnimalCard(int index, AppLocalizations l10n) {
    final animal = _animals[index];
    final animalNumber = index + 1;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Animal $animalNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeAnimal(index),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            TextFormField(
              initialValue: animal['animal_type'],
              decoration: InputDecoration(
                labelText: l10n.animalType,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.pets),
              ),
              onChanged: (value) {
                animal['animal_type'] = value;
                // Reset breed if it's not valid for the new animal type
                final breedOptions = _animalBreeds[value] ?? [];
                if (animal['breed'] != null && animal['breed'].isNotEmpty && !breedOptions.contains(animal['breed'])) {
                  animal['breed'] = '';
                  if (_breedControllers.containsKey(index)) {
                    _breedControllers[index]!.text = '';
                  }
                }
                _updateData();
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: animal['number_of_animals']?.toString(),
                    decoration: InputDecoration(
                      labelText: l10n.numberOfAnimals,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      animal['number_of_animals'] = value;
                      _updateData();
                    },
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _buildBreedAutocomplete(index, animal, l10n),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: animal['production_per_animal']?.toString(),
              decoration: InputDecoration(
                labelText: 'Production per Animal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.production_quantity_limits),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                animal['production_per_animal'] = value;
                _updateData();
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: animal['quantity_sold']?.toString(),
              decoration: InputDecoration(
                labelText: 'Quantity Sold',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.shopping_cart),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                animal['quantity_sold'] = value;
                _updateData();
              },
            ),
          ],
        ),
      ),
    );
  }
}