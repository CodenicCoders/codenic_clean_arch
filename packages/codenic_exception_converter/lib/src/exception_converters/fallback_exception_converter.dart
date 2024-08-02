import 'package:codenic_exception_converter/src/exception_converters/exception_converter.dart';
import 'package:codenic_exception_converter/src/failures/failure.dart';
import 'package:codenic_logger/codenic_logger.dart';

/// {@template FallbackExceptionConverter}
/// Converts the base exception [Exception] to failure [Failure].
///
/// If no error occurs, then value [T] is returned.
/// {@endtemplate}
final class FallbackExceptionConverter<T>
    extends ExceptionConverter<Exception, T> {
  /// {@macro FallbackExceptionConverter}
  const FallbackExceptionConverter();

  @override
  Failure convert(Exception exception) => const Failure();

  @override
  void logException(
    Exception exception,
    StackTrace stackTrace,
    CodenicLogger logger,
    MessageLog messageLog,
  ) {
    logger.error(
      messageLog..message = 'Unknown failure occurred',
      error: exception,
      stackTrace: stackTrace,
    );
  }
}
