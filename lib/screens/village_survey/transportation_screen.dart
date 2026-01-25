import 'package:flutter/material.dart';
import '../../form_template.dart';
import 'panchavati_trees_screen.dart';
import 'animals_fisheries_screen.dart'; // Import the previous screen

class TransportationScreen extends StatefulWidget {
  const TransportationScreen({super.key});

  @override
  _TransportationScreenState createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  final Map<String, TextEditingController> vehicles = {
    'Tractor': TextEditingController(),
    'Car/Jeep': TextEditingController(),
    'Motorcycle/Scooter': TextEditingController(),
    'Cycle': TextEditingController(),
    'E-rickshaw': TextEditingController(),
    'Pick-up/Truck': TextEditingController(),
  };

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PanchavatiTreesScreen()),
    );
  }

  void _goToPreviousScreen() {
    // Navigate back to AnimalsFisheriesScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AnimalsFisheriesScreen()),
    );
  }

  Widget _buildTransportationContent() {
    return Column(
      children: [
        // Vehicles Table
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
                          'Vehicle Type',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Count',
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
                
                // Vehicle Rows
                ...vehicles.entries.map((entry) => Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: entry.value,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter number',
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
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              // No prefixIcon - empty field ready for numbers
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.grey.shade800),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'Transportation Facilities',
      stepNumber: 'Step 17',
      nextScreenRoute: '/panchavati-trees',
      nextScreenName: 'Panchavati Trees',
      icon: Icons.directions_car,
      instructions: 'Enter number of vehicles available in the village',
      contentWidget: _buildTransportationContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen,
      onReset: () {
        setState(() {
          vehicles.forEach((_, controller) => controller.clear());
        });
      },
    );
  }

  @override
  void dispose() {
    vehicles.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
