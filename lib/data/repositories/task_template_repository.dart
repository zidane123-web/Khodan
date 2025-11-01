import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/local_data_sources.dart';
import '../models/sync_action.dart';
import '../models/task_template.dart';
import '../services/api_client.dart';
import '../services/offline_sync_manager.dart';

abstract class TaskTemplateRepository {
  Future<List<TaskTemplate>> fetchTemplates(String profileId);

  Future<TaskTemplate?> fetchTemplate(String id);

  Future<TaskTemplate> createTemplate(TaskTemplate template);

  Future<TaskTemplate> updateTemplate(TaskTemplate template);

  Future<void> deleteTemplate(String id);

  Future<List<TaskTemplateAssignment>> fetchAssignments(String profileId);

  Future<TaskTemplateAssignment?> fetchAssignment(String id);

  Future<TaskTemplateAssignment> upsertAssignment(
    TaskTemplateAssignment assignment, {
    List<TaskTemplateAssignmentEvent> events,
  });

  Future<void> deleteAssignment(String id);

  Future<List<TaskTemplateAssignmentEvent>> fetchAssignmentEvents(
    String assignmentId,
  );
}

class SupabaseTaskTemplateRepository implements TaskTemplateRepository {
  SupabaseTaskTemplateRepository({ApiExecutor? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<List<TaskTemplate>> fetchTemplates(String profileId) async {
    final List<dynamic> data = await _api.run(
      (SupabaseClient client) {
        final PostgrestTransformBuilder<PostgrestList> query = client
            .from('task_templates')
            .select('*, task_template_steps(*)')
            .eq('profile_id', profileId)
            .order('name');
        query.order(
          'position',
          ascending: true,
          referencedTable: 'task_template_steps',
        );
        return query;
      },
      label: 'taskTemplates.fetch',
    );
    return data
        .map((dynamic row) => TaskTemplate.fromJson(
              Map<String, dynamic>.from(row as Map),
            ))
        .toList();
  }

  @override
  Future<TaskTemplate?> fetchTemplate(String id) async {
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        final PostgrestTransformBuilder<PostgrestList> query = client
            .from('task_templates')
            .select('*, task_template_steps(*)')
            .eq('id', id)
            .limit(1);
        query.order(
          'position',
          ascending: true,
          referencedTable: 'task_template_steps',
        );
        return query;
      },
      label: 'taskTemplates.fetchOne',
    );
    if (response.isEmpty) {
      return null;
    }
    return TaskTemplate.fromJson(
      Map<String, dynamic>.from(response.first as Map),
    );
  }

  @override
  Future<TaskTemplate> createTemplate(TaskTemplate template) async {
    final Map<String, dynamic> payload = _buildTemplatePayload(template);
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('task_templates')
            .insert(payload)
            .select('*, task_template_steps(*)');
      },
      label: 'taskTemplates.create',
    );
    final Map<String, dynamic> json =
        Map<String, dynamic>.from(response.first as Map);
    return TaskTemplate.fromJson(json);
  }

  @override
  Future<TaskTemplate> updateTemplate(TaskTemplate template) async {
    final Map<String, dynamic> payload = _buildTemplatePayload(
      template,
      includeSteps: false,
    );
    await _api.run(
      (SupabaseClient client) {
        return client
            .from('task_templates')
            .update(payload)
            .eq('id', template.id);
      },
      label: 'taskTemplates.update',
    );

    final List<TaskTemplateStep> steps = template.steps;
    final Iterable<int> retainedIds =
        steps.where((TaskTemplateStep step) => step.id > 0).map(
              (TaskTemplateStep step) => step.id,
            );
    if (steps.isEmpty) {
      await _api.run(
        (SupabaseClient client) {
          return client
              .from('task_template_steps')
              .delete()
              .eq('template_id', template.id);
        },
        label: 'taskTemplateSteps.clear',
      );
    } else {
      await _api.run(
        (SupabaseClient client) {
          final builder = client
              .from('task_template_steps')
              .delete()
              .eq('template_id', template.id);
          if (retainedIds.isNotEmpty) {
            builder.not(
              'id',
              'in',
              '(${retainedIds.join(',')})',
            );
          }
          return builder;
        },
        label: 'taskTemplateSteps.prune',
      );

      await _api.run(
        (SupabaseClient client) {
          return client
              .from('task_template_steps')
              .upsert(
                steps
                    .map((TaskTemplateStep step) =>
                        _buildStepPayload(step, template.profileId))
                    .toList(),
                onConflict: 'id',
              )
              .select();
        },
        label: 'taskTemplateSteps.upsert',
      );
    }

    return (await fetchTemplate(template.id))!;
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _api.run(
      (SupabaseClient client) {
        return client.from('task_templates').delete().eq('id', id);
      },
      label: 'taskTemplates.delete',
    );
  }

  @override
  Future<List<TaskTemplateAssignment>> fetchAssignments(
    String profileId,
  ) async {
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('task_template_assignments')
            .select()
            .eq('profile_id', profileId)
            .order('updated_at', ascending: false);
      },
      label: 'taskTemplateAssignments.fetch',
    );
    return response
        .map((dynamic row) => TaskTemplateAssignment.fromJson(
              Map<String, dynamic>.from(row as Map),
            ))
        .toList();
  }

  @override
  Future<TaskTemplateAssignment?> fetchAssignment(String id) async {
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('task_template_assignments')
            .select()
            .eq('id', id)
            .limit(1);
      },
      label: 'taskTemplateAssignments.fetchOne',
    );
    if (response.isEmpty) {
      return null;
    }
    return TaskTemplateAssignment.fromJson(
      Map<String, dynamic>.from(response.first as Map),
    );
  }

  @override
  Future<TaskTemplateAssignment> upsertAssignment(
    TaskTemplateAssignment assignment, {
    List<TaskTemplateAssignmentEvent> events =
        const <TaskTemplateAssignmentEvent>[],
  }) async {
    final Map<String, dynamic> payload = _buildAssignmentPayload(assignment);
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('task_template_assignments')
            .upsert(payload, onConflict: 'id')
            .select();
      },
      label: 'taskTemplateAssignments.upsert',
    );
    if (events.isEmpty) {
      await _api.run(
        (SupabaseClient client) {
          return client
              .from('task_template_assignment_events')
              .delete()
              .eq('assignment_id', assignment.id);
        },
        label: 'taskTemplateAssignmentEvents.clear',
      );
    } else {
      await _api.run(
        (SupabaseClient client) {
          return client
              .from('task_template_assignment_events')
              .upsert(
                events
                    .map((TaskTemplateAssignmentEvent event) =>
                        _buildAssignmentEventPayload(event))
                    .toList(),
                onConflict: 'assignment_id,step_id,event_id',
              )
              .select();
        },
        label: 'taskTemplateAssignmentEvents.upsert',
      );
    }
    final Map<String, dynamic> json =
        Map<String, dynamic>.from(response.first as Map);
    return TaskTemplateAssignment.fromJson(json);
  }

  @override
  Future<void> deleteAssignment(String id) async {
    await _api.run(
      (SupabaseClient client) {
        return client
            .from('task_template_assignments')
            .delete()
            .eq('id', id);
      },
      label: 'taskTemplateAssignments.delete',
    );
  }

  @override
  Future<List<TaskTemplateAssignmentEvent>> fetchAssignmentEvents(
    String assignmentId,
  ) async {
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('task_template_assignment_events')
            .select()
            .eq('assignment_id', assignmentId)
            .order('step_id');
      },
      label: 'taskTemplateAssignmentEvents.fetch',
    );
    return response
        .map((dynamic row) => TaskTemplateAssignmentEvent.fromJson(
              Map<String, dynamic>.from(row as Map),
            ))
        .toList();
  }

  Map<String, dynamic> _buildTemplatePayload(
    TaskTemplate template, {
    bool includeSteps = true,
  }) {
    final Map<String, dynamic> json = template.toJson(includeSteps: false);
    json.remove('created_at');
    json.remove('updated_at');
    json.remove('archived_at');
    if (!includeSteps) {
      return json;
    }
    json['task_template_steps'] = <Map<String, dynamic>>[
      for (final TaskTemplateStep step in template.steps)
        _buildStepPayload(step, template.profileId),
    ];
    return json;
  }

  Map<String, dynamic> _buildStepPayload(
    TaskTemplateStep step,
    String profileId,
  ) {
    final Map<String, dynamic> json = <String, dynamic>{
      'template_id': step.templateId,
      'profile_id': profileId,
      'position': step.position,
      'title': step.title,
      'task_type': step.taskType,
      'category': step.category,
      'description': step.description,
      'offset_days': step.offsetDays,
      'offset_minutes': step.offsetMinutes,
      'anchor': step.anchor,
      'auto_complete_rule': step.autoCompleteRule,
      'notification_offsets': step.notificationOffsets,
      'priority': step.priority,
      'assign_to': step.assignTo,
    };
    if (step.id > 0) {
      json['id'] = step.id;
    }
    return json;
  }

  Map<String, dynamic> _buildAssignmentPayload(
    TaskTemplateAssignment assignment,
  ) {
    final Map<String, dynamic> json = assignment.toJson();
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  Map<String, dynamic> _buildAssignmentEventPayload(
    TaskTemplateAssignmentEvent event,
  ) {
    final Map<String, dynamic> json = event.toJson();
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }
}

class InMemoryTaskTemplateRepository implements TaskTemplateRepository {
  InMemoryTaskTemplateRepository();

  final Map<String, TaskTemplate> _templates =
      <String, TaskTemplate>{};
  final Map<String, TaskTemplateAssignment> _assignments =
      <String, TaskTemplateAssignment>{};
  final Map<String, List<TaskTemplateAssignmentEvent>> _assignmentEvents =
      <String, List<TaskTemplateAssignmentEvent>>{};
  final Random _random = Random();

  @override
  Future<List<TaskTemplate>> fetchTemplates(String profileId) async {
    final List<TaskTemplate> templates = _templates.values
        .where((TaskTemplate template) => template.profileId == profileId)
        .map(_cloneTemplate)
        .toList()
      ..sort((TaskTemplate a, TaskTemplate b) => a.name.compareTo(b.name));
    return templates;
  }

  @override
  Future<TaskTemplate?> fetchTemplate(String id) async {
    final TaskTemplate? template = _templates[id];
    return template == null ? null : _cloneTemplate(template);
  }

  @override
  Future<TaskTemplate> createTemplate(TaskTemplate template) async {
    final TaskTemplate normalised = _normaliseTemplate(template);
    _templates[normalised.id] = normalised;
    return _cloneTemplate(normalised);
  }

  @override
  Future<TaskTemplate> updateTemplate(TaskTemplate template) async {
    final TaskTemplate normalised = _normaliseTemplate(template);
    _templates[normalised.id] = normalised;
    return _cloneTemplate(normalised);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    _templates.remove(id);
    final Iterable<String> assignmentsToRemove = _assignments.values
        .where((TaskTemplateAssignment assignment) => assignment.templateId == id)
        .map((TaskTemplateAssignment assignment) => assignment.id);
    for (final String assignmentId in assignmentsToRemove) {
      await deleteAssignment(assignmentId);
    }
  }

  @override
  Future<List<TaskTemplateAssignment>> fetchAssignments(
    String profileId,
  ) async {
    final List<TaskTemplateAssignment> assignments = _assignments.values
        .where((TaskTemplateAssignment assignment) => assignment.profileId == profileId)
        .map(_cloneAssignment)
        .toList()
      ..sort((TaskTemplateAssignment a, TaskTemplateAssignment b) => b.updatedAt.compareTo(a.updatedAt));
    return assignments;
  }

  @override
  Future<TaskTemplateAssignment?> fetchAssignment(String id) async {
    final TaskTemplateAssignment? assignment = _assignments[id];
    return assignment == null ? null : _cloneAssignment(assignment);
  }

  @override
  Future<TaskTemplateAssignment> upsertAssignment(
    TaskTemplateAssignment assignment, {
    List<TaskTemplateAssignmentEvent> events =
        const <TaskTemplateAssignmentEvent>[],
  }) async {
    _assignments[assignment.id] = assignment;
    _assignmentEvents[assignment.id] =
        events.map(_cloneAssignmentEvent).toList();
    return _cloneAssignment(assignment);
  }

  @override
  Future<void> deleteAssignment(String id) async {
    _assignments.remove(id);
    _assignmentEvents.remove(id);
  }

  @override
  Future<List<TaskTemplateAssignmentEvent>> fetchAssignmentEvents(
    String assignmentId,
  ) async {
    final List<TaskTemplateAssignmentEvent> events =
        _assignmentEvents[assignmentId] ?? const <TaskTemplateAssignmentEvent>[];
    return events.map(_cloneAssignmentEvent).toList()
      ..sort((TaskTemplateAssignmentEvent a, TaskTemplateAssignmentEvent b) => a.stepId.compareTo(b.stepId));
  }

  TaskTemplate _normaliseTemplate(TaskTemplate template) {
    final List<TaskTemplateStep> steps = <TaskTemplateStep>[];
    for (int index = 0; index < template.steps.length; index++) {
      final TaskTemplateStep step = template.steps[index];
      final int currentId = step.id;
      final int newId = currentId > 0 ? currentId : _generateTemporaryStepId();
      steps.add(
        step.copyWith(
          id: newId,
          position: index + 1,
        ),
      );
    }
    return template.copyWith(steps: steps);
  }

  int _generateTemporaryStepId() {
    return -(_random.nextInt(1 << 31) + 1);
  }

  TaskTemplate _cloneTemplate(TaskTemplate template) {
    return template.copyWith(
      steps: <TaskTemplateStep>[
        for (final TaskTemplateStep step in template.steps) step.copyWith(),
      ],
    );
  }

  TaskTemplateAssignment _cloneAssignment(
    TaskTemplateAssignment assignment,
  ) {
    return assignment.copyWith(
      anchorMetadata: Map<String, dynamic>.from(assignment.anchorMetadata),
    );
  }

  TaskTemplateAssignmentEvent _cloneAssignmentEvent(
    TaskTemplateAssignmentEvent event,
  ) {
    return TaskTemplateAssignmentEvent(
      assignmentId: event.assignmentId,
      stepId: event.stepId,
      eventId: event.eventId,
      profileId: event.profileId,
      status: event.status,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    );
  }
}

class SyncedTaskTemplateRepository implements TaskTemplateRepository {
  SyncedTaskTemplateRepository({
    required TaskTemplateRepository remote,
    required LocalTaskTemplateDataSource localTemplates,
    required LocalTaskTemplateAssignmentDataSource localAssignments,
    OfflineSyncManager? offlineManager,
  })  : _remote = remote,
        _localTemplates = localTemplates,
        _localAssignments = localAssignments,
        _offlineManager = offlineManager ?? OfflineSyncManager.instance {
    _registerHandlers();
  }

  final TaskTemplateRepository _remote;
  final LocalTaskTemplateDataSource _localTemplates;
  final LocalTaskTemplateAssignmentDataSource _localAssignments;
  final OfflineSyncManager _offlineManager;
  bool _handlersRegistered = false;

  @override
  Future<List<TaskTemplate>> fetchTemplates(String profileId) async {
    if (_offlineManager.isOffline.value) {
      return _localTemplates.fetchTemplates(profileId);
    }
    try {
      final List<TaskTemplate> templates =
          await _remote.fetchTemplates(profileId);
      await _localTemplates.replaceTemplates(
        templates,
        profileId: profileId,
      );
      return templates;
    } catch (_) {
      return _localTemplates.fetchTemplates(profileId);
    }
  }

  @override
  Future<TaskTemplate?> fetchTemplate(String id) async {
    if (_offlineManager.isOffline.value) {
      return _localTemplates.fetchTemplateById(id);
    }
    final TaskTemplate? template = await _remote.fetchTemplate(id);
    if (template != null) {
      await _localTemplates.upsertTemplates(<TaskTemplate>[template]);
      return template;
    }
    return _localTemplates.fetchTemplateById(id);
  }

  @override
  Future<TaskTemplate> createTemplate(TaskTemplate template) async {
    if (_offlineManager.isOffline.value) {
      await _localTemplates.upsertTemplates(
        <TaskTemplate>[template],
        syncState: kSyncStatePending,
      );
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.createTaskTemplate,
          description: 'Creer modele ${template.name}',
          payload: <String, dynamic>{'template': template.toJson()},
          rollbackPayload: <String, dynamic>{'template_id': template.id},
          priority: 85,
        ),
      );
      return template;
    }
    final TaskTemplate created = await _remote.createTemplate(template);
    await _localTemplates.upsertTemplates(<TaskTemplate>[created]);
    return created;
  }

  @override
  Future<TaskTemplate> updateTemplate(TaskTemplate template) async {
    final TaskTemplate? previous =
        await _localTemplates.fetchTemplateById(template.id);
    if (_offlineManager.isOffline.value) {
      await _localTemplates.upsertTemplates(
        <TaskTemplate>[template],
        syncState: kSyncStatePending,
      );
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.updateTaskTemplate,
          description: 'Mettre a jour modele ${template.name}',
          payload: <String, dynamic>{'template': template.toJson()},
          rollbackPayload: previous == null
              ? <String, dynamic>{'template_id': template.id}
              : <String, dynamic>{'template': previous.toJson()},
          priority: 80,
        ),
      );
      return template;
    }
    final TaskTemplate updated = await _remote.updateTemplate(template);
    await _localTemplates.upsertTemplates(<TaskTemplate>[updated]);
    return updated;
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final TaskTemplate? previous =
        await _localTemplates.fetchTemplateById(id);
    if (_offlineManager.isOffline.value) {
      await _localTemplates.deleteTemplate(id);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.deleteTaskTemplate,
          description: 'Supprimer modele $id',
          payload: <String, dynamic>{'template_id': id},
          rollbackPayload: previous == null
              ? null
              : <String, dynamic>{'template': previous.toJson()},
          priority: 75,
        ),
      );
      return;
    }
    await _remote.deleteTemplate(id);
    await _localTemplates.deleteTemplate(id);
  }

  @override
  Future<List<TaskTemplateAssignment>> fetchAssignments(
    String profileId,
  ) async {
    if (_offlineManager.isOffline.value) {
      return _localAssignments.fetchAssignments(profileId);
    }
    try {
      final List<TaskTemplateAssignment> assignments =
          await _remote.fetchAssignments(profileId);
      final Map<String, List<TaskTemplateAssignmentEvent>> eventsMap =
          <String, List<TaskTemplateAssignmentEvent>>{};
      for (final TaskTemplateAssignment assignment in assignments) {
        eventsMap[assignment.id] =
            await _remote.fetchAssignmentEvents(assignment.id);
      }
      await _localAssignments.replaceAssignments(
        assignments,
        profileId: profileId,
        eventsByAssignment: eventsMap,
      );
      return assignments;
    } catch (_) {
      return _localAssignments.fetchAssignments(profileId);
    }
  }

  @override
  Future<TaskTemplateAssignment?> fetchAssignment(String id) async {
    if (_offlineManager.isOffline.value) {
      return _localAssignments.fetchAssignment(id);
    }
    final TaskTemplateAssignment? assignment =
        await _remote.fetchAssignment(id);
    if (assignment != null) {
      final List<TaskTemplateAssignmentEvent> events =
          await _remote.fetchAssignmentEvents(assignment.id);
      await _localAssignments.upsertAssignment(
        assignment,
        events: events,
      );
      return assignment;
    }
    return _localAssignments.fetchAssignment(id);
  }

  @override
  Future<TaskTemplateAssignment> upsertAssignment(
    TaskTemplateAssignment assignment, {
    List<TaskTemplateAssignmentEvent> events =
        const <TaskTemplateAssignmentEvent>[],
  }) async {
    final TaskTemplateAssignment? snapshot =
        await _localAssignments.fetchAssignment(assignment.id);
    final bool isUpdate = snapshot != null;
    final List<TaskTemplateAssignmentEvent> previousEvents = isUpdate
        ? await _localAssignments.fetchAssignmentEvents(assignment.id)
        : const <TaskTemplateAssignmentEvent>[];
    if (_offlineManager.isOffline.value) {
      final Map<String, dynamic> rollbackPayload;
      if (snapshot != null) {
        rollbackPayload = <String, dynamic>{
          'assignment': snapshot.toJson(),
          'events': <Map<String, dynamic>>[
            for (final TaskTemplateAssignmentEvent event in previousEvents)
              event.toJson(),
          ],
        };
      } else {
        rollbackPayload = <String, dynamic>{'assignment_id': assignment.id};
      }
      await _localAssignments.upsertAssignment(
        assignment,
        events: events,
        syncState: kSyncStatePending,
      );
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: isUpdate
              ? SyncActionType.updateTaskTemplateAssignment
              : SyncActionType.createTaskTemplateAssignment,
          description:
              'Mettre a jour attribution ${assignment.id}',
          payload: <String, dynamic>{
            'assignment': assignment.toJson(),
            'events': <Map<String, dynamic>>[
              for (final TaskTemplateAssignmentEvent event in events)
                event.toJson(),
            ],
          },
          rollbackPayload: rollbackPayload,
          priority: 70,
        ),
      );
      return assignment;
    }
    final TaskTemplateAssignment result = await _remote.upsertAssignment(
      assignment,
      events: events,
    );
    await _localAssignments.upsertAssignment(
      result,
      events: events,
    );
    return result;
  }

  @override
  Future<void> deleteAssignment(String id) async {
    final TaskTemplateAssignment? snapshot =
        await _localAssignments.fetchAssignment(id);
    final List<TaskTemplateAssignmentEvent> existingEvents =
        await _localAssignments.fetchAssignmentEvents(id);
    if (_offlineManager.isOffline.value) {
      await _localAssignments.deleteAssignment(id);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.deleteTaskTemplateAssignment,
          description: 'Supprimer attribution $id',
          payload: <String, dynamic>{'assignment_id': id},
          rollbackPayload: snapshot == null
              ? null
              : <String, dynamic>{
                  'assignment': snapshot.toJson(),
                  'events': <Map<String, dynamic>>[
                    for (final TaskTemplateAssignmentEvent event in existingEvents)
                      event.toJson(),
                  ],
                },
          priority: 65,
        ),
      );
      return;
    }
    await _remote.deleteAssignment(id);
    await _localAssignments.deleteAssignment(id);
  }

  @override
  Future<List<TaskTemplateAssignmentEvent>> fetchAssignmentEvents(
    String assignmentId,
  ) async {
    if (_offlineManager.isOffline.value) {
      return _localAssignments.fetchAssignmentEvents(assignmentId);
    }
    final List<TaskTemplateAssignmentEvent> events =
        await _remote.fetchAssignmentEvents(assignmentId);
    final TaskTemplateAssignment? assignment =
        await _localAssignments.fetchAssignment(assignmentId);
    if (assignment != null) {
      await _localAssignments.upsertAssignment(
        assignment,
        events: events,
      );
    }
    return events;
  }

  void _registerHandlers() {
    if (_handlersRegistered) {
      return;
    }
    _handlersRegistered = true;

    _offlineManager.registerHandler(
      SyncActionType.createTaskTemplate,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> json =
            action.payload['template'] as Map<String, dynamic>;
        final TaskTemplate template = TaskTemplate.fromJson(json);
        final TaskTemplate created = await _remote.createTemplate(template);
        await _localTemplates.upsertTemplates(
          <TaskTemplate>[created],
          syncState: kSyncStateSynced,
        );
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final String? templateId =
            action.rollbackPayload?['template_id'] as String?;
        if (templateId != null) {
          await _localTemplates.deleteTemplate(templateId);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.updateTaskTemplate,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> json =
            action.payload['template'] as Map<String, dynamic>;
        final TaskTemplate template = TaskTemplate.fromJson(json);
        final TaskTemplate updated = await _remote.updateTemplate(template);
        await _localTemplates.upsertTemplates(
          <TaskTemplate>[updated],
          syncState: kSyncStateSynced,
        );
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? json =
            action.rollbackPayload?['template'] as Map<String, dynamic>?;
        if (json != null) {
          await _localTemplates.upsertTemplates(
            <TaskTemplate>[TaskTemplate.fromJson(json)],
            syncState: kSyncStateSynced,
          );
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.deleteTaskTemplate,
      (QueuedSyncAction action) async {
        final String id = action.payload['template_id'] as String;
        await _remote.deleteTemplate(id);
        await _localTemplates.deleteTemplate(id);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? json =
            action.rollbackPayload?['template'] as Map<String, dynamic>?;
        if (json != null) {
          await _localTemplates.upsertTemplates(
            <TaskTemplate>[TaskTemplate.fromJson(json)],
            syncState: kSyncStateSynced,
          );
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.createTaskTemplateAssignment,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> json =
            action.payload['assignment'] as Map<String, dynamic>;
        final List<dynamic> rawEvents =
            action.payload['events'] as List<dynamic>? ?? <dynamic>[];
        final TaskTemplateAssignment assignment =
            TaskTemplateAssignment.fromJson(json);
        final List<TaskTemplateAssignmentEvent> events =
            rawEvents
                .map(
                  (dynamic eventJson) =>
                      TaskTemplateAssignmentEvent.fromJson(
                        Map<String, dynamic>.from(eventJson as Map),
                      ),
                )
                .toList();
        final TaskTemplateAssignment created = await _remote.upsertAssignment(
          assignment,
          events: events,
        );
        await _localAssignments.upsertAssignment(
          created,
          events: events,
          syncState: kSyncStateSynced,
        );
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final String? assignmentId =
            action.rollbackPayload?['assignment_id'] as String?;
        if (assignmentId != null) {
          await _localAssignments.deleteAssignment(assignmentId);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.updateTaskTemplateAssignment,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> json =
            action.payload['assignment'] as Map<String, dynamic>;
        final List<dynamic> rawEvents =
            action.payload['events'] as List<dynamic>? ?? <dynamic>[];
        final TaskTemplateAssignment assignment =
            TaskTemplateAssignment.fromJson(json);
        final List<TaskTemplateAssignmentEvent> events =
            rawEvents
                .map(
                  (dynamic eventJson) =>
                      TaskTemplateAssignmentEvent.fromJson(
                        Map<String, dynamic>.from(eventJson as Map),
                      ),
                )
                .toList();
        final TaskTemplateAssignment updated = await _remote.upsertAssignment(
          assignment,
          events: events,
        );
        await _localAssignments.upsertAssignment(
          updated,
          events: events,
          syncState: kSyncStateSynced,
        );
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? json =
            action.rollbackPayload?['assignment'] as Map<String, dynamic>?;
        final List<dynamic> rawEvents =
            action.rollbackPayload?['events'] as List<dynamic>? ?? <dynamic>[];
        if (json != null) {
          final TaskTemplateAssignment assignment =
              TaskTemplateAssignment.fromJson(json);
          final List<TaskTemplateAssignmentEvent> events =
              rawEvents
                  .map(
                    (dynamic eventJson) =>
                        TaskTemplateAssignmentEvent.fromJson(
                          Map<String, dynamic>.from(eventJson as Map),
                        ),
                  )
                  .toList();
          await _localAssignments.upsertAssignment(
            assignment,
            events: events,
            syncState: kSyncStateSynced,
          );
        } else {
          final String? assignmentId =
              action.rollbackPayload?['assignment_id'] as String?;
          if (assignmentId != null) {
            await _localAssignments.deleteAssignment(assignmentId);
          }
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.deleteTaskTemplateAssignment,
      (QueuedSyncAction action) async {
        final String id = action.payload['assignment_id'] as String;
        await _remote.deleteAssignment(id);
        await _localAssignments.deleteAssignment(id);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? json =
            action.rollbackPayload?['assignment'] as Map<String, dynamic>?;
        final List<dynamic> rawEvents =
            action.rollbackPayload?['events'] as List<dynamic>? ?? <dynamic>[];
        if (json != null) {
          final TaskTemplateAssignment assignment =
              TaskTemplateAssignment.fromJson(json);
          final List<TaskTemplateAssignmentEvent> events =
              rawEvents
                  .map(
                    (dynamic eventJson) =>
                        TaskTemplateAssignmentEvent.fromJson(
                          Map<String, dynamic>.from(eventJson as Map),
                        ),
                  )
                  .toList();
          await _localAssignments.upsertAssignment(
            assignment,
            events: events,
            syncState: kSyncStateSynced,
          );
        }
      },
    );
  }
}
