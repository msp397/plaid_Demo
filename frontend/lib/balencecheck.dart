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
  String _error = '';

  @override
  void initState() {
    super.initState();
    _createLinkToken();
  }

  Future<void> _createLinkToken() async {
    setState(() {
      _isLoading = true;
    });

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final linkToken = data['link_token'];
        await _exchangeLinkToken(linkToken);
      } else {
        setState(() {
          _error =
              'Failed to create link token. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exchangeLinkToken(String public_token) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/item/public_token/exchange'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "public_token": public_token,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        await _getBalance(accessToken);
      } else {
        setState(() {
          _error =
              'Failed to exchange link token. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getBalance(String accessToken) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/accounts/balance/get'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "access_token": accessToken
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final balance = data['accounts'][0]['balances']['available'];
        setState(() {
          _balance = balance.toString();
        });
      } else {
        setState(() {
          _error = 'Failed to get balance. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
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
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Balance',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                  Text(
                    _balance ?? 'N/A',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
