// PM Kisan Nidhi Beneficiary Page
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/survey_provider.dart';
import '../widgets/family_scheme_data_widget.dart';
import '../../../form_template.dart';

class PMKisanNidhiPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const PMKisanNidhiPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<PMKisanNidhiPage> createState() => _PMKisanNidhiPageState();
}

class _PMKisanNidhiPageState extends ConsumerState<PMKisanNidhiPage> {
  Map<String, dynamic> _schemeData = {};
  List<String> _familyMemberNames = [];

  @override
  void initState() {
    super.initState();
    _schemeData = Map<String, dynamic>.from(widget.pageData);
     if (_schemeData.isEmpty) {
        _schemeData = {'is_beneficiary': false, 'members': []};
    }
    _loadFamilyMembers();
  }
  
  @override
  void didUpdateWidget(covariant PMKisanNidhiPage oldWidget) {
      super.didUpdateWidget(oldWidget);
       if (widget.pageData != oldWidget.pageData) {
         _schemeData = Map<String, dynamic>.from(widget.pageData);
       }
  }

  void _loadFamilyMembers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final surveyState = ref.read(surveyProvider);
      final familyMembers = surveyState.surveyData['family_members'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _familyMemberNames = familyMembers
              .map((member) => member['name'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplateScreen(
      title: 'PM Kisan Nidhi Yojna Beneficiary',
      stepNumber: '27',
      nextScreenRoute: '/pm-kisan-samman-nidhi',
      nextScreenName: 'PM Kisan Samman Nidhi',
      icon: Icons.agriculture,
      onReset: () {
        setState(() {
           _schemeData = {'is_beneficiary': false, 'members': []};
           widget.onDataChanged(_schemeData);
        });
      },
      contentWidget: Column(
        children: [
          FamilySchemeDataWidget(
            title: 'PM Kisan Nidhi Yojna Beneficiary',
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
              widget.onDataChanged(newData);
            },
          ),
        ],
      ),
    );
  }
}
