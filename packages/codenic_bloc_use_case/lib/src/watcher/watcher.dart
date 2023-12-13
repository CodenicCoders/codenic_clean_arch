import 'dart:async';

import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:meta/meta.dart';

part 'verbose_stream.dart';
part 'watcher_state.dart';

/// {@template Watcher}
///
/// An abstract use case for running a stream asynchronously via a cubit which
/// accepts a [P] parameter for creating the stream.
///
/// The stream is created from the obtained [VerboseStream][L][R] when [watch]
/// is executed successfully. [L] is the error returned when stream creation
/// fails.
///
/// The created stream emits either an [L] error event or an [R] data event.
///
/// {@endtemplate}
abstract base class Watcher<P, L, R> extends DistinctCubit<WatcherState>
    with BaseUseCase<P, L, VerboseStream<L, R>> {
  /// {@macro Watcher}
  Watcher() : super(const WatcherInitial(DistinctCubit.initialActionToken));

  StreamSubscription<R>? _streamSubscription;

  /// The latest value emitted by calling [watch] which can either reference
  /// the [leftValue] or the [rightValue].
  ///
  /// This can be used to determine which is latest among the two values.
  ///
  /// If [watch] has not been called even once, then this is `null`.
  @override
  Either<L, VerboseStream<L, R>>? get value => super.value;

  /// {@template Watcher.leftValue}
  ///
  /// The error emitted by the [watch] call that prevented the creation of a
  /// stream.
  ///
  /// If [watch] call has not failed even once, then this is `null`.
  ///
  /// {@endtemplate}
  @override
  L? get leftValue => super.leftValue;

  /// {@template Watcher.rightValue}
  ///
  /// The [VerboseStream] returned by a successful [watch] call.
  ///
  /// If [watch] call has not succeeded even once, then this is `null`.
  ///
  /// {@endtemplate}
  @override
  VerboseStream<L, R>? get rightValue => super.rightValue;

  /// {@template Watcher.event}
  ///
  /// The latest value emitted by the [watch]-created stream which can either
  /// reference the [leftEvent] or the [rightEvent].
  ///
  /// This can be used to determine which is latest among the two values.
  ///
  /// If [watch]-created stream has not emitted an event even once, then this
  /// is `null`.
  ///
  /// {@endtemplate}
  Either<L, R>? _event;

  /// {@macro Watcher.event}
  Either<L, R>? get event => _event;

  @protected
  set event(Either<L, R>? newEvent) {
    _event = newEvent;
    newEvent?.fold((l) => _leftEvent = l, (r) => _rightEvent = r);
  }

  /// {@template Watcher.leftEvent}
  ///
  /// The last error event emitted by the [watch]-created stream.
  ///
  /// If any of the [watch]-created stream has not emitted an error event even
  /// once, then this is `null`.
  ///
  /// {@endtemplate}
  L? _leftEvent;

  /// {@macro Watcher.errorEvent}
  L? get leftEvent => _leftEvent;

  /// {@template Watcher.rightEvent}
  ///
  /// The last data event emitted by the [watch]-created stream.
  ///
  /// If any of the [watch]-created stream has not emitted a data event even
  /// once, then this is `null`.
  ///
  /// {@endtemplate}
  R? _rightEvent;

  /// {@macro Watcher.rightEvent}
  R? get rightEvent => _rightEvent;

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }

  /// Starts creating the stream to watch.
  ///
  /// This will initially emit a [StartWatching] state followed either by a
  /// [StartWatchFailed] or [StartWatchSuccess].
  ///
  /// Afterwards, the generated stream may emit a [WatchDataReceived] for data
  /// events, a [WatchErrorReceived] for error events, or a [WatchDone] when
  /// the stream has been closed.
  ///
  /// If successful, then this will return the [VerboseStream] of
  /// [StartWatchSuccess] which gives you access to the stream. Otherwise, this
  /// will return the [leftValue] of [StartWatchFailed].
  ///
  /// If the [Watcher] is closed or a new [watch] call has been made while
  /// the current instance is still in progress, then this will return `null`.
  Future<Either<L, VerboseStream<L, R>>?> watch({
    required P params,
    bool cancelOnError = false,
  }) async {
    final actionToken = requestNewActionToken();

    await (_streamSubscription?.cancel() ?? ensureAsync());

    if (isClosed) return null;

    if (distinctEmit(
          actionToken,
          () => StartWatching(actionToken),
        ) ==
        null) {
      return null;
    }

    final result = await onCall(params);

    if (isClosed) return null;

    distinctEmit(actionToken, () {
      setParamsAndValue(params, result);

      return result.fold(
        (l) => StartWatchFailed<L>(l, actionToken),
        (r) {
          _streamSubscription = r.listen(
            (data) {
              if (isClosed) return;

              distinctEmit(
                actionToken,
                () {
                  event = Right(data);

                  return WatchDataReceived<R>(data, actionToken);
                },
              );
            },
            onError: (error) {
              if (isClosed) return;

              distinctEmit(
                actionToken,
                () {
                  event = Left(error);

                  return WatchErrorReceived<L>(error, actionToken);
                },
              );
            },
            onDone: () {
              if (isClosed) return;

              distinctEmit(
                actionToken,
                () => WatchDone(actionToken),
              );
            },
            cancelOnError: cancelOnError,
          );

          return StartWatchSuccess(r, actionToken);
        },
      );
    });

    return result;
  }

  /// Clears all the data then emits a [WatcherInitial].
  @override
  Future<void> reset() async {
    final actionToken = requestNewActionToken();

    await (_streamSubscription?.cancel() ?? ensureAsync());

    if (isClosed) return;

    distinctEmit(
      actionToken,
      () {
        super.reset();
        _event = null;
        _leftEvent = null;
        _rightEvent = null;
        _streamSubscription = null;
        return WatcherInitial(actionToken);
      },
    );
  }
}
