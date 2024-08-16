import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trasnfer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              child: Text('Trasnfer'),
            ),
          ],
        ),
      ),
    );
  }
}
