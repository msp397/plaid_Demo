import 'dart:convert';
// import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/account_info.dart';
import 'package:http/http.dart' as http;
import 'package:plaid_flutter/plaid_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TPay',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LinkConfiguration? _configuration;
  String linkToken = '';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _createLinkToken();
      // _setupPlaidLinkWeb();
    } else {
      _createLinkToken();
      _setupPlaidLinkStreams();
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
          "client_name": "Torus Pay",
          "products": ["auth", "transfer"],
          "country_codes": ["US"],
          "language": "en",
          "webhook": "https://www.genericwebhookurl.com/webhook",
          "android_package_name": "com.example.frontend",
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          linkToken = jsonDecode(response.body)['link_token'];
          _configuration = LinkTokenConfiguration(token: linkToken);
        });
      } else {
        throw Exception('Failed to create link token');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _createTransferIntent() async {
    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/transfer/intents/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "account_id": "3gE5gnRzNyfXpBK5wEEKcymJ5albGVUqg77gr",
          "mode": "PAYMENT",
          "amount": "12.34",
          "description": "Desc",
          "ach_class": "ppd",
          "origination_account_id": "9853defc-e703-463d-86b1-dc0607a45359",
          "user": {"legal_name": "Anne Charleston"}
        }),
      );

      if (response.statusCode == 200) {
        final transferIntent = jsonDecode(response.body);
        print('Transfer Intent Created: $transferIntent');
      } else {
        throw Exception('Failed to create transfer intent');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _setupPlaidLinkStreams() {
    PlaidLink.onSuccess.listen((success) {
      print('Account Added Successfully');
      var accounts = success.metadata.accounts.map((account) {
        return {
          'id': account.id,
          'name': account.name,
        };
      }).toList();

      var institution = {
        'id': success.metadata.institution?.id ?? 'N/A',
        'name': success.metadata.institution?.name ?? 'N/A',
      };
      // Navigator.pushReplacement(
      //   // ignore: use_build_context_synchronously
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => AccountInfo(
      //             accounts: accounts,
      //             institution: institution,
      //           )),
      // );
    });

    PlaidLink.onExit.listen((exit) {
      if (exit.error != null) {
        print('Plaid Link Exit: ${exit.error}');
      } else {
        print('Plaid Link exited without error');
      }
    });
  }

  void _setupPlaidLinkWeb() {
    //   // Check if Plaid script is already included
    //   if (html.document.querySelector(
    //           'script[src="https://cdn.plaid.com/link/v2/stable/link-initialize.js"]') ==
    //       null) {
    //     // Create Plaid Link script element
    //     final script = html.ScriptElement()
    //       ..src = 'https://cdn.plaid.com/link/v2/stable/link-initialize.js'
    //       ..type = 'text/javascript';

    //     // Append Plaid Link script to the document
    //     html.document.body?.append(script);
    //   }

    //   // Check if Plaid button already exists
    //   if (html.document.getElementById('link-button') == null) {
    //     final button = html.ButtonElement()
    //       ..id = 'link-button'
    //       ..text = 'Add Bank Account';

    //     html.document.body?.append(button);
    //   }

    //   // Create Plaid initialization script
    //   final plaidScript = html.ScriptElement()
    //     ..text = '''
    //   var handler = Plaid.create({
    //     clientName: 'Torus Pay',
    //     env: 'sandbox',
    //     token: '$linkToken',
    //     product: ['auth', 'transfer'],
    //     onSuccess: function(public_token, metadata) {
    //       window.postMessage({ public_token: public_token, metadata: metadata }, '*');
    //     },
    //     onExit: function(err, metadata) {
    //       if (err != null) {
    //         window.postMessage({ error: err.message }, '*');
    //       }
    //     }
    //   });

    //   document.getElementById('link-button').addEventListener('click', function() {
    //     handler.open();
    //   });
    // ''';

    //   // Append Plaid initialization script
    //   html.document.body?.append(plaidScript);

    //   // Listen for messages from the Plaid Link JavaScript SDK
    //   html.window.onMessage.listen((event) {
    //     final message = event.data;
    //     if (message is Map) {
    //       if (message.containsKey('public_token')) {
    //         // Handle success here
    //         print('Public Token: ${message['public_token']}');
    //         // You may want to send this token to your server and process it further
    //       } else if (message.containsKey('error')) {
    //         print('Plaid Link Error: ${message['error']}');
    //       }
    //     }
    //   });
  }

  void _handleAddBank() {
    if (kIsWeb) {
      _setupPlaidLinkWeb();
    } else if (_configuration != null) {
      PlaidLink.open(configuration: _configuration!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank transfer via TPay'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.account_balance,
              size: 70,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
                foregroundColor: MaterialStatePropertyAll(Colors.white),
              ),
              onPressed: _handleAddBank,
              child: const Text('Add Bank Account'),
            ),
          ],
        ),
      ),
    );
  }
}
