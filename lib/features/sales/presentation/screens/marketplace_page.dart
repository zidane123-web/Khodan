import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/marketplace_listing.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/finance_repository.dart';
import '../../../../data/services/rabbit_sales_service.dart';
import '../cubit/sales_cubit.dart';
import '../cubit/sales_state.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SalesCubit>(
      create: (BuildContext context) => SalesCubit(
        salesService: context.read<RabbitSalesService>(),
        animalRepository: context.read<AnimalRepository>(),
        financeRepository: context.read<FinanceRepository>(),
      )..loadAll(),
      child: const _MarketplaceView(),
    );
  }
}

class _MarketplaceView extends StatelessWidget {
  const _MarketplaceView();

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
        final bool isWide = MediaQuery.of(context).size.width > 800;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Marketplace'),
            actions: <Widget>[
              IconButton(
                onPressed: state.isLoading
                    ? null
                    : () => context.read<SalesCubit>().loadAll(),
                icon: const Icon(Icons.refresh_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openListingSheet(context),
            icon: const Icon(Icons.post_add_outlined),
            label: const Text('Publier'),
          ),
          body: state.isLoading && state.listings.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: state.listings.isEmpty
                      ? const _MarketplaceEmpty()
                      : GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 3 : 1,
                            childAspectRatio: isWide ? 1.2 : 1.6,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: state.listings.length,
                          itemBuilder: (BuildContext context, int index) {
                            final MarketplaceListing listing =
                                state.listings[index];
                            return _ListingCard(listing: listing);
                          },
                        ),
                ),
        );
      },
    );
  }

  Future<void> _openListingSheet(BuildContext context) async {
    final SalesCubit cubit = context.read<SalesCubit>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    bool negotiable = false;
    DateTime? expiresAt;
    String visibility = 'public';
    String? animalId;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Publier une annonce',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Titre'),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Titre obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),
                      // ignore: deprecated_member_use
                      DropdownButtonFormField<String>(
                        initialValue: animalId,
                        decoration: const InputDecoration(
                          labelText: 'Associer un lapin (optionnel)',
                        ),
                        items: context
                            .read<SalesCubit>()
                            .state
                            .sellableAnimals
                            .map(
                              (animal) => DropdownMenuItem<String>(
                                value: animal.id,
                                child: Text(animal.tagId),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) =>
                            setModalState(() => animalId = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Prix indicatif',
                          prefixIcon: Icon(Icons.attach_money, size: 18),
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                      ),
                      SwitchListTile(
                        title: const Text('Négociable'),
                        value: negotiable,
                        onChanged: (bool value) =>
                            setModalState(() => negotiable = value),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: // ignore: deprecated_member_use
                                DropdownButtonFormField<String>(
                              initialValue: visibility,
                              decoration:
                                  const InputDecoration(labelText: 'Visibilité'),
                              items: const <DropdownMenuItem<String>>[
                                DropdownMenuItem<String>(
                                  value: 'public',
                                  child: Text('Publique'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'private',
                                  child: Text('Privée'),
                                ),
                              ],
                              onChanged: (String? value) {
                                if (value != null) {
                                  setModalState(() => visibility = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                expiresAt == null
                                    ? 'Expire dans 30 j'
                                    : 'Expire le ${expiresAt!.day}/${expiresAt!.month}',
                              ),
                              onPressed: () async {
                                final DateTime now = DateTime.now();
                                final DateTime? result = await showDatePicker(
                                  context: context,
                                  firstDate: now,
                                  lastDate: now.add(const Duration(days: 90)),
                                  initialDate:
                                      expiresAt ?? now.add(const Duration(days: 30)),
                                );
                                if (result != null) {
                                  setModalState(() => expiresAt = result);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () async {
                            if (formKey.currentState?.validate() != true) {
                              return;
                            }
                            await cubit.publishListing(
                              MarketplaceListingDraft(
                                title: titleController.text.trim(),
                                animalId: animalId,
                                description: descriptionController.text.trim(),
                                price: double.tryParse(
                                  priceController.text.replaceAll(',', '.'),
                                ),
                                isNegotiable: negotiable,
                                visibility: visibility,
                                expiresAt: expiresAt,
                              ),
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Publier'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final MarketplaceListing listing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    listing.title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<MarketplaceListingStatus>(
                  onSelected: (MarketplaceListingStatus status) {
                    context
                        .read<SalesCubit>()
                        .updateListingStatus(listing.id, status);
                  },
                  itemBuilder: (BuildContext context) =>
                      MarketplaceListingStatus.values
                          .map(
                            (MarketplaceListingStatus status) =>
                                PopupMenuItem<MarketplaceListingStatus>(
                              value: status,
                              child: Text(_statusLabel(status)),
                            ),
                          )
                          .toList(),
                  child: Chip(
                    label: Text(_statusLabel(listing.status)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (listing.description != null)
              Text(
                listing.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            const Spacer(),
            Text(
              listing.price != null
                  ? '${listing.price!.toStringAsFixed(0)} ${listing.currency}'
                  : 'Prix à discuter',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              listing.isNegotiable ? 'Négociable' : 'Fixe',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(MarketplaceListingStatus status) {
    switch (status) {
      case MarketplaceListingStatus.draft:
        return 'Brouillon';
      case MarketplaceListingStatus.published:
        return 'Publiée';
      case MarketplaceListingStatus.paused:
        return 'En pause';
      case MarketplaceListingStatus.expired:
        return 'Expirée';
      case MarketplaceListingStatus.sold:
        return 'Vendu';
      case MarketplaceListingStatus.withdrawn:
        return 'Retirée';
    }
  }
}

class _MarketplaceEmpty extends StatelessWidget {
  const _MarketplaceEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Icon(Icons.storefront_outlined, size: 64),
          SizedBox(height: 12),
          Text('Aucune annonce pour le moment'),
          SizedBox(height: 4),
          Text('Publiez votre première mini-annonce.'),
        ],
      ),
    );
  }
}
