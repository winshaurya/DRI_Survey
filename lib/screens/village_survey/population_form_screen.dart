import 'package:flutter/material.dart';
import '../../form_template.dart';
import 'farm_families_screen.dart';
import 'village_form_screen.dart'; // Import the previous screen

class PopulationFormScreen extends StatefulWidget {
  const PopulationFormScreen({super.key});

  @override
  _PopulationFormScreenState createState() => _PopulationFormScreenState();
}

class _PopulationFormScreenState extends State<PopulationFormScreen> {
  // Population controllers
  final TextEditingController familiesController = TextEditingController();
  final TextEditingController menController = TextEditingController();
  final TextEditingController womenController = TextEditingController();
  final TextEditingController maleChildrenController = TextEditingController();
  final TextEditingController femaleChildrenController = TextEditingController();

  // Religion controllers
  final TextEditingController hindusController = TextEditingController();
  final TextEditingController muslimsController = TextEditingController();
  final TextEditingController christiansController = TextEditingController();
  final TextEditingController otherReligionsController = TextEditingController();

  // Caste controllers
  final TextEditingController scController = TextEditingController();
  final TextEditingController stController = TextEditingController();
  final TextEditingController obcController = TextEditingController();
  final TextEditingController generalController = TextEditingController();

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FarmFamiliesScreen()),
    );
  }

  void _goToPreviousScreen() {
    // Navigate back to VillageFormScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => VillageFormScreen()),
    );
  }

  void _resetForm() {
    setState(() {
      familiesController.clear();
      menController.clear();
      womenController.clear();
      maleChildrenController.clear();
      femaleChildrenController.clear();
      hindusController.clear();
      muslimsController.clear();
      christiansController.clear();
      otherReligionsController.clear();
      scController.clear();
      stController.clear();
      obcController.clear();
      generalController.clear();
    });
  }

  Widget _buildPopulationContent() {
    return Column(
      children: [
        // Families
        QuestionCard(
          question: 'Families',
          description: 'Number of families in village',
          child: Column(
            children: [
              NumberInput(
                label: 'Enter number of families',
                controller: familiesController,
                prefixIcon: Icons.family_restroom,
              ),
            ],
          ),
        ),

        // Gender Breakdown
        QuestionCard(
          question: 'Gender Breakdown',
          description: 'People in each category',
          child: Column(
            children: [
              NumberInput(
                label: 'Men (18+ years)',
                controller: menController,
                prefixIcon: Icons.man,
              ),
              SizedBox(height: 15),
              NumberInput(
                label: 'Women (18+ years)',
                controller: womenController,
                prefixIcon: Icons.woman,
              ),
              SizedBox(height: 15),
              NumberInput(
                label: 'Male Children (0-17 years)',
                controller: maleChildrenController,
                prefixIcon: Icons.boy,
              ),
              SizedBox(height: 15),
              NumberInput(
                label: 'Female Children (0-17 years)',
                controller: femaleChildrenController,
                prefixIcon: Icons.girl,
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Religion Distribution
        QuestionCard(
          question: 'Religion Distribution',
          description: 'People by religion',
          child: Column(
            children: [
              NumberInput(
                label: 'Hindus',
                controller: hindusController,
                prefixIcon: Icons.temple_hindu,
              ),
              SizedBox(height: 10),
              NumberInput(
                label: 'Muslims',
                controller: muslimsController,
                prefixIcon: Icons.mosque,
              ),
              SizedBox(height: 10),
              NumberInput(
                label: 'Christians',
                controller: christiansController,
                prefixIcon: Icons.church,
              ),
              SizedBox(height: 10),
              NumberInput(
                label: 'Others',
                controller: otherReligionsController,
                prefixIcon: Icons.diversity_3,
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Caste Distribution
        QuestionCard(
          question: 'Caste Distribution',
          description: 'People by caste',
          child: Column(
            children: [
              NumberInput(
                label: 'Scheduled Caste (S.C.)',
                controller: scController,
                prefixIcon: Icons.assignment_ind,
              ),
              SizedBox(height: 10),
              NumberInput(
                label: 'Scheduled Tribe (S.T.)',
                controller: stController,
                prefixIcon: Icons.forest,
              ),
              SizedBox(height: 10),
              NumberInput(
                label: 'Other Backward Class (O.B.C.)',
                controller: obcController,
                prefixIcon: Icons.groups,
              ),
              SizedBox(height: 10),
              NumberInput(
                label: 'General',
                controller: generalController,
                prefixIcon: Icons.person,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'Population Details',
      stepNumber: 'Step 2',
      nextScreenRoute: '/farm-families',
      nextScreenName: 'Farm Families',
      icon: Icons.people,
      instructions: 'Enter village population statistics',
      contentWidget: _buildPopulationContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen,
      onReset: _resetForm,
    );
  }

  @override
  void dispose() {
    familiesController.dispose();
    menController.dispose();
    womenController.dispose();
    maleChildrenController.dispose();
    femaleChildrenController.dispose();
    hindusController.dispose();
    muslimsController.dispose();
    christiansController.dispose();
    otherReligionsController.dispose();
    scController.dispose();
    stController.dispose();
    obcController.dispose();
    generalController.dispose();
    super.dispose();
  }
}
