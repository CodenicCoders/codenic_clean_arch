import 'dart:async';

import 'package:codenic_exception_converter/codenic_exception_converter.dart';
import 'package:codenic_exception_converter/src/exception_converters/fallback_exception_converter.dart';

/// A signature for [ExceptionConverter] factories.
typedef ExceptionConverterFactory = ExceptionConverter<Exception, T>
    Function<T>();

/// {@template ExceptionConverter}
/// A class which allows multiple [ExceptionConverter]s to be grouped together,
/// so that when a task is executed and an exception is thrown, it can be
/// converted into the appropriate [Failure] object.
/// {@endtemplate}
class ExceptionConverterSuite {
  /// {@macro ExceptionConverter}
  ExceptionConverterSuite({
    this.defaultExceptionConverters = const [],
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

  /// The default [ExceptionConverter]s used to convert [Exception]s into
  /// [Failure]s.
  ///
  /// Here you can provide your own default [ExceptionConverter]s to convert
  /// [Exception]s into [Failure]s which will be used by the [observe] and
  /// [convert] methods.
  final List<ExceptionConverterFactory> defaultExceptionConverters;

  /// The default logger used by [observe].
  final CodenicLogger logger;

  /// Converts any uncaught [Exception] thrown by the [task] into a [Failure].
  ///
  /// A [messageLog](https://arch.codenic.dev/packages/codenic-logger)
  /// can be provided to log the result of the [task] after completion. If
  /// [printOutput] is `true`, then the returned output of the [task] is
  /// printed in the [messageLog].
  ///
  /// If no error occurs, then value [T] is returned.
  ///
  /// If an [Exception] is thrown, then it will be converted into a [Failure]
  /// using the [ExceptionConverter]s provided in the [exceptionConverters]
  /// and [ExceptionConverterSuite.defaultExceptionConverters], if any. If no
  /// matching [ExceptionConverter] is found, then the
  /// [FallbackExceptionConverter] will be used.
  ///
  /// If an [Error] is thrown, then it will be rethrown or handled by the
  /// [onError] function, if provided.
  FutureOr<Either<Failure, T>> observe<T>({
    required FutureOr<Either<Failure, T>> Function(MessageLog? messageLog) task,
    List<ExceptionConverter<Exception, T>>? exceptionConverters,
    MessageLog? messageLog,
    bool printOutput = false,
    FutureOr<Either<Failure, T>> Function(Error error, StackTrace stacktrace)?
        onError,
  }) async {
    final extendedExceptionConverters =
        _extendedExceptionConverters<T>(exceptionConverters);

    try {
      return await extendedExceptionConverters
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
    // ignore: avoid_catching_errors
    on Error catch (error, stacktrace) {
      if (onError != null) return onError(error, stacktrace);
      rethrow;
    }
  }

  /// Converts the given [exception] into a [Failure].
  ///
  /// The [exception] is expected to be an [Exception] object.
  Failure convert({
    required Exception exception,
    List<ExceptionConverter<Exception, void>>? exceptionConverters,
  }) {
    final extendedExceptionConverters =
        _extendedExceptionConverters(exceptionConverters);

    for (final exceptionConverter in extendedExceptionConverters) {
      if (exceptionConverter.exceptionEquals(exception)) {
        return exceptionConverter.convert(exception);
      }
    }

    // coverage:ignore-start
    throw StateError(
      'No matching exception conversion found for ${exception.runtimeType}',
    );
    // coverage:ignore-end
  }

  List<ExceptionConverter<Exception, T>> _extendedExceptionConverters<T>(
    List<ExceptionConverter<Exception, T>>? exceptionConverters,
  ) =>
      [
        ...?exceptionConverters,
        ...defaultExceptionConverters.map((e) => e<T>()),
        FallbackExceptionConverter<T>(),
      ];
}
