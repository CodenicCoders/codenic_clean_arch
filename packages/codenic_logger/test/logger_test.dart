import 'package:codenic_logger/codenic_logger.dart';
import 'package:test/test.dart';

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
    'Logger',
    () {
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

      late CodenicLogger logger;

      setUp(() {
        logger = CodenicLogger(printer: callbackPrinter);

        printedLevel = null;
        printedMessage = null;
        printedError = null;
        printedStackTrace = null;
      });

      group(
        'log levels',
        () {
          test(
            'should log trace',
            () {
              // Assign
              final messageLog = MessageLog(id: 'lorep_ipsum');

              // Act
              logger.trace(messageLog);

              // Assert
              expect(printedLevel, Level.trace);
              expect(printedMessage, messageLog);
              expect(printedError, isNull);
              expect(printedStackTrace, isNull);
            },
          );

          test(
            'should log debug',
            () {
              // Assign
              final messageLog = MessageLog(id: 'lorep_ipsum');

              // Act
              logger.debug(messageLog);

              // Assert
              expect(printedLevel, Level.debug);
              expect(printedMessage, messageLog);
              expect(printedError, isNull);
              expect(printedStackTrace, isNull);
            },
          );

          test(
            'should log info',
            () {
              // Assign
              final messageLog = MessageLog(id: 'lorep_ipsum');

              // Act
              logger.info(messageLog);

              // Assert
              expect(printedLevel, Level.info);
              expect(printedMessage, messageLog);
              expect(printedError, isNull);
              expect(printedStackTrace, isNull);
            },
          );

          test(
            'should log warn',
            () {
              // Assign
              final messageLog = MessageLog(id: 'lorep_ipsum');

              // Act
              logger.warn(messageLog);

              // Assert
              expect(printedLevel, Level.warning);
              expect(printedMessage, messageLog);
              expect(printedError, isNull);
              expect(printedStackTrace, isNull);
            },
          );

          test(
            'should log error',
            () {
              // Assign
              final messageLog = MessageLog(id: 'lorep_ipsum');
              final error = Exception();

              // Act
              logger.error(messageLog, error: error);

              // Assert
              expect(printedLevel, Level.error);
              expect(printedMessage, messageLog);
              expect(printedError, error);
              expect(printedStackTrace, isNull);
            },
          );

          test(
            'should log fatal',
            () {
              // Assign
              final messageLog = MessageLog(id: 'lorep_ipsum');

              // Act
              logger.fatal(messageLog);

              // Assert
              expect(printedLevel, Level.fatal);
              expect(printedMessage, messageLog);
              expect(printedError, isNull);
              expect(printedStackTrace, isNull);
            },
          );

          test(
            'should log message with user ID',
            () {
              // Assign
              final messageLog = MessageLog(
                id: 'lorep_ipsum',
                data: <String, dynamic>{'foo': 1},
              );

              // Act
              logger
                ..userId = 'sample-uid'
                ..info(messageLog);

              // Assert
              expect(
                printedMessage,
                messageLog.copyWith(
                  data: <String, dynamic>{
                    '__uid__': 'sample-uid',
                    ...messageLog.data,
                  },
                ),
              );
            },
          );
        },
      );

      group(
        'close',
        () {
          test(
            'should throw an `ArgumentError` when logging after closing',
            () {
              // Assign
              final messageLog = MessageLog(id: 'lorep_ipsum');

              // Act
              logger.close();

              // Assert
              expect(
                () => logger.info(messageLog),
                throwsA(isA<ArgumentError>()),
              );
            },
          );
        },
      );

      group(
        'copyWith',
        () {
          test(
            'should only change properties that have been replaced',
            () {
              // Assign
              final logger1 = CodenicLogger();

              // Act
              final logger2 = logger1.copyWith(printer: callbackPrinter);

              // Assert
              expect(logger2.printer, callbackPrinter);
              expect(logger2.filter, logger1.filter);
              expect(logger2.level, logger1.level);
              expect(logger2.output, logger1.output);
            },
          );

          test(
            'should not change any properties when nothing has been replaced',
            () {
              // Assign
              final logger1 = CodenicLogger();

              // Act
              final logger2 = logger1.copyWith();

              // Assert
              expect(logger2.printer, logger1.printer);
              expect(logger2.filter, logger1.filter);
              expect(logger2.level, logger1.level);
              expect(logger2.output, logger1.output);
            },
          );
        },
      );
    },
  );
}
