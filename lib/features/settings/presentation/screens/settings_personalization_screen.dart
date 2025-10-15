import 'package:flutter/material.dart';

class SettingsPersonalizationScreen extends StatelessWidget {
  const SettingsPersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnalisation de l’app'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Placeholder pour les préférences du tableau de bord et des rapports.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
