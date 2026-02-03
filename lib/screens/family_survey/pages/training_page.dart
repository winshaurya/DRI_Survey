import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/survey_provider.dart';

class TrainingPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const TrainingPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends ConsumerState<TrainingPage> {
  // Training
  List<Map<String, dynamic>> _trainingsTaken = [];
  bool _needTraining = false;
  List<Map<String, dynamic>> _trainingsNeeded = [];

  // SHG
  List<Map<String, dynamic>> _shgMembers = [];
  // FPO
  List<Map<String, dynamic>> _fpoMembers = [];

  List<String> _familyMemberNames = [];
  
  static const List<String> _farmSectors = [
    'Mushroom Production', 'Pearl Culture', 'Goat Farming', 'Poultry Farming', 
    'Fish Culture', 'Seed Production', 'Dairying', 'Vermi Compost Production', 
    'Bio Formulations', 'Herbal Gulal', 'Ornamental and Vegetable Nursery', 
    'Fruit Plant Nursery', 'Value Additon and Processing of Spices', 
    'Value Additon and Processing of Forest Produce'
  ];

  static const List<String> _nonFarmSectors = [
    'Cutting and Tailoring', 'Beauty and Wellness', 'Plumbing', 
    'Computer application', 'Solar', 'Automobile', 'Electrician', 'Handy Crafts'
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _loadFamilyMembers();
  }

  void _loadExistingData() {
    // Separate taken vs needed
    final rawTrainings = List<Map<String, dynamic>>.from(widget.pageData['training_members'] ?? []);
    
    _trainingsTaken = rawTrainings.where((t) => t['status'] == 'taken' || t['status'] == null).toList();
    _trainingsNeeded = rawTrainings.where((t) => t['status'] == 'needed').toList();
    
    _needTraining = widget.pageData['want_training'] == true || _trainingsNeeded.isNotEmpty;

    _shgMembers = List<Map<String, dynamic>>.from(widget.pageData['shg_members'] ?? []);
    _fpoMembers = List<Map<String, dynamic>>.from(widget.pageData['fpo_members'] ?? []);
  }

  @override
  void didUpdateWidget(covariant TrainingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always reload data as pageData is mutated in place by parent
    _loadExistingData();
    _loadFamilyMembers();
  }

  void _loadFamilyMembers() {
    // Try to get family members from pageData first, then fallback to provider
    List<dynamic> familyMembers = [];
    
    // First, check if family_members are in pageData (passed from SurveyPage)
    if (widget.pageData['family_members'] != null) {
      familyMembers = widget.pageData['family_members'] as List<dynamic>;
    } else {
      // Fallback to provider
      final surveyState = ref.read(surveyProvider);
      familyMembers = surveyState.surveyData['family_members'] as List<dynamic>? ?? [];
    }
    
    if (mounted) {
      setState(() {
        _familyMemberNames = familyMembers.map((member) => member['name'] as String? ?? '').where((name) => name.isNotEmpty).toList();
      });
    }
  }

  void _updateData() {
    final allTrainings = [..._trainingsTaken, ..._trainingsNeeded];
    final data = {
      'training_members': allTrainings,
      'want_training': _needTraining,
      'shg_members': _shgMembers,
      'fpo_members': _fpoMembers,
    };
    widget.onDataChanged(data);
  }

  // --- Add Methods ---
  void _addTrainingTaken() {
    setState(() {
      _trainingsTaken.add({
        'member_name': '',
        'training_type': '',
        'pass_out_year': '',
        'status': 'taken',
      });
    });
    _updateData();
  }

  void _addTrainingNeeded() {
    setState(() {
      _trainingsNeeded.add({
        'member_name': '',
        'training_type': '',
        'status': 'needed',
      });
    });
    _updateData();
  }

  void _addShgMember() {
    setState(() {
      _shgMembers.add({
        'member_name': '',
        'shg_name': '',
        'purpose': '',
        'agency': '',
      });
    });
    _updateData();
  }

  void _addFpoMember() {
    setState(() {
      _fpoMembers.add({
        'member_name': '',
        'fpo_name': '',
        'purpose': '',
        'agency': '',
      });
    });
    _updateData();
  }

  // --- Remove Methods ---
  void _removeTrainingTaken(int index) {
    setState(() {
      _trainingsTaken.removeAt(index);
    });
    _updateData();
  }

  void _removeTrainingNeeded(int index) {
    setState(() {
      _trainingsNeeded.removeAt(index);
    });
    _updateData();
  }

  void _removeShgMember(int index) {
    setState(() {
      _shgMembers.removeAt(index);
    });
    _updateData();
  }

  void _removeFpoMember(int index) {
    setState(() {
      _fpoMembers.removeAt(index);
    });
    _updateData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              'Training & Memberships',
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
              'Details about agricultural training and membership in SHGs or FPOs',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Training Taken Section ---
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: _buildSectionHeader(
              'Training Taken?',
              'Family members that have already received training',
              Icons.school,
              Colors.orange,
              _addTrainingTaken,
              'Add Family Member',
            ),
          ),
          const SizedBox(height: 16),
          if (_trainingsTaken.isEmpty)
             _buildEmptyState('No training records added.'),
          ...List.generate(
            _trainingsTaken.length,
            (index) => _buildTrainingTakenCard(index, _trainingsTaken[index]),
          ),

          const SizedBox(height: 32),
          const Divider(thickness: 1.5),
          const SizedBox(height: 16),

          // --- Training Needs Section ---
           FadeInLeft(
            delay: const Duration(milliseconds: 250),
            child: _buildTrainingNeedsSection(),
           ),

          const SizedBox(height: 32),
          const Divider(thickness: 1.5),
          const SizedBox(height: 16),

          // --- SHG Section ---
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: _buildSectionHeader(
              'Self Help Group (SHG) Members',
              'Family members part of SHG',
              Icons.groups,
              Colors.purple,
              _addShgMember,
              'Add Another Family Member',
            ),
          ),
          const SizedBox(height: 16),
          if (_shgMembers.isEmpty)
             _buildEmptyState('No SHG members added.'),
          ...List.generate(
            _shgMembers.length,
            (index) => _buildShgCard(index, _shgMembers[index]),
          ),

          const SizedBox(height: 32),
          const Divider(thickness: 1.5),
          const SizedBox(height: 16),

          // --- FPO Section ---
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: _buildSectionHeader(
              'FPO Members',
              'Family members part of FPO',
              Icons.store,
              Colors.teal,
              _addFpoMember,
              'Add Another Family Member',
            ),
          ),
          const SizedBox(height: 16),
          ..._fpoMembers.asMap().entries.map((entry) => _buildFpoCard(entry.key, entry.value)),
          
          const SizedBox(height: 60), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color, VoidCallback onAdd, String addLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: Text(addLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingNeedsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Text(
            'Do you need Training?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _needTraining,
                onChanged: (val) {
                  setState(() {
                    _needTraining = val!;
                    if (_trainingsNeeded.isEmpty) {
                      _addTrainingNeeded();
                    }
                  });
                  _updateData();
                },
              ),
              const Text('Yes'),
              const SizedBox(width: 24),
              Radio<bool>(
                value: false,
                groupValue: _needTraining,
                onChanged: (val) {
                   setState(() {
                    _needTraining = val!;
                    _trainingsNeeded.clear();
                  });
                  _updateData();
                },
              ),
              const Text('No'),
            ],
          ),
          if (_needTraining) ...[
            const SizedBox(height: 16),
            ...List.generate(
              _trainingsNeeded.length,
              (index) => _buildTrainingNeededCard(index, _trainingsNeeded[index]),
            ),
            if (_trainingsNeeded.isNotEmpty)
              Padding(
                 padding: const EdgeInsets.only(top: 8),
                 child: TextButton.icon(
                    onPressed: _addTrainingNeeded,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Requirement'),
                 ),
              ),
          ]
      ],
    );
  }

  // --- Specific Card Builders ---

  Widget _buildTrainingTakenCard(int index, Map<String, dynamic> data) {
    return _buildBaseCard(
      index,
      'training_taken',
      Colors.orange,
      () => _removeTrainingTaken(index),
      children: [
        _buildMemberDropdown(data, 'member_name'),
        const SizedBox(height: 12),
        _buildTrainingTypeDropdown(data, 'training_type', 'Field of Training'),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Passing Year', border: OutlineInputBorder()),
           initialValue: data['pass_out_year']?.toString(),
           keyboardType: TextInputType.number,
           onChanged: (val) {
             data['pass_out_year'] = val;
             _updateData();
           },
        ),
      ],
    );
  }

  Widget _buildTrainingNeededCard(int index, Map<String, dynamic> data) {
    return _buildBaseCard(
      index,
      'training_needed',
      Colors.blue,
      () => _removeTrainingNeeded(index),
      children: [
        // Optional: Member name if we want to track WHO needs it. 
        // User prompt: "If Yes, 'What field', and space to add what wanted via same autofill dropdown".
        // It implies we just want the field. But in family survey context, member is good practice.
        _buildMemberDropdown(data, 'member_name'),
         const SizedBox(height: 12),
        _buildTrainingTypeDropdown(data, 'training_type', 'What field?'),
      ],
    );
  }

  Widget _buildTrainingTypeDropdown(Map<String, dynamic> data, String key, String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      value: (data[key] != null && (_farmSectors.contains(data[key]) || _nonFarmSectors.contains(data[key]))) ? data[key] : null,
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(
          enabled: false,
          child: Text('--- Farm Sectors ---', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        ..._farmSectors.map((e) => DropdownMenuItem(value: e, child: Text(e))),
        const DropdownMenuItem<String>(
          enabled: false,
          child: Text('--- Non Farm Sectors ---', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        ..._nonFarmSectors.map((e) => DropdownMenuItem(value: e, child: Text(e))),
      ],
      onChanged: (val) {
        if (val != null) {
          data[key] = val;
          _updateData();
        }
      },
    );
  }

  Widget _buildShgCard(int index, Map<String, dynamic> data) {
    return _buildBaseCard(
      index,
      'shg',
      Colors.purple,
      () => _removeShgMember(index),
      children: [
        _buildMemberDropdown(data, 'member_name'),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Name of SHG', border: OutlineInputBorder()),
          initialValue: data['shg_name'],
          onChanged: (val) {
            data['shg_name'] = val;
            _updateData();
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Purpose of SHG', border: OutlineInputBorder()),
          initialValue: data['purpose'],
           onChanged: (val) {
             data['purpose'] = val;
             _updateData();
           },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Under which Agency', border: OutlineInputBorder()),
          initialValue: data['agency'],
           onChanged: (val) {
             data['agency'] = val;
             _updateData();
           },
        ),
      ],
    );
  }

  Widget _buildFpoCard(int index, Map<String, dynamic> data) {
    return _buildBaseCard(
      index,
      'fpo',
      Colors.teal,
      () => _removeFpoMember(index),
      children: [
        _buildMemberDropdown(data, 'member_name'),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Name of FPO / Co-op', border: OutlineInputBorder()),
          initialValue: data['fpo_name'],
          onChanged: (val) {
            data['fpo_name'] = val;
            _updateData();
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Purpose of FPO', border: OutlineInputBorder()),
          initialValue: data['purpose'],
          onChanged: (val) {
            data['purpose'] = val;
            _updateData();
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Under which Agency', border: OutlineInputBorder()),
          initialValue: data['agency'],
          onChanged: (val) {
            data['agency'] = val;
            _updateData();
          },
        ),
      ],
    );
  }

  // --- Reusable Widgets ---
  Widget _buildBaseCard(int index, String keyPrefix, Color color, VoidCallback onRemove, {required List<Widget> children}) {
    return FadeInUp(
      key: ValueKey('${keyPrefix}_$index'),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.3))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: onRemove,
                    child: const Icon(Icons.delete, color: Colors.grey, size: 20),
                  ),
                ],
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberDropdown(Map<String, dynamic> data, String key) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Family Member Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      value: data[key]?.isNotEmpty == true ? data[key] : null,
      items: _familyMemberNames.map((name) {
        return DropdownMenuItem<String>(
          value: name,
          child: Text(name),
        );
      }).toList(),
      onChanged: (value) {
        data[key] = value ?? '';
        _updateData();
      },
    );
  }
}
