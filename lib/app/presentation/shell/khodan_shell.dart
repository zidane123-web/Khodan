import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

class KhodanShellDestination {
  const KhodanShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class KhodanShellExtraDestination {
  const KhodanShellExtraDestination({
    required this.route,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String route;
  final String label;
  final String description;
  final IconData icon;
}

class KhodanShell extends StatefulWidget {
  const KhodanShell({
    required this.navigationShell,
    required this.destinations,
    required this.moreDestinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<KhodanShellDestination> destinations;
  final List<KhodanShellExtraDestination> moreDestinations;

  @override
  State<KhodanShell> createState() => _KhodanShellState();
}

class _KhodanShellState extends State<KhodanShell> {
  static const double _desktopBreakpoint = 1024;
  static const double _compactRailBreakpoint = 840;

  int get _selectedIndex => widget.navigationShell.currentIndex;
  int get _moreIndex => widget.destinations.length;

  @override
  Widget build(BuildContext context) {
    final bool useRail =
        MediaQuery.sizeOf(context).width >= _desktopBreakpoint;
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        top: !useRail,
        bottom: !useRail,
        child: useRail ? _buildRailLayout(context, theme) : _buildBody(),
      ),
      bottomNavigationBar: useRail ? null : _buildBottomNavigation(l10n),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWorkInProgressSnack(context, l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.placeholderFabLabel),
      ),
      floatingActionButtonLocation: useRail
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    return widget.navigationShell;
  }

  Widget _buildRailLayout(BuildContext context, ThemeData theme) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool useExtendedRail =
        MediaQuery.sizeOf(context).width >= _desktopBreakpoint + 160;

    return Row(
      children: <Widget>[
        NavigationRail(
          extended: useExtendedRail,
          minExtendedWidth: 220,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            if (index != _selectedIndex) {
              widget.navigationShell.goBranch(index);
            }
          },
          labelType: useExtendedRail
              ? NavigationRailLabelType.none
              : NavigationRailLabelType.selected,
          leading: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Icon(
              Icons.pets,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          destinations: widget.destinations
              .map(
                (KhodanShellDestination destination) => NavigationRailDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: Text(destination.label),
                ),
              )
              .toList(),
          trailing: _buildRailTrailing(context, l10n),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: widget.navigationShell,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildRailTrailing(BuildContext context, AppLocalizations l10n) {
    if (widget.moreDestinations.isEmpty) {
      return null;
    }

    final bool compact =
        MediaQuery.sizeOf(context).width < _compactRailBreakpoint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: IconButton(
        tooltip: l10n.navMore,
        onPressed: () => _openMoreMenu(context, l10n),
        icon: Icon(compact ? Icons.more_vert : Icons.apps),
      ),
    );
  }

  Widget _buildBottomNavigation(AppLocalizations l10n) {
    final List<NavigationDestination> destinations =
        widget.destinations.map(_mapDestination).toList();
    if (widget.moreDestinations.isNotEmpty) {
      destinations.add(
        NavigationDestination(
          icon: const Icon(Icons.more_horiz),
          selectedIcon: const Icon(Icons.more_horiz),
          label: l10n.navMore,
        ),
      );
    }

    return NavigationBar(
      selectedIndex: _selectedIndex,
      destinations: destinations,
      onDestinationSelected: (int index) {
        if (index == _moreIndex && widget.moreDestinations.isNotEmpty) {
          _openMoreMenu(context, l10n);
          return;
        }
        if (index != _selectedIndex) {
          widget.navigationShell.goBranch(index);
        }
      },
    );
  }

  NavigationDestination _mapDestination(KhodanShellDestination destination) {
    return NavigationDestination(
      icon: Icon(destination.icon),
      selectedIcon: Icon(destination.selectedIcon),
      label: destination.label,
    );
  }

  Future<void> _openMoreMenu(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (BuildContext context, int index) {
              final KhodanShellExtraDestination destination =
                  widget.moreDestinations[index];
              return ListTile(
                leading: Icon(destination.icon),
                title: Text(destination.label),
                subtitle: Text(destination.description),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (!mounted) return;
                  context.go(destination.route);
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: widget.moreDestinations.length,
          ),
        );
      },
    );
  }

  void _showWorkInProgressSnack(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.placeholderFabMessage),
        ),
      );
  }
}
