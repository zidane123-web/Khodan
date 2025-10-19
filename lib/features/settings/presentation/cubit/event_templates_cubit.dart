import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/event_template.dart';
import '../../../../data/repositories/event_template_repository.dart';

class EventTemplatesState extends Equatable {
  const EventTemplatesState({
    this.templates = const <EventTemplate>[],
    this.loading = false,
    this.saving = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<EventTemplate> templates;
  final bool loading;
  final bool saving;
  final String? errorMessage;
  final String? successMessage;

  EventTemplatesState copyWith({
    List<EventTemplate>? templates,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return EventTemplatesState(
      templates: templates ?? this.templates,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        templates,
        loading,
        saving,
        errorMessage,
        successMessage,
      ];
}

class EventTemplatesCubit extends Cubit<EventTemplatesState> {
  EventTemplatesCubit(this._repository, {required this.profileId})
      : super(const EventTemplatesState());

  final EventTemplateRepository _repository;
  final String profileId;

  bool _initialised = false;

  Future<void> initialize() async {
    if (_initialised) {
      return;
    }
    _initialised = true;
    await _loadTemplates(showLoader: true);
  }

  Future<void> refresh() => _loadTemplates(showLoader: false);

  Future<void> saveTemplate({
    int? id,
    required String name,
    required String eventType,
    required Map<String, dynamic> defaultDetails,
  }) async {
    emit(state.copyWith(saving: true, clearError: true, clearSuccess: true));
    final EventTemplate? existing = _findTemplate(id);
    final int resolvedId = id ?? _generateTemporaryId();
    final DateTime createdAt = existing?.createdAt ?? DateTime.now();
    final EventTemplate template = EventTemplate(
      id: resolvedId,
      userId: profileId,
      templateName: name.trim(),
      eventType: eventType.trim(),
      defaultDetails: defaultDetails,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
    try {
      final bool isUpdate = id != null;
      final EventTemplate result = isUpdate
          ? await _repository.updateTemplate(template)
          : await _repository.createTemplate(template);
      final String message = isUpdate
          ? 'Modèle mis à jour avec succès.'
          : 'Modèle créé avec succès.';
      await _loadTemplates(showLoader: false, successMessage: message);
      if (id == null && result.id != resolvedId) {
        await _loadTemplates(showLoader: false);
      }
    } catch (error) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> deleteTemplate(int id) async {
    emit(state.copyWith(saving: true, clearError: true, clearSuccess: true));
    try {
      await _repository.deleteTemplate(id);
      await _loadTemplates(
        showLoader: false,
        successMessage: 'Modèle supprimé.',
      );
    } catch (error) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void acknowledgeFeedback() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  Future<void> _loadTemplates({
    required bool showLoader,
    String? successMessage,
  }) async {
    if (showLoader) {
      emit(
        state.copyWith(
          loading: true,
          clearError: true,
          clearSuccess: true,
        ),
      );
    }
    try {
      final List<EventTemplate> templates =
          await _repository.fetchTemplates(profileId);
      emit(
        state.copyWith(
          templates: templates,
          loading: false,
          saving: false,
          errorMessage: null,
          successMessage: successMessage,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          saving: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  EventTemplate? _findTemplate(int? id) {
    if (id == null) {
      return null;
    }
    for (final EventTemplate template in state.templates) {
      if (template.id == id) {
        return template;
      }
    }
    return null;
  }

  int _generateTemporaryId() {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return -timestamp - Random().nextInt(1000);
  }
}

