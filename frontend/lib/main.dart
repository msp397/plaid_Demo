import 'dart:convert';
// import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/account_info.dart';
import 'package:frontend/transferui.dart';
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
      // home: HomeScreen(),
      home: TransferUI(),
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
  String publicToken = '';
  String accessToken = '';
  List<Map<String, String>> accounts = [];
  Map<String, String> institution = {};

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
          "products": ["auth"],
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
        print('Failed to create link token');
      }
    } catch (e) {
      print('Error: $e');
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
        setState(() {
          accessToken = data['access_token'];
        });
        // await _authGet();
        _routeAccountInfo();
      } else {
        throw Exception('Failed to exchange public token');
      }
    } catch (e) {
      print('Error Exchange token');
    }
  }

  Future<void> _authGet() async {
    try {
      final response = await http.post(
        Uri.parse('https://sandbox.plaid.com/auth/get'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client_id": "66b59ad4f271e2001a12e6ca",
          "secret": "3cea473d8ef5b0d0657275a727fece",
          "access_token": accessToken,
        }),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
      } else {
        throw Exception('Failed to exchange public token');
      }
    } catch (e) {
      print('Error Exchange token');
    }
  }

  void _setupPlaidLinkStreams() {
    PlaidLink.onSuccess.listen((success) {
      setState(() {
        print(success.publicToken.toString());
        publicToken = success.publicToken.toString();
        accounts = success.metadata.accounts.map((account) {
          return {
            'id': account.id,
            'name': account.name,
          };
        }).toList();

        institution = {
          'id': success.metadata.institution?.id ?? 'N/A',
          'name': success.metadata.institution?.name ?? 'N/A',
        };
      });
      print('Account Added Successfully');
      _exchangePublicToken();
    });

    PlaidLink.onExit.listen((exit) {
      if (exit.error != null) {
        print('Plaid Link Exit: ${exit.error}');
      } else {
        print('Plaid Link exited without error');
      }
    });
  }

  void _routeAccountInfo() {
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
          builder: (context) => AccountInfo(
                accounts: accounts,
                institution: institution,
              )),
    );
  }

  void _handleAddBank() {
    if (kIsWeb) {
      // _setupPlaidLinkWeb();
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
