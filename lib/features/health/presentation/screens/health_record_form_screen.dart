import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/ailment.dart';
import '../../../../data/models/animal.dart';
import '../../../../data/models/health_record.dart';
import '../../../../data/models/health_treatment.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/health_cubit.dart';

class HealthRecordFormScreen extends StatefulWidget {
  const HealthRecordFormScreen({
    super.key,
    this.existing,
    required this.ailments,
    required this.animals,
  });

  final HealthRecord? existing;
  final List<Ailment> ailments;
  final List<Animal> animals;

  @override
  State<HealthRecordFormScreen> createState() => _HealthRecordFormScreenState();
}

class _HealthRecordFormScreenState extends State<HealthRecordFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _notesController;
  late final TextEditingController _diagnosisController;

  Animal? _selectedAnimal;
  Ailment? _selectedAilment;
  HealthSeverity _severity = HealthSeverity.moderate;
  HealthRecordStatus _status = HealthRecordStatus.active;
  DateTime _onsetDate = DateTime.now();
  DateTime? _nextCheckAt;
  bool _autoScheduleCheck = false;

  @override
  void initState() {
    super.initState();
    final HealthRecord? record = widget.existing;
    _notesController = TextEditingController(text: record?.notes ?? '');
    _diagnosisController = TextEditingController(
      text: record?.customDiagnosis ?? '',
    );
    if (record != null) {
      for (final Animal animal in widget.animals) {
        if (animal.id == record.animalId) {
          _selectedAnimal = animal;
          break;
        }
      }
      for (final Ailment ailment in widget.ailments) {
        if (ailment.id == record.ailmentId) {
          _selectedAilment = ailment;
          break;
        }
      }
      _severity = record.severity;
      _status = record.status;
      _onsetDate = record.onsetDate;
      _nextCheckAt = record.nextCheckAt;
      _autoScheduleCheck = _nextCheckAt != null;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isEditing = widget.existing != null;
    final List<Animal> animals = widget.animals;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.healthEditRecord : l10n.healthAddRecord),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            // ignore: deprecated_member_use
            DropdownButtonFormField<Animal>(
              initialValue: _selectedAnimal,
              decoration: InputDecoration(labelText: l10n.healthSelectAnimal),
              items: animals
                  .map(
                    (Animal animal) => DropdownMenuItem<Animal>(
                      value: animal,
                      child: Text(animal.name ?? animal.tagId),
                    ),
                  )
                  .toList(),
              onChanged: (Animal? value) => setState(() {
                _selectedAnimal = value;
              }),
              validator: (Animal? value) =>
                  value == null ? l10n.healthValidationAnimal : null,
            ),
            const SizedBox(height: 16),
            // ignore: deprecated_member_use
            DropdownButtonFormField<Ailment?>(
              initialValue: _selectedAilment,
              decoration: InputDecoration(labelText: l10n.healthSelectAilment),
              items: <DropdownMenuItem<Ailment?>>[
                DropdownMenuItem<Ailment?>(
                  value: null,
                  child: Text(l10n.healthAilmentCustom),
                ),
                ...widget.ailments.map(
                  (Ailment ailment) => DropdownMenuItem<Ailment?>(
                    value: ailment,
                    child: Text(ailment.name),
                  ),
                ),
              ],
              onChanged: (Ailment? value) => setState(() {
                _selectedAilment = value;
                if (value != null && _diagnosisController.text.isEmpty) {
                  _diagnosisController.text = value.name;
                }
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _diagnosisController,
              decoration: InputDecoration(labelText: l10n.healthDiagnosisLabel),
              maxLines: 2,
              validator: (String? value) {
                if (_selectedAilment == null &&
                    (value == null || value.trim().isEmpty)) {
                  return l10n.healthValidationDiagnosis;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // ignore: deprecated_member_use
            DropdownButtonFormField<HealthSeverity>(
              initialValue: _severity,
              decoration: InputDecoration(
                labelText: l10n.healthSeverityLabel(''),
              ),
              items: HealthSeverity.values
                  .map(
                    (HealthSeverity severity) =>
                        DropdownMenuItem<HealthSeverity>(
                          value: severity,
                          child: Text(l10n.healthSeverityLabel(severity.key)),
                        ),
                  )
                  .toList(),
              onChanged: (HealthSeverity? value) {
                if (value != null) {
                  setState(() => _severity = value);
                }
              },
            ),
            const SizedBox(height: 16),
            // ignore: deprecated_member_use
            DropdownButtonFormField<HealthRecordStatus>(
              initialValue: _status,
              decoration: InputDecoration(
                labelText: l10n.healthStatusLabel(''),
              ),
              items: HealthRecordStatus.values
                  .map(
                    (HealthRecordStatus status) =>
                        DropdownMenuItem<HealthRecordStatus>(
                          value: status,
                          child: Text(l10n.healthStatusLabel(status.key)),
                        ),
                  )
                  .toList(),
              onChanged: (HealthRecordStatus? value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.healthOnsetDateLabel),
              subtitle: Text(DateFormat.yMMMMd().format(_onsetDate)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () async => _pickOnsetDate(context),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.healthNextCheckToggle),
              value: _autoScheduleCheck,
              onChanged: (bool value) {
                setState(() {
                  _autoScheduleCheck = value;
                  if (!value) {
                    _nextCheckAt = null;
                  }
                });
              },
            ),
            if (_autoScheduleCheck)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.healthNextCheckLabel(
                    DateFormat.yMMMMd().add_jm().format(
                      _nextCheckAt ?? DateTime.now(),
                    ),
                  ),
                ),
                trailing: const Icon(Icons.alarm),
                onTap: () async => _pickNextCheck(context),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.healthNotesLabel,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _submit(context),
              child: Text(isEditing ? l10n.commonUpdate : l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickOnsetDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _onsetDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _onsetDate = picked);
    }
  }

  Future<void> _pickNextCheck(BuildContext context) async {
    final DateTime initialDate =
        _nextCheckAt ?? DateTime.now().add(const Duration(days: 2));
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!context.mounted) {
      return;
    }
    if (pickedDate == null) {
      return;
    }
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (!context.mounted) {
      return;
    }
    if (pickedTime == null) {
      return;
    }
    setState(() {
      _nextCheckAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    final HealthCubit cubit = context.read<HealthCubit>();
    final HealthRecord? existing = widget.existing;
    final Animal animal = _selectedAnimal!;
    final DateTime now = DateTime.now();

    final HealthRecord record = HealthRecord(
      id: existing?.id ?? const Uuid().v4(),
      profileId: existing?.profileId ?? animal.profileId,
      animalId: animal.id,
      ailmentId: _selectedAilment?.id,
      customDiagnosis: _selectedAilment == null
          ? _diagnosisController.text.trim()
          : null,
      status: _status,
      severity: _severity,
      symptoms: _selectedAilment?.symptoms ?? <HealthSymptom>[],
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      onsetDate: _onsetDate,
      resolvedAt: _status == HealthRecordStatus.resolved
          ? (existing?.resolvedAt ?? now)
          : null,
      nextCheckAt: _autoScheduleCheck ? _nextCheckAt : null,
      offlineReference: existing?.offlineReference,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      treatments: existing?.treatments ?? const <HealthTreatment>[],
    );

    try {
      if (existing == null) {
        await cubit.createRecord(record);
      } else {
        await cubit.updateRecord(record);
      }
      if (!context.mounted) {
        return;
      }
      navigator.pop(record);
    } catch (_) {}
  }
}
