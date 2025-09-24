import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../animals/domain/genealogy_analyzer.dart';

class BreedingRecordScreen extends StatefulWidget {
  const BreedingRecordScreen({
    required this.animals,
    this.initial,
    this.initialDoeId,
    this.initialBuckId,
    super.key,
  });

  final List<Animal> animals;
  final BreedingRecord? initial;
  final String? initialDoeId;
  final String? initialBuckId;

  static Future<BreedingRecord?> show(
    BuildContext context, {
    required List<Animal> animals,
    BreedingRecord? initial,
    String? initialDoeId,
    String? initialBuckId,
  }) {
    return Navigator.of(context).push<BreedingRecord>(
      MaterialPageRoute<BreedingRecord>(
        builder: (_) => BreedingRecordScreen(
          animals: animals,
          initial: initial,
          initialDoeId: initialDoeId,
          initialBuckId: initialBuckId,
        ),
      ),
    );
  }

  @override
  State<BreedingRecordScreen> createState() => _BreedingRecordScreenState();
}

class _BreedingRecordScreenState extends State<BreedingRecordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final GenealogyAnalyzer _analyzer;

  final TextEditingController _bornAliveController = TextEditingController();
  final TextEditingController _bornDeadController = TextEditingController();
  final TextEditingController _adoptedController = TextEditingController();
  final TextEditingController _removedController = TextEditingController();
  final TextEditingController _weanedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedDoeId;
  String? _selectedBuckId;
  late DateTime _matingDate;
  DateTime? _palpationDate;
  String _palpationResult = 'unknown';
  DateTime? _kindlingDate;
  DateTime? _weaningDate;
  double? _pairingCoefficient;

  List<Animal> get _does => widget.animals
      .where(
        (Animal animal) =>
            animal.sex.toLowerCase().contains('fem') ||
            animal.sex.toLowerCase().startsWith('f'),
      )
      .toList();

  List<Animal> get _bucks => widget.animals
      .where(
        (Animal animal) =>
            animal.sex.toLowerCase().contains('mâ') ||
            animal.sex.toLowerCase().contains('mal'),
      )
      .toList();

  DateTime get _plannedPalpationDate =>
      _matingDate.add(const Duration(days: 12));

  DateTime get _plannedKindlingDate =>
      _matingDate.add(const Duration(days: 31));

  DateTime get _plannedWeaningDate =>
      (_kindlingDate ?? _plannedKindlingDate).add(const Duration(days: 28));

  @override
  void initState() {
    super.initState();
    final BreedingRecord? initial = widget.initial;
    _selectedDoeId = initial?.doeId ?? widget.initialDoeId;
    _selectedBuckId = initial?.buckId ?? widget.initialBuckId;
    _matingDate = initial?.matingDate ?? DateTime.now();
    _palpationDate = initial?.palpationDate;
    _palpationResult = initial?.palpationPositive == null
        ? 'unknown'
        : (initial!.palpationPositive! ? 'positive' : 'negative');
    _kindlingDate = initial?.kindlingDate;
    _weaningDate = initial?.weaningDate;

    _bornAliveController.text = initial?.kitsBornAlive?.toString() ?? '';
    _bornDeadController.text = initial?.kitsBornDead?.toString() ?? '';
    _adoptedController.text = initial?.adoptedKitsIn?.toString() ?? '';
    _removedController.text = initial?.kitsRemoved?.toString() ?? '';
    _weanedController.text = initial?.kitsWeaned?.toString() ?? '';
    _weightController.text = initial?.averageWeaningWeight?.toString() ?? '';
    _notesController.text = initial?.notes ?? '';

    final Map<String, Animal> animalsById = <String, Animal>{
      for (final Animal animal in widget.animals) animal.id: animal,
    };
    _analyzer = GenealogyAnalyzer(animalsById);
    _refreshPairingCoefficient();
  }

  @override
  void dispose() {
    _bornAliveController.dispose();
    _bornDeadController.dispose();
    _adoptedController.dispose();
    _removedController.dispose();
    _weanedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year - 1),
      lastDate: DateTime(initialDate.year + 2),
    );
    if (result != null) {
      setState(() {
        onSelected(result);
      });
    }
  }

  void _refreshPairingCoefficient() {
    final double? newValue =
        (_selectedDoeId != null && _selectedBuckId != null)
            ? _analyzer.computePairCoefficient(
                _selectedDoeId,
                _selectedBuckId,
              )
            : null;
    if (newValue != _pairingCoefficient) {
      setState(() {
        _pairingCoefficient = newValue;
      });
    }
  }

  void _submit() {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    if (_selectedDoeId == null || _selectedBuckId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une femelle et un mâle.')),
      );
      return;
    }

    final BreedingRecord base = widget.initial ??
        BreedingRecord(
          id: 'breeding-${DateTime.now().millisecondsSinceEpoch}',
          profileId: 'demo-profile',
          doeId: _selectedDoeId!,
          buckId: _selectedBuckId!,
          matingDate: _matingDate,
        );

    final bool? palpationPositive;
    switch (_palpationResult) {
      case 'positive':
        palpationPositive = true;
        break;
      case 'negative':
        palpationPositive = false;
        break;
      default:
        palpationPositive = null;
    }

    final BreedingRecord record = base.copyWith(
      doeId: _selectedDoeId!,
      buckId: _selectedBuckId!,
      matingDate: _matingDate,
      palpationDate: _palpationDate,
      palpationPositive: palpationPositive,
      kindlingDate: _kindlingDate,
      weaningDate: _weaningDate,
      kitsBornAlive: _parseInt(_bornAliveController.text),
      kitsBornDead: _parseInt(_bornDeadController.text),
      adoptedKitsIn: _parseInt(_adoptedController.text),
      kitsRemoved: _parseInt(_removedController.text),
      kitsWeaned: _parseInt(_weanedController.text),
      averageWeaningWeight: _parseDouble(_weightController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.of(context).pop(record);
  }

  int? _parseInt(String value) {
    return value.trim().isEmpty ? null : int.tryParse(value.trim());
  }

  double? _parseDouble(String value) {
    return value.trim().isEmpty ? null : double.tryParse(value.trim());
  }

  Future<void> _declareKindlingManually() async {
    await _pickDate(
      initialDate: _kindlingDate ?? _plannedKindlingDate,
      onSelected: (DateTime date) {
        _kindlingDate = date;
      },
    );
  }

  Widget _buildDateTile({
    required String title,
    required IconData icon,
    DateTime? value,
    DateTime? planned,
    VoidCallback? onClear,
    required VoidCallback onPick,
  }) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String subtitle;
    if (value != null) {
      subtitle = localizations.formatMediumDate(value);
    } else if (planned != null) {
      subtitle = 'Prévu le ${localizations.formatMediumDate(planned)}';
    } else {
      subtitle = 'À planifier';
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (value != null && onClear != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Effacer',
              onPressed: () => setState(onClear),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Choisir une date',
            onPressed: onPick,
          ),
        ],
      ),
      onTap: onPick,
    );
  }

  Widget _buildTimelineCard(ThemeData theme) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final DateTime plannedPalpation = _plannedPalpationDate;
    final DateTime plannedKindling = _plannedKindlingDate;
    final DateTime plannedWeaning = _plannedWeaningDate;

    final List<_TimelineStep> steps = <_TimelineStep>[
      _TimelineStep(
        label: 'Saillie',
        icon: Icons.favorite_outline,
        plannedDate: _matingDate,
        actualDate: _matingDate,
        highlight: true,
      ),
      _TimelineStep(
        label: 'Palpation',
        icon: Icons.monitor_heart,
        plannedDate: plannedPalpation,
        actualDate: _palpationDate,
      ),
      _TimelineStep(
        label: 'Mise-bas',
        icon: Icons.nest_cam_wired_stand,
        plannedDate: plannedKindling,
        actualDate: _kindlingDate,
      ),
      _TimelineStep(
        label: 'Sevrage',
        icon: Icons.child_care_outlined,
        plannedDate: plannedWeaning,
        actualDate: _weaningDate,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Chronologie du cycle', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            for (int i = 0; i < steps.length; i++)
              _TimelineStepTile(
                data: steps[i],
                isLast: i == steps.length - 1,
                localizations: localizations,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPairingSection(ThemeData theme) {
    if (_pairingCoefficient == null) {
      return const SizedBox.shrink();
    }

    final double value =
        _pairingCoefficient!.clamp(0.0, 0.125).toDouble();
    final double normalized = value / 0.125;
    final _RiskLevel risk = _RiskLevel.fromValue(_pairingCoefficient!);
    final Color color = risk.color(theme);
    final String message = risk.message(_pairingCoefficient!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.analytics_outlined,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Coefficient de consanguinité : ${_pairingCoefficient!.toStringAsFixed(3)}',
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: normalized.isFinite ? normalized : 0,
            minHeight: 10,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initial == null ? 'Nouvelle saillie' : 'Modifier la saillie',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _submit,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Accouplement', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedDoeId,
                      decoration: const InputDecoration(
                        labelText: 'Femelle',
                      ),
                      validator: (String? value) =>
                          value == null ? 'Sélection obligatoire' : null,
                      items: _does
                          .map(
                            (Animal animal) => DropdownMenuItem<String>(
                              value: animal.id,
                              child: Text(
                                '${animal.tagId}${animal.name != null ? ' · ${animal.name}' : ''}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedDoeId = value;
                        });
                        _refreshPairingCoefficient();
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedBuckId,
                      decoration: const InputDecoration(
                        labelText: 'Mâle',
                      ),
                      validator: (String? value) =>
                          value == null ? 'Sélection obligatoire' : null,
                      items: _bucks
                          .map(
                            (Animal animal) => DropdownMenuItem<String>(
                              value: animal.id,
                              child: Text(
                                '${animal.tagId}${animal.name != null ? ' · ${animal.name}' : ''}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedBuckId = value;
                        });
                        _refreshPairingCoefficient();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDateTile(
                      title: 'Date de saillie',
                      icon: Icons.favorite,
                      value: _matingDate,
                      onPick: () => _pickDate(
                        initialDate: _matingDate,
                        onSelected: (DateTime value) {
                          _matingDate = value;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPairingSection(theme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineCard(theme),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Suivi de gestation',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildDateTile(
                      title: 'Palpation',
                      icon: Icons.monitor_heart,
                      value: _palpationDate,
                      planned: _plannedPalpationDate,
                      onClear: () {
                        _palpationDate = null;
                      },
                      onPick: () => _pickDate(
                        initialDate: _palpationDate ?? _plannedPalpationDate,
                        onSelected: (DateTime value) {
                          _palpationDate = value;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _palpationResult,
                      decoration: const InputDecoration(
                        labelText: 'Résultat',
                      ),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: 'unknown',
                          child: Text('À confirmer'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'positive',
                          child: Text('Gestante'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'negative',
                          child: Text('Non gestante'),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _palpationResult = value;
                          if (value != 'positive' && _kindlingDate == null) {
                            _weaningDate = null;
                            _bornAliveController.clear();
                            _bornDeadController.clear();
                            _adoptedController.clear();
                            _removedController.clear();
                            _weanedController.clear();
                            _weightController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mise-bas',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _KindlingSection(
                      enabled:
                          _palpationResult == 'positive' || _kindlingDate != null,
                      plannedKindling: _plannedKindlingDate,
                      kindlingDate: _kindlingDate,
                      bornAliveController: _bornAliveController,
                      bornDeadController: _bornDeadController,
                      adoptedController: _adoptedController,
                      removedController: _removedController,
                      onSelectDate: () => _pickDate(
                        initialDate: _kindlingDate ?? _plannedKindlingDate,
                        onSelected: (DateTime value) {
                          _kindlingDate = value;
                        },
                      ),
                      onClearDate: () {
                        _kindlingDate = null;
                      },
                      onRequestManual: () async {
                        await _declareKindlingManually();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _WeaningCard(
              enabled: _palpationResult == 'positive' || _kindlingDate != null,
              plannedWeaning: _plannedWeaningDate,
              weaningDate: _weaningDate,
              onSelectDate: () => _pickDate(
                initialDate: _weaningDate ?? _plannedWeaningDate,
                onSelected: (DateTime value) {
                  _weaningDate = value;
                },
              ),
              onClearDate: () {
                _weaningDate = null;
              },
              weanedController: _weanedController,
              weightController: _weightController,
              onRequestManualKindling: _declareKindlingManually,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Notes', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Observations, détails sur la portée…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Enregistrer la saillie'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.plannedDate,
    this.actualDate,
    this.highlight = false,
  });

  final String label;
  final IconData icon;
  final DateTime plannedDate;
  final DateTime? actualDate;
  final bool highlight;
}

class _TimelineStepTile extends StatelessWidget {
  const _TimelineStepTile({
    required this.data,
    required this.isLast,
    required this.localizations,
  });

  final _TimelineStep data;
  final bool isLast;
  final MaterialLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isCompleted = data.actualDate != null;
    final Color indicatorColor = isCompleted
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;
    final String subtitle = isCompleted
        ? 'Réalisé le ${localizations.formatMediumDate(data.actualDate!)}'
        : 'Prévu le ${localizations.formatMediumDate(data.plannedDate)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              CircleAvatar(
                radius: 14,
                backgroundColor: indicatorColor.withOpacity(0.15),
                child: Icon(
                  data.icon,
                  size: 16,
                  color: indicatorColor,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 48,
                  color: indicatorColor.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color:
                        data.highlight ? theme.colorScheme.primary : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KindlingSection extends StatelessWidget {
  const _KindlingSection({
    required this.enabled,
    required this.plannedKindling,
    required this.kindlingDate,
    required this.bornAliveController,
    required this.bornDeadController,
    required this.adoptedController,
    required this.removedController,
    required this.onSelectDate,
    required this.onClearDate,
    required this.onRequestManual,
  });

  final bool enabled;
  final DateTime plannedKindling;
  final DateTime? kindlingDate;
  final TextEditingController bornAliveController;
  final TextEditingController bornDeadController;
  final TextEditingController adoptedController;
  final TextEditingController removedController;
  final VoidCallback onSelectDate;
  final VoidCallback onClearDate;
  final Future<void> Function() onRequestManual;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.55,
          child: AbsorbPointer(
            absorbing: !enabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.nest_cam_wired_stand),
                  title: const Text('Date de mise-bas'),
                  subtitle: Text(
                    kindlingDate != null
                        ? localizations.formatMediumDate(kindlingDate!)
                        : 'Prévu le ${localizations.formatMediumDate(plannedKindling)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (kindlingDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: onClearDate,
                        ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        onPressed: onSelectDate,
                      ),
                    ],
                  ),
                  onTap: onSelectDate,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: bornAliveController,
                        decoration: const InputDecoration(
                          labelText: 'Nés vivants',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: bornDeadController,
                        decoration: const InputDecoration(
                          labelText: 'Mort-nés',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: adoptedController,
                        decoration: const InputDecoration(
                          labelText: 'Lapereaux adoptés',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: removedController,
                        decoration: const InputDecoration(
                          labelText: 'Lapereaux retirés',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (!enabled) ...<Widget>[
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Confirmez la gestation pour renseigner la mise-bas.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onRequestManual,
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text('Déclarer une mise-bas'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _WeaningCard extends StatelessWidget {
  const _WeaningCard({
    required this.enabled,
    required this.plannedWeaning,
    required this.weaningDate,
    required this.onSelectDate,
    required this.onClearDate,
    required this.weanedController,
    required this.weightController,
    required this.onRequestManualKindling,
  });

  final bool enabled;
  final DateTime plannedWeaning;
  final DateTime? weaningDate;
  final VoidCallback onSelectDate;
  final VoidCallback onClearDate;
  final TextEditingController weanedController;
  final TextEditingController weightController;
  final Future<void> Function() onRequestManualKindling;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Sevrage de la portée', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: enabled ? 1 : 0.55,
              child: AbsorbPointer(
                absorbing: !enabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.child_care_outlined),
                      title: const Text('Date de sevrage'),
                      subtitle: Text(
                        weaningDate != null
                            ? localizations.formatMediumDate(weaningDate!)
                            : 'Prévu le ${localizations.formatMediumDate(plannedWeaning)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (weaningDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: onClearDate,
                            ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today_outlined),
                            onPressed: onSelectDate,
                          ),
                        ],
                      ),
                      onTap: onSelectDate,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: weanedController,
                            decoration: const InputDecoration(
                              labelText: 'Lapereaux sevrés',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: weightController,
                            decoration: const InputDecoration(
                              labelText: 'Poids moyen (kg)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (!enabled) ...<Widget>[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Renseignez la mise-bas avant d’ouvrir le suivi du sevrage.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: onRequestManualKindling,
                        icon: const Icon(Icons.nest_cam_wired_stand),
                        label: const Text('Déclarer une mise-bas'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _RiskLevel { low, medium, high }

extension on _RiskLevel {
  static _RiskLevel fromValue(double value) {
    if (value >= 0.0625) {
      return _RiskLevel.high;
    }
    if (value >= 0.03125) {
      return _RiskLevel.medium;
    }
    return _RiskLevel.low;
  }

  Color color(ThemeData theme) {
    switch (this) {
      case _RiskLevel.low:
        return Colors.green.shade600;
      case _RiskLevel.medium:
        return Colors.orange.shade600;
      case _RiskLevel.high:
        return theme.colorScheme.error;
    }
  }

  String message(double value) {
    switch (this) {
      case _RiskLevel.low:
        return 'Risque faible. Coefficient estimé à ${value.toStringAsFixed(3)}.';
      case _RiskLevel.medium:
        return 'Surveillez cette portée : coefficient ${value.toStringAsFixed(3)}.';
      case _RiskLevel.high:
        return 'Risque élevé de consanguinité (${value.toStringAsFixed(3)}). Envisagez un autre croisement.';
    }
  }
}
