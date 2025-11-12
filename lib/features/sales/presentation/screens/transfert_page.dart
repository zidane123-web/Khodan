import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/rabbit_transfer.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/finance_repository.dart';
import '../../../../data/services/rabbit_sales_service.dart';
import '../cubit/sales_cubit.dart';
import '../cubit/sales_state.dart';

class TransfertPage extends StatelessWidget {
  const TransfertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SalesCubit>(
      create: (BuildContext context) => SalesCubit(
        salesService: context.read<RabbitSalesService>(),
        animalRepository: context.read<AnimalRepository>(),
        financeRepository: context.read<FinanceRepository>(),
      )..loadAll(),
      child: const _TransferView(),
    );
  }
}

class _TransferView extends StatelessWidget {
  const _TransferView();

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
            title: const Text('Transferts'),
            actions: <Widget>[
              IconButton(
                onPressed: state.isLoading
                    ? null
                    : () => context.read<SalesCubit>().loadAll(),
                icon: const Icon(Icons.refresh_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openTransferDialog(context, state),
            child: const Icon(Icons.swap_horiz_outlined),
          ),
          body: state.isLoading && state.transfers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.transfers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final RabbitTransfer transfer = state.transfers[index];
                    return _TransferCard(transfer: transfer);
                  },
                ),
        );
      },
    );
  }

  Future<void> _openTransferDialog(
    BuildContext context,
    SalesState state,
  ) async {
    final SalesCubit cubit = context.read<SalesCubit>();
    if (state.sellableAnimals.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Aucun lapin disponible pour transfert')),
        );
      return;
    }
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String? animalId = state.sellableAnimals.first.id;
    final TextEditingController recipientController = TextEditingController();
    final TextEditingController feeController = TextEditingController();
    String? notes;
    DateTime? expiry;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: const Text('Nouveau transfert'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // ignore: deprecated_member_use
                      DropdownButtonFormField<String>(
                        initialValue: animalId,
                        decoration: const InputDecoration(labelText: 'Lapin'),
                        items: state.sellableAnimals
                            .map(
                              (Animal animal) => DropdownMenuItem<String>(
                                value: animal.id,
                                child: Text(animal.tagId),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (String? value) {
                          setModalState(() => animalId = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: recipientController,
                        decoration: const InputDecoration(
                          labelText: 'Profil destinataire (UUID ou e-mail)',
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Champ obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: feeController,
                        decoration: const InputDecoration(
                          labelText: 'Frais logistique (optionnel)',
                          prefixIcon: Icon(Icons.money_outlined, size: 18),
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                        ),
                        maxLines: 3,
                        onChanged: (String value) => notes = value,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.calendar_today_outlined, size: 18),
                          onPressed: () async {
                            final DateTime now = DateTime.now();
                            final DateTime? result = await showDatePicker(
                              context: context,
                              firstDate: now,
                              lastDate: now.add(const Duration(days: 30)),
                              initialDate:
                                  expiry ?? now.add(const Duration(days: 2)),
                            );
                            if (result != null) {
                              setModalState(() => expiry = result);
                            }
                          },
                          label: Text(
                            expiry == null
                                ? 'Expiration par défaut (48h)'
                                : 'Expire le ${expiry!.day}/${expiry!.month}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }
                    await cubit.initiateTransfer(
                      RabbitTransferRequest(
                        animalId: animalId!,
                        recipientProfileId: recipientController.text.trim(),
                        transferFee: double.tryParse(
                              feeController.text.replaceAll(',', '.'),
                            ) ??
                            0,
                        notes: notes,
                        expiresAt: expiry,
                      ),
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Envoyer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TransferCard extends StatelessWidget {
  const _TransferCard({required this.transfer});

  final RabbitTransfer transfer;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.swap_horiz_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(transfer.animalTag ?? transfer.animalId),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Destinataire: ${transfer.recipientProfileId}'),
            if (transfer.expiresAt != null)
              Text(
                'Expire le ${transfer.expiresAt!.day}/${transfer.expiresAt!.month}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: <Widget>[
            Chip(label: Text(_label(transfer.status))),
            if (transfer.status == RabbitTransferStatus.pending)
              IconButton(
                tooltip: 'Accepter',
                onPressed: () =>
                    context.read<SalesCubit>().acceptTransfer(transfer.id),
                icon: const Icon(Icons.check_circle_outline),
              ),
            if (transfer.status == RabbitTransferStatus.pending)
              IconButton(
                tooltip: 'Rejeter',
                onPressed: () =>
                    context.read<SalesCubit>().rejectTransfer(transfer.id),
                icon: const Icon(Icons.close_outlined),
              ),
          ],
        ),
      ),
    );
  }

  static String _label(RabbitTransferStatus status) {
    switch (status) {
      case RabbitTransferStatus.pending:
        return 'En attente';
      case RabbitTransferStatus.accepted:
        return 'Accepté';
      case RabbitTransferStatus.rejected:
        return 'Rejeté';
      case RabbitTransferStatus.cancelled:
        return 'Annulé';
      case RabbitTransferStatus.completed:
        return 'Terminé';
    }
  }
}
