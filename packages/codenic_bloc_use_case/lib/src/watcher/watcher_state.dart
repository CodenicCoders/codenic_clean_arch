part of 'watcher.dart';

/// {@template WatcherState}
///
/// The root class of all states emitted by [Watcher].
///
/// {@endtemplate}
sealed class WatcherState with EquatableMixin {
  /// {@macro WatcherState}
  const WatcherState(this.watchToken);

  /// Groups states executed from a single [Watcher.watch].
  ///
  /// This also prevents old [Watcher.watch] calls from emitting
  /// states when a newer [Watcher.watch] call is running in the process.
  ///
  /// Every time [Watcher.watch] is called, this gets incremented.
  final int watchToken;

  @override
  List<Object?> get props => [watchToken];
}

/// {@template WatcherInitial}
///
/// The initial state of the [Watcher] when [Watcher.watch] has
/// not been called yet or has been reset.
///
/// {@endtemplate}
final class WatcherInitial extends WatcherState {
  /// {@macro WatcherInitial}
  const WatcherInitial(super.watchToken);
}

/// {@template StartWatching}
///
/// The initial state emitted when [Watcher.watch] is called.
///
/// {@endtemplate}
final class StartWatching extends WatcherState {
  /// {@macro StartWatching}
  const StartWatching(super.watchToken);
}

/// {@template StartWatchFailed}
///
/// The state emitted when [Watcher.watch] call fails.
///
/// {@endtemplate}
final class StartWatchFailed<L> extends WatcherState {
  /// {@macro StartWatchFailed}
  const StartWatchFailed(this.leftValue, int watchToken) : super(watchToken);

  /// {@macro Watcher.leftValue}
  final L leftValue;

  @override
  List<Object?> get props => super.props..add(leftValue);
}

/// {@template StartWatchSuccess}
///
/// The state emitted when a [Watcher.watch] call succeeds.
///
/// {@endtemplate}
final class StartWatchSuccess<R extends VerboseStream<dynamic, dynamic>>
    extends WatcherState {
  /// {@macro StartWatchSuccess}
  const StartWatchSuccess(this.rightValue, int watchToken) : super(watchToken);

  /// {@macro Watcher.rightValue}
  final R rightValue;

  @override
  List<Object?> get props => super.props..add(rightValue);
}

/// {@template WatchErrorReceived}
///
/// The state emitted when the [Watcher.watch]-created stream emits an
/// error event.
///
/// {@endtemplate}
final class WatchErrorReceived<LE> extends WatcherState {
  /// {@macro WatchErrorReceived}
  const WatchErrorReceived(this.leftEvent, int watchToken) : super(watchToken);

  /// {@macro Watcher.leftEvent}
  final LE leftEvent;

  @override
  List<Object?> get props => super.props..add(leftEvent);
}

/// {@template WatchDataReceived}
///
/// The state emitted when the [Watcher.watch]-created stream emits a
/// data event.
///
/// {@endtemplate}
final class WatchDataReceived<RE> extends WatcherState {
  /// {@macro WatchDataReceived}
  const WatchDataReceived(this.rightEvent, int watchToken) : super(watchToken);

  /// {@macro Watcher.rightEvent}
  final RE rightEvent;

  @override
  List<Object?> get props => super.props..add(rightEvent);
}

/// {@template WatchDone}
///
/// The state emitted when the [Watcher.watch]-created stream closes.
///
/// {@endtemplate}
final class WatchDone extends WatcherState {
  /// {@macro WatchDone}
  const WatchDone(super.watchToken);
}
