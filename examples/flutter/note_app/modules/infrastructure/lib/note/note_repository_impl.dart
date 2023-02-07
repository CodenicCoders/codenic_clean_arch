import 'dart:async';

import 'package:domain/domain.dart';
import 'package:domain/note/entities/note_entry.dart';
import 'package:domain/note/failures/note_content_too_long_failure.dart';
import 'package:domain/note/failures/note_title_too_long_failure.dart';
import 'package:domain/note/repositories/note_repository.dart';
import 'package:infrastructure/data_sources/sqlbrite/sqlbrite_data_source.dart';

/// {@template NoteRepositoryImpl}
/// See [NoteRepository].
/// {@endtemplate}
class NoteRepositoryImpl extends NoteRepository {
  /// {@macro NoteRepositoryImpl}
  NoteRepositoryImpl({
    required ExceptionConverterSuite exceptionConverterSuite,
    required SqlbriteDataSource sqlbriteDataSource,
  })  : _exceptionConverterSuite = exceptionConverterSuite,
        _sqlbriteDataSource = sqlbriteDataSource;

  /// A utility tool for converting [Exception]s to [Failure]s.
  final ExceptionConverterSuite _exceptionConverterSuite;

  /// The SQLBrite data source instance for persisting note entries.
  final SqlbriteDataSource _sqlbriteDataSource;

  @override
  FutureOr<Either<Failure, void>> createNoteEntry(
      {String? title, String? content}) {
    return _exceptionConverterSuite.observe(
      messageLog: MessageLog(id: 'create-note-entry')
        ..data.addAll({'title': title, 'content': content}),
      task: (messageLog) async {
        if (title != null && title.length > 24) {
          return const Left(NoteTitleTooLongFailure());
        }

        if (content != null && content.length > 128) {
          return const Left(NoteContentTooLongFailure());
        }

        await _sqlbriteDataSource.createNoteEntry(
          title: title ?? '',
          content: content ?? '',
        );

        return const Right(null);
      },
    );
  }

  @override
  FutureOr<Either<Failure, void>> updateNoteEntry(
      {required String id, String? title, String? content}) {
    assert(title != null || content != null);

    return _exceptionConverterSuite.observe(
      messageLog: MessageLog(id: 'update-note-entry')
        ..data.addAll({'id': id, 'title': title, 'content': content}),
      task: (messageLog) async {
        await _sqlbriteDataSource.updateNoteEntry(
          id: id,
          title: title,
          content: content,
        );

        return const Right(null);
      },
    );
  }

  @override
  FutureOr<Either<Failure, void>> deleteNoteEntry({required String id}) {
    return _exceptionConverterSuite.observe(
      messageLog: MessageLog(id: 'delete-note-entry')..data.addAll({'id': id}),
      task: (messageLog) async {
        await _sqlbriteDataSource.deleteNoteEntry(id: id);
        return const Right(null);
      },
    );
  }

  @override
  FutureOr<Either<Failure, List<NoteEntry>>> fetchNoteEntries(
      {int? limit, pageToken}) {
    return _exceptionConverterSuite.observe(
      messageLog: MessageLog(id: 'fetch-note-entries')
        ..data.addAll({'limit': limit, 'nextToken': pageToken}),
      task: (messageLog) async {
        final noteEntries = await _sqlbriteDataSource.fetchNoteEntries(
          limit: limit ?? 10,
          offset: pageToken,
        );

        return Right(noteEntries.map((e) => e.toEntity()).toList());
      },
    );
  }

  @override
  FutureOr<Either<Failure, VerboseStream<Failure, List<NoteEntry>>>>
      watchNoteEntries({int? limit}) async {
    return _exceptionConverterSuite.observe(
      messageLog: MessageLog(id: 'watch-note-entries')
        ..data.addAll({'limit': limit}),
      task: (messageLog) async {
        final stream = _sqlbriteDataSource
            .watchRecentNoteEntries(limit: limit ?? 10)
            .map((event) => event.map((e) => e.toEntity()).toList());

        // A `VerboseStream` is a stream wrapper that enables the conversion
        // of an error into another object (in our case, a `Failure` object)
        // before it is emitted.
        return Right(
          VerboseStream(
            errorConverter: (error, stackTrace) =>
                _exceptionConverterSuite.convert(
              messageLog: messageLog,
              error: error,
              stackTrace: stackTrace,
            ),
            stream: stream,
          ),
        );
      },
    );
  }
}
