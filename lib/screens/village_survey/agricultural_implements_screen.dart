import 'package:flutter/material.dart';
import 'agricultural_technology_screen.dart';
import 'signboards_screen.dart';

class AgriculturalImplementsScreen extends StatefulWidget {
  const AgriculturalImplementsScreen({super.key});

  @override
  _AgriculturalImplementsScreenState createState() => _AgriculturalImplementsScreenState();
}

class _AgriculturalImplementsScreenState extends State<AgriculturalImplementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _othersController = TextEditingController();
  
  // Map to store implement name and its count (null if not available)
  final Map<String, String?> implements = {
    'Tractor': null,
    'Duster': null,
    'Sprayer': null,
    'Thresher': null,
    'Seed Drill': null,
    'Diesel pump': null,
  };

  // Controllers for each implement input
  final Map<String, TextEditingController> _implementControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each implement
    for (var key in implements.keys) {
      _implementControllers[key] = TextEditingController();
    }
  }

  void _submitForm() {
    // Navigate directly to next screen without showing dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignboardsScreen()),
    );
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AgriculturalTechnologyScreen()),
    );
  }

  Widget _buildImplementInputField(String label, String hint, IconData icon, TextEditingController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Color(0xFF800080)),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        prefixIcon: Icon(Icons.edit_note, size: 20, color: Colors.grey.shade600),
                        isDense: true,
                      ),
                      validator: (value) => null,
                      style: TextStyle(fontSize: 14),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.info_outline, size: 12, color: Colors.grey.shade600),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Enter number or description',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOthersInputField() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.add_box, size: 20, color: Color(0xFF800080)),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Other Implements (Specify)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _othersController,
                      decoration: InputDecoration(
                        hintText: 'Enter other implements separated by commas',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        prefixIcon: Icon(Icons.edit_note, size: 20, color: Colors.grey.shade600),
                        isDense: true,
                      ),
                      validator: (value) => null,
                      style: TextStyle(fontSize: 14),
                      maxLines: 2,
                    ),
                    SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.info_outline, size: 12, color: Colors.grey.shade600),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Leave empty if none. Format: "Generator: 1, Harvester: 2"',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double horizontalPadding = isMobile ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 80,
                      maxHeight: isMobile ? 90 : 100,
                    ),
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isMobile ? 12 : 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Government of India',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003366),
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 4 : 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Digital India - Power To Empower',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Card
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 12 : 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.build, color: Color(0xFF800080), size: isMobile ? 20 : 24),
                                      SizedBox(width: isMobile ? 8 : 10),
                                      Expanded(
                                        child: Text(
                                          'Agricultural Implements',
                                          style: TextStyle(
                                            fontSize: isMobile ? 18 : 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF800080),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isMobile ? 6 : 8),
                                  Text(
                                    'Step 22: Availability of agricultural implements',
                                    style: TextStyle(fontSize: isMobile ? 14 : 16),
                                  ),
                                  SizedBox(height: isMobile ? 6 : 8),
                                  Container(
                                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF800080).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.info_outline, color: Color(0xFF800080), size: isMobile ? 14 : 16),
                                        SizedBox(width: isMobile ? 6 : 8),
                                        Expanded(
                                          child: Text(
                                            'Fields are optional. Leave empty if none available. You can enter numbers or descriptions.',
                                            style: TextStyle(
                                              fontSize: isMobile ? 11 : 12,
                                              color: Color(0xFF800080),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isMobile ? 16 : 20),
                          
                          // Implements Input Fields
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 12 : 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Enter implement details:',
                                          style: TextStyle(
                                            fontSize: isMobile ? 16 : 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'All Optional',
                                          style: TextStyle(
                                            fontSize: isMobile ? 10 : 12,
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isMobile ? 4 : 5),
                                  Text(
                                    'Enter number of units or descriptive text. Leave empty if not available.',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 12 : 20),
                                  
                                  // Implement input fields
                                  ...implements.entries.map((entry) {
                                    IconData icon;
                                    switch (entry.key) {
                                      case 'Tractor':
                                        icon = Icons.directions_car;
                                        break;
                                      case 'Duster':
                                        icon = Icons.air;
                                        break;
                                      case 'Sprayer':
                                        icon = Icons.water_drop;
                                        break;
                                      case 'Thresher':
                                        icon = Icons.settings;
                                        break;
                                      case 'Seed Drill':
                                        icon = Icons.grass;
                                        break;
                                      case 'Diesel pump':
                                        icon = Icons.oil_barrel;
                                        break;
                                      default:
                                        icon = Icons.build;
                                    }
                                    
                                    return _buildImplementInputField(
                                      entry.key,
                                      'e.g., "2" or "1 available"',
                                      icon,
                                      _implementControllers[entry.key]!,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isMobile ? 16 : 20),
                          
                          // Others field
                          _buildOthersInputField(),
                          
                          SizedBox(height: isMobile ? 20 : 30),
                          
                          // Buttons - Previous and Continue
                          isMobile
                              ? Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: _goToPreviousScreen,
                                        icon: Icon(Icons.arrow_back),
                                        label: Text('Previous'),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: 14),
                                          side: BorderSide(color: Color(0xFF800080)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _submitForm,
                                        icon: Icon(Icons.arrow_forward),
                                        label: Text('Save & Continue'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF800080),
                                          padding: EdgeInsets.symmetric(vertical: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _goToPreviousScreen,
                                        icon: Icon(Icons.arrow_back),
                                        label: Text('Previous'),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: 14),
                                          side: BorderSide(color: Color(0xFF800080)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _submitForm,
                                        icon: Icon(Icons.arrow_forward),
                                        label: Text('Save & Continue'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF800080),
                                          padding: EdgeInsets.symmetric(vertical: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _othersController.dispose();
    for (var controller in _implementControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
