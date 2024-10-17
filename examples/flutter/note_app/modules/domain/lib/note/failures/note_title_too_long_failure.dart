import 'package:domain/domain.dart';
import 'package:domain/note/entities/note_entry.dart';

/// {@template NoteTitleTooLongFailure}
/// A failure representing a [NoteEntry.title] that has exceeded the maximum
/// length.
/// {@endtemplate}
class NoteTitleTooLongFailure extends Failure {
  /// {@macro NoteTitleTooLongFailure}
  const NoteTitleTooLongFailure({super.message = 'The note title is too long'});
}
