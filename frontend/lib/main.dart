import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/utils/urls.dart';
import 'package:http/http.dart' as http;
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:js_util' as js_util;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank Transfer App',
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

  Future<void> _createLinkToken() async {
    try {
      final response = await http.post(
        Uri.parse(URLS.base_url + URLS.create_link_token),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user": {"client_user_id": "App123"},
          "client_name": "Plaid App",
          "products": ["auth"],
          "country_codes": ["GB"],
          "language": "en",
        }),
      );
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        linkToken = jsonDecode(response.body)['link_token'];
        print(linkToken);
        setState(() {
          _configuration = LinkTokenConfiguration(token: linkToken);
        });
      } else {
        throw Exception('Failed to create link token');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handleAddBank() {
    if (kIsWeb) {
      _openPlaidLinkWeb();
    } else {
      if (_configuration != null) {
        PlaidLink.open(configuration: _configuration!);
      }
    }
  }

  void _openPlaidLinkWeb() {
    if (_configuration != null) {
      js_util.callMethod(html.window, 'openPlaidLink', [linkToken]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bank Transfer App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _createLinkToken,
              child: Text("Create Link Token"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _configuration != null
                  ? kIsWeb
                      ? _openPlaidLinkWeb
                      : _handleAddBank
                  : null,
              child: Text('Add Bank'),
            ),
          ],
        ),
      ),
    );
  }
}
