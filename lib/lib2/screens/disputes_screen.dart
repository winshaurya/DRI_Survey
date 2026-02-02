import 'package:flutter/material.dart';
import 'unemployment_screen.dart';
import 'social_consciousness_screen.dart';

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({super.key});

  @override
  _DisputesScreenState createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen> {
  final _formKey = GlobalKey<FormState>();
  
  TextEditingController familyDisputesController = TextEditingController();
  TextEditingController revenueDisputesController = TextEditingController();
  TextEditingController criminalDisputesController = TextEditingController();

  void _submitForm() {
    // Navigate directly to next screen without showing dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SocialConsciousnessScreen()),
    );
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UnemploymentScreen()),
    );
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
                                Icon(Icons.gavel, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Village Disputes',
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
                              'Step 25: Number of disputes in village',
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
                    
                    // Family Disputes
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
                            'a) Family Disputes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade800,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: familyDisputesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Number of family disputes',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.family_restroom, color: Colors.red),
                              helperText: 'Disputes within families (leave empty for zero)',
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Revenue Disputes
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
                            'b) Revenue (Property Related) Disputes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: revenueDisputesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Number of revenue disputes',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.landscape, color: Colors.orange),
                              helperText: 'Property, land, revenue related disputes (leave empty for zero)',
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Criminal Disputes
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
                            'c) Faujdari (Criminal) Disputes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple.shade800,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: criminalDisputesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Number of criminal disputes',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.security, color: Colors.purple),
                              helperText: 'Criminal cases, police complaints (leave empty for zero)',
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Buttons - Previous and Continue
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _goToPreviousScreen,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: Color(0xFF800080), width: 2),
                            ),
                            icon: Icon(Icons.arrow_back, size: 24),
                            label: Text(
                              'Previous',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
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
                    
                    // Removed: Progress Indicator with Navigation Info
                    
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
    familyDisputesController.dispose();
    revenueDisputesController.dispose();
    criminalDisputesController.dispose();
    super.dispose();
  }
}