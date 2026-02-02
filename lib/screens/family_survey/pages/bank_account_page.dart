import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/family_scheme_data_widget.dart';
import '../../../providers/survey_provider.dart';

class BankAccountPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const BankAccountPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  ConsumerState<BankAccountPage> createState() => _BankAccountPageState();
}

class _BankAccountPageState extends ConsumerState<BankAccountPage> {
  List<String> _familyMembers = [];
  Map<String, dynamic> _bankData = {};

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
    _loadData();
  }

  void _loadFamilyMembers() {
    final surveyState = ref.read(surveyProvider);
    final familyMembers = surveyState.surveyData['family_members'] as List<dynamic>? ?? [];
    setState(() {
      _familyMembers = familyMembers
          .map((member) => member['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    });
  }

  void _loadData() {
    _bankData = Map<String, dynamic>.from(widget.pageData);
    if (_bankData.isEmpty) {
        _bankData = {
          'is_beneficiary': false,
          'members': [],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return FamilySchemeDataWidget(
      title: 'Bank Account Information',
      familyMemberNames: _familyMembers,
      data: _bankData,
      showBankAccounts: true,
      showBeneficiaryCheck: false,
      onDataChanged: (data) {
        setState(() {
          _bankData = data;
        });
        widget.onDataChanged(_bankData);
      },
    );
  }
}

