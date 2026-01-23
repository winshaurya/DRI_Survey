import 'package:flutter/material.dart';
import '../form_template.dart'; // Import the form template
import 'kitchen_gardens_screen.dart';
import 'children_not_in_school_screen.dart'; // Import the previous screen

class OrchardsPlantsScreen extends StatefulWidget {
  const OrchardsPlantsScreen({super.key});

  @override
  _OrchardsPlantsScreenState createState() => _OrchardsPlantsScreenState();
}

class _OrchardsPlantsScreenState extends State<OrchardsPlantsScreen> {
  // Controllers
  final TextEditingController orchardsController = TextEditingController();
  final TextEditingController plantsController = TextEditingController();

  // Calculated total
  String _totalPlants = '0';

  // Calculate total when values change
  void _calculateTotal() {
    int orchards = int.tryParse(orchardsController.text) ?? 0;
    int plants = int.tryParse(plantsController.text) ?? 0;
    
    setState(() {
      _totalPlants = (orchards + plants).toString();
    });
  }

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KitchenGardensScreen()),
    );
  }

  void _goToPreviousScreen() {
    // Navigate back to ChildrenNotInSchoolScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChildrenNotInSchoolScreen()),
    );
  }

  Widget _buildOrchardsContent() {
    return Column(
      children: [
        // Orchards Input
        QuestionCard(
          question: 'Number of Orchards',
          description: 'Orchards, plantations (0 if none)',
          child: NumberInput(
            label: 'Enter number of orchards',
            controller: orchardsController,
            prefixIcon: Icons.park,
            onChanged: (value) => _calculateTotal(),
          ),
        ),
        
        SizedBox(height: 20),
        
        // Plants Input
        QuestionCard(
          question: 'Number of Plants',
          description: 'Individual plants, trees (0 if none)',
          child: NumberInput(
            label: 'Enter number of plants',
            controller: plantsController,
            prefixIcon: Icons.eco,
            onChanged: (value) => _calculateTotal(),
          ),
        ),
        
        SizedBox(height: 20),
        
        // Total Display
      
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'Orchards & Plants',
      stepNumber: 'Step 13',
      nextScreenRoute: '/kitchen-gardens',
      nextScreenName: 'Kitchen Gardens',
      icon: Icons.park,
      instructions: 'Number of orchards and plants',
      contentWidget: _buildOrchardsContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen, onReset: () {  },
    );
  }

  @override
  void dispose() {
    orchardsController.dispose();
    plantsController.dispose();
    super.dispose();
  }
}