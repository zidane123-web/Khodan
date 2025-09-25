import 'package:flutter/material.dart';

class BreedingRecordDetailScreen extends StatelessWidget {
  const BreedingRecordDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la saillie'),
      ),
      body: const Center(
        child: Text('Détails de la saillie'),
      ),
    );
  }
}
