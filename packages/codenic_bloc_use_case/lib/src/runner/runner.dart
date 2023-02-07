import 'dart:async';

import 'package:codenic_bloc_use_case/src/base.dart';
import 'package:codenic_bloc_use_case/src/util/ensure_async.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

part 'runner_state.dart';

/// {@template Runner}
///
/// An abstract use case for executing tasks asynchronously via a cubit which
/// accepts a [P] parameter and emits either an [L] failed value or an [R]
/// success value.
///
/// {@endtemplate}
abstract class Runner<P, L, R> extends DistinctCubit<RunnerState>
    with BaseUseCase<P, L, R> {
  /// {@macro Runner}
  Runner() : super(const RunnerInitial(DistinctCubit.initialActionToken));

  /// The latest value emitted by calling [run] which can either reference the
  /// [leftValue] or the [rightValue].
  ///
  /// This can be used to determine which is latest among the two values.
  ///
  /// If [run] has not been called even once, then this is `null`.
  @override
  Either<L, R>? get value => super.value;

  /// {@template Runner.leftValue}
  ///
  /// The last error value emitted by calling [run].
  ///
  /// If [run] has not failed even once, then this is `null`.
  ///
  /// {@endtemplate}
  @override
  L? get leftValue => super.leftValue;

  /// {@template Runner.rightValue}
  ///
  /// The last success value emitted by calling [run].
  ///
  /// If [run] has not succeeded even once, then this is `null`.
  ///
  /// {@endtemplate}
  @override
  R? get rightValue => super.rightValue;

  /// Executes the [onCall] use case action.
  ///
  /// This will initially emit a [Running] state followed either by a
  /// [RunFailed] or [RunSuccess].
  ///
  /// If successful, then this will return the [rightValue] of the [RunSuccess].
  /// Otherwise, this will return the [leftValue] of the [RunFailed].
  ///
  /// If the [Runner] is closed or a new [run] call has been made while
  /// the current instance is still in progress, then this will return `null`.
  Future<Either<L, R>?> run({required P params}) async {
    final actionToken = requestNewActionToken();

    await ensureAsync();

    if (isClosed) return null;

    if (distinctEmit(
          actionToken,
          () => Running(actionToken),
        ) ==
        null) {
      return null;
    }

    final result = await onCall(params);

    if (isClosed) return null;

    distinctEmit(
      actionToken,
      () {
        setParamsAndValue(params, result);

        return result.fold(
          (l) => RunFailed(l, actionToken),
          (r) => RunSuccess(r, actionToken),
        );
      },
    );

    return result;
  }

  /// Clears all the data then emits a [RunnerInitial].
  @override
  Future<void> reset() async {
    final actionToken = requestNewActionToken();

    await ensureAsync();

    if (isClosed) return;

    distinctEmit(
      actionToken,
      () {
        super.reset();
        return RunnerInitial(actionToken);
      },
    );
  }
}
