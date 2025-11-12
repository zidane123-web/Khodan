import 'dart:collection';

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
      UnmodifiableListView<NotificationHook>(_hooks);
}
