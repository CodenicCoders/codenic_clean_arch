import 'package:equatable/equatable.dart';

/// {@template Failure}
/// A base class for all failures.
/// {@endtemplate}
class Failure with EquatableMixin {
  /// {@macro Failure}
  const Failure({
    this.code = 'failure',
    this.message = "Something went wrong. We're working on it",
  });

  /// A unique code for the failure.
  final String code;

  /// A user-facing message designed to give details about an error to the user.
  final String message;

  // coverage:ignore-start
  @override
  List<Object> get props => [code, message];
  // coverage:ignore-end
}
