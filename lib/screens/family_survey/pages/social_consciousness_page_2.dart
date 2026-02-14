import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class SocialConsciousnessPage2 extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const SocialConsciousnessPage2({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<SocialConsciousnessPage2> createState() => _SocialConsciousnessPage2State();
}

class _SocialConsciousnessPage2State extends State<SocialConsciousnessPage2> {
  late TextEditingController _meditationMembersController;
  late TextEditingController _yogaMembersController;
  late TextEditingController _communityActivitiesTypeController;
  late TextEditingController _shramSadhanaMembersController;

  @override
  void initState() {
    super.initState();
    _meditationMembersController = TextEditingController(text: widget.pageData['meditation_members'] ?? '');
    _yogaMembersController = TextEditingController(text: widget.pageData['yoga_members'] ?? '');
    _communityActivitiesTypeController = TextEditingController(text: widget.pageData['community_activities_type'] ?? '');
    _shramSadhanaMembersController = TextEditingController(text: widget.pageData['shram_sadhana_members'] ?? '');
  }

  @override
  void didUpdateWidget(covariant SocialConsciousnessPage2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
      _updateController(_meditationMembersController, 'meditation_members');
      _updateController(_yogaMembersController, 'yoga_members');
      _updateController(_communityActivitiesTypeController, 'community_activities_type');
      _updateController(_shramSadhanaMembersController, 'shram_sadhana_members');
    }
  }

  void _updateController(TextEditingController controller, String key) {
    final newVal = widget.pageData[key] as String? ?? '';
    if (controller.text != newVal) {
      controller.text = newVal;
    }
  }

  @override
  void dispose() {
    _meditationMembersController.dispose();
    _yogaMembersController.dispose();
    _communityActivitiesTypeController.dispose();
    _shramSadhanaMembersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Helper to get value from pageData
    String? getString(String key) => widget.pageData[key] as String?;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Social Consciousness Survey - Part 2',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please answer questions about lifestyle and community participation',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Question 9: LED Lights
          const Text(
            '9. Do you use LED lights?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'led_lights', 'yes'),
          _buildRadioField('No', 'led_lights', 'no'),

          const SizedBox(height: 24),

          // Question 10: Turn off devices
          const Text(
            '10. Do you turn off Electrical/Electronic devices when not in use?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'turn_off_devices', 'yes'),
          _buildRadioField('No', 'turn_off_devices', 'no'),

          const SizedBox(height: 24),

          // Question 11: Fix Leaks
          const Text(
            '11. If you find water leaking from any tap/hand pump do you try to fix it?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'fix_leaks', 'yes'),
          _buildRadioField('No', 'fix_leaks', 'no'),

          const SizedBox(height: 24),

          // Question 12: Avoid Plastics
          const Text(
            '12. Do you avoid single-use plastics?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'avoid_plastics', 'yes'),
          _buildRadioField('No', 'avoid_plastics', 'no'),

          const SizedBox(height: 24),

          // Question 13: Puja/Pray
          const Text(
            '13. Do all Members do the Family do Puja/Pray?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'family_prayers', 'yes'),
          _buildRadioField('No', 'family_prayers', 'no'),

          const SizedBox(height: 24),

          // Question 14: Meditate
          const Text(
            '14. Do Members of the Family Meditate?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'family_meditation', 'yes'),
          _buildRadioField('No', 'family_meditation', 'no'),
          if (getString('family_meditation') == 'yes')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _meditationMembersController,
                decoration: InputDecoration(
                  labelText: 'If yes who?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  widget.pageData['meditation_members'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),

          const SizedBox(height: 24),

          // Question 15: Yoga
          const Text(
            '15. Do Members of the Family do Yoga?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'family_yoga', 'yes'),
          _buildRadioField('No', 'family_yoga', 'no'),
          if (getString('family_yoga') == 'yes')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _yogaMembersController,
                decoration: InputDecoration(
                  labelText: 'If yes who?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  widget.pageData['yoga_members'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),

          const SizedBox(height: 24),

          // Question 16: Community Activities
          const Text(
            '16. Do Members of the Family participate in community activities?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'community_activities', 'yes'),
          _buildRadioField('No', 'community_activities', 'no'),
          if (getString('community_activities') == 'yes')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _communityActivitiesTypeController,
                decoration: InputDecoration(
                  labelText: 'If yes, which?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  widget.pageData['community_activities_type'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),

          const SizedBox(height: 24),

          // Question 17: Shram Sadhana
          const Text(
            '17. Do members of your Family participate in Shram Sadhana?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'shram_sadhana', 'yes'),
          _buildRadioField('No', 'shram_sadhana', 'no'),
          if (getString('shram_sadhana') == 'yes')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _shramSadhanaMembersController,
                decoration: InputDecoration(
                  labelText: 'If yes who?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  widget.pageData['shram_sadhana_members'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadioField(String label, String groupKey, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: widget.pageData[groupKey],
      onChanged: (newValue) {
        setState(() {
          widget.pageData[groupKey] = newValue;
        });
        widget.onDataChanged(widget.pageData);
      },
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

