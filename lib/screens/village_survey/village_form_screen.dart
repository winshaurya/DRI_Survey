import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart' as provider_package;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_service.dart';
import '../../services/supabase_service.dart';
import '../../services/sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../data/india_states_districts.dart';
import '../../data/shine_villages.dart';
import '../../form_template.dart';
import '../../services/location_service.dart';
import '../../providers/village_survey_provider.dart';
import '../family_survey/widgets/side_navigation.dart';
import 'infrastructure_screen.dart';

class VillageFormScreen extends ConsumerStatefulWidget {
  const VillageFormScreen({super.key});

  @override
  ConsumerState<VillageFormScreen> createState() => _VillageFormScreenState();
}

class _VillageFormScreenState extends ConsumerState<VillageFormScreen> {
  // Form controllers
  final TextEditingController villageNameController = TextEditingController();
  final TextEditingController villageCodeController = TextEditingController();
  final TextEditingController blockController = TextEditingController();
  final TextEditingController panchayatController = TextEditingController();
  final TextEditingController tehsilController = TextEditingController();
  final TextEditingController ldgCodeController = TextEditingController();
  final TextEditingController shineCodeController = TextEditingController();
  final TextEditingController praTeamController = TextEditingController();

  // Location Data
  double? _latitude;
  double? _longitude;
  double? _accuracy;
  String? _locationTimestamp;

  String selectedState = '';
  String selectedDistrict = '';
  bool _isLoadingLocation = false;
  bool _locationFetched = false;

  // Map state
  MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(28.6139, 77.2090); // Default to Delhi
  Location _location = Location();
  bool _locationLoaded = false;

  // State/district options (loaded from static map)
  Map<String, List<String>> stateDistrictData = {};
  List<String> availableDistricts = [];
  List<String> stateOptions = [];

  @override
  void initState() {
    super.initState();
    _loadStateDistrictData();

    // Check for existing session first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForExistingSession();
    });

    _initializeLocation();
  }

  Future<void> _checkForExistingSession() async {
    final databaseService = provider_package.Provider.of<DatabaseService>(context, listen: false);
    final sessionId = databaseService.currentSessionId;
    
    if (sessionId != null) {
      try {
        final db = await databaseService.database;
        final List<Map<String, dynamic>> sessions = await db.query(
          'village_survey_sessions',
          where: 'session_id = ?',
          whereArgs: [sessionId],
        );
        
        if (sessions.isNotEmpty) {
          final session = sessions.first;
          setState(() {
            villageNameController.text = session['village_name'] ?? '';
            villageCodeController.text = session['village_code'] ?? '';
            blockController.text = session['block'] ?? '';
            panchayatController.text = session['panchayat'] ?? '';
            tehsilController.text = session['tehsil'] ?? '';
            ldgCodeController.text = session['ldg_code'] ?? '';
            shineCodeController.text = session['shine_code'] ?? '';
            
            selectedState = session['state'] ?? '';
            if (selectedState.isNotEmpty) {
              availableDistricts = Set<String>.from(stateDistrictData[selectedState] ?? []).toList()..sort();
              selectedDistrict = session['district'] ?? '';
            }

            _latitude = session['latitude'];
            _longitude = session['longitude'];
            if (_latitude != null && _longitude != null) {
              _locationFetched = true;
              _currentLocation = LatLng(_latitude!, _longitude!);
            }
          });
        }
      } catch (e) {
        debugPrint('Error loading existing session: $e');
      }
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

  Future<void> _initializeLocation() async {
    // Get current location for map display
    await _getCurrentLocation();

    // Automatically fetch and save location data without user interaction
    try {
      final locationData = await LocationService.getCompleteLocationData();

      if (locationData != null && mounted) {
        setState(() {
          _latitude = locationData['latitude'];
          _longitude = locationData['longitude'];
          _accuracy = locationData['accuracy'];
          _locationTimestamp = locationData['timestamp'];

          // Auto-fill address fields
          if (locationData['village']?.isNotEmpty == true) {
            villageNameController.text = locationData['village'];
          }
          if (locationData['subLocality']?.isNotEmpty == true) {
            panchayatController.text = locationData['subLocality'];
          }
          if (locationData['subAdministrativeArea']?.isNotEmpty == true) {
            blockController.text = locationData['subAdministrativeArea'];
            tehsilController.text = locationData['subAdministrativeArea'];
          }
          if (locationData['administrativeArea']?.isNotEmpty == true) {
            selectedDistrict = locationData['administrativeArea'];
          }

          _locationFetched = true;
        });
      }
    } catch (e) {
      // Silently handle error - location will be fetched manually if needed
    }
  }

  void _loadStateDistrictData() {
    stateDistrictData = Map<String, List<String>>.from(indiaStatesDistricts);
    stateOptions = stateDistrictData.keys.toList()..sort();
    availableDistricts = [];
  }

  void _onStateChanged(String? value) {
    setState(() {
      selectedState = value ?? '';
      selectedDistrict = '';
      availableDistricts = Set<String>.from(stateDistrictData[selectedState] ?? []).toList()..sort();
    });
  }

  void _onDistrictChanged(String? value) {
    setState(() {
      selectedDistrict = value ?? '';
    });
  }

  Future<void> _submitForm() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Get the village survey provider
      final villageSurveyNotifier = ref.read(villageSurveyProvider.notifier);

      // Create session data with form values
      final sessionId = const Uuid().v4();
      final formData = {
        'session_id': sessionId,
        'shine_code': shineCodeController.text,
        'village_name': villageNameController.text.isEmpty ? 'Unknown Village' : villageNameController.text,
        'village_code': villageCodeController.text,
        'state': selectedState,
        'district': selectedDistrict,
        'block': blockController.text,
        'panchayat': panchayatController.text,
        'tehsil': tehsilController.text,
        'ldg_code': ldgCodeController.text,
        'latitude': _latitude,
        'longitude': _longitude,
        'location_accuracy': _accuracy,
        'location_timestamp': _locationTimestamp,
        'status': 'in_progress',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Use the provider to initialize the village survey (this handles surveyor_email)
      await villageSurveyNotifier.initializeVillageSurvey(formData);

      // Mark page 0 as completed and sync immediately
      final currentSessionId = formData['session_id'] as String;
      await provider_package.Provider.of<DatabaseService>(context, listen: false)
          .markVillagePageCompleted(currentSessionId, 0);

      // Sync immediately to Supabase (do not block UI). Fire-and-forget with timeout.
      try {
        unawaited(
          provider_package.Provider.of<SyncService>(context, listen: false)
              .syncVillagePageData(currentSessionId, 0, formData)
              .timeout(const Duration(seconds: 6)),
        );
      } catch (e) {
        debugPrint('❌ Failed to start sync for village survey session $currentSessionId: $e');
      }

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Navigate to next screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InfrastructureScreen()),
        );
      }
    } catch (e) {
      print('Error initializing village survey: $e');
      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating village survey: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveFormData() async {
    final databaseService = provider_package.Provider.of<DatabaseService>(context, listen: false);
    final supabaseService = provider_package.Provider.of<SupabaseService>(context, listen: false);
    final syncService = SyncService.instance;

    // Get current authenticated user email
    final currentUserEmail = supabaseService.currentUser?.email ?? 'unknown';

    // Check if we have an existing session
    final existingSessionId = databaseService.currentSessionId;
    if (existingSessionId == null) {
      // No existing session, create a new one
      final sessionId = const Uuid().v4();

      final sessionData = {
        'session_id': sessionId,
        'village_name': villageNameController.text.isEmpty ? 'Unknown Village' : villageNameController.text,
        'village_code': villageCodeController.text,
        'state': selectedState,
        'district': selectedDistrict,
        'block': blockController.text,
        'panchayat': panchayatController.text,
        'tehsil': tehsilController.text,
        'ldg_code': ldgCodeController.text,
        'shine_code': shineCodeController.text,
        'latitude': _latitude,
        'longitude': _longitude,
        'location_accuracy': _accuracy,
        'location_timestamp': _locationTimestamp,
        'surveyor_email': currentUserEmail,  // ✅ ADD SURVEYOR EMAIL
        'status': 'in_progress',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        await databaseService.createNewVillageSurveySession(sessionData);
        await databaseService.markVillagePageCompleted(sessionId, 0);
        unawaited(syncService.syncVillagePageData(sessionId, 0, sessionData));
      } catch (e) {
        print('Error saving form data: $e');
      }
    } else {
      // Update existing session
      final sessionData = {
        'village_name': villageNameController.text.isEmpty ? 'Unknown Village' : villageNameController.text,
        'village_code': villageCodeController.text,
        'state': selectedState,
        'district': selectedDistrict,
        'block': blockController.text,
        'panchayat': panchayatController.text,
        'tehsil': tehsilController.text,
        'ldg_code': ldgCodeController.text,
        'shine_code': shineCodeController.text,
        'latitude': _latitude,
        'longitude': _longitude,
        'location_accuracy': _accuracy,
        'location_timestamp': _locationTimestamp,
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        final db = await databaseService.database;
        await db.update(
          'village_survey_sessions',
          sessionData,
          where: 'session_id = ?',
          whereArgs: [existingSessionId],
        );
        await databaseService.markVillagePageCompleted(existingSessionId, 0);
        unawaited(syncService.syncVillagePageData(existingSessionId, 0, sessionData));
      } catch (e) {
        print('Error updating form data: $e');
      }
    }
  }

  // SIMPLE BACK FUNCTION
  void _goBack() async {
    final shouldPop = await _onWillPop();
    if (shouldPop && mounted) {
      Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    // Check if any form data has been entered
    final hasData = villageNameController.text.isNotEmpty ||
        villageCodeController.text.isNotEmpty ||
        blockController.text.isNotEmpty ||
        panchayatController.text.isNotEmpty ||
        tehsilController.text.isNotEmpty ||
        ldgCodeController.text.isNotEmpty ||
        shineCodeController.text.isNotEmpty ||
        selectedState.isNotEmpty ||
        selectedDistrict.isNotEmpty ||
        _latitude != null ||
        _longitude != null;

    // If no data entered, allow exit without prompt
    if (!hasData) {
      return true;
    }

    // Show confirmation dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Village Survey'),
        content: const Text(
          'You have unsaved progress. Would you like to save your current village details before leaving?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Don't exit
            child: const Text('Continue Survey'),
          ),
          TextButton(
            onPressed: () async {
              // Save current form data
              await _saveFormData();
              Navigator.of(context).pop(true); // Exit after saving
            },
            child: const Text('Save & Exit'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Exit without saving
            child: const Text('Exit Without Saving'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _resetForm() {
    setState(() {
      villageNameController.clear();
      villageCodeController.clear();
      blockController.clear();
      panchayatController.clear();
      tehsilController.clear();
      ldgCodeController.clear();
      shineCodeController.clear();
      praTeamController.clear();
      selectedState = '';
      selectedDistrict = '';
      availableDistricts = [];
      _locationFetched = false;
      _latitude = null;
      _longitude = null;
    });

    // Also create a fresh in-memory current session so reset acts like "start new"
    try {
      DatabaseService().currentSessionId = const Uuid().v4();
    } catch (_) {}
  }

  void _onShineVillageSelected(ShineVillage shineVillage) {
    setState(() {
      shineCodeController.text = shineVillage.shineCode;
      villageNameController.text = shineVillage.revenueVillage;
      panchayatController.text = shineVillage.panchayat;
      blockController.text = shineVillage.block;
      praTeamController.text = shineVillage.praTeam;
      
      // Handle State
      String tempState = shineVillage.state;
      // Handle potential abbreviation mappings or mismatches if needed
      if (tempState == "M.P.") tempState = "Madhya Pradesh";
      if (tempState == "U.P.") tempState = "Uttar Pradesh";

      if (stateDistrictData.containsKey(tempState)) {
        selectedState = tempState;
        // Ensure unique districts and sort
        availableDistricts = Set<String>.from(stateDistrictData[selectedState] ?? []).toList()..sort();
      } else {
        // If state not found, reset
        selectedState = '';
        availableDistricts = [];
      }

      // Handle District
      if (availableDistricts.contains(shineVillage.district)) {
        selectedDistrict = shineVillage.district;
      } else {
        // Try to handle known data issues or close matches
        // For now, reset if not found in list to prevent errors
        selectedDistrict = '';
        
        // Debug/Fallback: if district is same as state (data error), we clear it.
        // If it was supposed to be Chitrakoot (for U.P.), we can't guess easily without a map.
      }
      
      ldgCodeController.text = shineVillage.rvLgdCode;
    });
  }

  Future<void> _fetchLocation() async {
    if (_locationFetched) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData = await LocationService.getCompleteLocationData();

      if (locationData != null && mounted) {
        setState(() {
          _latitude = locationData['latitude'];
          _longitude = locationData['longitude'];
          _accuracy = locationData['accuracy'];
          _locationTimestamp = locationData['timestamp'];

          // Auto-fill address fields
          if (locationData['village']?.isNotEmpty == true) {
            villageNameController.text = locationData['village'];
          }
          if (locationData['subLocality']?.isNotEmpty == true) {
            panchayatController.text = locationData['subLocality'];
          }
          if (locationData['subAdministrativeArea']?.isNotEmpty == true) {
            blockController.text = locationData['subAdministrativeArea'];
            tehsilController.text = locationData['subAdministrativeArea'];
          }
          if (locationData['administrativeArea']?.isNotEmpty == true) {
            selectedDistrict = locationData['administrativeArea'];
          }

          _locationFetched = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.locationDetectedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToGetLocation(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Widget _buildVillageContent() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // 1. Location with Map (First Question)
        QuestionCard(
          question: l10n.locationCoordinates,
          description: l10n.captureGpsCoordinates,
          child: Column(
            children: [
              // OpenStreetMap Widget (16:9 aspect ratio)
              Container(
                height: MediaQuery.of(context).size.width * 9 / 16, // 16:9 aspect ratio
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentLocation,
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.edu_survey_new',
                          ),
                          MarkerLayer(
                            markers: [
                              if (_locationLoaded)
                                Marker(
                                  point: _currentLocation,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: Stack(
                                      children: [
                                        Icon(Icons.location_on, color: Colors.red, size: 40),
                                        Positioned(
                                          top: 5,
                                          left: 13,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.red, width: 2),
                                            ),
                                            child: Icon(Icons.my_location, color: Colors.red, size: 8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      // Floating Action Button for centering map to current location
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          onPressed: () {
                            if (_locationLoaded) {
                              _mapController.move(_currentLocation, 15.0);
                            } else {
                              _getCurrentLocation().then((_) {
                                if (_locationLoaded) {
                                  _mapController.move(_currentLocation, 15.0);
                                }
                              });
                            }
                          },
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          elevation: 4,
                          mini: true,
                          child: const Icon(Icons.my_location),
                          tooltip: 'Center to my location',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Location Success Indicator
              if (_locationFetched)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16, top: 16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Location detected successfully',
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

              // Location Coordinates Display
              if (_locationFetched && _latitude != null && _longitude != null)
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Latitude', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                          SizedBox(height: 4),
                          Text(_latitude!.toStringAsFixed(6), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.grey[300]),
                      Column(
                        children: [
                          Text('Longitude', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                          SizedBox(height: 4),
                          Text(_longitude!.toStringAsFixed(6), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),

              // Capture Location Button
              ElevatedButton.icon(
                onPressed: _isLoadingLocation ? null : _fetchLocation,
                icon: _isLoadingLocation
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.my_location),
                label: Text(_locationFetched ? 'Update Location' : 'Capture Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _locationFetched ? Colors.green : Color(0xFF800080),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),

        // 2. SHINE Code Autocomplete (Second Question)
        QuestionCard(
          question: 'SHINE Code',
          description: 'Select SHINE Code to auto-fill village details',
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Autocomplete<ShineVillage>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<ShineVillage>.empty();
                  }
                  return ShineVillagesData.villages.where((ShineVillage option) {
                    return option.shineCode.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                displayStringForOption: (ShineVillage option) => option.shineCode,
                onSelected: (ShineVillage selection) {
                  _onShineVillageSelected(selection);
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                   // Keep the local controller in sync with our state controller if needed
                   // But here we use textEditingController for the autocomplete logic
                   // We should update our state controller when this changes or just use this one if we want.
                   // To allow manual entry without selection, we can listen to changes.
                   return TextFormField(
                     controller: textEditingController,
                     focusNode: focusNode,
                     decoration: InputDecoration(
                       labelText: 'Enter/Search SHINE Code',
                       hintText: 'e.g. SHINE_001',
                       prefixIcon: Icon(Icons.qr_code, color: Color(0xFF800080)),
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                       filled: true,
                       fillColor: Colors.white,
                     ),
                   );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: 200.0,
                        child: ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ShineVillage option = options.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Text(option.shineCode, style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${option.revenueVillage}, ${option.district}'), 
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          ),
        ),

        // 3. Village Name
        QuestionCard(
          question: l10n.nameOfVillage,
          description: l10n.officialNameOfVillage,
          child: TextInput(
            label: l10n.enterVillageName,
            controller: villageNameController,
            prefixIcon: Icons.home,
          ),
        ),

        // 4. Village Code (RV LGD Code)
        QuestionCard(
          question: 'LGD Code', // Renaming "Village Code" to "LGD Code" based on user context "RV LGD CODE"
          description: 'Revenue Village LGD Code',
          child: TextInput(
            label: 'Enter LGD Code',
            controller: ldgCodeController,
            prefixIcon: Icons.numbers,
          ),
        ),

        // 5. Panchayat
        QuestionCard(
          question: 'Panchayat',
          description: 'Name of the Panchayat',
          child: TextInput(
            label: 'Enter Panchayat',
            controller: panchayatController,
            prefixIcon: Icons.account_balance,
          ),
        ),

        // 6. Block
        QuestionCard(
          question: 'Block',
          description: 'Name of the Block',
          child: TextInput(
            label: 'Enter Block',
            controller: blockController,
            prefixIcon: Icons.holiday_village,
          ),
        ),

        // 7. Tehsil
        QuestionCard(
          question: 'Tehsil',
          description: 'Name of the Tehsil',
          child: TextInput(
            label: 'Enter Tehsil',
            controller: tehsilController,
            prefixIcon: Icons.location_city,
          ),
        ),

        // 8. District
        QuestionCard(
          question: 'District',
          description: 'Select District',
          child: DropdownInput(
            label: 'Select District',
            value: selectedDistrict,
            items: availableDistricts,
            onChanged: _onDistrictChanged,
            prefixIcon: Icons.map,
            enabled: selectedState.isNotEmpty,
          ),
        ),

        // 9. State
        QuestionCard(
          question: 'State',
          description: 'Select State',
          child: DropdownInput(
            label: 'Select State',
            value: selectedState,
            items: stateOptions,
            onChanged: _onStateChanged,
            prefixIcon: Icons.public,
          ),
        ),

        // 10. PRA Team
        QuestionCard(
          question: 'PRA Team',
          description: 'Names of PRA Team Members',
          child: TextInput(
            label: 'Enter PRA Team Members',
            controller: praTeamController,
            prefixIcon: Icons.group,
          ),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormTemplateScreen(
      title: l10n.villageInformation,
      stepNumber: l10n.step1,
      instructions: l10n.fillVillageDetails,
      contentWidget: _buildVillageContent(),
      onSubmit: _submitForm,
      onBack: _goBack,
      onReset: _resetForm,
      nextScreenRoute: '/infrastructure',
      nextScreenName: 'Infrastructure',
      icon: Icons.info,
      drawer: const SideNavigation(),
    );
  }

  @override
  void dispose() {
    villageNameController.dispose();
    villageCodeController.dispose();
    blockController.dispose();
    panchayatController.dispose();
    tehsilController.dispose();
    ldgCodeController.dispose();
    shineCodeController.dispose();
    praTeamController.dispose();
    super.dispose();
  }
}