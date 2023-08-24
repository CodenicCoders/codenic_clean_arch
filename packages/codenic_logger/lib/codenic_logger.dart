import 'package:codenic_logger/src/message_log.dart';
import 'package:codenic_logger/src/message_log_printer.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

export 'package:codenic_logger/src/message_log.dart';
export 'package:codenic_logger/src/message_log_printer.dart';
export 'package:logger/logger.dart';

/// {@template CodenicLogger}
///
/// Creates a logger that appropriately displays information from a
/// [MessageLog].
///
/// {@endtemplate}
class CodenicLogger {
  /// {@macro CodenicLogger}
  CodenicLogger({
    this.filter,
    this.output,
    this.level,
    MessageLogPrinter? printer,
  }) : printer = printer ?? MessageLogPrinter() {
    _logger = Logger(
      printer: this.printer,
      filter: filter,
      output: output,
      level: level,
    );
  }

  /// See [MessageLogPrinter].
  final MessageLogPrinter printer;

  /// See [LogFilter].
  final LogFilter? filter;

  /// See [LogOutput].
  final LogOutput? output;

  /// See [Level].
  final Level? level;

  /// An instance of the [logger package](https://pub.dev/packages/logger) used
  /// for generating log outputs.
  late final Logger _logger;

  /// Associates the log messages with this user ID.
  String? userId;

  /// If the [userId] is not `null`, then this appends the [userId] in the
  /// [messageLog]'s data. Otherwise, [messageLog] is returned without any
  /// changes.
  MessageLog _tryAppendUserIdToMessageLog(MessageLog messageLog) =>
      userId != null
          ? messageLog.copyWith(
              data: <String, dynamic>{
                '__uid__': userId,
                ...messageLog.data,
              },
            )
          : messageLog;

  /// Logs a message at trace level.
  ///
  /// The [error] refers to the caught exception or error.
  ///
  /// The [stackTrace] conveys information about the call sequence that
  /// triggered the [error].
  @mustCallSuper
  void trace(
    MessageLog messageLog, {
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      _logger.t(
        _tryAppendUserIdToMessageLog(messageLog),
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs a message at debug level.
  ///
  /// The [error] refers to the caught exception or error.
  ///
  /// The [stackTrace] conveys information about the call sequence that
  /// triggered the [error].
  @mustCallSuper
  void debug(MessageLog messageLog, {dynamic error, StackTrace? stackTrace}) =>
      _logger.d(
        _tryAppendUserIdToMessageLog(messageLog),
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs a message at info level.
  ///
  /// The [error] refers to the caught exception or error.
  ///
  /// The [stackTrace] conveys information about the call sequence that
  /// triggered the [error].
  @mustCallSuper
  void info(MessageLog messageLog, {dynamic error, StackTrace? stackTrace}) =>
      _logger.i(
        _tryAppendUserIdToMessageLog(messageLog),
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs a message at warn level.
  ///
  /// The [error] refers to the caught exception or error.
  ///
  /// The [stackTrace] conveys information about the call sequence that
  /// triggered the [error].
  @mustCallSuper
  void warn(MessageLog messageLog, {dynamic error, StackTrace? stackTrace}) =>
      _logger.w(
        _tryAppendUserIdToMessageLog(messageLog),
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs a message at error level.
  ///
  /// The [error] refers to the caught exception or error.
  ///
  /// The [stackTrace] conveys information about the call sequence that
  /// triggered the [error].
  @mustCallSuper
  void error(MessageLog messageLog, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e(
        _tryAppendUserIdToMessageLog(messageLog),
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs a message at fatal level.
  ///
  /// The [error] refers to the caught exception or error.
  ///
  /// The [stackTrace] conveys information about the call sequence that
  /// triggered the [error].
  @mustCallSuper
  void fatal(MessageLog messageLog, {dynamic error, StackTrace? stackTrace}) =>
      _logger.f(
        _tryAppendUserIdToMessageLog(messageLog),
        error: error,
        stackTrace: stackTrace,
      );

  /// Closes the logger releases all resources.
  void close() => _logger.close();

  /// Creates a new [CodenicLogger] with the value replaced by the non-null.
  CodenicLogger copyWith({
    MessageLogPrinter? printer,
    LogFilter? filter,
    LogOutput? output,
    Level? level,
  }) =>
      CodenicLogger(
        printer: printer ?? this.printer,
        filter: filter ?? this.filter,
        output: output ?? this.output,
        level: level ?? this.level,
      );
}
