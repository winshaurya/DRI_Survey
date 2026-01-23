import 'package:flutter/material.dart';

class CookingMediumScreen extends StatefulWidget {
  @override
  _CookingMediumScreenState createState() => _CookingMediumScreenState();
}

class _CookingMediumScreenState extends State<CookingMediumScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Cooking medium fields (number of families using each)
  String _chulaWood = '';
  String _chulaGobar = '';
  String _inductionStove = '';
  String _gasStove = '';
  String _gobarGasStove = '';
  String _electricStove = '';
  String _totalFamiliesCooking = '';
  
  // Auto-calculate total families
  void _calculateTotalFamilies() {
    int chulaWood = int.tryParse(_chulaWood) ?? 0;
    int chulaGobar = int.tryParse(_chulaGobar) ?? 0;
    int induction = int.tryParse(_inductionStove) ?? 0;
    int gas = int.tryParse(_gasStove) ?? 0;
    int gobarGas = int.tryParse(_gobarGasStove) ?? 0;
    int electric = int.tryParse(_electricStove) ?? 0;
    
    int total = chulaWood + chulaGobar + induction + gas + gobarGas + electric;
    
    setState(() {
      _totalFamiliesCooking = total.toString();
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
              Text('Cooking Medium Data Saved'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cooking medium data has been saved successfully!'),
                SizedBox(height: 15),
                
                // Cooking Medium Summary
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
                      Text('🍳 Cooking Medium Summary:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 8),
                      if (_chulaWood.isNotEmpty && _chulaWood != '0')
                        _buildCookingItem('Chula - wood/bio mass:', _chulaWood),
                      if (_chulaGobar.isNotEmpty && _chulaGobar != '0')
                        _buildCookingItem('Chula - Gobar burning:', _chulaGobar),
                      if (_inductionStove.isNotEmpty && _inductionStove != '0')
                        _buildCookingItem('Induction Stove:', _inductionStove),
                      if (_gasStove.isNotEmpty && _gasStove != '0')
                        _buildCookingItem('Gas Stove:', _gasStove),
                      if (_gobarGasStove.isNotEmpty && _gobarGasStove != '0')
                        _buildCookingItem('Gobar Gas Stove:', _gobarGasStove),
                      if (_electricStove.isNotEmpty && _electricStove != '0')
                        _buildCookingItem('Electric Stove:', _electricStove),
                      SizedBox(height: 8),
                      Divider(color: Color(0xFF800080).withOpacity(0.2)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Total Families:', style: TextStyle(fontWeight: FontWeight.w600)),
                          Spacer(),
                          Text(
                            _totalFamiliesCooking.isEmpty ? '0' : _totalFamiliesCooking,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF800080),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 15),
                
                // Success Message
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: Colors.green, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'All data collection completed successfully!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
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
                _resetForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All data submitted successfully! Thank you.'),
                    backgroundColor: Color(0xFF800080),
                    duration: Duration(seconds: 5),
                  ),
                );
                // Navigate to completion screen (you'll need to create this)
                Navigator.pushNamed(context, '/completion');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Finish & Submit All Data'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCookingItem(String label, String value) {
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
              value + ' families',
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
      _chulaWood = '';
      _chulaGobar = '';
      _inductionStove = '';
      _gasStove = '';
      _gobarGasStove = '';
      _electricStove = '';
      _totalFamiliesCooking = '';
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
                                Icon(Icons.restaurant, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Cooking Medium Information',
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
                              'Step 8c: Type of Cooking Medium used by families',
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
                    
                    // Cooking Medium Section
                    _buildQuestionWithBackground(
                      question: '🍳 Type of Cooking Medium',
                      description: 'Number of families using each cooking medium',
                      child: Column(
                        children: [
                          // Chula - wood/bio mass burning
                          _buildCookingNumberField(
                            label: 'Chula - wood/bio mass burning',
                            icon: Icons.fireplace,
                            onChanged: (value) {
                              setState(() {
                                _chulaWood = value ?? '';
                                _calculateTotalFamilies();
                              });
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
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
                                _calculateTotalFamilies();
                              });
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
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
                                _calculateTotalFamilies();
                              });
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
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
                                _calculateTotalFamilies();
                              });
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
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
                                _calculateTotalFamilies();
                              });
                            },
                            validator: (value) {
                              if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
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
                                _calculateTotalFamilies();
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
                    
                    SizedBox(height: 20),
                    
                    // Total Families Card
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
                                'Total Families (Auto-calculated)',
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
                            _totalFamiliesCooking.isEmpty ? '0' : _totalFamiliesCooking,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Sum of all cooking medium users',
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
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildCookingTypeCount('Wood Chula', _chulaWood),
                              _buildCookingTypeCount('Gobar Chula', _chulaGobar),
                              _buildCookingTypeCount('Induction', _inductionStove),
                              _buildCookingTypeCount('Gas', _gasStove),
                              _buildCookingTypeCount('Gobar Gas', _gobarGasStove),
                              _buildCookingTypeCount('Electric', _electricStove),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // Completion Progress
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.flag, color: Colors.green, size: 32),
                              SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  'Final Step - Data Collection',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            'You are about to complete all data collection for Digital India initiative.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green.shade800,
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.3),
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
                              _buildProgressStep('Step 8a', true),
                              _buildProgressStep('Step 8b', true),
                              _buildProgressStep('Step 8c', true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Summary Card
                    if (_totalFamiliesCooking.isNotEmpty && _totalFamiliesCooking != '0')
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
                            icon: Icon(Icons.check, size: 24),
                            label: Text(
                              'Submit All Data',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Final Message
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data Collection Complete!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Thank you for contributing to Digital India initiative. Your data will help in village development planning.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
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

  // Cooking Number Field
  Widget _buildCookingNumberField({
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

  // Cooking Type Count Widget
  Widget _buildCookingTypeCount(String label, String value) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
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
      ),
    );
  }

  // Progress Step Widget
  Widget _buildProgressStep(String label, bool completed) {
    return Column(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: completed ? Colors.white : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: completed
                ? Icon(Icons.check, size: 14, color: Colors.green)
                : Text(label.split(' ')[1], style: TextStyle(fontSize: 10, color: Colors.green)),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: Colors.green.shade800,
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
                  '📋 Cooking Medium Summary:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF800080),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_chulaWood.isNotEmpty && _chulaWood != '0')
              _buildSummaryItem('Wood Chula:', _chulaWood + ' families'),
            if (_chulaGobar.isNotEmpty && _chulaGobar != '0')
              _buildSummaryItem('Gobar Chula:', _chulaGobar + ' families'),
            if (_inductionStove.isNotEmpty && _inductionStove != '0')
              _buildSummaryItem('Induction Stove:', _inductionStove + ' families'),
            if (_gasStove.isNotEmpty && _gasStove != '0')
              _buildSummaryItem('Gas Stove:', _gasStove + ' families'),
            if (_gobarGasStove.isNotEmpty && _gobarGasStove != '0')
              _buildSummaryItem('Gobar Gas Stove:', _gobarGasStove + ' families'),
            if (_electricStove.isNotEmpty && _electricStove != '0')
              _buildSummaryItem('Electric Stove:', _electricStove + ' families'),
            SizedBox(height: 8),
            Container(
              height: 1,
              color: Colors.amber.shade300,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Total Families:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                  ),
                ),
                Spacer(),
                Text(
                  _totalFamiliesCooking + ' families',
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