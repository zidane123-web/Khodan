import 'package:flutter/material.dart';

/// Écran principal du tableau de bord Khodan.
///
/// Contient :
/// - message d'accueil,
/// - actions rapides,
/// - menu + ouvrant un bottom sheet,
/// - cartes d'indicateurs avec valeurs temporaires,
/// - section planning mockée.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddMenu(context),
        tooltip: 'Ajouts rapides',
        child: const Icon(Icons.add),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isWide = constraints.maxWidth >= 900;
          final EdgeInsetsGeometry padding = EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: isWide ? 24 : 16,
          );

          final Widget content = _DashboardContent(
            isWide: isWide,
          );

          return SafeArea(
            child: Padding(
              padding: padding,
              child: isWide
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: content,
                      ),
                    )
                  : content,
            ),
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final List<Widget> leftColumnChildren = <Widget>[
      const _WelcomeMessage(),
      const SizedBox(height: 24),
      _QuickActions(isWide: isWide),
      const SizedBox(height: 24),
      _IndicatorsGrid(isWide: isWide),
    ];

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: leftColumnChildren,
            ),
          ),
          const SizedBox(width: 32),
          Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.topCenter,
              child: _PlanningSection(isWide: isWide),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ...leftColumnChildren,
          const SizedBox(height: 24),
          _PlanningSection(isWide: isWide),
        ],
      ),
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              'Bienvenue sur Khodan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Retrouvez vos elevages, vos actions rapides et les prochains evenements en un coup d\'oeil.',
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final SliverGridDelegateWithFixedCrossAxisCount gridDelegate =
        isWide ? _desktopDelegate : _mobileDelegate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: gridDelegate,
          itemCount: _DashboardMockData.quickActions.length,
          itemBuilder: (BuildContext context, int index) {
            final _DashboardAction action =
                _DashboardMockData.quickActions[index];
            return _QuickActionButton(action: action);
          },
        ),
      ],
    );
  }

  static const SliverGridDelegateWithFixedCrossAxisCount _mobileDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 1.8,
  );

  static const SliverGridDelegateWithFixedCrossAxisCount _desktopDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 2.2,
  );
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.action,
  });

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        alignment: Alignment.centerLeft,
      ),
      onPressed: action.onTap,
      icon: Icon(action.icon),
      label: Text(action.label),
    );
  }
}

class _IndicatorsGrid extends StatelessWidget {
  const _IndicatorsGrid({
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = isWide ? 2 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Indicateurs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isWide ? 2.4 : 2.2,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: _DashboardMockData.indicators
              .map((DashboardIndicator indicator) {
            return _IndicatorCard(indicator: indicator);
          }).toList(),
        ),
      ],
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  const _IndicatorCard({
    required this.indicator,
  });

  final DashboardIndicator indicator;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withAlpha((255 * 0.15).round()),
              child: Icon(
                indicator.icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    indicator.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    indicator.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    indicator.helper,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanningSection extends StatelessWidget {
  const _PlanningSection({
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final List<PlanningItem> items = _DashboardMockData.planning;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Planning des 7 prochains jours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Text('Aucune tâche à venir pour le moment.')
            else
              ...items.map((PlanningItem item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.event_note,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.date,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(item.label),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 12),
            Align(
              alignment: isWide ? Alignment.centerLeft : Alignment.center,
              child: OutlinedButton(
                onPressed: onOpenPlanning,
                child: const Text('Voir tout le planning'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardIndicator {
  const DashboardIndicator({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
  });

  final String title;
  final String value;
  final String helper;
  final IconData icon;
}

class PlanningItem {
  const PlanningItem({
    required this.date,
    required this.label,
  });

  final String date;
  final String label;
}

class _DashboardAction {
  const _DashboardAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _DashboardMockData {
  static final List<_DashboardAction> quickActions = <_DashboardAction>[
    _DashboardAction(
      label: 'Saillie',
      icon: Icons.favorite,
      onTap: onCreateBreeding,
    ),
    _DashboardAction(
      label: 'Mise bas',
      icon: Icons.cruelty_free,
      onTap: onCreateKindling,
    ),
    _DashboardAction(
      label: 'Pesée',
      icon: Icons.monitor_weight,
      onTap: onCreateWeighing,
    ),
    _DashboardAction(
      label: 'Abattage',
      icon: Icons.restaurant,
      onTap: onCreateHarvest,
    ),
  ];

  static final List<DashboardIndicator> indicators = <DashboardIndicator>[
    DashboardIndicator(
      title: 'Lapines actives',
      value: '12',
      helper: 'Données à connecter à Supabase.',
      icon: Icons.pets,
    ),
    DashboardIndicator(
      title: 'Lapins prêts pour la vente',
      value: '8',
      helper: 'Données à connecter à Supabase.',
      icon: Icons.shopping_basket,
    ),
    DashboardIndicator(
      title: 'Portées en cours',
      value: '5',
      helper: 'Données à connecter à Supabase.',
      icon: Icons.home,
    ),
    DashboardIndicator(
      title: 'Tâches en retard',
      value: '2',
      helper: 'Données à connecter à Supabase.',
      icon: Icons.warning_amber,
    ),
  ];

  static final List<PlanningItem> planning = <PlanningItem>[
    PlanningItem(
      date: '02/11',
      label: 'Palpation lapine #K-24',
    ),
    PlanningItem(
      date: '03/11',
      label: 'Préparer nid portée #P-18',
    ),
    PlanningItem(
      date: '05/11',
      label: 'Pesée portée #P-11',
    ),
  ];
}

// Les fonctions suivantes sont des stubs destinés à être branchés sur Supabase.
void onCreateBreeding() {
  debugPrint('TODO: implémenter la création de saillie.');
}

void onCreateKindling() {
  debugPrint('TODO: implémenter la déclaration de mise bas.');
}

void onCreateWeighing() {
  debugPrint('TODO: implémenter la saisie de pesée.');
}

void onCreateHarvest() {
  debugPrint('TODO: implémenter l\'enregistrement d\'abattage.');
}

void onQuickAddBreeder() {
  debugPrint('TODO: implémenter l\'ajout d\'un éleveur.');
}

void onQuickAddBreeding() {
  debugPrint('TODO: implémenter la planification d\'une saillie.');
}

void onQuickAddTask() {
  debugPrint('TODO: implémenter la création d\'une tâche.');
}

void onQuickAddLoss() {
  debugPrint('TODO: implémenter l\'enregistrement d\'une perte.');
}

void onOpenPlanning() {
  debugPrint('TODO: ouvrir l\'agenda complet.');
}

void _showQuickAddMenu(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Ajouter un éleveur'),
              onTap: () {
                Navigator.of(context).pop();
                onQuickAddBreeder();
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Planifier une saillie'),
              onTap: () {
                Navigator.of(context).pop();
                onQuickAddBreeding();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Créer une tâche'),
              onTap: () {
                Navigator.of(context).pop();
                onQuickAddTask();
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Enregistrer une perte'),
              onTap: () {
                Navigator.of(context).pop();
                onQuickAddLoss();
              },
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Plus d\'actions bientot.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    },
  );
}
