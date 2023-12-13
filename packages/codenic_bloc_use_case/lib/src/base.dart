import 'dart:async';

import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:meta/meta.dart';

/// An abstract class for the core functionalities of a use case.
///
/// A use case represents a specific action within a system.
abstract base mixin class BaseUseCase<P, L, R> {
  /// {@template BaseUseCase.value}
  ///
  /// The last [L] or [R] value produced by the use case which can either
  /// reference the [leftValue] or the [rightValue].
  ///
  /// This can be used to determine which is latest among the two values.
  ///
  /// {@endtemplate}
  Either<L, R>? _value;

  /// {@macro BaseUseCase.value}
  Either<L, R>? get value => _value;

  /// {@template BaseUseCase.leftValue}
  ///
  /// The last error value by the use case.
  ///
  /// {@endtemplate}
  L? _leftValue;

  /// {@macro BaseUseCase.leftValue}
  L? get leftValue => _leftValue;

  /// {@template BaseUseCase.rightValue}
  ///
  /// The last success value by the use case.
  ///
  /// {@endtemplate}
  R? _rightValue;

  /// {@macro BaseUseCase.rightValue}
  R? get rightValue => _rightValue;

  /// {@template BaseUseCase.params}
  ///
  /// The last params used to execute the use case.
  ///
  /// This can either reference the [leftParams] or the [rightParams] depending
  /// whether the use case has failed or suceeded, respectively.
  ///
  /// {@endtemplate}
  Either<P, P>? _params;

  /// {@macro BaseUseCase.params}
  Either<P, P>? get params => _params;

  /// {@template BaseUseCase.leftParams}
  ///
  /// The last params used to execute the use case when it failed.
  ///
  /// {@endtemplate}
  P? _leftParams;

  /// {@macro BaseUseCase.leftParams}
  P? get leftParams => _leftParams;

  /// {@template BaseUseCase.rightParams}
  ///
  /// The last params used to execute the use case when it succeeded.
  ///
  /// {@endtemplate}
  P? _rightParams;

  /// {@macro BaseUseCase.rightParams}
  P? get rightParams => _rightParams;

  /// The use case action callback.
  @protected
  FutureOr<Either<L, R>> onCall(P params);

  /// Sets the [params] and [value] of the use case.
  @protected
  void setParamsAndValue(P params, Either<L, R> value) {
    _value = value;

    value.fold(
      (l) {
        _leftValue = l;
        _params = Left(params);
        _leftParams = params;
      },
      (r) {
        _rightValue = r;
        _params = Right(params);
        _rightParams = params;
      },
    );
  }

  /// Clears all the data.
  void reset() {
    _leftValue = null;
    _rightValue = null;
    _value = null;

    _leftParams = null;
    _rightParams = null;
    _params = null;
  }
}

/// {@template DistinctCubit}
///
/// A [Cubit] that enables [state] emission from one method call at a time.
///
/// If multiple state-emitting method calls are running at the same time, then
/// this can prevent old method calls from emitting states in favor of the
/// new method call states.
///
/// {@endtemplate}
abstract base class DistinctCubit<S> extends Cubit<S> {
  /// {@macro DistinctCubit}
  DistinctCubit(super.initialState);

  /// The initial action token.
  ///
  /// {@template DistinctCubit.actionToken}
  ///
  /// An action token identifies a method call that can emit states. The
  /// generated token is used in conjunction with [distinctEmit] to ensure that
  /// a method call can only emit states as long as their action token is not
  /// stale.
  ///
  /// {@endtemplate}
  static const initialActionToken = 0;

  /// The active action token.
  ///
  /// {@macro DistinctCubit.actionToken}
  int _activeActionToken = initialActionToken;

  /// Generates a new action token.
  ///
  /// This must be called within a method that can emit states to generate
  /// their unique action token.
  ///
  /// {@macro DistinctCubit.actionToken}
  @protected
  int requestNewActionToken() => ++_activeActionToken;

  /// Updates the Cubit's state based on the [stateCallback].
  ///
  /// If the [actionToken] is not equal to the active action token, then
  /// [stateCallback] will not be called and `null` will be returned.
  /// Otherwise, if `true`, then the state from [stateCallback] will be emitted
  /// and returned.
  ///
  /// This does nothing if:
  /// - the [actionToken] is stale.
  /// - the state being emitted is equal to the current state.
  ///
  /// To allow for the possibility of notifying listeners of the initial state,
  /// emitting a state which is equal to the initial state is allowed as long
  /// as it is the first thing emitted by the instance.
  ///
  /// * Throws a [StateError] if the bloc is closed.
  @protected
  S? distinctEmit(int actionToken, S Function() stateCallback) {
    if (actionToken != _activeActionToken) {
      return null;
    }

    final state = stateCallback();

    emit(state);

    return state;
  }

  /// Do not use directly. Instead, use [distinctEmit].
  @override
  void emit(S state) => super.emit(state);
}
