import 'package:flutter/material.dart';

import '../../../../data/models/breeding_record.dart';

class BreedingRecordScreen extends StatelessWidget {
  const BreedingRecordScreen({required this.record, super.key});

  final BreedingRecord record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la saillie'),
      ),
      body: Center(
        child: Text('Détails de la saillie pour ${record.id}'),
      ),
    );
  }
}
