import 'dart:async';

import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Verbose stream',
    () {
      group(
        'listen',
        () {
          test(
            'should emit data to listener',
            () async {
              // Given
              final streamController = StreamController<int>();
              final emittedData = <int>[];

              // When

              VerboseStream<String, int>(
                stream: streamController.stream,
                errorConverter: (error, stacktrace) => '',
              ).listen(emittedData.add);

              streamController.add(1);

              await streamController.close();

              // Then
              expect(emittedData, [1]);
            },
          );

          test(
            'should convert error to expected failed value',
            () async {
              // Given
              final streamController = StreamController<int>();
              final emittedError = <String>[];

              // When

              VerboseStream<String, int>(
                stream: streamController.stream,
                errorConverter: (error, stacktrace) {
                  if (error is FormatException) {
                    return error.message;
                  }

                  return '';
                },
              ).listen(
                (data) {},
                onError: emittedError.add,
              );

              streamController.addError(const FormatException('Test error'));

              await streamController.close();

              // Then
              expect(emittedError, ['Test error']);
            },
          );

          test(
            'should trigger on done when stream is closed',
            () async {
              // Given
              final streamController = StreamController<int>();
              var isDone = false;

              // When

              VerboseStream<String, int>(
                stream: streamController.stream,
                errorConverter: (error, stacktrace) => '',
              ).listen(
                (data) {},
                onDone: () => isDone = true,
              );

              await streamController.close();

              // Then
              expect(isDone, true);
            },
          );

          test(
            'should trigger on done when stream error occurs',
            () async {
              // Given
              final streamController = StreamController<int>();
              var isDone = false;

              // When

              VerboseStream<String, int>(
                stream: streamController.stream,
                errorConverter: (error, stacktrace) => '',
              ).listen(
                (data) {},
                onDone: () => isDone = true,
              );

              await streamController.close();

              // Then
              expect(isDone, true);
            },
          );
        },
      );
    },
  );
}
