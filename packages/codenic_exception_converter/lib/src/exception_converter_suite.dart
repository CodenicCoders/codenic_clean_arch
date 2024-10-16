import 'dart:async';

import 'package:codenic_exception_converter/codenic_exception_converter.dart';
import 'package:codenic_exception_converter/src/exception_converters/fallback_exception_converter.dart';

/// A signature for [ErrorConverter] factories.
typedef ErrorConverterFactory = ErrorConverter<Object, T> Function<T>();

/// {@template ExceptionConverterSuite}
/// A class which allows multiple [ErrorConverter]s to be grouped together,
/// so that when a task is executed and an error is thrown, it can be
/// converted into the appropriate [Failure] object.
/// {@endtemplate}
class ExceptionConverterSuite {
  /// {@macro ExceptionConverterSuite}
  ExceptionConverterSuite({
    this.defaultErrorConverters = const [],
    CodenicLogger? logger,
  }) : logger = logger ?? CodenicLogger() {
    _addPredefinedStackTraceBlocklist();
  }

  /// Appends some predefined stack trace lines to the [logger]'s
  /// stack trace blocklist to remove lines from the
  /// `codenic_exception_converter`, `codenic_bloc_use_case` and `fpdart`
  /// packages.
  void _addPredefinedStackTraceBlocklist() {
    final stackTraceBlocklistAddons = [
      RegExp(r'(packages\/|package:)codenic_exception_converter'),
      RegExp(r'(packages\/|package:)codenic_bloc_use_case'),
      RegExp(r'(packages\/|package:)fpdart'),
      RegExp(r'^<asynchronous suspension>$'),
    ];

    if (logger.printer.stackTraceBlocklist.isEmpty) {
      logger.printer.stackTraceBlocklist.addAll(stackTraceBlocklistAddons);
    } else {
      for (final regExpAddon in stackTraceBlocklistAddons) {
        var isAlreadyAdded = false;

        for (final regExp in logger.printer.stackTraceBlocklist) {
          if (regExp.pattern == regExpAddon.pattern) {
            isAlreadyAdded = true;
            continue;
          }
        }

        if (!isAlreadyAdded) {
          logger.printer.stackTraceBlocklist.add(regExpAddon);
        }
      }
    }
  }

  /// The default [ErrorConverter]s used to convert errors into [Failure]s.
  ///
  /// Here you can provide your own default [ErrorConverter]s to convert
  /// errors into [Failure]s which will be used by the [observe] and
  /// [convert] methods.
  final List<ErrorConverterFactory> defaultErrorConverters;

  /// The default logger used by [observe].
  final CodenicLogger logger;

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
    required FutureOr<Either<Failure, T>> Function(MessageLog? messageLog) task,
    List<ErrorConverter<Object, T>>? errorConverters,
    MessageLog? messageLog,
    bool printOutput = false,
  }) async {
    final extendedErrorConverters =
        _extendedErrorConverters<T>(errorConverters);

    return await extendedErrorConverters
        .fold<FutureOr<Either<Failure, T>> Function(MessageLog? messageLog)>(
      (messageLog) async {
        final result = await task(messageLog);

        if (messageLog != null) {
          if (printOutput) messageLog.data['__output__'] = result;

          result.fold(
            (l) => logger.warn(messageLog),
            (r) => logger.info(messageLog),
          );
        }

        return result;
      },
      (task, element) => (messageLog) => element.observe(
            task: task,
            logger: logger,
            messageLog: messageLog,
            printOutput: printOutput,
          ),
    )(messageLog);
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
        FallbackExceptionConverter<T>(),
      ];
}
