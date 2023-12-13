part of 'watcher.dart';

/// {@template VerboseStream}
///
/// A stream wrapper that enforces a [stream] to explicitly return either
/// a [RE] right event on data events, or a [LE] left event on error events as
/// a replacement for the [Object] error.
///
/// For more info about data and error events, see [Stream].
/// {@endtemplate}
class VerboseStream<LE, RE> {
  /// {@macro VerboseStream}
  const VerboseStream({required this.stream, required this.errorConverter});

  /// The stream source of events.
  final Stream<RE> stream;

  /// Converts the [Object] error from [Stream.listen]'s `onError` to an
  /// [LE] value.
  final LE Function(Object error, StackTrace? stackTrace) errorConverter;

  /// Create a [stream] listener.
  ///
  /// Similar to [Stream.listen] with the added feature of converting the
  /// [onError] callback to have a type of `void Function(Left error)`.
  ///
  /// Note that [cancelOnError] will only cancel the [StreamSubscription] when
  /// an error occurs. This will not close the stream itself, hence, [onDone]
  /// will not be called.
  ///
  /// For more info, see [Stream.listen].
  StreamSubscription<RE> listen(
    void Function(RE) onData, {
    void Function(LE)? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      stream.listen(
        onData,
        onError: onError != null
            ? (Object error, StackTrace? stackTrace) {
                final left = errorConverter(error, stackTrace);
                onError.call(left);
              }
            : null,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}
