import 'package:flutter/material.dart';

class SettingsLogsScreen extends StatelessWidget {
  const SettingsLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journaux & diagnostics'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Placeholder pour consulter les journaux et exporter les diagnostics.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
