import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/services/api_client.dart';

class NotificationPayload {
  NotificationPayload({
    required this.taskId,
    required this.triggerAt,
    this.profileId,
    this.title,
    this.body,
    this.assignmentId,
    this.stepId,
    this.email,
    this.phone,
    this.metadata = const <String, dynamic>{},
  });

  final String taskId;
  final DateTime triggerAt;
  final String? profileId;
  final String? title;
  final String? body;
  final String? assignmentId;
  final int? stepId;
  final String? email;
  final String? phone;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'task_id': taskId,
      'trigger_at': triggerAt.toUtc().toIso8601String(),
      'profile_id': profileId,
      'title': title,
      'body': body,
      'assignment_id': assignmentId,
      'step_id': stepId,
      'email': email,
      'phone': phone,
      'metadata': metadata,
    };
  }
}

abstract class NotificationHook {
  Future<void> dispatch(NotificationPayload payload);
}

class NotificationServiceRegistry {
  NotificationServiceRegistry._();

  static final NotificationServiceRegistry instance =
      NotificationServiceRegistry._();

  final List<NotificationHook> _hooks = <NotificationHook>[];

  void register(NotificationHook hook) {
    if (_hooks.contains(hook)) {
      return;
    }
    _hooks.add(hook);
  }

  void unregister(NotificationHook hook) {
    _hooks.remove(hook);
  }

  List<NotificationHook> get hooks =>
      List<NotificationHook>.unmodifiable(_hooks);
}

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialised = false;
  bool _timezoneInitialised = false;

  Future<void> initialize({bool requestPermissions = true}) async {
    if (!_timezoneInitialised) {
      tz.initializeTimeZones();
      _timezoneInitialised = true;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: requestPermissions,
          requestBadgePermission: requestPermissions,
          requestSoundPermission: requestPermissions,
        );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(settings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'planning_reminders',
      'Planning reminders',
      description: 'Task and template reminders for the planning module.',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialised = true;
  }

  Future<void> scheduleTaskReminder({
    required String taskId,
    required DateTime triggerAt,
    required String title,
    String? body,
    String? profileId,
    String? assignmentId,
    int? stepId,
    String? emailTarget,
    String? phoneTarget,
    Map<String, dynamic> metadata = const <String, dynamic>{},
    List<NotificationHook>? hooks,
  }) async {
    if (!_initialised) {
      await initialize();
    }
    if (triggerAt.isBefore(DateTime.now())) {
      return;
    }
    final int notificationId = _buildNotificationId(taskId);
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(triggerAt, tz.local);

    final NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'planning_reminders',
        'Planning reminders',
        channelDescription:
            'Task and template reminders for the planning module.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );

    final NotificationPayload payload = NotificationPayload(
      taskId: taskId,
      triggerAt: triggerAt,
      profileId: profileId,
      title: title,
      body: body,
      assignmentId: assignmentId,
      stepId: stepId,
      email: emailTarget,
      phone: phoneTarget,
      metadata: metadata,
    );

    final List<NotificationHook> effectiveHooks =
        hooks ?? NotificationServiceRegistry.instance.hooks;
    for (final NotificationHook hook in effectiveHooks) {
      try {
        await hook.dispatch(payload);
      } catch (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('Notification hook failed: $error\n$stackTrace');
        }
      }
    }
  }

  Future<void> rescheduleTaskReminder({
    required String taskId,
    required DateTime triggerAt,
    required String title,
    String? body,
    String? profileId,
    String? assignmentId,
    int? stepId,
    String? emailTarget,
    String? phoneTarget,
    Map<String, dynamic> metadata = const <String, dynamic>{},
    List<NotificationHook>? hooks,
  }) async {
    await cancelTaskReminder(taskId);
    await scheduleTaskReminder(
      taskId: taskId,
      triggerAt: triggerAt,
      title: title,
      body: body,
      profileId: profileId,
      assignmentId: assignmentId,
      stepId: stepId,
      emailTarget: emailTarget,
      phoneTarget: phoneTarget,
      metadata: metadata,
      hooks: hooks,
    );
  }

  Future<void> cancelTaskReminder(String taskId) async {
    final int notificationId = _buildNotificationId(taskId);
    await _plugin.cancel(notificationId);
  }

  int _buildNotificationId(String taskId) {
    final int hash = taskId.hashCode;
    return hash.abs();
  }
}

class EmailNotificationHook implements NotificationHook {
  EmailNotificationHook({ApiExecutor? apiClient})
    : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<void> dispatch(NotificationPayload payload) async {
    if (payload.email == null || payload.email!.isEmpty) {
      return;
    }
    if (payload.profileId == null) {
      return;
    }
    await _api.run((SupabaseClient client) {
      return client.from('notifications_outbox').insert(<String, dynamic>{
        'profile_id': payload.profileId,
        'target': payload.email,
        'channel': 'email',
        'payload': payload.toJson(),
        'task_id': payload.taskId,
        'template_assignment_id': payload.assignmentId,
        'template_step_id': payload.stepId,
        'scheduled_at': payload.triggerAt.toUtc().toIso8601String(),
      });
    }, label: 'notifications.email.enqueue');
  }
}

class SmsNotificationHook implements NotificationHook {
  SmsNotificationHook({ApiExecutor? apiClient})
    : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<void> dispatch(NotificationPayload payload) async {
    if (payload.phone == null || payload.phone!.isEmpty) {
      return;
    }
    if (payload.profileId == null) {
      return;
    }
    await _api.run((SupabaseClient client) {
      return client.from('notifications_outbox').insert(<String, dynamic>{
        'profile_id': payload.profileId,
        'target': payload.phone,
        'channel': 'sms',
        'payload': payload.toJson(),
        'task_id': payload.taskId,
        'template_assignment_id': payload.assignmentId,
        'template_step_id': payload.stepId,
        'scheduled_at': payload.triggerAt.toUtc().toIso8601String(),
      });
    }, label: 'notifications.sms.enqueue');
  }
}
