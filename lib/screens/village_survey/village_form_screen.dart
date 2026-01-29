import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../data/india_states_districts.dart';
import '../../data/shine_villages.dart';
import '../../form_template.dart';
import '../../services/location_service.dart';
import 'infrastructure_screen.dart';
import '../family_survey/widgets/side_navigation.dart';

class VillageFormScreen extends StatefulWidget {
  const VillageFormScreen({super.key});

  @override
  _VillageFormScreenState createState() => _VillageFormScreenState();
}

class _VillageFormScreenState extends State<VillageFormScreen> {
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

  String selectedState = '';
  String selectedDistrict = '';
  bool _isLoadingLocation = false;
  bool _locationFetched = false;

  // State/district options (loaded from static map)
  Map<String, List<String>> stateDistrictData = {};
  List<String> availableDistricts = [];
  List<String> stateOptions = [];

  @override
  void initState() {
    super.initState();
    _loadStateDistrictData();
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

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InfrastructureScreen()),
    );
  }

  // SIMPLE BACK FUNCTION
  void _goBack() {
    Navigator.pop(context);
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

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData = await LocationService.getCompleteLocationData();

      if (locationData != null && mounted) {
        setState(() {
          _locationFetched = true;
          _latitude = locationData['latitude'];
          _longitude = locationData['longitude'];

        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location coordinates captured successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
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
        // 1. Coordinates (First Question)
        QuestionCard(
          question: l10n.locationCoordinates,
          description: l10n.captureGpsCoordinates,
          child: Column(
            children: [
              if (_locationFetched && _latitude != null && _longitude != null)
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