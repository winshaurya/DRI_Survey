import 'package:flutter/material.dart';
import 'survey_details_screen.dart';
import 'forest_map_screen.dart';

class DetailedMapScreen extends StatefulWidget {
  const DetailedMapScreen({super.key});

  @override
  _DetailedMapScreenState createState() => _DetailedMapScreenState();
}

class _DetailedMapScreenState extends State<DetailedMapScreen> {
  final List<MapPoint> _mapPoints = [];
  MapPoint? _selectedPoint;
  int _pointCounter = 1;

  final List<String> _categories = [
    'Forest', 'Wasteland', 'Garden/Orchard', 'Burial Ground/Crematory',
    'Crop Plants', 'Vegetables', 'Fruit Trees', 'Trees', 'Plants',
    'Medicinal Plants', 'Herbs', 'Animals', 'Birds', 'Insects',
    'Micro Flora', 'Micro Fauna', 'Traditional Collection Areas for MFPs',
    'TK on above', 'Local Biodiversity Hotspots', 'Other biological significant areas',
    'Local Endemic and Endangered Species', 'Lifescape diversity', 'Knowledge',
    'Special features like local rituals', 'Ecological History of Area', 'Others'
  ];

  void _addPoint(Offset position) {
    setState(() {
      _selectedPoint = MapPoint(
        id: _pointCounter++,
        position: position,
        category: _categories.first,
        remarks: '',
      );
      _mapPoints.add(_selectedPoint!);
    });
  }

  void _deletePoint(MapPoint point) {
    setState(() {
      _mapPoints.remove(point);
      if (_selectedPoint?.id == point.id) _selectedPoint = null;
    });
  }

  void _saveAndContinue() {
    // Navigate directly to next screen without showing dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ForestMapScreen()),
    );
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SurveyDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: Column(
              children: [
                Text('Government of India', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                SizedBox(height: 4),
                Text('Digital India', style: TextStyle(fontSize: 14, color: Color(0xFFFF9933), fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // Title
          Card(
            margin: EdgeInsets.all(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.map_outlined, color: Color(0xFF800080)),
                    SizedBox(width: 10),
                    Text('Village Map Points', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF800080))),
                  ]),
                  SizedBox(height: 8),
                  Text('Step 29: Add points with categories and remarks'),
                  SizedBox(height: 8),
                  Row(children: [
                    Text('Points: ${_mapPoints.length}', style: TextStyle(fontWeight: FontWeight.w600)),
                    Spacer(),
                    if (_selectedPoint != null)
                      OutlinedButton(
                        onPressed: () => _deletePoint(_selectedPoint!),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red)),
                        child: Text('Delete Selected', style: TextStyle(color: Colors.red)),
                      ),
                  ]),
                ],
              ),
            ),
          ),

          // Map Area
          Expanded(
            child: GestureDetector(
              onTapDown: (details) => _addPoint(details.localPosition),
              child: Container(
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Stack(
                  children: [
                    // Grid background
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/map_background.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken),
                        ),
                      ),
                    ),
                    
                    // Points
                    ..._mapPoints.map((point) => Positioned(
                      left: point.position.dx - 15,
                      top: point.position.dy - 15,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPoint = point),
                        child: Container(
                          width: 30,
                          height: 30,
                          child: Stack(
                            children: [
                              Icon(Icons.location_on, color: _selectedPoint?.id == point.id ? Colors.red : Colors.blue, size: 30),
                              Center(child: Text('${point.id}', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                      ),
                    )),
                    
                    // Instructions
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.black54,
                        child: Text('Tap anywhere to add a point', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Point Editor
          if (_selectedPoint != null)
            Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Point #${_selectedPoint!.id}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                        IconButton(icon: Icon(Icons.close), onPressed: () => setState(() => _selectedPoint = null), iconSize: 20),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text('Category', style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                      child: DropdownButton<String>(
                        value: _selectedPoint!.category,
                        isExpanded: true,
                        items: _categories.map((category) => DropdownMenuItem(value: category, child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text(category)))).toList(),
                        onChanged: (value) => setState(() => _selectedPoint!.category = value!),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('Remarks', style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    TextField(
                      onChanged: (value) => setState(() => _selectedPoint!.remarks = value),
                      decoration: InputDecoration(hintText: 'Enter remarks...', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

          // Navigation
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _goToPreviousScreen,
                    icon: Icon(Icons.arrow_back),
                    label: Text('Previous'),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Color(0xFF800080))),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveAndContinue,
                    icon: Icon(Icons.arrow_forward),
                    label: Text('Save & Continue'),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080), padding: EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapPoint {
  final int id;
  final Offset position;
  String category;
  String remarks;

  MapPoint({
    required this.id,
    required this.position,
    required this.category,
    required this.remarks,
  });
}