import 'dart:async';

import 'package:codenic_bloc_use_case/codenic_bloc_use_case.dart';
import 'package:codenic_exception_converter/codenic_exception_converter.dart';
import 'package:domain/note/entities/note_entry.dart';
import 'package:domain/note/failures/note_content_too_long_failure.dart';
import 'package:domain/note/failures/note_title_too_long_failure.dart';

/// {@template NoteRepository}
/// A repository for managing [NoteEntry]s.
/// {@endtemplate}
abstract class NoteRepository {
  /// {@macro NoteRepository}
  const NoteRepository();

  /// Creates a new [NoteEntry] initialized the given [title] and [content].
  ///
  /// A [Failure] may be thrown:
  /// - [NoteContentTooLongFailure]
  /// - [NoteTitleTooLongFailure]
  FutureOr<Either<Failure, void>> createNoteEntry({
    String? title,
    String? content,
  });

  /// Updates the [NoteEntry] referenced by the given [id].
  ///
  /// A [Failure] may be thrown:
  /// - [NoteContentTooLongFailure]
  /// - [NoteTitleTooLongFailure]
  FutureOr<Either<Failure, void>> updateNoteEntry({
    required String id,
    String? title,
    String? content,
  });

  /// Deletes an existing [NoteEntry] with the given [id].
  FutureOr<Either<Failure, void>> deleteNoteEntry({required String id});

  /// Fetches a collection of [NoteEntry]s.
  ///
  /// The [limit] parameter can be used to limit the number of entries.
  /// The [pageToken] parameter can be used to fetch a specific page of entries.
  FutureOr<Either<Failure, List<NoteEntry>>> fetchNoteEntries({
    int? limit,
    dynamic pageToken,
  });

  /// Streams a collection of [NoteEntry]s.
  ///
  /// The [limit] parameter can be used to limit the number of entries.
  ///
  /// A [VerboseStream] is a [Stream] wrapper which gives it an error
  /// handler for converting [Exception]s into [Failure]s before it gets
  /// emitted
  FutureOr<Either<Failure, VerboseStream<Failure, List<NoteEntry>>>>
      watchNoteEntries({int? limit});
}
