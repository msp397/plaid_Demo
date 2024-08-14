import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/utils/urls.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  String _message = 'Fetching transactions...';
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _transactionPublicToken();
    _exchangePublicToken('YOUR_LINK_TOKEN_HERE');
    _getTransactions('YOUR_ACCESS_TOKEN_HERE');
  }

  Future<void> _transactionPublicToken() async {
    try {
      final response = await http.post(
        Uri.parse(URLS.base_url + URLS.create_link_token),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "institution_id": "ins_3",
          "initial_products": ["transactions"],
          "options": {"webhook": "https://www.genericwebhookurl.com/webhook"}
        }),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final linkToken = jsonDecode(response.body)['link_token'];
        print('Link Token: $linkToken');

        await _exchangePublicToken(linkToken);
      } else {
        setState(() {
          _message = 'Failed to create link token';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  Future<void> _exchangePublicToken(String linkToken) async {
    const String publicToken = 'YOUR_PUBLIC_TOKEN_HERE';

    try {
      final response = await http.post(
        Uri.parse(URLS.base_url + URLS.create_public_token),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"public_token": publicToken}),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final accessToken = jsonDecode(response.body)['access_token'];
        print('Access Token: $accessToken');
        // Proceed to get transactions
        await _getTransactions(accessToken);
      } else {
        setState(() {
          _message = 'Failed to exchange public token';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  Future<void> _getTransactions(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse(URLS.base_url + URLS.get_transactions),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "access_token": accessToken,
          "start_date": "2017-01-01",
          "end_date": "2018-01-01",
          "options": {"count": 250, "offset": 100}
        }),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          _transactions = jsonDecode(response.body)['transactions'];
          _message = 'Transactions fetched successfully!';
        });
      } else {
        setState(() {
          _message = 'Failed to fetch transactions';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _message,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return ListTile(
                    title: Text(transaction['name'] ?? 'Unknown'),
                    subtitle: Text(transaction['date'] ?? 'No date'),
                    trailing: Text(transaction['amount'].toString() ?? '0.0'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
