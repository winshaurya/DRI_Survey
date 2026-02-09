// completion_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../database/database_helper.dart';
import '../../services/sync_service.dart';
import 'village_survey_preview_page.dart';

class CompletionScreen extends StatelessWidget {
  const CompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF800080),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 60, color: Colors.white),
            ),
            SizedBox(height: 30),
            Text(
              'Data Collection Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF800080),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Government of India',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Digital India',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF9933),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Power To Empower',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF138808),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Thank you for your valuable contribution to village data collection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final databaseService = Provider.of<DatabaseService>(context, listen: false);
                        final syncService = SyncService.instance;
                        final sessionId = databaseService.currentSessionId;

                        if (sessionId != null) {
                          await databaseService.updateVillageSurveyStatus(sessionId, 'completed');
                          await syncService.syncVillageSurveyToSupabase(sessionId);

                          // Get the shine_code from the session
                          final session = await databaseService.getVillageSurveySession(sessionId);
                          final shineCode = session?['shine_code'] as String?;

                          if (shineCode != null) {
                            // Navigate to preview page instead of home
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => VillageSurveyPreviewPage(
                                  shineCode: shineCode,
                                  fromHistory: false,
                                  showSubmitButton: true, // Show submit button from survey flow
                                ),
                              ),
                            );
                            return;
                          }
                        }
                      } catch (e) {
                        print('Error loading preview: $e');
                      }

                      // Fallback to home if anything fails
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF800080),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    icon: Icon(Icons.preview),
                    label: Text('View Survey'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
