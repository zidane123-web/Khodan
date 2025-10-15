import 'package:flutter/material.dart';

class SettingsReferentialsScreen extends StatelessWidget {
  const SettingsReferentialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Référentiels d’élevage'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Placeholder pour la configuration des espèces, durées de gestation et de sevrage.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
