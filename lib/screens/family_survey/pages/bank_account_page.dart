import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/survey_models.dart';

class BankAccountPage extends StatefulWidget {
  final int surveyId;

  const BankAccountPage({Key? key, required this.surveyId}) : super(key: key);

  @override
  _BankAccountPageState createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  final _dbHelper = DatabaseHelper();
  List<BankAccount> _accounts = [];
  List<String> _familyMembers = [];
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
      final accounts = accountsData.map((e) => BankAccount.fromMap(e)).toList();

      setState(() {
        _familyMembers = members;
        _accounts = accounts;
        if (_accounts.isEmpty) {
          _addAccount();
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _addAccount() {
    setState(() {
      _accounts.add(BankAccount(
        surveyId: widget.surveyId,
        srNo: _accounts.length + 1,
        createdAt: DateTime.now().toIso8601String(),
        detailsCorrect: 'yes', // Default
      ));
    });
  }
  
  Future<void> _saveAll() async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saving...')));
      for(var account in _accounts) {
          if (account.id != null) {
              await _dbHelper.updateBankAccount(account.toMap());
          } else {
              int id = await _dbHelper.insertBankAccount(account.toMap());
              // Update object with new ID (optional, but good practice if staying on page)
              int index = _accounts.indexOf(account);
              if(index != -1) {
                  setState(() {
                      _accounts[index] = account.copyWith(id: id);
                  });
              }
          }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved Successfully')));
      }
  }

  void _updateAccount(int index, BankAccount account) {
      setState(() {
          _accounts[index] = account;
      });
  }

  void _deleteAccount(int index) async {
      final account = _accounts[index];
      if (account.id != null) {
          await _dbHelper.deleteBankAccount(account.id!);
      }
      setState(() {
          _accounts.removeAt(index);
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Details'),
        actions: [
             IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveAll,
            )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          return _buildAccountCard(index);
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: _addAccount,
      ),
    );
  }

  Widget _buildAccountCard(int index) {
    final account = _accounts[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text('Account #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAccount(index),
                    )
                ],
            ),
            const Divider(),
            
            // 1. Member Name (Dropdown)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '1. Member Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)
              ),
              value: _familyMembers.contains(account.memberName) ? account.memberName : null,
              items: _familyMembers.map((name) {
                return DropdownMenuItem(value: name, child: Text(name));
              }).toList(),
              onChanged: (val) {
                _updateAccount(index, account.copyWith(memberName: val));
              },
            ),
            const SizedBox(height: 12),
            
            // 2. Account Number
            TextFormField(
              decoration: const InputDecoration(
                labelText: '2. Account Number',
                border: OutlineInputBorder(),
              ),
              initialValue: account.accountNumber,
              keyboardType: TextInputType.number,
              onChanged: (val) {
                 _updateAccount(index, account.copyWith(accountNumber: val));
              },
            ),
            const SizedBox(height: 12),

            // 3. Bank Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: '3. Bank Name',
                border: OutlineInputBorder(),
              ),
              initialValue: account.bankName,
              onChanged: (val) {
                 _updateAccount(index, account.copyWith(bankName: val));
              },
            ),

            const SizedBox(height: 12),
            // 4. Details Correct (Yes/No)
            const Text('4. Details Correct?', style: TextStyle(fontWeight: FontWeight.w500)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Yes'),
                    value: 'yes',
                    groupValue: account.detailsCorrect,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                       _updateAccount(index, account.copyWith(detailsCorrect: val));
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('No'),
                    value: 'no',
                    groupValue: account.detailsCorrect,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                       _updateAccount(index, account.copyWith(detailsCorrect: val));
                    },
                  ),
                ),
              ],
            ),

            // 5. If No -> Incorrect Details
            if (account.detailsCorrect == 'no')
              TextFormField(
                decoration: const InputDecoration(
                    labelText: "5. What's incorrect?",
                    border: OutlineInputBorder(),
                ),
                initialValue: account.incorrectDetails,
                onChanged: (val) {
                   _updateAccount(index, account.copyWith(incorrectDetails: val));
                },
              ),
          ],
        ),
      ),
    );
  }
}