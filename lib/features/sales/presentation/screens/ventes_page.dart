import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/rabbit_sale.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/finance_repository.dart';
import '../../../../data/services/rabbit_sales_service.dart';
import '../cubit/sales_cubit.dart';
import '../cubit/sales_state.dart';
import '../widgets/nouvelle_vente_form.dart';

class VentesPage extends StatelessWidget {
  const VentesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SalesCubit>(
      create: (BuildContext context) => SalesCubit(
        salesService: context.read<RabbitSalesService>(),
        animalRepository: context.read<AnimalRepository>(),
        financeRepository: context.read<FinanceRepository>(),
      )..loadAll(),
      child: const VentesView(),
    );
  }
}

class VentesView extends StatelessWidget {
  const VentesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SalesCubit, SalesState>(
      listenWhen: (SalesState previous, SalesState current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (BuildContext context, SalesState state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (BuildContext context, SalesState state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ventes'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Exporter CSV',
                onPressed: state.filteredSales.isEmpty || state.isExporting
                    ? null
                    : () async {
                        final SalesCubit cubit = context.read<SalesCubit>();
                        final ScaffoldMessengerState messenger =
                            ScaffoldMessenger.of(context);
                        final String? filename = await cubit.exportSalesCsv();
                        if (filename != null) {
                          messenger
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(content: Text('$filename enregistré')),
                            );
                        }
                      },
                icon: state.isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined),
              ),
              IconButton(
                tooltip: 'Actualiser',
                onPressed: state.isLoading
                    ? null
                    : () => context.read<SalesCubit>().refreshSales(),
                icon: const Icon(Icons.refresh_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openNewSaleForm(context, state),
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle vente'),
          ),
          body: state.isLoading && state.sales.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool isWide = constraints.maxWidth > 900;
                    return RefreshIndicator(
                      onRefresh: context.read<SalesCubit>().refreshSales,
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: <Widget>[
                          _FiltersBar(isWide: isWide),
                          const SizedBox(height: 24),
                          if (state.filteredSales.isEmpty)
                            const _EmptyState()
                          else
                            _SalesCollection(
                              sales: state.filteredSales,
                              isWide: isWide,
                            ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _openNewSaleForm(BuildContext context, SalesState state) async {
    final SalesCubit cubit = context.read<SalesCubit>();
    final List<Animal> animals = state.sellableAnimals;
    if (animals.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Aucun lapin disponible à la vente.')),
        );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NouvelleVenteForm(
          animals: animals,
          contacts: state.contacts,
          onSubmit: (RabbitSaleDraft draft) => cubit.createSale(draft),
        );
      },
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final SalesState state = context.watch<SalesCubit>().state;
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 220,
          child: // ignore: deprecated_member_use
              DropdownButtonFormField<RabbitSaleStatus?>(
            initialValue: state.statusFilter,
            decoration: const InputDecoration(
              labelText: 'Statut',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: <DropdownMenuItem<RabbitSaleStatus?>>[
              const DropdownMenuItem<RabbitSaleStatus?>(
                value: null,
                child: Text('Tous les statuts'),
              ),
              ...RabbitSaleStatus.values.map(
                (RabbitSaleStatus status) => DropdownMenuItem<RabbitSaleStatus?>(
                  value: status,
                  child: Text(_statusLabel(status)),
                ),
              ),
            ],
            onChanged: context.read<SalesCubit>().updateStatusFilter,
          ),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(
            state.periodFilter == null
                ? 'Période'
                : '${state.periodFilter!.start.day}/${state.periodFilter!.start.month} - '
                    '${state.periodFilter!.end.day}/${state.periodFilter!.end.month}',
          ),
          onPressed: () async {
            final DateTime now = DateTime.now();
            final SalesCubit cubit = context.read<SalesCubit>();
            final DateTimeRange? range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 1),
              initialDateRange: state.periodFilter ??
                  DateTimeRange(
                    start: DateTime(now.year, now.month, 1),
                    end: now,
                  ),
            );
            cubit.updatePeriodFilter(range);
          },
        ),
        if (state.periodFilter != null)
          TextButton(
            onPressed: () =>
                context.read<SalesCubit>().updatePeriodFilter(null),
            child: const Text('Réinitialiser la période'),
          ),
      ],
    );
  }

  static String _statusLabel(RabbitSaleStatus status) {
    switch (status) {
      case RabbitSaleStatus.draft:
        return 'Brouillon';
      case RabbitSaleStatus.pending:
        return 'En attente';
      case RabbitSaleStatus.completed:
        return 'Confirmée';
      case RabbitSaleStatus.cancelled:
        return 'Annulée';
    }
  }
}

class _SalesCollection extends StatelessWidget {
  const _SalesCollection({required this.sales, required this.isWide});

  final List<RabbitSale> sales;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: sales.length,
        itemBuilder: (BuildContext context, int index) =>
            _SaleCard(sale: sales[index]),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) =>
          _SaleCard(sale: sales[index]),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: sales.length,
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale});

  final RabbitSale sale;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  sale.animalTag ?? sale.animalId,
                  style: theme.textTheme.titleMedium,
                ),
                Chip(
                  label: Text(_statusLabel(sale.status)),
                  backgroundColor: _statusColor(theme, sale.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${sale.price.toStringAsFixed(0)} ${sale.currency}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sale.contactName ?? 'Sans contact',
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (sale.status == RabbitSaleStatus.pending)
                  TextButton.icon(
                    onPressed: () =>
                        context.read<SalesCubit>().completeSale(sale.id),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirmer'),
                  ),
                if (sale.status == RabbitSaleStatus.pending)
                  TextButton.icon(
                    onPressed: () =>
                        context.read<SalesCubit>().cancelSale(sale.id),
                    icon: const Icon(Icons.close),
                    label: const Text('Annuler'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(RabbitSaleStatus status) =>
      _FiltersBar._statusLabel(status);

  static Color _statusColor(ThemeData theme, RabbitSaleStatus status) {
    switch (status) {
      case RabbitSaleStatus.completed:
        return theme.colorScheme.secondaryContainer;
      case RabbitSaleStatus.cancelled:
        return theme.colorScheme.errorContainer;
      case RabbitSaleStatus.pending:
        return theme.colorScheme.tertiaryContainer;
      case RabbitSaleStatus.draft:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Icon(Icons.shopping_basket_outlined, size: 64),
        const SizedBox(height: 12),
        Text(
          'Aucune vente pour l’instant.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        const Text('Créez une vente locale ou utilisez la marketplace.'),
      ],
    );
  }
}
