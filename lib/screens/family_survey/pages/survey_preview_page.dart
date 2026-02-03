import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dri_survey/services/excel_service.dart';

class SurveyPreviewPage extends StatelessWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const SurveyPreviewPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  Future<void> _handleExport(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating Excel file...')),
      );
      
      await ExcelService().exportSurveyToExcel(pageData);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel export completed successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              'Survey Preview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInDown(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleExport(context),
                icon: const Icon(Icons.table_view, color: Colors.white),
                label: const Text('Export to Excel', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Review all your survey responses before submitting',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Review all your survey responses before submitting',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Location Information
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildSection(
              title: 'Location Information',
              icon: Icons.location_on,
              color: Colors.blue,
              children: [
                _buildPreviewField('Village Name', pageData['village_name']),
                _buildPreviewField('Village Number', pageData['village_number']),
                _buildPreviewField('Panchayat', pageData['panchayat']),
                _buildPreviewField('Block', pageData['block']),
                _buildPreviewField('Tehsil', pageData['tehsil']),
                _buildPreviewField('District', pageData['district']),
                _buildPreviewField('Postal Address', pageData['postal_address']),
                _buildPreviewField('Pin Code', pageData['pin_code']),
                _buildPreviewField('Surveyor Name', pageData['surveyor_name']),
                _buildPreviewField('Phone Number', pageData['phone_number']),
              ],
            ),
          ),

          // Family Details
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildSection(
              title: 'Family Details',
              icon: Icons.people,
              color: Colors.purple,
              children: _buildFamilyMembersList(pageData['family_members'] as List? ?? []),
            ),
          ),

          // Social Consciousness
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildSection(
              title: 'Social Consciousness',
              icon: Icons.public,
              color: Colors.teal,
              children: [
                _buildBoolField('Caste System Follow', pageData['social_consciousness_1']),
                _buildBoolField('Gender Equality', pageData['social_consciousness_2']),
                _buildBoolField('Environmental Awareness', pageData['social_consciousness_3']),
              ],
            ),
          ),

          // Agricultural Information
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: _buildSection(
              title: 'Agricultural Information',
              icon: Icons.agriculture,
              color: Colors.green,
              children: [
                _buildPreviewField('Land Holding (acres)', pageData['land_holding']),
                _buildPreviewField('Irrigation Type', pageData['irrigation']),
                _buildPreviewField('Fertilizer Use', pageData['fertilizer_use']),
                const Divider(),
                const Text('Crop Details', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._buildCropsList(pageData['crops'] as List? ?? []),
              ],
            ),
          ),

          // Livestock & Equipment
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildSection(
              title: 'Livestock & Equipment',
              icon: Icons.pets,
              color: Colors.orange,
              children: [
                ..._buildAnimalsList(pageData['animals'] as List? ?? []),
                const SizedBox(height: 12),
                _buildBoolField('Has Equipment', pageData['equipment']),
                // Add equipment details if available in flat map
                if (pageData['tractor'] != null) _buildPreviewField('Tractor', pageData['tractor']),
              ],
            ),
          ),

          // Lifestyle & Transportation
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: _buildSection(
              title: 'Lifestyle & Infrastructure',
              icon: Icons.home,
              color: Colors.indigo,
              children: [
                _buildBoolField('Entertainment Access', pageData['entertainment']),
                _buildBoolField('Transportation Available', pageData['transport']),
                _buildBoolField('Water Sources', pageData['water_sources']),
                if (pageData['drinking_water_source'] != null) 
                   _buildPreviewField('Drinking Water Source', pageData['drinking_water_source']),
              ],
            ),
          ),

          // Health & Medical
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: _buildSection(
              title: 'Health & Medical',
              icon: Icons.local_hospital,
              color: Colors.red,
              children: [
                _buildBoolField('Medical Facilities', pageData['medical']),
                if (pageData['medical_treatment'] != null) _buildPreviewField('Treatment Type', pageData['medical_treatment']),
                const SizedBox(height: 8),
                const Text('Family Diseases', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._buildDiseasesList(pageData['diseases'] as List? ?? []),
                const SizedBox(height: 8),
                _buildBoolField('Health Programmes', pageData['health_programme']),
                _buildPreviewField('Folklore Medicine Use', pageData['folklore_medicine']),
              ],
            ),
          ),

          // Training & Skills
          FadeInUp(
            delay: const Duration(milliseconds: 900),
            child: _buildSection(
              title: 'Training & Skills',
              icon: Icons.school,
              color: Colors.orange,
              children: [
                ..._buildTrainingList(pageData['training_members'] as List? ?? []),
                _buildBoolField('Want Training', pageData['want_training']),
                _buildMembershipList('SHG Members', pageData['shg_members'] as List? ?? []),
                _buildMembershipList('FPO Members', pageData['fpo_members'] as List? ?? []),
              ],
            ),
          ),

          // Government Schemes
          FadeInUp(
            delay: const Duration(milliseconds: 1000),
            child: _buildSection(
              title: 'Government Schemes & Benefits',
              icon: Icons.card_membership,
              color: Colors.green[700]!,
              children: [
                _buildSchemeBeneficiary('VB-G RAM-G', pageData['vb_g_ram_g']),
                _buildSchemeBeneficiary('PM Kisan Samman Nidhi', pageData['pm_kisan']),
                _buildSchemeBeneficiary('Kisan Credit Card', pageData['kisan_credit_card']),
                _buildSchemeBeneficiary('Swachh Bharat Mission', pageData['swachh_bharat']),
                _buildSchemeBeneficiary('Fasal Bima', pageData['fasal_bima']),
                _buildSchemeBeneficiary('Bank Accounts', pageData['bank_account']),
              ],
            ),
          ),

          // Children & Malnutrition
          FadeInUp(
            delay: const Duration(milliseconds: 1050),
            child: _buildSection(
              title: 'Children & Health Stats',
              icon: Icons.baby_changing_station,
              color: Colors.pink,
              children: [
                _buildPreviewField('Births (Last 3 Years)', pageData['births_last_3_years']),
                _buildPreviewField('Infant Deaths (Last 3 Years)', pageData['infant_deaths_last_3_years']),
                _buildPreviewField('Malnourished Children Count', pageData['malnourished_children']),
                _buildMalnourishedChildrenList(pageData['malnourished_children_data'] as List? ?? []),
              ],
            ),
          ),

          // Disputes & Migration
          FadeInUp(
            delay: const Duration(milliseconds: 1100),
            child: _buildSection(
              title: 'Other Information',
              icon: Icons.info,
              color: Colors.grey,
              children: [
                _buildBoolField('Disputes Present', pageData['disputes']),
                _buildBoolField('Migration Issues', pageData['migration']),
                _buildBoolField('Government Schemes', pageData['government_schemes']),
                _buildBoolField('House Conditions', pageData['house_conditions']),
              ],
            ),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewField(String label, dynamic value) {
    final displayValue = (value == null || (value is String && value.isEmpty)) 
        ? 'Not provided' 
        : value.toString();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (value == null || (value is String && value.isEmpty)) 
                  ? Colors.grey[200] 
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: (value == null || (value is String && value.isEmpty)) 
                    ? Colors.grey[600] 
                    : Colors.black,
                fontStyle: (value == null || (value is String && value.isEmpty)) 
                    ? FontStyle.italic 
                    : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoolField(String label, dynamic value) {
    final boolValue = value is bool ? value : (value.toString().toLowerCase() == 'true');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            boolValue ? Icons.check_circle : Icons.cancel,
            color: boolValue ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          const Spacer(),
          Text(
            boolValue ? 'Yes' : 'No',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: boolValue ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFamilyMembersList(List familyMembers) {
    if (familyMembers.isEmpty) {
      return [const Text('No family members added', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))];
    }
    return List.generate(familyMembers.length, (index) {
      final member = familyMembers[index] as Map<String, dynamic>?;
      if (member == null) {
        return const Text('Invalid member data');
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Member ${index + 1}: ${member['name']?.toString() ?? 'Not provided'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Age: ${member['age']?.toString() ?? 'N/A'}')),
                  Expanded(child: Text('Gender: ${member['gender']?.toString() ?? 'N/A'}')),
                ],
              ),
              if (member['occupation'] != null)
                Text('Occupation: ${member['occupation']}'),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildTrainingList(List trainings) {
    if (trainings.isEmpty) {
      return [const Text('No training records', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))];
    }
    return List.generate(trainings.length, (index) {
      final training = trainings[index] as Map<String, dynamic>?;
      if (training == null) {
        return const Text('Invalid training data');
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                training['member_name']?.toString() ?? 'Not provided',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '${training['training_type']?.toString() ?? 'N/A'} (Status: ${training['status']?.toString() ?? 'N/A'})',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMembershipList(String title, List members) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          if (members.isEmpty)
            Text('No ${title.toLowerCase()} added', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12))
          else
            ...List.generate(members.length, (index) {
              final member = members[index] as Map<String, dynamic>?;
              if (member == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• ${member['member_name']?.toString() ?? 'Not provided'} - ${member['shg_name']?.toString() ?? member['fpo_name']?.toString() ?? 'Not provided'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSchemeBeneficiary(String schemeName, dynamic data) {
    final isBeneficiary = (data is Map && data['is_beneficiary'] == true);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isBeneficiary ? Icons.check_circle : Icons.cancel,
            color: isBeneficiary ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(schemeName, style: const TextStyle(fontSize: 13)),
          ),
          Text(
            isBeneficiary ? 'Beneficiary' : 'Not Beneficiary',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isBeneficiary ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMalnourishedChildrenList(List children) {
    if (children.isEmpty) {
      return const SizedBox.shrink(); 
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12, bottom: 6),
          child: Text('Malnourished Children Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        ...List.generate(children.length, (index) {
          final child = children[index] as Map<String, dynamic>?;
          if (child == null) return const SizedBox.shrink();
          
          final diseases = child['diseases'] as List? ?? [];
          final diseaseNames = diseases.map((d) => d['name']?.toString() ?? '').where((s) => s.isNotEmpty).join(', ');

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.pink[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Child ID: ${child['child_id'] ?? 'Not selected'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Height: ${child['height'] ?? '-'} cm, Weight: ${child['weight'] ?? '-'} kg', style: const TextStyle(fontSize: 12)),
                  if (diseaseNames.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Conditions: $diseaseNames', style: TextStyle(color: Colors.red[800], fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  List<Widget> _buildCropsList(List crops) {
    if (crops.isEmpty) {
      return [const Text('No crops recorded', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))];
    }
    return List.generate(crops.length, (index) {
      final crop = crops[index] as Map<String, dynamic>?;
      if (crop == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text('• ${crop['crop_name']}: ${crop['area'] ?? 0} acres, ${crop['production'] ?? 0} quintals', 
          style: const TextStyle(fontSize: 13)),
      );
    });
  }

  List<Widget> _buildAnimalsList(List animals) {
    if (animals.isEmpty) {
      return [const Text('No animals recorded', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))];
    }
    return [
      const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text('Livestock Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
      ...List.generate(animals.length, (index) {
        final animal = animals[index] as Map<String, dynamic>?;
        if (animal == null) return const SizedBox.shrink();
        return Text('• ${animal['animal_type']}: ${animal['count'] ?? 0} (Breed: ${animal['breed'] ?? 'N/A'})', 
          style: const TextStyle(fontSize: 13));
      })
    ];
  }

  List<Widget> _buildDiseasesList(List diseases) {
    if (diseases.isEmpty) {
      return [const Text('No diseases recorded', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12))];
    }
    return List.generate(diseases.length, (index) {
      final disease = diseases[index] as Map<String, dynamic>?;
      if (disease == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text('• ${disease['member_name']}: ${disease['disease_name']} (${disease['treatment_type']})', 
          style: const TextStyle(fontSize: 12)),
      );
    });
  }
}
