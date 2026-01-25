import 'package:flutter/material.dart';
import '../../form_template.dart'; // Import the form template
import 'irrigation_facilities_screen.dart';
import 'orchards_plants_screen.dart'; // Import the previous screen

class KitchenGardensScreen extends StatefulWidget {
  const KitchenGardensScreen({super.key});

  @override
  _KitchenGardensScreenState createState() => _KitchenGardensScreenState();
}

class _KitchenGardensScreenState extends State<KitchenGardensScreen> {
  // Controller
  final TextEditingController gardensController = TextEditingController();

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IrrigationFacilitiesScreen()),
    );
  }

  void _goToPreviousScreen() {
    // Navigate back to OrchardsPlantsScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OrchardsPlantsScreen()),
    );
  }

  Widget _buildGardensContent() {
    return Column(
      children: [
        // Info Alert
        InfoAlert(
          message: 'Small vegetable gardens near homes for family nutrition',
        ),
        
        SizedBox(height: 15),
        
        // Main Input
        QuestionCard(
          question: 'Number of Kitchen Gardens',
          description: 'Enter number (0 if none)',
          child: NumberInput(
            label: 'Number of kitchen gardens',
            controller: gardensController,
            prefixIcon: Icons.restaurant_menu,
          ),
        ),
        
        SizedBox(height: 20),
        
       
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'Kitchen Gardens',
      stepNumber: 'Step 14',
      nextScreenRoute: '/irrigation-facilities',
      nextScreenName: 'Irrigation Facilities',
      icon: Icons.restaurant_menu,
      instructions: 'Number of kitchen gardens',
      contentWidget: _buildGardensContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen, onReset: () {  },
    );
  }

  @override
  void dispose() {
    gardensController.dispose();
    super.dispose();
  }
}
