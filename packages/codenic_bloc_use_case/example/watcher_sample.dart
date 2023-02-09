// ignore_for_file: avoid_print

part of 'main.dart';

Future<void> watcher() async {
  print(
    '\n//******************** WATCHER USE CASE SAMPLE ********************',
  );

  print('\n** INITIALIZE WATCHER **');

  // Initialize the watcher use case
  final watchFruitBasket = WatchFruitBasket();

  printWatchResults(watchFruitBasket);

  print('\n** FAILED WATCHER START **');

  // Start the watcher stream with an expected failed result
  await watchFruitBasket.watch(
    params: const WatchFruitBasketParams(maxCapacity: -1),
  );

  // View the results
  printWatchResults(watchFruitBasket);

  print('\n** SUCCESSFUL WATCHER START **');

  // Start the watcher stream with an expected failed result
  await watchFruitBasket.watch(
    params: const WatchFruitBasketParams(maxCapacity: 2),
  );

  // View the results
  printWatchResults(watchFruitBasket);

  print('\n** WATCHER ERROR EVENT **');

  // Emit an error event in the watcher
  watchFruitBasket.addFruits(['Apple', 'Orange', 'Mango']);

  await Future<void>.delayed(Duration.zero);

  // View the results
  printWatchResults(watchFruitBasket);

  print('\n** WATCHER DATA EVENT **');

  // Emit a data event in the watcher
  watchFruitBasket.addFruits(['Apple', 'Orange']);

  await Future<void>.delayed(Duration.zero);

  // View the results
  printWatchResults(watchFruitBasket);

  print('\n** WATCHER STREAM CLOSED **');

  await watchFruitBasket.closeStream();

  print('\n** RESET WATCHER **');

  // Reset the watcher use case to its initial state
  await watchFruitBasket.reset();

  // View the results
  printWatchResults(watchFruitBasket);

  print(
    '\n******************** WATCHER USE CASE SAMPLE END ********************//',
  );
}

void printWatchResults(
  Watcher<WatchFruitBasketParams, Failure, FruitBasket> watcher,
) {
  print('');

  // The latest value returned when calling `watch()`. This may either be the
  // `leftValue` if `StartWatchFailed` was recently emitted. Otherwise, this
  // will be equal to the `rightValue` if `StartWatchSuccess` was more recent
  print('Current value: ${watcher.value}');

  // The latest params returned when calling `watch()`. This may either be the
  // `leftParams` if `StartWatchFailed` was recently emitted. Otherwise, this
  // will be equal to the `rightParams` if `StartWatchSuccess` was more recent
  print('Current params: ${watcher.params}');

  // The last left value returned when a failed `watch()` was called
  print('Last left value: ${watcher.leftValue}');

  // The last left params passed when a failed `watch()` was called
  print('Last left params: ${watcher.leftParams}');

  // The last right value returned when a successful `watch()` was called
  print('Last right value: ${watcher.rightValue}');

  // The last right params passed when a successful `watch()` was called
  print('Last right params: ${watcher.rightParams}');

  print('');

  // The latest event emitted by the Watcher. This can either be the
  // `leftEvent` if `WatchErrorReceived` was recently emitted. Otherwise, this
  // will be equal to the `rightEvent` if `WatchDataReceived` was more recent
  print('Current event: ${watcher.event}');

  // The last error event emitted by Watcher
  print('Last left event: ${watcher.leftEvent}');

  // The last data event emitted by the Watcher
  print('Last right event: ${watcher.rightEvent}');

  // To set all these values back to `null`, call `reset()`
}

/// A watcher for streaming fruits that goes inside the fruit basket.
class WatchFruitBasket
    extends Watcher<WatchFruitBasketParams, Failure, FruitBasket> {
  /// The stream controller for the fruit basket.
  StreamController<FruitBasket>? streamController;

  /// The max number of fruits allowed in the fruit basket.
  int? basketCapacity;

  /// The fruits currently in the fruit basket.
  List<String>? fruits;

  /// A callback function triggered when the [watch] method is called.
  @override
  FutureOr<Either<Failure, VerboseStream<Failure, FruitBasket>>> onCall(
    WatchFruitBasketParams params,
  ) async {
    if (params.maxCapacity < 1) {
      // When the basket capacity is less than 1, then a left value is returned
      return const Left(Failure('Basket capacity must be greater than 0'));
    }

    basketCapacity = params.maxCapacity;
    fruits = [];
    await streamController?.close();

    // Create a new stream controller
    streamController = StreamController<FruitBasket>();

    // Return a right value `VerboseStream` containing the stream that will be
    // listened to and its error converter
    //
    // A [VerboseStream] is a [Stream] wrapper which gives it an error
    // handler for converting [Exception]s into [Failure]s before it gets
    // emitted
    return Right(
      VerboseStream(
        stream: streamController!.stream,
        errorConverter: (error, stackTrace) => Failure(error.toString()),
      ),
    );
  }

  /// A helper method to add fruits to the fruit basket.
  void addFruits(List<String> newFruits) {
    if (fruits == null || basketCapacity == null || streamController == null) {
      return;
    }

    if (fruits!.length + newFruits.length <= basketCapacity!) {
      fruits!.addAll(newFruits);
      streamController!.add(FruitBasket(fruits!));
    } else {
      streamController!.addError(Exception('Fruit Basket is full'));
    }
  }

  /// A helper method for closing the stream controller.
  Future<void> closeStream() async => streamController?.close();

  @override
  Future<void> close() {
    streamController?.close();
    return super.close();
  }
}

/// The parameter for the [WatchFruitBasket] use case to specify the max
/// capacity allowed in the fruit basket.
class WatchFruitBasketParams {
  const WatchFruitBasketParams({required this.maxCapacity});

  /// The max number of fruits allowed in the fruit basket.
  final int maxCapacity;

  @override
  String toString() => toMap().toString();

  Map<String, dynamic> toMap() => {'maxCapacity': maxCapacity};
}

/// The right value for the [FruitBasket] use case representing the fruit
/// basket.
class FruitBasket {
  const FruitBasket(this.fruits);

  /// The fruits in the basket.
  final List<String> fruits;

  @override
  String toString() => 'FruitBasket: $fruits';
}
