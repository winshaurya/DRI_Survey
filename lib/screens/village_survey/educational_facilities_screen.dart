import 'package:flutter/material.dart';
import 'drainage_waste_screen.dart';

class EducationalFacilitiesScreen extends StatefulWidget {
  @override
  _EducationalFacilitiesScreenState createState() => _EducationalFacilitiesScreenState();
}

class _EducationalFacilitiesScreenState extends State<EducationalFacilitiesScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Educational facilities fields
  String _numAnganwadi = '';
  String _numShikshaGuarantee = '';
  String _otherFacilityName = '';
  String _otherFacilityCount = '';

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
              Text('Educational Facilities Data Saved'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Educational facilities data has been saved. Continue to drainage and waste management?'),
                SizedBox(height: 15),
                
                // Educational Facilities Summary
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE6E6FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🎓 Educational Facilities Summary:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 8),
                      if (_numAnganwadi.isNotEmpty)
                        _buildFacilityItem('No. of Anganwadi:', _numAnganwadi),
                      if (_numShikshaGuarantee.isNotEmpty)
                        _buildFacilityItem('No. of Shiksha Guarantee Beneficiaries:', _numShikshaGuarantee),
                      if (_otherFacilityName.isNotEmpty && _otherFacilityCount.isNotEmpty)
                        _buildFacilityItem('$_otherFacilityName:', _otherFacilityCount),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DrainageWasteScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Educational facilities data saved!'),
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Continue to Drainage & Waste'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFacilityItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080)),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _numAnganwadi = '';
      _numShikshaGuarantee = '';
      _otherFacilityName = '';
      _otherFacilityCount = '';
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
                                Icon(Icons.school, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Educational Facilities',
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
                              'Step 7: Other educational facilities and type',
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
                    
                    // Anganwadi Section
                    _buildQuestionWithBackground(
                      question: 'a) No. of Anganwadi',
                      description: 'Number of Anganwadi centers in village',
                      child: _buildNumberField(
                        label: 'Enter number of Anganwadi',
                        icon: Icons.child_care,
                        onChanged: (value) {
                          setState(() {
                            _numAnganwadi = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Numbers only';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // Shiksha Guarantee Section
                    _buildQuestionWithBackground(
                      question: 'b) No. of Shiksha Guarantee Beneficiaries',
                      description: 'Number of beneficiaries under Shiksha Guarantee Scheme',
                      child: _buildNumberField(
                        label: 'Enter number of beneficiaries',
                        icon: Icons.school,
                        onChanged: (value) {
                          setState(() {
                            _numShikshaGuarantee = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Numbers only';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // Other Facilities Section
                    _buildQuestionWithBackground(
                      question: 'Other Educational Facilities',
                      description: 'Other educational facilities in village',
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Facility Name (e.g., Coaching Center, Library, etc.)',
                            icon: Icons.menu_book,
                            onSaved: (value) => _otherFacilityName = value ?? '',
                          ),
                          
                          SizedBox(height: 15),
                          
                          _buildNumberField(
                            label: 'Number of such facilities',
                            icon: Icons.numbers,
                            onChanged: (value) {
                              setState(() {
                                _otherFacilityCount = value ?? '';
                              });
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // Completion Progress
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF800080),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF800080).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.flag, color: Colors.white, size: 32),
                              SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  'Step 7 - Educational Facilities',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            'You are progressing through village data collection for Digital India initiative.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildProgressStep('Step 1', true),
                              _buildProgressStep('Step 2', true),
                              _buildProgressStep('Step 3', true),
                              _buildProgressStep('Step 4', true),
                              _buildProgressStep('Step 5', true),
                              _buildProgressStep('Step 6', true),
                              _buildProgressStep('Step 7', true),
                              _buildProgressStep('Step 8', false),
                              _buildProgressStep('Step 9', false),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Step 8: Drainage & Waste Management',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Summary Card
                    if (_numAnganwadi.isNotEmpty || _numShikshaGuarantee.isNotEmpty || _otherFacilityCount.isNotEmpty)
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
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Progress Indicator
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.school, color: Color(0xFF800080), size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Step 7: Educational facilities data collection',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF800080),
                              ),
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
        border: Border.all(
          color: Color(0xFF800080).withOpacity(0.3),
          width: 1,
        ),
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

  // Progress Step Widget
  Widget _buildProgressStep(String label, bool completed) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: completed ? Colors.white : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: completed
                ? Icon(Icons.check, size: 18, color: Color(0xFF800080))
                : Text(label.split(' ')[1], style: TextStyle(fontSize: 12, color: Color(0xFF800080))),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
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
                  '📋 Educational Facilities Summary:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF800080),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_numAnganwadi.isNotEmpty)
              _buildSummaryItem('Anganwadi Centers:', _numAnganwadi),
            if (_numShikshaGuarantee.isNotEmpty)
              _buildSummaryItem('Shiksha Guarantee Beneficiaries:', _numShikshaGuarantee),
            if (_otherFacilityName.isNotEmpty && _otherFacilityCount.isNotEmpty)
              _buildSummaryItem('$_otherFacilityName:', _otherFacilityCount),
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

  // Number Field Widget
  Widget _buildNumberField({
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
    required FormFieldValidator<String?> validator,
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
      validator: validator,
      style: TextStyle(color: Colors.grey.shade800),
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
}