import 'package:flutter/material.dart';
import '../form_template.dart';
import 'drainage_waste_screen.dart';
import 'infrastructure_availability_screen.dart';

class EducationalFacilitiesScreen extends StatefulWidget {
  const EducationalFacilitiesScreen({super.key});

  @override
  _EducationalFacilitiesScreenState createState() => _EducationalFacilitiesScreenState();
}

class _EducationalFacilitiesScreenState extends State<EducationalFacilitiesScreen> {
  // Controllers
  final TextEditingController numAnganwadiController = TextEditingController();
  final TextEditingController numShikshaGuaranteeController = TextEditingController();
  final TextEditingController otherFacilityNameController = TextEditingController();
  final TextEditingController otherFacilityCountController = TextEditingController();

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DrainageWasteScreen()),
    );
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => InfrastructureAvailabilityScreen()),
    );
  }

  Widget _buildEducationalContent() {
    return Column(
      children: [
        // Anganwadi Section
        QuestionCard(
          question: 'a) No. of Anganwadi',
          description: 'Number of Anganwadi centers in village',
          child: NumberInput(
            label: 'Enter number of Anganwadi',
            controller: numAnganwadiController,
            prefixIcon: Icons.child_care,
          ),
        ),
        
        SizedBox(height: 25),
        
        // Shiksha Guarantee Section
        QuestionCard(
          question: 'b) No. of Shiksha Guarantee Beneficiaries',
          description: 'Number of beneficiaries under Shiksha Guarantee Scheme',
          child: NumberInput(
            label: 'Enter number of beneficiaries',
            controller: numShikshaGuaranteeController,
            prefixIcon: Icons.school,
          ),
        ),
        
        SizedBox(height: 25),
        
        // Other Facilities Section
        QuestionCard(
          question: ' Other Educational Facilities',
          description: 'Other educational facilities in village',
          child: Column(
            children: [
              TextInput(
                label: 'Facility Name (e.g., Coaching Center, Library, etc.)',
                controller: otherFacilityNameController,
                prefixIcon: Icons.menu_book,
                isRequired: false,
              ),
              
              SizedBox(height: 15),
              
              NumberInput(
                label: 'Number of such facilities',
                controller: otherFacilityCountController,
                prefixIcon: Icons.numbers,
              ),
            ],
          ),
        ),
        
        // Removed: Progress Indicator (Step Locator)
        
      ],
    );
  }

  // Removed: _buildProgressStep() function

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'Educational Facilities',
      stepNumber: 'Step 7',
      nextScreenRoute: '/drainage-waste',
      nextScreenName: 'Drainage & Waste Management',
      icon: Icons.school,
      instructions: 'Other educational facilities and type',
      contentWidget: _buildEducationalContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen,
      onReset: () {
        numAnganwadiController.clear();
        numShikshaGuaranteeController.clear();
        otherFacilityNameController.clear();
        otherFacilityCountController.clear();
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    numAnganwadiController.dispose();
    numShikshaGuaranteeController.dispose();
    otherFacilityNameController.dispose();
    otherFacilityCountController.dispose();
    super.dispose();
  }
}