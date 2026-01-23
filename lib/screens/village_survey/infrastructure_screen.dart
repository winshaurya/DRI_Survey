import 'package:flutter/material.dart';
import 'infrastructure_availability_screen.dart';

class InfrastructureScreen extends StatefulWidget {
  @override
  _InfrastructureScreenState createState() => _InfrastructureScreenState();
}

class _InfrastructureScreenState extends State<InfrastructureScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Approach Roads fields
  bool _hasApproachRoads = false;
  String _numApproachRoads = '';
  String _approachCondition = '';
  String _approachRemarks = '';
  
  // Internal Lanes fields
  bool _hasInternalLanes = false;
  String _numInternalLanes = '';
  String _internalCondition = '';
  String _internalRemarks = '';
  
  // Condition options
  final List<String> _conditionOptions = ['Good', 'Bad'];

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
              Text('Infrastructure Data Saved'),
            ],
          ),
          content: Text('Infrastructure data has been saved successfully. Continue to infrastructure availability?'),
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
                  MaterialPageRoute(builder: (context) => InfrastructureAvailabilityScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Infrastructure data saved!'),
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Continue to Infrastructure Availability'),
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
            width: 80,
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
      _hasApproachRoads = false;
      _numApproachRoads = '';
      _approachCondition = '';
      _approachRemarks = '';
      _hasInternalLanes = false;
      _numInternalLanes = '';
      _internalCondition = '';
      _internalRemarks = '';
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
                                Icon(Icons.engineering, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Infrastructure Information',
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
                              'Step 5: Availability of Approach Roads and Internal Lanes',
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
                    
                    // Approach Roads Section
                    _buildQuestionWithBackground(
                      question: '🛣️ Approach Roads',
                      description: 'Availability and condition of approach roads to village',
                      child: Column(
                        children: [
                          // Availability Radio
                          _buildRadioField(
                            label: 'Are Approach Roads available?',
                            value: _hasApproachRoads,
                            onChanged: (value) {
                              setState(() {
                                _hasApproachRoads = value!;
                                if (!_hasApproachRoads) {
                                  _numApproachRoads = '';
                                  _approachCondition = '';
                                  _approachRemarks = '';
                                }
                              });
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Conditional fields (only show if approach roads are available)
                          if (_hasApproachRoads) ...[
                            // Number of Approach Roads
                            _buildNumberField(
                              label: 'Number of Approach Roads',
                              icon: Icons.numbers,
                              onChanged: (value) {
                                setState(() {
                                  _numApproachRoads = value ?? '';
                                });
                              },
                              validator: (value) {
                                if (_hasApproachRoads && (value == null || value.isEmpty)) {
                                  return 'Please enter number of approach roads';
                                }
                                if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return 'Numbers only';
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: 15),
                            
                            // Condition Dropdown
                            _buildDropdownField(
                              label: 'Condition of Approach Roads',
                              icon: Icons.assessment,
                              value: _approachCondition,
                              items: _conditionOptions,
                              validator: (value) {
                                if (_hasApproachRoads && (value == null || value.isEmpty)) {
                                  return 'Please select condition';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _approachCondition = value ?? '';
                                });
                              },
                            ),
                            
                            SizedBox(height: 15),
                            
                            // Remarks
                            _buildTextField(
                              label: 'Remarks (if any)',
                              icon: Icons.note,
                              onSaved: (value) => _approachRemarks = value ?? '',
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // Internal Lanes Section
                    _buildQuestionWithBackground(
                      question: '🚧 Internal Lanes',
                      description: 'Availability and condition of internal lanes in village',
                      child: Column(
                        children: [
                          // Availability Radio
                          _buildRadioField(
                            label: 'Are Internal Lanes available?',
                            value: _hasInternalLanes,
                            onChanged: (value) {
                              setState(() {
                                _hasInternalLanes = value!;
                                if (!_hasInternalLanes) {
                                  _numInternalLanes = '';
                                  _internalCondition = '';
                                  _internalRemarks = '';
                                }
                              });
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Conditional fields (only show if internal lanes are available)
                          if (_hasInternalLanes) ...[
                            // Number of Internal Lanes
                            _buildNumberField(
                              label: 'Number of Internal Lanes',
                              icon: Icons.numbers,
                              onChanged: (value) {
                                setState(() {
                                  _numInternalLanes = value ?? '';
                                });
                              },
                              validator: (value) {
                                if (_hasInternalLanes && (value == null || value.isEmpty)) {
                                  return 'Please enter number of internal lanes';
                                }
                                if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return 'Numbers only';
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: 15),
                            
                            // Condition Dropdown
                            _buildDropdownField(
                              label: 'Condition of Internal Lanes',
                              icon: Icons.assessment,
                              value: _internalCondition,
                              items: _conditionOptions,
                              validator: (value) {
                                if (_hasInternalLanes && (value == null || value.isEmpty)) {
                                  return 'Please select condition';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _internalCondition = value ?? '';
                                });
                              },
                            ),
                            
                            SizedBox(height: 15),
                            
                            // Remarks
                            _buildTextField(
                              label: 'Remarks (if any)',
                              icon: Icons.note,
                              onSaved: (value) => _internalRemarks = value ?? '',
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Summary Card
                    if (_hasApproachRoads || _hasInternalLanes)
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
                          Icon(Icons.flag, color: Color(0xFF800080), size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Step 5 of 7: Infrastructure Data Collection',
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
                  '📋 Infrastructure Summary:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF800080),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_hasApproachRoads)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Approach Roads:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (_numApproachRoads.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 4),
                      child: Text('• Number: $_numApproachRoads'),
                    ),
                  if (_approachCondition.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 2),
                      child: Text('• Condition: $_approachCondition'),
                    ),
                  if (_approachRemarks.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 2),
                      child: Text('• Remarks: $_approachRemarks'),
                    ),
                ],
              ),
            if (_hasApproachRoads && _hasInternalLanes)
              SizedBox(height: 10),
            if (_hasInternalLanes)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Internal Lanes:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (_numInternalLanes.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 4),
                      child: Text('• Number: $_numInternalLanes'),
                    ),
                  if (_internalCondition.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 2),
                      child: Text('• Condition: $_internalCondition'),
                    ),
                  if (_internalRemarks.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 2),
                      child: Text('• Remarks: $_internalRemarks'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Radio Field Widget
  Widget _buildRadioField({
    required String label,
    required bool? value,
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
                title: Text('Yes', style: TextStyle(color: Colors.grey.shade800)),
                value: true,
                groupValue: value,
                onChanged: onChanged,
                activeColor: Color(0xFF800080),
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text('No', style: TextStyle(color: Colors.grey.shade800)),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: Icon(icon, color: Color(0xFF800080)),
            ),
            hint: Text(
              'Select condition',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
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
}