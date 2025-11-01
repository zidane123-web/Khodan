import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../data/models/contact.dart';
import '../../../../data/models/finance_flow.dart';
import '../../../../data/models/financial_transaction.dart';
import '../../../../data/models/transaction_category.dart';
import '../../../../data/repositories/finance_repository.dart';
import '../cubit/finance_cubit.dart';
import '../cubit/finance_state.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinanceCubit>(
      create: (BuildContext context) =>
          FinanceCubit(repository: context.read<FinanceRepository>())..load(),
      child: const FinanceScreen(),
    );
  }
}

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  final NumberFormat _amountFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FinanceCubit, FinanceState>(
      listenWhen: (FinanceState previous, FinanceState current) =>
          previous.errorMessage != current.errorMessage,
      listener: (BuildContext context, FinanceState state) {
        if (state.errorMessage != null) {
          final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
            context,
          );
          messenger
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (BuildContext context, FinanceState state) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Finances'),
              bottom: const TabBar(
                tabs: <Tab>[
                  Tab(text: 'Transactions'),
                  Tab(text: 'Contacts'),
                ],
              ),
              actions: <Widget>[
                IconButton(
                  tooltip: 'Exporter CSV',
                  onPressed:
                      state.isExporting || state.filteredTransactions.isEmpty
                      ? null
                      : () async {
                          final FinanceCubit cubit = context
                              .read<FinanceCubit>();
                          final ScaffoldMessengerState messenger =
                              ScaffoldMessenger.of(context);
                          final String? filename = await cubit.exportCsv();
                          if (!mounted || filename == null) return;
                          messenger
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(content: Text('$filename enregistre.')),
                            );
                        },
                  icon: state.isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined),
                ),
              ],
            ),
            body: TabBarView(
              children: <Widget>[
                _buildTransactionsTab(context, state),
                _buildContactsTab(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsTab(BuildContext context, FinanceState state) {
    final FinanceCubit cubit = context.read<FinanceCubit>();
    final ThemeData theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () => _openTransactionForm(context, state),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final DateTimeRange? range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDateRange:
                        state.dateRange ??
                        DateTimeRange(
                          start: DateTime.now().subtract(
                            const Duration(days: 30),
                          ),
                          end: DateTime.now(),
                        ),
                  );
                  if (!mounted) return;
                  if (range == null) {
                    cubit.refreshFilters(resetDateRange: true);
                  } else {
                    cubit.refreshFilters(dateRange: range);
                  }
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  state.dateRange == null
                      ? 'Periode'
                      : '${DateFormat.yMMMd().format(state.dateRange!.start)} - '
                            '${DateFormat.yMMMd().format(state.dateRange!.end)}',
                ),
              ),
              _buildCategoryDropdown(context, state),
              _buildFlowDropdown(context, state),
              _buildContactDropdown(context, state),
              SizedBox(
                width: min(MediaQuery.of(context).size.width, 360),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Recherche',
                  ),
                  onChanged: cubit.updateSearch,
                ),
              ),
              if (state.dateRange != null ||
                  state.categoryId != null ||
                  state.contactId != null ||
                  state.flow != null ||
                  state.searchQuery.isNotEmpty)
                TextButton(
                  onPressed: cubit.clearFilters,
                  child: const Text('Reinitialiser les filtres'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(theme, state),
          const SizedBox(height: 16),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (state.filteredTransactions.isEmpty)
            Column(
              children: <Widget>[
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  state.searchQuery.isEmpty &&
                          state.categoryId == null &&
                          state.dateRange == null
                      ? 'Aucune transaction enregistree.'
                      : 'Aucun resultat pour ces filtres.',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            )
          else
            _buildTransactionList(context, state),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, FinanceState state) {
    final FinanceCubit cubit = context.read<FinanceCubit>();
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        initialValue: state.categoryId,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Categorie'),
        items: <DropdownMenuItem<String>>[
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Toutes les categories'),
          ),
          ...state.categories.map(
            (TransactionCategory category) => DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.label),
            ),
          ),
        ],
        onChanged: (String? value) => cubit.refreshFilters(
          categoryId: value,
          resetCategory: value == null,
        ),
      ),
    );
  }

  Widget _buildFlowDropdown(BuildContext context, FinanceState state) {
    final FinanceCubit cubit = context.read<FinanceCubit>();
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<FinanceFlow>(
        initialValue: state.flow,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Type'),
        items: const <DropdownMenuItem<FinanceFlow>>[
          DropdownMenuItem<FinanceFlow>(
            value: null,
            child: Text('Tous les types'),
          ),
          DropdownMenuItem<FinanceFlow>(
            value: FinanceFlow.expense,
            child: Text('Depense'),
          ),
          DropdownMenuItem<FinanceFlow>(
            value: FinanceFlow.income,
            child: Text('Recette'),
          ),
          DropdownMenuItem<FinanceFlow>(
            value: FinanceFlow.neutral,
            child: Text('Neutre'),
          ),
        ],
        onChanged: (FinanceFlow? value) =>
            cubit.refreshFilters(flow: value, resetFlow: value == null),
      ),
    );
  }

  Widget _buildContactDropdown(BuildContext context, FinanceState state) {
    final FinanceCubit cubit = context.read<FinanceCubit>();
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        initialValue: state.contactId,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Contact'),
        items: <DropdownMenuItem<String>>[
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Tous les contacts'),
          ),
          ...state.contacts.map(
            (Contact contact) => DropdownMenuItem<String>(
              value: contact.id,
              child: Text(contact.displayName),
            ),
          ),
        ],
        onChanged: (String? value) =>
            cubit.refreshFilters(contactId: value, resetContact: value == null),
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, FinanceState state) {
    final List<_SummaryCardData> cards = <_SummaryCardData>[
      _SummaryCardData(
        label: 'Recettes',
        value: state.totalIncome,
        color: Colors.green.shade600,
      ),
      _SummaryCardData(
        label: 'Depenses',
        value: state.totalExpense,
        color: Colors.red.shade600,
      ),
      _SummaryCardData(
        label: 'Solde',
        value: state.netBalance,
        color: theme.colorScheme.primary,
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool horizontal = constraints.maxWidth > 600;
        return Flex(
          direction: horizontal ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cards
              .map(
                (_SummaryCardData card) => Expanded(
                  child: Card(
                    color: card.color.withAlpha(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            card.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: card.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _amountFormat.format(card.value),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: card.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildTransactionList(BuildContext context, FinanceState state) {
    final FinanceCubit cubit = context.read<FinanceCubit>();
    final ThemeData theme = Theme.of(context);
    final DateFormat headerFormat = DateFormat.yMMMMd('fr_FR');

    final Map<String, List<FinancialTransaction>> grouped =
        groupBy<FinancialTransaction, String>(
          state.filteredTransactions,
          (FinancialTransaction tx) =>
              tx.occuredOn.toIso8601String().split('T').first,
        );
    final List<String> sortedKeys = grouped.keys.toList()
      ..sort((String a, String b) => b.compareTo(a));

    return Column(
      children: sortedKeys
          .map(
            (String key) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    headerFormat.format(DateTime.parse(key)),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                ...grouped[key]!.map(
                  (FinancialTransaction tx) => Card(
                    child: ListTile(
                      title: Text(tx.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (tx.contact?.displayName != null)
                            Text('Contact : ${tx.contact!.displayName}'),
                          if (tx.category != null)
                            Text('Categorie : ${tx.category!.label}'),
                          if (tx.paymentMethod != null &&
                              tx.paymentMethod!.isNotEmpty)
                            Text('Paiement : ${tx.paymentMethod}'),
                          if (tx.notes != null && tx.notes!.isNotEmpty)
                            Text(tx.notes!),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            _amountFormat.format(tx.amount),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: tx.flow.isIncome
                                  ? Colors.green.shade700
                                  : tx.flow.isExpense
                                  ? Colors.red.shade700
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(tx.currency, style: theme.textTheme.bodySmall),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () =>
                          _openTransactionForm(context, state, existing: tx),
                      leading: tx.attachmentUrl != null
                          ? const Icon(Icons.attachment_outlined)
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      onLongPress: () =>
                          _showTransactionMenu(context, cubit, tx, state),
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(growable: false),
    );
  }

  void _showTransactionMenu(
    BuildContext context,
    FinanceCubit cubit,
    FinancialTransaction transaction,
    FinanceState state,
  ) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openTransactionForm(context, state, existing: transaction);
                },
              ),
              if (transaction.attachmentUrl != null)
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('Ouvrir le recu'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final String? url = await cubit.openReceipt(transaction);
                    if (url != null && mounted) {
                      await launchUrlString(url);
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Supprimer'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final bool? confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) => AlertDialog(
                      title: const Text('Supprimer la transaction'),
                      content: const Text(
                        'Cette transaction sera supprimee definitivement.',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('Annuler'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && mounted) {
                    await cubit.deleteTransaction(transaction.id);
                    if (!mounted) return;
                    messenger
                      ..clearSnackBars()
                      ..showSnackBar(
                        const SnackBar(content: Text('Transaction supprimee.')),
                      );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactsTab(BuildContext context, FinanceState state) {
    final FinanceCubit cubit = context.read<FinanceCubit>();
    final ThemeData theme = Theme.of(context);
    final Map<String, int> usageCount = <String, int>{};
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    for (final FinancialTransaction tx in state.transactions) {
      if (tx.contactId != null) {
        usageCount.update(
          tx.contactId!,
          (int value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () => _openContactForm(context),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Ajouter un contact'),
              ),
              const Spacer(),
              if (state.isSaving) const CircularProgressIndicator(),
            ],
          ),
        ),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.contacts.isEmpty
              ? Center(
                  child: Text(
                    'Aucun contact enregistre.',
                    style: theme.textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: state.contacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Contact contact = state.contacts[index];
                    final int count = usageCount[contact.id] ?? 0;
                    return ListTile(
                      leading: Icon(_contactIcon(contact.type)),
                      title: Text(contact.displayName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Type : ${_contactTypeLabel(contact.type)}'),
                          if (contact.phone != null &&
                              contact.phone!.isNotEmpty)
                            Text('Telephone : ${contact.phone}'),
                          if (contact.email != null &&
                              contact.email!.isNotEmpty)
                            Text('Email : ${contact.email}'),
                          Text('Transactions liees : $count'),
                        ],
                      ),
                      onTap: () => _openContactForm(context, existing: contact),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Supprimer',
                        onPressed: count > 0
                            ? null
                            : () async {
                                final bool? confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext dialogContext) =>
                                      AlertDialog(
                                        title: const Text(
                                          'Supprimer le contact',
                                        ),
                                        content: const Text(
                                          'Supprimer ce contact ? Cette action ne peut pas etre annulee.',
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(false),
                                            child: const Text('Annuler'),
                                          ),
                                          FilledButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(true),
                                            child: const Text('Supprimer'),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirmed == true && mounted) {
                                  await cubit.deleteContact(contact.id);
                                  if (mounted) {
                                    messenger
                                      ..clearSnackBars()
                                      ..showSnackBar(
                                        const SnackBar(
                                          content: Text('Contact supprime.'),
                                        ),
                                      );
                                  }
                                }
                              },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _contactIcon(ContactType type) {
    switch (type) {
      case ContactType.breeder:
        return Icons.pets;
      case ContactType.supplier:
        return Icons.storefront_outlined;
      case ContactType.client:
        return Icons.shopping_bag_outlined;
      case ContactType.staff:
        return Icons.badge_outlined;
      case ContactType.other:
        return Icons.person_outline;
    }
  }

  String _contactTypeLabel(ContactType type) {
    switch (type) {
      case ContactType.breeder:
        return 'Eleveur';
      case ContactType.supplier:
        return 'Fournisseur';
      case ContactType.client:
        return 'Client';
      case ContactType.staff:
        return 'Personnel';
      case ContactType.other:
        return 'Autre';
    }
  }

  Future<void> _openTransactionForm(
    BuildContext context,
    FinanceState state, {
    FinancialTransaction? existing,
  }) async {
    final FinanceCubit cubit = context.read<FinanceCubit>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final TransactionDraft? result =
        await showModalBottomSheet<TransactionDraft?>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext sheetContext) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: _TransactionForm(state: state, existing: existing),
            );
          },
        );
    if (result == null || !mounted) {
      return;
    }
    try {
      await cubit.saveTransaction(result);
      if (!mounted) return;
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              result.id == null
                  ? 'Transaction enregistree.'
                  : 'Transaction mise a jour.',
            ),
          ),
        );
    } catch (_) {
      // deja remonte via listener
    }
  }

  Future<void> _openContactForm(
    BuildContext context, {
    Contact? existing,
  }) async {
    final FinanceCubit cubit = context.read<FinanceCubit>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ContactDraft? result = await showModalBottomSheet<ContactDraft?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: _ContactForm(existing: existing),
        );
      },
    );
    if (result == null || !mounted) {
      return;
    }
    try {
      await cubit.saveContact(result);
      if (!mounted) return;
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              existing == null ? 'Contact ajoute.' : 'Contact mis a jour.',
            ),
          ),
        );
    } catch (_) {
      // deja remonte via listener
    }
  }
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _TransactionForm extends StatefulWidget {
  const _TransactionForm({required this.state, this.existing});

  final FinanceState state;
  final FinancialTransaction? existing;

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _currencyController;
  late TextEditingController _paymentController;
  late TextEditingController _notesController;
  late DateTime _occuredOn;
  String? _categoryId;
  String? _contactId;
  FinanceFlow _flow = FinanceFlow.expense;
  TransactionAttachmentDraft? _attachment;
  bool _removeExistingAttachment = false;

  @override
  void initState() {
    super.initState();
    final FinancialTransaction? existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _currencyController = TextEditingController(
      text: existing?.currency ?? 'XOF',
    );
    _paymentController = TextEditingController(
      text: existing?.paymentMethod ?? '',
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _occuredOn = existing?.occuredOn ?? DateTime.now();
    _categoryId = existing?.categoryId;
    _contactId = existing?.contactId;
    _flow =
        existing?.flow ??
        widget.state.categories
            .firstWhereOrNull(
              (TransactionCategory cat) => cat.id == _categoryId,
            )
            ?.defaultFlow ??
        FinanceFlow.expense;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _paymentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final bool wide = media.size.width > 520;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: media.viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.existing == null
                    ? 'Nouvelle transaction'
                    : 'Modifier la transaction',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Libelle'),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Titre obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Flex(
                direction: wide ? Axis.horizontal : Axis.vertical,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      decoration: const InputDecoration(labelText: 'Montant'),
                      validator: (String? value) {
                        final double? parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          if (_flow.isNeutral && parsed == 0) {
                            return null;
                          }
                          return 'Montant invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12, height: 12),
                  SizedBox(
                    width: wide ? 140 : double.infinity,
                    child: TextFormField(
                      controller: _currencyController,
                      decoration: const InputDecoration(labelText: 'Devise'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          initialDate: _occuredOn,
                        );
                        if (picked != null) {
                          setState(() => _occuredOn = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(DateFormat.yMMMd().format(_occuredOn)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<FinanceFlow>(
                      initialValue: _flow,
                      decoration: const InputDecoration(labelText: 'Type'),
                      onChanged: (FinanceFlow? value) {
                        if (value != null) {
                          setState(() => _flow = value);
                        }
                      },
                      items: const <DropdownMenuItem<FinanceFlow>>[
                        DropdownMenuItem<FinanceFlow>(
                          value: FinanceFlow.expense,
                          child: Text('Depense'),
                        ),
                        DropdownMenuItem<FinanceFlow>(
                          value: FinanceFlow.income,
                          child: Text('Recette'),
                        ),
                        DropdownMenuItem<FinanceFlow>(
                          value: FinanceFlow.neutral,
                          child: Text('Neutre'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Categorie'),
                items: widget.state.categories
                    .map(
                      (TransactionCategory category) =>
                          DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.label),
                          ),
                    )
                    .toList(growable: false),
                onChanged: (String? value) {
                  setState(() {
                    _categoryId = value;
                    final TransactionCategory? category = widget
                        .state
                        .categories
                        .firstWhereOrNull(
                          (TransactionCategory cat) => cat.id == value,
                        );
                    if (category != null) {
                      _flow = category.defaultFlow;
                    }
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Categorie obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _contactId,
                decoration: const InputDecoration(
                  labelText: 'Contact (optionnel)',
                ),
                items: <DropdownMenuItem<String>>[
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Aucun'),
                  ),
                  ...widget.state.contacts.map(
                    (Contact contact) => DropdownMenuItem<String>(
                      value: contact.id,
                      child: Text(contact.displayName),
                    ),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() => _contactId = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _paymentController,
                decoration: const InputDecoration(
                  labelText: 'Methode de paiement',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () async {
                      final FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                            withData: true,
                          );
                      if (result != null && result.files.isNotEmpty) {
                        final PlatformFile file = result.files.first;
                        final Uint8List? bytes = file.bytes;
                        if (bytes != null) {
                          setState(() {
                            _attachment = TransactionAttachmentDraft(
                              fileName: file.name,
                              bytes: bytes,
                              contentType: file.extension == 'png'
                                  ? 'image/png'
                                  : 'image/jpeg',
                            );
                            _removeExistingAttachment = false;
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      _attachment?.fileName ??
                          widget.existing?.attachmentName ??
                          'Ajouter un recu',
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (widget.existing?.attachmentUrl != null ||
                      _attachment != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _attachment = null;
                          _removeExistingAttachment = true;
                        });
                      },
                      child: const Text('Retirer la piece jointe'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() != true) {
                      return;
                    }
                    final double amount =
                        double.tryParse(
                          _amountController.text.replaceAll(',', '.'),
                        ) ??
                        0;
                    Navigator.of(context).pop(
                      TransactionDraft(
                        id: widget.existing?.id,
                        profileId: widget.existing?.profileId,
                        title: _titleController.text.trim(),
                        amount: amount,
                        currency: _currencyController.text.trim().isEmpty
                            ? 'XOF'
                            : _currencyController.text.trim(),
                        occuredOn: _occuredOn,
                        categoryId: _categoryId,
                        contactId: _contactId,
                        flow: _flow,
                        paymentMethod: _paymentController.text.trim().isEmpty
                            ? null
                            : _paymentController.text.trim(),
                        notes: _notesController.text.trim().isEmpty
                            ? null
                            : _notesController.text.trim(),
                        attachment: _attachment,
                        removeExistingAttachment: _removeExistingAttachment,
                      ),
                    );
                  },
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm({this.existing});

  final Contact? existing;

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  ContactType _type = ContactType.other;

  @override
  void initState() {
    super.initState();
    final Contact? existing = widget.existing;
    _nameController = TextEditingController(text: existing?.displayName ?? '');
    _emailController = TextEditingController(text: existing?.email ?? '');
    _phoneController = TextEditingController(text: existing?.phone ?? '');
    _addressController = TextEditingController(text: existing?.address ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _type = existing?.type ?? ContactType.other;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: media.viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.existing == null
                  ? 'Nouveau contact'
                  : 'Modifier le contact',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nom obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ContactType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const <DropdownMenuItem<ContactType>>[
                DropdownMenuItem<ContactType>(
                  value: ContactType.breeder,
                  child: Text('Eleveur'),
                ),
                DropdownMenuItem<ContactType>(
                  value: ContactType.supplier,
                  child: Text('Fournisseur'),
                ),
                DropdownMenuItem<ContactType>(
                  value: ContactType.client,
                  child: Text('Client'),
                ),
                DropdownMenuItem<ContactType>(
                  value: ContactType.staff,
                  child: Text('Personnel'),
                ),
                DropdownMenuItem<ContactType>(
                  value: ContactType.other,
                  child: Text('Autre'),
                ),
              ],
              onChanged: (ContactType? value) {
                if (value != null) {
                  setState(() => _type = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telephone'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Adresse'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() != true) {
                    return;
                  }
                  Navigator.of(context).pop(
                    ContactDraft(
                      id: widget.existing?.id,
                      profileId: widget.existing?.profileId,
                      displayName: _nameController.text.trim(),
                      type: _type,
                      email: _emailController.text.trim().isEmpty
                          ? null
                          : _emailController.text.trim(),
                      phone: _phoneController.text.trim().isEmpty
                          ? null
                          : _phoneController.text.trim(),
                      address: _addressController.text.trim().isEmpty
                          ? null
                          : _addressController.text.trim(),
                      notes: _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
                      createdAt: widget.existing?.createdAt,
                    ),
                  );
                },
                child: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
