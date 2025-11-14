import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/farm_member.dart';
import '../../../../data/models/subscription_plan.dart';
import '../../../../data/models/user_subscription.dart';
import '../../../../data/services/subscription_service.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.loading = false,
    this.plans = const <SubscriptionPlan>[],
    this.current,
    this.members = const <FarmMember>[],
    this.errorMessage,
    this.infoMessage,
    this.pendingAction = false,
    this.profileId,
    this.breedersUsed = 0,
    this.membersUsed = 0,
    this.storageUsedMb = 0,
    this.tutorialDismissed = false,
  });

  final bool loading;
  final List<SubscriptionPlan> plans;
  final UserSubscription? current;
  final List<FarmMember> members;
  final String? errorMessage;
  final String? infoMessage;
  final bool pendingAction;
  final String? profileId;
  final int breedersUsed;
  final int membersUsed;
  final int storageUsedMb;
  final bool tutorialDismissed;

  SubscriptionPlan? get activePlan => current?.plan;

  int? get maxBreeders => activePlan?.maxBreeders;

  int? get maxMembers => activePlan?.maxMembers;

  int? get storageLimitMb => activePlan?.storageLimitMb;

  bool get breedersLimitReached =>
      maxBreeders != null && breedersUsed >= maxBreeders!;

  bool get membersLimitReached =>
      maxMembers != null && membersUsed >= maxMembers!;

  bool get showQuotaBanner => breedersLimitReached ||
      membersLimitReached ||
      (current?.requiresAttention ?? false);

  bool get hasPendingPayment =>
      current?.status == SubscriptionStatus.pendingManualPayment;

  SubscriptionState copyWith({
    bool? loading,
    List<SubscriptionPlan>? plans,
    UserSubscription? current,
    bool clearCurrent = false,
    List<FarmMember>? members,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
    bool? pendingAction,
    String? profileId,
    bool clearProfile = false,
    int? breedersUsed,
    int? membersUsed,
    int? storageUsedMb,
    bool? tutorialDismissed,
  }) {
    return SubscriptionState(
      loading: loading ?? this.loading,
      plans: plans ?? this.plans,
      current: clearCurrent ? null : (current ?? this.current),
      members: members ?? this.members,
      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo
          ? null
          : (infoMessage ?? this.infoMessage),
      pendingAction: pendingAction ?? this.pendingAction,
      profileId: clearProfile ? null : (profileId ?? this.profileId),
      breedersUsed: breedersUsed ?? this.breedersUsed,
      membersUsed: membersUsed ?? this.membersUsed,
      storageUsedMb: storageUsedMb ?? this.storageUsedMb,
      tutorialDismissed: tutorialDismissed ?? this.tutorialDismissed,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        loading,
        plans,
        current,
        members,
        errorMessage,
        infoMessage,
        pendingAction,
        profileId,
        breedersUsed,
        membersUsed,
        storageUsedMb,
        tutorialDismissed,
      ];
}

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({
    required SubscriptionService service,
    required AuthCubit authCubit,
  })  : _service = service,
        _authCubit = authCubit,
        super(const SubscriptionState());

  final SubscriptionService _service;
  final AuthCubit _authCubit;
  StreamSubscription<AuthState>? _authSubscription;
  String? _profileId;
  bool _initialized = false;

  void initialize() {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _authSubscription = _authCubit.stream.listen(_handleAuthState);
    _handleAuthState(_authCubit.state);
  }

  Future<void> refresh() async {
    final String? profileId = _profileId;
    if (profileId == null) {
      return;
    }
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
      ),
    );
    try {
      final List<SubscriptionPlan> plans =
          List<SubscriptionPlan>.from(await _service.fetchPlans());
      plans.sort((SubscriptionPlan a, SubscriptionPlan b) =>
          a.sortOrder.compareTo(b.sortOrder));
      UserSubscription? current = await _service.fetchCurrent(profileId);
      if (current == null && plans.isNotEmpty) {
        final SubscriptionPlan defaultPlan = plans.firstWhere(
          (SubscriptionPlan plan) => plan.code == 'free',
          orElse: () => plans.first,
        );
        current = await _service.bootstrapFreePlan(
          profileId,
          defaultPlan,
        );
      }
      final List<FarmMember> members =
          await _service.fetchMembers(profileId);
      emit(
        state.copyWith(
          loading: false,
          plans: plans,
          current: current,
          members: members,
          membersUsed: _countActiveMembers(members),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> requestPlanChange(SubscriptionPlan plan) async {
    final String? profileId = _profileId;
    if (profileId == null) {
      return;
    }
    emit(
      state.copyWith(
        pendingAction: true,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      final UserSubscription updated = await _service.requestManualPlanChange(
        profileId: profileId,
        plan: plan,
        usageSnapshot: <String, dynamic>{
          'breeders_used': state.breedersUsed,
          'members_used': state.membersUsed,
          'storage_mb': state.storageUsedMb,
        },
      );
      emit(
        state.copyWith(
          pendingAction: false,
          current: updated,
          infoMessage: 'Référence ${updated.manualPaymentReference ?? ''} générée. Consultez vos instructions de paiement.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          pendingAction: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> addMember({
    required String email,
    String? displayName,
    String role = 'viewer',
  }) async {
    final String? profileId = _profileId;
    if (profileId == null) {
      return;
    }
    emit(
      state.copyWith(
        pendingAction: true,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      final FarmMember member = await _service.addMember(
        profileId: profileId,
        email: email,
        displayName: displayName,
        role: role,
      );
      final List<FarmMember> members = List<FarmMember>.from(state.members)
        ..add(member);
      final int count = _countActiveMembers(members);
      emit(
        state.copyWith(
          pendingAction: false,
          members: members,
          membersUsed: count,
          infoMessage: 'Invitation envoyée à $email.',
        ),
      );
      await _syncUsage(
        membersUsed: count,
      );
    } catch (error) {
      emit(
        state.copyWith(
          pendingAction: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> removeMember(String memberId) async {
    emit(
      state.copyWith(
        pendingAction: true,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      await _service.removeMember(memberId);
      final List<FarmMember> members = state.members
          .map(
            (FarmMember member) => member.id == memberId
                ? member.copyWith(
                    status: 'removed',
                    endAt: DateTime.now(),
                  )
                : member,
          )
          .toList();
      final int count = _countActiveMembers(members);
      emit(
        state.copyWith(
          pendingAction: false,
          members: members,
          membersUsed: count,
          infoMessage: 'Membre retiré.',
        ),
      );
      await _syncUsage(membersUsed: count);
    } catch (error) {
      emit(
        state.copyWith(
          pendingAction: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void reportUsage({
    int? breeders,
    int? members,
    int? storageMb,
  }) {
    if (breeders == null && members == null && storageMb == null) {
      return;
    }
    emit(
      state.copyWith(
        breedersUsed: breeders ?? state.breedersUsed,
        membersUsed: members ?? state.membersUsed,
        storageUsedMb: storageMb ?? state.storageUsedMb,
      ),
    );
    unawaited(
      _syncUsage(
        breedersUsed: breeders,
        membersUsed: members,
        storageUsedMb: storageMb,
      ),
    );
  }

  void dismissTutorial() {
    if (!state.tutorialDismissed) {
      emit(state.copyWith(tutorialDismissed: true));
    }
  }

  void acknowledgeError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  void acknowledgeInfo() {
    if (state.infoMessage != null) {
      emit(state.copyWith(clearInfo: true));
    }
  }

  void _handleAuthState(AuthState authState) {
    final String? profileId =
        authState.profile?.id ?? authState.session?.user.id;
    if (profileId == null) {
      _profileId = null;
      emit(
        state.copyWith(
          clearCurrent: true,
          clearProfile: true,
          members: const <FarmMember>[],
          breedersUsed: 0,
          membersUsed: 0,
          storageUsedMb: 0,
        ),
      );
      return;
    }
    if (profileId == _profileId) {
      return;
    }
    _profileId = profileId;
    emit(state.copyWith(profileId: profileId));
    unawaited(refresh());
  }

  Future<void> _syncUsage({
    int? breedersUsed,
    int? membersUsed,
    int? storageUsedMb,
  }) async {
    final String? profileId = _profileId;
    if (profileId == null) {
      return;
    }
    if (state.current == null) {
      return;
    }
    if (breedersUsed == null &&
        membersUsed == null &&
        storageUsedMb == null) {
      return;
    }
    try {
      final UserSubscription updated = await _service.updateUsage(
        profileId: profileId,
        breedersUsed: breedersUsed ?? state.breedersUsed,
        membersUsed: membersUsed ?? state.membersUsed,
        storageUsedMb: storageUsedMb ?? state.storageUsedMb,
      );
      emit(state.copyWith(current: updated));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  static int _countActiveMembers(List<FarmMember> members) {
    return members
        .where((FarmMember member) => member.status != 'removed')
        .length;
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
