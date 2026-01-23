import 'package:flutter/material.dart';
import '../../components/logo_widget.dart';
import 'infrastructure_screen.dart';

class HousingScreen extends StatefulWidget {
  @override
  _HousingScreenState createState() => _HousingScreenState();
}

class _HousingScreenState extends State<HousingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Housing fields
  String _huts = '';
  String _kacha = '';
  String _pakka = '';
  String _kachaPakka = '';
  String _pmAwasYojana = '';
  String _solarLight = '';
  String _totalHouses = '';
  
  // Auto-calculate total
  void _calculateTotalHouses() {
    int huts = int.tryParse(_huts) ?? 0;
    int kacha = int.tryParse(_kacha) ?? 0;
    int pakka = int.tryParse(_pakka) ?? 0;
    int kachaPakka = int.tryParse(_kachaPakka) ?? 0;
    
    int total = huts + kacha + pakka + kachaPakka;
    
    setState(() {
      _totalHouses = total.toString();
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
              Text('Housing Data Saved'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Housing data has been saved. Continue to infrastructure data?'),
                SizedBox(height: 15),
                
                // Housing Summary
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
                      Text('🏠 Housing Summary:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 8),
                      _buildHousingItem('Huts:', _huts),
                      _buildHousingItem('Kacha (Earthen House):', _kacha),
                      _buildHousingItem('Pakka (Brick House):', _pakka),
                      _buildHousingItem('Kacha/Pakka:', _kachaPakka),
                      SizedBox(height: 8),
                      Container(
                        height: 1,
                        color: Color(0xFF800080).withOpacity(0.2),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Total Houses:', style: TextStyle(fontWeight: FontWeight.w600)),
                          Spacer(),
                          Text(
                            _totalHouses,
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
                
                // Government Schemes
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🏛️ Government Schemes:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade800)),
                      SizedBox(height: 8),
                      _buildSchemeItem('PM Awas Yojana:', _pmAwasYojana),
                      _buildSchemeItem('Solar Light:', _solarLight),
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
                  MaterialPageRoute(builder: (context) => InfrastructureScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Housing data saved!'),
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Continue to Infrastructure'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildHousingItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          SizedBox(width: 10),
          Text(
            value.isEmpty ? '0' : value,
            style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080)),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          SizedBox(width: 10),
          Text(
            value.isEmpty ? '0' : value,
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade700),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _huts = '';
      _kacha = '';
      _pakka = '';
      _kachaPakka = '';
      _pmAwasYojana = '';
      _solarLight = '';
      _totalHouses = '';
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
                                Icon(Icons.house, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Housing Information',
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
                              'Step 4: No. of Families Possessing Different Types of Houses',
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
                    
                    // Housing Types Section
                    _buildQuestionWithBackground(
                      question: '🏘️ Types of Houses *',
                      description: 'Enter number of families for each housing type',
                      child: Column(
                        children: [
                          // Huts
                          _buildNumberField(
                            label: 'Huts',
                            icon: Icons.house_siding,
                            onChanged: (value) {
                              setState(() {
                                _huts = value ?? '';
                                _calculateTotalHouses();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number of huts';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Kacha (Earthen House)
                          _buildNumberField(
                            label: 'Kacha (Earthen House)',
                            icon: Icons.landscape,
                            onChanged: (value) {
                              setState(() {
                                _kacha = value ?? '';
                                _calculateTotalHouses();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number of Kacha houses';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Pakka (Brick House)
                          _buildNumberField(
                            label: 'Pakka (Brick House)',
                            icon: Icons.domain,
                            onChanged: (value) {
                              setState(() {
                                _pakka = value ?? '';
                                _calculateTotalHouses();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number of Pakka houses';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 15),
                          
                          // Kacha/Pakka
                          _buildNumberField(
                            label: 'Kacha/Pakka (Mixed)',
                            icon: Icons.home_work,
                            onChanged: (value) {
                              setState(() {
                                _kachaPakka = value ?? '';
                                _calculateTotalHouses();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number of Kacha/Pakka houses';
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
                    
                    // Total Houses Card
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
                          Icon(Icons.home, size: 32, color: Colors.white),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Houses (Auto-calculated)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Sum of all housing types',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _totalHouses.isEmpty ? '0' : _totalHouses,
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
                    
                    // Government Schemes Section
                    _buildQuestionWithBackground(
                      question: '🏛️ Government Schemes',
                      description: 'Number of families benefiting from government schemes',
                      child: Column(
                        children: [
                          // PM Awas Yojana
                          _buildNumberField(
                            label: 'PM Awas Yojana',
                            icon: Icons.verified_user,
                            onChanged: (value) {
                              setState(() {
                                _pmAwasYojana = value ?? '';
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
                          
                          // Solar Light
                          _buildNumberField(
                            label: 'Solar Light',
                            icon: Icons.lightbulb,
                            onChanged: (value) {
                              setState(() {
                                _solarLight = value ?? '';
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
                    
                    // Summary Card
                    if (_totalHouses.isNotEmpty && _totalHouses != '0')
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
                  '📋 Housing Summary:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF800080),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_huts.isNotEmpty)
              _buildSummaryItem('Huts:', _huts),
            if (_kacha.isNotEmpty)
              _buildSummaryItem('Kacha Houses:', _kacha),
            if (_pakka.isNotEmpty)
              _buildSummaryItem('Pakka Houses:', _pakka),
            if (_kachaPakka.isNotEmpty)
              _buildSummaryItem('Kacha/Pakka:', _kachaPakka),
            if (_pmAwasYojana.isNotEmpty)
              _buildSummaryItem('PM Awas Yojana:', _pmAwasYojana),
            if (_solarLight.isNotEmpty)
              _buildSummaryItem('Solar Light:', _solarLight),
            SizedBox(height: 8),
            Container(
              height: 1,
              color: Colors.amber.shade300,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Total Houses:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                  ),
                ),
                Spacer(),
                Text(
                  _totalHouses,
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
}
