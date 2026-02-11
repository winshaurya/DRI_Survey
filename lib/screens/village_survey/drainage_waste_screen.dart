import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../l10n/app_localizations.dart';
import '../../form_template.dart';
import '../../services/database_service.dart';
import '../../services/supabase_service.dart';
import '../../services/sync_service.dart';
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
  final TextEditingController drainIntoController = TextEditingController();

  Map<String, bool> _selectedDrainageTypes = {};
  bool _hasWasteCollection = false;
  bool _hasWasteSegregation = false;

  @override
  void initState() {
    super.initState();
    // Initialize drainage types map
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      final options = _getDrainageOptions(l10n);
      setState(() {
        _selectedDrainageTypes = {for (var option in options) option: false};
      });
    });
  }

  List<String> _getDrainageOptions(AppLocalizations l10n) {
    return [
      l10n.earthenDrain,
      l10n.masonryDrain,
      l10n.coveredDrain,
      l10n.openChannel,
      l10n.noDrainageSystem,
    ];
  }

  Future<void> _submitForm() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final sessionId = databaseService.currentSessionId;

    if (sessionId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No active session found. Please start from Village Form.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Check authentication before syncing
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    final currentUser = supabaseService.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not authenticated. Please login again.')),
        );
      }
      return;
    }

    try {
      // Prepare drainage data
      final drainageData = {
        'id': const Uuid().v4(),
        'session_id': sessionId,
        'drainage_system_available': _selectedDrainageTypes.values.any((selected) => selected) ? 1 : 0,
        'waste_management_system': (_hasWasteCollection || _hasWasteSegregation) ? 1 : 0,
        'earthen_drain': _selectedDrainageTypes[_getDrainageOptions(AppLocalizations.of(context)!) [0]] ?? false ? 1 : 0,
        'masonry_drain': _selectedDrainageTypes[_getDrainageOptions(AppLocalizations.of(context)!) [1]] ?? false ? 1 : 0,
        'covered_drain': _selectedDrainageTypes[_getDrainageOptions(AppLocalizations.of(context)!) [2]] ?? false ? 1 : 0,
        'open_channel': _selectedDrainageTypes[_getDrainageOptions(AppLocalizations.of(context)!) [3]] ?? false ? 1 : 0,
        'no_drainage_system': _selectedDrainageTypes[_getDrainageOptions(AppLocalizations.of(context)!) [4]] ?? false ? 1 : 0,
        'drainage_destination': drainIntoController.text.trim(),
        'drainage_remarks': drainageRemarksController.text.trim(),
        'waste_collected_regularly': _hasWasteCollection ? 1 : 0,
        'waste_segregated': _hasWasteSegregation ? 1 : 0,
        'waste_remarks': wasteRemarksController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      // 1. Save to SQLite
      await databaseService.insertOrUpdate('village_drainage_waste', drainageData, sessionId);

      await databaseService.markVillagePageCompleted(sessionId, 4);
      unawaited(SyncService.instance.syncVillagePageData(sessionId, 4, drainageData));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drainage data saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate to next screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const IrrigationFacilitiesScreen()),
      );
    } catch (e) {
      print('Critical error saving drainage data: $e');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving drainage data locally: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EducationalFacilitiesScreen()),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedDrainageTypes.updateAll((key, value) => false);
      _hasWasteCollection = false;
      _hasWasteSegregation = false;
    });
    drainageRemarksController.clear();
    wasteRemarksController.clear();
    drainIntoController.clear();
  }

  Widget _buildDrainageContent() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        CheckboxList(
          label: l10n.typeOfDrainageSystem,
          description: l10n.selectTheDrainageSystemAvailableInTheVillage,
          items: _selectedDrainageTypes,
          onChanged: (selected) {
            setState(() {
              _selectedDrainageTypes = selected;
            });
          },
        ),

        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextInput(
            label: l10n.remarksOptional,
            controller: drainageRemarksController,
            prefixIcon: Icons.note_alt_outlined,
            isRequired: false,
          ),
        ),

        const SizedBox(height: 20),

        QuestionCard(
          question: 'Where does the drainage drain into?',
          description: 'Specify the destination of the drainage system',
          child: TextInput(
            label: 'Drainage destination',
            controller: drainIntoController,
            prefixIcon: Icons.location_on_outlined,
            isRequired: false,
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
    drainIntoController.dispose();
    super.dispose();
  }
}
