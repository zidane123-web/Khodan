import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/support_request.dart';
import '../../../../data/repositories/support_repository.dart';
import '../../../../data/services/offline_sync_manager.dart';

class SupportState extends Equatable {
  const SupportState({
    this.submitting = false,
    this.errorMessage,
    this.successMessage,
    this.recentRequests = const <SupportRequest>[],
  });

  final bool submitting;
  final String? errorMessage;
  final String? successMessage;
  final List<SupportRequest> recentRequests;

  SupportState copyWith({
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    List<SupportRequest>? recentRequests,
  }) {
    return SupportState(
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
      recentRequests: recentRequests ?? this.recentRequests,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[submitting, errorMessage, successMessage, recentRequests];
}

class SupportCubit extends Cubit<SupportState> {
  SupportCubit({
    required SupportRepository repository,
    required String profileId,
    required String contactEmail,
    OfflineSyncManager? offlineManager,
  })  : _repository = repository,
        _profileId = profileId,
        _contactEmail = contactEmail,
        _offlineManager = offlineManager ?? OfflineSyncManager.instance,
        super(const SupportState());

  final SupportRepository _repository;
  final String _profileId;
  final String _contactEmail;
  final OfflineSyncManager _offlineManager;

  Future<void> submit({
    required String subject,
    required String message,
    String priority = 'normal',
  }) async {
    emit(
      state.copyWith(
        submitting: true,
        clearError: true,
        clearSuccess: true,
      ),
    );
    final SupportRequest request = SupportRequest(
      profileId: _profileId,
      subject: subject,
      message: message,
      contactEmail: _contactEmail,
      priority: priority,
      createdAt: DateTime.now(),
    );
    try {
      await _repository.submit(request);
      final List<SupportRequest> updated = <SupportRequest>[
        request,
        ...state.recentRequests,
      ];
      emit(
        state.copyWith(
          submitting: false,
          successMessage: _offlineManager.isOffline.value
              ? 'Message enregistré hors connexion. Il sera envoyé automatiquement.'
              : 'Message envoyé au support. Nous vous répondrons rapidement.',
          recentRequests: updated.take(10).toList(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void acknowledgeError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  void acknowledgeSuccess() {
    if (state.successMessage != null) {
      emit(state.copyWith(clearSuccess: true));
    }
  }
}
