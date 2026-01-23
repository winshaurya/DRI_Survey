import 'package:flutter/material.dart';
import '../form_template.dart';
import 'children_not_in_school_screen.dart';
import 'bpl_families_screen.dart';

class TraditionalOccupationsScreen extends StatefulWidget {
  const TraditionalOccupationsScreen({super.key});

  @override
  _TraditionalOccupationsScreenState createState() => _TraditionalOccupationsScreenState();
}

class _TraditionalOccupationsScreenState extends State<TraditionalOccupationsScreen> {
  // Traditional occupations with their counts
  final Map<String, TextEditingController> occupations = {
    'Armourer': TextEditingController(),
    'Barber (Naai)': TextEditingController(),
    'Basket/Mat/Broom Maker/Coir Weaver': TextEditingController(),
    'Blacksmith (Lohar)': TextEditingController(),
    'Boat Maker': TextEditingController(),
    'Carpenter (Suthar/Badhai)': TextEditingController(),
    'Cobbler (Charmkar)/Shoesmith/Footwear artisan': TextEditingController(),
    'Doll & Toy Maker (Traditional)': TextEditingController(),
    'Fishing Net Maker': TextEditingController(),
    'Garland maker (Malakaar)': TextEditingController(),
    'Goldsmith (Sonar)': TextEditingController(),
    'Hammer and Tool Kit Maker': TextEditingController(),
    'Locksmith': TextEditingController(),
    'Mason (Rajmistri)': TextEditingController(),
    'Potter (Kumhaar)': TextEditingController(),
    'Sculptor (Moortikar, stone carver), Stone Breaker': TextEditingController(),
    'Tailor (Darzi)': TextEditingController(),
    'Washerman (Dhobi)': TextEditingController(),
    'Folklore Medicine (Traditional Medicine)': TextEditingController(),
  };

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChildrenNotInSchoolScreen()),
    );
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BPLFamiliesScreen()),
    );
  }

  Widget _buildOccupationsContent() {
    return Column(
      children: [
        // Occupations Grid
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                        flex: 3,
                        child: Text(
                          'Traditional Occupation',
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
                
                // Occupations List - Removed a), b) prefixes
                ...occupations.entries.map((entry) {
                  int index = occupations.keys.toList().indexOf(entry.key);
                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                      color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.key, // Removed: '${String.fromCharCode(97 + index)}) '
                            style: TextStyle(fontWeight: FontWeight.w500),
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
                                // No prefixIcon - empty field
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return 'Numbers only';
                                }
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
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
      title: 'Traditional Occupations',
      stepNumber: 'Step 11',
      nextScreenRoute: '/children-not-in-school',
      nextScreenName: 'Children Not in School',
      icon: Icons.handyman,
      instructions: 'Number of traditional occupations in village',
      contentWidget: _buildOccupationsContent(),
      onSubmit: _submitForm,
      onBack: _goToPreviousScreen,
      onReset: () {
        occupations.forEach((_, controller) => controller.clear());
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    occupations.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}