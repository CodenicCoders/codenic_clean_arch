import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:test/test.dart';

/// A dummy use case for testing the [Watcher].
///
/// A stream use case that emits succeeding even numbers respective to
/// the given incrementor value.
final class TestWatchEvenNumbers extends Watcher<int, String, int> {
  int _currentValue = 0;
  int _incrementor = 0;

  StreamController<int>? _streamController;

  @override
  Future<Either<String, VerboseStream<String, int>>> onCall(int params) async {
    await ensureAsync();

    if (params % 2 != 0 || params <= 0) {
      return const Left('Argument must be an even whole number');
    }

    _currentValue = 0;
    _incrementor = params;

    _streamController = StreamController();

    final verboseStream = VerboseStream<String, int>(
      stream: _streamController!.stream,
      errorConverter: (error, stackTrace) => error.toString(),
    );

    return Right(verboseStream);
  }

  void nextEvenNumber() =>
      _streamController?.add(_currentValue += _incrementor);

  void sendError(Exception error) => _streamController?.addError(error);

  void closeStream() => _streamController?.close();
}

void main() {
  group(
    'Watcher use case',
    () {
      group(
        'watch',
        () {
          late TestWatchEvenNumbers watcher;

          setUp(() => watcher = TestWatchEvenNumbers());

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should emit error value when stream start fails',
            build: () => watcher,
            act: (watcher) => watcher.watch(params: 1),
            expect: () => const [
              StartWatching(1),
              StartWatchFailed('Argument must be an even whole number', 1),
            ],
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should emit new value when stream start succeeds',
            build: () => watcher,
            act: (watcher) => watcher.watch(params: 2),
            expect: () => [
              const StartWatching(1),
              StartWatchSuccess<VerboseStream<String, int>>(
                watcher.rightValue!,
                1,
              ),
            ],
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should emit data event',
            build: () => watcher,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher.nextEvenNumber();
            },
            expect: () => [
              const StartWatching(1),
              StartWatchSuccess<VerboseStream<String, int>>(
                watcher.rightValue!,
                1,
              ),
              const WatchDataReceived(2, 1),
            ],
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should emit error event',
            build: () => watcher,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher.sendError(Exception('Error Event Emitted'));
            },
            expect: () => [
              const StartWatching(1),
              StartWatchSuccess<VerboseStream<String, int>>(
                watcher.rightValue!,
                1,
              ),
              const WatchErrorReceived<String>(
                'Exception: Error Event Emitted',
                1,
              ),
            ],
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should emit done when stream has closed',
            build: () => watcher,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher.closeStream();
            },
            expect: () => [
              const StartWatching(1),
              StartWatchSuccess<VerboseStream<String, int>>(
                watcher.rightValue!,
                1,
              ),
              const WatchDone(1),
            ],
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should not emit new event when an error occurs given that '
            'cancel on error is enabled',
            build: () => watcher,
            act: (watcher) async {
              await watcher.watch(params: 2, cancelOnError: true);
              watcher
                ..sendError(Exception('Error Event Emitted'))
                ..nextEvenNumber();
            },
            expect: () => [
              const StartWatching(1),
              StartWatchSuccess<VerboseStream<String, int>>(
                watcher.rightValue!,
                1,
              ),
              const WatchErrorReceived<String>(
                'Exception: Error Event Emitted',
                1,
              ),
            ],
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should still emit new event when an error occured given that '
            'cancel on error is disabled',
            build: () => watcher,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher
                ..sendError(Exception('Error Event Emitted'))
                ..nextEvenNumber();
            },
            expect: () => [
              const StartWatching(1),
              StartWatchSuccess<VerboseStream<String, int>>(
                watcher.rightValue!,
                1,
              ),
              const WatchErrorReceived<String>(
                'Exception: Error Event Emitted',
                1,
              ),
              const WatchDataReceived<int>(2, 1),
            ],
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should not emit state from old watch call when new watch call '
            'is made at the same time',
            build: () => watcher,
            act: (watcher) async => Future.wait([
              watcher.watch(params: 2),
              watcher.watch(params: 2),
            ]),
            expect: () => [
              const StartWatching(2),
              StartWatchSuccess<VerboseStream<String, int>>(
                watcher.rightValue!,
                2,
              ),
            ],
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should cancel state emission from old running watch call when '
            'new watch call is made',
            build: () => watcher,
            act: (watcher) async {
              unawaited(watcher.watch(params: 2));
              await ensureAsync();
              await watcher.watch(params: 2);
            },
            expect: () => [
              const StartWatching(1),
              const StartWatching(2),
              StartWatchSuccess<VerboseStream<String, int>>(
                watcher.rightValue!,
                2,
              ),
            ],
          );

          test(
            'should return null if use case is closed',
            () async {
              await watcher.close();

              final watchResult = await watcher.watch(params: 2);

              expect(watchResult, isNull);
            },
          );

          test('should return error value if start watch fails', () async {
            final watchResult = await watcher.watch(params: 1);

            expect(
              watchResult,
              isA<Left<String, VerboseStream<String, int>>>(),
            );
          });

          test('should return success value if start watch succeeds', () async {
            final watchResult = await watcher.watch(params: 2);

            expect(
              watchResult,
              isA<Right<String, VerboseStream<String, int>>>(),
            );
          });
        },
      );

      group(
        'value',
        () {
          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should identify if last emitted value is a success value',
            build: TestWatchEvenNumbers.new,
            act: (watcher) => watcher.watch(params: 2),
            verify: (watcher) => expect(watcher.value?.isRight(), true),
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should identify if last emitted event is an error value',
            build: TestWatchEvenNumbers.new,
            act: (watcher) => watcher.watch(params: 1),
            verify: (watcher) => expect(watcher.value?.isLeft(), true),
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should clear value when reset',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              await watcher.reset();
            },
            verify: (watcher) => expect(watcher.value, null),
          );
        },
      );

      group(
        'left value',
        () {
          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should still have reference to the last error value when stream '
            'creation succeeds',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 1);
              await watcher.watch(params: 2);
            },
            verify: (watcher) => expect(
              watcher.leftValue,
              'Argument must be an even whole number',
            ),
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should clear left value when reset',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 1);
              await watcher.reset();
            },
            verify: (watcher) => expect(watcher.leftValue, null),
          );
        },
      );

      group(
        'right value',
        () {
          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should still have reference to the last success value when stream '
            'creation fails',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              await watcher.watch(params: 1);
            },
            verify: (watcher) => expect(watcher.rightValue != null, true),
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should clear right value when reset',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              await watcher.reset();
            },
            verify: (watcher) => expect(watcher.rightValue, null),
          );
        },
      );

      group(
        'event',
        () {
          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should identify if last emitted event is a data event',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher
                ..sendError(Exception('Error Event Emitted'))
                ..nextEvenNumber();
            },
            verify: (watcher) => expect(watcher.event?.isRight(), true),
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should identify if last emitted event is an error event',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher
                ..nextEvenNumber()
                ..sendError(Exception('Error Event Emitted'));
            },
            verify: (watcher) => expect(watcher.event?.isLeft(), true),
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should clear event when reset',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher.nextEvenNumber();
              await ensureAsync();
              await watcher.reset();
            },
            verify: (watcher) => expect(watcher.event, null),
          );
        },
      );

      group(
        'left event',
        () {
          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should still have reference to the last error event when new data '
            'event is emitted',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher
                ..sendError(Exception('Error Event Emitted'))
                ..nextEvenNumber();
            },
            verify: (watcher) => expect(
              watcher.leftEvent,
              'Exception: Error Event Emitted',
            ),
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should still have reference to the last error event when new '
            'stream is created',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher.sendError(Exception('Error Event Emitted'));
              await ensureAsync();
              await watcher.watch(params: 2);
            },
            verify: (watcher) => expect(
              watcher.leftEvent,
              'Exception: Error Event Emitted',
            ),
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should clear left event when reset',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher.sendError(Exception('Error Event Emitted'));
              await ensureAsync();
              await watcher.reset();
            },
            verify: (watcher) => expect(watcher.leftEvent, null),
          );
        },
      );

      group(
        'right event',
        () {
          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should still have reference to the last data event when new error '
            'event is emitted',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher
                ..nextEvenNumber()
                ..sendError(Exception('Error Event Emitted'));
            },
            verify: (watcher) => expect(watcher.rightEvent, 2),
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should still have reference to the last data event when new '
            'stream is created',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher.nextEvenNumber();
              await ensureAsync();
              await watcher.watch(params: 2);
            },
            verify: (watcher) => expect(watcher.rightEvent, 2),
          );

          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should clear right event when reset',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              watcher.nextEvenNumber();
              await ensureAsync();
              await watcher.reset();
            },
            verify: (watcher) => expect(watcher.rightEvent, null),
          );
        },
      );

      group(
        'reset',
        () {
          blocTest<TestWatchEvenNumbers, WatcherState>(
            'should reset watcher',
            build: TestWatchEvenNumbers.new,
            act: (watcher) async {
              await watcher.watch(params: 2);
              await watcher.reset();
            },
            expect: () => [
              const StartWatching(1),
              isA<StartWatchSuccess>(),
              const WatcherInitial(2),
            ],
          );
        },
      );
    },
  );
}
