import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class SocialConsciousnessPage1 extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const SocialConsciousnessPage1({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<SocialConsciousnessPage1> createState() => _SocialConsciousnessPage1State();
}

class _SocialConsciousnessPage1State extends State<SocialConsciousnessPage1> {
  late TextEditingController _clothesOtherController;
  late TextEditingController _foodWasteAmountController;
  late TextEditingController _wasteDisposalOtherController;

  @override
  void initState() {
    super.initState();
    _clothesOtherController = TextEditingController(text: widget.pageData['clothes_other_specify'] ?? '');
    _foodWasteAmountController = TextEditingController(text: widget.pageData['food_waste_amount'] ?? '');
    _wasteDisposalOtherController = TextEditingController(text: widget.pageData['waste_disposal_other'] ?? '');
  }

  @override
  void didUpdateWidget(covariant SocialConsciousnessPage1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
      _updateController(_clothesOtherController, 'clothes_other_specify');
      _updateController(_foodWasteAmountController, 'food_waste_amount');
      _updateController(_wasteDisposalOtherController, 'waste_disposal_other');
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
    _clothesOtherController.dispose();
    _foodWasteAmountController.dispose();
    _wasteDisposalOtherController.dispose();
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
            'Social Consciousness Survey - Part 1',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please answer questions about environmental consciousness and daily habits',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Question 1: Clothes Buying
          const Text(
            '1. How often do family Member\'s buy new clothes?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Weekly', 'clothes_frequency', 'weekly'),
          _buildRadioField('Monthly', 'clothes_frequency', 'monthly'),
          _buildRadioField('Yearly', 'clothes_frequency', 'yearly'),
          _buildRadioField('As per need', 'clothes_frequency', 'as_per_need'),
          _buildRadioField('Other', 'clothes_frequency', 'other'),
          if (getString('clothes_frequency') == 'other')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _clothesOtherController,
                decoration: InputDecoration(
                  labelText: 'Please specify',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  widget.pageData['clothes_other_specify'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),

          const SizedBox(height: 24),

          // Question 2: Food Waste
          const Text(
            '2. Is there Food Waste in the Home?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'food_waste_exists', 'yes'),
          _buildRadioField('No', 'food_waste_exists', 'no'),
          if (getString('food_waste_exists') == 'yes')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _foodWasteAmountController,
                decoration: InputDecoration(
                  labelText: 'If Yes, How much?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  widget.pageData['food_waste_amount'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),

          const SizedBox(height: 24),

          // Question 3: Waste Disposal
          const Text(
            '3. How do you dispose of waste?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Throw Anywhere', 'waste_disposal', 'throw_anywhere'),
          _buildRadioField('Put into Village Dustbins', 'waste_disposal', 'village_dustbins'),
          _buildRadioField('Collect and sell to Kabadiwala', 'waste_disposal', 'sell_kabadiwala'),
          _buildRadioField('Other', 'waste_disposal', 'other'),
          if (getString('waste_disposal') == 'other')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: _wasteDisposalOtherController,
                decoration: InputDecoration(
                  labelText: 'Please specify',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  widget.pageData['waste_disposal_other'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),

          const SizedBox(height: 24),

          // Question 4: Segregate Waste
          const Text(
            '4. Do you segregate waste?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'separate_waste', 'yes'),
          _buildRadioField('No', 'separate_waste', 'no'),

          const SizedBox(height: 24),

          // Question 5: Compost Pit
          const Text(
            '5. Do you have a Compost Pit?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'compost_pit', 'yes'),
          _buildRadioField('No', 'compost_pit', 'no'),

          const SizedBox(height: 24),

          // Question 6: Recycle Used Items
          const Text(
            '6. Do you recycle used items?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'recycle_used_items', 'yes'),
          _buildRadioField('No', 'recycle_used_items', 'no'),

          const SizedBox(height: 24),

          // Question 7: Toilet
          const Text(
            '7. Do you have a Toilet?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'have_toilet', 'yes'),
          _buildRadioField('No', 'have_toilet', 'no'),
          if (getString('have_toilet') == 'yes') ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('If yes, is it in use?', style: TextStyle(fontWeight: FontWeight.w500)),
                  _buildRadioField('Yes', 'toilet_in_use', 'yes'),
                  _buildRadioField('No', 'toilet_in_use', 'no'),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Question 8: Soak Pit
          const Text(
            '8. If Yes (to Toilet), does it have a Soak Pit?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRadioField('Yes', 'soak_pit', 'yes'),
          _buildRadioField('No', 'soak_pit', 'no'),
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
