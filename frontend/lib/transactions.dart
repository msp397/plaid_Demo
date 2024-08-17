import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final publicToken = await _createPublicToken();
      if (publicToken != null) {
        final accessToken = await _exchangePublicToken(publicToken);
        if (accessToken != null) {
          await _getTransactions(accessToken);
        } else {
          setState(() {
            _message = 'Failed to obtain access token';
          });
        }
      } else {
        setState(() {
          _message = 'Failed to create public token';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  Future<String?> _createPublicToken() async {
    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/sandbox/public_token/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "institution_id": "ins_20",
          "initial_products": ["transactions"],
          "options": {"webhook": "https://www.genericwebhookurl.com/webhook"}
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['public_token'];
      } else {
        print('Error creating public token: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating public token: $e');
      return null;
    }
  }

  Future<String?> _exchangePublicToken(String publicToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/item/public_token/exchange'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "public_token": publicToken
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['access_token'];
      } else {
        print('Error exchanging public token: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error exchanging public token: $e');
      return null;
    }
  }

  Future<void> _getTransactions(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/transactions/get'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "access_token": accessToken,
          "start_date": "2017-01-01",
          "end_date": "2024-08-17",
          "options": {"count": 250, "offset": 0}
        }),
      );
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _transactions = responseBody['transactions'] ?? [];
          _message = 'Transactions fetched successfully!';
        });
      } else {
        print('Error fetching transactions: ${response.body}');
        setState(() {
          _message = 'Failed to fetch transactions';
        });
      }
    } catch (e) {
      print('Error fetching transactions: $e');
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
              child: _transactions.isEmpty
                  ? Center(child: Text('No transactions available'))
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        final category =
                            (transaction['category'] as List<dynamic>?)
                                        ?.isNotEmpty ==
                                    true
                                ? transaction['category'][0]
                                : 'Unknown';
                        final amount = transaction['amount'] ?? 0.0;
                        final date = transaction['date'] ?? 'No date';

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              transaction['name'] ?? 'Unknown',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 4.0),
                                Chip(
                                  label: Text(
                                    category,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                              ],
                            ),
                            trailing: Text(
                              '\$${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
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
