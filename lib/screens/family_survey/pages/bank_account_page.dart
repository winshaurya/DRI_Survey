import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../widgets/family_scheme_data_widget.dart';

class BankAccountPage extends StatefulWidget {
  final int surveyId;

  const BankAccountPage({Key? key, required this.surveyId}) : super(key: key);

  @override
  _BankAccountPageState createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  final _dbHelper = DatabaseHelper();
  List<String> _familyMembers = [];
  Map<String, dynamic> _bankData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final members = await _dbHelper.getFamilyMembers(widget.surveyId);
      final accountsData = await _dbHelper.getBankAccounts(widget.surveyId);

      // Convert database data to widget format
      List<Map<String, dynamic>> membersData = [];
      if (accountsData.isNotEmpty) {
        // Group accounts by member
        Map<String, List<Map<String, dynamic>>> memberAccounts = {};

        for (var account in accountsData) {
          String memberName = account['member_name'] ?? '';
          if (!memberAccounts.containsKey(memberName)) {
            memberAccounts[memberName] = [];
          }
          memberAccounts[memberName]!.add({
            'bank_name': account['bank_name'],
            'account_number': account['account_number'],
            'ifsc_code': account['ifsc_code'],
            'branch_name': account['branch_name'],
            'account_type': account['account_type'],
            'has_account': account['has_account'] == 1,
            'details_correct': account['details_correct'] == 1,
            'incorrect_details': account['incorrect_details'],
          });
        }

        // Convert to widget format
        memberAccounts.forEach((memberName, accounts) {
          membersData.add({
            'sr_no': membersData.length + 1,
            'name': memberName,
            'bank_accounts': accounts,
          });
        });
      }

      setState(() {
        _familyMembers = members;
        _bankData = {
          'is_beneficiary': membersData.isNotEmpty,
          'members': membersData,
        };
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving bank account data...'))
      );

      // Clear existing bank accounts for this survey
      await _dbHelper.deleteBankAccountsBySurveyId(widget.surveyId);

      // Save new data
      final members = _bankData['members'] as List? ?? [];
      for (var member in members) {
        final bankAccounts = member['bank_accounts'] as List? ?? [];
        for (var account in bankAccounts) {
          final bankAccount = {
            'survey_id': widget.surveyId,
            'member_name': member['name'],
            'bank_name': account['bank_name'],
            'account_number': account['account_number'],
            'ifsc_code': account['ifsc_code'],
            'branch_name': account['branch_name'],
            'account_type': account['account_type'],
            'has_account': account['has_account'] == true ? 1 : 0,
            'details_correct': account['details_correct'] == true ? 1 : 0,
            'incorrect_details': account['incorrect_details'],
            'created_at': DateTime.now().toIso8601String(),
          };
          await _dbHelper.insertBankAccount(bankAccount);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank account data saved successfully'))
        );
      }
    } catch (e) {
      debugPrint('Error saving data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving data'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator())
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Account Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveData,
            tooltip: 'Save bank account data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FamilySchemeDataWidget(
          title: 'Bank Account Information',
          familyMemberNames: _familyMembers,
          data: _bankData,
          showBankAccounts: true,
          showBeneficiaryCheck: false, // Always show since it's bank accounts
          onDataChanged: (data) {
            setState(() {
              _bankData = data;
            });
          },
        ),
      ),
    );
  }
}
