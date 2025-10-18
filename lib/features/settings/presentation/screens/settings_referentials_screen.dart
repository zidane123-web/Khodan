import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/event_template.dart';
import '../../../../data/models/food_stock.dart';
import '../../../../data/models/food_type.dart';
import '../../../../data/models/species_config.dart';
import '../../../../data/repositories/event_template_repository.dart';
import '../../../../data/repositories/food_inventory_repository.dart';
import '../../../../data/repositories/species_repository.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/event_templates_cubit.dart';
import '../cubit/food_inventory_cubit.dart';
import '../cubit/species_cubit.dart';

class SettingsReferentialsScreen extends StatelessWidget {
  const SettingsReferentialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthState authState = context.read<AuthCubit>().state;
    final String? profileId =
        authState.profile?.id ?? authState.session?.user.id;

    if (profileId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Referentiels elevage')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Aucun profil actif. Connectez-vous pour gerer vos referentiels.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<SpeciesCubit>(
          create: (BuildContext context) => SpeciesCubit(
            context.read<SpeciesRepository>(),
            profileId: profileId,
          )..initialize(),
        ),
        BlocProvider<EventTemplatesCubit>(
          create: (BuildContext context) => EventTemplatesCubit(
            context.read<EventTemplateRepository>(),
            profileId: profileId,
          )..initialize(),
        ),
        BlocProvider<FoodInventoryCubit>(
          create: (BuildContext context) => FoodInventoryCubit(
            context.read<FoodInventoryRepository>(),
            profileId: profileId,
          )..initialize(),
        ),
      ],
      child: const _ReferentialsView(),
    );
  }
}

class _ReferentialsView extends StatelessWidget {
  const _ReferentialsView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<SpeciesCubit, SpeciesState>(
          listenWhen: (SpeciesState previous, SpeciesState current) =>
              previous.errorMessage != current.errorMessage ||
              previous.successMessage != current.successMessage,
          listener: (BuildContext context, SpeciesState state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              context.read<SpeciesCubit>().acknowledgeFeedback();
            } else if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              context.read<SpeciesCubit>().acknowledgeFeedback();
            }
          },
        ),
        BlocListener<EventTemplatesCubit, EventTemplatesState>(
          listenWhen:
              (EventTemplatesState previous, EventTemplatesState current) =>
                  previous.errorMessage != current.errorMessage ||
                  previous.successMessage != current.successMessage,
          listener: (BuildContext context, EventTemplatesState state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              context.read<EventTemplatesCubit>().acknowledgeFeedback();
            } else if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              context.read<EventTemplatesCubit>().acknowledgeFeedback();
            }
          },
        ),
        BlocListener<FoodInventoryCubit, FoodInventoryState>(
          listenWhen:
              (FoodInventoryState previous, FoodInventoryState current) =>
                  previous.errorMessage != current.errorMessage ||
                  previous.successMessage != current.successMessage,
          listener: (BuildContext context, FoodInventoryState state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              context.read<FoodInventoryCubit>().acknowledgeFeedback();
            } else if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              context.read<FoodInventoryCubit>().acknowledgeFeedback();
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Referentiels elevage')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const <Widget>[
              _SpeciesSection(),
              SizedBox(height: 24),
              _EventTemplatesSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeciesSection extends StatelessWidget {
  const _SpeciesSection();

  @override
  Widget build(BuildContext context) {
    final Color outline = Theme.of(context).colorScheme.outlineVariant;
    return BlocBuilder<SpeciesCubit, SpeciesState>(
      builder: (BuildContext context, SpeciesState state) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Especes elevees',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: state.saving
                          ? null
                          : () => _showSpeciesDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.loading && state.species.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.species.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Aucune espece n\'est configuree. Ajoutez votre premiere espece pour parametrer gestation et sevrage.',
                    ),
                  )
                else
                  Column(
                    children: state.species
                        .map(
                          (SpeciesConfig config) => _SpeciesTile(
                            config: config,
                            disabled: state.saving,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpeciesTile extends StatelessWidget {
  const _SpeciesTile({required this.config, required this.disabled});

  final SpeciesConfig config;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> schemaChips = config.eventsSchema
        .map(
          (String value) =>
              Chip(label: Text(value), visualDensity: VisualDensity.compact),
        )
        .toList();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(config.speciesName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Gestation: ${config.gestationDays} j | Sevrage: ${config.weaningDays} j',
                style: theme.textTheme.bodySmall,
              ),
              if (schemaChips.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: schemaChips),
              ],
            ],
          ),
          trailing: Wrap(
            spacing: 8,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Modifier',
                onPressed: disabled
                    ? null
                    : () => _showSpeciesDialog(context, existing: config),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Supprimer',
                onPressed: disabled
                    ? null
                    : () => _confirmSpeciesDeletion(context, config),
              ),
            ],
          ),
          onTap: () => _showSpeciesDialog(context, existing: config),
        ),
      ),
    );
  }
}

class _InventorySection extends StatelessWidget {
  const _InventorySection();

  @override
  Widget build(BuildContext context) {
    final Color outline = Theme.of(context).colorScheme.outlineVariant;
    return BlocBuilder<FoodInventoryCubit, FoodInventoryState>(
      builder: (BuildContext context, FoodInventoryState state) {
        final Map<int, FoodType> typeById = <int, FoodType>{
          for (final FoodType type in state.types) type.id: type,
        };
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Inventaire aliments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _InventorySummary(summary: state.summary),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Types d\'aliments',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: state.saving
                          ? null
                          : () => _showFoodTypeDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.types.isEmpty)
                  const Text(
                    'Aucun type d\'aliment. Ajoutez une categorie (granules, foin, complement, ...).',
                  )
                else
                  Column(
                    children: state.types
                        .map(
                          (FoodType type) =>
                              _FoodTypeTile(type: type, disabled: state.saving),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 16),
                Divider(color: outline.withAlpha((0.6 * 255).round())),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Entrees de stock',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: state.saving
                          ? null
                          : () => _showFoodStockDialog(context),
                      icon: const Icon(Icons.add_chart_outlined),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.loading && state.stock.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.stock.isEmpty)
                  const Text(
                    'Aucune entree de stock. Enregistrez vos achats pour suivre la consommation.',
                  )
                else
                  Column(
                    children: state.stock
                        .map(
                          (FoodStockEntry entry) => _FoodStockTile(
                            entry: entry,
                            typeById: typeById,
                            disabled: state.saving,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InventorySummary extends StatelessWidget {
  const _InventorySummary({required this.summary});

  final InventorySummary summary;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    final TextStyle? valueStyle = Theme.of(context).textTheme.titleLarge;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _SummaryChip(
          label: 'Quantite (kg)',
          value: summary.totalQuantityKg.toStringAsFixed(1),
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        _SummaryChip(
          label: 'Cout total (EUR)',
          value: '${summary.totalCost.toStringAsFixed(2)} EUR',
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        _SummaryChip(
          label: 'Consommation/mois (kg)',
          value: summary.estimatedMonthlyConsumptionKg.toStringAsFixed(1),
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: labelStyle),
          const SizedBox(height: 4),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _FoodTypeTile extends StatelessWidget {
  const _FoodTypeTile({required this.type, required this.disabled});

  final FoodType type;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(type.name),
        subtitle: Text('Ajoute le ${_formatDate(type.createdAt)}'),
        trailing: Wrap(
          spacing: 8,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifier',
              onPressed: disabled
                  ? null
                  : () => _showFoodTypeDialog(context, existing: type),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Supprimer',
              onPressed: disabled
                  ? null
                  : () => _confirmFoodTypeDeletion(context, type),
            ),
          ],
        ),
        onTap: () => _showFoodTypeDialog(context, existing: type),
      ),
    );
  }
}

class _FoodStockTile extends StatelessWidget {
  const _FoodStockTile({
    required this.entry,
    required this.typeById,
    required this.disabled,
  });

  final FoodStockEntry entry;
  final Map<int, FoodType> typeById;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final FoodType? type = entry.foodTypeId == null
        ? null
        : typeById[entry.foodTypeId!];
    final ThemeData theme = Theme.of(context);
    final String typeLabel = type?.name ?? 'Type inconnu';
    final String quantity = '${entry.quantityKg.toStringAsFixed(1)} kg';
    final String cost = entry.cost == null
        ? '--'
        : '${entry.cost!.toStringAsFixed(2)} EUR';
    final String date = entry.purchaseDate == null
        ? 'Date non definie'
        : _formatDate(entry.purchaseDate!);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(typeLabel),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Quantite: $quantity', style: theme.textTheme.bodySmall),
            Text('Cout: $cost', style: theme.textTheme.bodySmall),
            Text('Achat: $date', style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifier',
              onPressed: disabled
                  ? null
                  : () => _showFoodStockDialog(context, existing: entry),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Supprimer',
              onPressed: disabled
                  ? null
                  : () => _confirmFoodStockDeletion(context, entry),
            ),
          ],
        ),
        onTap: () => _showFoodStockDialog(context, existing: entry),
      ),
    );
  }
}

class _EventTemplatesSection extends StatelessWidget {
  const _EventTemplatesSection();

  @override
  Widget build(BuildContext context) {
    final Color outline = Theme.of(context).colorScheme.outlineVariant;
    return BlocBuilder<EventTemplatesCubit, EventTemplatesState>(
      builder: (BuildContext context, EventTemplatesState state) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Modeles d\'evenements',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: state.saving
                          ? null
                          : () => _showTemplateDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.loading && state.templates.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.templates.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Aucun modele d\'evenement. Ajoutez des raccourcis pour vos actions recurrents (vaccination, pesee, etc.).',
                    ),
                  )
                else
                  Column(
                    children: state.templates
                        .map(
                          (EventTemplate template) => _TemplateTile(
                            template: template,
                            disabled: state.saving,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template, required this.disabled});

  final EventTemplate template;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String prettyDetails = template.defaultDetails.isEmpty
        ? 'Aucun detail par defaut'
        : const JsonEncoder.withIndent(
            '  ',
          ).convert(template.defaultDetails).trim();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(template.templateName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Type: ', style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(prettyDetails, style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifier',
              onPressed: disabled
                  ? null
                  : () => _showTemplateDialog(context, existing: template),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Supprimer',
              onPressed: disabled
                  ? null
                  : () => _confirmTemplateDeletion(context, template),
            ),
          ],
        ),
        onTap: () => _showTemplateDialog(context, existing: template),
      ),
    );
  }
}

Future<void> _showSpeciesDialog(
  BuildContext context, {
  SpeciesConfig? existing,
}) async {
  final SpeciesCubit cubit = context.read<SpeciesCubit>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController(
    text: existing?.speciesName ?? '',
  );
  final TextEditingController gestationController = TextEditingController(
    text: existing != null ? existing.gestationDays.toString() : '',
  );
  final TextEditingController weaningController = TextEditingController(
    text: existing != null ? existing.weaningDays.toString() : '',
  );
  final TextEditingController schemaController = TextEditingController(
    text: existing != null ? existing.eventsSchema.join(', ') : '',
  );
  String? schemaError;

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) {
          return AlertDialog(
            title: Text(
              existing == null ? 'Nouvelle espece' : 'Modifier l\'espece',
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'espece',
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nom obligatoire';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: gestationController,
                      decoration: const InputDecoration(
                        labelText: 'Gestation (jours)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        final int? parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Valeur positive requise';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: weaningController,
                      decoration: const InputDecoration(
                        labelText: 'Sevrage (jours)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        final int? parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Valeur positive requise';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: schemaController,
                      decoration: const InputDecoration(
                        labelText: 'Schema d\'evenements',
                        helperText:
                            'Separez par une virgule ou un retour ligne',
                      ),
                      maxLines: 3,
                    ),
                    if (schemaError != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        schemaError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  final List<String> schema = schemaController.text
                      .split(RegExp(r'[\n,]'))
                      .map((String value) => value.trim())
                      .where((String value) => value.isNotEmpty)
                      .toList();
                  if (schema.isEmpty) {
                    setState(() {
                      schemaError =
                          'Indiquez au moins un evenement (ex: accouplement, palpation)';
                    });
                    return;
                  }
                  setState(() => schemaError = null);
                  await cubit.saveSpecies(
                    id: existing?.id,
                    name: nameController.text,
                    gestationDays: int.parse(gestationController.text),
                    weaningDays: int.parse(weaningController.text),
                    eventsSchema: schema,
                  );
                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _confirmSpeciesDeletion(
  BuildContext context,
  SpeciesConfig config,
) async {
  final SpeciesCubit cubit = context.read<SpeciesCubit>();
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Supprimer l\'espece'),
        content: Text(
          'Confirmer la suppression de "" ? Cette action supprime uniquement les parametres de referentiel.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      );
    },
  );
  if (confirmed == true) {
    await cubit.deleteSpecies(config.id);
  }
}

Future<void> _showTemplateDialog(
  BuildContext context, {
  EventTemplate? existing,
}) async {
  final EventTemplatesCubit cubit = context.read<EventTemplatesCubit>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController(
    text: existing?.templateName ?? '',
  );
  final TextEditingController typeController = TextEditingController(
    text: existing?.eventType ?? '',
  );
  final TextEditingController detailsController = TextEditingController(
    text: existing == null || existing.defaultDetails.isEmpty
        ? ''
        : const JsonEncoder.withIndent('  ').convert(existing.defaultDetails),
  );
  String? jsonError;

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
              return AlertDialog(
                title: Text(
                  existing == null ? 'Nouveau modele' : 'Modifier le modele',
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du modele',
                          ),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nom obligatoire';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: typeController,
                          decoration: const InputDecoration(
                            labelText: 'Type d\'evenement',
                            helperText: 'Ex: visite, vaccination, pesee',
                          ),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Type obligatoire';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: detailsController,
                          decoration: const InputDecoration(
                            labelText: 'Details par defaut (JSON)',
                            helperText:
                                'Laissez vide ou fournissez un objet JSON',
                          ),
                          maxLines: 4,
                        ),
                        if (jsonError != null) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            jsonError!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Annuler'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      Map<String, dynamic> defaultDetails = <String, dynamic>{};
                      if (detailsController.text.trim().isNotEmpty) {
                        try {
                          final dynamic decoded = jsonDecode(
                            detailsController.text,
                          );
                          if (decoded is Map<String, dynamic>) {
                            defaultDetails = Map<String, dynamic>.from(decoded);
                            setState(() => jsonError = null);
                          } else {
                            setState(
                              () => jsonError =
                                  'Le JSON doit decrire un objet (key/value).',
                            );
                            return;
                          }
                        } catch (error) {
                          setState(() => jsonError = 'JSON invalide: ');
                          return;
                        }
                      } else {
                        setState(() => jsonError = null);
                      }
                      await cubit.saveTemplate(
                        id: existing?.id,
                        name: nameController.text,
                        eventType: typeController.text,
                        defaultDetails: defaultDetails,
                      );
                      if (context.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              );
            },
      );
    },
  );
}

Future<void> _confirmTemplateDeletion(
  BuildContext context,
  EventTemplate template,
) async {
  final EventTemplatesCubit cubit = context.read<EventTemplatesCubit>();
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Supprimer le modele'),
        content: Text('Confirmer la suppression de "" ?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      );
    },
  );
  if (confirmed == true) {
    await cubit.deleteTemplate(template.id);
  }
}

Future<void> _showFoodTypeDialog(
  BuildContext context, {
  FoodType? existing,
}) async {
  final FoodInventoryCubit cubit = context.read<FoodInventoryCubit>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController(
    text: existing?.name ?? '',
  );

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(existing == null ? 'Nouveau type' : 'Modifier le type'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nom du type'),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nom obligatoire';
              }
              return null;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }
              await cubit.saveFoodType(
                id: existing?.id,
                name: nameController.text,
              );
              if (context.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      );
    },
  );
}

Future<void> _confirmFoodTypeDeletion(
  BuildContext context,
  FoodType type,
) async {
  final FoodInventoryCubit cubit = context.read<FoodInventoryCubit>();
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Supprimer le type'),
        content: Text(
          'Confirmer la suppression de "${type.name}" ? Les entrees de stock resteront mais sans type.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      );
    },
  );
  if (confirmed == true) {
    await cubit.deleteFoodType(type.id);
  }
}

Future<void> _showFoodStockDialog(
  BuildContext context, {
  FoodStockEntry? existing,
}) async {
  final FoodInventoryCubit cubit = context.read<FoodInventoryCubit>();
  final FoodInventoryState state = cubit.state;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController quantityController = TextEditingController(
    text: existing == null ? '' : existing.quantityKg.toStringAsFixed(1),
  );
  final TextEditingController costController = TextEditingController(
    text: existing?.cost == null ? '' : existing!.cost!.toStringAsFixed(2),
  );
  int? selectedTypeId = existing?.foodTypeId;
  DateTime? selectedDate = existing?.purchaseDate;

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
              return AlertDialog(
                title: Text(
                  existing == null
                      ? 'Nouvelle entree de stock'
                      : 'Modifier l\'entree',
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        DropdownButtonFormField<int>(
                          value: selectedTypeId,
                          decoration: const InputDecoration(
                            labelText: 'Type d\'aliment',
                          ),
                          items: state.types
                              .map(
                                (FoodType type) => DropdownMenuItem<int>(
                                  value: type.id,
                                  child: Text(type.name),
                                ),
                              )
                              .toList(),
                          onChanged: (int? value) {
                            setState(() => selectedTypeId = value);
                          },
                        ),
                        TextFormField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantite (kg)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (String? value) {
                            final double? parsed = double.tryParse(value ?? '');
                            if (parsed == null || parsed <= 0) {
                              return 'Quantite positive requise';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: costController,
                          decoration: const InputDecoration(
                            labelText: 'Cout (EUR)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () async {
                              final DateTime now = DateTime.now();
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? now,
                                firstDate: DateTime(now.year - 5),
                                lastDate: DateTime(now.year + 1),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                            icon: const Icon(Icons.event_outlined),
                            label: Text(
                              selectedDate == null
                                  ? 'Date d\'achat (optionnel)'
                                  : 'Achat: ${_formatDate(selectedDate!)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Annuler'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      final double quantity = double.parse(
                        quantityController.text.replaceAll(',', '.'),
                      );
                      final double? cost = costController.text.trim().isEmpty
                          ? null
                          : double.tryParse(
                              costController.text.replaceAll(',', '.'),
                            );
                      await cubit.saveFoodStock(
                        id: existing?.id,
                        foodTypeId: selectedTypeId,
                        quantityKg: quantity,
                        cost: cost,
                        purchaseDate: selectedDate,
                      );
                      if (context.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              );
            },
      );
    },
  );
}

Future<void> _confirmFoodStockDeletion(
  BuildContext context,
  FoodStockEntry entry,
) async {
  final FoodInventoryCubit cubit = context.read<FoodInventoryCubit>();
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Supprimer l\'entree'),
        content: const Text(
          'Confirmer la suppression de cette entree de stock ?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      );
    },
  );
  if (confirmed == true) {
    await cubit.deleteFoodStock(entry.id);
  }
}

String _formatDate(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
