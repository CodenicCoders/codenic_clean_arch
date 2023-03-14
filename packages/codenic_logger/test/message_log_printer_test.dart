import 'package:codenic_logger/codenic_logger.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Message log printer',
    () {
      group(
        'log',
        () {
          test(
            'should print more line when error occurs',
            () {
              // Given
              final messageLogPrinter = MessageLogPrinter(
                methodCount: 3,
                errorMethodCount: 4,
              );

              final messageLog = MessageLog(
                id: 'sample',
                message: 'lorep',
                data: <String, dynamic>{'aliquam': 'arcu'},
              );

              final logEvent = LogEvent(Level.info, messageLog);

              final errorLogEvent = LogEvent(
                Level.error,
                messageLog,
                Exception(),
                StackTrace.current,
              );

              // When

              final output = messageLogPrinter.log(logEvent);
              final errorOutput = messageLogPrinter.log(errorLogEvent);

              // Then
              expect(errorOutput.length > output.length, true);
            },
          );
        },
      );

      group(
        'format stack trace',
        () {
          test(
            'should move start index',
            () {
              // Given
              const stackTraceStr = '''
#0   main (file:///codenic_clean_arch/packages/codenic_logger/example/main.dart:11:5)
#1   _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:297:19)
#2   _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:192:12)
''';

              final stackTrace = StackTrace.fromString(stackTraceStr);

              final messageLogPrinter =
                  MessageLogPrinter(stackTraceBeginIndex: 1);

              // When
              final formattedStackTrace =
                  messageLogPrinter.formatStackTrace(stackTrace, 8);

              // Then
              expect(
                formattedStackTrace,
                '''
#0   _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:297:19)
#1   _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:192:12)''',
              );
            },
          );

          test(
            'should not print blocklisted lines',
            () {
              // Given
              const stackTraceStr = '''
#0   main (file:///codenic_clean_arch/packages/codenic_logger/example/main.dart:11:5)
#1   _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:297:19)
#2   _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:192:12)
''';

              final stackTrace = StackTrace.fromString(stackTraceStr);

              final messageLogPrinter = MessageLogPrinter(
                stackTraceBlocklist: [RegExp('<anonymous closure>')],
              );

              // When
              final formattedStackTrace =
                  messageLogPrinter.formatStackTrace(stackTrace, 8);

              // Then
              expect(
                formattedStackTrace,
                '''
#0   main (file:///codenic_clean_arch/packages/codenic_logger/example/main.dart:11:5)
#1   _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:192:12)''',
              );
            },
          );

          test(
            'should remove device stack trace lines',
            () {
              // Given
              const stackTraceStr = '''
#0   lorep (package:codenic_logger/main.dart:11:5)
#1   _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:297:19)
#2   _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:192:12)
''';

              final stackTrace = StackTrace.fromString(stackTraceStr);

              final messageLogPrinter = MessageLogPrinter();

              // When
              final formattedStackTrace =
                  messageLogPrinter.formatStackTrace(stackTrace, 8);

              // Then
              expect(
                formattedStackTrace,
                '''
#0   _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:297:19)
#1   _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:192:12)''',
              );
            },
          );

          test(
            'should remove web stack trace lines',
            () {
              // Given
              const stackTraceStr = '''
packages/codenic_logger/main.dart 11:5
packages/lorep/isolate_patch.dart 297:19
packages/ipsum/isolate_path.dart 192:12
''';

              final stackTrace = StackTrace.fromString(stackTraceStr);

              final messageLogPrinter = MessageLogPrinter();

              // When
              final formattedStackTrace =
                  messageLogPrinter.formatStackTrace(stackTrace, 8);

              // Then
              expect(
                formattedStackTrace,
                '''
#0   packages/lorep/isolate_patch.dart 297:19
#1   packages/ipsum/isolate_path.dart 192:12''',
              );
            },
          );

          test(
            'should remove browser stack trace lines',
            () {
              // Given
              const stackTraceStr = '''
#0   Declarer.test.<anonymous closure>.<anonymous closure> (package:test_api/src/backend/declarer.dart:215:19)
#1   Declarer.test.<anonymous closure>.<anonymous closure> (package:test_api/src/backend/declarer.dart:215:19)
#2   Declarer.test.<anonymous closure>.<anonymous closure> (package:codenic_logger/src/backend/declarer.dart:215:19)
''';

              final stackTrace = StackTrace.fromString(stackTraceStr);

              final messageLogPrinter = MessageLogPrinter();

              // When
              final formattedStackTrace =
                  messageLogPrinter.formatStackTrace(stackTrace, 8);

              // Then
              expect(
                formattedStackTrace,
                '''
#0   Declarer.test.<anonymous closure>.<anonymous closure> (package:test_api/src/backend/declarer.dart:215:19)
#1   Declarer.test.<anonymous closure>.<anonymous closure> (package:test_api/src/backend/declarer.dart:215:19)''',
              );
            },
          );
        },
      );
    },
  );
}
