import 'dart:convert';
import 'package:flutter/material.dart';
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
      title: 'Bank Transfer App',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
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

  Future<void> _createLinkToken() async {
    const String backendUrl = 'http://localhost:3000/api/create-link-token';

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
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
        final String linkToken = jsonDecode(response.body)['link_token'];
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
                  ? () {
                      PlaidLink.open(configuration: _configuration!);
                    }
                  : null,
              child: Text('Add Bank'),
            ),
          ],
        ),
      ),
    );
  }
}
