import 'package:flutter/material.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

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
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center, // Center text inside TextField
            ),
            const SizedBox(height: 20),
            // Description Text
            const Text(
              'Payment Description',
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(),
            // Pay button
            ElevatedButton(
              onPressed: () {
                // Handle pay button pressed
                final amount = _amountController.text;
                // You can handle the payment logic here
                print('Amount to pay: $amount');
              },
              child: const Text('Pay'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Background color
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
