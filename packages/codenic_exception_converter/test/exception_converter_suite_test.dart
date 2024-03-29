import 'dart:io';

import 'package:codenic_exception_converter/codenic_exception_converter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements CodenicLogger {}

class SocketFailure extends Failure {
  const SocketFailure({super.message = 'Socket failure occurred'});
}

final class SocketExceptionConverter<T>
    extends ExceptionConverter<SocketException, T> {
  const SocketExceptionConverter();

  @override
  Failure convert({
    required SocketException exception,
    StackTrace? stackTrace,
    CodenicLogger? logger,
    MessageLog? messageLog,
  }) =>
      const SocketFailure();
}

typedef PrinterCallback = List<String> Function(
  Level level,
  dynamic message,
  dynamic error,
  StackTrace? stackTrace,
);

class CallbackPrinter extends MessageLogPrinter {
  CallbackPrinter({required this.callback});

  final PrinterCallback callback;

  @override
  List<String> log(LogEvent event) {
    return callback(
      event.level,
      event.message,
      event.error,
      event.stackTrace,
    );
  }
}

void main() {
  group(
    'Exception converter suite',
    () {
      final messageLog = MessageLog(id: 'test');

      Level? printedLevel;
      dynamic printedMessage;
      dynamic printedError;
      StackTrace? printedStackTrace;

      final callbackPrinter = CallbackPrinter(
        callback: (level, message, error, stackTrace) {
          printedLevel = level;
          printedMessage = message;
          printedError = error;
          printedStackTrace = stackTrace;

          return [];
        },
      );

      late ExceptionConverterSuite exceptionConverterSuite;

      setUp(() {
        final logger = CodenicLogger(printer: callbackPrinter);
        exceptionConverterSuite = ExceptionConverterSuite(logger: logger);

        printedLevel = null;
        printedMessage = null;
        printedError = null;
        printedStackTrace = null;
      });

      group(
        'observe sync',
        () {
          test(
            'should return a `NetworkFailure` when a socket exception is '
            'thrown',
            () async {
              final result = await exceptionConverterSuite.observe<void>(
                messageLog: messageLog,
                exceptionConverters: [const SocketExceptionConverter()],
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
                exceptionConverters: [SocketExceptionConverter.new],
              );

              final result = await exceptionConverter.observe<void>(
                messageLog: messageLog,
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
            'should return a base failure when an exception is thrown without '
            'an exception converter',
            () async {
              final result = await exceptionConverterSuite.observe<void>(
                messageLog: messageLog,
                task: (messageLog) {
                  throw const FormatException();
                },
              );

              result.fold(
                (l) => expect(l, isA<Failure>()),
                (r) => throw StateError(''),
              );
            },
          );

          test('should log a warning when a failure is returned, ', () async {
            await exceptionConverterSuite.observe<void>(
              messageLog: messageLog,
              task: (messageLog) {
                return const Left(Failure());
              },
            );

            expect(printedLevel, Level.warning);
            expect(printedMessage, messageLog);
            expect(printedError, isNull);
            expect(printedStackTrace, isNull);
          });

          test('should log an info on success', () async {
            await exceptionConverterSuite.observe<void>(
              messageLog: messageLog,
              task: (messageLog) {
                return const Right(null);
              },
            );

            expect(printedLevel, Level.info);
            expect(printedMessage, messageLog);
            expect(printedError, isNull);
            expect(printedStackTrace, isNull);
          });
        },
      );

      group(
        'observe',
        () {
          test(
            'should return a `NetworkFailure` when a socket exception is '
            'thrown',
            () async {
              final result = await exceptionConverterSuite.observe<void>(
                messageLog: messageLog,
                exceptionConverters: [const SocketExceptionConverter()],
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
                exceptionConverters: [SocketExceptionConverter.new],
              );

              final result = await exceptionConverter.observe<void>(
                messageLog: messageLog,
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
            'should return a base failure when an exception is thrown without '
            'an exception converter',
            () async {
              final result = await exceptionConverterSuite.observe<void>(
                messageLog: messageLog,
                task: (messageLog) {
                  throw const FormatException();
                },
              );

              result.fold(
                (l) => expect(l, isA<Failure>()),
                (r) => throw StateError(''),
              );
            },
          );

          test(
            'should log a warning when a failure is returned, ',
            () async {
              await exceptionConverterSuite.observe<void>(
                messageLog: messageLog,
                task: (messageLog) async {
                  return const Left(Failure());
                },
              );

              expect(printedLevel, Level.warning);
              expect(printedMessage, messageLog);
              expect(printedError, isNull);
              expect(printedStackTrace, isNull);
            },
          );

          test(
            'should log an info on success',
            () async {
              await exceptionConverterSuite.observe<void>(
                messageLog: messageLog,
                task: (messageLog) async {
                  return const Right(null);
                },
              );

              expect(printedLevel, Level.info);
              expect(printedMessage, messageLog);
              expect(printedError, isNull);
              expect(printedStackTrace, isNull);
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
                messageLog: messageLog,
                error: const SocketException('test'),
                exceptionConverters: [const SocketExceptionConverter()],
              );

              expect(result, isA<SocketFailure>());
            },
          );

          test(
            'should convert `SocketException` to `NetworkFailure` using the '
            'default exception converters',
            () {
              final exceptionConverter = ExceptionConverterSuite(
                exceptionConverters: [SocketExceptionConverter.new],
              );

              final result = exceptionConverter.convert(
                messageLog: messageLog,
                error: const SocketException('test'),
              );

              expect(result, isA<SocketFailure>());
            },
          );

          test(
            'should throw an `Error` when an `Error` is passed',
            () {
              expect(
                () => exceptionConverterSuite.convert(
                  messageLog: messageLog,
                  error: const OutOfMemoryError(),
                ),
                throwsA(isA<OutOfMemoryError>()),
              );
            },
          );

          test(
            'should throw an `Error` when an `Error` with `StackTrace` is '
            'passed',
            () {
              final stackTrace = StackTrace.fromString('Fake stack trace');

              try {
                exceptionConverterSuite.convert(
                  error: const OutOfMemoryError(),
                  stackTrace: stackTrace,
                );
              } catch (e, s) {
                expect(e, isA<OutOfMemoryError>());
                expect(s, stackTrace);
              }
            },
          );

          test(
            'should throw an `ArgumentError` when an a non-exception is passed',
            () {
              expect(
                () => exceptionConverterSuite.convert(
                  messageLog: messageLog,
                  error: 'Test',
                ),
                throwsA(isA<ArgumentError>()),
              );
            },
          );
        },
      );

      group(
        'add predefined stack trace blocklist reg exps',
        () {
          test('should not duplicate stack trace reg exp in blocklist', () {
            final codenicLogger = CodenicLogger(
              printer: MessageLogPrinter(
                stackTraceBlocklist: [RegExp(r'^<asynchronous suspension>$')],
              ),
            );

            ExceptionConverterSuite(logger: codenicLogger);

            expect(
              codenicLogger.printer.stackTraceBlocklist,
              hasLength(4),
            );
          });
        },
      );
    },
  );
}
