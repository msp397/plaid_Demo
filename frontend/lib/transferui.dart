import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/payment.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

class TransferUI extends StatefulWidget {
  const TransferUI({super.key});

  @override
  State<TransferUI> createState() => _TransferUIState();
}

class _TransferUIState extends State<TransferUI> {
  final TextEditingController _recipientController = TextEditingController();
  List<String> _accountNumbers = [];
  Map<String, String> _accountNumberToId =
      {}; // Maps account numbers to account IDs
  String? _selectedAccountNumber;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _publicToken();
  }

  Future<void> _publicToken() async {
    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/sandbox/public_token/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "institution_id": "ins_20",
          "initial_products": ["auth"],
          "options": {"webhook": "https://www.genericwebhookurl.com/webhook"}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final publicToken = data['public_token'];
        _exchangePublicToken(publicToken);
      } else {
        throw Exception('Failed to create public token');
      }
    } catch (e) {
      _showErrorDialog('Failed to create public token');
    }
  }

  Future<void> _exchangePublicToken(String publicToken) async {
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
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _fetchAccountNumbers();
      } else {
        throw Exception('Failed to exchange public token');
      }
    } catch (e) {
      _showErrorDialog('Failed to exchange public token');
    }
  }

  Future<void> _fetchAccountNumbers() async {
    if (_accessToken == null) {
      _showErrorDialog('Access token is not available');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/auth/get'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "access_token": _accessToken
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accounts = data['numbers']['ach'] as List;

        if (accounts.isNotEmpty) {
          setState(() {
            _accountNumbers = accounts
                .map((account) => account['account'] as String)
                .toList();
            _accountNumberToId = {
              for (var item in accounts)
                item['account'] as String: item['account_id'] as String
            };
          });
        }
      } else {
        throw Exception('Failed to fetch account numbers');
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch account numbers');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToNextScreen() {
    if (_selectedAccountNumber == null || _recipientController.text.isEmpty) {
      _showErrorDialog(
          'Please select an account and enter the recipient name.');
      return;
    }

    final accountId = _accountNumberToId[_selectedAccountNumber];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Payment(
          accountId: accountId ?? '',
          recipientName: _recipientController.text,
          accessToken: _accessToken!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedAccountNumber,
                hint: const Text('Select Account'),
                items: _accountNumbers.map((String account) {
                  return DropdownMenuItem<String>(
                    value: account,
                    child: Text(account),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAccountNumber = newValue;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Account Number',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _recipientController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Recipient Name',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToNextScreen,
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
