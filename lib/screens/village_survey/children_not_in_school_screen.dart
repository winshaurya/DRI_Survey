import 'package:flutter/material.dart';
import '../../form_template.dart';
import 'orchards_plants_screen.dart';
import 'traditional_occupations_screen.dart';

class ChildrenNotInSchoolScreen extends StatefulWidget {
  const ChildrenNotInSchoolScreen({super.key});

  @override
  _ChildrenNotInSchoolScreenState createState() => _ChildrenNotInSchoolScreenState();
}

class _ChildrenNotInSchoolScreenState extends State<ChildrenNotInSchoolScreen> {
  final TextEditingController boysController = TextEditingController();
  final TextEditingController girlsController = TextEditingController();

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrchardsPlantsScreen()),
    );
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TraditionalOccupationsScreen()),
    );
  }

  Widget _buildChildrenContent() {
    return Column(
      children: [
        QuestionCard(
          question: 'Children Not in School (5-14 years)',
          description: 'Number of children who do not go to school',
          child: Column(
            children: [
              NumberInput(
                label: 'Boys not in school',
                controller: boysController,
                prefixIcon: Icons.boy,
              ),
              SizedBox(height: 15),
              NumberInput(
                label: 'Girls not in school',
                controller: girlsController,
                prefixIcon: Icons.girl,
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
      title: 'Children Not in School',
      stepNumber: 'Step 12',
      nextScreenRoute: '/orchards-plants',
      nextScreenName: 'Orchards/Plants',
      icon: Icons.school,
      instructions: 'Number of children (5 to 14 years) who do not go to school',
      contentWidget: _buildChildrenContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen, 
      onReset: () {
        boysController.clear();
        girlsController.clear();
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    boysController.dispose();
    girlsController.dispose();
    super.dispose();
  }
}
