import 'dart:async';

import 'package:codenic_exception_converter/codenic_exception_converter.dart';

/// {@template ErrorConverter}
/// A base class for converting an error [E] to a [Failure].
///
/// If no error occurs, then value [T] is returned.
///
/// While a single [ErrorConverter] may not be very useful on its own, you
/// can use a group of error converters together in an [ExceptionConverterSuite]
/// to run a task and automatically convert any errors that are thrown into
/// the appropriate [Failure] object.
/// {@endtemplate}
abstract base class ErrorConverter<E extends Object, T> {
  /// {@macro ErrorConverter}
  const ErrorConverter();

  /// Returns `true` if the [error] is the same as [E]. Otherwise, `false`
  /// is returned.
  bool errorEquals(Object error) => error is E;

  /// Executes the given [task] and converts any thrown error [E] to a
  /// [Failure].
  Future<Either<Failure, T>> observe({
    required FutureOr<Either<Failure, T>> Function(MessageLog? messageLog) task,
    CodenicLogger? logger,
    MessageLog? messageLog,
    bool printOutput = false,
  }) async {
    assert(
      messageLog == null || logger != null,
      'If you want to log the exception, then you must provide a logger.',
    );

    try {
      return await task(messageLog);
    } on E catch (error, stackTrace) {
      final result = Left<Failure, T>(convert(error));

      if (logger != null && messageLog != null) {
        if (printOutput) messageLog.data['__output__'] = result;
        logError(error, stackTrace, logger, messageLog);
      }

      return result;
    }
  }

  /// Converts the error [E] to a [Failure].
  Failure convert(E error);

  /// Logs the [error] and [stackTrace] using the given [logger] and
  /// [messageLog].
  ///
  /// This is only used at [ExceptionConverterSuite.observe] when an exception
  /// occurs.
  void logError(
    E error,
    StackTrace stackTrace,
    CodenicLogger logger,
    MessageLog messageLog,
  );
}
