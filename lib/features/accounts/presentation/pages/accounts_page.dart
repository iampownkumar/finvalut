import 'package:flutter/material.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: const Center(
        child: Text(
          'Accounts feature coming in Phase 2!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
