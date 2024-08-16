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
    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/link/token/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "client_name": "Torus Pay",
          "institution_id": "ins_3",
          "initial_products": ["auth"],
          "options": {"webhook": "https://www.genericwebhookurl.com/webhook"},
          "webhook": "https://www.genericwebhookurl.com/webhook",
          "android_package_name": "com.example.frontend",
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
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Balance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),
            Text(
              '${_balance ?? 'N/A'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
