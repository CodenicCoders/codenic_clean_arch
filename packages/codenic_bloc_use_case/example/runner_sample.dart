// ignore_for_file: avoid_print

part of 'main.dart';

Future<void> runner() async {
  print('\n//******************** RUNNER USE CASE SAMPLE ********************');

  print('\n** INITIALIZE RUNNER **');

  // Initialize the runner use case
  final countFruit = CountFruit();

  printRunResults(countFruit);

  print('\n** FAILED RUN **');

  // Execute the runner with an expected failed result
  await countFruit.run(params: const CountFruitParams([]));

  // View the results
  printRunResults(countFruit);

  print('\n** SUCCESSFUL RUN **');

  // Execute the runner with an expected successful result
  await countFruit.run(
    params: const CountFruitParams(['Apple', 'Orange', 'Apple']),
  );

  // View the results
  printRunResults(countFruit);

  print('\n** RESET RUNNER **');

  // Reset the runner use case to its initial state
  await countFruit.reset();

  // View the results
  printRunResults(countFruit);

  print(
    '\n******************** RUNNER USE CASE SAMPLE END ********************//',
  );
}

void printRunResults(
  Runner<CountFruitParams, Failure, CountFruitResult> runner,
) {
  print('');

  // The recent value returned when calling `run()`. This may either be the
  // `leftValue` if the current state is `RunFailed` or the `rightValue` if the
  // current state is `RunSuccess`

  // The latest value returned when calling `run()`. This may either be the
  // `leftValue` if `RunFailed` was recently emitted. Otherwise, this
  // will be equal to the `rightValue` if `RunSuccess` was more recent

  print('Current value: ${runner.value}');

  // The recent params passed when calling `run()`. This may either be the
  // `leftParams` if the state current is `RunFailed` or the `rightParams` if
  // the current state is `RunSuccess`
  print('Current params: ${runner.params}');

  // The last left value returned when a failed `run()` was called
  print('Last left value: ${runner.leftValue}');

  // The last left params passed when a failed `run()` was called
  print('Last left params: ${runner.leftParams}');

  // The last right value returned when a successful `run()` was called
  print('Last right value: ${runner.rightValue}');

  // The last right params passed when a successful `run()` was called
  print('Last right params: ${runner.rightParams}');

  // To set all these values back to `null`, call `reset()`
}

/// A runner that counts the quantity of each given fruit.
final class CountFruit
    extends Runner<CountFruitParams, Failure, CountFruitResult> {
  /// A callback function triggered when the [run] method is called.
  @override
  FutureOr<Either<Failure, CountFruitResult>> onCall(
    CountFruitParams params,
  ) async {
    if (params.fruits.isEmpty) {
      // When the given fruits is empty, then a left value is returned
      return const Left(Failure('There are no fruits to count'));
    }

    final fruitCount = <String, int>{};

    for (final fruit in params.fruits) {
      fruitCount[fruit] = (fruitCount[fruit] ?? 0) + 1;
    }

    // Returns a right value containing the fruit count
    final result = CountFruitResult(fruitCount);
    return Right(result);
  }
}

/// A parameter for the [CountFruit] use case containing all the available
/// fruits to count.
final class CountFruitParams {
  const CountFruitParams(this.fruits);

  /// The fruits in our fruit basket.
  ///
  /// Example:
  /// [ apple, orange, mango, apple, apple, mango ]
  final List<String> fruits;

  @override
  String toString() => {'fruits': fruits}.toString();
}

/// The right value for [CountFruit] containing the count for each fruit.
final class CountFruitResult {
  const CountFruitResult(this.fruitCount);

  /// The fruits counted by type
  ///
  /// Example:
  /// { apple: 3, orange: 1, mango: 2 }
  final Map<String, int> fruitCount;

  @override
  String toString() => '$fruitCount';
}
