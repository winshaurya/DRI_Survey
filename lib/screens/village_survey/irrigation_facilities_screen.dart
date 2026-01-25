import 'package:flutter/material.dart';
import '../../form_template.dart';
import 'animals_fisheries_screen.dart';
import 'kitchen_gardens_screen.dart';

class IrrigationFacilitiesScreen extends StatefulWidget {
  const IrrigationFacilitiesScreen({super.key});

  @override
  _IrrigationFacilitiesScreenState createState() => _IrrigationFacilitiesScreenState();
}

class _IrrigationFacilitiesScreenState extends State<IrrigationFacilitiesScreen> {
  // Yes/No states for each facility
  bool? _hasCanal;
  bool? _hasTubeWell;
  bool? _hasPonds;
  bool? _hasRiver;
  bool? _hasWell;

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnimalsFisheriesScreen()),
    );
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => KitchenGardensScreen()),
    );
  }

  Widget _buildYesNoOption(String label, bool? value, Function(bool?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded( // FIX: Wrap the button in Expanded at Row level
                child: _buildOptionButton('Yes', value == true, () => onChanged(true)),
              ),
              SizedBox(width: 12),
              Expanded( // FIX: Wrap the button in Expanded at Row level
                child: _buildOptionButton('No', value == false, () => onChanged(false)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
            ? (text == 'Yes' ? Colors.green.shade100 : Colors.red.shade100)
            : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
              ? (text == 'Yes' ? Colors.green : Colors.red)
              : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected 
                ? (text == 'Yes' ? Colors.green.shade800 : Colors.red.shade800)
                : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIrrigationContent() {
    return Column(
      children: [
        // Facilities List
        QuestionCard(
          question: 'Available irrigation facilities',
          description: 'Select Yes or No for each facility',
          child: Column(
            children: [
              SizedBox(height: 10),
              
              // Canal
              _buildYesNoOption(
                'Canal',
                _hasCanal,
                (value) => setState(() => _hasCanal = value),
              ),
              
              SizedBox(height: 15),
              
              // Tube Well/Bore Well
              _buildYesNoOption(
                'Tube Well/Bore Well',
                _hasTubeWell,
                (value) => setState(() => _hasTubeWell = value),
              ),
              
              SizedBox(height: 15),
              
              // Ponds
              _buildYesNoOption(
                'Ponds',
                _hasPonds,
                (value) => setState(() => _hasPonds = value),
              ),
              
              SizedBox(height: 15),
              
              // River
              _buildYesNoOption(
                'River',
                _hasRiver,
                (value) => setState(() => _hasRiver = value),
              ),
              
              SizedBox(height: 15),
              
              // Well
              _buildYesNoOption(
                'Well',
                _hasWell,
                (value) => setState(() => _hasWell = value),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 20),
        
        // Summary (optional)
        if (_hasCanal != null || _hasTubeWell != null || _hasPonds != null || 
            _hasRiver != null || _hasWell != null)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFE6E6FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop, color: Color(0xFF800080), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Selected Facilities',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF800080),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_hasCanal == true) _buildSelectedChip('Canal', Colors.green),
                    if (_hasTubeWell == true) _buildSelectedChip('Tube Well', Colors.blue),
                    if (_hasPonds == true) _buildSelectedChip('Ponds', Colors.orange),
                    if (_hasRiver == true) _buildSelectedChip('River', Colors.purple),
                    if (_hasWell == true) _buildSelectedChip('Well', Colors.brown),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'Irrigation Facilities',
      stepNumber: 'Step 15',
      nextScreenRoute: '/animals-fisheries',
      nextScreenName: 'Animals/Fisheries',
      icon: Icons.water,
      instructions: 'Select Yes or No for each irrigation facility',
      contentWidget: _buildIrrigationContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen,
      onReset: () {
        setState(() {
          _hasCanal = null;
          _hasTubeWell = null;
          _hasPonds = null;
          _hasRiver = null;
          _hasWell = null;
        });
      },
    );
  }
}
