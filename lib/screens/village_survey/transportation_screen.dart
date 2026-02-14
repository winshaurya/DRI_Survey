import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../services/supabase_service.dart';
import '../../services/sync_service.dart';
import '../../form_template.dart';
import 'irrigation_facilities_screen.dart'; // Import the previous screen

class TransportationScreen extends StatefulWidget {
  const TransportationScreen({super.key});

  @override
  _TransportationScreenState createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  final Map<String, TextEditingController> vehicles = {
    'Tractor': TextEditingController(),
    'Car/Jeep': TextEditingController(),
    'Motorcycle/Scooter': TextEditingController(),
    'Cycle': TextEditingController(),
    'E-rickshaw': TextEditingController(),
    'Pick-up/Truck': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final databaseService = Provider.of<DatabaseService>(context, listen: false);
        final sessionId = databaseService.currentSessionId;
        if (sessionId == null) return;

        final rows = await databaseService.getVillageData('village_transport_facilities', sessionId);
        if (rows.isNotEmpty) {
          final row = rows.first;
          vehicles['Tractor']?.text = (row['tractor_count'] ?? '').toString();
          vehicles['Car/Jeep']?.text = (row['car_jeep_count'] ?? '').toString();
          vehicles['Motorcycle/Scooter']?.text = (row['motorcycle_scooter_count'] ?? '').toString();
          vehicles['Cycle']?.text = (row['cycle_count'] ?? '').toString();
          vehicles['E-rickshaw']?.text = (row['e_rickshaw_count'] ?? '').toString();
          vehicles['Pick-up/Truck']?.text = (row['pickup_truck_count'] ?? '').toString();
          setState(() {});
        }
      } catch (e) {
        debugPrint('Error loading transport data: $e');
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
      'road_connectivity': 0,
      'public_transport_available': 0,
      'tractor_count': int.tryParse(vehicles['Tractor']?.text ?? '') ?? 0,
      'car_jeep_count': int.tryParse(vehicles['Car/Jeep']?.text ?? '') ?? 0,
      'motorcycle_scooter_count': int.tryParse(vehicles['Motorcycle/Scooter']?.text ?? '') ?? 0,
      'cycle_count': int.tryParse(vehicles['Cycle']?.text ?? '') ?? 0,
      'e_rickshaw_count': int.tryParse(vehicles['E-rickshaw']?.text ?? '') ?? 0,
      'pickup_truck_count': int.tryParse(vehicles['Pick-up/Truck']?.text ?? '') ?? 0,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await databaseService.insertOrUpdate('village_transport_facilities', data, sessionId);

      await databaseService.markVillagePageCompleted(sessionId, 14);
      unawaited(SyncService.instance.syncVillagePageData(sessionId, 14, data));

      if (mounted) {
        Navigator.pop(context);
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

  Widget _buildTransportationContent() {
    return Column(
      children: [
        // Vehicles Table
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF800080),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Vehicle Type',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Count',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Vehicle Rows
                ...vehicles.entries.map((entry) => Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: entry.value,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Color(0xFF800080), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              // No prefixIcon - empty field ready for numbers
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Numbers only';
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'Transportation Facilities',
      stepNumber: 'Step 17',
      nextScreenRoute: '/village-form',
      nextScreenName: 'Village Information',
      icon: Icons.directions_car,
      instructions: 'Enter number of vehicles available in the village',
      contentWidget: _buildTransportationContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen,
      onReset: () {
        setState(() {
          vehicles.forEach((_, controller) => controller.clear());
        });
      },
    );
  }

  @override
  void dispose() {
    vehicles.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
