import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/location_service.dart';
import '../../../data/india_states_districts.dart';
import '../../../data/shine_villages.dart';

class LocationPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const LocationPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _isLoadingLocation = false;
  bool _locationFetched = false;

  // Form controllers for auto-fill functionality
  final TextEditingController villageNameController = TextEditingController();
  final TextEditingController panchayatController = TextEditingController();
  final TextEditingController blockController = TextEditingController();
  final TextEditingController tehsilController = TextEditingController();
  final TextEditingController postalAddressController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  // SHINE Code and dropdown state
  String selectedState = '';
  String selectedDistrict = '';
  Map<String, List<String>> stateDistrictData = {};
  List<String> availableDistricts = [];
  List<String> stateOptions = [];

  // Map state
  MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(28.6139, 77.2090); // Default to Delhi
  Location _location = Location();
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadStateDistrictData();
    _initializeLocation();

    // Initialize controllers with existing data
    villageNameController.text = widget.pageData['village_name'] ?? '';
    panchayatController.text = widget.pageData['panchayat'] ?? '';
    blockController.text = widget.pageData['block'] ?? '';
    tehsilController.text = widget.pageData['tehsil'] ?? '';
    postalAddressController.text = widget.pageData['postal_address'] ?? '';
    pinCodeController.text = widget.pageData['pin_code'] ?? '';
  }

  @override
  void dispose() {
    villageNameController.dispose();
    panchayatController.dispose();
    blockController.dispose();
    tehsilController.dispose();
    postalAddressController.dispose();
    pinCodeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LocationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh controllers if pageData updated from parent/db
    if (widget.pageData != oldWidget.pageData) {
      villageNameController.text = widget.pageData['village_name'] ?? '';
      panchayatController.text = widget.pageData['panchayat'] ?? '';
      blockController.text = widget.pageData['block'] ?? '';
      tehsilController.text = widget.pageData['tehsil'] ?? '';
      postalAddressController.text = widget.pageData['postal_address'] ?? '';
      pinCodeController.text = widget.pageData['pin_code'] ?? '';
      
      // Update state/district selection
      if (widget.pageData['state'] != null) {
        selectedState = widget.pageData['state'];
        availableDistricts = Set<String>.from(stateDistrictData[selectedState] ?? []).toList()..sort();
      }
      if (widget.pageData['district'] != null) {
        selectedDistrict = widget.pageData['district'];
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
          widget.pageData['latitude'] = locationData['latitude'];
          widget.pageData['longitude'] = locationData['longitude'];
          widget.pageData['accuracy'] = locationData['accuracy'];
          widget.pageData['location_timestamp'] = locationData['timestamp'];

          // Auto-fill address fields
          if (locationData['village']?.isNotEmpty == true) {
            widget.pageData['village_name'] = locationData['village'];
            villageNameController.text = locationData['village'];
          }
          if (locationData['subLocality']?.isNotEmpty == true) {
            widget.pageData['panchayat'] = locationData['subLocality'];
            panchayatController.text = locationData['subLocality'];
          }
          if (locationData['subAdministrativeArea']?.isNotEmpty == true) {
            widget.pageData['block'] = locationData['subAdministrativeArea'];
            widget.pageData['tehsil'] = locationData['subAdministrativeArea'];
            blockController.text = locationData['subAdministrativeArea'];
            tehsilController.text = locationData['subAdministrativeArea'];
          }
          if (locationData['administrativeArea']?.isNotEmpty == true) {
            widget.pageData['district'] = locationData['administrativeArea'];
            selectedDistrict = locationData['administrativeArea'];
          }
          if (locationData['postalCode']?.isNotEmpty == true) {
            widget.pageData['pin_code'] = locationData['postalCode'];
            pinCodeController.text = locationData['postalCode'];
          }

          _locationFetched = true;
        });

        widget.onDataChanged(widget.pageData);
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
      widget.pageData['state'] = selectedState;
      widget.onDataChanged(widget.pageData);
    });
  }

  void _onDistrictChanged(String? value) {
    setState(() {
      selectedDistrict = value ?? '';
      widget.pageData['district'] = selectedDistrict;
      widget.onDataChanged(widget.pageData);
    });
  }

  void _onShineVillageSelected(ShineVillage shineVillage) {
    setState(() {
      // Update controllers for auto-fill
      villageNameController.text = shineVillage.revenueVillage;
      panchayatController.text = shineVillage.panchayat;
      blockController.text = shineVillage.block;
      tehsilController.text = shineVillage.block; // Using block as tehsil

      // Update pageData
      widget.pageData['shine_code'] = shineVillage.shineCode;
      widget.pageData['village_name'] = shineVillage.revenueVillage;
      widget.pageData['panchayat'] = shineVillage.panchayat;
      widget.pageData['block'] = shineVillage.block;
      widget.pageData['tehsil'] = shineVillage.block; // Using block as tehsil

      // Handle State
      String tempState = shineVillage.state;
      // Handle potential abbreviation mappings or mismatches if needed
      if (tempState == "M.P.") tempState = "Madhya Pradesh";
      if (tempState == "U.P.") tempState = "Uttar Pradesh";

      if (stateDistrictData.containsKey(tempState)) {
        selectedState = tempState;
        availableDistricts = Set<String>.from(stateDistrictData[selectedState] ?? []).toList()..sort();
      } else {
        selectedState = '';
        availableDistricts = [];
      }

      // Handle District
      if (availableDistricts.contains(shineVillage.district)) {
        selectedDistrict = shineVillage.district;
      } else {
        selectedDistrict = '';
      }

      widget.pageData['state'] = selectedState;
      widget.pageData['district'] = selectedDistrict;
      widget.pageData['lgd_code'] = shineVillage.rvLgdCode;
    });

    widget.onDataChanged(widget.pageData);
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
          widget.pageData['latitude'] = locationData['latitude'];
          widget.pageData['longitude'] = locationData['longitude'];
          widget.pageData['accuracy'] = locationData['accuracy'];
          widget.pageData['location_timestamp'] = locationData['timestamp'];

          // Auto-fill address fields
          if (locationData['village']?.isNotEmpty == true) {
            widget.pageData['village_name'] = locationData['village'];
          }
          if (locationData['subLocality']?.isNotEmpty == true) {
            widget.pageData['panchayat'] = locationData['subLocality'];
          }
          if (locationData['subAdministrativeArea']?.isNotEmpty == true) {
            widget.pageData['block'] = locationData['subAdministrativeArea'];
            widget.pageData['tehsil'] = locationData['subAdministrativeArea'];
          }
          if (locationData['administrativeArea']?.isNotEmpty == true) {
            widget.pageData['district'] = locationData['administrativeArea'];
            selectedDistrict = locationData['administrativeArea'];
          }
          // Don't set state from country - country is "India", not a state name
          // The state should be selected manually from the dropdown
          // Pin code should be filled after location is fetched
          if (locationData['postalCode']?.isNotEmpty == true) {
            widget.pageData['pin_code'] = locationData['postalCode'];
          }

          _locationFetched = true;
        });

        widget.onDataChanged(widget.pageData);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with optional location fetching
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.locationInformation,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            IconButton(
              onPressed: _isLoadingLocation ? null : _fetchLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              tooltip: l10n.getCurrentLocation,
            ),
          ],
        ),

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
                  l10n.locationDetectedSuccessfully,
                  style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),



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
  // Removed interactiveFlags as it is not supported in the current version
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
                          _getCurrentLocation().then((_) {
                            if (_locationLoaded) {
                              _mapController.move(_currentLocation, 15.0);
                            }
                          });
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

        // Location Coordinates Display (First Question)
        if (_locationFetched && widget.pageData['latitude'] != null && widget.pageData['longitude'] != null)
          Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Latitude', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    SizedBox(height: 4),
                    Text(widget.pageData['latitude'].toStringAsFixed(6), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.grey[300]),
                Column(
                  children: [
                    Text('Longitude', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    SizedBox(height: 4),
                    Text(widget.pageData['longitude'].toStringAsFixed(6), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),

        // SHINE Code Autocomplete (Second Question)
        LayoutBuilder(
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
                // Set initial value if available
                if (widget.pageData['shine_code']?.isNotEmpty == true && textEditingController.text.isEmpty) {
                  textEditingController.text = widget.pageData['shine_code'];
                }
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'SHINE Code',
                    hintText: 'e.g. SHINE_001',
                    prefixIcon: Icon(Icons.qr_code, color: Color(0xFF800080)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    widget.pageData['shine_code'] = value;
                    widget.onDataChanged(widget.pageData);
                  },
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

        const SizedBox(height: 16),

        // Phone Number Field
        TextFormField(
          initialValue: widget.pageData['phone_number'],
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter 10-digit phone number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          maxLength: 10,
          onSaved: (value) => widget.pageData['phone_number'] = value,
          onChanged: (value) {
            widget.pageData['phone_number'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: villageNameController,
          decoration: InputDecoration(
            labelText: l10n.villageName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => widget.pageData['village_name'] = value,
          onChanged: (value) {
            widget.pageData['village_name'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: panchayatController,
          decoration: InputDecoration(
            labelText: l10n.panchayat,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => widget.pageData['panchayat'] = value,
          onChanged: (value) {
            widget.pageData['panchayat'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),

        const SizedBox(height: 16),

        // Block Field
        TextFormField(
          controller: blockController,
          decoration: InputDecoration(
            labelText: l10n.block,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => widget.pageData['block'] = value,
          onChanged: (value) {
            widget.pageData['block'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),

        const SizedBox(height: 16),

        // Tehsil Field
        TextFormField(
          controller: tehsilController,
          decoration: InputDecoration(
            labelText: 'Tehsil',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSaved: (value) => widget.pageData['tehsil'] = value,
          onChanged: (value) {
            widget.pageData['tehsil'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),

        const SizedBox(height: 16),

        // District Dropdown
        DropdownButtonFormField<String>(
          initialValue: selectedDistrict.isNotEmpty ? selectedDistrict : null,
          decoration: InputDecoration(
            labelText: l10n.district,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.map),
          ),
          items: availableDistricts.map((String district) {
            return DropdownMenuItem<String>(
              value: district,
              child: Text(district),
            );
          }).toList(),
          onChanged: _onDistrictChanged,
        ),

        const SizedBox(height: 16),

        // State Dropdown
        DropdownButtonFormField<String>(
          initialValue: selectedState.isNotEmpty ? selectedState : null,
          decoration: InputDecoration(
            labelText: 'State',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.public),
          ),
          items: stateOptions.map((String state) {
            return DropdownMenuItem<String>(
              value: state,
              child: Text(state),
            );
          }).toList(),
          onChanged: _onStateChanged,
        ),

        const SizedBox(height: 16),

        TextFormField(
          initialValue: widget.pageData['postal_address'],
          decoration: InputDecoration(
            labelText: l10n.postalAddress,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
          onSaved: (value) => widget.pageData['postal_address'] = value,
          onChanged: (value) {
            widget.pageData['postal_address'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          initialValue: widget.pageData['pin_code'],
          decoration: InputDecoration(
            labelText: l10n.pinCode,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => widget.pageData['pin_code'] = value,
          onChanged: (value) {
            widget.pageData['pin_code'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),

      ],
    );
  }
}
