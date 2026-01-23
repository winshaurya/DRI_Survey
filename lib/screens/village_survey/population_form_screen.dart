import 'package:flutter/material.dart';
import '../../components/logo_widget.dart';
import 'farm_families_screen.dart';

class PopulationFormScreen extends StatefulWidget {
  @override
  _PopulationFormScreenState createState() => _PopulationFormScreenState();
}

class _PopulationFormScreenState extends State<PopulationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Population fields
  String _population = '';
  String _totalFamilies = '';
  String _totalMembers = '';
  String _men = '';
  String _women = '';
  String _maleChildren = '';
  String _femaleChildren = '';
  String _selectedCaste = '';
  String _selectedReligion = '';
  String _otherReligion = '';
  
  // Caste options
  final List<String> _casteOptions = [
    'S.C. (Scheduled Caste)',
    'S.T. (Scheduled Tribe)',
    'O.B.C. (Other Backward Class)',
    'General'
  ];
  
  // Religion options
  final List<String> _religionOptions = [
    'Hindu',
    'Muslim',
    'Christian',
    'Other'
  ];
  
  // Auto-calculate functions
  void _calculateTotalMembers() {
    int men = int.tryParse(_men) ?? 0;
    int women = int.tryParse(_women) ?? 0;
    int maleChildren = int.tryParse(_maleChildren) ?? 0;
    int femaleChildren = int.tryParse(_femaleChildren) ?? 0;
    
    int total = men + women + maleChildren + femaleChildren;
    
    setState(() {
      _totalMembers = total.toString();
    });
  }
  
  void _calculatePopulation() {
    int families = int.tryParse(_totalFamilies) ?? 0;
    int avgFamilySize = 4; // Assuming average family size
    
    int population = families * avgFamilySize;
    
    setState(() {
      _population = population.toString();
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
              Text('Population Data Saved'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Population data has been saved. Continue to farm families data?'),
                SizedBox(height: 15),
                
                // Population Summary
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE6E6FA), // Light purple
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📊 Population Summary:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Text('👨‍👩‍👧‍👦 Total Population:', style: TextStyle(fontWeight: FontWeight.w500))),
                          Text(_population, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF800080))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text('🏠 Total Families:', style: TextStyle(fontWeight: FontWeight.w500))),
                          Text(_totalFamilies, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF800080))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text('👥 Total Members:', style: TextStyle(fontWeight: FontWeight.w500))),
                          Text(_totalMembers, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF800080))),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 15),
                
                // Gender Breakdown
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF3E5F5), // Light purple
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('👥 Gender Breakdown:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 8),
                      _buildGenderItem('👨 Men', _men),
                      _buildGenderItem('👩 Women', _women),
                      _buildGenderItem('👦 Male Children', _maleChildren),
                      _buildGenderItem('👧 Female Children', _femaleChildren),
                    ],
                  ),
                ),
                
                SizedBox(height: 15),
                
                // Caste & Religion
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E8), // Light green
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🏛️ Social Data:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade800)),
                      SizedBox(height: 8),
                      _buildSocialItem('Caste:', _selectedCaste),
                      _buildSocialItem('Religion:', 
                        _selectedReligion == 'Other' ? _otherReligion : _selectedReligion),
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
                  MaterialPageRoute(builder: (context) => FarmFamiliesScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Population data saved!'),
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Continue to Farm Families'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildGenderItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
        ],
      ),
    );
  }

  Widget _buildSocialItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _population = '';
      _totalFamilies = '';
      _totalMembers = '';
      _men = '';
      _women = '';
      _maleChildren = '';
      _femaleChildren = '';
      _selectedCaste = '';
      _selectedReligion = '';
      _otherReligion = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          const VillageAppHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
            
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
                                Icon(Icons.people, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Population Details',
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
                              'Step 2: Enter village population statistics',
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
                    
                    // Population (Auto-calculated)
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuestionWithBackground(
                            question: '🏠 Total Families *',
                            description: 'Enter total number of families in village',
                            child: _buildNumberField(
                              label: 'Enter number of families',
                              icon: Icons.family_restroom,
                              onChanged: (value) {
                                setState(() {
                                  _totalFamilies = value ?? '';
                                  _calculatePopulation();
                                });
                              },
                        validator: (value) {
                          return null;
                        },
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        // Estimated Population Card
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Color(0xFFE6E6FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                              image: DecorationImage(
                                image: AssetImage('assets/images/form_background.png'),
                                fit: BoxFit.cover,
                                opacity: 0.05,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_alt, size: 20, color: Color(0xFF800080)),
                                    SizedBox(width: 8),
                                    Text(
                                      '👨‍👩‍👧‍👦 Estimated Population',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF800080),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _population.isEmpty ? '0' : _population,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF800080),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Auto-calculated (Families × 4)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Gender breakdown section
                    _buildQuestionWithBackground(
                      question: '👥 Gender Breakdown *',
                      description: 'Enter number of people in each category',
                      child: Column(
                        children: [
                          // Men
                          _buildNumberField(
                            label: '👨 Men (18+ years)',
                            icon: Icons.man,
                            onChanged: (value) {
                              setState(() {
                                _men = value ?? '';
                                _calculateTotalMembers();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number of men';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Women
                          _buildNumberField(
                            label: '👩 Women (18+ years)',
                            icon: Icons.woman,
                            onChanged: (value) {
                              setState(() {
                                _women = value ?? '';
                                _calculateTotalMembers();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number of women';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Male Children
                          _buildNumberField(
                            label: '👦 Male Children (0-17 years)',
                            icon: Icons.boy,
                            onChanged: (value) {
                              setState(() {
                                _maleChildren = value ?? '';
                                _calculateTotalMembers();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number of male children';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Female Children
                          _buildNumberField(
                            label: '👧 Female Children (0-17 years)',
                            icon: Icons.girl,
                            onChanged: (value) {
                              setState(() {
                                _femaleChildren = value ?? '';
                                _calculateTotalMembers();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number of female children';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Total Members (Auto-calculated)
                    Container(
                      padding: EdgeInsets.all(15),
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
                      child: Row(
                        children: [
                          Icon(Icons.group, size: 32, color: Colors.white),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Members (Auto-calculated)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Men + Women + Male Children + Female Children',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _totalMembers.isEmpty ? '0' : _totalMembers,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // Caste & Religion section
                    _buildQuestionWithBackground(
                      question: '🏛️ Social Information *',
                      description: 'Select caste and religion distribution',
                      child: Column(
                        children: [
                          // Caste
                          _buildDropdownField(
                            label: 'Caste Category',
                            icon: Icons.category,
                            value: _selectedCaste,
                            items: _casteOptions,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select caste';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedCaste = value ?? '';
                              });
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Religion
                          _buildDropdownField(
                            label: 'Religion',
                            icon: Icons.mosque,
                            value: _selectedReligion,
                            items: _religionOptions,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select religion';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedReligion = value ?? '';
                                _otherReligion = '';
                              });
                            },
                          ),
                          
                          // Other religion text field (only if "Other" is selected)
                          if (_selectedReligion == 'Other')
                            Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: _buildTextField(
                                label: 'Specify Other Religion *',
                                icon: Icons.edit,
                                validator: (value) {
                                  if (_selectedReligion == 'Other' && (value == null || value.isEmpty)) {
                                    return 'Please specify religion';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _otherReligion = value ?? '',
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Summary Card
                    if (_totalFamilies.isNotEmpty || _men.isNotEmpty || _selectedCaste.isNotEmpty)
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
                  '📋 Data Summary:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF800080),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_totalFamilies.isNotEmpty)
              _buildSummaryItem('Families:', _totalFamilies),
            if (_men.isNotEmpty)
              _buildSummaryItem('Men:', _men),
            if (_women.isNotEmpty)
              _buildSummaryItem('Women:', _women),
            if (_maleChildren.isNotEmpty)
              _buildSummaryItem('Male Children:', _maleChildren),
            if (_femaleChildren.isNotEmpty)
              _buildSummaryItem('Female Children:', _femaleChildren),
            if (_selectedCaste.isNotEmpty)
              _buildSummaryItem('Caste:', _selectedCaste),
            if (_selectedReligion.isNotEmpty)
              _buildSummaryItem('Religion:', 
                _selectedReligion == 'Other' ? _otherReligion : _selectedReligion),
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

  // Text Field Widget
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FormFieldValidator<String?> validator,
    required FormFieldSetter<String?> onSaved,
    TextInputType keyboardType = TextInputType.text,
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
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      style: TextStyle(color: Colors.grey.shade800),
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

  // Dropdown Field Widget
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required FormFieldValidator<String?> validator,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: Color(0xFF800080)),
        style: TextStyle(color: Colors.grey.shade800),
        dropdownColor: Colors.white,
      ),
    );
  }
}
