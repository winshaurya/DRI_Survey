import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../database/database_helper.dart';
import '../../services/sync_service.dart';
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
  final TextEditingController _remarksController = TextEditingController();

  MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(28.6139, 77.2090); // Default to Delhi
  Location _location = Location();
  bool _locationLoaded = false;

  final List<String> _categories = [
    'Forest', 'Wasteland', 'Garden/Orchard', 'Burial Ground/Crematory',
    'Crop Plants', 'Vegetables', 'Fruit Trees', 'Trees', 'Plants',
    'Medicinal Plants', 'Herbs', 'Animals', 'Birds', 'Insects',
    'Micro Flora', 'Micro Fauna', 'Traditional Collection Areas for MFPs',
    'TK on above', 'Local Biodiversity Hotspots', 'Other biological significant areas',
    'Local Endemic and Endangered Species', 'Lifescape diversity', 'Knowledge',
    'Special features like local rituals', 'Ecological History of Area', 'Others'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingPoints();
    });
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPoints() async {
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final sessionId = databaseService.currentSessionId;
      if (sessionId == null) return;

      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> maps = await db.query(
        'village_map_points',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'point_id ASC',
      );

      if (maps.isNotEmpty) {
        setState(() {
          _mapPoints.clear();
          for (var map in maps) {
            _mapPoints.add(MapPoint(
              id: map['point_id'] as int,
              position: LatLng(map['latitude'] as double, map['longitude'] as double),
              category: map['category'] as String,
              remarks: map['remarks'] as String? ?? '',
            ));
          }
          if (_mapPoints.isNotEmpty) {
            int maxId = _mapPoints.map((p) => p.id).reduce((curr, next) => curr > next ? curr : next);
            _pointCounter = maxId + 1;
            
            // Set map center to the first point if available
            if (_locationLoaded && _mapPoints.isNotEmpty) {
               // Optional: center map
            }
          }
        });
      }
    } catch (e) {
      print('Error loading points: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }
      LocationData locationData = await _location.getLocation();
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _locationLoaded = true;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _addPoint(LatLng position) {
    setState(() {
      _selectedPoint = MapPoint(
        id: _pointCounter++,
        position: position,
        category: _categories.first,
        remarks: '',
      );
      _mapPoints.add(_selectedPoint!);
      _remarksController.text = _selectedPoint!.remarks;
    });
  }

  void _selectPoint(MapPoint point) {
    setState(() {
      _selectedPoint = point;
      _remarksController.text = point.remarks;
    });
  }

  void _deletePoint(MapPoint point) {
    setState(() {
      _mapPoints.remove(point);
      if (_selectedPoint?.id == point.id) {
        _selectedPoint = null;
        _remarksController.clear();
      }
    });
  }

  Future<void> _saveAndContinue() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final syncService = SyncService.instance;
    final sessionId = databaseService.currentSessionId;

    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No active session found')),
      );
      return;
    }

    try {
      // Clear existing points for this session to avoid duplicates
      final db = await DatabaseHelper().database;
      await db.delete('village_map_points', where: 'session_id = ?', whereArgs: [sessionId]);

      // 1. Save all points
      final List<Map<String, dynamic>> pointsPayload = [];
      for (var point in _mapPoints) {
        final data = {
          'id': const Uuid().v4(),
          'session_id': sessionId,
          'latitude': point.position.latitude,
          'longitude': point.position.longitude,
          'category': point.category,
          'remarks': point.remarks,
          'point_id': point.id,
          'created_at': DateTime.now().toIso8601String(),
        };

        await DatabaseHelper().insert('village_map_points', data);
        pointsPayload.add(data);
      }

      await databaseService.markVillagePageCompleted(sessionId, 10);
      unawaited(syncService.syncVillagePageData(sessionId, 10, {'map_points': pointsPayload}));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForestMapScreen()),
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
      MaterialPageRoute(builder: (context) => SurveyDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [


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
                  Text('Step 11: Add points with categories and remarks'),
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
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentLocation,
                    zoom: 15.0,
                    onTap: (tapPosition, point) => _addPoint(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.edu_survey_new',
                    ),
                    MarkerLayer(
                      markers: [
                        // Current location marker
                        if (_locationLoaded)
                          Marker(
                            point: _currentLocation,
                            child: Icon(Icons.my_location, color: Colors.blue, size: 30),
                          ),
                        // Points markers
                        ..._mapPoints.map((point) => Marker(
                          point: point.position,
                          child: GestureDetector(
                            onTap: () => _selectPoint(point),
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
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: "btn_location",
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                       _mapController.move(_currentLocation, 15.0);
                    },
                    child: Icon(Icons.my_location, color: Colors.blue),
                  ),
                ),
              ],
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
                      controller: _remarksController,
                      onChanged: (value) {
                         if (_selectedPoint != null) {
                           _selectedPoint!.remarks = value;
                         }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter remarks...', 
                        border: OutlineInputBorder(), 
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                      ),
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
  final LatLng position;
  String category;
  String remarks;

  MapPoint({
    required this.id,
    required this.position,
    required this.category,
    required this.remarks,
  });
}
