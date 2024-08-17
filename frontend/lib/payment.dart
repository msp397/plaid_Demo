import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:http/http.dart' as http;

class Payment extends StatefulWidget {
  final String accountId;
  final String recipientName;
  final String accessToken;
  const Payment(
      {super.key,
      required this.accountId,
      required this.recipientName,
      required this.accessToken});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  LinkConfiguration? _configuration;
  String linkToken = '';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String transferIntentId = '';
  String authId = '';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
    _setupPlaidLinkStreams();
  }

  void _setupPlaidLinkStreams() {
    PlaidLink.onSuccess.listen((success) {
      print(success);
      // _authorizeTransfer();
    });

    PlaidLink.onExit.listen((exit) {
      if (exit.error != null) {
        print('Plaid Link Exit: ${exit.error}');
      } else {
        print('Plaid Link exited without error');
      }
    });
  }

  String _formatAmount(String amount) {
    try {
      final double value = double.parse(amount);
      return value
          .toStringAsFixed(2); // Ensure the amount has two decimal places
    } catch (e) {
      print('Error formatting amount: $e');
      return amount; // Return original if formatting fails
    }
  }

  Future<void> _createTransferIntend() async {
    try {
      final formattedAmount = _formatAmount(_amountController.text);
      print(formattedAmount);
      final response = await http.post(
        Uri.parse("https://sandbox.plaid.com/transfer/intent/create"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "account_id": widget.accountId,
          "mode": "DISBURSEMENT",
          "amount": formattedAmount,
          "description": _descriptionController.text,
          "ach_class": "ppd",
          "user": {"legal_name": widget.recipientName.toString()}
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          var data = jsonDecode(response.body);
          transferIntentId = data['transfer_intent']['id'];
          _createLinkToken();
        });
      } else {
        print('Failed to create transfer intent');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _createLinkToken() async {
    try {
      final response = await http.post(
        Uri.parse("https://sandbox.plaid.com/link/token/create"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user": {"client_user_id": "App123"},
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "access_token": widget.accessToken,
          "client_name": "Torus Pay",
          "products": ["transfer"],
          "transfer": {"intent_id": transferIntentId},
          "country_codes": ["US"],
          "language": "en",
          "webhook": "https://www.genericwebhookurl.com/webhook",
          "android_package_name": "com.example.frontend",
          'link_customization_name': 'tpay'
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          linkToken = jsonDecode(response.body)['link_token'];
          _configuration = LinkTokenConfiguration(token: linkToken);
          PlaidLink.open(configuration: _configuration!);
        });
      } else {
        print('Failed to create link token');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Future<void> _authorizeTransfer() async {
  //   try {
  //     final formattedAmount = _formatAmount(_amountController.text);
  //     final response = await http.post(
  //       Uri.parse("https://sandbox.plaid.com/transfer/authorization/create"),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         "client_id": "66b59ad4f271e2001a12e6ca",
  //         "secret": "3cea473d8ef5b0d0657275a727fece",
  //         "access_token": widget.accessToken,
  //         "account_id": widget.accountId,
  //         "type": "credit",
  //         "network": "ach",
  //         "amount": formattedAmount,
  //         "ach_class": "ppd",
  //         "user": {
  //           "legal_name": widget.recipientName,
  //           "email_address": "test@email.com",
  //           "phone_number": null,
  //           "address": {
  //             "street": "test",
  //             "city": "test",
  //             "region": "CA",
  //             "postal_code": "94053",
  //             "country": "US"
  //           }
  //         },
  //       }),
  //     );
  //     print(response.body);
  //     print(response.statusCode);
  //     if (response.statusCode == 200) {
  //       var data = jsonDecode(response.body);
  //       if (data['authorization']['decision'] == "approved") {
  //         setState(() {
  //           authId = data['authorization']['id'];
  //           _initiateTransfer();
  //         });
  //       }
  //     } else {
  //       throw Exception('Failed to authorize transfer');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  // Future<void> _initiateTransfer() async {
  //   try {
  //     final formattedAmount = _formatAmount(_amountController.text);
  //     final response = await http.post(
  //       Uri.parse("https://sandbox.plaid.com/transfer/create"),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         "client_id": "66b59ad4f271e2001a12e6ca",
  //         "secret": "3cea473d8ef5b0d0657275a727fece",
  //         "idempotency_key": "test123",
  //         "access_token": widget.accessToken,
  //         "account_id": widget.accountId,
  //         "amount": formattedAmount,
  //         "description": _descriptionController.text,
  //         "metadata": {},
  //         "authorization_id": authId
  //       }),
  //     );
  //     print(response.body);
  //     print(response.statusCode);
  //     if (response.statusCode == 200) {
  //     } else {
  //       throw Exception('Failed to initiate transfer');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Added padding around the Column
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            // Enter amount TextField
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Enter amount',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Enter a description',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.name,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_descriptionController.text.isNotEmpty &&
                    _amountController.text.isNotEmpty) {
                  _createTransferIntend();
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Background color
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              ),
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
