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
          "user": {"client_user_id": "App123"},
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "client_name": "Torus Pay",
          "products": ["auth"],
          "country_codes": ["US"],
          "language": "en",
          "webhook": "https://www.genericwebhookurl.com/webhook",
          "android_package_name": "com.example.frontend",
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final linkToken = data['link_token'];
        await _getpulicToken();
      } else {}
    } catch (e) {
      throw Exception('Failed to create link token');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getpulicToken() async {
    setState(() {
      _isLoading = true;
    });

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
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final publicToken = data['public_token'];
        _exchangePublicToken(publicToken);
      }
    } catch (e) {
      throw Exception('Failed to create link token');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exchangePublicToken(String publicToken) async {
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
          "public_token": publicToken,
        }),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        await _getBalance(accessToken);
      } else {
        throw Exception('Failed to exchange public token');
      }
    } catch (e) {
      throw Exception('Error Exchange token');
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
        Uri.parse('https://sandbox.plaid.com/accounts/get'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "access_token": accessToken
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accounts = data['accounts'] as List<dynamic>? ?? [];

        String? accountBalance;

        for (var account in accounts) {
          if (account is Map<String, dynamic> &&
              account['account_id'] == widget.accountId) {
            final balances = account['balances'] as Map<String, dynamic>?;
            if (balances != null) {
              final availableBalance = balances['available'];
              accountBalance = availableBalance?.toString() ?? 'N/A';
            }
            break;
          }
        }

        setState(() {
          _balance =
              accountBalance ?? 'Account not found or balance unavailable';
        });
      } else {
        throw Exception('Failed to get balance');
      }
    } catch (e) {
      throw Exception('Error getting balance');
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
                ],
              ),
      ),
    );
  }
}
