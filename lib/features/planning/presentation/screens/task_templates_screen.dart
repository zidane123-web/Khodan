import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:uuid/uuid.dart';

import '../../../../data/models/breeding_record.dart';
import '../../../../data/models/task_template.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/repositories/task_template_repository.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../services/task_template_service.dart';
import '../cubit/task_templates_cubit.dart';

class TaskTemplatesScreen extends StatelessWidget {
  const TaskTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthState authState = context.read<AuthCubit>().state;
    final String? profileId =
        authState.profile?.id ?? authState.session?.user.id;

    if (profileId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modeles de taches')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Connectez-vous pour gerer vos modeles de taches.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return BlocProvider<TaskTemplatesCubit>(
      create: (BuildContext context) {
        final TaskTemplateRepository templateRepository = context
            .read<TaskTemplateRepository>();
        final BreedingRepository breedingRepository = context
            .read<BreedingRepository>();
        final EventRepository eventRepository = context.read<EventRepository>();
        final TaskTemplateService service = TaskTemplateService(
          taskTemplateRepository: templateRepository,
          eventRepository: eventRepository,
        );
        return TaskTemplatesCubit(
          templateRepository: templateRepository,
          breedingRepository: breedingRepository,
          service: service,
          profileId: profileId,
        )..load();
      },
      child: const _TaskTemplatesView(),
    );
  }
}

class _TaskTemplatesView extends StatelessWidget {
  const _TaskTemplatesView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskTemplatesCubit, TaskTemplatesState>(
      listener: (BuildContext context, TaskTemplatesState state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(state.successMessage!)));
        }
      },
      builder: (BuildContext context, TaskTemplatesState state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Modeles de taches'),
            actions: <Widget>[
              IconButton(
                onPressed: state.loading
                    ? null
                    : () => context.read<TaskTemplatesCubit>().load(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.saving || state.applying
                ? null
                : () => _openTemplateDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Nouveau modele'),
          ),
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : _TaskTemplateList(state: state),
        );
      },
    );
  }

  void _openTemplateDialog(
    BuildContext context, {
    TaskTemplate? template,
  }) async {
    final TaskTemplatesCubit cubit = context.read<TaskTemplatesCubit>();
    final TaskTemplate? result = await showDialog<TaskTemplate>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _TaskTemplateFormDialog(
          profileId: cubit.profileId,
          template: template,
        );
      },
    );
    if (result != null && context.mounted) {
      await cubit.saveTemplate(result);
    }
  }
}

class _TaskTemplateList extends StatelessWidget {
  const _TaskTemplateList({required this.state});

  final TaskTemplatesState state;

  @override
  Widget build(BuildContext context) {
    if (state.templates.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aucun modele defini pour le moment.\nCreez un modele pour generer vos taches recurentes.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: state.templates.length,
      itemBuilder: (BuildContext context, int index) {
        final TaskTemplate template = state.templates[index];
        return _TemplateTile(
          template: template,
          breedingRecords: state.breedingRecords,
        );
      },
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template, required this.breedingRecords});

  final TaskTemplate template;
  final List<BreedingRecord> breedingRecords;

  @override
  Widget build(BuildContext context) {
    final TaskTemplatesCubit cubit = context.read<TaskTemplatesCubit>();
    final List<TaskTemplateStep> orderedSteps = template.steps.toList()
      ..sort((TaskTemplateStep a, TaskTemplateStep b) {
        return a.position.compareTo(b.position);
      });

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    template.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<_TemplateAction>(
                  onSelected: (_TemplateAction action) async {
                    switch (action) {
                      case _TemplateAction.edit:
                        _TaskTemplatesView()._openTemplateDialog(
                          context,
                          template: template,
                        );
                        break;
                      case _TemplateAction.apply:
                        await _ApplyTemplateDialog.show(
                          context: context,
                          template: template,
                          breedingRecords: breedingRecords,
                          profileId: cubit.profileId,
                        );
                        break;
                      case _TemplateAction.delete:
                        await cubit.deleteTemplate(template.id);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<_TemplateAction>>[
                        const PopupMenuItem<_TemplateAction>(
                          value: _TemplateAction.edit,
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Modifier'),
                          ),
                        ),
                        const PopupMenuItem<_TemplateAction>(
                          value: _TemplateAction.apply,
                          child: ListTile(
                            leading: Icon(Icons.playlist_add),
                            title: Text('Appliquer'),
                          ),
                        ),
                        const PopupMenuItem<_TemplateAction>(
                          value: _TemplateAction.delete,
                          child: ListTile(
                            leading: Icon(Icons.delete_outline),
                            title: Text('Supprimer'),
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${template.category} - ${template.scopeType} - ${orderedSteps.length} etape${orderedSteps.length > 1 ? 's' : ''}',
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: orderedSteps
                  .map(
                    (TaskTemplateStep step) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${step.position}. ${step.title} - ${step.taskType} - J+${step.offsetDays}',
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (template.notes != null && template.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(template.notes!),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () => _OpenTemplateActions.openApply(
                    context: context,
                    template: template,
                    breedingRecords: breedingRecords,
                    profileId: cubit.profileId,
                  ),
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Appliquer'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _OpenTemplateActions.openForm(
                    context: context,
                    profileId: cubit.profileId,
                    initialTemplate: template,
                    onSubmit: (TaskTemplate result) =>
                        cubit.saveTemplate(result),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier'),
                ),
                TextButton.icon(
                  onPressed: () => cubit.deleteTemplate(template.id),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Supprimer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _TemplateAction { edit, apply, delete }

class _OpenTemplateActions {
  const _OpenTemplateActions._();

  static Future<void> openForm({
    required BuildContext context,
    required String profileId,
    TaskTemplate? initialTemplate,
    required Future<void> Function(TaskTemplate template) onSubmit,
  }) async {
    final TaskTemplate? result = await showDialog<TaskTemplate>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _TaskTemplateFormDialog(
          profileId: profileId,
          template: initialTemplate,
        );
      },
    );
    if (result != null && context.mounted) {
      await onSubmit(result);
    }
  }

  static Future<void> openApply({
    required BuildContext context,
    required TaskTemplate template,
    required List<BreedingRecord> breedingRecords,
    required String profileId,
  }) async {
    final TaskTemplatesCubit cubit = context.read<TaskTemplatesCubit>();
    final _ApplyTemplateResult? result = await showDialog<_ApplyTemplateResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _ApplyTemplateDialog(
          template: template,
          breedingRecords: breedingRecords,
          profileId: profileId,
        );
      },
    );
    if (result != null && context.mounted) {
      await cubit.applyTemplate(
        template: template,
        assignment: result.assignment,
        animalIds: result.animalIds,
        anchorDates: result.anchorDates,
        metadata: result.metadata,
        emailTarget: result.email,
        phoneTarget: result.phone,
      );
    }
  }
}

class _TaskTemplateFormDialog extends StatefulWidget {
  const _TaskTemplateFormDialog({required this.profileId, this.template});

  final String profileId;
  final TaskTemplate? template;

  @override
  State<_TaskTemplateFormDialog> createState() =>
      _TaskTemplateFormDialogState();
}

class _TaskTemplateFormDialogState extends State<_TaskTemplateFormDialog> {
  static const List<String> _categories = <String>[
    'reproduction',
    'health',
    'logistics',
    'monitoring',
  ];
  static const List<String> _scopes = <String>['litter', 'treatment', 'custom'];
  static const List<String> _anchors = <String>[
    'template_start',
    'previous_step',
    'mating_date',
    'palpation_date',
    'kindling_date',
    'weaning_date',
    'custom_date',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;
  late String _category;
  late String _scopeType;
  late String _defaultAnchor;
  bool _isActive = true;
  final List<_EditableStep> _steps = <_EditableStep>[];

  @override
  void initState() {
    super.initState();
    final TaskTemplate? template = widget.template;
    _nameController = TextEditingController(text: template?.name ?? '');
    _slugController = TextEditingController(text: template?.slug ?? '');
    _notesController = TextEditingController(text: template?.notes ?? '');
    _tagsController = TextEditingController(
      text: template == null ? '' : template.tags.join(', '),
    );
    _category = template?.category ?? _categories.first;
    _scopeType = template?.scopeType ?? _scopes.first;
    _defaultAnchor = template?.defaultAnchor ?? _anchors.first;
    _isActive = template?.isActive ?? true;

    if (template != null) {
      for (final TaskTemplateStep step in template.steps) {
        _steps.add(_EditableStep.fromStep(step));
      }
    } else {
      _steps.add(_EditableStep.newStep(widget.profileId));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    for (final _EditableStep step in _steps) {
      step.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.template == null
            ? 'Nouveau modele'
            : 'Modifier ${widget.template!.name}',
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom du modele'),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nom requis';
                    }
                    return null;
                  },
                  onChanged: (String value) {
                    if (_slugController.text.trim().isEmpty) {
                      _slugController.text = _slugify(value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _slugController,
                  decoration: const InputDecoration(
                    labelText: 'Slug (optionnel)',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: 'Categorie',
                        ),
                        items: _categories
                            .map(
                              (String item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _scopeType,
                        decoration: const InputDecoration(
                          labelText: 'Portee / traitement',
                        ),
                        items: _scopes
                            .map(
                              (String item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => _scopeType = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _defaultAnchor,
                  decoration: const InputDecoration(
                    labelText: 'Ancre par defaut',
                  ),
                  items: _anchors
                      .map(
                        (String item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _defaultAnchor = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (separes par des virgules)',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (bool value) {
                    setState(() => _isActive = value);
                  },
                  title: const Text('Modele actif'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Text(
                      'Etapes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    Text('(${_steps.length})'),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children: _steps
                      .asMap()
                      .entries
                      .map(
                        (MapEntry<int, _EditableStep> entry) =>
                            _buildStepCard(entry.key, entry.value),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _steps.add(_EditableStep.newStep(widget.profileId));
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une etape'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _save, child: const Text('Enregistrer')),
      ],
    );
  }

  Widget _buildStepCard(int index, _EditableStep editable) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Etape ${index + 1}'),
                const Spacer(),
                IconButton(
                  onPressed: _steps.length <= 1
                      ? null
                      : () {
                          setState(() => _steps.removeAt(index));
                        },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            TextFormField(
              controller: editable.titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Titre requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: editable.taskTypeController,
              decoration: const InputDecoration(labelText: 'Type de tache'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: editable.anchor,
              decoration: const InputDecoration(labelText: 'Ancre'),
              items: _anchors
                  .map(
                    (String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => editable.anchor = value);
                }
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: editable.offsetDaysController,
                    decoration: const InputDecoration(labelText: 'Jours'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: editable.offsetMinutesController,
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: editable.notificationsController,
              decoration: const InputDecoration(
                labelText: 'Notifications (min, separateur virgule)',
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: editable.descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Ajoutez au moins une etape.')),
        );
      return;
    }

    final DateTime now = DateTime.now();
    final TaskTemplate? existing = widget.template;
    final String templateId = existing?.id ?? const Uuid().v4();
    final List<String> tags = _tagsController.text
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList();

    final List<TaskTemplateStep> steps = <TaskTemplateStep>[];
    for (int i = 0; i < _steps.length; i++) {
      final _EditableStep editable = _steps[i];
      final int stepId =
          editable.existingId ??
          editable.generatedId ??
          -DateTime.now().millisecondsSinceEpoch - i;
      final int offsetDays =
          int.tryParse(editable.offsetDaysController.text.trim()) ?? 0;
      final int offsetMinutes =
          int.tryParse(editable.offsetMinutesController.text.trim()) ?? 0;
      final List<int> notificationOffsets = editable
          .notificationsController
          .text
          .split(',')
          .map((String raw) => raw.trim())
          .where((String raw) => raw.isNotEmpty)
          .map((String raw) => int.tryParse(raw) ?? 0)
          .toList();
      steps.add(
        TaskTemplateStep(
          id: stepId,
          templateId: templateId,
          profileId: widget.profileId,
          position: i + 1,
          title: editable.titleController.text.trim(),
          taskType: editable.taskTypeController.text.trim(),
          category: _category,
          description: editable.descriptionController.text.trim().isEmpty
              ? null
              : editable.descriptionController.text.trim(),
          offsetDays: offsetDays,
          offsetMinutes: offsetMinutes,
          anchor: editable.anchor,
          autoCompleteRule: const <String, dynamic>{},
          notificationOffsets: notificationOffsets,
          priority: 'normal',
          assignTo: null,
          createdAt: editable.createdAt ?? now,
          updatedAt: now,
        ),
      );
    }

    final TaskTemplate result = TaskTemplate(
      id: templateId,
      profileId: widget.profileId,
      name: _nameController.text.trim(),
      slug: _slugController.text.trim().isEmpty
          ? _slugify(_nameController.text.trim())
          : _slugController.text.trim(),
      category: _category,
      scopeType: _scopeType,
      speciesId: existing?.speciesId,
      defaultAnchor: _defaultAnchor,
      visibility: existing?.visibility ?? 'private',
      isActive: _isActive,
      tags: tags,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      archivedAt: existing?.archivedAt,
      steps: steps,
    );

    Navigator.of(context).pop(result);
  }

  String _slugify(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp('-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-+$'), '');
  }
}

class _EditableStep {
  _EditableStep({
    required this.templateId,
    required this.profileId,
    required this.titleController,
    required this.taskTypeController,
    required this.offsetDaysController,
    required this.offsetMinutesController,
    required this.notificationsController,
    required this.descriptionController,
    required this.anchor,
    this.existingId,
    this.generatedId,
    this.createdAt,
    this.updatedAt,
  });

  factory _EditableStep.fromStep(TaskTemplateStep step) {
    return _EditableStep(
      templateId: step.templateId,
      profileId: step.profileId,
      titleController: TextEditingController(text: step.title),
      taskTypeController: TextEditingController(text: step.taskType),
      offsetDaysController: TextEditingController(
        text: step.offsetDays.toString(),
      ),
      offsetMinutesController: TextEditingController(
        text: step.offsetMinutes.toString(),
      ),
      notificationsController: TextEditingController(
        text: step.notificationOffsets.join(','),
      ),
      descriptionController: TextEditingController(
        text: step.description ?? '',
      ),
      anchor: step.anchor,
      existingId: step.id,
      createdAt: step.createdAt,
      updatedAt: step.updatedAt,
    );
  }

  factory _EditableStep.newStep(String profileId) {
    final int tempId = _tempIdCounter--;
    return _EditableStep(
      templateId: '',
      profileId: profileId,
      titleController: TextEditingController(text: 'Nouvelle etape'),
      taskTypeController: TextEditingController(text: 'custom'),
      offsetDaysController: TextEditingController(text: '0'),
      offsetMinutesController: TextEditingController(text: '0'),
      notificationsController: TextEditingController(),
      descriptionController: TextEditingController(),
      anchor: 'template_start',
      generatedId: tempId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static int _tempIdCounter = -1;

  final String templateId;
  final String profileId;
  final TextEditingController titleController;
  final TextEditingController taskTypeController;
  final TextEditingController offsetDaysController;
  final TextEditingController offsetMinutesController;
  final TextEditingController notificationsController;
  final TextEditingController descriptionController;
  String anchor;
  final int? existingId;
  final int? generatedId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  void dispose() {
    titleController.dispose();
    taskTypeController.dispose();
    offsetDaysController.dispose();
    offsetMinutesController.dispose();
    notificationsController.dispose();
    descriptionController.dispose();
  }
}

class _ApplyTemplateResult {
  _ApplyTemplateResult({
    required this.assignment,
    required this.animalIds,
    required this.anchorDates,
    required this.metadata,
    this.email,
    this.phone,
  });

  final TaskTemplateAssignment assignment;
  final List<String> animalIds;
  final Map<String, DateTime> anchorDates;
  final Map<String, dynamic> metadata;
  final String? email;
  final String? phone;
}

class _ApplyTemplateDialog extends StatefulWidget {
  const _ApplyTemplateDialog({
    required this.template,
    required this.breedingRecords,
    required this.profileId,
  });

  final TaskTemplate template;
  final List<BreedingRecord> breedingRecords;
  final String profileId;

  static Future<_ApplyTemplateResult?> show({
    required BuildContext context,
    required TaskTemplate template,
    required List<BreedingRecord> breedingRecords,
    required String profileId,
  }) {
    return showDialog<_ApplyTemplateResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _ApplyTemplateDialog(
          template: template,
          breedingRecords: breedingRecords,
          profileId: profileId,
        );
      },
    );
  }

  @override
  State<_ApplyTemplateDialog> createState() => _ApplyTemplateDialogState();
}

class _ApplyTemplateDialogState extends State<_ApplyTemplateDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _animalsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  BreedingRecord? _selectedBreeding;
  late DateTime _anchorDate;
  late String _anchorType;

  @override
  void initState() {
    super.initState();
    _anchorType = widget.template.defaultAnchor;
    _anchorDate = DateTime.now();
    if (widget.breedingRecords.isNotEmpty) {
      _selectedBreeding = widget.breedingRecords.first;
      final DateTime? mating = _selectedBreeding?.matingDate;
      if (mating != null) {
        _anchorDate = mating;
      }
    }
  }

  @override
  void dispose() {
    _animalsController.dispose();
    _notesController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Appliquer ${widget.template.name}'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButtonFormField<BreedingRecord>(
                  // ignore: deprecated_member_use
                  value: _selectedBreeding,
                  decoration: const InputDecoration(
                    labelText: 'Portee (optionnel)',
                  ),
                  items: widget.breedingRecords
                      .map(
                        (BreedingRecord record) =>
                            DropdownMenuItem<BreedingRecord>(
                              value: record,
                              child: Text(_formatBreeding(record)),
                            ),
                      )
                      .toList(),
                  onChanged: (BreedingRecord? value) {
                    setState(() => _selectedBreeding = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _anchorType,
                  decoration: const InputDecoration(
                    labelText: 'Ancre utilisee',
                  ),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'template_start',
                      child: Text('Debut du modele'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'mating_date',
                      child: Text('Saillie'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'kindling_date',
                      child: Text('Mise bas'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'custom_date',
                      child: Text('Date personnalisee'),
                    ),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _anchorType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _anchorDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _anchorDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date dancrage',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      '${_anchorDate.year}-${_anchorDate.month.toString().padLeft(2, '0')}-${_anchorDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _animalsController,
                  decoration: const InputDecoration(
                    labelText: 'Animaux (IDs separes par des virgules)',
                    hintText: 'doe-001,buck-001',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Notification e-mail (optionnel)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Notification SMS (optionnel)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Appliquer')),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final DateTime now = DateTime.now();
    final List<String> animalIds = _animalsController.text
        .split(',')
        .map((String raw) => raw.trim())
        .where((String raw) => raw.isNotEmpty)
        .toList();

    final TaskTemplateAssignment assignment = TaskTemplateAssignment(
      id: const Uuid().v4(),
      profileId: widget.profileId,
      templateId: widget.template.id,
      scopeType: _selectedBreeding == null ? 'custom' : 'litter',
      scopeId: _selectedBreeding?.id,
      anchorType: _anchorType,
      anchorDate: _anchorDate,
      anchorMetadata: <String, dynamic>{
        if (_selectedBreeding != null) 'breedingId': _selectedBreeding!.id,
      },
      status: 'active',
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    Navigator.of(context).pop(
      _ApplyTemplateResult(
        assignment: assignment,
        animalIds: animalIds,
        anchorDates: <String, DateTime>{_anchorType: _anchorDate},
        metadata: <String, dynamic>{'notes': _notesController.text.trim()},
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      ),
    );
  }

  static String _formatBreeding(BreedingRecord record) {
    final String doe = record.doeId;
    final String buck = record.buckId;
    final DateTime matingDate = record.matingDate;
    final String dateText =
        '${matingDate.year}-${matingDate.month.toString().padLeft(2, '0')}-'
        '${matingDate.day.toString().padLeft(2, '0')}';
    return '$doe x $buck - $dateText';
  }
}
