import 'package:flutter/material.dart';
import 'package:frontend/balencecheck.dart';
import 'package:frontend/transfer.dart';
import 'package:frontend/transfer_screen.dart';

class AccountInfo extends StatefulWidget {
  final List<Map<String, String>> accounts;
  final Map<String, String> institution;

  const AccountInfo({
    super.key,
    required this.accounts,
    required this.institution,
  });

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  String? _selectedAccountId = '';

  void _onTransferFunds() {
    if (_selectedAccountId!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Transfer(),
        ),
      );
    }
  }

  void _onCheckBalance() {
    if (_selectedAccountId!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BalanceCheck(accountId: _selectedAccountId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.institution['name'] ?? 'N/A',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.accounts.length,
              itemBuilder: (context, index) {
                final account = widget.accounts[index];
                return ListTile(
                  leading: Radio<String>(
                    value: account['id'] ?? '',
                    groupValue: _selectedAccountId,
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountId = value;
                      });
                    },
                  ),
                  title: Text(account['name'] ?? 'N/A'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _onTransferFunds,
                  child: const Text('Transfer Funds'),
                ),
                ElevatedButton(
                  onPressed: _onCheckBalance,
                  child: const Text('Check Balance'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
