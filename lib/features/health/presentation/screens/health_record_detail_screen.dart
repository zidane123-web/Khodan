import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/ailment.dart';
import '../../../../data/models/health_record.dart';
import '../../../../data/models/health_treatment.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/health_cubit.dart';
import '../cubit/health_state.dart';
import 'health_record_form_screen.dart';
import 'health_treatment_form.dart';

class HealthRecordDetailScreen extends StatelessWidget {
  const HealthRecordDetailScreen({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocBuilder<HealthCubit, HealthState>(
      builder: (BuildContext context, HealthState state) {
        HealthRecord? recordCandidate;
        for (final HealthRecord item in state.records) {
          if (item.id == recordId) {
            recordCandidate = item;
            break;
          }
        }
        if (recordCandidate == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.healthRecordDetails)),
            body: Center(child: Text(l10n.healthRecordNotFound)),
          );
        }
        final HealthRecord record = recordCandidate;
        final DateFormat formatter = DateFormat.yMMMMd();
        final DateFormat reminderFormatter = DateFormat.yMMMMd().add_jm();
        final String animalName =
            context.read<HealthCubit>().findAnimal(record.animalId)?.name ??
            record.animalId;

        final String? fallbackTitle = record.treatments.isEmpty
            ? null
            : record.treatments.first.title;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.healthRecordFor(animalName)),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _editRecord(context, record),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, record),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.medical_services_outlined),
            label: Text(l10n.healthAddTreatment),
            onPressed: () => _openTreatmentForm(context, record: record),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                record.customDiagnosis ??
                    fallbackTitle ??
                    l10n.healthRecordDetails,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  Chip(
                    avatar: const Icon(Icons.thermostat, size: 16),
                    label: Text(l10n.healthSeverityLabel(record.severity.key)),
                  ),
                  Chip(
                    avatar: const Icon(Icons.flag_outlined, size: 16),
                    label: Text(l10n.healthStatusLabel(record.status.key)),
                  ),
                  Chip(
                    avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(formatter.format(record.onsetDate)),
                  ),
                  if (record.nextCheckAt != null)
                    Chip(
                      avatar: const Icon(Icons.alarm, size: 16),
                      label: Text(
                        l10n.healthNextCheckLabel(
                          reminderFormatter.format(record.nextCheckAt!),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (record.symptoms.isNotEmpty) ...<Widget>[
                Text(
                  l10n.healthSymptomsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: <Widget>[
                    for (final HealthSymptom symptom in record.symptoms)
                      Chip(label: Text(symptom.label)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              if (record.notes != null && record.notes!.isNotEmpty) ...<Widget>[
                Text(
                  l10n.healthNotesLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(record.notes!),
                const SizedBox(height: 16),
              ],
              Text(
                l10n.healthTreatmentsSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (record.treatments.isEmpty)
                Text(l10n.healthNoTreatmentsYet)
              else
                ...record.treatments
                    .sorted(
                      (HealthTreatment a, HealthTreatment b) =>
                          a.startAt.compareTo(b.startAt),
                    )
                    .map(
                      (HealthTreatment treatment) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(treatment.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 4),
                              Text(_treatmentSchedule(formatter, treatment)),
                              if (treatment.notes != null &&
                                  treatment.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(treatment.notes!),
                                ),
                            ],
                          ),
                          leading: Icon(
                            treatment.isCompleted
                                ? Icons.check_circle
                                : Icons.pending_actions_outlined,
                            color: treatment.isCompleted
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: <Widget>[
                              if (!treatment.isCompleted)
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  tooltip: l10n.healthMarkTreatmentDone,
                                  onPressed: () => _markTreatmentCompleted(
                                    context,
                                    treatment,
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _openTreatmentForm(
                                  context,
                                  record: record,
                                  treatment: treatment,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _confirmDeleteTreatment(context, treatment),
                              ),
                            ],
                          ),
                          onTap: () => _openTreatmentForm(
                            context,
                            record: record,
                            treatment: treatment,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  String _treatmentSchedule(DateFormat formatter, HealthTreatment treatment) {
    final String start = formatter.format(treatment.startAt);
    final String? end = treatment.endAt == null
        ? null
        : formatter.format(treatment.endAt!);
    return end == null ? start : '$start -> $end';
  }

  Future<void> _editRecord(BuildContext context, HealthRecord record) async {
    final HealthCubit cubit = context.read<HealthCubit>();
    final HealthState state = cubit.state;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => HealthRecordFormScreen(
          existing: record,
          ailments: state.ailments,
          animals: state.animals,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, HealthRecord record) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final HealthCubit cubit = context.read<HealthCubit>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.commonConfirm),
          content: Text(l10n.healthDeleteRecordConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await cubit.deleteRecord(record.id);
      navigator.pop();
    }
  }

  Future<void> _confirmDeleteTreatment(
    BuildContext context,
    HealthTreatment treatment,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final HealthCubit cubit = context.read<HealthCubit>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.commonConfirm),
          content: Text(l10n.healthDeleteTreatmentConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await cubit.deleteTreatment(treatment);
    }
  }

  Future<void> _openTreatmentForm(
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

  Future<void> _markTreatmentCompleted(
    BuildContext context,
    HealthTreatment treatment,
  ) async {
    final HealthTreatment updated = treatment.copyWith(
      completedAt: DateTime.now(),
    );
    final HealthCubit cubit = context.read<HealthCubit>();
    await cubit.updateTreatment(updated);
  }
}

extension ListSortingExtension<T> on List<T> {
  List<T> sorted(int Function(T a, T b) compare) {
    final List<T> copy = List<T>.from(this);
    copy.sort(compare);
    return copy;
  }
}
