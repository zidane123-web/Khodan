import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/contact.dart';
import '../../../../data/models/rabbit_sale.dart';

class NouvelleVenteForm extends StatefulWidget {
  const NouvelleVenteForm({
    required this.animals,
    required this.contacts,
    required this.onSubmit,
    this.initialCurrency = 'XOF',
    super.key,
  });

  final List<Animal> animals;
  final List<Contact> contacts;
  final Future<void> Function(RabbitSaleDraft draft) onSubmit;
  final String initialCurrency;

  @override
  State<NouvelleVenteForm> createState() => _NouvelleVenteFormState();
}

class _NouvelleVenteFormState extends State<NouvelleVenteForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _animalId;
  String? _contactId;
  String _currency = 'XOF';
  String _paymentMethod = 'cash';
  DateTime? _expectedCloseDate;
  bool _ackWeight = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _currency = widget.initialCurrency;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Nouvelle vente',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // ignore: deprecated_member_use
            DropdownButtonFormField<String>(
              initialValue: _animalId,
              decoration: const InputDecoration(
                labelText: 'Lapin',
              ),
              items: widget.animals
                  .map(
                    (Animal animal) => DropdownMenuItem<String>(
                      value: animal.id,
                      child: Text(
                        '${animal.tagId} • ${animal.name ?? 'Sans nom'}',
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (String? value) => setState(() => _animalId = value),
              validator: (String? value) =>
                  value == null ? 'Sélectionner un lapin' : null,
            ),
            const SizedBox(height: 12),
            // ignore: deprecated_member_use
            DropdownButtonFormField<String>(
              initialValue: _contactId,
              decoration: const InputDecoration(
                labelText: 'Acheteur (contact)',
              ),
              items: widget.contacts
                  .map(
                    (Contact contact) => DropdownMenuItem<String>(
                      value: contact.id,
                      child: Text(contact.displayName),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (String? value) => setState(() => _contactId = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Prix',
                      prefixIcon: Icon(Icons.payments_outlined, size: 18),
                    ),
                    validator: (String? value) {
                      final double? parsed = double.tryParse(
                        value?.replaceAll(',', '.') ?? '',
                      );
                      if (parsed == null || parsed <= 0) {
                        return 'Montant invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: // ignore: deprecated_member_use
                      DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: const InputDecoration(labelText: 'Devise'),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'XOF',
                        child: Text('XOF'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'EUR',
                        child: Text('EUR'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'USD',
                        child: Text('USD'),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => _currency = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ignore: deprecated_member_use
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Mode de paiement'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'cash',
                  child: Text('Espèces'),
                ),
                DropdownMenuItem<String>(
                  value: 'mobile_money',
                  child: Text('Mobile Money'),
                ),
                DropdownMenuItem<String>(
                  value: 'cheque',
                  child: Text('Chèque'),
                ),
                DropdownMenuItem<String>(
                  value: 'other',
                  child: Text('Autre'),
                ),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _paymentMethod = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes / conseils post-vente',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(
                      _expectedCloseDate == null
                          ? 'Date estimée de paiement'
                          : 'Échéance : ${_expectedCloseDate!.day}/${_expectedCloseDate!.month}',
                    ),
                    onPressed: _pickCloseDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(
                  'Astuce débutant',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Notez la dernière pesée et proposez un rappel de soins aux acheteurs, comme dans Everbreed.',
                ),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _ackWeight,
              onChanged: (bool? value) {
                setState(() => _ackWeight = value ?? false);
              },
              title: const Text(
                'Je confirme avoir vérifié la pesée et les preuves avant de vendre.',
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                onPressed:
                    _submitting || !_ackWeight ? null : () => _submit(context),
                label: const Text('Enregistrer la vente'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCloseDate() async {
    final DateTime now = DateTime.now();
    final DateTime? result = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 60)),
      initialDate: _expectedCloseDate ?? now.add(const Duration(days: 2)),
    );
    if (result != null) {
      setState(() => _expectedCloseDate = result);
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    setState(() => _submitting = true);
    final NavigatorState navigator = Navigator.of(context);
    try {
      final RabbitSaleDraft draft = RabbitSaleDraft(
        animalId: _animalId!,
        contactId: _contactId,
        price: double.parse(_priceController.text.replaceAll(',', '.')),
        currency: _currency,
        paymentMethod: _paymentMethod,
        expectedCloseDate: _expectedCloseDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      await widget.onSubmit(draft);
      if (navigator.mounted) {
        navigator.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
