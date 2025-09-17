import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          _ReportCard(
            title: 'Taux de fertilité',
            description: 'Suivez les performances de vos accouplements mois par mois.',
          ),
          _ReportCard(
            title: 'Taille moyenne des portées',
            description: 'Analysez l’évolution du nombre de nés vivants par portée.',
          ),
          _ReportCard(
            title: 'Performances par reproducteur',
            description: 'Identifiez vos lapins les plus prolifiques.',
          ),
          _ReportCard(
            title: 'Finances',
            description: 'Suivez les ventes, achats et coûts d’alimentation.',
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Graphique à venir'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
