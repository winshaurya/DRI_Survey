import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/survey_provider.dart';

class GovernmentSchemesPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const GovernmentSchemesPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<GovernmentSchemesPage> createState() => _GovernmentSchemesPageState();
}

class _GovernmentSchemesPageState extends ConsumerState<GovernmentSchemesPage> {
  // Aadhaar Scheme Members
  List<Map<String, dynamic>> _aadhaarMembers = [];
  // Ayushman Scheme Members
  List<Map<String, dynamic>> _ayushmanMembers = [];
  // Ration Scheme Members
  List<Map<String, dynamic>> _rationMembers = [];
  // Family ID Scheme Members
  List<Map<String, dynamic>> _familyIdMembers = [];
  // Samagra Scheme Members
  List<Map<String, dynamic>> _samagraMembers = [];
  // Handicapped Scheme Members
  List<Map<String, dynamic>> _handicappedMembers = [];
  // Tribal Scheme Members
  List<Map<String, dynamic>> _tribalMembers = [];
  // Pension Scheme Members
  List<Map<String, dynamic>> _pensionMembers = [];
  // Widow Scheme Members
  List<Map<String, dynamic>> _widowMembers = [];

  List<String> _familyMemberNames = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _loadFamilyMembers();
  }

  @override
  void didUpdateWidget(covariant GovernmentSchemesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
      _loadExistingData();
      _loadFamilyMembers();
    }
  }

  void _loadExistingData() {
    _aadhaarMembers = List<Map<String, dynamic>>.from(widget.pageData['aadhaar_scheme_members'] ?? []);
    _ayushmanMembers = List<Map<String, dynamic>>.from(widget.pageData['ayushman_scheme_members'] ?? []);
    _rationMembers = List<Map<String, dynamic>>.from(widget.pageData['ration_scheme_members'] ?? []);
    _familyIdMembers = List<Map<String, dynamic>>.from(widget.pageData['family_id_scheme_members'] ?? []);
    _samagraMembers = List<Map<String, dynamic>>.from(widget.pageData['samagra_scheme_members'] ?? []);
    _handicappedMembers = List<Map<String, dynamic>>.from(widget.pageData['handicapped_scheme_members'] ?? []);
    _tribalMembers = List<Map<String, dynamic>>.from(widget.pageData['tribal_scheme_members'] ?? []);
    _pensionMembers = List<Map<String, dynamic>>.from(widget.pageData['pension_scheme_members'] ?? []);
    _widowMembers = List<Map<String, dynamic>>.from(widget.pageData['widow_scheme_members'] ?? []);
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
    final data = {
      'aadhaar_scheme_members': _aadhaarMembers,
      'ayushman_scheme_members': _ayushmanMembers,
      'ration_scheme_members': _rationMembers,
      'family_id_scheme_members': _familyIdMembers,
      'samagra_scheme_members': _samagraMembers,
      'handicapped_scheme_members': _handicappedMembers,
      'tribal_scheme_members': _tribalMembers,
      'pension_scheme_members': _pensionMembers,
      'widow_scheme_members': _widowMembers,
    };
    widget.onDataChanged(data);
  }

  void _addAadhaarMember() {
    setState(() {
      _aadhaarMembers.add({
        'sr_no': _aadhaarMembers.length + 1,
        'family_member_name': '',
        'have_card': null,
        'card_number': '',
        'details_correct': null,
        'what_incorrect': '',
        'benefits_received': null,
      });
    });
    _updateData();
  }

  void _addAyushmanMember() {
    setState(() {
      _ayushmanMembers.add({
        'sr_no': _ayushmanMembers.length + 1,
        'family_member_name': '',
        'have_card': null,
        'card_number': '',
        'details_correct': null,
        'what_incorrect': '',
        'benefits_received': null,
      });
    });
    _updateData();
  }

  void _addRationMember() {
    setState(() {
      _rationMembers.add({
        'sr_no': _rationMembers.length + 1,
        'family_member_name': '',
        'have_card': null,
        'card_number': '',
        'details_correct': null,
        'what_incorrect': '',
        'benefits_received': null,
      });
    });
    _updateData();
  }

  void _addFamilyIdMember() {
    setState(() {
      _familyIdMembers.add({
        'sr_no': _familyIdMembers.length + 1,
        'family_member_name': '',
        'have_card': null,
        'card_number': '',
        'details_correct': null,
        'what_incorrect': '',
        'benefits_received': null,
      });
    });
    _updateData();
  }

  void _addSamagraMember() {
    setState(() {
      _samagraMembers.add({
        'sr_no': _samagraMembers.length + 1,
        'family_member_name': '',
        'have_card': null,
        'card_number': '',
        'details_correct': null,
        'what_incorrect': '',
        'benefits_received': null,
      });
    });
    _updateData();
  }

  void _addHandicappedMember() {
    setState(() {
      _handicappedMembers.add({
        'sr_no': _handicappedMembers.length + 1,
        'family_member_name': '',
        'have_card': null,
        'card_number': '',
        'details_correct': null,
        'what_incorrect': '',
        'benefits_received': null,
      });
    });
    _updateData();
  }

  void _addTribalMember() {
    setState(() {
      _tribalMembers.add({
        'sr_no': _tribalMembers.length + 1,
        'family_member_name': '',
        'have_card': null,
        'card_number': '',
        'details_correct': null,
        'what_incorrect': '',
        'benefits_received': null,
      });
    });
    _updateData();
  }

  void _addPensionMember() {
    setState(() {
      _pensionMembers.add({
        'sr_no': _pensionMembers.length + 1,
        'family_member_name': '',
        'have_card': null,
        'card_number': '',
        'details_correct': null,
        'what_incorrect': '',
        'benefits_received': null,
      });
    });
    _updateData();
  }

  void _addWidowMember() {
    setState(() {
      _widowMembers.add({
        'sr_no': _widowMembers.length + 1,
        'family_member_name': '',
        'have_card': null,
        'card_number': '',
        'details_correct': null,
        'what_incorrect': '',
        'benefits_received': null,
      });
    });
    _updateData();
  }

  Widget _buildSchemeMemberSection(
    String title,
    IconData icon,
    Color color,
    List<Map<String, dynamic>> members,
    Function() onAddMember,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...members.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              return _buildMemberForm(member, index, members, () => _updateData());
            }),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onAddMember,
              icon: const Icon(Icons.add),
              label: const Text('Add Another Family Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberForm(Map<String, dynamic> member, int index, List<Map<String, dynamic>> members, VoidCallback onUpdate) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Member ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Family Member Name Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Family Member Name',
                border: OutlineInputBorder(),
              ),
              initialValue: member['family_member_name']?.isNotEmpty == true ? member['family_member_name'] : null,
              items: _familyMemberNames.map((name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (value) {
                member['family_member_name'] = value ?? '';
                onUpdate();
              },
            ),
            const SizedBox(height: 12),

            // Have Card Radio Buttons
            const Text('Have Card?', style: TextStyle(fontWeight: FontWeight.w500)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Yes'),
                    value: true,
                    groupValue: member['have_card'],
                    onChanged: (value) {
                      setState(() {
                        member['have_card'] = value;
                        if (value == false) {
                          member['card_number'] = '';
                          member['details_correct'] = null;
                          member['what_incorrect'] = '';
                          member['benefits_received'] = null;
                        }
                      });
                      onUpdate();
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('No'),
                    value: false,
                    groupValue: member['have_card'],
                    onChanged: (value) {
                      setState(() {
                        member['have_card'] = value;
                        if (value == false) {
                          member['card_number'] = '';
                          member['details_correct'] = null;
                          member['what_incorrect'] = '';
                          member['benefits_received'] = null;
                        }
                      });
                      onUpdate();
                    },
                  ),
                ),
              ],
            ),

            // Card Number (only if have_card is true)
            if (member['have_card'] == true) ...[
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                initialValue: member['card_number'] ?? '',
                onChanged: (value) {
                  member['card_number'] = value;
                  onUpdate();
                },
              ),
              const SizedBox(height: 12),

              // Details Correct Radio Buttons
              const Text('Details Correct?', style: TextStyle(fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Yes'),
                      value: true,
                      groupValue: member['details_correct'],
                      onChanged: (value) {
                        setState(() {
                          member['details_correct'] = value;
                          if (value == true) {
                            member['what_incorrect'] = '';
                          }
                        });
                        onUpdate();
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('No'),
                      value: false,
                      groupValue: member['details_correct'],
                      onChanged: (value) {
                        setState(() {
                          member['details_correct'] = value;
                          if (value == true) {
                            member['what_incorrect'] = '';
                          }
                        });
                        onUpdate();
                      },
                    ),
                  ),
                ],
              ),

              // What is incorrect (only if details_correct is false)
              if (member['details_correct'] == false) ...[
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'What is incorrect?',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: member['what_incorrect'] ?? '',
                  onChanged: (value) {
                    member['what_incorrect'] = value;
                    onUpdate();
                  },
                ),
              ],

              const SizedBox(height: 12),

              // Benefits Received Radio Buttons
              const Text('Benefits Received?', style: TextStyle(fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Yes'),
                      value: true,
                      groupValue: member['benefits_received'],
                      onChanged: (value) {
                        member['benefits_received'] = value;
                        onUpdate();
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('No'),
                      value: false,
                      groupValue: member['benefits_received'],
                      onChanged: (value) {
                        member['benefits_received'] = value;
                        onUpdate();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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
              'Government Schemes & Benefits',
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
              'Detailed information about government scheme enrollment and benefits received',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Aadhaar Scheme Section
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: _buildSchemeMemberSection(
              'Aadhaar Scheme',
              Icons.badge, // Replaced '🆔' with Icons.badge
              Colors.blue,
              _aadhaarMembers,
              _addAadhaarMember,
            ),
          ),

          // Ayushman Card Section
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: _buildSchemeMemberSection(
              'Ayushman Card',
              Icons.health_and_safety,
              Colors.teal,
              _ayushmanMembers, 
              _addAyushmanMember,
            ),
          ),

          // Family ID Section
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: _buildSchemeMemberSection(
              'Family ID',
              Icons.family_restroom,
              Colors.brown,
              _familyIdMembers, 
              _addFamilyIdMember, 
            ),
          ),

          // Ration Card Section
          FadeInLeft(
            delay: const Duration(milliseconds: 500),
            child: _buildSchemeMemberSection(
              'Ration Card',
              Icons.shopping_basket,
              Colors.red,
              _rationMembers, 
              _addRationMember, 
            ),
          ),

          // Samagra ID Section
          FadeInLeft(
            delay: const Duration(milliseconds: 600),
            child: _buildSchemeMemberSection(
              'Samagra ID',
              Icons.featured_play_list,
              Colors.purple,
              _samagraMembers, 
              _addSamagraMember, 
            ),
          ),

          // Handicapped Allowance Section
          FadeInLeft(
            delay: const Duration(milliseconds: 700),
            child: _buildSchemeMemberSection(
              'Handicapped Allowance',
              Icons.accessible,
              Colors.orange,
              _handicappedMembers, 
              _addHandicappedMember, 
            ),
          ),

          // Tribal Card Scheme Section
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: _buildSchemeMemberSection(
              'Tribal Card Scheme',
              Icons.forest,
              Colors.orange,
              _tribalMembers,
              _addTribalMember,
            ),
          ),

          // Pension Allowance Scheme Section
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: _buildSchemeMemberSection(
              'Pension Allowance',
              Icons.elderly,
              Colors.green,
              _pensionMembers,
              _addPensionMember,
            ),
          ),

          // Widow Allowance Scheme Section
          FadeInLeft(
            delay: const Duration(milliseconds: 500),
            child: _buildSchemeMemberSection(
              'Widow Allowance',
              Icons.person,
              Colors.purple,
              _widowMembers,
              _addWidowMember,
            ),
          ),
        ],
      ),
    );
  }
}
