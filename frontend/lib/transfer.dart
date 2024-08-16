import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Transfer extends StatefulWidget {
  const Transfer({super.key});

  @override
  State<Transfer> createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  late SharedPreferences prefs;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String publicToken = '';
  String accessToken = '';
  String authorizeID = '';
  bool _enableTransfer = false;

  @override
  void initState() {
    super.initState();
    _getpulicToken();
    initSharedPrefs();
  }

  void initSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _getpulicToken() async {
    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/sandbox/public_token/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "institution_id": "ins_20",
          "initial_products": ["transfer"],
          "options": {"webhook": "https://www.genericwebhookurl.com/webhook"}
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          publicToken = data['public_token'];
        });
        _exchangePublicToken();
      }
    } catch (e) {
      throw Exception('Failed to create public token');
    }
  }

  Future<void> _exchangePublicToken() async {
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
        accessToken = data['access_token'];
        // prefs.setString('access-token', accessToken);
        _authGet();
      } else {
        throw Exception('Failed to exchange public token');
      }
    } catch (e) {
      throw Exception('Error Exchange token');
    }
  }

  Future<void> _authGet() async {
    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/auth/get'),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "access_token": accessToken,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
      } else {
        print('Error Getting auth data ${response.statusCode}');
      }
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> _authorizeTransfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://sandbox.plaid.com/transfer/authorization/create"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "access_token": accessToken,
          "account_id": _accountNumberController.text,
          "type": "debit",
          "network": "ach",
          "amount": "0.10",
          "ach_class": "ppd",
          "user": {
            "legal_name": "test",
            "email_address": "test@email.com",
            "phone_number": null,
            "address": {
              "street": "test",
              "city": "test",
              "region": "CA",
              "postal_code": "94053",
              "country": "US"
            }
          },
        }),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          _enableTransfer = true;
        });
      } else {
        throw Exception('Failed to authorize transfer');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _initiateTransfer() async {
    try {
      final response = await http.post(
        Uri.parse("https://sandbox.plaid.com/transfer/create"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "idempotency_key": "test123",
          "access_token": accessToken,
          "account_id": _accountNumberController.text,
          "amount": "0.10",
          "description": "test",
          "metadata": {},
          "authorization_id": "a024679b-9f93-553b-5e3a-77455ddb0ab9"
        }),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {});
      } else {
        throw Exception('Failed to initiate transfer');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Funds'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountNumberController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Account Number",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an account number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _authorizeTransfer,
                  child: const Text("Authorize"),
                ),
                const SizedBox(height: 16),
                _enableTransfer
                    ? ElevatedButton(
                        onPressed: _initiateTransfer,
                        child: const Text("Proceed"),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
