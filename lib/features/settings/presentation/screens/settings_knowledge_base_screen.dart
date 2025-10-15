import 'package:flutter/material.dart';

class SettingsKnowledgeBaseScreen extends StatelessWidget {
  const SettingsKnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Base de connaissances'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Placeholder pour la consultation de la base de connaissances.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
