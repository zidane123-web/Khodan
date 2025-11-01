import 'package:uuid/uuid.dart';

import '../../../data/models/animal_event.dart';
import '../../../data/models/event.dart';
import '../../../data/models/task_template.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/repositories/task_template_repository.dart';
import '../../notifications/services/local_notification_service.dart';

class TaskTemplateApplicationResult {
  TaskTemplateApplicationResult({
    required this.assignment,
    required this.events,
  });

  final TaskTemplateAssignment assignment;
  final List<LivestockEvent> events;
}

class TaskTemplateService {
  TaskTemplateService({
    required TaskTemplateRepository taskTemplateRepository,
    required EventRepository eventRepository,
    LocalNotificationService? notificationService,
    Uuid? uuid,
  }) : _taskTemplates = taskTemplateRepository,
       _eventRepository = eventRepository,
       _notifications =
           notificationService ?? LocalNotificationService.instance,
       _uuid = uuid ?? const Uuid();

  final TaskTemplateRepository _taskTemplates;
  final EventRepository _eventRepository;
  final LocalNotificationService _notifications;
  final Uuid _uuid;

  Future<TaskTemplateApplicationResult> applyTemplate({
    required TaskTemplate template,
    required TaskTemplateAssignment assignment,
    required List<String> animalIds,
    Map<String, DateTime> anchorDates = const <String, DateTime>{},
    Map<String, dynamic> metadata = const <String, dynamic>{},
    String? emailTarget,
    String? phoneTarget,
  }) async {
    final DateTime now = DateTime.now();
    final List<TaskTemplateStep> orderedSteps = template.steps.toList()
      ..sort(
        (TaskTemplateStep a, TaskTemplateStep b) =>
            a.position.compareTo(b.position),
      );
    final Map<int, LivestockEvent> eventsByStep = <int, LivestockEvent>{};
    DateTime? previousDate;
    final List<LivestockEvent> createdEvents = <LivestockEvent>[];
    final List<TaskTemplateAssignmentEvent> assignmentEvents =
        <TaskTemplateAssignmentEvent>[];

    for (final TaskTemplateStep step in orderedSteps) {
      final DateTime baseDate = _resolveAnchorDate(
        step.anchor,
        assignment,
        anchorDates,
        previousDate,
        eventsByStep,
      );
      final DateTime scheduledDate = baseDate
          .add(Duration(days: step.offsetDays))
          .add(Duration(minutes: step.offsetMinutes));
      final LivestockEvent event = LivestockEvent(
        id: _uuid.v4(),
        profileId: template.profileId,
        eventType: step.taskType,
        eventDate: scheduledDate,
        details: <String, dynamic>{
          'title': step.title,
          'description': step.description,
          'category': step.category,
          'animalIds': animalIds,
          'origin': 'template',
          'template': <String, dynamic>{
            'assignmentId': assignment.id,
            'stepId': step.id,
          },
          'metadata': metadata,
        },
        notes: step.description,
        taskTemplateAssignmentId: assignment.id,
        taskTemplateStepId: step.id,
      );
      final List<AnimalEventLink> links = animalIds
          .map(
            (String animalId) => AnimalEventLink(
              eventId: event.id,
              animalId: animalId,
              role: 'subject',
            ),
          )
          .toList();
      final LivestockEvent created = await _eventRepository.createEvent(
        event,
        links: links,
      );
      createdEvents.add(created);
      eventsByStep[step.id] = created;
      previousDate = created.eventDate;
      assignmentEvents.add(
        TaskTemplateAssignmentEvent(
          assignmentId: assignment.id,
          stepId: step.id,
          eventId: created.id,
          profileId: template.profileId,
          status: 'active',
          createdAt: now,
          updatedAt: now,
        ),
      );

      for (final int offset in step.notificationOffsets) {
        final DateTime reminderAt = created.eventDate.add(
          Duration(minutes: offset),
        );
        await _notifications.scheduleTaskReminder(
          taskId: '${created.id}#$offset',
          triggerAt: reminderAt,
          title: step.title,
          body: step.description,
          profileId: template.profileId,
          assignmentId: assignment.id,
          stepId: step.id,
          emailTarget: emailTarget,
          phoneTarget: phoneTarget,
          metadata: <String, dynamic>{
            'category': step.category,
            'taskType': step.taskType,
          },
        );
      }
    }

    final TaskTemplateAssignment persisted = await _taskTemplates
        .upsertAssignment(
          assignment.copyWith(updatedAt: now),
          events: assignmentEvents,
        );

    return TaskTemplateApplicationResult(
      assignment: persisted,
      events: createdEvents,
    );
  }

  DateTime _resolveAnchorDate(
    String anchor,
    TaskTemplateAssignment assignment,
    Map<String, DateTime> anchorDates,
    DateTime? previousDate,
    Map<int, LivestockEvent> eventsByStep,
  ) {
    switch (anchor) {
      case 'previous_step':
        return previousDate ?? assignment.anchorDate;
      case 'mating_date':
      case 'palpation_date':
      case 'kindling_date':
      case 'weaning_date':
      case 'custom_date':
        final DateTime? resolved = anchorDates[anchor];
        if (resolved != null) {
          return resolved;
        }
        break;
      default:
        if (anchor.startsWith('step:')) {
          final int? stepId = int.tryParse(anchor.split(':').last);
          if (stepId != null) {
            final LivestockEvent? event = eventsByStep[stepId];
            if (event != null) {
              return event.eventDate;
            }
          }
        }
        break;
    }
    return assignment.anchorDate;
  }
}
