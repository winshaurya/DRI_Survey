import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../services/supabase_service.dart';
import '../../services/sync_service.dart';
import 'seed_clubs_screen.dart';
import 'social_map_screen.dart';

class SignboardsScreen extends StatefulWidget {
  const SignboardsScreen({super.key});

  @override
  _SignboardsScreenState createState() => _SignboardsScreenState();
}

class _SignboardsScreenState extends State<SignboardsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _signboardsController = TextEditingController();
  final _infoBoardsController = TextEditingController();
  final _wallWritingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final databaseService = Provider.of<DatabaseService>(context, listen: false);
        final sessionId = databaseService.currentSessionId;
        if (sessionId == null) return;

        final rows = await databaseService.getVillageData('village_signboards', sessionId);
        if (rows.isNotEmpty) {
          final row = rows.first;
          _signboardsController.text = (row['signboards'] ?? '') as String;
          _infoBoardsController.text = (row['info_boards'] ?? '') as String;
          _wallWritingController.text = (row['wall_writing'] ?? '') as String;
          setState(() {});
        }
      } catch (e) {
        debugPrint('Error loading signboards data: $e');
      }
    });
  }

  Future<void> _submitForm() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final sessionId = databaseService.currentSessionId;

    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No active session found')),
      );
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

    final data = {
      'id': const Uuid().v4(),
      'session_id': sessionId,
      'signboard_type': '',
      'location': '',
      'signboards': _signboardsController.text,
      'info_boards': _infoBoardsController.text,
      'wall_writing': _wallWritingController.text,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await databaseService.insertOrUpdate('village_signboards', data, sessionId);

      await databaseService.markVillagePageCompleted(sessionId, 7);
      unawaited(SyncService.instance.syncVillagePageData(sessionId, 7, data));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SocialMapScreen()),
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
      MaterialPageRoute(builder: (context) => const SeedClubsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(children: [
        // Header - compact (Govt/platform labels removed)
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: Colors.white,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Signboards', 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF003366)
              ),
            ),
          ),
          ),

        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12), // Reduced padding
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Header - Made more compact
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12), // Reduced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.info, color: Color(0xFF800080), size: 22),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Signboards & Information', 
                                style: TextStyle(
                                  fontSize: 16, // Reduced font size
                                  fontWeight: FontWeight.w700, 
                                  color: Color(0xFF800080)
                                )
                              ),
                            ),
                          ]),
                          SizedBox(height: 4),
                          Text('Step 8: Availability of signboards',
                            style: TextStyle(
                              fontSize: 13, // Reduced font size
                              color: Colors.grey.shade600,
                            )
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16), // Reduced spacing

                  // Input Fields - Now smaller
                  _buildInputField(
                    label: 'Signboards',
                    controller: _signboardsController,
                    hint: 'Direction boards, name boards, etc.',
                    icon: Icons.signpost,
                  ),

                  SizedBox(height: 12), // Reduced spacing

                  _buildInputField(
                    label: 'Information Boards',
                    controller: _infoBoardsController,
                    hint: 'Government schemes, announcements, etc.',
                    icon: Icons.newspaper,
                  ),

                  SizedBox(height: 12), // Reduced spacing

                  _buildInputField(
                    label: 'Wall-writing',
                    controller: _wallWritingController,
                    hint: 'Paintings, slogans, messages on walls',
                    icon: Icons.draw,
                  ),

                  SizedBox(height: 20),

                  // Buttons - Previous and Continue - Made more compact
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _goToPreviousScreen,
                          icon: Icon(Icons.arrow_back, size: 18),
                          label: Text('Previous',
                            style: TextStyle(fontSize: 13)
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12), // Reduced
                            side: BorderSide(color: Color(0xFF800080)),
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Reduced spacing
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _submitForm,
                        icon: Icon(Icons.done, size: 18),
                        label: Text('Save & Continue',
                            style: TextStyle(fontSize: 13)
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF800080),
                            padding: EdgeInsets.symmetric(vertical: 12), // Reduced
                          ),
                        ),
                      ),
                    ]),
                  ),

                  // Removed: Navigation Info Container
                  
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(10), // Reduced from 12
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6), // More compact
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, 
            style: TextStyle(
              fontSize: 13, // Reduced from 14
              fontWeight: FontWeight.w600
            )
          ),
          SizedBox(height: 6), // Reduced from 8
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '$hint (leave empty for zero)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4), // More compact
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10, // Reduced from 12
                vertical: 10   // Reduced from 12
              ),
              prefixIcon: Icon(icon, size: 18), // Smaller icon
              helperText: 'Optional - empty means zero',
              helperStyle: TextStyle(
                fontSize: 11, // Smaller helper text
                color: Colors.grey.shade600,
              ),
            ),
            style: TextStyle(fontSize: 13), // Smaller input text
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _signboardsController.dispose();
    _infoBoardsController.dispose();
    _wallWritingController.dispose();
    super.dispose();
  }
}
