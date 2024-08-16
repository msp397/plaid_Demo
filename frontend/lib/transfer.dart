import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class Transfer extends StatefulWidget {
  const Transfer({super.key});

  @override
  State<Transfer> createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  final TextEditingController _amountController = TextEditingController();
  String publicToken = '';
  String accessToken = '';
  String authorizeID = '';
  bool _enableTransfer = false;

  @override
  void initState() {
    super.initState();
    _createPublicToken();
  }

  Future<void> _createPublicToken() async {
    setState(() {
      publicToken = "link-sandbox-7ec7a20f-772f-4d69-8cf1-a7114fecd3dc";
    });
    try {
      final response = await http.post(
        Uri.parse("http://192.168.2.32:3000/api/create-public-token"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          {
            "institution_id": "ins_20", // need to pass dynamically
            "initial_products": ["auth"],
            "options": {"webhook": "https://www.genericwebhookurl.com/webhook"}
          }
        }),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          publicToken = jsonDecode(response.body)['public_token'];
          _exchangePublicToken();
        });
      } else {
        throw Exception('Failed to create public token');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _exchangePublicToken() async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.2.32:3000/api/exchange-public-token"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          {"public_token": publicToken}
        }),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          accessToken = jsonDecode(response.body)['access_token'];
        });
      } else {
        throw Exception('Failed to create public token');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _authorizeTransfer() async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.2.32:3000/transfer/authorize"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "access_token": accessToken,
          "account_id": "3obxqX6D34TXGyPpKepDurB8KqkaJBCZEZoAZ",
          "type": "credit",
          "network": "ach",
          "amount": _amountController.text,
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
        Uri.parse("http://192.168.2.32:3000/transfer/initiate"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "idempotency_key": "test123",
          "access_token": accessToken,
          "account_id": "3obxqX6D34TXGyPpKepDurB8KqkaJBCZEZoAZ",
          "amount": "12.34",
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Amount",
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _authorizeTransfer,
              child: Text("Authorize"),
            ),
            _enableTransfer
                ? ElevatedButton(
                    onPressed: _initiateTransfer,
                    child: Text("Proceed"),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
