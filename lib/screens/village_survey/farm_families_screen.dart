import 'package:flutter/material.dart';
import '../../components/logo_widget.dart';
import 'housing_screen.dart';

class FarmFamiliesScreen extends StatefulWidget {
  @override
  _FarmFamiliesScreenState createState() => _FarmFamiliesScreenState();
}

class _FarmFamiliesScreenState extends State<FarmFamiliesScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Farm families fields
  String _bigFarmers = '';
  String _smallFarmers = '';
  String _marginalFarmers = '';
  String _landlessFarmers = '';
  String _totalFarmFamilies = '';
  
  // Auto-calculate total
  void _calculateTotal() {
    int big = int.tryParse(_bigFarmers) ?? 0;
    int small = int.tryParse(_smallFarmers) ?? 0;
    int marginal = int.tryParse(_marginalFarmers) ?? 0;
    int landless = int.tryParse(_landlessFarmers) ?? 0;
    
    int total = big + small + marginal + landless;
    
    setState(() {
      _totalFarmFamilies = total.toString();
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
              Text('Farm Data Saved'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Farm families data has been saved. Continue to housing data?'),
                SizedBox(height: 15),
                
                // Farm Families Summary
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
                      Text('🏡 Farm Families Summary:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 8),
                      _buildFarmItem('Big Farmers (> 5 Hectare):', _bigFarmers),
                      _buildFarmItem('Small Farmers (1-5 Hectare):', _smallFarmers),
                      _buildFarmItem('Marginal Farmers (Up to 1 Hectare):', _marginalFarmers),
                      _buildFarmItem('Landless Families:', _landlessFarmers),
                      SizedBox(height: 8),
                      Divider(color: Color(0xFF800080).withOpacity(0.2)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text('👨‍👩‍👧‍👦 Total Farm Families:', style: TextStyle(fontWeight: FontWeight.w600)),
                          Spacer(),
                          Text(
                            _totalFarmFamilies,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF800080),
                            ),
                          ),
                        ],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HousingScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Farm families data saved!'),
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Continue to Housing'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFarmItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          SizedBox(width: 10),
          Text(
            value.isEmpty ? '0' : value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF800080),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _bigFarmers = '';
      _smallFarmers = '';
      _marginalFarmers = '';
      _landlessFarmers = '';
      _totalFarmFamilies = '';
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
                                Icon(Icons.agriculture, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Farm Families Information',
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
                              'Step 3: Enter farm families by landholding categories',
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
                    
                    // Big Farmers (> 5 Hectare)
                    _buildQuestionWithBackground(
                      question: '🚜 Big Farmers (Landholding > 5 Hectare) *',
                      description: 'Farmers with landholding more than 5 hectares',
                      child: _buildNumberField(
                        label: 'Enter number of big farmers',
                        icon: Icons.agriculture,
                        onChanged: (value) {
                          setState(() {
                            _bigFarmers = value ?? '';
                            _calculateTotal();
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of big farmers';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Numbers only';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Small Farmers (1-5 Hectare)
                    _buildQuestionWithBackground(
                      question: '🌾 Small Farmers (Landholding 1-5 Hectare) *',
                      description: 'Farmers with landholding between 1 to 5 hectares',
                      child: _buildNumberField(
                        label: 'Enter number of small farmers',
                        icon: Icons.grass,
                        onChanged: (value) {
                          setState(() {
                            _smallFarmers = value ?? '';
                            _calculateTotal();
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of small farmers';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Numbers only';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Marginal Farmers (Upto 1 Hectare)
                    _buildQuestionWithBackground(
                      question: '🌱 Marginal Farmers (Upto 1 Hectare) *',
                      description: 'Farmers with landholding up to 1 hectare',
                      child: _buildNumberField(
                        label: 'Enter number of marginal farmers',
                        icon: Icons.spa,
                        onChanged: (value) {
                          setState(() {
                            _marginalFarmers = value ?? '';
                            _calculateTotal();
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of marginal farmers';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Numbers only';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Landless Families
                    _buildQuestionWithBackground(
                      question: '👨‍🌾 Landless Families *',
                      description: 'Families without agricultural land',
                      child: _buildNumberField(
                        label: 'Enter number of landless families',
                        icon: Icons.person_outline,
                        onChanged: (value) {
                          setState(() {
                            _landlessFarmers = value ?? '';
                            _calculateTotal();
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of landless families';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Numbers only';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // Total Farm Families Card (Auto-calculated)
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
                              Icon(Icons.calculate, color: Colors.white, size: 28),
                              SizedBox(width: 10),
                              Text(
                                'Total Farm Families',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            _totalFarmFamilies.isEmpty ? '0' : _totalFarmFamilies,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Auto-calculated (Sum of all categories)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCategoryCount('Big', _bigFarmers),
                              _buildCategoryCount('Small', _smallFarmers),
                              _buildCategoryCount('Marginal', _marginalFarmers),
                              _buildCategoryCount('Landless', _landlessFarmers),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Summary Card
                    if (_totalFarmFamilies.isNotEmpty && _totalFarmFamilies != '0')
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
                          Icon(Icons.check_circle, color: Color(0xFF800080), size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Farm families data will be submitted to the Digital India database',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
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
        suffixIcon: Icon(Icons.people, color: Colors.grey.shade400),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(color: Colors.grey.shade800),
    );
  }

  // Category Count Widget
  Widget _buildCategoryCount(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value.isEmpty ? '0' : value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
                  '📊 Farm Families Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF800080),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_bigFarmers.isNotEmpty)
              _buildSummaryItem('Big Farmers (> 5 Ha):', _bigFarmers),
            if (_smallFarmers.isNotEmpty)
              _buildSummaryItem('Small Farmers (1-5 Ha):', _smallFarmers),
            if (_marginalFarmers.isNotEmpty)
              _buildSummaryItem('Marginal Farmers (≤ 1 Ha):', _marginalFarmers),
            if (_landlessFarmers.isNotEmpty)
              _buildSummaryItem('Landless Families:', _landlessFarmers),
            SizedBox(height: 8),
            Container(
              height: 1,
              color: Colors.amber.shade300,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Total Farm Families:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                  ),
                ),
                Spacer(),
                Text(
                  _totalFarmFamilies,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF800080),
                  ),
                ),
              ],
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
