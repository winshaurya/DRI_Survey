import 'package:flutter/material.dart';
import '../table_template.dart';
import 'drainage_waste_screen.dart';

class CropProductivityScreen extends StatefulWidget {
  const CropProductivityScreen({super.key});

  @override
  _CropProductivityScreenState createState() => _CropProductivityScreenState();
}

class _CropProductivityScreenState extends State<CropProductivityScreen> {
  final List<Map<String, dynamic>> crops = [
    {'name': 'Sorghum', 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': 'Pigeon Pea', 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': 'Paddy', 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': 'Wheat', 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': 'Gram', 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': 'Barley', 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': 'Lentil', 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': 'Mustard', 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': 'Linseed', 'area': TextEditingController(), 'productivity': TextEditingController()},
  ];

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DrainageWasteScreen()),
    );
  }

  Widget _buildCropContent() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('Crop', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Area (acres)', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Productivity', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            
            SizedBox(height: 10),
            
            ...crops.map((crop) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(child: Text(crop['name']!)),
                  Expanded(
                    child: TextFormField(
                      controller: crop['area'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: 'Acres', border: OutlineInputBorder()),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: crop['productivity'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: 'Quintal/acre', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TemplateScreen(
      title: 'Crop Productivity',
      stepNumber: 'Step 9',
      nextScreenRoute: '/bpl-families',
      nextScreenName: 'BPL Families',
      icon: Icons.grass,
      instructions: 'Enter area in acres and productivity in quintal/acre for each crop',
      contentWidget: _buildCropContent(),
      onBack: _goToPreviousScreen, // ✅ Add this line
    );
  }

  @override
  void dispose() {
    for (var crop in crops) {
      crop['area']!.dispose();
      crop['productivity']!.dispose();
    }
    super.dispose();
  }
}