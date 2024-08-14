import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/account_info.dart';
import 'package:frontend/utils/urls.dart';
import 'package:http/http.dart' as http;
import 'package:plaid_flutter/plaid_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    _createLinkToken();
    _setupPlaidLinkStreams();
  }

  Future<void> _createLinkToken() async {
    setState(() {
      linkToken = "link-sandbox-7ec7a20f-772f-4d69-8cf1-a7114fecd3dc";
      _configuration = LinkTokenConfiguration(token: linkToken);
    });
    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/" + URLS.create_link_token),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user": {"client_user_id": "App123"},
          "client_name": "Torus Pay",
          "products": ["auth"],
          "country_codes": ["US"],
          "language": "en",
        }),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        // linkToken = jsonDecode(response.body)['link_token'];
        setState(() {
          _configuration = LinkTokenConfiguration(token: linkToken);
        });
        print(linkToken);
      } else {
        throw Exception('Failed to create link token');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handleAddBank() {
    if (_configuration != null) {
      PlaidLink.open(
        configuration: _configuration!,
      );
    }
  }

  void _setupPlaidLinkStreams() {
    PlaidLink.onSuccess.listen((success) {
      print('Account Added SuccessFully');
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
      print(success.metadata.institution?.id);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AccountInfo(
                  accounts: accounts,
                  institution: institution,
                )),
      );
    });

    PlaidLink.onExit.listen((exit) {
      if (exit.error != null) {
        print('Plaid Link Exit: ${exit.error}');
      } else {
        print('Plaid Link exited without error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank transfer via TPay'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.account_balance,
              size: 70,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
              onPressed: _configuration != null ? _handleAddBank : null,
              child: Text('Add Bank Account'),
            ),
          ],
        ),
      ),
    );
  }
}
