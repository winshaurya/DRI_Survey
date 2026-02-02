import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../database/database_helper.dart';
import '../../services/supabase_service.dart';
import 'irrigation_facilities_screen.dart'; // Import the previous screen
import 'signboards_screen.dart';

class SeedClubsScreen extends StatefulWidget {
  const SeedClubsScreen({super.key});

  @override
  _SeedClubsScreenState createState() => _SeedClubsScreenState();
}

class _SeedClubsScreenState extends State<SeedClubsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _seedClubsController = TextEditingController();

  Future<void> _submitForm() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    final sessionId = databaseService.currentSessionId;

    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No active session found')),
      );
      return;
    }

    final int clubsCount = int.tryParse(_seedClubsController.text) ?? 0;

    final data = {
      'id': const Uuid().v4(),
      'session_id': sessionId,
      'clubs_available': clubsCount > 0 ? 1 : 0,
      'total_clubs': clubsCount,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await DatabaseHelper().insert('village_seed_clubs', data);
      await supabaseService.saveVillageData('village_seed_clubs', data);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignboardsScreen()),
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
    // Navigate back to IrrigationFacilitiesScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => IrrigationFacilitiesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          color: Colors.white,
          child: Column(children: [
            Text('Government of India', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF003366)
            )),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Digital India', style: TextStyle(
                  fontSize: 16, color: Color(0xFFFF9933), fontWeight: FontWeight.w600
                )),
                SizedBox(width: 8),
                Text('Power To Empower', style: TextStyle(
                  fontSize: 14, color: Color(0xFF138808), fontStyle: FontStyle.italic
                )),
              ],
            ),
            SizedBox(height: 5),
            Text('Step 7', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF800080)
            )),
          ]),
        ),

        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Header
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.agriculture, color: Color(0xFF800080)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Seed Clubs', style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF800080)
                                  )),
                                  Text('Step 7', style: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade600
                                  )),
                                ],
                              ),
                            ),
                          ]),
                          SizedBox(height: 5),
                          Text('Number of seed clubs in village'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Simple info note
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade800, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Seed clubs: community groups for saving and exchanging traditional seeds',
                            style: TextStyle(fontSize: 13, color: Colors.blue.shade800)),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Input Field
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Number of Seed Clubs', style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF800080)
                        )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _seedClubsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter number (leave empty for zero)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            prefixIcon: Icon(Icons.group, color: Color(0xFF800080)),
                            helperText: 'Optional - empty means zero',
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 25),

                  // Buttons - Previous and Continue
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _goToPreviousScreen,
                        icon: Icon(Icons.arrow_back),
                        label: Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Color(0xFF800080)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: Icon(Icons.done),
                        label: Text('Save & Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF800080),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _seedClubsController.dispose();
    super.dispose();
  }
}
