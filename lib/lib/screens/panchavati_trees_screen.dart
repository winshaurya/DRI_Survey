import 'package:flutter/material.dart';
import '../form_template.dart';
import 'organic_manure_screen.dart';
import 'transportation_screen.dart'; // Import the previous screen

class PanchavatiTreesScreen extends StatefulWidget {
  const PanchavatiTreesScreen({super.key});

  @override
  _PanchavatiTreesScreenState createState() => _PanchavatiTreesScreenState();
}

class _PanchavatiTreesScreenState extends State<PanchavatiTreesScreen> {
  bool hasPanchavati = false;
  final TextEditingController panchavatiCountController = TextEditingController();
  
  final Map<String, TextEditingController> trees = {
    'Pipal': TextEditingController(),
    'Banyan': TextEditingController(),
    'Mango': TextEditingController(),
    'Aonla': TextEditingController(),
    'Bel': TextEditingController(),
    'Other': TextEditingController(),
  };

  // Calculate total trees
  String _totalTrees = '0';

  void _calculateTotalTrees() {
    int total = 0;
    trees.forEach((_, controller) {
      total += int.tryParse(controller.text) ?? 0;
    });
    
    setState(() {
      _totalTrees = total.toString();
    });
  }

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrganicManureScreen()),
    );
  }

  void _goToPreviousScreen() {
    // Navigate back to TransportationScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TransportationScreen()),
    );
  }

  Widget _buildPanchavatiContent() {
    return Column(
      children: [
        // Panchavati Radio Section
        QuestionCard(
          question: 'Presence of Panchavati',
          description: 'Traditional group of five sacred trees',
          child: Column(
            children: [
              RadioOptionGroup(
                label: 'Is there a Panchavati in the village?',
                options: ['Yes', 'No'],
                selectedValue: hasPanchavati ? 'Yes' : 'No',
                onChanged: (value) {
                  setState(() {
                    hasPanchavati = value == 'Yes';
                    if (!hasPanchavati) {
                      panchavatiCountController.clear();
                    }
                  });
                },
              ),
              
              if (hasPanchavati) ...[
                SizedBox(height: 15),
                NumberInput(
                  label: 'How many Panchavati?',
                  controller: panchavatiCountController,
                  // Removed prefixIcon
                ),
              ],
            ],
          ),
        ),
        
        SizedBox(height: 20),
        
        // Trees Table
        QuestionCard(
          question: 'Tree Types and Counts',
          description: 'Count of sacred and important trees in the village',
          child: Column(
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
                          color: Color(0xFF228B22), // Green color for trees
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
                                'Tree Type',
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
                      
                      // Tree Rows
                      ...trees.entries.map((entry) => Container(
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
                                child: NumberInput(
                                  label: '',
                                  controller: entry.value,
                                  // Removed prefixIcon
                                  isRequired: false,
                                  onChanged: (value) => _calculateTotalTrees(),
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
          ),
        ),
        
        SizedBox(height: 20),
        
        // Total Trees Display
        
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'Panchavati Trees',
      stepNumber: 'Step 18',
      nextScreenRoute: '/organic-manure',
      nextScreenName: 'Organic Manure',
      icon: Icons.park,
      instructions: 'Record Panchavati availability and tree counts in the village',
      contentWidget: _buildPanchavatiContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen, onReset: () {  },
    );
  }

  @override
  void dispose() {
    panchavatiCountController.dispose();
    trees.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}