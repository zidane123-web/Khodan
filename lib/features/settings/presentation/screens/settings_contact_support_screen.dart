import 'package:flutter/material.dart';

class SettingsContactSupportScreen extends StatelessWidget {
  const SettingsContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacter le support'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Placeholder pour envoyer un message ou obtenir les coordonnées du support.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
