import 'package:flutter/material.dart';

import '../mvp_demo_controller.dart';

class NewRabbitPage extends StatefulWidget {
  const NewRabbitPage({super.key});

  @override
  State<NewRabbitPage> createState() => _NewRabbitPageState();
}

class _NewRabbitPageState extends State<NewRabbitPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _breedController =
      TextEditingController(text: 'Néo-Zélandais');
  final TextEditingController _cageController = TextEditingController(text: 'Cage 1');
  String _sex = 'Femelle';
  RabbitCategory _category = RabbitCategory.breeder;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _breedController.dispose();
    _cageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final MvpDemoController store = MvpDemoScope.of(context);
    store.addRabbit(
      name: _nameController.text.trim(),
      id: _idController.text.trim(),
      sex: _sex,
      breed: _breedController.text.trim(),
      cage: _cageController.text.trim(),
      category: _category,
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lapin ajouté.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau lapin')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (String? value) =>
                      value == null || value.isEmpty ? 'Nom requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(labelText: 'ID'),
                  validator: (String? value) =>
                      value == null || value.isEmpty ? 'Identifiant requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _breedController,
                  decoration: const InputDecoration(labelText: 'Race'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cageController,
                  decoration: const InputDecoration(labelText: 'Cage'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _sex,
                  decoration: const InputDecoration(labelText: 'Sexe'),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'Femelle',
                      child: Text('Femelle'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Mâle',
                      child: Text('Mâle'),
                    ),
                  ],
                  onChanged: (String? value) => setState(() => _sex = value ?? 'Femelle'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RabbitCategory>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: const <DropdownMenuItem<RabbitCategory>>[
                    DropdownMenuItem<RabbitCategory>(
                      value: RabbitCategory.breeder,
                      child: Text('Reproducteur'),
                    ),
                    DropdownMenuItem<RabbitCategory>(
                      value: RabbitCategory.growOut,
                      child: Text('Engraissement'),
                    ),
                  ],
                  onChanged: (RabbitCategory? value) =>
                      setState(() => _category = value ?? RabbitCategory.breeder),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewBreedingPage extends StatefulWidget {
  const NewBreedingPage({super.key});

  @override
  State<NewBreedingPage> createState() => _NewBreedingPageState();
}

class _NewBreedingPageState extends State<NewBreedingPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  MvpRabbit? _buck;
  MvpRabbit? _doe;
  DateTime _date = DateTime.now();
  String _cage = 'Cage';
  bool _checkedAvailability = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedAvailability) {
      return;
    }
    final MvpDemoController store = MvpDemoScope.of(context);
    final List<MvpRabbit> bucks = store.rabbits
        .where((MvpRabbit rabbit) => rabbit.sex.toLowerCase().startsWith('m'))
        .toList();
    final List<MvpRabbit> does = store.rabbits
        .where((MvpRabbit rabbit) => rabbit.sex.toLowerCase().startsWith('f'))
        .toList();
    _checkedAvailability = true;
    if (bucks.isEmpty || does.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajoutez au moins un mâle et une femelle.')),
        );
        Navigator.of(context).pop();
      });
      return;
    }
    _buck = bucks.first;
    _doe = does.first;
    _cage = _doe?.cage ?? _cage;
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 60)),
      initialDate: _date,
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_buck == null || _doe == null) {
      return;
    }
    final MvpDemoController store = MvpDemoScope.of(context);
    store.addBreedingCycle(
      buckName: _buck!.name,
      doeName: _doe!.name,
      date: _date,
      cage: _cage,
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saillie enregistrée.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MvpDemoController store = MvpDemoScope.of(context);
    final List<MvpRabbit> bucks = store.rabbits
        .where((MvpRabbit rabbit) => rabbit.sex.toLowerCase().startsWith('m'))
        .toList();
    final List<MvpRabbit> does = store.rabbits
        .where((MvpRabbit rabbit) => rabbit.sex.toLowerCase().startsWith('f'))
        .toList();

    if ((bucks.isEmpty || does.isEmpty) && _checkedAvailability) {
      return const SizedBox.shrink();
    }

    _buck ??= bucks.isNotEmpty ? bucks.first : null;
    _doe ??= does.isNotEmpty ? does.first : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle saillie')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<MvpRabbit>(
                  value: _buck,
                  decoration: const InputDecoration(labelText: 'Mâle'),
                  items: bucks
                      .map(
                        (MvpRabbit rabbit) => DropdownMenuItem<MvpRabbit>(
                          value: rabbit,
                          child: Text('${rabbit.name} (${rabbit.id})'),
                        ),
                      )
                      .toList(),
                  onChanged: (MvpRabbit? value) => setState(() => _buck = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MvpRabbit>(
                  value: _doe,
                  decoration: const InputDecoration(labelText: 'Femelle'),
                  items: does
                      .map(
                        (MvpRabbit rabbit) => DropdownMenuItem<MvpRabbit>(
                          value: rabbit,
                          child: Text('${rabbit.name} (${rabbit.id})'),
                        ),
                      )
                      .toList(),
                  onChanged: (MvpRabbit? value) =>
                      setState(() => _doe = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _cage,
                  decoration: const InputDecoration(labelText: 'Cage'),
                  onChanged: (String value) => _cage = value.trim(),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(
                    '${_date.day}/${_date.month}/${_date.year}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FinanceEntryPage extends StatefulWidget {
  const FinanceEntryPage({required this.isExpense, super.key});

  final bool isExpense;

  @override
  State<FinanceEntryPage> createState() => _FinanceEntryPageState();
}

class _FinanceEntryPageState extends State<FinanceEntryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late String _type;

  List<String> get _types => widget.isExpense
      ? <String>['Dépense', 'Alimentation', 'Santé']
      : <String>['Vente', 'Engraissement', 'Reproducteur'];

  @override
  void initState() {
    super.initState();
    _type = widget.isExpense ? 'Dépense' : 'Vente';
  }

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final double amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final MvpDemoController store = MvpDemoScope.of(context);
    store.addTransaction(
      label: _labelController.text.trim(),
      amount: amount,
      isExpense: widget.isExpense,
      type: _type,
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isExpense ? 'Dépense ajoutée.' : 'Vente enregistrée.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.isExpense ? 'Nouvelle dépense' : 'Nouvelle vente';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _labelController,
                  decoration: const InputDecoration(labelText: 'Libellé'),
                  validator: (String? value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
                  validator: (String? value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: _types
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) => setState(() => _type = value ?? _type),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
