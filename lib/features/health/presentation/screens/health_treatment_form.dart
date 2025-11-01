import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/health_record.dart';
import '../../../../data/models/health_treatment.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/health_cubit.dart';

class HealthTreatmentFormScreen extends StatefulWidget {
  const HealthTreatmentFormScreen({
    super.key,
    required this.record,
    this.existing,
  });

  final HealthRecord record;
  final HealthTreatment? existing;

  @override
  State<HealthTreatmentFormScreen> createState() =>
      _HealthTreatmentFormScreenState();
}

class _HealthTreatmentFormScreenState extends State<HealthTreatmentFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _dosageController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _notesController;

  HealthTreatmentType _type = HealthTreatmentType.medication;
  late DateTime _startAt;
  DateTime? _endAt;
  bool _markCompleted = false;
  Set<int> _reminderMinutes = <int>{};

  static const List<int> _reminderValues = <int>[-1440, -60, 0, 60, 1440];

  @override
  void initState() {
    super.initState();
    final HealthTreatment? treatment = widget.existing;
    _titleController = TextEditingController(text: treatment?.title ?? '');
    _dosageController = TextEditingController(text: treatment?.dosage ?? '');
    _frequencyController = TextEditingController(
      text: treatment?.frequency ?? '',
    );
    _notesController = TextEditingController(text: treatment?.notes ?? '');
    _startAt = treatment?.startAt ?? DateTime.now();
    _endAt = treatment?.endAt;
    _type = treatment?.treatmentType ?? HealthTreatmentType.medication;
    _reminderMinutes = Set<int>.from(treatment?.reminderMinutes ?? <int>[]);
    _markCompleted = treatment?.completedAt != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateFormat formatter = DateFormat.yMMMMd().add_jm();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null
              ? l10n.healthAddTreatment
              : l10n.healthEditTreatment,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.healthTreatmentTitle),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.healthValidationTreatmentTitle;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HealthTreatmentType>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.healthTreatmentType),
              items: HealthTreatmentType.values
                  .map(
                    (HealthTreatmentType type) =>
                        DropdownMenuItem<HealthTreatmentType>(
                          value: type,
                          child: Text(l10n.healthTreatmentTypeLabel(type.key)),
                        ),
                  )
                  .toList(),
              onChanged: (HealthTreatmentType? value) {
                if (value != null) {
                  setState(() => _type = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosageController,
              decoration: InputDecoration(
                labelText: l10n.healthTreatmentDosage,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _frequencyController,
              decoration: InputDecoration(
                labelText: l10n.healthTreatmentFrequency,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.healthTreatmentStart),
              subtitle: Text(formatter.format(_startAt)),
              trailing: const Icon(Icons.schedule),
              onTap: () => _pickDateTime(context, initial: _startAt).then((
                DateTime? value,
              ) {
                if (value != null) {
                  setState(() => _startAt = value);
                }
              }),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _endAt == null
                    ? l10n.healthTreatmentEndOptional
                    : l10n.healthTreatmentEndValue(formatter.format(_endAt!)),
              ),
              trailing: const Icon(Icons.schedule_outlined),
              onTap: () =>
                  _pickDateTime(
                    context,
                    initial: _endAt ?? _startAt.add(const Duration(days: 1)),
                  ).then((DateTime? value) {
                    if (value != null) {
                      setState(() => _endAt = value);
                    }
                  }),
            ),
            SwitchListTile(
              title: Text(l10n.healthTreatmentMarkCompleted),
              value: _markCompleted,
              onChanged: (bool value) => setState(() => _markCompleted = value),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.healthRemindersTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reminderValues
                  .map(
                    (int value) => FilterChip(
                      label: Text(_reminderLabel(l10n, value)),
                      selected: _reminderMinutes.contains(value),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _reminderMinutes.add(value);
                          } else {
                            _reminderMinutes.remove(value);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.healthNotesLabel,
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _submit(context),
              child: Text(
                widget.existing == null ? l10n.commonSave : l10n.commonUpdate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(
    BuildContext context, {
    required DateTime initial,
  }) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !context.mounted) {
      return null;
    }
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !context.mounted) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _reminderLabel(AppLocalizations l10n, int minutes) {
    switch (minutes) {
      case -1440:
        return l10n.healthReminderOneDayBefore;
      case -60:
        return l10n.healthReminderOneHourBefore;
      case 0:
        return l10n.healthReminderAtStart;
      case 60:
        return l10n.healthReminderOneHourAfter;
      case 1440:
        return l10n.healthReminderOneDayAfter;
      default:
        return l10n.healthReminderMinutes(minutes);
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_endAt != null && _endAt!.isBefore(_startAt)) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).healthValidationDates),
          ),
        );
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    final HealthCubit cubit = context.read<HealthCubit>();
    final HealthTreatment? existing = widget.existing;
    final DateTime now = DateTime.now();
    final HealthTreatment treatment = HealthTreatment(
      id: existing?.id ?? const Uuid().v4(),
      recordId: widget.record.id,
      profileId: widget.record.profileId,
      title: _titleController.text.trim(),
      treatmentType: _type,
      dosage: _dosageController.text.trim().isEmpty
          ? null
          : _dosageController.text.trim(),
      frequency: _frequencyController.text.trim().isEmpty
          ? null
          : _frequencyController.text.trim(),
      startAt: _startAt,
      endAt: _endAt,
      completedAt: _markCompleted ? existing?.completedAt ?? now : null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      taskId: existing?.taskId,
      reminderMinutes: _reminderMinutes.toList()..sort(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (existing == null) {
        await cubit.createTreatment(treatment);
      } else {
        await cubit.updateTreatment(treatment);
      }
      if (!context.mounted) {
        return;
      }
      navigator.pop();
    } catch (_) {}
  }
}
