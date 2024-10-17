import 'package:domain/domain.dart';
import 'package:domain/note/entities/note_entry.dart';

/// {@template NoteContentTooLongFailure}
/// A failure representing a [NoteEntry.content] that has exceeded the maximum
/// length.
/// {@endtemplate}
class NoteContentTooLongFailure extends Failure {
  /// {@macro NoteContentTooLongFailure}
  const NoteContentTooLongFailure({
    super.message = 'The note content is too long',
  });
}
