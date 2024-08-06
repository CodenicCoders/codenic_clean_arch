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
    this.exceptionConverters = const [],
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
  /// This is used by [observe] and [convert].
  final List<ExceptionConverterFactory> exceptionConverters;

  /// The default logger used by [observe].
  final CodenicLogger logger;

  List<ExceptionConverter<Exception, T>> _exceptionConverters<T>() {
    return exceptionConverters.map((e) => e<T>()).toList();
  }

  /// Converts any uncaught [Exception] thrown by the [task] into a [Failure].
  ///
  /// A [messageLog](https://arch.codenic.dev/packages/codenic-logger)
  /// can be provided to log the result of the [task] after completion. If
  /// [printOutput] is `true`, then the returned output of the [task] is
  /// printed in the [messageLog].
  ///
  /// If no error occurs, then value [T] is returned.
  ///
  /// If an [Exception] is thrown, then it is handled by the
  /// [exceptionConverters] and [ExceptionConverterSuite.exceptionConverters].
  ///
  /// If the [Exception] does not have an exception converter, then it will be
  /// converted to [Failure] by default using the [FallbackExceptionConverter].
  ///
  /// NOTE:
  /// -  [Error]s are not caught by this method considering that it is bad
  /// practice to catch an [Error].
  /// See https://groups.google.com/a/dartlang.org/g/misc/c/lx9CXiV3o30/m/s5l_PwpHUGAJ.
  Future<Either<Failure, T>> observe<T>({
    required FutureOr<Either<Failure, T>> Function(MessageLog? messageLog) task,
    List<ExceptionConverter<Exception, T>>? exceptionConverters,
    MessageLog? messageLog,
    bool printOutput = false,
  }) async {
    final extendedExceptionConverters =
        _extendedExceptionConverters<T>(exceptionConverters);

    return extendedExceptionConverters
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
      (previousValue, element) => (messageLog) => element.observe(
            task: previousValue,
            logger: logger,
            messageLog: messageLog,
            printOutput: printOutput,
          ),
    )(messageLog);
  }

  /// Converts the given [error] into a [Failure].
  ///
  /// The [error] is expected to be an [Exception] object.
  ///
  /// If the given [error] is an [Error], then it is re-thrown. For more info,
  /// see https://stackoverflow.com/a/57004304.
  ///
  /// If the given [error] is not an [Exception], then an [ArgumentError] is
  /// thrown.
  Failure convert({
    required Object error,
    List<ExceptionConverter<Exception, void>>? exceptionConverters,
  }) {
    if (error is! Exception) {
      throw ArgumentError(
        'The given error is not an Exception: ${error.runtimeType}',
      );
    }

    final extendedExceptionConverters =
        _extendedExceptionConverters(exceptionConverters);

    for (final exceptionConverter in extendedExceptionConverters) {
      if (exceptionConverter.exceptionEquals(error)) {
        return exceptionConverter.convert(error);
      }
    }

    // coverage:ignore-start
    throw StateError(
      'No matching exception conversion found for ${error.runtimeType}',
    );
    // coverage:ignore-end
  }

  List<ExceptionConverter<Exception, T>> _extendedExceptionConverters<T>(
    List<ExceptionConverter<Exception, T>>? exceptionConverters,
  ) =>
      [
        ...?exceptionConverters,
        ..._exceptionConverters<T>(),
        FallbackExceptionConverter<T>(),
      ];
}
