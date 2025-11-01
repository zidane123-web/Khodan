import 'package:equatable/equatable.dart';

class TaskTemplate extends Equatable {
  const TaskTemplate({
    required this.id,
    required this.profileId,
    required this.name,
    this.slug,
    required this.category,
    required this.scopeType,
    this.speciesId,
    required this.defaultAnchor,
    required this.visibility,
    required this.isActive,
    this.tags = const <String>[],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.steps = const <TaskTemplateStep>[],
  });

  final String id;
  final String profileId;
  final String name;
  final String? slug;
  final String category;
  final String scopeType;
  final int? speciesId;
  final String defaultAnchor;
  final String visibility;
  final bool isActive;
  final List<String> tags;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final List<TaskTemplateStep> steps;

  TaskTemplate copyWith({
    String? id,
    String? profileId,
    String? name,
    String? slug,
    String? category,
    String? scopeType,
    int? speciesId,
    String? defaultAnchor,
    String? visibility,
    bool? isActive,
    List<String>? tags,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    List<TaskTemplateStep>? steps,
  }) {
    return TaskTemplate(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      category: category ?? this.category,
      scopeType: scopeType ?? this.scopeType,
      speciesId: speciesId ?? this.speciesId,
      defaultAnchor: defaultAnchor ?? this.defaultAnchor,
      visibility: visibility ?? this.visibility,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      steps: steps ?? this.steps,
    );
  }

  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawSteps =
        (json['task_template_steps'] ?? json['steps'] ?? <dynamic>[])
            as List<dynamic>;
    final Iterable<String> rawTags =
        (json['tags'] as List<dynamic>? ?? <dynamic>[])
            .cast<String>();
    return TaskTemplate(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      category: json['category'] as String,
      scopeType: json['scope_type'] as String,
      speciesId: json['species_id'] as int?,
      defaultAnchor: json['default_anchor'] as String? ?? 'template_start',
      visibility: json['visibility'] as String? ?? 'private',
      isActive: json['is_active'] as bool? ?? true,
      tags: List<String>.unmodifiable(rawTags),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      archivedAt: (json['archived_at'] as String?) == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      steps: rawSteps
          .map((dynamic item) =>
              TaskTemplateStep.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList()
          .cast<TaskTemplateStep>(),
    );
  }

  Map<String, dynamic> toJson({bool includeSteps = true}) {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'name': name,
      'slug': slug,
      'category': category,
      'scope_type': scopeType,
      'species_id': speciesId,
      'default_anchor': defaultAnchor,
      'visibility': visibility,
      'is_active': isActive,
      'tags': tags,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
      if (includeSteps)
        'task_template_steps': <Map<String, dynamic>>[
          for (final TaskTemplateStep step in steps) step.toJson(),
        ],
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        name,
        slug,
        category,
        scopeType,
        speciesId,
        defaultAnchor,
        visibility,
        isActive,
        tags,
        notes,
        createdAt,
        updatedAt,
        archivedAt,
        steps,
      ];
}

class TaskTemplateStep extends Equatable {
  const TaskTemplateStep({
    required this.id,
    required this.templateId,
    required this.profileId,
    required this.position,
    required this.title,
    required this.taskType,
    required this.category,
    this.description,
    this.offsetDays = 0,
    this.offsetMinutes = 0,
    this.anchor = 'template_start',
    this.autoCompleteRule = const <String, dynamic>{},
    this.notificationOffsets = const <int>[],
    this.priority = 'normal',
    this.assignTo,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String templateId;
  final String profileId;
  final int position;
  final String title;
  final String taskType;
  final String category;
  final String? description;
  final int offsetDays;
  final int offsetMinutes;
  final String anchor;
  final Map<String, dynamic> autoCompleteRule;
  final List<int> notificationOffsets;
  final String priority;
  final String? assignTo;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskTemplateStep copyWith({
    int? id,
    String? templateId,
    String? profileId,
    int? position,
    String? title,
    String? taskType,
    String? category,
    String? description,
    int? offsetDays,
    int? offsetMinutes,
    String? anchor,
    Map<String, dynamic>? autoCompleteRule,
    List<int>? notificationOffsets,
    String? priority,
    String? assignTo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskTemplateStep(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      profileId: profileId ?? this.profileId,
      position: position ?? this.position,
      title: title ?? this.title,
      taskType: taskType ?? this.taskType,
      category: category ?? this.category,
      description: description ?? this.description,
      offsetDays: offsetDays ?? this.offsetDays,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      anchor: anchor ?? this.anchor,
      autoCompleteRule: autoCompleteRule ?? this.autoCompleteRule,
      notificationOffsets:
          notificationOffsets ?? this.notificationOffsets,
      priority: priority ?? this.priority,
      assignTo: assignTo ?? this.assignTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TaskTemplateStep.fromJson(Map<String, dynamic> json) {
    final Iterable<int> offsets =
        (json['notification_offsets'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic value) => (value as num).toInt());
    return TaskTemplateStep(
      id: (json['id'] as num).toInt(),
      templateId: (json['template_id'] ?? json['task_template_id']) as String,
      profileId: json['profile_id'] as String,
      position: (json['position'] as num).toInt(),
      title: json['title'] as String,
      taskType: json['task_type'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      offsetDays: (json['offset_days'] as num?)?.toInt() ?? 0,
      offsetMinutes: (json['offset_minutes'] as num?)?.toInt() ?? 0,
      anchor: json['anchor'] as String? ?? 'template_start',
      autoCompleteRule: json['auto_complete_rule'] == null
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(
              json['auto_complete_rule'] as Map<String, dynamic>,
            ),
      notificationOffsets: List<int>.unmodifiable(offsets),
      priority: json['priority'] as String? ?? 'normal',
      assignTo: json['assign_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'template_id': templateId,
      'profile_id': profileId,
      'position': position,
      'title': title,
      'task_type': taskType,
      'category': category,
      'description': description,
      'offset_days': offsetDays,
      'offset_minutes': offsetMinutes,
      'anchor': anchor,
      'auto_complete_rule': autoCompleteRule,
      'notification_offsets': notificationOffsets,
      'priority': priority,
      'assign_to': assignTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        templateId,
        profileId,
        position,
        title,
        taskType,
        category,
        description,
        offsetDays,
        offsetMinutes,
        anchor,
        autoCompleteRule,
        notificationOffsets,
        priority,
        assignTo,
        createdAt,
        updatedAt,
      ];
}

class TaskTemplateAssignment extends Equatable {
  const TaskTemplateAssignment({
    required this.id,
    required this.profileId,
    required this.templateId,
    required this.scopeType,
    this.scopeId,
    required this.anchorType,
    required this.anchorDate,
    this.anchorMetadata = const <String, dynamic>{},
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String profileId;
  final String templateId;
  final String scopeType;
  final String? scopeId;
  final String anchorType;
  final DateTime anchorDate;
  final Map<String, dynamic> anchorMetadata;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskTemplateAssignment copyWith({
    String? id,
    String? profileId,
    String? templateId,
    String? scopeType,
    String? scopeId,
    String? anchorType,
    DateTime? anchorDate,
    Map<String, dynamic>? anchorMetadata,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskTemplateAssignment(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      templateId: templateId ?? this.templateId,
      scopeType: scopeType ?? this.scopeType,
      scopeId: scopeId ?? this.scopeId,
      anchorType: anchorType ?? this.anchorType,
      anchorDate: anchorDate ?? this.anchorDate,
      anchorMetadata: anchorMetadata ?? this.anchorMetadata,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TaskTemplateAssignment.fromJson(Map<String, dynamic> json) {
    return TaskTemplateAssignment(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      templateId: json['template_id'] as String,
      scopeType: json['scope_type'] as String,
      scopeId: json['scope_id'] as String?,
      anchorType: json['anchor_type'] as String,
      anchorDate: DateTime.parse(json['anchor_date'] as String),
      anchorMetadata: json['anchor_metadata'] == null
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(
              json['anchor_metadata'] as Map<String, dynamic>,
            ),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'template_id': templateId,
      'scope_type': scopeType,
      'scope_id': scopeId,
      'anchor_type': anchorType,
      'anchor_date': DateTime.utc(
        anchorDate.year,
        anchorDate.month,
        anchorDate.day,
      ).toIso8601String(),
      'anchor_metadata': anchorMetadata,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        templateId,
        scopeType,
        scopeId,
        anchorType,
        anchorDate,
        anchorMetadata,
        status,
        notes,
        createdAt,
        updatedAt,
      ];
}

class TaskTemplateAssignmentEvent extends Equatable {
  const TaskTemplateAssignmentEvent({
    required this.assignmentId,
    required this.stepId,
    required this.eventId,
    required this.profileId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String assignmentId;
  final int stepId;
  final String eventId;
  final String profileId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TaskTemplateAssignmentEvent.fromJson(Map<String, dynamic> json) {
    return TaskTemplateAssignmentEvent(
      assignmentId: json['assignment_id'] as String,
      stepId: (json['step_id'] as num).toInt(),
      eventId: json['event_id'] as String,
      profileId: json['profile_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'assignment_id': assignmentId,
      'step_id': stepId,
      'event_id': eventId,
      'profile_id': profileId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
        assignmentId,
        stepId,
        eventId,
        profileId,
        status,
        createdAt,
        updatedAt,
      ];
}
