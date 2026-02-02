import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' hide TextInput;
import '../form_template.dart';
import 'population_form_screen.dart';

class VillageFormScreen extends StatefulWidget {
  const VillageFormScreen({super.key});

  @override
  _VillageFormScreenState createState() => _VillageFormScreenState();
}

class _VillageFormScreenState extends State<VillageFormScreen> {
  // Form controllers
  final TextEditingController villageNameController = TextEditingController();
  final TextEditingController villageCodeController = TextEditingController();
  final TextEditingController gpsLinkController = TextEditingController();
  final TextEditingController blockController = TextEditingController();
  final TextEditingController panchayatController = TextEditingController();
  final TextEditingController tehsilController = TextEditingController();
  final TextEditingController ldgCodeController = TextEditingController();

  String selectedState = '';
  String selectedDistrict = '';

  // Initialize as empty - will be loaded from JSON
  Map<String, List<String>> stateDistrictData = {};
  List<String> availableDistricts = [];

  @override
  void initState() {
    super.initState();
    // Load JSON data here
    _loadStateDistrictData();
  }

  // Method to load data from your JSON file
  Future<void> _loadStateDistrictData() async {
    try {
      // Load your JSON file - adjust the path based on where you placed it
      // Example: if placed in assets/data/districts.json
      String jsonString = await rootBundle.loadString('assets/data/districts.json');
      
      // Parse JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Convert JSON to Map<String, List<String>>
      Map<String, List<String>> loadedData = {};
      jsonData.forEach((key, value) {
        if (value is List) {
          loadedData[key] = List<String>.from(value);
        }
      });
      
      setState(() {
        // Replace with loaded data from JSON
        stateDistrictData = loadedData;
      });
    } catch (e) {
      print('Error loading JSON: $e');
      // Fallback to hardcoded data if JSON loading fails
      setState(() {
        stateDistrictData = {
          'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer'],
          'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik'],
          'Uttar Pradesh': ['Lucknow', 'Varanasi', 'Agra', 'Kanpur', 'Prayagraj'],
          'Delhi': ['New Delhi', 'North Delhi', 'South Delhi', 'East Delhi', 'West Delhi'],
        };
      });
    }
  }

  void _onStateChanged(String? value) {
    setState(() {
      selectedState = value ?? '';
      selectedDistrict = '';
      availableDistricts = stateDistrictData[selectedState] ?? [];
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
      MaterialPageRoute(builder: (context) => PopulationFormScreen()),
    );
  }

  // ADD THIS - SIMPLE BACK FUNCTION
  void _goBack() {
    Navigator.pop(context);
  }

  void _resetForm() {
    setState(() {
      villageNameController.clear();
      villageCodeController.clear();
      gpsLinkController.clear();
      blockController.clear();
      panchayatController.clear();
      tehsilController.clear();
      ldgCodeController.clear();
      selectedState = '';
      selectedDistrict = '';
      availableDistricts = [];
    });
  }

  Widget _buildVillageContent() {
    return Column(
      children: [
        // Village Name
        QuestionCard(
          question: ' Name of village *',
          description: 'Official name of the village',
          child: TextInput(
            label: 'Enter village name',
            controller: villageNameController,
            prefixIcon: Icons.location_city,
          ),
        ),

        // Village Code
        QuestionCard(
          question: ' Village Code Number *',
          description: 'Official village code',
          child: NumberInput(
            label: 'Enter village code',
            controller: villageCodeController,
            prefixIcon: Icons.numbers,
          ),
        ),

        // GPS Link
        QuestionCard(
          question: ' GPS Location Link',
          description: 'Google Maps link to village location',
          child: TextInput(
            label: 'https://maps.google.com/?q=latitude,longitude',
            controller: gpsLinkController,
            prefixIcon: Icons.map,
          ),
        ),

        // State Selection
        QuestionCard(
          question: ' State *',
          description: 'Select the state where village is located',
          child: DropdownInput(
            label: 'Select State',
            value: selectedState,
            items: stateDistrictData.keys.toList(),
            onChanged: _onStateChanged,
            prefixIcon: Icons.flag,
          ),
        ),

        // District Selection
        QuestionCard(
          question: 'District *',
          description: 'Select district (select state first)',
          child: DropdownInput(
            label: selectedState.isEmpty
                ? 'Select state first'
                : 'Select District',
            value: selectedDistrict,
            items: availableDistricts,
            onChanged: _onDistrictChanged,
            enabled: selectedState.isNotEmpty,
            prefixIcon: Icons.location_city,
          ),
        ),

        // Block
        QuestionCard(
          question: ' Block *',
          description: 'Administrative block name',
          child: TextInput(
            label: 'Enter block name',
            controller: blockController,
            prefixIcon: Icons.grid_view,
          ),
        ),

        // Panchayat
        QuestionCard(
          question: ' Panchayat *',
          description: 'Gram Panchayat name',
          child: TextInput(
            label: 'Enter panchayat name',
            controller: panchayatController,
            prefixIcon: Icons.account_balance,
          ),
        ),

        // Tehsil
        QuestionCard(
          question: ' Tehsil *',
          description: 'Tehsil or Taluka name',
          child: TextInput(
            label: 'Enter Tehsil name',
            controller: tehsilController,
            prefixIcon: Icons.terrain,
          ),
        ),

        // LDG Code
        QuestionCard(
          question: ' LDG Code *',
          description: 'Local Development Code',
          child: NumberInput(
            label: 'Enter LDG code',
            controller: ldgCodeController,
            prefixIcon: Icons.code,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'Village Information',
      stepNumber: 'Step 1',
      nextScreenRoute: '/population',
      nextScreenName: 'Population Data',
      icon: Icons.location_city,
      instructions: 'Please fill all the details about the village',
      contentWidget: _buildVillageContent(),
      onSubmit: _submitForm,
      onBack: _goBack,  // ADD THIS LINE - IT WAS MISSING
      onReset: _resetForm,
    );
  }

  @override
  void dispose() {
    villageNameController.dispose();
    villageCodeController.dispose();
    gpsLinkController.dispose();
    blockController.dispose();
    panchayatController.dispose();
    tehsilController.dispose();
    ldgCodeController.dispose();
    super.dispose();
  }
}