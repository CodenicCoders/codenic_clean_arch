import 'dart:async';

import 'package:codenic_exception_converter/codenic_exception_converter.dart';

/// {@template ExceptionConverter}
/// An abstract class that converts an exception [E] to a [Failure] if exception
/// [E] occurs while running [observe] .
///
/// If no error occurs, then value [T] is returned.
///
/// While a single [ExceptionConverter] may not be very useful on its own, you
/// can use a group of exception converters together in an
/// [ExceptionConverterSuite] to run a task and automatically convert any
/// exceptions that are thrown into the appropriate [Failure] object.
/// {@endtemplate}
abstract base class ExceptionConverter<E extends Exception, T> {
  /// {@macro ExceptionConverter}
  const ExceptionConverter();

  /// Returns `true` if the [exception] is the same as [E]. Otherwise, `false`
  /// is returned.
  bool exceptionEquals(Exception exception) {
    return exception is E;
  }

  /// Executes and observes the given [task].
  ///
  /// {@template observe}
  /// If an [Exception] is thrown by the [task], then it will be converted
  /// into a [Failure]. Otherwise, [T] will be returned.
  ///
  /// The [logger] and [messageLog] is used to log and give more details
  /// about the exception.
  /// {@endtemplate}
  Future<Either<Failure, T>> observe({
    required FutureOr<Either<Failure, T>> Function(MessageLog? messageLog) task,
    CodenicLogger? logger,
    MessageLog? messageLog,
  }) async {
    assert(
      messageLog == null || logger != null,
      'If you want to log the exception, then you must provide a logger.',
    );

    try {
      return await task(messageLog);
    } on E catch (exception, stackTrace) {
      return Left(
        convert(
          logger: logger,
          messageLog: messageLog,
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Converts the [Exception] [E] to a [Failure].
  ///
  /// The [logger] and [messageLog] is used to log and give more details
  /// about the exception.
  Failure convert({
    required E exception,
    StackTrace? stackTrace,
    CodenicLogger? logger,
    MessageLog? messageLog,
  });
}
