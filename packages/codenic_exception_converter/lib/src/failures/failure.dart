import 'package:equatable/equatable.dart';

/// {@template Failure}
/// A base class for all failures.
/// {@endtemplate}
class Failure with EquatableMixin {
  /// {@macro Failure}
  const Failure({this.message = "Something went error. We're working on it"});

  /// A user-facing message designed to give details about an error to the user.
  final String message;

  // coverage:ignore-start
  @override
  List<Object> get props => [message];
  // coverage:ignore-end
}
