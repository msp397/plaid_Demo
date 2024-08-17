import 'package:flutter/material.dart';
import 'package:frontend/balance.dart';
import 'package:frontend/balencecheck.dart';
import 'package:frontend/transactions.dart';
import 'package:frontend/transferui.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late SharedPreferences prefs;
  final String _selectedAccountId = '';

  @override
  void initState() {
    super.initState();
    initSharedPrefs();
  }

  void initSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _onTransferFunds() {
    if (_selectedAccountId!.isNotEmpty) {}
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransferUI(),
      ),
    );
  }

  void _onCheckBalance() {
    if (_selectedAccountId!.isNotEmpty) {}
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BalanceCheck(),
      ),
    );
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
                  // leading: Radio<String>(
                  //   value: account['id'] ?? '',
                  //   groupValue: _selectedAccountId,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _selectedAccountId = value;
                  //     });
                  //   },
                  // ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${account['name']}'),
                      Text('${account['mask']}')
                    ],
                  ),
                  subtitle: Text(account['type'] ?? 'NA'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _onTransferFunds,
                    child: const Text('Transfer'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _onCheckBalance,
                    child: const Text('Check Balance'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionList(
                            accessToken: prefs.getString('access-token') ?? '',
                          ),
                        ),
                      );
                    },
                    child: const Text('Transactions'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'This is a sandbox mode',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
