import 'dart:io';

import 'package:codenic_exception_converter/codenic_exception_converter.dart';
import 'package:test/test.dart';

class SocketFailure extends Failure {
  const SocketFailure({
    super.code = 'socket-failure',
    super.message = 'Socket failure occurred',
  });
}

final class SocketExceptionConverter<T>
    extends ExceptionConverter<SocketException, T> {
  const SocketExceptionConverter();

  @override
  Failure convert(SocketException exception) => const SocketFailure();

  @override
  void logError(
    String tag,
    SocketException exception,
    StackTrace stackTrace,
  ) {}
}

void main() {
  group(
    'Exception converter suite',
    () {
      late ExceptionConverterSuite exceptionConverterSuite;

      setUp(() {
        exceptionConverterSuite = ExceptionConverterSuite();
      });

      group(
        'observe',
        () {
          test(
            'should return a `NetworkFailure` when a socket exception is '
            'thrown',
            () async {
              final result = await exceptionConverterSuite.observe<void>(
                tag: 'test',
                errorConverters: [const SocketExceptionConverter()],
                task: (messageLog) {
                  throw const SocketException('test');
                },
              );

              result.fold(
                (l) => expect(l, isA<SocketFailure>()),
                (r) => throw StateError(''),
              );
            },
          );

          test(
            'should return a failure from the default exception converters '
            'when an exception is thrown',
            () async {
              final exceptionConverter = ExceptionConverterSuite(
                defaultErrorConverters: [SocketExceptionConverter.new],
              );

              final result = await exceptionConverter.observe<void>(
                tag: 'test',
                task: (messageLog) {
                  throw const SocketException('test');
                },
              );

              result.fold(
                (l) => expect(l, isA<SocketFailure>()),
                (r) => throw StateError(''),
              );
            },
          );
        },
      );

      group(
        'convert',
        () {
          test(
            'should convert `SocketException` to `NetworkFailure`',
            () {
              final result = exceptionConverterSuite.convert(
                error: const SocketException('test'),
                errorConverters: [const SocketExceptionConverter()],
              );

              expect(result, isA<SocketFailure>());
            },
          );

          test(
            'should convert `SocketException` to `NetworkFailure` using the '
            'default exception converters',
            () {
              final exceptionConverter = ExceptionConverterSuite(
                defaultErrorConverters: [SocketExceptionConverter.new],
              );

              final result = exceptionConverter.convert(
                error: const SocketException('test'),
              );

              expect(result, isA<SocketFailure>());
            },
          );
        },
      );
    },
  );
}
