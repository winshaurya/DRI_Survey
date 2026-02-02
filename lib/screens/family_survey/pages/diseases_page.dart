import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/survey_provider.dart';
import '../widgets/family_scheme_data_widget.dart';
import '../../../form_template.dart';

class DiseasesPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const DiseasesPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<DiseasesPage> createState() => _DiseasesPageState();
}

class _DiseasesPageState extends ConsumerState<DiseasesPage> {
  Map<String, dynamic> _diseasesData = {};
  List<String> _familyMemberNames = [];

  @override
  void initState() {
    super.initState();
    _diseasesData = Map<String, dynamic>.from(widget.pageData);
    if (_diseasesData.isEmpty) {
      _diseasesData = {'is_beneficiary': false, 'members': []};
    }
    _loadFamilyMembers();
  }

  @override
  void didUpdateWidget(covariant DiseasesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
      _diseasesData = Map<String, dynamic>.from(widget.pageData);
    }
  }

  void _loadFamilyMembers() {
    final surveyState = ref.read(surveyProvider);
    final familyMembers = surveyState.surveyData['family_members'] as List<dynamic>? ?? [];
    setState(() {
      _familyMemberNames = familyMembers
          .map((member) => member['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Health Issues and Diseases',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
        ),
        const SizedBox(height: 16),
        
        FamilySchemeDataWidget(
          title: 'Family Members with Diseases',
          familyMemberNames: _familyMemberNames,
          data: _diseasesData,
          showBeneficiaryCheck: false, // No beneficiary check for diseases
          showNameIncluded: false,
          showDetailsCorrect: false,
          showReceived: false,
          showDays: false,
          showDiseaseName: true,
          showSufferingSince: true,
          showTreatmentTaken: true,
          showTreatmentFromWhen: true,
          showTreatmentFromWhere: true,
          showTreatmentTakenFrom: true,
          onDataChanged: (newData) {
            setState(() {
              _diseasesData = newData;
            });
            widget.onDataChanged(newData);
          },
        ),
      ],
    );
  }
}
