import 'dart:async';

import 'package:codenic_exception_converter/codenic_exception_converter.dart';

/// A signature for [ErrorConverter] factories.
typedef ErrorConverterFactory = ErrorConverter<Object, T> Function<T>();

typedef TaskCallback<T> = FutureOr<Either<Failure, T>> Function(String tag);

/// {@template ExceptionConverterSuite}
/// A class which allows multiple [ErrorConverter]s to be grouped together,
/// so that when a task is executed and an error is thrown, it can be
/// converted into the appropriate [Failure] object.
/// {@endtemplate}
class ExceptionConverterSuite {
  /// {@macro ExceptionConverterSuite}
  ExceptionConverterSuite({this.defaultErrorConverters = const []});

  /// The default [ErrorConverter]s used to convert errors into [Failure]s.
  ///
  /// Here you can provide your own default [ErrorConverter]s to convert
  /// errors into [Failure]s which will be used by the [observe] and
  /// [convert] methods.
  final List<ErrorConverterFactory> defaultErrorConverters;

  /// Converts any uncaught errors thrown by the [task] into a [Failure].
  ///
  /// A [messageLog](https://arch.codenic.dev/packages/codenic-logger)
  /// can be provided to log the result of the [task] after completion. If
  /// [printOutput] is `true`, then the returned output of the [task] is
  /// printed in the [messageLog].
  ///
  /// If no error occurs, then value [T] is returned.
  ///
  /// If an error is thrown, then it will be converted into a [Failure]
  /// using the [ErrorConverter]s provided in the [errorConverters]
  /// and [ExceptionConverterSuite.defaultErrorConverters], if any. If no
  /// matching [ErrorConverter] is found, then the [FallbackExceptionConverter]
  /// will be used for thrown [Exception]s. Otherwise, the [Error] will be
  /// thrown as is.
  FutureOr<Either<Failure, T>> observe<T>({
    required String tag,
    required TaskCallback<T> task,
    List<ErrorConverter<Object, T>>? errorConverters,
  }) async {
    final extendedErrorConverters =
        _extendedErrorConverters<T>(errorConverters);

    return await extendedErrorConverters.fold<TaskCallback<T>>(
      (tag) async => await task(tag),
      (task, element) => (tag) => element.observe(tag: tag, task: task),
    )(tag);
  }

  /// Converts the given [error] into a [Failure].
  ///
  /// If no matching [ErrorConverter] is found, then a [StateError] is thrown.
  Failure convert({
    required Object error,
    List<ErrorConverter<Object, void>>? errorConverters,
  }) {
    final extendedErrorConverters = _extendedErrorConverters(errorConverters);

    for (final errorConverter in extendedErrorConverters) {
      if (errorConverter.errorEquals(error)) {
        return errorConverter.convert(error);
      }
    }

    // coverage:ignore-start
    throw StateError(
      'No matching error conversion found for ${error.runtimeType}',
    );
    // coverage:ignore-end
  }

  List<ErrorConverter<Object, T>> _extendedErrorConverters<T>(
    List<ErrorConverter<Object, T>>? errorConverters,
  ) =>
      [
        ...?errorConverters,
        ...defaultErrorConverters.map((e) => e<T>()),
      ];
}
