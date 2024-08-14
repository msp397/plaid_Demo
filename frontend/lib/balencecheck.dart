import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BalanceCheck extends StatefulWidget {
  const BalanceCheck({super.key, this.accountId});

  final String? accountId;

  @override
  State<BalanceCheck> createState() => _BalanceCheckState();
}

class _BalanceCheckState extends State<BalanceCheck> {
  bool _isLoading = false;
  String? _balance;

  @override
  void initState() {
    super.initState();
    _createPublicToken();
  }

  Future<void> _createPublicToken() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('http://192.168.2.85:3000/balance/balance-auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "institution_id": "ins_3",
          "initial_products": ["auth"],
          "options": {"webhook": "https://www.genericwebhookurl.com/webhook"}
        }),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final linkToken = data['public_token'];
        await _exchangePublicToken(linkToken);
      } else {
        print(
            'Failed to create public token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _exchangePublicToken(String publicToken) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.2.85:3000/balance/exchange-public-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"public_token": publicToken}),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        await _getBalance(accessToken);
      } else {
        print(
            'Failed to exchange public token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _getBalance(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.2.85:3000/balance/check-balance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"access_token": accessToken}),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _balance = data['balance'];
        });
      } else {
        print('Failed to get balance. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance Check'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
                'Account ID: ${widget.accountId ?? 'N/A'}\nBalance: ${_balance ?? 'N/A'}'),
      ),
    );
  }
}
