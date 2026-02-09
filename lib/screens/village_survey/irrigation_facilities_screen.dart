import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../services/sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../form_template.dart';
import 'seed_clubs_screen.dart';
import 'drainage_waste_screen.dart';

class IrrigationFacilitiesScreen extends StatefulWidget {
  const IrrigationFacilitiesScreen({super.key});

  @override
  _IrrigationFacilitiesScreenState createState() => _IrrigationFacilitiesScreenState();
}

class _IrrigationFacilitiesScreenState extends State<IrrigationFacilitiesScreen> {
  // Yes/No states for each facility
  bool? _hasCanal;
  bool? _hasTubeWell;
  bool? _hasPonds;
  bool? _hasRiver;
  bool? _hasWell;

  Future<void> _submitForm() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final sessionId = databaseService.currentSessionId;

    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No active session found')),
      );
      return;
    }

    final data = {
      'id': const Uuid().v4(),
      'session_id': sessionId,
      'has_canal': _hasCanal == true ? 1 : 0,
      'has_tube_well': _hasTubeWell == true ? 1 : 0,
      'has_ponds': _hasPonds == true ? 1 : 0,
      'has_river': _hasRiver == true ? 1 : 0,
      'has_well': _hasWell == true ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      // 1. Save to SQLite
      await databaseService.insertOrUpdate('village_irrigation_facilities', data, sessionId);
      print('Saved irrigation facilities to SQLite');

      await databaseService.markVillagePageCompleted(sessionId, 5);
      unawaited(SyncService.instance.syncVillagePageData(sessionId, 5, data));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SeedClubsScreen()),
        );
      }
    } catch (e) {
      print('Error saving data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DrainageWasteScreen()),
    );
  }

  Widget _buildYesNoOption(String label, bool? value, Function(bool?) onChanged) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded( // FIX: Wrap the button in Expanded at Row level
                child: _buildOptionButton(l10n.yes, value == true, () => onChanged(true)),
              ),
              SizedBox(width: 12),
              Expanded( // FIX: Wrap the button in Expanded at Row level
                child: _buildOptionButton(l10n.no, value == false, () => onChanged(false)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
            ? (text == 'Yes' ? Colors.green.shade100 : Colors.red.shade100)
            : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
              ? (text == 'Yes' ? Colors.green : Colors.red)
              : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected 
                ? (text == 'Yes' ? Colors.green.shade800 : Colors.red.shade800)
                : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIrrigationContent() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Facilities List
        QuestionCard(
          question: l10n.availableIrrigationFacilities,
          description: l10n.selectYesOrNoForEachFacility,
          child: Column(
            children: [
              SizedBox(height: 10),

              // Canal
              _buildYesNoOption(
                l10n.canal,
                _hasCanal,
                (value) => setState(() => _hasCanal = value),
              ),

              SizedBox(height: 15),

              // Tube Well/Bore Well
              _buildYesNoOption(
                l10n.tubeWellBoreWell,
                _hasTubeWell,
                (value) => setState(() => _hasTubeWell = value),
              ),

              SizedBox(height: 15),

              // Ponds
              _buildYesNoOption(
                l10n.ponds,
                _hasPonds,
                (value) => setState(() => _hasPonds = value),
              ),

              SizedBox(height: 15),

              // River
              _buildYesNoOption(
                l10n.river,
                _hasRiver,
                (value) => setState(() => _hasRiver = value),
              ),

              SizedBox(height: 15),

              // Well
              _buildYesNoOption(
                l10n.well,
                _hasWell,
                (value) => setState(() => _hasWell = value),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Summary (optional)
        if (_hasCanal != null || _hasTubeWell != null || _hasPonds != null ||
            _hasRiver != null || _hasWell != null)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFE6E6FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF800080).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop, color: Color(0xFF800080), size: 20),
                    SizedBox(width: 8),
                    Text(
                      l10n.selectedFacilities,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF800080),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_hasCanal == true) _buildSelectedChip(l10n.canal, Colors.green),
                    if (_hasTubeWell == true) _buildSelectedChip(l10n.tubeWellBoreWell, Colors.blue),
                    if (_hasPonds == true) _buildSelectedChip(l10n.ponds, Colors.orange),
                    if (_hasRiver == true) _buildSelectedChip(l10n.river, Colors.purple),
                    if (_hasWell == true) _buildSelectedChip(l10n.well, Colors.brown),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormTemplateScreen(
      title: l10n.availableIrrigationFacilities,
      stepNumber: l10n.step6,
      nextScreenRoute: '/seed-clubs',
      nextScreenName: l10n.seedClubs,
      icon: Icons.water,
      instructions: l10n.selectYesOrNoForEachFacility,
      contentWidget: _buildIrrigationContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen,
      onReset: () {
        setState(() {
          _hasCanal = null;
          _hasTubeWell = null;
          _hasPonds = null;
          _hasRiver = null;
          _hasWell = null;
        });
      },
    );
  }
}
