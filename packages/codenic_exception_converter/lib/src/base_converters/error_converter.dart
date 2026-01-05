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
  ///
  /// The [tag] identifies the service that threw the error.
  Future<Either<Failure, T>> observe({
    required String tag,
    required TaskCallback<T> task,
  }) async {
    try {
      return await task(tag);
    } on E catch (error, stackTrace) {
      final result = Left<Failure, T>(convert(error));

      logError(tag, error, stackTrace);

      return result;
    }
  }

  /// Converts the error [E] to a [Failure].
  Failure convert(E error);

  /// A function for logger errors that are thrown by the [observe] method.
  ///
  /// The [tag] identifies the service that threw the error.
  /// The [error] is the error that was thrown.
  /// The [stackTrace] is the stack trace of the error.
  void logError(String tag, E error, StackTrace stackTrace);
}
