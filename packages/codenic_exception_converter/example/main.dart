// ignore_for_file: avoid_print

import 'dart:io';

import 'package:codenic_exception_converter/codenic_exception_converter.dart';

Future<void> main() async {
  // To run, type `dart --enable-asserts example/main.dart`.

  await _observeWithDefaultConverters();
  print('');
  await _observeWithArgConverters();
  print('');
  await _observeNoExceptionConverters();
  print('');
  _convert();
}

Future<void> _observeWithDefaultConverters() async {
  // Create an exception converter suite that can convert a `SocketException`
  // into a `NetworkFailure`
  final exceptionConverterSuite = ExceptionConverterSuite(
    defaultErrorConverters: [SocketExceptionConverter.new],
  );

  final result = await exceptionConverterSuite.observe<void>(
    messageLog: MessageLog(id: 'observe-with-default-converters'),
    printOutput: true,
    task: (messageLog) {
      // Simulate exception
      throw const SocketException('test');
    },
  );

  print('Observe (with default converters): $result');
}

Future<void> _observeWithArgConverters() async {
  final exceptionConverterSuite = ExceptionConverterSuite();

  final result = await exceptionConverterSuite.observe<void>(
    messageLog: MessageLog(id: 'observe-with-argument-converters'),
    // Provide an exception converter as an argument
    errorConverters: [const SocketExceptionConverter()],
    printOutput: true,
    task: (messageLog) {
      // Simulate exception
      throw const SocketException('test');
    },
  );

  print('Observe (with argument exception converters): $result');
}

Future<void> _observeNoExceptionConverters() async {
  final exceptionConverterSuite = ExceptionConverterSuite();

  final result = await exceptionConverterSuite.observe<void>(
    messageLog: MessageLog(id: 'observe-with-no-exception-converters'),
    task: (messageLog) {
      try {
        // Simulate exception
        throw const SocketException('test');
      } on SocketException {
        return const Left(NetworkFailure());
      }
    },
  );

  print('Observe (no exception converter): $result');
}

void _convert() {
  final exceptionConverterSuite = ExceptionConverterSuite(
    defaultErrorConverters: [SocketExceptionConverter.new],
  );

  final result = exceptionConverterSuite.convert(
    error: const SocketException('test'),
    errorConverters: [const SocketExceptionConverter()],
  );

  print('Convert result: $result');
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'A network failure occurred'});
}

/// A custom exception converter for converting a [SocketException] to a
/// [NetworkFailure] if an error occurs.
///
/// If no exception is caught, then [T] is returned.
final class SocketExceptionConverter<T>
    extends ExceptionConverter<SocketException, T> {
  const SocketExceptionConverter();

  @override
  Failure convert(SocketException exception) => const NetworkFailure();

  @override
  void logError(
    SocketException exception,
    StackTrace stackTrace,
    CodenicLogger logger,
    MessageLog messageLog,
  ) =>
      logger.error(messageLog, error: exception, stackTrace: stackTrace);
}
