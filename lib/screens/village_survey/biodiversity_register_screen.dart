import 'package:flutter/material.dart';
import 'cooking_medium_screen.dart';

class BiodiversityRegisterScreen extends StatefulWidget {
  @override
  _BiodiversityRegisterScreenState createState() => _BiodiversityRegisterScreenState();
}

class _BiodiversityRegisterScreenState extends State<BiodiversityRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  TextEditingController registerStatusController = TextEditingController();
  TextEditingController documentationDetailsController = TextEditingController();
  TextEditingController biodiversityComponentsController = TextEditingController();
  TextEditingController traditionalKnowledgeController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF800080)),
              SizedBox(width: 10),
              Text('Biodiversity Register Data Saved'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Biodiversity register information has been saved. Continue to Cooking Medium?'),
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
                      Text('🌿 Biodiversity Register Summary:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 8),
                      if (registerStatusController.text.isNotEmpty)
                        _buildSummaryItem('Register Status:', registerStatusController.text),
                      if (documentationDetailsController.text.isNotEmpty)
                        _buildSummaryItem('Documentation:', 'Complete'),
                      if (biodiversityComponentsController.text.isNotEmpty)
                        _buildSummaryItem('Components:', 'Documented'),
                      
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.eco, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Biodiversity documentation complete',
                              style: TextStyle(color: Colors.green.shade800),
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
                  MaterialPageRoute(builder: (context) => CookingMediumScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Biodiversity register data saved! Moving to Cooking Medium'),
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Continue to Cooking Medium'),
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
            width: 150,
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
      registerStatusController.clear();
      documentationDetailsController.clear();
      biodiversityComponentsController.clear();
      traditionalKnowledgeController.clear();
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
                                Icon(Icons.eco, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'People\'s Biodiversity Register (PBR)',
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
                              'Step 32: Documentation of People\'s Biodiversity Register',
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
                    
                    // Info Card
                    Card(
                      elevation: 3,
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.green.shade800),
                                SizedBox(width: 10),
                                Text(
                                  'What is People\'s Biodiversity Register (PBR)?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'PBR is a comprehensive record of local biological resources and traditional '
                              'knowledge. It documents biodiversity, conservation practices, and community wisdom.',
                              style: TextStyle(color: Colors.green.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Register Status
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
                            'PBR Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800080),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: registerStatusController,
                            decoration: InputDecoration(
                              labelText: 'Status of Biodiversity Register',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.assignment_turned_in),
                              helperText: 'e.g., Completed, In Progress, Not Started, etc.',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter PBR status';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Documentation Details
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
                            'Documentation Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800080),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: documentationDetailsController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Details of documentation',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              helperText: 'What has been documented, by whom, when, etc.',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter documentation details';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Biodiversity Components
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
                            'Biodiversity Components Documented',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800080),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: biodiversityComponentsController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'List biodiversity components documented',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              helperText: 'Flora, fauna, ecosystems, genetic resources, etc.',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please list biodiversity components';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Traditional Knowledge
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
                            'Traditional Knowledge Documented',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800080),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: traditionalKnowledgeController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Traditional knowledge and practices documented',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              helperText: 'Medicinal uses, agricultural practices, conservation methods, etc.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    
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
                              Icon(Icons.eco, color: Color(0xFF800080), size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Step 32: People\'s Biodiversity Register documentation',
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
                                  'Next: Cooking Medium Survey',
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
                    
                    // Congratulations Card
                    Card(
                      elevation: 3,
                      color: Colors.purple.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.celebration, color: Color(0xFF800080), size: 40),
                            SizedBox(height: 10),
                            Text(
                              'Congratulations!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF800080),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'You have completed all biodiversity and environmental data collection. '
                              'Only one more section remains!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.purple.shade700),
                            ),
                          ],
                        ),
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

  @override
  void dispose() {
    registerStatusController.dispose();
    documentationDetailsController.dispose();
    biodiversityComponentsController.dispose();
    traditionalKnowledgeController.dispose();
    super.dispose();
  }
}