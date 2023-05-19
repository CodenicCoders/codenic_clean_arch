import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:test/test.dart';

/// A dummy use case for testing the [Runner].
///
/// A use case that returns the next even number from the given even number
/// argument.
final class TestNextEvenNumber extends Runner<int, String, int> {
  @override
  Future<Either<String, int>> onCall(int params) async {
    await ensureAsync();

    if (params % 2 != 0) {
      return const Left('Argument is not an even number');
    }

    final nextEvenNum = params + 2;

    return Right(nextEvenNum);
  }
}

void main() {
  group(
    'Runner use case',
    () {
      group(
        'run',
        () {
          late TestNextEvenNumber runner;

          setUp(() => runner = TestNextEvenNumber());

          blocTest<Runner<int, String, int>, RunnerState>(
            'should return success value when run succeeds',
            build: () => runner,
            act: (runner) => runner.run(params: 2),
            expect: () => const [Running(1), RunSuccess(4, 1)],
          );

          blocTest<Runner<int, String, int>, RunnerState>(
            'should return failure value when run fails',
            build: () => runner,
            act: (runner) => runner.run(params: 1),
            expect: () => const [
              Running(1),
              RunFailed('Argument is not an even number', 1),
            ],
          );

          blocTest<Runner<int, String, int>, RunnerState>(
            'should not emit state from old run call when new run call is made '
            'at the same time',
            build: () => runner,
            act: (runner) async =>
                Future.wait([runner.run(params: 0), runner.run(params: 1)]),
            expect: () => const [
              Running(2),
              RunFailed('Argument is not an even number', 2),
            ],
          );

          blocTest<Runner<int, String, int>, RunnerState>(
            'should cancel state emission from old running batch-run call when '
            'new batch-run call is made',
            build: () => runner,
            act: (runner) async {
              unawaited(runner.run(params: 1));
              await ensureAsync();
              await runner.run(params: 2);
            },
            expect: () => const [
              Running(1),
              Running(2),
              RunSuccess(4, 2),
            ],
          );

          test(
            'should return null when use case is closed',
            () async {
              await runner.close();

              final runResult = await runner.run(params: 1);

              expect(runResult, null);
            },
          );

          test(
            'should return error value if run fails',
            () async {
              final result = await runner.run(params: 1);

              expect(result, isA<Left<String, int>>());
            },
          );

          test(
            'should return success value if run succeeds',
            () async {
              final result = await runner.run(params: 2);

              expect(result, isA<Right<String, int>>());
            },
          );
        },
      );

      group(
        'value',
        () {
          blocTest<Runner<int, String, int>, RunnerState>(
            'should identify if last emitted value is a success value',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 1);
              await runner.run(params: 2);
            },
            verify: (runner) => expect(runner.value?.isRight(), true),
          );

          blocTest<Runner<int, String, int>, RunnerState>(
            'should identify if last emitted value is an error value',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 2);
              await runner.run(params: 1);
            },
            verify: (runner) => expect(runner.value?.isLeft(), true),
          );

          blocTest<Runner<int, String, int>, RunnerState>(
            'should clear value when reset',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 2);
              await runner.reset();
            },
            verify: (runner) => expect(runner.value, null),
          );
        },
      );

      group(
        'left value',
        () {
          blocTest<Runner<int, String, int>, RunnerState>(
            'should still have reference to the last error value when runner '
            'succeeds',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 1);
              await runner.run(params: 2);
            },
            verify: (runner) =>
                expect(runner.leftValue, 'Argument is not an even number'),
          );

          blocTest<Runner<int, String, int>, RunnerState>(
            'should clear left value when reset',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 1);
              await runner.reset();
            },
            verify: (runner) => expect(runner.leftValue, null),
          );
        },
      );

      group(
        'right value',
        () {
          blocTest<Runner<int, String, int>, RunnerState>(
            'should still have reference to the last success value when runner '
            'fails',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 2);
              await runner.run(params: 1);
            },
            verify: (runner) => expect(runner.rightValue, 4),
          );

          blocTest<Runner<int, String, int>, RunnerState>(
            'should clear right value when reset',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 2);
              await runner.reset();
            },
            verify: (runner) => expect(runner.rightValue, null),
          );
        },
      );

      group(
        'params',
        () {
          blocTest<Runner<int, String, int>, RunnerState>(
            'should identify if last emitted params is a success params',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 1);
              await runner.run(params: 2);
            },
            verify: (runner) => expect(runner.params?.isRight(), true),
          );

          blocTest<Runner<int, String, int>, RunnerState>(
            'should identify if last emitted params is an error params',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 2);
              await runner.run(params: 1);
            },
            verify: (runner) => expect(runner.params?.isLeft(), true),
          );

          blocTest<Runner<int, String, int>, RunnerState>(
            'should clear params when reset',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 2);
              await runner.reset();
            },
            verify: (runner) => expect(runner.params, null),
          );
        },
      );

      group(
        'left params',
        () {
          blocTest<Runner<int, String, int>, RunnerState>(
            'should still have reference to the last error params when runner '
            'succeeds',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 1);
              await runner.run(params: 2);
            },
            verify: (runner) => expect(runner.leftParams, 1),
          );

          blocTest<Runner<int, String, int>, RunnerState>(
            'should clear left params when reset',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 1);
              await runner.reset();
            },
            verify: (runner) => expect(runner.leftParams, null),
          );
        },
      );

      group(
        'right params',
        () {
          blocTest<Runner<int, String, int>, RunnerState>(
            'should still have reference to the last success params when '
            'runner fails',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 2);
              await runner.run(params: 1);
            },
            verify: (runner) => expect(runner.rightParams, 2),
          );

          blocTest<Runner<int, String, int>, RunnerState>(
            'should clear right params when reset',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 2);
              await runner.reset();
            },
            verify: (runner) => expect(runner.rightParams, null),
          );
        },
      );

      group(
        'reset',
        () {
          blocTest<Runner<int, String, int>, RunnerState>(
            'should reset runner',
            build: TestNextEvenNumber.new,
            act: (runner) async {
              await runner.run(params: 2);
              await runner.reset();
            },
            expect: () =>
                const [Running(1), RunSuccess(4, 1), RunnerInitial(2)],
          );
        },
      );
    },
  );
}
