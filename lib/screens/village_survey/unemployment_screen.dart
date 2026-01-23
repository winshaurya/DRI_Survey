import 'package:flutter/material.dart';
import 'disputes_screen.dart';

class UnemploymentScreen extends StatefulWidget {
  @override
  _UnemploymentScreenState createState() => _UnemploymentScreenState();
}

class _UnemploymentScreenState extends State<UnemploymentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  TextEditingController unemployedController = TextEditingController();
  TextEditingController totalPopulationController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      int unemployed = int.tryParse(unemployedController.text) ?? 0;
      int totalPopulation = int.tryParse(totalPopulationController.text) ?? 0;
      
      double percentage = totalPopulation > 0 ? (unemployed / totalPopulation) * 100 : 0;
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF800080)),
              SizedBox(width: 10),
              Text('Unemployment Data Saved'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unemployment data has been saved. Continue to Disputes?'),
                SizedBox(height: 15),
                
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
                      Text('📊 Unemployment Summary:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 8),
                      _buildSummaryItem('Unemployed (16+ years):', unemployedController.text),
                      _buildSummaryItem('Total Population (16+):', totalPopulationController.text),
                      _buildSummaryItem('Unemployment Rate:', '${percentage.toStringAsFixed(1)}%'),
                      
                      if (percentage > 10)
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'High unemployment rate (>10%)',
                                style: TextStyle(color: Colors.red.shade800),
                              ),
                            ],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisputesScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Unemployment data saved! Moving to Disputes'),
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Continue to Disputes'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
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
      unemployedController.clear();
      totalPopulationController.clear();
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
            
            Container(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.work, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Unemployment Data',
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
                              'Step 24: Number of unemployed rural people (16 years and above)',
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
                    
                    // Total Population
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Population (16 years and above)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800080),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: totalPopulationController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Total population age 16+ in village',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.people),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Enter valid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Unemployed People
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unemployed Rural People',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800080),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'People age 16+ seeking employment',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: unemployedController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Number of unemployed people',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.work_off, color: Colors.red),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Enter valid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Calculation Display
                    if (unemployedController.text.isNotEmpty && totalPopulationController.text.isNotEmpty)
                      _buildCalculationWidget(),
                    
                    SizedBox(height: 30),
                    
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.work, color: Color(0xFF800080), size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Step 24: Unemployment data collection',
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
                                Icon(Icons.navigate_next, color: Colors.green.shade700, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Next: Village Disputes',
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

  Widget _buildCalculationWidget() {
    try {
      int unemployed = int.tryParse(unemployedController.text) ?? 0;
      int total = int.tryParse(totalPopulationController.text) ?? 0;
      
      if (total <= 0 || unemployed < 0) return SizedBox();
      
      double percentage = (unemployed / total) * 100;
      
      return Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: percentage > 10 ? Colors.red.shade50 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: percentage > 10 ? Colors.red.shade200 : Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  percentage > 10 ? Icons.warning : Icons.info,
                  color: percentage > 10 ? Colors.red : Colors.blue,
                ),
                SizedBox(width: 8),
                Text(
                  'Unemployment Rate',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: percentage > 10 ? Colors.red.shade800 : Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              '$unemployed out of $total people are unemployed',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Unemployment rate: ${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: percentage > 10 ? Colors.red.shade800 : Colors.blue.shade800,
              ),
            ),
            if (unemployed > total)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Unemployed cannot exceed total population',
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    } catch (e) {
      return SizedBox();
    }
  }

  @override
  void dispose() {
    unemployedController.dispose();
    totalPopulationController.dispose();
    super.dispose();
  }
}