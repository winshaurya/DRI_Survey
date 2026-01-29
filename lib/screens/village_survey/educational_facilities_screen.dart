import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../form_template.dart';
import 'infrastructure_availability_screen.dart';
import 'drainage_waste_screen.dart';
import 'irrigation_facilities_screen.dart';

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
      MaterialPageRoute(builder: (context) => const DrainageWasteScreen()),
    );
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => InfrastructureAvailabilityScreen()),
    );
  }

  Widget _buildEducationalContent() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Anganwadi Section
        QuestionCard(
          question: l10n.numberOfAnganwadi,
          description: l10n.anganwadiCenters,
          child: NumberInput(
            label: l10n.enterNumberOfAnganwadi,
            controller: numAnganwadiController,
            prefixIcon: Icons.child_care,
          ),
        ),

        SizedBox(height: 25),

        // Shiksha Guarantee Section
        QuestionCard(
          question: l10n.numberOfShikshaGuarantee,
          description: l10n.shikshaGuaranteeBeneficiaries,
          child: NumberInput(
            label: l10n.enterNumberOfBeneficiaries,
            controller: numShikshaGuaranteeController,
            prefixIcon: Icons.school,
          ),
        ),

        SizedBox(height: 25),

        // Other Facilities Section
        QuestionCard(
          question: l10n.otherEducationalFacilitiesTitle,
          description: l10n.otherEducationalFacilitiesDesc,
          child: Column(
            children: [
              TextInput(
                label: l10n.facilityName,
                controller: otherFacilityNameController,
                prefixIcon: Icons.menu_book,
                isRequired: false,
              ),

              SizedBox(height: 15),

              NumberInput(
                label: l10n.numberOfSuchFacilities,
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
    final l10n = AppLocalizations.of(context)!;
    return FormTemplateScreen(
      title: l10n.educationalFacilities,
      stepNumber: 'Step 4',
      nextScreenRoute: '/drainage-waste',
      nextScreenName: 'Drainage System',
      icon: Icons.school,
      instructions: l10n.otherEducationalFacilities,
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
