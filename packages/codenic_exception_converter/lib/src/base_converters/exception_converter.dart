import 'package:codenic_exception_converter/codenic_exception_converter.dart';

/// {@template ExceptionConverter}
/// A base class for converting an [Exception] [E] to a [Failure].
///
/// If no error occurs, then value [T] is returned.
///
/// While a single [ExceptionConverter] may not be very useful on its own, you
/// can use a group of exception converters together in an
/// [ExceptionConverterSuite] to run a task and automatically convert any
/// errors that are thrown into the appropriate [Failure] object.
/// {@endtemplate}
abstract base class ExceptionConverter<E extends Exception, T>
    extends ErrorConverter<E, T> {
  /// {@macro ExceptionConverter}
  const ExceptionConverter();
}
