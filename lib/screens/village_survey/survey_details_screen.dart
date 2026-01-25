import 'package:flutter/material.dart';
import 'social_map_screen.dart';
import 'detailed_map_screen.dart';

class SurveyDetailsScreen extends StatefulWidget {
  const SurveyDetailsScreen({super.key});

  @override
  _SurveyDetailsScreenState createState() => _SurveyDetailsScreenState();
}

class _SurveyDetailsScreenState extends State<SurveyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Categories with remarks controllers
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

  void _submitForm() {
    // Navigate directly to next screen without showing dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DetailedMapScreen()),
    );
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
              color: Color(0xFF800080).withOpacity(0.1),
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
          
          // Remarks Input
          Padding(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Remarks',
                hintText: 'Enter remarks (optional)',
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
        // Compact Header
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          color: Colors.white,
          child: Column(children: [
            Text('Government of India', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF003366)
            )),
            SizedBox(height: 4),
            Text('Digital India', style: TextStyle(
              fontSize: 12, color: Color(0xFFFF9933), fontWeight: FontWeight.w600
            )),
          ]),
        ),

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
                          Text('Step 28: Survey information and remarks'),
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
                            'Add optional remarks for each category. Leave blank if no remarks.',
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
