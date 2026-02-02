import 'package:flutter/material.dart';
import 'signboards_screen.dart';
import 'disputes_screen.dart';

class UnemploymentScreen extends StatefulWidget {
  const UnemploymentScreen({super.key});

  @override
  _UnemploymentScreenState createState() => _UnemploymentScreenState();
}

class _UnemploymentScreenState extends State<UnemploymentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  TextEditingController unemployedController = TextEditingController();
  TextEditingController totalPopulationController = TextEditingController();

  void _submitForm() {
    // Navigate directly to next screen without showing dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DisputesScreen()),
    );
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignboardsScreen()),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, IconData icon, bool isRequired) {
    return Container(
      padding: EdgeInsets.all(12), // Reduced padding
      margin: EdgeInsets.only(bottom: 12),
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
              Expanded( // FIX: Wrap label in Expanded
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16, // Reduced font size
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF800080),
                  ),
                ),
              ),
              SizedBox(width: 8),
              if (!isRequired)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(icon, size: 20), // Smaller icon
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Reduced padding
              suffixIcon: !isRequired ? Container(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  '0 if empty',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ) : null,
            ),
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'Required';
              }
              if (value != null && value.isNotEmpty) {
                final parsed = int.tryParse(value);
                if (parsed == null) {
                  return 'Enter a valid number';
                }
                if (parsed < 0) {
                  return 'Cannot be negative';
                }
              }
              return null;
            },
          ),
          if (!isRequired)
            Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Leave empty if none (will be treated as 0)',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header removed
            
            Container(
              padding: EdgeInsets.all(16), // Reduced padding
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(16), // Reduced padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.work, color: Color(0xFF800080), size: 28),
                                SizedBox(width: 10),
                                Expanded( // FIX: Wrap title in Expanded
                                  child: Text(
                                    'Unemployment Data',
                                    style: TextStyle(
                                      fontSize: 20, // Reduced font size
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF800080),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Step 24: Number of unemployed rural people (16 years and above)',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14, // Reduced font size
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF800080).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Color(0xFF800080), size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Fields are optional. Empty fields will be saved as 0.',
                                      style: TextStyle(
                                        fontSize: 11, // Reduced font size
                                        color: Color(0xFF800080),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              height: 3,
                              width: 80, // Reduced width
                              decoration: BoxDecoration(
                                color: Color(0xFF800080),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Total Population (Optional)
                    _buildInputField(
                      'Total Population (16 years and above)',
                      totalPopulationController,
                      'Total population age 16+ (optional)',
                      Icons.people,
                      false,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Unemployed People (Optional)
                    Container(
                      padding: EdgeInsets.all(12), // Reduced padding
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
                              Expanded( // FIX: Wrap label in Expanded
                                child: Text(
                                  'Unemployed Rural People',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF800080),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Optional',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'People age 16+ seeking employment',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: 13, // Reduced font size
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: unemployedController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Number of unemployed people (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(Icons.work_off, color: Colors.red, size: 20),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              suffixIcon: Container(
                                padding: EdgeInsets.only(right: 8),
                                child: Text(
                                  '0 if empty',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final parsed = int.tryParse(value);
                                if (parsed == null) {
                                  return 'Enter a valid number';
                                }
                                if (parsed < 0) {
                                  return 'Cannot be negative';
                                }
                              }
                              return null;
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              'Leave empty if none (will be treated as 0)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Calculation Display
                    if (unemployedController.text.isNotEmpty || totalPopulationController.text.isNotEmpty)
                      _buildCalculationWidget(),
                    
                    SizedBox(height: 24),
                    
                    // Buttons - Previous and Continue
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _goToPreviousScreen,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14), // Reduced padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(color: Color(0xFF800080), width: 1.5),
                              ),
                              icon: Icon(Icons.arrow_back, size: 20), // Smaller icon
                              label: Text(
                                'Previous',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600), // Smaller font
                              ),
                            ),
                          ),
                          SizedBox(width: 12), // Reduced spacing
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF800080),
                                padding: EdgeInsets.symmetric(vertical: 14), // Reduced padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: Icon(Icons.arrow_forward, size: 20), // Smaller icon
                              label: Text(
                                'Save & Continue',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600), // Smaller font
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
      
      if (total == 0 && unemployed == 0) return SizedBox();
      
      String rateText = 'N/A';
      if (total > 0) {
        double percentage = (unemployed / total) * 100;
        rateText = '${percentage.toStringAsFixed(1)}%';
      }
      
      return Container(
        padding: EdgeInsets.all(12), // Reduced padding
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: total > 0 && (unemployed / total) > 0.1 ? Colors.red.shade50 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: total > 0 && (unemployed / total) > 0.1 ? Colors.red.shade200 : Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  total > 0 && (unemployed / total) > 0.1 ? Icons.warning : Icons.info,
                  color: total > 0 && (unemployed / total) > 0.1 ? Colors.red : Colors.blue,
                  size: 20, // Smaller icon
                ),
                SizedBox(width: 8),
                Expanded( // FIX: Wrap title in Expanded
                  child: Text(
                    'Unemployment Rate',
                    style: TextStyle(
                      fontSize: 15, // Reduced font size
                      fontWeight: FontWeight.w600,
                      color: total > 0 && (unemployed / total) > 0.1 ? Colors.red.shade800 : Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '$unemployed out of $total people are unemployed',
              style: TextStyle(
                fontSize: 14, // Reduced font size
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Unemployment rate: $rateText',
              style: TextStyle(
                fontSize: 15, // Reduced font size
                fontWeight: FontWeight.w600,
                color: total > 0 && (unemployed / total) > 0.1 ? Colors.red.shade800 : Colors.blue.shade800,
              ),
            ),
            if (total > 0 && unemployed > total)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 16), // Smaller icon
                    SizedBox(width: 8),
                    Expanded( // FIX: Wrap error message in Expanded
                      child: Text(
                        'Unemployed cannot exceed total population',
                        style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            if (total == 0)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.grey, size: 16), // Smaller icon
                    SizedBox(width: 8),
                    Expanded( // FIX: Wrap info message in Expanded
                      child: Text(
                        'Total population is 0. Rate calculation not available.',
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                      ),
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