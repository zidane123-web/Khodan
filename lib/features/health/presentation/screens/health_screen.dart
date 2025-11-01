import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/ailment.dart';
import '../../../../data/models/animal.dart';
import '../../../../data/models/health_record.dart';
import '../../../../data/models/health_treatment.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/health_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/health_cubit.dart';
import '../cubit/health_state.dart';
import 'health_record_detail_screen.dart';
import 'health_record_form_screen.dart';
import 'health_treatment_form.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HealthCubit>(
      create: (BuildContext context) => HealthCubit(
        healthRepository: context.read<HealthRepository>(),
        animalRepository: context.read<AnimalRepository>(),
      )..load(),
      child: const _HealthView(),
    );
  }
}

class _HealthView extends StatefulWidget {
  const _HealthView();

  @override
  State<_HealthView> createState() => _HealthViewState();
}

class _HealthViewState extends State<_HealthView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool showFab = _tabController.index == 1;

    return BlocListener<HealthCubit, HealthState>(
      listenWhen: (HealthState previous, HealthState current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (BuildContext context, HealthState state) {
        if (state.errorMessage == null) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.healthTitle),
          bottom: TabBar(
            controller: _tabController,
            tabs: <Tab>[
              Tab(text: l10n.healthTabLibrary),
              Tab(text: l10n.healthTabRecords),
            ],
          ),
        ),
        floatingActionButton: showFab
            ? FloatingActionButton(
                onPressed: () => _openRecordForm(context),
                tooltip: l10n.healthAddRecord,
                child: const Icon(Icons.add),
              )
            : null,
        body: TabBarView(
          controller: _tabController,
          children: const <Widget>[_HealthLibraryTab(), _HealthRecordsTab()],
        ),
      ),
    );
  }

  Future<void> _openRecordForm(
    BuildContext context, {
    HealthRecord? record,
  }) async {
    final HealthCubit cubit = context.read<HealthCubit>();
    final HealthState state = cubit.state;
    await Navigator.of(context).push<HealthRecord>(
      MaterialPageRoute<HealthRecord>(
        builder: (BuildContext context) => HealthRecordFormScreen(
          existing: record,
          ailments: state.ailments,
          animals: state.animals,
        ),
      ),
    );
  }
}

class _HealthLibraryTab extends StatelessWidget {
  const _HealthLibraryTab();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocBuilder<HealthCubit, HealthState>(
      buildWhen: (HealthState previous, HealthState current) =>
          previous.isLoading != current.isLoading ||
          previous.filteredAilments != current.filteredAilments ||
          previous.searchQuery != current.searchQuery,
      builder: (BuildContext context, HealthState state) {
        if (state.isLoading && state.ailments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.healthSearchPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: context.read<HealthCubit>().searchAilments,
              ),
              const SizedBox(height: 16),
              if (state.filteredAilments.isEmpty)
                Expanded(child: Center(child: Text(l10n.healthAilmentsEmpty)))
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: state.filteredAilments.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final Ailment ailment = state.filteredAilments[index];
                      return ListTile(
                        title: Text(ailment.name),
                        subtitle: Text(
                          ailment.commonCauses ?? l10n.healthAilmentNoDetails,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _showAilmentDetails(context, ailment),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAilmentDetails(BuildContext context, Ailment ailment) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  ailment.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (ailment.symptoms.isNotEmpty) ...<Widget>[
                  Text(
                    l10n.healthSymptomsTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final HealthSymptom symptom in ailment.symptoms)
                        Chip(label: Text(symptom.label)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (ailment.commonCauses != null) ...<Widget>[
                  Text(
                    l10n.healthCausesTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(ailment.commonCauses!),
                  const SizedBox(height: 12),
                ],
                if (ailment.recommendedTreatments.isNotEmpty) ...<Widget>[
                  Text(
                    l10n.healthTreatmentsTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final TreatmentSuggestion suggestion
                      in ailment.recommendedTreatments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            suggestion.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (suggestion.description != null)
                            Text(suggestion.description!),
                          if (suggestion.defaultDosage != null ||
                              suggestion.defaultDurationDays != null)
                            Text(
                              l10n.healthTreatmentSummary(
                                suggestion.defaultDosage ?? '-',
                                suggestion.defaultDurationDays ?? 0,
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                        ],
                      ),
                    ),
                ],
                if (ailment.preventiveActions != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    l10n.healthPreventionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(ailment.preventiveActions!),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.commonClose),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HealthRecordsTab extends StatelessWidget {
  const _HealthRecordsTab();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocBuilder<HealthCubit, HealthState>(
      buildWhen: (HealthState previous, HealthState current) =>
          previous.records != current.records ||
          previous.isLoading != current.isLoading,
      builder: (BuildContext context, HealthState state) {
        if (state.isLoading && state.records.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final DateFormat shortDate = DateFormat.yMMMd();
        if (state.records.isEmpty) {
          return Center(child: Text(l10n.healthRecordsEmpty));
        }
        return RefreshIndicator(
          onRefresh: context.read<HealthCubit>().refreshRecords,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.records.length,
            itemBuilder: (BuildContext context, int index) {
              final HealthRecord record = state.records[index];
              final Animal? animal = context.read<HealthCubit>().findAnimal(
                record.animalId,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    animal?.name ?? animal?.tagId ?? record.animalId,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: <Widget>[
                          Chip(
                            label: Text(
                              l10n.healthSeverityLabel(record.severity.key),
                            ),
                          ),
                          Chip(
                            label: Text(
                              l10n.healthStatusLabel(record.status.key),
                            ),
                          ),
                          if (record.nextCheckAt != null)
                            Chip(
                              avatar: const Icon(Icons.alarm, size: 16),
                              label: Text(
                                l10n.healthNextCheckLabel(
                                  shortDate.format(record.nextCheckAt!),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.customDiagnosis ??
                            l10n.healthDiagnosisFromLibrary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String value) =>
                        _handleMenu(context, value, record),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text(l10n.commonEdit),
                          ),
                          PopupMenuItem<String>(
                            value: 'open',
                            child: Text(l10n.healthOpenDetails),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(
                              l10n.commonDelete,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                  ),
                  onTap: () => _openDetails(context, record),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleMenu(BuildContext context, String action, HealthRecord record) {
    switch (action) {
      case 'edit':
        _openForm(context, record: record);
      case 'open':
        _openDetails(context, record);
      case 'delete':
        _confirmDelete(context, record);
    }
  }

  Future<void> _openForm(BuildContext context, {HealthRecord? record}) async {
    final HealthCubit cubit = context.read<HealthCubit>();
    final HealthState state = cubit.state;
    await Navigator.of(context).push<HealthRecord>(
      MaterialPageRoute<HealthRecord>(
        builder: (BuildContext context) => HealthRecordFormScreen(
          existing: record,
          ailments: state.ailments,
          animals: state.animals,
        ),
      ),
    );
  }

  Future<void> _openDetails(BuildContext context, HealthRecord record) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            HealthRecordDetailScreen(recordId: record.id),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, HealthRecord record) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final HealthCubit cubit = context.read<HealthCubit>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.commonConfirm),
          content: Text(l10n.healthDeleteRecordConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
    if (!context.mounted) {
      return;
    }
    if (confirmed == true) {
      await cubit.deleteRecord(record.id);
    }
  }
}

Future<void> showTreatmentForm(
  BuildContext context, {
  required HealthRecord record,
  HealthTreatment? treatment,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          HealthTreatmentFormScreen(record: record, existing: treatment),
    ),
  );
}
