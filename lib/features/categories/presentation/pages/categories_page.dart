import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: const Center(
        child: Text(
          'Categories feature coming in Phase 2!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
