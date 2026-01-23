import 'package:flutter/material.dart';
import 'educational_facilities_screen.dart';

class InfrastructureAvailabilityScreen extends StatefulWidget {
  @override
  _InfrastructureAvailabilityScreenState createState() => _InfrastructureAvailabilityScreenState();
}

class _InfrastructureAvailabilityScreenState extends State<InfrastructureAvailabilityScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // School availability fields
  bool _hasPrimarySchool = false;
  String _primarySchoolDistance = '';
  
  bool _hasJuniorSchool = false;
  String _juniorSchoolDistance = '';
  
  bool _hasHighSchool = false;
  String _highSchoolDistance = '';
  
  bool _hasIntermediateSchool = false;
  String _intermediateSchoolDistance = '';
  
  String _otherEducationalFacility = '';
  
  // Number of students
  String _boysStudents = '';
  String _girlsStudents = '';
  String _totalStudents = '';
  
  // Infrastructure fields
  bool _hasPlayground = false;
  String _playgroundRemarks = '';
  
  bool _hasPanchayatBhavan = false;
  String _panchayatRemarks = '';
  
  bool _hasShardaKendra = false;
  String _shardaKendraDistance = '';
  
  bool _hasPostOffice = false;
  String _postOfficeDistance = '';
  
  bool _hasHealthFacility = false;
  String _healthFacilityDistance = '';
  
  bool _hasPrimaryHealthCentre = false;
  
  bool _hasBank = false;
  String _bankDistance = '';
  
  bool _hasElectricalConnection = false;
  
  bool _hasDrinkingWaterSource = false;
  
  // Water source details
  String _numWells = '';
  String _numPonds = '';
  String _numHandPumps = '';
  String _numTubeWells = '';
  String _numTapWater = '';
  
  // Auto-calculate total students
  void _calculateTotalStudents() {
    int boys = int.tryParse(_boysStudents) ?? 0;
    int girls = int.tryParse(_girlsStudents) ?? 0;
    
    int total = boys + girls;
    
    setState(() {
      _totalStudents = total.toString();
    });
  }

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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Infrastructure availability data has been saved. Continue to educational facilities?'),
                SizedBox(height: 15),
                
                // School Summary
                if (_hasPrimarySchool || _hasJuniorSchool || _hasHighSchool || _hasIntermediateSchool)
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
                        Text('🏫 School Availability:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                        SizedBox(height: 8),
                        if (_hasPrimarySchool) _buildInfraItem('Primary School:', _primarySchoolDistance.isEmpty ? 'Available' : '${_primarySchoolDistance} km'),
                        if (_hasJuniorSchool) _buildInfraItem('Junior School:', _juniorSchoolDistance.isEmpty ? 'Available' : '${_juniorSchoolDistance} km'),
                        if (_hasHighSchool) _buildInfraItem('High School:', _highSchoolDistance.isEmpty ? 'Available' : '${_highSchoolDistance} km'),
                        if (_hasIntermediateSchool) _buildInfraItem('Intermediate School:', _intermediateSchoolDistance.isEmpty ? 'Available' : '${_intermediateSchoolDistance} km'),
                      ],
                    ),
                  ),
                
                if (_hasPrimarySchool || _hasJuniorSchool || _hasHighSchool || _hasIntermediateSchool)
                  SizedBox(height: 15),
                
                // Students Summary
                if (_boysStudents.isNotEmpty || _girlsStudents.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('👨‍🎓 Number of Students:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                        SizedBox(height: 8),
                        if (_boysStudents.isNotEmpty) _buildInfraItem('Boys:', _boysStudents),
                        if (_girlsStudents.isNotEmpty) _buildInfraItem('Girls:', _girlsStudents),
                        if (_totalStudents.isNotEmpty) _buildInfraItem('Total:', _totalStudents),
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
                  MaterialPageRoute(builder: (context) => EducationalFacilitiesScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Infrastructure availability data saved!'),
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Continue to Educational Facilities'),
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
            width: 120,
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
      _hasPrimarySchool = false;
      _primarySchoolDistance = '';
      _hasJuniorSchool = false;
      _juniorSchoolDistance = '';
      _hasHighSchool = false;
      _highSchoolDistance = '';
      _hasIntermediateSchool = false;
      _intermediateSchoolDistance = '';
      _otherEducationalFacility = '';
      _boysStudents = '';
      _girlsStudents = '';
      _totalStudents = '';
      _hasPlayground = false;
      _playgroundRemarks = '';
      _hasPanchayatBhavan = false;
      _panchayatRemarks = '';
      _hasShardaKendra = false;
      _shardaKendraDistance = '';
      _hasPostOffice = false;
      _postOfficeDistance = '';
      _hasHealthFacility = false;
      _healthFacilityDistance = '';
      _hasPrimaryHealthCentre = false;
      _hasBank = false;
      _bankDistance = '';
      _hasElectricalConnection = false;
      _hasDrinkingWaterSource = false;
      _numWells = '';
      _numPonds = '';
      _numHandPumps = '';
      _numTubeWells = '';
      _numTapWater = '';
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
                                  'Infrastructure Availability',
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
                              'Step 6: Availability of Infrastructure in Village',
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
                    
                    // School Availability Section
                    _buildQuestionWithBackground(
                      question: '🏫 School Availability',
                      description: 'Availability of different types of schools',
                      child: Column(
                        children: [
                          // Primary School
                          _buildSchoolRadioField(
                            label: '(i) Primary School (Upto 5th Standard)',
                            hasSchool: _hasPrimarySchool,
                            distance: _primarySchoolDistance,
                            onChanged: (value) {
                              setState(() {
                                _hasPrimarySchool = value!;
                                if (!_hasPrimarySchool) _primarySchoolDistance = '';
                              });
                            },
                            onDistanceChanged: (value) {
                              setState(() {
                                _primarySchoolDistance = value ?? '';
                              });
                            },
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Junior School
                          _buildSchoolRadioField(
                            label: '(ii) Junior School (6th to 8th Standard)',
                            hasSchool: _hasJuniorSchool,
                            distance: _juniorSchoolDistance,
                            onChanged: (value) {
                              setState(() {
                                _hasJuniorSchool = value!;
                                if (!_hasJuniorSchool) _juniorSchoolDistance = '';
                              });
                            },
                            onDistanceChanged: (value) {
                              setState(() {
                                _juniorSchoolDistance = value ?? '';
                              });
                            },
                          ),
                          
                          SizedBox(height: 20),
                          
                          // High School
                          _buildSchoolRadioField(
                            label: '(iii) High School (9th to 10th Standard)',
                            hasSchool: _hasHighSchool,
                            distance: _highSchoolDistance,
                            onChanged: (value) {
                              setState(() {
                                _hasHighSchool = value!;
                                if (!_hasHighSchool) _highSchoolDistance = '';
                              });
                            },
                            onDistanceChanged: (value) {
                              setState(() {
                                _highSchoolDistance = value ?? '';
                              });
                            },
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Intermediate School
                          _buildSchoolRadioField(
                            label: '(iv) Intermediate School (10+2)',
                            hasSchool: _hasIntermediateSchool,
                            distance: _intermediateSchoolDistance,
                            onChanged: (value) {
                              setState(() {
                                _hasIntermediateSchool = value!;
                                if (!_hasIntermediateSchool) _intermediateSchoolDistance = '';
                              });
                            },
                            onDistanceChanged: (value) {
                              setState(() {
                                _intermediateSchoolDistance = value ?? '';
                              });
                            },
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Other Educational Facilities
                          _buildTextField(
                            label: '(v) Other (like Anganwadi, Shiksha Guarantee Scheme, etc.)',
                            icon: Icons.menu_book,
                            onSaved: (value) => _otherEducationalFacility = value ?? '',
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // Number of Students Section
                    _buildQuestionWithBackground(
                      question: '👨‍🎓 Number of Students',
                      description: 'Total number of students in village',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildNumberField(
                                  label: '(i) Boys',
                                  icon: Icons.boy,
                                  onChanged: (value) {
                                    setState(() {
                                      _boysStudents = value ?? '';
                                      _calculateTotalStudents();
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
                              SizedBox(width: 15),
                              Expanded(
                                child: _buildNumberField(
                                  label: '(ii) Girls',
                                  icon: Icons.girl,
                                  onChanged: (value) {
                                    setState(() {
                                      _girlsStudents = value ?? '';
                                      _calculateTotalStudents();
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
                            ],
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Total Students Card
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Color(0xFFE6E6FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.school, color: Color(0xFF800080), size: 28),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    'Total Students',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF800080),
                                    ),
                                  ),
                                ),
                                Text(
                                  _totalStudents.isEmpty ? '0' : _totalStudents,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF800080),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // Infrastructure Facilities Section
                    _buildQuestionWithBackground(
                      question: '🏛️ Other Infrastructure Facilities',
                      description: 'Availability of various infrastructure facilities',
                      child: Column(
                        children: [
                          // Playground
                          _buildFacilityRadioField(
                            label: 'c) Playground',
                            hasFacility: _hasPlayground,
                            remarks: _playgroundRemarks,
                            onChanged: (value) {
                              setState(() {
                                _hasPlayground = value!;
                                if (!_hasPlayground) _playgroundRemarks = '';
                              });
                            },
                            onRemarksChanged: (value) {
                              setState(() {
                                _playgroundRemarks = value ?? '';
                              });
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Panchayat Bhavan
                          _buildFacilityRadioField(
                            label: 'd) Panchayat Bhavan',
                            hasFacility: _hasPanchayatBhavan,
                            remarks: _panchayatRemarks,
                            onChanged: (value) {
                              setState(() {
                                _hasPanchayatBhavan = value!;
                                if (!_hasPanchayatBhavan) _panchayatRemarks = '';
                              });
                            },
                            onRemarksChanged: (value) {
                              setState(() {
                                _panchayatRemarks = value ?? '';
                              });
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Sharda Kendra
                          _buildFacilityRadioDistanceField(
                            label: 'e) Sharda Kendra (Place of Worship)',
                            hasFacility: _hasShardaKendra,
                            distance: _shardaKendraDistance,
                            onChanged: (value) {
                              setState(() {
                                _hasShardaKendra = value!;
                                if (!_hasShardaKendra) _shardaKendraDistance = '';
                              });
                            },
                            onDistanceChanged: (value) {
                              setState(() {
                                _shardaKendraDistance = value ?? '';
                              });
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Post Office
                          _buildFacilityRadioDistanceField(
                            label: 'f) Post Office',
                            hasFacility: _hasPostOffice,
                            distance: _postOfficeDistance,
                            onChanged: (value) {
                              setState(() {
                                _hasPostOffice = value!;
                                if (!_hasPostOffice) _postOfficeDistance = '';
                              });
                            },
                            onDistanceChanged: (value) {
                              setState(() {
                                _postOfficeDistance = value ?? '';
                              });
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Health Facility
                          _buildFacilityRadioDistanceField(
                            label: 'g) Health Facility (General Practitioners)',
                            hasFacility: _hasHealthFacility,
                            distance: _healthFacilityDistance,
                            onChanged: (value) {
                              setState(() {
                                _hasHealthFacility = value!;
                                if (!_hasHealthFacility) _healthFacilityDistance = '';
                              });
                            },
                            onDistanceChanged: (value) {
                              setState(() {
                                _healthFacilityDistance = value ?? '';
                              });
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Primary Health Centre
                          _buildSimpleRadioField(
                            label: 'h) Primary Health Centre',
                            hasFacility: _hasPrimaryHealthCentre,
                            onChanged: (value) {
                              setState(() {
                                _hasPrimaryHealthCentre = value!;
                              });
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Bank
                          _buildFacilityRadioDistanceField(
                            label: 'i) Bank',
                            hasFacility: _hasBank,
                            distance: _bankDistance,
                            onChanged: (value) {
                              setState(() {
                                _hasBank = value!;
                                if (!_hasBank) _bankDistance = '';
                              });
                            },
                            onDistanceChanged: (value) {
                              setState(() {
                                _bankDistance = value ?? '';
                              });
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Electrical Connection
                          _buildSimpleRadioField(
                            label: 'j) Electrical Connection',
                            hasFacility: _hasElectricalConnection,
                            onChanged: (value) {
                              setState(() {
                                _hasElectricalConnection = value!;
                              });
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Drinking Water Source
                          _buildWaterSourceSection(),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Summary Card
                    if (_hasPrimarySchool || _hasJuniorSchool || _hasHighSchool || _hasIntermediateSchool || 
                        _boysStudents.isNotEmpty || _girlsStudents.isNotEmpty)
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

  // School Radio Field with Distance
  Widget _buildSchoolRadioField({
    required String label,
    required bool hasSchool,
    required String distance,
    required Function(bool?) onChanged,
    required Function(String?) onDistanceChanged,
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
                groupValue: hasSchool,
                onChanged: onChanged,
                activeColor: Color(0xFF800080),
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text('No', style: TextStyle(color: Colors.grey.shade800)),
                value: false,
                groupValue: hasSchool,
                onChanged: onChanged,
                activeColor: Color(0xFF800080),
                dense: true,
              ),
            ),
          ],
        ),
        if (hasSchool)
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Distance From Village (km)',
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
                prefixIcon: Icon(Icons.location_on, color: Color(0xFF800080)),
              ),
              keyboardType: TextInputType.number,
              onChanged: onDistanceChanged,
              validator: (value) {
                if (hasSchool && (value == null || value.isEmpty)) {
                  return 'Please enter distance';
                }
                if (value != null && value.isNotEmpty && !RegExp(r'^[0-9.]+$').hasMatch(value)) {
                  return 'Numbers only';
                }
                return null;
              },
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
      ],
    );
  }

  // Facility Radio Field with Remarks
  Widget _buildFacilityRadioField({
    required String label,
    required bool hasFacility,
    required String remarks,
    required Function(bool?) onChanged,
    required Function(String?) onRemarksChanged,
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
                groupValue: hasFacility,
                onChanged: onChanged,
                activeColor: Color(0xFF800080),
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text('No', style: TextStyle(color: Colors.grey.shade800)),
                value: false,
                groupValue: hasFacility,
                onChanged: onChanged,
                activeColor: Color(0xFF800080),
                dense: true,
              ),
            ),
          ],
        ),
        if (hasFacility)
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Remarks',
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
                prefixIcon: Icon(Icons.note, color: Color(0xFF800080)),
              ),
              onChanged: onRemarksChanged,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
      ],
    );
  }

  // Facility Radio Field with Distance
  Widget _buildFacilityRadioDistanceField({
    required String label,
    required bool hasFacility,
    required String distance,
    required Function(bool?) onChanged,
    required Function(String?) onDistanceChanged,
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
                groupValue: hasFacility,
                onChanged: onChanged,
                activeColor: Color(0xFF800080),
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text('No', style: TextStyle(color: Colors.grey.shade800)),
                value: false,
                groupValue: hasFacility,
                onChanged: onChanged,
                activeColor: Color(0xFF800080),
                dense: true,
              ),
            ),
          ],
        ),
        if (hasFacility)
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Distance (km)',
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
                prefixIcon: Icon(Icons.location_on, color: Color(0xFF800080)),
              ),
              keyboardType: TextInputType.number,
              onChanged: onDistanceChanged,
              validator: (value) {
                if (hasFacility && (value == null || value.isEmpty)) {
                  return 'Please enter distance';
                }
                if (value != null && value.isNotEmpty && !RegExp(r'^[0-9.]+$').hasMatch(value)) {
                  return 'Numbers only';
                }
                return null;
              },
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
      ],
    );
  }

  // Simple Radio Field
  Widget _buildSimpleRadioField({
    required String label,
    required bool hasFacility,
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
                groupValue: hasFacility,
                onChanged: onChanged,
                activeColor: Color(0xFF800080),
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text('No', style: TextStyle(color: Colors.grey.shade800)),
                value: false,
                groupValue: hasFacility,
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

  // Water Source Section
  Widget _buildWaterSourceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimpleRadioField(
          label: 'k) Source of Drinking Water',
          hasFacility: _hasDrinkingWaterSource,
          onChanged: (value) {
            setState(() {
              _hasDrinkingWaterSource = value!;
              if (!_hasDrinkingWaterSource) {
                _numWells = '';
                _numPonds = '';
                _numHandPumps = '';
                _numTubeWells = '';
                _numTapWater = '';
              }
            });
          },
        ),
        
        if (_hasDrinkingWaterSource) ...[
          SizedBox(height: 15),
          Text(
            'Water Source Details:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 10),
          
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  label: '(i) No. of Wells',
                  icon: Icons.water,
                  onChanged: (value) {
                    setState(() {
                      _numWells = value ?? '';
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
              SizedBox(width: 10),
              Expanded(
                child: _buildNumberField(
                  label: '(ii) No. of Ponds',
                  icon: Icons.waves,
                  onChanged: (value) {
                    setState(() {
                      _numPonds = value ?? '';
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
            ],
          ),
          
          SizedBox(height: 15),
          
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  label: '(iii) No. of Hand Pumps',
                  icon: Icons.build,
                  onChanged: (value) {
                    setState(() {
                      _numHandPumps = value ?? '';
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
              SizedBox(width: 10),
              Expanded(
                child: _buildNumberField(
                  label: '(iv) No. of Tube Wells',
                  icon: Icons.opacity,
                  onChanged: (value) {
                    setState(() {
                      _numTubeWells = value ?? '';
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
            ],
          ),
          
          SizedBox(height: 15),
          
          _buildNumberField(
            label: '(v) No. of Tap Water connections (Nal Jaal)',
            icon: Icons.water_damage,
            onChanged: (value) {
              setState(() {
                _numTapWater = value ?? '';
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
            if (_hasPrimarySchool)
              _buildSummaryItem('Primary School:', _primarySchoolDistance.isEmpty ? 'Available' : '${_primarySchoolDistance} km'),
            if (_hasJuniorSchool)
              _buildSummaryItem('Junior School:', _juniorSchoolDistance.isEmpty ? 'Available' : '${_juniorSchoolDistance} km'),
            if (_hasHighSchool)
              _buildSummaryItem('High School:', _highSchoolDistance.isEmpty ? 'Available' : '${_highSchoolDistance} km'),
            if (_hasIntermediateSchool)
              _buildSummaryItem('Intermediate School:', _intermediateSchoolDistance.isEmpty ? 'Available' : '${_intermediateSchoolDistance} km'),
            if (_boysStudents.isNotEmpty)
              _buildSummaryItem('Boys Students:', _boysStudents),
            if (_girlsStudents.isNotEmpty)
              _buildSummaryItem('Girls Students:', _girlsStudents),
            if (_totalStudents.isNotEmpty)
              _buildSummaryItem('Total Students:', _totalStudents),
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