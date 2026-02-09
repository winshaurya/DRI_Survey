import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../services/sync_service.dart';
import 'social_map_screen.dart';
import 'detailed_map_screen.dart';

class SurveyDetailsScreen extends StatefulWidget {
  const SurveyDetailsScreen({super.key});

  @override
  _SurveyDetailsScreenState createState() => _SurveyDetailsScreenState();
}

class _SurveyDetailsScreenState extends State<SurveyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Categories with details controllers
  final List<Map<String, dynamic>> surveyCategories = [
    {'category': 'Forest', 'controller': TextEditingController(), 'icon': Icons.park},
    {'category': 'Wasteland', 'controller': TextEditingController(), 'icon': Icons.landscape},
    {'category': 'Garden/Orchard', 'controller': TextEditingController(), 'icon': Icons.nature},
    {'category': 'Burial Ground', 'controller': TextEditingController(), 'icon': Icons.terrain},
    {'category': 'Crop Plants', 'controller': TextEditingController(), 'icon': Icons.grass},
    {'category': 'Vegetables', 'controller': TextEditingController(), 'icon': Icons.eco},
    {'category': 'Fruit Trees', 'controller': TextEditingController(), 'icon': Icons.apple},
    {'category': 'Animals', 'controller': TextEditingController(), 'icon': Icons.pets},
    {'category': 'Birds', 'controller': TextEditingController(), 'icon': Icons.emoji_nature},
    {'category': 'Local Biodiversity', 'controller': TextEditingController(), 'icon': Icons.biotech},
    {'category': 'Traditional Knowledge', 'controller': TextEditingController(), 'icon': Icons.history_edu},
    {'category': 'Special Features', 'controller': TextEditingController(), 'icon': Icons.star},
  ];

  Future<void> _submitForm() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final sessionId = databaseService.currentSessionId;

    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No active session found')),
      );
      return;
    }

    // Helper to get text from controller found in list of maps
    String getDetails(String category) {
      final item = surveyCategories.firstWhere((element) => element['category'] == category, orElse: () => {'controller': TextEditingController()});
      return (item['controller'] as TextEditingController).text;
    }

    final data = {
      'id': const Uuid().v4(),
      'session_id': sessionId,
      'forest_details': getDetails('Forest'),
      'wasteland_details': getDetails('Wasteland'),
      'garden_details': getDetails('Garden/Orchard'),
      'burial_ground_details': getDetails('Burial Ground'),
      'crop_plants_details': getDetails('Crop Plants'),
      'vegetables_details': getDetails('Vegetables'),
      'fruit_trees_details': getDetails('Fruit Trees'),
      'animals_details': getDetails('Animals'),
      'birds_details': getDetails('Birds'),
      'local_biodiversity_details': getDetails('Local Biodiversity'),
      'traditional_knowledge_details': getDetails('Traditional Knowledge'),
      'special_features_details': getDetails('Special Features'),
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await databaseService.insertOrUpdate('village_survey_details', data, sessionId);

      await databaseService.markVillagePageCompleted(sessionId, 9);
      unawaited(SyncService.instance.syncVillagePageData(sessionId, 9, data));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailedMapScreen()),
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
      MaterialPageRoute(builder: (context) => SocialMapScreen()),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> item) {
    TextEditingController controller = item['controller'];
    IconData icon = item['icon'];
    String category = item['category'];

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF800080).withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Color(0xFF800080)),
                SizedBox(width: 8),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF800080),
                  ),
                ),
              ],
            ),
          ),
          
          // Details Input
          Padding(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Details',
                hintText: 'Enter details (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
              style: TextStyle(fontSize: 12),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(children: [
        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Form Header
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.assignment, color: Color(0xFF800080), size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Survey Details', style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF800080)
                              )),
                            ),
                          ]),
                          SizedBox(height: 4),
                          Text('Step 10: Survey information and remarks'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Instructions
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade800, size: 14),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Fill multiple entries comma separated',
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15),

                  // Category List
                  ...surveyCategories.map((item) => _buildCategoryItem(item)),

                  SizedBox(height: 20),

                  // Buttons - Previous and Continue
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _goToPreviousScreen,
                        icon: Icon(Icons.arrow_back, size: 16),
                        label: Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Color(0xFF800080)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: Icon(Icons.arrow_forward, size: 16),
                        label: Text('Save & Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF800080),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ]),

                  // Removed: Navigation Info Container
                  
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
    for (var item in surveyCategories) {
      item['controller'].dispose();
    }
    super.dispose();
  }
}
