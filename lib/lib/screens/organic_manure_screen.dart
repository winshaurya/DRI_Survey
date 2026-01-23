import 'package:flutter/material.dart';
import 'panchavati_trees_screen.dart'; // Import the previous screen
import 'seed_clubs_screen.dart';

class OrganicManureScreen extends StatefulWidget {
  const OrganicManureScreen({super.key});

  @override
  _OrganicManureScreenState createState() => _OrganicManureScreenState();
}

class _OrganicManureScreenState extends State<OrganicManureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _familiesController = TextEditingController();
  final _fullyController = TextEditingController();
  final _partiallyController = TextEditingController();

  void _submitForm() {
    // Navigate directly to next screen without showing dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SeedClubsScreen()),
    );
  }

  void _goToPreviousScreen() {
    // Navigate back to PanchavatiTreesScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PanchavatiTreesScreen()),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              prefixIcon: Icon(icon, size: 20),
              helperText: 'Leave empty for zero',
            ),
            // REMOVED VALIDATOR - Field is now optional
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          color: Colors.white,
          child: Column(children: [
            Text('Government of India', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF003366)
            )),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Digital India', style: TextStyle(
                  fontSize: 16, color: Color(0xFFFF9933), fontWeight: FontWeight.w600
                )),
                SizedBox(width: 8),
                Text('Power To Empower', style: TextStyle(
                  fontSize: 14, color: Color(0xFF138808), fontStyle: FontStyle.italic
                )),
              ],
            ),
          ]),
        ),

        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Header
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.eco, color: Color(0xFF800080)),
                            SizedBox(width: 10),
                            Text('Organic Manure', style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF800080)
                            )),
                          ]),
                          SizedBox(height: 5),
                          Text('Step 19: Organic manure usage data'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Input Fields
                  _buildInputField(
                    'Families Using Organic Manure',
                    _familiesController,
                    'Number of families',
                    Icons.family_restroom,
                  ),

                  _buildInputField(
                    'Fully Organic Area (acres)',
                    _fullyController,
                    'Full organic cultivation area',
                    Icons.grass,
                  ),

                  _buildInputField(
                    'Partially Organic Area (acres)',
                    _partiallyController,
                    'Partial organic cultivation area',
                    Icons.agriculture,
                  ),

                  SizedBox(height: 25),

                  // Buttons - Previous and Continue
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _goToPreviousScreen,
                        icon: Icon(Icons.arrow_back),
                        label: Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Color(0xFF800080)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: Icon(Icons.arrow_forward),
                        label: Text('Save & Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF800080),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ]),

                  // FOOTER REMOVED FROM HERE
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _familiesController.dispose();
    _fullyController.dispose();
    _partiallyController.dispose();
    super.dispose();
  }
}