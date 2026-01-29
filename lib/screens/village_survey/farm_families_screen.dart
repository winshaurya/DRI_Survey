import 'package:flutter/material.dart';
import '../../form_template.dart'; // Import the form template
import 'housing_screen.dart';
import 'village_form_screen.dart'; // Import the previous screen

class FarmFamiliesScreen extends StatefulWidget {
  const FarmFamiliesScreen({super.key});

  @override
  _FarmFamiliesScreenState createState() => _FarmFamiliesScreenState();
}

class _FarmFamiliesScreenState extends State<FarmFamiliesScreen> {
  // Controllers for form fields
  final TextEditingController bigFarmersController = TextEditingController();
  final TextEditingController smallFarmersController = TextEditingController();
  final TextEditingController marginalFarmersController = TextEditingController();
  final TextEditingController landlessFarmersController = TextEditingController();

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HousingScreen()),
    );
  }

  void _goToPreviousScreen() {
    // Navigate back to VillageFormScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => VillageFormScreen()),
    );
  }

  Widget _buildFarmContent() {
    return Column(
      children: [
        // Big Farmers (> 5 Hectare)
        QuestionCard(
          question: ' Big Farmers (Landholding > 5 Hectare) *',
          description: 'Farmers with landholding more than 5 hectares',
          child: NumberInput(
            label: 'Enter number of big farmers',
            controller: bigFarmersController,
            prefixIcon: Icons.agriculture,
          ),
        ),
        
        SizedBox(height: 20),
        
        // Small Farmers (1-5 Hectare)
        QuestionCard(
          question: ' Small Farmers (Landholding 1-5 Hectare) *',
          description: 'Farmers with landholding between 1 to 5 hectares',
          child: NumberInput(
            label: 'Enter number of small farmers',
            controller: smallFarmersController,
            prefixIcon: Icons.grass,
          ),
        ),
        
        SizedBox(height: 20),
        
        // Marginal Farmers (Upto 1 Hectare)
        QuestionCard(
          question: ' Marginal Farmers (Upto 1 Hectare) *',
          description: 'Farmers with landholding up to 1 hectare',
          child: NumberInput(
            label: 'Enter number of marginal farmers',
            controller: marginalFarmersController,
            prefixIcon: Icons.spa,
          ),
        ),
        
        SizedBox(height: 20),
        
        // Landless Families
        QuestionCard(
          question: ' Landless Families *',
          description: 'Families without agricultural land',
          child: NumberInput(
            label: 'Enter number of landless families',
            controller: landlessFarmersController,
            prefixIcon: Icons.person_outline,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'Farm Families Information',
      stepNumber: 'Step 3',
      nextScreenRoute: '/housing',
      nextScreenName: 'Housing Details',
      icon: Icons.agriculture,
      instructions: 'Enter farm families by landholding categories',
      contentWidget: _buildFarmContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen, onReset: () {  },
    );
  }

  @override
  void dispose() {
    bigFarmersController.dispose();
    smallFarmersController.dispose();
    marginalFarmersController.dispose();
    landlessFarmersController.dispose();
    super.dispose();
  }
}
