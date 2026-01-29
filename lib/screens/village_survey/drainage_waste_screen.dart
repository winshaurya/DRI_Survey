import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../form_template.dart';
import 'educational_facilities_screen.dart';
import 'irrigation_facilities_screen.dart';

class DrainageWasteScreen extends StatefulWidget {
  const DrainageWasteScreen({super.key});

  @override
  State<DrainageWasteScreen> createState() => _DrainageWasteScreenState();
}

class _DrainageWasteScreenState extends State<DrainageWasteScreen> {
  final TextEditingController drainageRemarksController = TextEditingController();
  final TextEditingController wasteRemarksController = TextEditingController();

  String? _selectedDrainageType;
  bool _hasWasteCollection = false;
  bool _hasWasteSegregation = false;

  List<String> _getDrainageOptions(AppLocalizations l10n) {
    return [
      l10n.earthenDrain,
      l10n.masonryDrain,
      l10n.coveredDrain,
      l10n.openChannel,
      l10n.noDrainageSystem,
    ];
  }

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IrrigationFacilitiesScreen()),
    );
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EducationalFacilitiesScreen()),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedDrainageType = null;
      _hasWasteCollection = false;
      _hasWasteSegregation = false;
    });
    drainageRemarksController.clear();
    wasteRemarksController.clear();
  }

  Widget _buildDrainageContent() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        QuestionCard(
          question: l10n.typeOfDrainageSystem,
          description: l10n.selectTheDrainageSystemAvailableInTheVillage,
          child: Column(
            children: [
              DropdownInput(
                label: l10n.drainageSystemType,
                value: _selectedDrainageType,
                items: _getDrainageOptions(l10n),
                prefixIcon: Icons.water_damage_outlined,
                onChanged: (value) {
                  setState(() {
                    _selectedDrainageType = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              TextInput(
                label: l10n.remarksOptional,
                controller: drainageRemarksController,
                prefixIcon: Icons.note_alt_outlined,
                isRequired: false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        QuestionCard(
          question: l10n.wasteAndSanitation,
          description: l10n.optionalDetailsAboutCollectionAndSegregation,
          child: Column(
            children: [
              RadioOptionGroup(
                label: l10n.isWasteCollectedRegularly,
                options: [l10n.yes, l10n.no],
                selectedValue: _hasWasteCollection ? l10n.yes : l10n.no,
                onChanged: (value) {
                  setState(() {
                    _hasWasteCollection = value == l10n.yes;
                  });
                },
              ),
              const SizedBox(height: 12),
              RadioOptionGroup(
                label: l10n.isWasteSegregated,
                options: [l10n.yes, l10n.no],
                selectedValue: _hasWasteSegregation ? l10n.yes : l10n.no,
                onChanged: (value) {
                  setState(() {
                    _hasWasteSegregation = value == l10n.yes;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextInput(
                label: l10n.remarksOptional,
                controller: wasteRemarksController,
                prefixIcon: Icons.comment_bank_outlined,
                isRequired: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormTemplateScreen(
      title: l10n.drainageSystem,
      stepNumber: l10n.step5,
      instructions: l10n.recordTheTypeOfDrainageSystemAndRelatedWasteHandling,
      contentWidget: _buildDrainageContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen,
      onReset: _resetForm,
      nextScreenRoute: '/irrigation-facilities',
      nextScreenName: l10n.availableIrrigationFacilities,
      icon: Icons.water_damage,
    );
  }

  @override
  void dispose() {
    drainageRemarksController.dispose();
    wasteRemarksController.dispose();
    super.dispose();
  }
}
