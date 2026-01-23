import 'package:flutter/material.dart';
import 'social_map_screen.dart';

class SocialConsciousnessScreen extends StatefulWidget {
  @override
  _SocialConsciousnessScreenState createState() => _SocialConsciousnessScreenState();
}

class _SocialConsciousnessScreenState extends State<SocialConsciousnessScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Social consciousness indicators (9 rows as per your requirement)
  final List<Map<String, TextEditingController>> indicators = List.generate(9, (index) {
    return {
      'indicator': TextEditingController(),
      'instances': TextEditingController(),
      'details': TextEditingController(),
    };
  });

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      int totalInstances = 0;
      int indicatorsWithData = 0;
      
      for (var indicator in indicators) {
        int instances = int.tryParse(indicator['instances']!.text) ?? 0;
        if (instances > 0) {
          totalInstances += instances;
          indicatorsWithData++;
        }
      }
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF800080)),
              SizedBox(width: 10),
              Text('Social Consciousness Data Saved'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Social consciousness data has been saved. Continue to Social Map?'),
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
                      Text('📊 Social Consciousness Summary:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                      SizedBox(height: 8),
                      _buildSummaryItem('Total Indicators:', '$indicatorsWithData'),
                      _buildSummaryItem('Total Instances:', '$totalInstances'),
                      
                      if (indicatorsWithData > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text('Top Indicators:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF800080))),
                            SizedBox(height: 5),
                            ..._getTopIndicators(3).map((entry) => 
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                child: Text('• ${entry['indicator']}: ${entry['instances']} instances'),
                              )
                            ),
                          ],
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
                  MaterialPageRoute(builder: (context) => SocialMapScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Social consciousness data saved! Moving to Social Map'),
                    backgroundColor: Color(0xFF800080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800080)),
              child: Text('Continue to Social Map'),
            ),
          ],
        ),
      );
    }
  }

  List<Map<String, String>> _getTopIndicators(int count) {
    List<Map<String, String>> topIndicators = [];
    
    for (var indicator in indicators) {
      String indicatorName = indicator['indicator']!.text;
      String instances = indicator['instances']!.text;
      
      if (indicatorName.isNotEmpty && instances.isNotEmpty) {
        int instanceCount = int.tryParse(instances) ?? 0;
        if (instanceCount > 0) {
          topIndicators.add({
            'indicator': indicatorName,
            'instances': instances,
          });
        }
      }
    }
    
    // Sort by instances (descending)
    topIndicators.sort((a, b) {
      int aCount = int.tryParse(a['instances']!) ?? 0;
      int bCount = int.tryParse(b['instances']!) ?? 0;
      return bCount.compareTo(aCount);
    });
    
    return topIndicators.take(count).toList();
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
      for (var indicator in indicators) {
        indicator['indicator']!.clear();
        indicator['instances']!.clear();
        indicator['details']!.clear();
      }
    });
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
                                Icon(Icons.psychology, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Social Consciousness',
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
                              'Step 26: Data on social consciousness indicators',
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
                    
                    // Indicators Table
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
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF800080),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text('Sr. No.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text('Indicator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('No. of instances', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text('Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 10),
                          
                          // Indicator rows
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: indicators.length,
                            itemBuilder: (context, index) {
                              var indicator = indicators[index];
                              
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                  color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text('${index + 1}', textAlign: TextAlign.center),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        controller: indicator['indicator'],
                                        decoration: InputDecoration(
                                          hintText: 'Social indicator',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: indicator['instances'],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Instances',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required (0 if none)';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        controller: indicator['details'],
                                        decoration: InputDecoration(
                                          hintText: 'Details',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Examples Section
                    Card(
                      elevation: 3,
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade800),
                                SizedBox(width: 10),
                                Text(
                                  'Example Social Consciousness Indicators:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildExampleChip('Community clean-up drives'),
                                _buildExampleChip('Tree plantation events'),
                                _buildExampleChip('Blood donation camps'),
                                _buildExampleChip('Women empowerment programs'),
                                _buildExampleChip('Education awareness camps'),
                                _buildExampleChip('Health check-up camps'),
                                _buildExampleChip('Elderly care initiatives'),
                                _buildExampleChip('Youth leadership programs'),
                                _buildExampleChip('Disaster relief efforts'),
                              ],
                            ),
                          ],
                        ),
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
                    
                    // Progress Indicator
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
                              Icon(Icons.psychology, color: Color(0xFF800080), size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Step 26: Social consciousness data collection',
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
                                  'Next: Social Map Details',
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

  Widget _buildExampleChip(String text) {
    return Chip(
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
    for (var indicator in indicators) {
      indicator['indicator']!.dispose();
      indicator['instances']!.dispose();
      indicator['details']!.dispose();
    }
    super.dispose();
  }
}