// VB G RAM G Beneficiary Page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/survey_provider.dart';
import '../widgets/family_scheme_data_widget.dart';

class VBGBeneficiaryPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const VBGBeneficiaryPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<VBGBeneficiaryPage> createState() => _VBGBeneficiaryPageState();
}

class _VBGBeneficiaryPageState extends ConsumerState<VBGBeneficiaryPage> {
  Map<String, dynamic> _schemeData = {};
  List<String> _familyMemberNames = [];
  final String _schemeKey = 'vb_gram';

  @override
  void initState() {
    super.initState();
    _initData();
    _loadFamilyMembers();
  }

  @override
  void didUpdateWidget(covariant VBGBeneficiaryPage oldWidget) {
      super.didUpdateWidget(oldWidget);
      _initData();
      _loadFamilyMembers();
  }

  void _initData() {
    var existing = widget.pageData[_schemeKey];
    if (existing != null && existing is Map) {
       _schemeData = Map<String, dynamic>.from(existing);
    } else {
       _schemeData = {'is_beneficiary': false, 'members': []};
    }
  }

  void _loadFamilyMembers() {
    // Try to get family members from pageData first, then fallback to provider
    List<dynamic> familyMembers = [];
    
    // First, check if family_members are in pageData (passed from SurveyPage)
    if (widget.pageData['family_members'] != null) {
      familyMembers = widget.pageData['family_members'] as List<dynamic>;
    } else {
      // Fallback to provider
      final surveyState = ref.read(surveyProvider);
      familyMembers = surveyState.surveyData['family_members'] as List<dynamic>? ?? [];
    }
    
    if (mounted) {
      setState(() {
        _familyMemberNames = familyMembers
            .map((member) => member['name'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FamilySchemeDataWidget(
      title: 'VB G RAM G Beneficiary',
      familyMemberNames: _familyMemberNames,
      data: _schemeData,
      showNameIncluded: true,
      showDetailsCorrect: true,
      showDays: true,
      daysLabel: 'No. of days',
      onDataChanged: (newData) {
        setState(() {
          _schemeData = newData;
        });
        widget.onDataChanged({_schemeKey: newData});
      },
    );
  }
}
