import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class SocialConsciousnessPage3 extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const SocialConsciousnessPage3({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<SocialConsciousnessPage3> createState() => _SocialConsciousnessPage3State();
}

class _SocialConsciousnessPage3State extends State<SocialConsciousnessPage3> {
  late TextEditingController _discoursesMembersController;
  late TextEditingController _happinessFamilyWhoController;
  late TextEditingController _unhappinessReasonController;
  late TextEditingController _addictionDetailsController;
  late TextEditingController _savingsPercentageController;

  @override
  void initState() {
    super.initState();
    _discoursesMembersController = TextEditingController(text: widget.pageData['discourses_members'] ?? '');
    _happinessFamilyWhoController = TextEditingController(text: widget.pageData['happiness_family_who'] ?? '');
    _unhappinessReasonController = TextEditingController(text: widget.pageData['unhappiness_reason'] ?? '');
    _addictionDetailsController = TextEditingController(text: widget.pageData['addiction_details'] ?? '');
    _savingsPercentageController = TextEditingController(text: widget.pageData['savings_percentage'] ?? '');
  }

  @override
  void didUpdateWidget(covariant SocialConsciousnessPage3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
      _updateController(_discoursesMembersController, 'discourses_members');
      _updateController(_happinessFamilyWhoController, 'happiness_family_who');
      _updateController(_unhappinessReasonController, 'unhappiness_reason');
      _updateController(_addictionDetailsController, 'addiction_details');
      _updateController(_savingsPercentageController, 'savings_percentage');
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
    _discoursesMembersController.dispose();
    _happinessFamilyWhoController.dispose();
    _unhappinessReasonController.dispose();
    _addictionDetailsController.dispose();
    _savingsPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Helper to get value from pageData
    String? getString(String key) => widget.pageData[key] as String?;
    // Helper to get checked status
    bool isChecked(String key) => widget.pageData[key] == 'yes';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Social Consciousness Survey - Part 3',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Lifestyle, Happiness & Savings',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Question 18: Spiritual Discourses
          const Text(
            '18. Do Members of the Family listen to spiritual/motivational discourses (kathas)?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'spiritual_discourses', 'yes'),
          _buildRadioField('No', 'spiritual_discourses', 'no'),
          if (getString('spiritual_discourses') == 'yes')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _discoursesMembersController,
                decoration: InputDecoration(
                  labelText: 'If yes who?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  widget.pageData['discourses_members'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),

          const SizedBox(height: 24),

          // Question 19: Personal Happiness
          const Text(
            '19. Are you happy?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'personal_happiness', 'yes'),
          _buildRadioField('No', 'personal_happiness', 'no'),

          const SizedBox(height: 24),

          // Question 20: Family Happiness
          const Text(
            '20. Are members of your family happy?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'family_happiness', 'yes'),
          _buildRadioField('No', 'family_happiness', 'no'),
          
          if (getString('family_happiness') == 'yes')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _happinessFamilyWhoController,
                decoration: InputDecoration(
                  labelText: 'If yes, who?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  widget.pageData['happiness_family_who'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),

          if (getString('family_happiness') == 'no') ...[
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 12.0),
              child: Text('Reason for Unhappiness:', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            _buildCheckboxField('Financial Problems', 'financial_problems'),
            _buildCheckboxField('Family Disputes', 'family_disputes'),
            _buildCheckboxField('Illness/Health Issues', 'illness_issues'),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _unhappinessReasonController,
                decoration: InputDecoration(
                  labelText: 'Other Reason (Specify)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  widget.pageData['unhappiness_reason'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Question 21: Addictions
          const Text(
            '21. Does any member of the Family:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCheckboxField('Smoke', 'addiction_smoke'),
          _buildCheckboxField('Drink', 'addiction_drink'),
          _buildCheckboxField('Eat Gudka', 'addiction_gutka'),
          _buildCheckboxField('Gamble', 'addiction_gamble'),
          _buildCheckboxField('Chew Tambacoo', 'addiction_tobacco'),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: TextFormField(
              controller: _addictionDetailsController,
              decoration: InputDecoration(
                labelText: 'Other / Details',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                widget.pageData['addiction_details'] = value;
                widget.onDataChanged(widget.pageData);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Question 22: Savings
          const Text(
            '22. Do you save your income?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'savings_exists', 'yes'),
          _buildRadioField('No', 'savings_exists', 'no'),
          if (getString('savings_exists') == 'yes')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _savingsPercentageController,
                decoration: InputDecoration(
                  labelText: 'What percentage of income',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  widget.pageData['savings_percentage'] = value;
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

  Widget _buildCheckboxField(String label, String key) {
    return CheckboxListTile(
      title: Text(label),
      value: widget.pageData[key] == 'yes',
      onChanged: (bool? value) {
        setState(() {
          widget.pageData[key] = value == true ? 'yes' : 'no';
        });
        widget.onDataChanged(widget.pageData);
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.only(left: 16.0),
      visualDensity: VisualDensity.compact,
    );
  }
}
