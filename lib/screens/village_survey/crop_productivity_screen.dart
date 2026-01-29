import 'package:flutter/material.dart';
import '../../table_template.dart';
import 'bpl_families_screen.dart';
import 'educational_facilities_screen.dart';

class CropProductivityScreen extends StatefulWidget {
  const CropProductivityScreen({super.key});

  @override
  _CropProductivityScreenState createState() => _CropProductivityScreenState();
}

class _CropProductivityScreenState extends State<CropProductivityScreen> {
  final List<Map<String, dynamic>> crops = [
    {'name': TextEditingController(), 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': TextEditingController(), 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': TextEditingController(), 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': TextEditingController(), 'area': TextEditingController(), 'productivity': TextEditingController()},
    {'name': TextEditingController(), 'area': TextEditingController(), 'productivity': TextEditingController()},
  ];

  final List<String> cropOptions = [
    // Kharif
    'Sorghum', 'Pearlmillet', 'Rice', 'Greengram', 'Blackgram', 'Pigeon pea', 'Sesame', 'Vegetables',
    // Rabi
    'Wheat', 'Barley', 'Chickpea', 'Lentil', 'Mustard', 'Linseed', 'Vegetables',
    // Summer
    'Greengram', 'Blackgram', 'Vegetables',
  ];

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EducationalFacilitiesScreen()),
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
            
            ...crops.asMap().entries.map((entry) {
              final index = entry.key;
              final crop = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: crop['name']!.text.isNotEmpty ? crop['name']!.text : null,
                        decoration: InputDecoration(
                          hintText: 'Select crop',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: cropOptions.map((String cropName) {
                          return DropdownMenuItem<String>(
                            value: cropName,
                            child: Text(cropName),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          crop['name']!.text = value ?? '';
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: crop['area'],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: 'Acres', border: OutlineInputBorder()),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: crop['productivity'],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: 'Quintal/acre', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              );
            }),
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
