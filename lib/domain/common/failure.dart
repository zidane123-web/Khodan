import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => <Object?>[message, cause];
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.cause});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.cause});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.cause});
}
