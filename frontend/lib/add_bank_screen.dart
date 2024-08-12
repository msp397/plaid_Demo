import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class AddBankScreen extends StatefulWidget {
  @override
  _AddBankScreenState createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  String _linkToken = '';

  @override
  void initState() {
    super.initState();
    _createLinkToken();
  }

  Future<void> _createLinkToken() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/create_link_token'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _linkToken = data['link_token'];
        });
        print(data);
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

        // url: 'https://cdn.plaid.com/link/v2/stable/link.html?token=$_linkToken',
        // appBar: AppBar(title: Text('Plaid Link')),
        );
  }
}
