import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/breeding_record.dart';
import '../../../../data/models/task_template.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/task_template_repository.dart';
import '../../../planning/services/task_template_service.dart';

class TaskTemplatesState extends Equatable {
  const TaskTemplatesState({
    this.templates = const <TaskTemplate>[],
    this.breedingRecords = const <BreedingRecord>[],
    this.loading = false,
    this.saving = false,
    this.applying = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<TaskTemplate> templates;
  final List<BreedingRecord> breedingRecords;
  final bool loading;
  final bool saving;
  final bool applying;
  final String? errorMessage;
  final String? successMessage;

  TaskTemplatesState copyWith({
    List<TaskTemplate>? templates,
    List<BreedingRecord>? breedingRecords,
    bool? loading,
    bool? saving,
    bool? applying,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return TaskTemplatesState(
      templates: templates ?? this.templates,
      breedingRecords: breedingRecords ?? this.breedingRecords,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      applying: applying ?? this.applying,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    templates,
    breedingRecords,
    loading,
    saving,
    applying,
    errorMessage,
    successMessage,
  ];
}

class TaskTemplatesCubit extends Cubit<TaskTemplatesState> {
  TaskTemplatesCubit({
    required this.templateRepository,
    required this.breedingRepository,
    required this.service,
    required this.profileId,
  }) : super(const TaskTemplatesState());

  final TaskTemplateRepository templateRepository;
  final BreedingRepository breedingRepository;
  final TaskTemplateService service;
  final String profileId;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearMessages: true));
    try {
      final List<TaskTemplate> templates = await templateRepository
          .fetchTemplates(profileId);
      final List<BreedingRecord> breedingRecords = await breedingRepository
          .fetchBreedingRecords();
      emit(
        state.copyWith(
          templates: templates,
          breedingRecords: breedingRecords,
          loading: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(loading: false, errorMessage: error.toString()));
    }
  }

  Future<void> saveTemplate(TaskTemplate template) async {
    emit(state.copyWith(saving: true, clearMessages: true));
    try {
      final bool exists = state.templates.any(
        (TaskTemplate existing) => existing.id == template.id,
      );
      if (exists) {
        await templateRepository.updateTemplate(template);
      } else {
        await templateRepository.createTemplate(template);
      }
      final List<TaskTemplate> templates = await templateRepository
          .fetchTemplates(profileId);
      emit(
        state.copyWith(
          templates: templates,
          saving: false,
          successMessage: exists
              ? 'Modele mis a jour.'
              : 'Modele cree avec succes.',
        ),
      );
    } catch (error) {
      emit(state.copyWith(saving: false, errorMessage: error.toString()));
    }
  }

  Future<void> deleteTemplate(String id) async {
    emit(state.copyWith(saving: true, clearMessages: true));
    try {
      await templateRepository.deleteTemplate(id);
      final List<TaskTemplate> templates = await templateRepository
          .fetchTemplates(profileId);
      emit(
        state.copyWith(
          templates: templates,
          saving: false,
          successMessage: 'Modele supprime.',
        ),
      );
    } catch (error) {
      emit(state.copyWith(saving: false, errorMessage: error.toString()));
    }
  }

  Future<void> applyTemplate({
    required TaskTemplate template,
    required TaskTemplateAssignment assignment,
    required List<String> animalIds,
    Map<String, DateTime> anchorDates = const <String, DateTime>{},
    Map<String, dynamic> metadata = const <String, dynamic>{},
    String? emailTarget,
    String? phoneTarget,
  }) async {
    emit(state.copyWith(applying: true, clearMessages: true));
    try {
      await service.applyTemplate(
        template: template,
        assignment: assignment,
        animalIds: animalIds,
        anchorDates: anchorDates,
        metadata: metadata,
        emailTarget: emailTarget,
        phoneTarget: phoneTarget,
      );
      final List<TaskTemplate> templates = await templateRepository
          .fetchTemplates(profileId);
      emit(
        state.copyWith(
          templates: templates,
          applying: false,
          successMessage: 'Modele applique a la portee ou au traitement.',
        ),
      );
    } catch (error) {
      emit(state.copyWith(applying: false, errorMessage: error.toString()));
    }
  }

  void acknowledgeFeedback() {
    emit(state.copyWith(clearMessages: true));
  }
}
