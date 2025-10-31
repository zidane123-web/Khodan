import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/hutch.dart';
import '../cubit/hutches_cubit.dart';

Future<HutchDraft?> showCreateHutchDialog(BuildContext context) {
  return showDialog<HutchDraft>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => const _HutchFormDialog(),
  );
}

Future<void> showMaintenanceSheet(BuildContext context, Hutch hutch) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => _MaintenanceSheet(hutch: hutch),
  );
}

class _HutchFormDialog extends StatefulWidget {
  const _HutchFormDialog();

  @override
  State<_HutchFormDialog> createState() => _HutchFormDialogState();
}

class _HutchFormDialogState extends State<_HutchFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController(text: '8');
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _capacityController.dispose();
    _zoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau clapier'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Numero de clapier'),
              validator: (String? value) =>
                  value == null || value.trim().isEmpty ? 'Champ obligatoire' : null,
            ),
            TextFormField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Capacite'),
              validator: (String? value) {
                final String trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Champ obligatoire';
                }
                final int? parsed = int.tryParse(trimmed);
                if (parsed == null || parsed <= 0) {
                  return 'Valeur invalide';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _zoneController,
              decoration: const InputDecoration(labelText: 'Zone'),
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              HutchDraft(
                label: _labelController.text.trim(),
                capacity: int.parse(_capacityController.text.trim()),
                zone: _zoneController.text.trim().isEmpty
                    ? null
                    : _zoneController.text.trim(),
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              ),
            );
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _MaintenanceSheet extends StatefulWidget {
  const _MaintenanceSheet({required this.hutch});

  final Hutch hutch;

  @override
  State<_MaintenanceSheet> createState() => _MaintenanceSheetState();
}

class _MaintenanceSheetState extends State<_MaintenanceSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _cleaningDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: insets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Entretien - ${widget.hutch.label}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _cleaningDate,
                  firstDate: DateTime(2015),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _cleaningDate = picked;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('Date de nettoyage ${_formatDate(_cleaningDate)}'),
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                helperText: 'Ajoutez les actions realisees ou a planifier',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    await context.read<HutchesCubit>().recordMaintenance(
                          hutchId: widget.hutch.id,
                          cleaningDate: _cleaningDate,
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                        );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String year = date.year.toString();
  return '$day/$month/$year';
}
