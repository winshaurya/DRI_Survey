import 'package:flutter/material.dart';
import '../../form_template.dart'; // Import the form template
import 'traditional_occupations_screen.dart';
import 'crop_productivity_screen.dart'; // Import the previous screen

class BPLFamiliesScreen extends StatefulWidget {
  const BPLFamiliesScreen({super.key});

  @override
  _BPLFamiliesScreenState createState() => _BPLFamiliesScreenState();
}

class _BPLFamiliesScreenState extends State<BPLFamiliesScreen> {
  // Controllers
  final TextEditingController familiesController = TextEditingController();
  final TextEditingController bplController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TraditionalOccupationsScreen()),
    );
  }

  void _goToPreviousScreen() {
    // Navigate back to CropProductivityScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CropProductivityScreen()),
    );
  }

  Widget _buildBPLContent() {
    return Column(
      children: [
        // Families
        QuestionCard(
          question: 'Number of Families',
          description: 'Families in village',
          child: NumberInput(
            label: 'Families in village',
            controller: familiesController,
            prefixIcon: Icons.family_restroom,
          ),
        ),
        
        SizedBox(height: 20),
        
        // BPL Families
        QuestionCard(
          question: 'BPL Families (Below Poverty Line)',
          description: 'Annual income less than ₹27,000',
          child: NumberInput(
            label: 'Number of BPL families',
            controller: bplController,
            prefixIcon: Icons.money_off,
          ),
        ),
        
        SizedBox(height: 20),
        
        // Average Annual Income
        QuestionCard(
          question: 'Average Annual Income of BPL Families',
          description: 'Average income must be less than ₹27,000',
          child: TextInput(
            label: 'Average income',
            controller: incomeController,
            prefixIcon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                double income = double.tryParse(value) ?? 0;
                if (income >= 27000) {
                  return 'Income must be less than ₹27,000';
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'BPL Families',
      stepNumber: 'Step 10',
      nextScreenRoute: '/traditional-occupations',
      nextScreenName: 'Traditional Occupations',
      icon: Icons.people,
      instructions: 'Below Poverty Line families (Income < ₹27,000 per annum)',
      contentWidget: _buildBPLContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen, onReset: () {  },
    );
  }

  @override
  void dispose() {
    familiesController.dispose();
    bplController.dispose();
    incomeController.dispose();
    super.dispose();
  }
}
