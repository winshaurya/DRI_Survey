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
  List<Map<String, dynamic>> _trainings = [];
  // SHG
  List<Map<String, dynamic>> _shgMembers = [];
  // FPO
  List<Map<String, dynamic>> _fpoMembers = [];

  List<String> _familyMemberNames = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _loadFamilyMembers();
  }

  void _loadExistingData() {
    _trainings = List<Map<String, dynamic>>.from(widget.pageData['trainings'] ?? []);
    _shgMembers = List<Map<String, dynamic>>.from(widget.pageData['shg_members'] ?? []);
    _fpoMembers = List<Map<String, dynamic>>.from(widget.pageData['fpo_members'] ?? []);
  }

  void _loadFamilyMembers() {
    final surveyState = ref.read(surveyProvider);
    final familyMembers = surveyState.surveyData['family_members'] as List<dynamic>? ?? [];
    _familyMemberNames = familyMembers.map((member) => member['name'] as String? ?? '').where((name) => name.isNotEmpty).toList();
  }

  void _updateData() {
    final data = {
      'trainings': _trainings,
      'shg_members': _shgMembers,
      'fpo_members': _fpoMembers,
    };
    widget.onDataChanged(data);
  }

  // --- Add Methods ---
  void _addTraining() {
    setState(() {
      _trainings.add({
        'member_name': '',
        'training_type': '',
        'duration': '',
        'institute': '',
      });
    });
    _updateData();
  }

  void _addShgMember() {
    setState(() {
      _shgMembers.add({
        'member_name': '',
        'shg_name': '',
        'role': '',
      });
    });
    _updateData();
  }

  void _addFpoMember() {
    setState(() {
      _fpoMembers.add({
        'member_name': '',
        'fpo_name': '',
        'share_amount': '',
      });
    });
    _updateData();
  }

  // --- Remove Methods ---
  void _removeTraining(int index) {
    setState(() {
      _trainings.removeAt(index);
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

          // --- Training Section ---
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: _buildSectionHeader(
              'Technical Training',
              Icons.school,
              Colors.orange,
              _addTraining,
              'Add Training Details',
            ),
          ),
          const SizedBox(height: 16),
          ..._trainings.asMap().entries.map((entry) => _buildTrainingCard(entry.key, entry.value)),
          const SizedBox(height: 24),

          // --- SHG Section ---
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: _buildSectionHeader(
              'Self Help Group (SHG) Membership',
              Icons.diversity_3,
              Colors.purple,
              _addShgMember,
              'Add SHG Member',
            ),
          ),
          const SizedBox(height: 16),
          ..._shgMembers.asMap().entries.map((entry) => _buildShgCard(entry.key, entry.value)),
          const SizedBox(height: 24),

          // --- FPO Section ---
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: _buildSectionHeader(
              'FPO Membership',
              Icons.agriculture,
              Colors.teal,
              _addFpoMember,
              'Add FPO Member',
            ),
          ),
          const SizedBox(height: 16),
          ..._fpoMembers.asMap().entries.map((entry) => _buildFpoCard(entry.key, entry.value)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, VoidCallback onAdd, String addLabel) {
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
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  // --- Specific Card Builders ---

  Widget _buildTrainingCard(int index, Map<String, dynamic> data) {
    return _buildBaseCard(
      index,
      Colors.orange,
      () => _removeTraining(index),
      children: [
        _buildMemberDropdown(data, 'member_name'),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Training Type / Subject', border: OutlineInputBorder()),
          initialValue: data['training_type'],
          onChanged: (val) {
             data['training_type'] = val;
             _updateData();
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Duration (days)', border: OutlineInputBorder()),
                 initialValue: data['duration'],
                 onChanged: (val) {
                    data['duration'] = val;
                    _updateData();
                 },
                 keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Organizing Institute', border: OutlineInputBorder()),
                initialValue: data['institute'],
                onChanged: (val) {
                  data['institute'] = val;
                  _updateData();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShgCard(int index, Map<String, dynamic> data) {
    return _buildBaseCard(
      index,
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
          decoration: const InputDecoration(labelText: 'Role / Designation', border: OutlineInputBorder()),
          initialValue: data['role'],
           onChanged: (val) {
             data['role'] = val;
             _updateData();
           },
        ),
      ],
    );
  }

  Widget _buildFpoCard(int index, Map<String, dynamic> data) {
    return _buildBaseCard(
      index,
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
          decoration: const InputDecoration(labelText: 'Share Capital Amount (₹)', border: OutlineInputBorder()),
          initialValue: data['share_amount'],
          keyboardType: TextInputType.number,
          onChanged: (val) {
            data['share_amount'] = val;
            _updateData();
          },
        ),
      ],
    );
  }

  // --- Reusable Widgets ---
  Widget _buildBaseCard(int index, Color color, VoidCallback onRemove, {required List<Widget> children}) {
    return FadeInUp(
      key: ValueKey('card_$index'),
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
