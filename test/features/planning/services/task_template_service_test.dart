import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:khodan/data/models/animal_event.dart';
import 'package:khodan/data/models/event.dart';
import 'package:khodan/data/models/task_template.dart';
import 'package:khodan/data/repositories/event_repository.dart';
import 'package:khodan/data/repositories/task_template_repository.dart';
import 'package:khodan/features/notifications/services/local_notification_service.dart';
import 'package:khodan/features/planning/services/task_template_service.dart';

class _MockTaskTemplateRepository extends Mock
    implements TaskTemplateRepository {}

class _MockEventRepository extends Mock implements EventRepository {}

class _MockNotificationService extends Mock
    implements LocalNotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockTaskTemplateRepository templates;
  late _MockEventRepository events;
  late _MockNotificationService notifications;
  late TaskTemplateService service;

  setUpAll(() {
    registerFallbackValue(
      LivestockEvent(
        id: 'fallback',
        profileId: 'profile',
        eventType: 'fallback',
        eventDate: DateTime.utc(2025, 1, 1),
        details: const <String, dynamic>{},
        notes: '',
      ),
    );
    registerFallbackValue(
      const AnimalEventLink(
        eventId: 'fallback',
        animalId: 'fallback',
        role: 'subject',
      ),
    );
    registerFallbackValue(
      TaskTemplateAssignment(
        id: 'assignment-fallback',
        profileId: 'profile',
        templateId: 'template',
        scopeType: 'custom',
        anchorType: 'template_start',
        anchorDate: DateTime.utc(2025, 1, 1),
        anchorMetadata: const <String, dynamic>{},
        status: 'active',
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      ),
    );
    registerFallbackValue(const <TaskTemplateAssignmentEvent>[]);
    registerFallbackValue(<AnimalEventLink>[]);
  });

  setUp(() {
    templates = _MockTaskTemplateRepository();
    events = _MockEventRepository();
    notifications = _MockNotificationService();
    service = TaskTemplateService(
      taskTemplateRepository: templates,
      eventRepository: events,
      notificationService: notifications,
    );
  });

  group('TaskTemplateService.applyTemplate', () {
    test('generates events, assignment links, and reminders', () async {
      final DateTime anchor = DateTime.utc(2025, 3, 1);
      final TaskTemplateStep breedingStep = TaskTemplateStep(
        id: 1,
        templateId: 'template-1',
        profileId: 'profile-1',
        position: 0,
        title: 'Palpation',
        taskType: 'palpation',
        category: 'reproduction',
        description: 'Controle gestation',
        offsetDays: 0,
        offsetMinutes: 0,
        anchor: 'mating_date',
        autoCompleteRule: const <String, dynamic>{},
        notificationOffsets: const <int>[0],
        priority: 'normal',
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      );
      final TaskTemplateStep followUpStep = TaskTemplateStep(
        id: 2,
        templateId: 'template-1',
        profileId: 'profile-1',
        position: 1,
        title: 'Mise bas',
        taskType: 'kindling',
        category: 'reproduction',
        description: 'Suivi mise bas',
        offsetDays: 30,
        offsetMinutes: 0,
        anchor: 'previous_step',
        autoCompleteRule: const <String, dynamic>{},
        notificationOffsets: const <int>[-60, 0],
        priority: 'important',
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      );
      final TaskTemplate template = TaskTemplate(
        id: 'template-1',
        profileId: 'profile-1',
        name: 'Gestation standard 31 j',
        category: 'reproduction',
        scopeType: 'litter',
        defaultAnchor: 'mating_date',
        visibility: 'private',
        isActive: true,
        tags: const <String>['breeding'],
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
        steps: <TaskTemplateStep>[breedingStep, followUpStep],
      );
      final TaskTemplateAssignment assignment = TaskTemplateAssignment(
        id: 'assignment-1',
        profileId: 'profile-1',
        templateId: template.id,
        scopeType: 'litter',
        scopeId: 'breeding-1',
        anchorType: 'mating_date',
        anchorDate: anchor,
        anchorMetadata: const <String, dynamic>{'breedingId': 'breeding-1'},
        status: 'active',
        createdAt: DateTime.utc(2025, 2, 20),
        updatedAt: DateTime.utc(2025, 2, 20),
      );

      final List<LivestockEvent> createdEvents = <LivestockEvent>[];
      when(
        () => events.createEvent(any(), links: any(named: 'links')),
      ).thenAnswer((Invocation invocation) async {
        final LivestockEvent event =
            invocation.positionalArguments.first as LivestockEvent;
        createdEvents.add(event);
        return event;
      });
      when(
        () => templates.upsertAssignment(any(), events: any(named: 'events')),
      ).thenAnswer(
        (Invocation invocation) async =>
            invocation.positionalArguments.first as TaskTemplateAssignment,
      );
      final List<Map<String, dynamic>> reminders = <Map<String, dynamic>>[];
      when(
        () => notifications.scheduleTaskReminder(
          taskId: any(named: 'taskId'),
          triggerAt: any(named: 'triggerAt'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          profileId: any(named: 'profileId'),
          assignmentId: any(named: 'assignmentId'),
          stepId: any(named: 'stepId'),
          emailTarget: any(named: 'emailTarget'),
          phoneTarget: any(named: 'phoneTarget'),
          metadata: any(named: 'metadata'),
          hooks: any(named: 'hooks'),
        ),
      ).thenAnswer((Invocation invocation) async {
        reminders.add(<String, dynamic>{
          'taskId': invocation.namedArguments[#taskId] as String,
          'triggerAt': invocation.namedArguments[#triggerAt] as DateTime,
          'stepId': invocation.namedArguments[#stepId] as int?,
        });
      });

      final TaskTemplateApplicationResult result = await service.applyTemplate(
        template: template,
        assignment: assignment,
        animalIds: const <String>['doe-001', 'buck-001'],
        anchorDates: <String, DateTime>{'mating_date': anchor},
        metadata: const <String, dynamic>{'origin': 'test'},
        emailTarget: 'farmer@example.com',
        phoneTarget: '+22912345678',
      );

      expect(createdEvents, hasLength(2));
      final LivestockEvent firstEvent = createdEvents.first;
      final LivestockEvent secondEvent = createdEvents.last;
      expect(firstEvent.eventDate, anchor);
      expect(secondEvent.eventDate, anchor.add(const Duration(days: 30)));
      expect(firstEvent.taskTemplateAssignmentId, assignment.id);
      expect(secondEvent.taskTemplateStepId, followUpStep.id);

      expect(result.events, hasLength(2));
      expect(result.assignment.id, assignment.id);

      final VerificationResult assignmentCall = verify(
        () => templates.upsertAssignment(
          captureAny(),
          events: captureAny(named: 'events'),
        ),
      );
      assignmentCall.called(1);
      expect(reminders, hasLength(3));
      expect(reminders.first['taskId'] as String, endsWith('#0'));
      expect(reminders.last['stepId'], equals(followUpStep.id));

      final TaskTemplateAssignment persistedAssignment =
          assignmentCall.captured.first as TaskTemplateAssignment;
      final List<TaskTemplateAssignmentEvent> persistedEvents =
          assignmentCall.captured.last as List<TaskTemplateAssignmentEvent>;
      expect(persistedAssignment.id, assignment.id);
      expect(persistedEvents, hasLength(2));
      expect(
        persistedEvents.map((TaskTemplateAssignmentEvent e) => e.stepId),
        orderedEquals(<int>[breedingStep.id, followUpStep.id]),
      );
    });
  });
}
