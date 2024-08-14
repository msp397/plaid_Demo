import 'package:flutter/material.dart';

class AccountInfo extends StatelessWidget {
  final List<Map<String, String>> accounts;
  final Map<String, String> institution;

  const AccountInfo({
    Key? key,
    required this.accounts,
    required this.institution,
  }) : super(key: key);

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
              '${institution['name'] ?? 'N/A'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return ListTile(
                  title: Text(account['name'] ?? 'N/A'),
                  subtitle: Text('ID: ${account['id'] ?? 'N/A'}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
