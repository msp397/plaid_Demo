import 'package:flutter/material.dart';
import 'package:frontend/balencecheck.dart';
import 'package:frontend/transfer.dart';

class AccountInfo extends StatefulWidget {
  final List<Map<String, String>> accounts;
  final Map<String, String> institution;

  const AccountInfo({
    Key? key,
    required this.accounts,
    required this.institution,
  }) : super(key: key);

  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  String? _selectedAccountId = '1';

  void _onTransferFunds() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Transfer(),
      ),
    );
  }

  void _onCheckBalance() {
    if (_selectedAccountId != null) {
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
        title: Text('Bank Accounts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${widget.institution['name'] ?? 'N/A'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  child: Text('Transfer Funds'),
                ),
                ElevatedButton(
                  onPressed: _onCheckBalance,
                  child: Text('Check Balance'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
