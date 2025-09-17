import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool resetError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, errorMessage];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, resetError: true));
    try {
      await _repository.signInWithEmail(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.success));
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> signUp(String email, String password, {String? farmName}) async {
    emit(state.copyWith(status: AuthStatus.loading, resetError: true));
    try {
      await _repository.signUpWithEmail(
        email: email,
        password: password,
        farmName: farmName,
      );
      emit(state.copyWith(status: AuthStatus.success));
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> signOut() => _repository.signOut();
}
