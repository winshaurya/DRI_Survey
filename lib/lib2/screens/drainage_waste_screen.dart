import 'package:flutter/material.dart';
import '../form_template.dart';
import 'crop_productivity_screen.dart';
import 'educational_facilities_screen.dart';

class DrainageWasteScreen extends StatefulWidget {
  const DrainageWasteScreen({super.key});

  @override
  _DrainageWasteScreenState createState() => _DrainageWasteScreenState();
}

class _DrainageWasteScreenState extends State<DrainageWasteScreen> {
  // Drainage Controllers
  final TextEditingController drainageRemarksController = TextEditingController();
  final TextEditingController wasteRemarksController = TextEditingController();
  
  // Cooking Medium Controllers
  final GlobalKey<FormState> _cookingFormKey = GlobalKey<FormState>();
  String _chulaWood = '';
  String _chulaGobar = '';
  String _inductionStove = '';
  String _gasStove = '';
  String _gobarGasStove = '';
  String _electricStove = '';
  
  // Dropdown value
  String? _selectedDrainageType;
  final List<String> _drainageOptions = [
    'Earthen Drain',
    'Masonry Drain',
    'No Drainage System',
  ];
  
  // Boolean states
  bool _hasWasteCollection = false;
  bool _hasWasteSegregated = false;
  bool _hasSoakPitsToilets = false;
  bool _hasSoakPitsDrains = false;

  void _submitForm() {
    // Direct navigation without popup
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CropProductivityScreen()),
    );
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EducationalFacilitiesScreen()),
    );
  }

  Widget _buildDrainageContent() {
    return Column(
      children: [
        // Drainage System Section
        QuestionCard(
          question: 'Drainage System',
          description: 'Type of drainage system in the village',
          child: Column(
            children: [
              DropdownInput(
                label: 'Drainage System Type',
                value: _selectedDrainageType,
                items: _drainageOptions,
                prefixIcon: Icons.water_damage,
                onChanged: (value) {
                  setState(() {
                    _selectedDrainageType = value;
                  });
                },
              ),
              SizedBox(height: 15),
              TextInput(
                label: 'Remarks about drainage system',
                controller: drainageRemarksController,
                prefixIcon: Icons.note,
                isRequired: false,
              ),
            ],
          ),
        ),
        
        SizedBox(height: 25),
        
        // Waste Disposal Section
        QuestionCard(
          question: 'Waste Disposal',
          description: 'Waste management practices in the village',
          child: Column(
            children: [
              RadioOptionGroup(
                label: 'Waste Collection',
                options: ['Yes', 'No'],
                selectedValue: _hasWasteCollection ? 'Yes' : 'No',
                onChanged: (value) {
                  setState(() {
                    _hasWasteCollection = value == 'Yes';
                  });
                },
              ),
              
              SizedBox(height: 15),
              
              RadioOptionGroup(
                label: 'Waste Segregated',
                options: ['Yes', 'No'],
                selectedValue: _hasWasteSegregated ? 'Yes' : 'No',
                onChanged: (value) {
                  setState(() {
                    _hasWasteSegregated = value == 'Yes';
                  });
                },
              ),
              
              SizedBox(height: 15),
              
              RadioOptionGroup(
                label: 'Soak Pits for Toilets',
                options: ['Yes', 'No'],
                selectedValue: _hasSoakPitsToilets ? 'Yes' : 'No',
                onChanged: (value) {
                  setState(() {
                    _hasSoakPitsToilets = value == 'Yes';
                  });
                },
              ),
              
              SizedBox(height: 15),
              
              RadioOptionGroup(
                label: 'Soak Pits for Drains',
                options: ['Yes', 'No'],
                selectedValue: _hasSoakPitsDrains ? 'Yes' : 'No',
                onChanged: (value) {
                  setState(() {
                    _hasSoakPitsDrains = value == 'Yes';
                  });
                },
              ),
              
              SizedBox(height: 15),
              
              TextInput(
                label: 'Remarks about waste management',
                controller: wasteRemarksController,
                prefixIcon: Icons.note,
                isRequired: false,
              ),
            ],
          ),
        ),
        
        SizedBox(height: 25),
        
        // Cooking Medium Section
        QuestionCard(
          question: 'Cooking Medium',
          description: 'Type of Cooking Medium used by families',
          child: Column(
            children: [
              // Chula - wood/bio mass burning
              _buildCookingNumberField(
                label: 'Chula - wood/bio mass burning',
                icon: Icons.fireplace,
                onChanged: (value) {
                  setState(() {
                    _chulaWood = value ?? '';
                  });
                },
              ),
              
              SizedBox(height: 15),
              
              // Chula - Gobar burning
              _buildCookingNumberField(
                label: 'Chula - Gobar burning',
                icon: Icons.grass,
                onChanged: (value) {
                  setState(() {
                    _chulaGobar = value ?? '';
                  });
                },
              ),
              
              SizedBox(height: 15),
              
              // Induction Stove
              _buildCookingNumberField(
                label: 'Induction Stove',
                icon: Icons.electrical_services,
                onChanged: (value) {
                  setState(() {
                    _inductionStove = value ?? '';
                  });
                },
              ),
              
              SizedBox(height: 15),
              
              // Gas Stove
              _buildCookingNumberField(
                label: 'Gas Stove',
                icon: Icons.local_gas_station,
                onChanged: (value) {
                  setState(() {
                    _gasStove = value ?? '';
                  });
                },
              ),
              
              SizedBox(height: 15),
              
              // Gobar Gas Stove
              _buildCookingNumberField(
                label: 'Gobar Gas Stove',
                icon: Icons.eco,
                onChanged: (value) {
                  setState(() {
                    _gobarGasStove = value ?? '';
                  });
                },
              ),
              
              SizedBox(height: 15),
              
              // Electric Stove
              _buildCookingNumberField(
                label: 'Electric Stove',
                icon: Icons.bolt,
                onChanged: (value) {
                  setState(() {
                    _electricStove = value ?? '';
                  });
                },
              ),
            ],
          ),
        ),
        
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCookingNumberField({
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF800080), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: Icon(icon, color: Color(0xFF800080)),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      validator: (value) {
        if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
          return 'Numbers only';
        }
        return null;
      },
      style: TextStyle(color: Colors.grey.shade800),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'Drainage & Cooking Medium',
      stepNumber: 'Step 8',
      nextScreenRoute: '/crop-productivity',
      nextScreenName: 'Crop Productivity',
      icon: Icons.water_damage,
      instructions: 'Drainage system, waste disposal and cooking medium information',
      contentWidget: _buildDrainageContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen, 
      onReset: () {
        setState(() {
          _selectedDrainageType = null;
          _hasWasteCollection = false;
          _hasWasteSegregated = false;
          _hasSoakPitsToilets = false;
          _hasSoakPitsDrains = false;
          _chulaWood = '';
          _chulaGobar = '';
          _inductionStove = '';
          _gasStove = '';
          _gobarGasStove = '';
          _electricStove = '';
          drainageRemarksController.clear();
          wasteRemarksController.clear();
        });
      },
    );
  }

  @override
  void dispose() {
    drainageRemarksController.dispose();
    wasteRemarksController.dispose();
    super.dispose();
  }
}