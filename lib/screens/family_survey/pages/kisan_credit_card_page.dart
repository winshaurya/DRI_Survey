// Kisan Credit Card Beneficiary Page
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/survey_provider.dart';
import '../widgets/family_scheme_data_widget.dart';
import '../../../form_template.dart';

class KisanCreditCardPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const KisanCreditCardPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<KisanCreditCardPage> createState() => _KisanCreditCardPageState();
}

class _KisanCreditCardPageState extends ConsumerState<KisanCreditCardPage> {
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
  void didUpdateWidget(covariant KisanCreditCardPage oldWidget) {
      super.didUpdateWidget(oldWidget);
       if (widget.pageData != oldWidget.pageData) {
         _schemeData = Map<String, dynamic>.from(widget.pageData);
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
    return FormTemplateScreen(
        title: 'Kisan Credit Card Beneficiary',
        stepNumber: '29',
        nextScreenRoute: '/swachh-bharat',
        nextScreenName: 'Swachh Bharat Mission',
        icon: Icons.credit_card,
        onReset: () {
            setState(() {
               _schemeData = {'is_beneficiary': false, 'members': []};
               widget.onDataChanged(_schemeData);
            });
        },
        contentWidget: Column(
          children: [
            FamilySchemeDataWidget(
              title: 'Kisan Credit Card Beneficiary',
              familyMemberNames: _familyMemberNames,
              data: _schemeData,
              showNameIncluded: false,
              showDetailsCorrect: true,
              showReceived: true,
              showDays: false,
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
