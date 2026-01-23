import 'package:flutter/material.dart';
import 'transportation_screen.dart';  // CHANGED from CookingMediumScreen

class AnimalsFisheriesScreen extends StatefulWidget {
  @override
  _AnimalsFisheriesScreenState createState() => _AnimalsFisheriesScreenState();
}

class _AnimalsFisheriesScreenState extends State<AnimalsFisheriesScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Animals data
  final Map<String, Map<String, TextEditingController>> animalsData = {
    'Cattle': {
      'number': TextEditingController(),
      'breed': TextEditingController(),
    },
    'Buffalo': {
      'number': TextEditingController(),
      'breed': TextEditingController(),
    },
    'Goat': {
      'number': TextEditingController(),
      'breed': TextEditingController(),
    },
    'Sheep': {
      'number': TextEditingController(),
      'breed': TextEditingController(),
    },
    'Pig': {
      'number': TextEditingController(),
      'breed': TextEditingController(),
    },
    'Poultry': {
      'number': TextEditingController(),
      'breed': TextEditingController(),
    },
    'Bullocks': {
      'number': TextEditingController(),
      'breed': TextEditingController(),
    },
    'Fisheries': {
      'number': TextEditingController(),
      'breed': TextEditingController(),
    },
    'Other': {
      'number': TextEditingController(),
      'breed': TextEditingController(),
    },
  };

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Calculate totals
      int totalAnimals = 0;
      int totalFisheries = 0;
      int otherAnimals = 0;
      
      animalsData.forEach((animal, controllers) {
        int number = int.tryParse(controllers['number']!.text) ?? 0;
        if (animal == 'Fisheries') {
          totalFisheries += number;
        } else if (animal == 'Other') {
          otherAnimals += number;
        } else {
          totalAnimals += number;
        }
      });
      
      int grandTotal = totalAnimals + totalFisheries + otherAnimals;
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF800080)),
              SizedBox(width: 10),
              Text('Animals & Fisheries Data Saved'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Animals and fisheries data has been saved. Continue to Transportation?'), // CHANGED
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
                      Text('📊 Animals & Fisheries Summary:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 8),
                      _buildSummaryItem('Total Livestock:', '$totalAnimals'),
                      _buildSummaryItem('Total Fisheries:', '$totalFisheries'),
                      if (otherAnimals > 0) _buildSummaryItem('Other Animals:', '$otherAnimals'),
                      _buildSummaryItem('Grand Total:', '$grandTotal'),
                      
                      // Top 3 animals
                      SizedBox(height: 10),
                      Text('Top Livestock:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 5),
                      ..._getTopAnimals(3).where((entry) => entry.key != 'Fisheries' && entry.key != 'Other').map((entry) => 
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text('• ${entry.key}: ${entry.value}'),
                        )
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
                  MaterialPageRoute(builder: (context) => TransportationScreen()), // CHANGED
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Animals & fisheries data saved! Moving to Transportation'), // CHANGED
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Continue to Transportation'), // CHANGED
            ),
          ],
        ),
      );
    }
  }

  List<MapEntry<String, int>> _getTopAnimals(int count) {
    List<MapEntry<String, int>> entries = [];
    animalsData.forEach((animal, controllers) {
      int value = int.tryParse(controllers['number']!.text) ?? 0;
      if (value > 0) {
        entries.add(MapEntry(animal, value));
      }
    });
    
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(count).toList();
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
      animalsData.forEach((animal, controllers) {
        controllers['number']!.clear();
        controllers['breed']!.clear();
      });
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
                                Icon(Icons.pets, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Animals and Fisheries',
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
                              'Step 16: Number of animals and fisheries in village',
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
                    
                    // Animals Table
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
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF800080),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text('Sr. No', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('Animals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('Number', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('Breed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 10),
                          
                          // Animal rows
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: animalsData.length,
                            itemBuilder: (context, index) {
                              String animal = animalsData.keys.elementAt(index);
                              Map<String, TextEditingController> controllers = animalsData[animal]!;
                              
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                  color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text('${index + 1}', textAlign: TextAlign.center),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        animal,
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: controllers['number'],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          hintText: '0',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return '0 if none';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: controllers['breed'],
                                        decoration: InputDecoration(
                                          hintText: 'Breed type',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Note Section
                    Card(
                      elevation: 2,
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber.shade800),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Note: Enter 0 for animals/fisheries not present in village. For "Other" category, specify breed type in the breed field.',
                                style: TextStyle(color: Colors.amber.shade800),
                              ),
                            ),
                          ],
                        ),
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
                              Icon(Icons.pets, color: Color(0xFF800080), size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Step 16: Animals and fisheries data collection',
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
                                  'Next: Transportation Facilities',
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

  @override
  void dispose() {
    animalsData.forEach((animal, controllers) {
      controllers['number']!.dispose();
      controllers['breed']!.dispose();
    });
    super.dispose();
  }
}