import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Mode hors-ligne'),
            subtitle: const Text('Synchronise automatiquement dès le retour du réseau.'),
            value: true,
            onChanged: (bool value) {},
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Gestion des espèces'),
            subtitle: const Text('Configurer les durées de gestation et sevrage.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Assistance'),
            subtitle: const Text('Consulter la base de connaissances et contacter le support.'),
            trailing: const Icon(Icons.help_outline),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
