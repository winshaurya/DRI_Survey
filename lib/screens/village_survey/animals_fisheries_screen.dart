import 'package:flutter/material.dart';
import '../../table_template.dart';
import 'transportation_screen.dart';
import 'irrigation_facilities_screen.dart';

class AnimalsFisheriesScreen extends StatefulWidget {
  const AnimalsFisheriesScreen({super.key});

  @override
  _AnimalsFisheriesScreenState createState() => _AnimalsFisheriesScreenState();
}

class _AnimalsFisheriesScreenState extends State<AnimalsFisheriesScreen> {
  final Map<String, Map<String, TextEditingController>> animalsData = {
    'Cattle': {'num': TextEditingController(), 'breed': TextEditingController()},
    'Buffalo': {'num': TextEditingController(), 'breed': TextEditingController()},
    'Goat': {'num': TextEditingController(), 'breed': TextEditingController()},
    'Sheep': {'num': TextEditingController(), 'breed': TextEditingController()},
    'Pig': {'num': TextEditingController(), 'breed': TextEditingController()},
    'Poultry': {'num': TextEditingController(), 'breed': TextEditingController()},
    'Bullocks': {'num': TextEditingController(), 'breed': TextEditingController()},
    'Fisheries': {'num': TextEditingController(), 'breed': TextEditingController()},
    'Other': {'num': TextEditingController(), 'breed': TextEditingController()},
  };

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => IrrigationFacilitiesScreen()),
    );
  }

  void _submitForm() {
    // Direct navigation to TransportationScreen without popup
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransportationScreen()),
    );
  }

  Widget _buildAnimalsContent() {
    // Calculate total animals
    int totalAnimals = 0;
    animalsData.forEach((animal, controllers) {
      if (animal != 'Fisheries' && animal != 'Other') {
        totalAnimals += int.tryParse(controllers['num']!.text) ?? 0;
      }
    });

    return Column(
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
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
                        flex: 2,
                        child: Text(
                          'Animal',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Number',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Breed',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Table Rows
                ...animalsData.entries.map((entry) => Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(entry.key),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: entry.value['num'],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter number', // Changed from '0'
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: entry.value['breed'],
                            decoration: InputDecoration(
                              hintText: 'Enter breed',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 20),
        
        // Total Animals Display
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xFF800080),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.pets, color: Colors.white, size: 28),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Total Animals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                totalAnimals.toString(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Removed the yellow note box
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Since we can't pass onSubmit to TemplateScreen, we need to create a custom build
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
          'Animals and Fisheries',
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
                            Icon(Icons.pets, color: Color(0xFF800080)),
                            SizedBox(width: 10),
                            Text('Animals and Fisheries', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF800080))),
                          ]),
                          SizedBox(height: 8),
                          Text('Step 16: Animals and Fisheries'),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Content Widget
                  _buildAnimalsContent(),
                  
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
                  
                  // Navigation info REMOVED - nothing below the buttons
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
    animalsData.forEach((_, c) {
      c['num']!.dispose();
      c['breed']!.dispose();
    });
    super.dispose();
  }
}
