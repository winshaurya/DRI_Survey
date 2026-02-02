
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class FolkloreMedicinePage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const FolkloreMedicinePage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<FolkloreMedicinePage> createState() => _FolkloreMedicinePageState();
}

class _FolkloreMedicinePageState extends State<FolkloreMedicinePage> {
  final List<Map<String, dynamic>> _folkloreMedicines = [];
  final _formKey = GlobalKey<FormState>();

  // Controllers for current entry
  String? _selectedFamilyMember;
  final TextEditingController _plantLocalNameController = TextEditingController();
  final TextEditingController _plantBotanicalNameController = TextEditingController();
  final TextEditingController _usesController = TextEditingController();

  List<String> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Load existing data from pageData
    final existingData = widget.pageData['folklore_medicines'] as List<dynamic>?;

    if (existingData != null && _folkloreMedicines.isEmpty) {
      _folkloreMedicines.clear();
      _folkloreMedicines.addAll(existingData.map((item) => Map<String, dynamic>.from(item)));
    }

    // Load family members
    _loadFamilyMembers();
  }

  void _loadFamilyMembers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final familyMembersData = widget.pageData['family_members'] as List<dynamic>? ?? [];

      if (familyMembersData.isNotEmpty && mounted) {
        final members = familyMembersData
            .map((member) => member['name'] as String)
            .where((name) => name.isNotEmpty)
            .toList();

        if (_familyMembers != members) {
          setState(() {
            _familyMembers = members;
          });
        }
      }
    });
  }

  void _addFolkloreMedicine() {
    if (_selectedFamilyMember != null &&
        (_plantLocalNameController.text.isNotEmpty ||
        _plantBotanicalNameController.text.isNotEmpty ||
        _usesController.text.isNotEmpty)) {

      setState(() {
        _folkloreMedicines.add({
          'person_name': _selectedFamilyMember,
          'plant_local_name': _plantLocalNameController.text.trim(),
          'plant_botanical_name': _plantBotanicalNameController.text.trim(),
          'uses': _usesController.text.trim(),
        });
      });

      // Clear controllers
      _selectedFamilyMember = null;
      _plantLocalNameController.clear();
      _plantBotanicalNameController.clear();
      _usesController.clear();

      // Update data
      _updateData();
    }
  }

  void _removeFolkloreMedicine(int index) {
    setState(() {
      _folkloreMedicines.removeAt(index);
    });
    _updateData();
  }

  void _updateData() {
    final data = {
      'folklore_medicines': _folkloreMedicines,
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
              'Knowledge About Folklore Medicine',
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
              'Record traditional medicinal knowledge from family members',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),

          // Existing entries
          if (_folkloreMedicines.isNotEmpty) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recorded Folklore Medicines',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._folkloreMedicines.asMap().entries.map((entry) {
                      final index = entry.key;
                      final medicine = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Family Member: ${medicine['person_name']}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Plant: ${medicine['plant_local_name']} (${medicine['plant_botanical_name']})',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  Text(
                                    'Uses: ${medicine['uses']}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeFolkloreMedicine(index),
                              tooltip: 'Remove entry',
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Add new entry form
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Folklore Medicine Knowledge',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter details about traditional medicinal plants known to family members',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedFamilyMember,
                      decoration: InputDecoration(
                        labelText: 'Family Member Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: _familyMembers.map((member) {
                        return DropdownMenuItem<String>(
                          value: member,
                          child: Text(member),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedFamilyMember = value);
                        _updateData();
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _plantLocalNameController,
                      decoration: InputDecoration(
                        labelText: 'Name of the Plant (Local)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.grass),
                      ),
                      onChanged: (value) => _updateData(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _plantBotanicalNameController,
                      decoration: InputDecoration(
                        labelText: 'Name of the Plant (Botanical)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.science),
                      ),
                      onChanged: (value) => _updateData(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _usesController,
                      decoration: InputDecoration(
                        labelText: 'Uses of the Plant',
                        hintText: 'Describe how the plant is used medicinally',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.medical_services),
                      ),
                      maxLines: 3,
                      onChanged: (value) => _updateData(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _folkloreMedicines.add({
                            'person_name': '',
                            'plant_local_name': '',
                            'plant_botanical_name': '',
                            'uses': '',
                          });
                        });
                      },
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Add More Folklore Medicines'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

        ],
      ),
    );
  }

  @override
  void dispose() {
    _plantLocalNameController.dispose();
    _plantBotanicalNameController.dispose();
    _usesController.dispose();
    super.dispose();
  }
}