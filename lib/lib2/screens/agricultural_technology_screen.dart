import 'package:flutter/material.dart';
import 'seed_clubs_screen.dart'; // Import the previous screen (changed from organic_manure)
import 'agricultural_implements_screen.dart';

class AgriculturalTechnologyScreen extends StatefulWidget {
  const AgriculturalTechnologyScreen({super.key});

  @override
  _AgriculturalTechnologyScreenState createState() => _AgriculturalTechnologyScreenState();
}

class _AgriculturalTechnologyScreenState extends State<AgriculturalTechnologyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController traditionalController = TextEditingController();
  final TextEditingController improvedController = TextEditingController();

  void _submitForm() {
    // Directly save and navigate without popup
    int traditional = int.tryParse(traditionalController.text) ?? 0;
    int improved = int.tryParse(improvedController.text) ?? 0;
    
    // Show simple snackbar for confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data saved successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
    
    // Navigate directly to next screen
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AgriculturalImplementsScreen()),
      );
    });
  }

  void _goToPreviousScreen() {
    // Navigate back to SeedClubsScreen (changed from OrganicManureScreen)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SeedClubsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header - Made more compact
            Container(
              height: 90, // Reduced height
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Government of India', 
                    style: TextStyle(
                      fontSize: 18, // Reduced font size
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF003366)
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text('Digital India', 
                    style: TextStyle(
                      fontSize: 14, // Reduced font size
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              padding: EdgeInsets.all(12), // Reduced padding
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title - Made more compact
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12), // Reduced padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.engineering, color: Color(0xFF800080), size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Agricultural Technology', 
                                  style: TextStyle(
                                    fontSize: 16, // Reduced font size
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ),
                            ]),
                            SizedBox(height: 6),
                            Text('Step 21: Families using agricultural technology',
                              style: TextStyle(
                                fontSize: 13, // Reduced font size
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16), // Reduced spacing
                    
                    // Traditional Input - Made more compact
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12), // Reduced padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Traditional (ITK)', 
                              style: TextStyle(
                                fontSize: 14, // Reduced font size
                                fontWeight: FontWeight.w600
                              )
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: traditionalController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Families using traditional methods',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, 
                                  vertical: 12
                                ),
                                helperText: 'Optional - leave empty for zero',
                                helperStyle: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 12), // Reduced spacing
                    
                    // Improved Input - Made more compact
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12), // Reduced padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Improved Technology', 
                              style: TextStyle(
                                fontSize: 14, // Reduced font size
                                fontWeight: FontWeight.w600
                              )
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: improvedController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Families using improved technology',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, 
                                  vertical: 12
                                ),
                                helperText: 'Optional - leave empty for zero',
                                helperStyle: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 24), // Reduced spacing before buttons
                    
                    // Buttons - Previous and Continue - Made more compact
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _goToPreviousScreen,
                              icon: Icon(Icons.arrow_back, size: 18),
                              label: Text('Previous',
                                style: TextStyle(fontSize: 13)
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12), // Reduced
                                side: BorderSide(color: Color(0xFF800080)),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _submitForm,
                              icon: Icon(Icons.save, size: 18),
                              label: Text('Save & Continue',
                                style: TextStyle(fontSize: 13)
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF800080),
                                padding: EdgeInsets.symmetric(vertical: 12), // Reduced
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

  @override
  void dispose() {
    traditionalController.dispose();
    improvedController.dispose();
    super.dispose();
  }
}