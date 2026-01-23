import 'package:flutter/material.dart';
import 'animals_fisheries_screen.dart';

class IrrigationFacilitiesScreen extends StatefulWidget {
  @override
  _IrrigationFacilitiesScreenState createState() => _IrrigationFacilitiesScreenState();
}

class _IrrigationFacilitiesScreenState extends State<IrrigationFacilitiesScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Irrigation facilities availability
  bool hasCanal = false;
  bool hasTubeWell = false;
  bool hasPonds = false;
  bool hasRiver = false;
  bool hasWell = false;
  
  // Additional information
  TextEditingController canalDetailsController = TextEditingController();
  TextEditingController tubeWellDetailsController = TextEditingController();
  TextEditingController pondsDetailsController = TextEditingController();
  TextEditingController riverDetailsController = TextEditingController();
  TextEditingController wellDetailsController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      int totalFacilities = 0;
      if (hasCanal) totalFacilities++;
      if (hasTubeWell) totalFacilities++;
      if (hasPonds) totalFacilities++;
      if (hasRiver) totalFacilities++;
      if (hasWell) totalFacilities++;
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF800080)),
              SizedBox(width: 10),
              Text('Irrigation Data Saved'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Irrigation facilities data has been saved. Continue to Animals/Fisheries?'),
                SizedBox(height: 15),
                
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE6E6FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📊 Irrigation Facilities Summary:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 8),
                      _buildSummaryItem('Total Facilities:', '$totalFacilities'),
                      if (hasCanal) _buildSummaryItem('Canal:', 'Available'),
                      if (hasTubeWell) _buildSummaryItem('Tube Well/Bore Well:', 'Available'),
                      if (hasPonds) _buildSummaryItem('Ponds:', 'Available'),
                      if (hasRiver) _buildSummaryItem('River:', 'Available'),
                      if (hasWell) _buildSummaryItem('Well:', 'Available'),
                      
                      if (totalFacilities == 0)
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'No irrigation facilities available',
                                style: TextStyle(color: Colors.red.shade800),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Edit', style: TextStyle(color: Color(0xFF800080))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnimalsFisheriesScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Irrigation data saved! Moving to Animals/Fisheries'),
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Continue to Animals/Fisheries'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080)),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      hasCanal = false;
      hasTubeWell = false;
      hasPonds = false;
      hasRiver = false;
      hasWell = false;
      
      canalDetailsController.clear();
      tubeWellDetailsController.clear();
      pondsDetailsController.clear();
      riverDetailsController.clear();
      wellDetailsController.clear();
    });
  }

  Widget _buildIrrigationOption(String title, bool value, Function(bool?) onChanged, TextEditingController controller) {
    return Column(
      children: [
        CheckboxListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF800080),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (value)
          Padding(
            padding: EdgeInsets.only(left: 40, right: 10, bottom: 15),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Details about $title',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Government of India Header
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Government of India',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Digital India',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF9933),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Power To Empower',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF138808),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.water, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Irrigation Facilities',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF800080),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Step 15: Irrigation facilities available in village',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              height: 4,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Color(0xFF800080),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // Irrigation Facilities Card
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Available Irrigation Facilities',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800080),
                            ),
                          ),
                          SizedBox(height: 15),
                          
                          // Irrigation Options
                          _buildIrrigationOption(
                            'a) Canal',
                            hasCanal,
                            (value) => setState(() => hasCanal = value ?? false),
                            canalDetailsController,
                          ),
                          
                          _buildIrrigationOption(
                            'b) Tube Well/Bore Well',
                            hasTubeWell,
                            (value) => setState(() => hasTubeWell = value ?? false),
                            tubeWellDetailsController,
                          ),
                          
                          _buildIrrigationOption(
                            'c) Ponds',
                            hasPonds,
                            (value) => setState(() => hasPonds = value ?? false),
                            pondsDetailsController,
                          ),
                          
                          _buildIrrigationOption(
                            'd) River',
                            hasRiver,
                            (value) => setState(() => hasRiver = value ?? false),
                            riverDetailsController,
                          ),
                          
                          _buildIrrigationOption(
                            'e) Well',
                            hasWell,
                            (value) => setState(() => hasWell = value ?? false),
                            wellDetailsController,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Summary Section
                    if (hasCanal || hasTubeWell || hasPonds || hasRiver || hasWell)
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Irrigation Facilities:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                if (hasCanal) _buildFacilityChip('Canal', Icons.waves),
                                if (hasTubeWell) _buildFacilityChip('Tube Well', Icons.water_drop),
                                if (hasPonds) _buildFacilityChip('Ponds', Icons.water),
                                if (hasRiver) _buildFacilityChip('River', Icons.water),
                                if (hasWell) _buildFacilityChip('Well', Icons.water),
                              ],
                            ),
                          ],
                        ),
                      ),
                    
                    SizedBox(height: 30),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _resetForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade700,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.refresh),
                            label: Text('Reset Form'),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF800080),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.arrow_forward, size: 24),
                            label: Text(
                              'Save & Continue',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.water, color: Color(0xFF800080), size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Step 15: Irrigation facilities data collection',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF800080),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.navigate_next, color: Colors.green.shade700, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Next: Animals and Fisheries',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.blue.shade700),
      label: Text(text, style: TextStyle(fontSize: 12)),
      backgroundColor: Colors.blue.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.blue.shade300),
      ),
    );
  }

  @override
  void dispose() {
    canalDetailsController.dispose();
    tubeWellDetailsController.dispose();
    pondsDetailsController.dispose();
    riverDetailsController.dispose();
    wellDetailsController.dispose();
    super.dispose();
  }
}