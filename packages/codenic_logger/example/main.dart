import 'package:codenic_logger/codenic_logger.dart';

final codenicLogger = CodenicLogger();

void main() {
  // To run, type `dart --enable-asserts example/main.dart`.

  completeLogWithUserId();
  updateMessageLog();
  logError();
  logLevels();
}

void completeLogWithUserId() {
  final messageLog = MessageLog(
    id: 'complete_log_with_user_id',
    message: 'Log success',
    data: <String, dynamic>{'lorep': 'ipsum', 'mauris': 42},
  );

  // Assign then remove user ID after printing.

  codenicLogger
    ..userId = 'sample-uid'
    ..trace(messageLog..message = 'Has user ID')
    ..userId = null;
}

void updateMessageLog() {
  final messageLog = MessageLog(id: 'update_message_log');

  codenicLogger.trace(
    messageLog
      ..message = 'Update message log success'
      ..data.addAll(<String, dynamic>{'lorep': 'ipsum', 'mauris': 42}),
  );
}

void logError() {
  final messageLog = MessageLog(id: 'log_error');

  // throw Exception('Test exception');

  try {
    throw Exception('Test exception');
  } catch (exception, stackTrace) {
    codenicLogger.error(
      messageLog..message = 'An unknown error occurred',
      error: exception,
      stackTrace: stackTrace,
    );
  }
}

void logLevels() {
  final messageLog = MessageLog(id: 'log_levels');

  codenicLogger
    ..trace(messageLog..message = 'Trace log success')
    ..debug(messageLog..message = 'Debug log success')
    ..info(messageLog..message = 'Info log success')
    ..warn(messageLog..message = 'Warn log success')
    ..error(messageLog..message = 'Error log success')
    ..fatal(messageLog..message = 'Fatal log success');
}
