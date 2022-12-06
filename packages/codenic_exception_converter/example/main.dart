// ignore_for_file: avoid_print

import 'dart:io';

import 'package:codenic_exception_converter/codenic_exception_converter.dart';

Future<void> main() async {
  // To run, type `dart --enable-asserts example/main.dart`.

  _observeWithDefaultConverters();
  print('');
  _observeWithArgConverters();
  print('');
  _observeNoExceptionConverters();
  print('');
  _convert();
}

void _observeWithDefaultConverters() {
  // Create an exception converter suite that can convert a `SocketException`
  // into a `NetworkFailure`
  final exceptionConverterSuite = ExceptionConverterSuite(
    exceptionConverters: [SocketExceptionConverter.new],
  );

  final result = exceptionConverterSuite.observeSync<void>(
    messageLog: MessageLog(id: 'observe-with-default-converters'),
    task: (messageLog) {
      // Simulate exception
      throw const SocketException('test');
    },
  );

  print('Observe (with default converters): $result');
}

void _observeWithArgConverters() {
  final exceptionConverterSuite = ExceptionConverterSuite();

  final result = exceptionConverterSuite.observeSync<void>(
    messageLog: MessageLog(id: 'observe-with-argument-converters'),
    // Provide an exception converter as an argument
    exceptionConverters: [const SocketExceptionConverter()],
    task: (messageLog) {
      // Simulate exception
      throw const SocketException('test');
    },
  );

  print('Observe (with argument exception converters): $result');
}

void _observeNoExceptionConverters() {
  final exceptionConverterSuite = ExceptionConverterSuite();

  final result = exceptionConverterSuite.observeSync<void>(
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
    exceptionConverters: [SocketExceptionConverter.new],
  );

  final result = exceptionConverterSuite.convert(
    error: const SocketException('test'),
    exceptionConverters: [const SocketExceptionConverter()],
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
class SocketExceptionConverter<T>
    extends ExceptionConverter<SocketException, NetworkFailure, T> {
  const SocketExceptionConverter();

  @override
  NetworkFailure convert({
    required SocketException exception,
    StackTrace? stackTrace,
    CodenicLogger? logger,
    MessageLog? messageLog,
  }) {
    if (logger != null && messageLog != null) {
      // Optional: you can log the exception here if needed
      logger.error(messageLog, error: exception, stackTrace: stackTrace);
    }

    return const NetworkFailure();
  }
}
