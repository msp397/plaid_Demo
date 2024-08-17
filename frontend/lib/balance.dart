import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TransactionList extends StatefulWidget {
  final String accessToken;
  const TransactionList({super.key, required this.accessToken});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  List<dynamic> _transfers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getTransaction();
  }

  void getTransaction() async {
    await _getTransactionList(widget.accessToken);
  }

  Future<void> _getTransactionList(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/transfer/list'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "start_date": "2019-12-06T10:35:49Z",
          "end_date": "2024-08-17T17:00:49Z",
          "count": 14,
          "offset": 2
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _transfers = data['transfers'];
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to get transactions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting transactions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transfers.isEmpty
              ? const Center(child: Text('No Data Found'))
              : ListView.builder(
                  itemCount: _transfers.length,
                  itemBuilder: (context, index) {
                    final transfer = _transfers[index];
                    return ListTile(
                      title: Text(transfer['description'] ?? 'No description'),
                      subtitle: Text(
                        '${transfer['amount']} ${transfer['iso_currency_code']}',
                      ),
                      trailing: Text(
                        transfer['status']?.toUpperCase() ?? 'UNKNOWN',
                        style: TextStyle(
                          color: transfer['status'] == 'settled'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
