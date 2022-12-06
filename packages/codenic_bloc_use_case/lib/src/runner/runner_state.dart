part of 'runner.dart';

/// {@template RunnerState}
///
/// The root class of all states emitted by [Runner].
///
/// {@endtemplate}
abstract class RunnerState with EquatableMixin {
  /// {@macro RunnerState}
  const RunnerState(this.runToken);

  /// Groups states executed from a single [Runner.run].
  ///
  /// This also prevents old [Runner.run] calls from emitting states
  /// when a newer [Runner.run] call is running in the process.
  ///
  /// Every time [Runner.run] is called, this gets incremented.
  final int runToken;

  @override
  List<Object?> get props => [runToken];
}

/// {@template RunnerInitial}
///
/// The initial state of the [Runner] when [Runner.run] has not
/// been called yet or has been reset.
///
/// {@endtemplate}
class RunnerInitial extends RunnerState {
  /// {@macro RunnerInitial}
  const RunnerInitial(super.runToken);
}

/// {@template Running}
///
/// The initial state emitted when [Runner.run] is called.
///
/// {@endtemplate}
class Running extends RunnerState {
  /// {@macro Running}
  const Running(super.runToken);
}

/// {@template RunFailed}
///
/// The state emitted when [Runner.run] call fails.
///
/// {@endtemplate}
class RunFailed<L> extends RunnerState {
  /// {@macro RunFailed}
  const RunFailed(this.leftValue, int runToken) : super(runToken);

  /// {@macro Runner.leftValue}
  final L leftValue;

  @override
  List<Object?> get props => super.props..add(leftValue);
}

/// {@template RunSuccess}
///
/// The state emitted when a [Runner.run] call succeeds.
///
/// {@endtemplate}
class RunSuccess<R> extends RunnerState {
  /// {@macro RunSuccess}
  const RunSuccess(this.rightValue, int runToken) : super(runToken);

  /// {@macro Runner.rightValue}
  final R rightValue;

  @override
  List<Object?> get props => super.props..add(rightValue);
}
