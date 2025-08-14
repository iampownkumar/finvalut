import 'package:flutter/material.dart';

class CreditCardsPage extends StatelessWidget {
  const CreditCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Cards'),
      ),
      body: const Center(
        child: Text(
          'Credit Cards feature coming in Phase 3!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
