import 'package:flutter/material.dart';
import 'social_map_screen.dart';
import 'disputes_screen.dart'; // Import the previous screen

class SocialConsciousnessScreen extends StatefulWidget {
  const SocialConsciousnessScreen({super.key});

  @override
  _SocialConsciousnessScreenState createState() => _SocialConsciousnessScreenState();
}

class _SocialConsciousnessScreenState extends State<SocialConsciousnessScreen> {
  final List<Map<String, TextEditingController>> indicators = List.generate(9, (index) {
    return {
      'indicator': TextEditingController(),
      'instances': TextEditingController(),
      'details': TextEditingController(),
    };
  });

  // Function to navigate back to DisputesScreen
  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DisputesScreen()),
    );
  }

  void _submitForm() {
    // Direct navigation to SocialMapScreen without popup
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SocialMapScreen()),
    );
  }

  Widget _buildSocialContent() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Instructions
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade800, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Record social consciousness indicators in the village (e.g., child marriage, dowry, discrimination, etc.)',
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Table Header
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF800080),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Indicator', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  Expanded(
                    child: Text('Instances', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  Expanded(
                    child: Text('Details', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
            
            // Table Rows
            ...indicators.asMap().entries.map((entry) => Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: entry.value['indicator'],
                      decoration: InputDecoration(
                        hintText: 'Social indicator',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: entry.value['instances'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'No. of instances',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: entry.value['details'],
                      decoration: InputDecoration(
                        hintText: 'Additional details',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            
            // Removed the Navigation Info footer
            
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Custom build to avoid TemplateScreen popup
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF800080)),
          onPressed: _goToPreviousScreen,
          tooltip: 'Go back',
        ),
        title: Text(
          'Social Consciousness',
          style: TextStyle(
            color: Color(0xFF800080),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 100,
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Government of India', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                  Text('Digital India', 
                    style: TextStyle(fontSize: 16, color: Colors.orange)),
                ],
              ),
            ),
            
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.psychology, color: Color(0xFF800080)),
                            SizedBox(width: 10),
                            Text('Social Consciousness', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF800080))),
                          ]),
                          SizedBox(height: 8),
                          Text('Step 26: Social Consciousness'),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Content Widget
                  _buildSocialContent(),
                  
                  SizedBox(height: 20),
                  
                  // Buttons - Direct navigation without popup
                  Row(
                    children: [
                      // Previous button - Added here
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _goToPreviousScreen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: Icon(Icons.arrow_back, size: 20),
                          label: Text('Previous'),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Save & Continue button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF800080),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text('Save & Continue'),
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
    );
  }

  @override
  void dispose() {
    for (var indicator in indicators) {
      indicator['indicator']!.dispose();
      indicator['instances']!.dispose();
      indicator['details']!.dispose();
    }
    super.dispose();
  }
}