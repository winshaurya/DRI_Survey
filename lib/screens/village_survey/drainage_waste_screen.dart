import 'package:flutter/material.dart';
import 'crop_productivity_screen.dart'; // CHANGE THIS IMPORT

class DrainageWasteScreen extends StatefulWidget {
  @override
  _DrainageWasteScreenState createState() => _DrainageWasteScreenState();
}

class _DrainageWasteScreenState extends State<DrainageWasteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Drainage system fields
  String _selectedDrainageType = '';
  final List<String> _drainageOptions = [
    'Earthen Drain',
    'Masonry Drain',
    'No Drainage System',
  ];

  // Waste disposal fields
  bool _hasWasteCollection = false;
  bool _hasWasteSegregated = false;
  bool _hasSoakPitsToilets = false;
  bool _hasSoakPitsDrains = false;

  // Additional remarks
  String _drainageRemarks = '';
  String _wasteRemarks = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF800080)),
              SizedBox(width: 10),
              Text('Drainage & Waste Data Saved'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drainage and waste management data has been saved. Continue to Crop Productivity?',
                ),
                SizedBox(height: 15),

                // Drainage System Summary
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE6E6FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(0xFF800080).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🚰 Drainage System:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF800080),
                        ),
                      ),
                      SizedBox(height: 8),
                      if (_selectedDrainageType.isNotEmpty)
                        _buildInfraItem('Type:', _selectedDrainageType),
                      if (_drainageRemarks.isNotEmpty)
                        _buildInfraItem('Remarks:', _drainageRemarks),
                    ],
                  ),
                ),

                SizedBox(height: 15),

                // Waste Management Summary
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(0xFF800080).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🗑️ Waste Management:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF800080),
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInfraItem(
                        'Waste Collection:',
                        _hasWasteCollection ? 'Yes' : 'No',
                      ),
                      _buildInfraItem(
                        'Waste Segregated:',
                        _hasWasteSegregated ? 'Yes' : 'No',
                      ),
                      _buildInfraItem(
                        'Soak Pits for Toilets:',
                        _hasSoakPitsToilets ? 'Yes' : 'No',
                      ),
                      _buildInfraItem(
                        'Soak Pits for Drains:',
                        _hasSoakPitsDrains ? 'Yes' : 'No',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Edit', style: TextStyle(color: Color(0xFF800080))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to Crop Productivity instead of Cooking Medium
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CropProductivityScreen(),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Drainage & waste data saved! Moving to Crop Productivity',
                    ),
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF800080),
              ),
              child: Text(
                'Continue to Crop Productivity',
              ), // CHANGE BUTTON TEXT
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfraItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF800080),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedDrainageType = '';
      _hasWasteCollection = false;
      _hasWasteSegregated = false;
      _hasSoakPitsToilets = false;
      _hasSoakPitsDrains = false;
      _drainageRemarks = '';
      _wasteRemarks = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Government of India Header
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Government of India Text
                    Text(
                      'Government of India',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Digital India Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Digital India',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF9933),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Power To Empower',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF138808),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Main Form Container
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/indian_background.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.1),
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Header Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.water_damage,
                                  color: Color(0xFF800080),
                                  size: 32,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Drainage & Waste Management',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF800080),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Step 8: Drainage system and waste disposal',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              height: 4,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Color(0xFF800080),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    // Drainage System Section
                    _buildQuestionWithBackground(
                      question: '8a) Type of drainage system',
                      description:
                          'Select the type of drainage system in village',
                      child: Column(
                        children: [
                          // Drainage Type Dropdown
                          _buildDropdownField(
                            label: 'Drainage System Type',
                            icon: Icons.waves,
                            value: _selectedDrainageType,
                            items: _drainageOptions,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select drainage type';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedDrainageType = value ?? '';
                              });
                            },
                          ),

                          SizedBox(height: 15),

                          // Drainage Remarks
                          _buildTextField(
                            label: 'Remarks about drainage system',
                            icon: Icons.note,
                            onSaved: (value) => _drainageRemarks = value ?? '',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 25),

                    // Waste Disposal Section
                    _buildQuestionWithBackground(
                      question: '8b) Waste Disposal',
                      description: 'Waste management practices in village',
                      child: Column(
                        children: [
                          // Waste Collection
                          _buildWasteRadioField(
                            label: 'Waste Collection',
                            value: _hasWasteCollection,
                            onChanged: (value) {
                              setState(() {
                                _hasWasteCollection = value!;
                              });
                            },
                          ),

                          SizedBox(height: 15),

                          // Waste Segregated
                          _buildWasteRadioField(
                            label: 'Waste Segregated',
                            value: _hasWasteSegregated,
                            onChanged: (value) {
                              setState(() {
                                _hasWasteSegregated = value!;
                              });
                            },
                          ),

                          SizedBox(height: 15),

                          // Soak Pits for Toilets
                          _buildWasteRadioField(
                            label: 'Soak Pits for Toilets',
                            value: _hasSoakPitsToilets,
                            onChanged: (value) {
                              setState(() {
                                _hasSoakPitsToilets = value!;
                              });
                            },
                          ),

                          SizedBox(height: 15),

                          // Soak Pits for Drains
                          _buildWasteRadioField(
                            label: 'Soak Pits for Drains',
                            value: _hasSoakPitsDrains,
                            onChanged: (value) {
                              setState(() {
                                _hasSoakPitsDrains = value!;
                              });
                            },
                          ),

                          SizedBox(height: 15),

                          // Waste Remarks
                          _buildTextField(
                            label: 'Remarks about waste management',
                            icon: Icons.note,
                            onSaved: (value) => _wasteRemarks = value ?? '',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Summary Card
                    if (_selectedDrainageType.isNotEmpty ||
                        _hasWasteCollection ||
                        _hasWasteSegregated)
                      _buildSummaryCard(),

                    SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _resetForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade700,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.refresh),
                            label: Text('Reset Form'),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF800080),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.arrow_forward, size: 24),
                            label: Text(
                              'Save & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Progress Indicator with next step info
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color(0xFF800080).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.water_damage,
                                color: Color(0xFF800080),
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Step 8: Sanitation and waste management data collection',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF800080),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.navigate_next,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Next: Crop Productivity',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for question with background image
  Widget _buildQuestionWithBackground({
    required String question,
    required Widget child,
    String? description,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Color.fromARGB(30, 128, 0, 128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF800080).withOpacity(0.3), width: 1),
        image: DecorationImage(
          image: AssetImage('assets/images/form_background.png'),
          fit: BoxFit.cover,
          opacity: 0.05,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Text with Purple Padding
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF800080),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (description != null)
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 15),
          // Input Field
          child,
        ],
      ),
    );
  }

  // Waste Radio Field
  Widget _buildWasteRadioField({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: Text(
                  'Yes',
                  style: TextStyle(color: Colors.grey.shade800),
                ),
                value: true,
                groupValue: value,
                onChanged: onChanged,
                activeColor: Color(0xFF800080),
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text(
                  'No',
                  style: TextStyle(color: Colors.grey.shade800),
                ),
                value: false,
                groupValue: value,
                onChanged: onChanged,
                activeColor: Color(0xFF800080),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Dropdown Field Widget
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required FormFieldValidator<String?> validator,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: Icon(icon, color: Color(0xFF800080)),
            ),
            hint: Text(
              'Select drainage type',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            validator: validator,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFF800080)),
            style: TextStyle(color: Colors.grey.shade800),
            dropdownColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // Text Field Widget
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String?> onSaved,
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
      onSaved: onSaved,
      style: TextStyle(color: Colors.grey.shade800),
    );
  }

  // Summary Card
  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.amber.shade200, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Color(0xFF800080)),
                SizedBox(width: 8),
                Text(
                  '📋 Drainage & Waste Summary:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF800080),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_selectedDrainageType.isNotEmpty)
              _buildSummaryItem('Drainage System:', _selectedDrainageType),
            if (_hasWasteCollection)
              _buildSummaryItem(
                'Waste Collection:',
                _hasWasteCollection ? 'Yes' : 'No',
              ),
            if (_hasWasteSegregated)
              _buildSummaryItem(
                'Waste Segregated:',
                _hasWasteSegregated ? 'Yes' : 'No',
              ),
            if (_hasSoakPitsToilets)
              _buildSummaryItem(
                'Soak Pits for Toilets:',
                _hasSoakPitsToilets ? 'Yes' : 'No',
              ),
            if (_hasSoakPitsDrains)
              _buildSummaryItem(
                'Soak Pits for Drains:',
                _hasSoakPitsDrains ? 'Yes' : 'No',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF800080),
            ),
          ),
        ],
      ),
    );
  }
}
