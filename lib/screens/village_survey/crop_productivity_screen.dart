import 'package:flutter/material.dart';

class CropProductivityScreen extends StatefulWidget {
  @override
  _CropProductivityScreenState createState() => _CropProductivityScreenState();
}

class _CropProductivityScreenState extends State<CropProductivityScreen> {
  List<Map<String, dynamic>> crops = [
    {
      'name': 'Sorghum',
      'area': TextEditingController(),
      'productivity': TextEditingController(),
    },
    {
      'name': 'Pigeon Pea',
      'area': TextEditingController(),
      'productivity': TextEditingController(),
    },
    {
      'name': 'Paddy',
      'area': TextEditingController(),
      'productivity': TextEditingController(),
    },
    {
      'name': 'Wheat',
      'area': TextEditingController(),
      'productivity': TextEditingController(),
    },
    {
      'name': 'Gram',
      'area': TextEditingController(),
      'productivity': TextEditingController(),
    },
    {
      'name': 'Barley',
      'area': TextEditingController(),
      'productivity': TextEditingController(),
    },
    {
      'name': 'Lentil',
      'area': TextEditingController(),
      'productivity': TextEditingController(),
    },
    {
      'name': 'Mustard',
      'area': TextEditingController(),
      'productivity': TextEditingController(),
    },
    {
      'name': 'Linseed',
      'area': TextEditingController(),
      'productivity': TextEditingController(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Productivity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            
            // Title
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '9. Average Crop Productivity (Quintal/acre)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: 20),

            // Table Header
            Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Sr. No',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Crops',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Area (acre)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Productivity (Quintal/acre)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Crop Rows
            Expanded(
              child: ListView.builder(
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  final crop = crops[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text('${index + 1}'),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(crop['name']!),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: TextField(
                              controller: crop['area'],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Acres',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: TextField(
                              controller: crop['productivity'],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Quintal/acre',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    label: Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Validate if all fields are filled
                      bool allFilled = true;
                      for (var crop in crops) {
                        if (crop['area']!.text.isEmpty || crop['productivity']!.text.isEmpty) {
                          allFilled = false;
                          break;
                        }
                      }
                      
                      if (allFilled) {
                        // Save data and navigate to BPL Families screen
                        Navigator.pushNamed(context, '/bpl-families');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill all crop data fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.arrow_forward),
                    label: Text('Next: BPL Families'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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