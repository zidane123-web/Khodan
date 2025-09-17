import 'package:flutter/material.dart';

class TasksList extends StatelessWidget {
  const TasksList({
    required this.title,
    required this.tasks,
    super.key,
  });

  final String title;
  final List<String> tasks;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              Text(
                'Aucune tâche à afficher',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...tasks.map(
                (String task) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(task),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
