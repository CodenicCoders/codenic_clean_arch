import 'package:codenic_exception_converter/src/exception_converters/exception_converter.dart';
import 'package:codenic_exception_converter/src/failures/failure.dart';
import 'package:codenic_logger/codenic_logger.dart';

/// {@template FallbackExceptionConverter}
/// Converts the base exception [Exception] to failure [Failure].
///
/// If no error occurs, then value [T] is returned.
/// {@endtemplate}
class FallbackExceptionConverter<T>
    extends ExceptionConverter<Exception, Failure, T> {
  /// {@macro FallbackExceptionConverter}
  const FallbackExceptionConverter();

  @override
  Failure convert({
    required Exception exception,
    StackTrace? stackTrace,
    CodenicLogger? logger,
    MessageLog? messageLog,
  }) {
    if (logger != null && messageLog != null) {
      logger.error(
        messageLog..message = 'Unknown failure occurred',
        error: exception,
        stackTrace: stackTrace,
      );
    }

    return const Failure();
  }
}
