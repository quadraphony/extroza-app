import 'package:flutter/material.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: const Center(child: Text('User badges will be displayed here.')),
    );
  }
}