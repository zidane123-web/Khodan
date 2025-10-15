import 'package:flutter/material.dart';

class SettingsProfileScreen extends StatelessWidget {
  const SettingsProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil utilisateur'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Placeholder pour la gestion du profil et des informations de compte.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
